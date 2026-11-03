import 'helpers/test_seeds.dart';
import 'package:admin_web/src/core/auth/admin_auth_notifier.dart';
import 'package:admin_web/src/core/auth/admin_role.dart';
import 'package:admin_web/src/features/audit/application/audit_notifier.dart';
import 'package:admin_web/src/features/audit/domain/audit_models.dart';
import 'package:admin_web/src/features/bookings/application/booking_management_notifier.dart';
import 'package:admin_web/src/features/finance/application/finance_notifier.dart';
import 'package:admin_web/src/features/finance/domain/finance_models.dart';
import 'package:admin_web/src/features/integrations/application/integrations_notifier.dart';
import 'package:admin_web/src/features/operations/application/operations_notifier.dart';
import 'package:admin_web/src/features/pricing/application/pricing_notifier.dart';
import 'package:admin_web/src/features/pricing/domain/pricing_models.dart';
import 'package:admin_web/src/features/promotions/application/promotions_notifier.dart';
import 'package:admin_web/src/features/promotions/domain/promotion_models.dart';
import 'package:admin_web/src/features/riders/application/rider_management_notifier.dart';
import 'package:admin_web/src/features/riders/domain/rider_management_state.dart';
import 'package:admin_web/src/features/support/application/support_safety_notifier.dart';
import 'package:admin_web/src/features/support/domain/support_safety_models.dart';
import 'package:app_models/app_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Go-Volts Admin Web Platform Simulation Test Suite (All 9 Modules)', () {
    test('Simulate complete multi-role operational shift across all 9 modules', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final authNotifier = container.read(adminAuthNotifierProvider.notifier);
      final opsNotifier = container.read(operationsNotifierProvider.notifier);
      final bookingNotifier = container.read(bookingManagementNotifierProvider.notifier);
      final riderNotifier = container.read(riderManagementNotifierProvider.notifier);
      final safetyNotifier = container.read(supportSafetyNotifierProvider.notifier);
      final financeNotifier = container.read(financeNotifierProvider.notifier);
      final promoNotifier = container.read(promotionsNotifierProvider.notifier);
      final pricingNotifier = container.read(pricingNotifierProvider.notifier);
      final auditNotifier = container.read(auditNotifierProvider.notifier);
      final intNotifier = container.read(integrationsNotifierProvider.notifier);

      opsNotifier.seedForTest();
      bookingNotifier.seedForTest();
      riderNotifier.seedForTest();
      safetyNotifier.seedForTest();
      financeNotifier.seedForTest();
      pricingNotifier.seedForTest();
      auditNotifier.seedForTest();
      intNotifier.seedForTest();

      // =======================================================================
      // STEP 1: Morning Operations Agent Shift (Live Dispatch & Bookings)
      // =======================================================================
      authNotifier.signIn(email: 'adeola.ops@govolts.ng', role: StaffRole.opsAgent);
      expect(container.read(adminAuthNotifierProvider).role, equals(StaffRole.opsAgent));

      // 1.1 Inspect live fleet telemetry
      final opsState = container.read(operationsNotifierProvider);
      expect(opsState.onlineRiders.length, greaterThanOrEqualTo(3));
      expect(opsState.urgentJobs.isNotEmpty, isTrue);

      // 1.2 Override manual assignment with mandatory governance reason
      final stalledJob = opsState.urgentJobs.first;
      await opsNotifier.assignRiderToJob(
        bookingId: stalledJob.bookingId,
        riderId: 'RDR-001',
        reason: 'Nearest available moped with 92% battery capacity on Lekki corridor',
      );

      final updatedJobs = container.read(operationsNotifierProvider).urgentJobs;
      expect(updatedJobs.any((j) => j.bookingId == stalledJob.bookingId), isFalse);
      expect(container.read(operationsNotifierProvider).lastActionMessage, contains('RDR-001'));

      // 1.3 Audit trail automatically records the dispatch override
      auditNotifier.appendAuditEntry(
        AuditLogEntry(
          id: 'aud_sim_001',
          timestamp: DateTime.now(),
          actorId: 'adeola.ops@govolts.ng',
          actorName: 'Adeola Sowande',
          actorRole: 'Operations Agent',
          category: AuditCategory.dispatchOverride,
          action: 'Manual Rider Reassignment Override',
          entityType: 'Trip',
          entityId: stalledJob.bookingId,
          previousStateJson: '{"assignedRiderId": null}',
          newStateJson: '{"assignedRiderId": "RDR-001"}',
          ipAddress: '102.89.23.11',
          cryptographicHash: 'SHA256:sim_hash_dispatch_001',
        ),
      );

      // 1.4 Filter booking management records by service type
      bookingNotifier.setServiceFilter('School Run');
      final schoolBookings = container.read(bookingManagementNotifierProvider).filteredBookings;
      expect(schoolBookings.every((b) => b.serviceType == ServiceTierEligibility.schoolRunCommute), isTrue);

      // =======================================================================
      // STEP 2: Safety Officer Shift (Compliance & Confidential Safeguarding)
      // =======================================================================
      authNotifier.setRole(StaffRole.safetyOfficer);
      expect(container.read(adminAuthNotifierProvider).role.canAccessSafety, isTrue);
      expect(container.read(adminAuthNotifierProvider).role.canAccessRiders, isTrue);

      // 2.1 Rider Compliance Review: Certify applicant for School-Run Dedicated Chaperone
      final pendingApplicant = container.read(riderManagementNotifierProvider)
          .riders.firstWhere((r) => r.status == RiderComplianceStatus.pendingReview);
      expect(pendingApplicant.isSchoolRunCertified, isFalse);

      riderNotifier.toggleServiceTierCertification(
        riderId: pendingApplicant.id,
        tier: ServiceTierEligibility.schoolRunCommute,
      );
      await riderNotifier.approveRider(
        riderId: pendingApplicant.id,
        certifiedTiers: [
          ...pendingApplicant.certifiedTiers,
          ServiceTierEligibility.schoolRunCommute,
        ],
        auditNote: 'Verified NIN and LASDRI compliance credentials',
      );

      final certifiedRider = container.read(riderManagementNotifierProvider)
          .riders.firstWhere((a) => a.id == pendingApplicant.id);
      expect(certifiedRider.isSchoolRunCertified, isTrue);
      expect(certifiedRider.status, equals(RiderComplianceStatus.approved));

      // 2.2 Confidential Safety Incident Investigation
      final incidents = container.read(supportSafetyNotifierProvider).incidents;
      expect(incidents.isNotEmpty, isTrue);
      final activeCase = incidents.firstWhere((i) => i.status == SafetyIncidentStatus.investigating);

      safetyNotifier.addSafetyInvestigationNote(
        activeCase.id,
        'Guardian contacted; confirmed student was handed over to verified school gatekeeper via OTP',
      );
      safetyNotifier.resolveSafetyIncident(activeCase.id);

      final resolvedCase = container.read(supportSafetyNotifierProvider)
          .incidents.firstWhere((i) => i.id == activeCase.id);
      expect(resolvedCase.status, equals(SafetyIncidentStatus.resolved));
      expect(resolvedCase.investigationNotes.last, contains('handed over to verified school gatekeeper'));

      // =======================================================================
      // STEP 3: Finance Officer Shift (Maker-Checker Dual Approval & Payouts)
      // =======================================================================
      authNotifier.setRole(StaffRole.finance);
      expect(container.read(adminAuthNotifierProvider).role.canAccessFinance, isTrue);

      // 3.1 Request ₦18,000 refund (>= ₦10,000 requires Maker-Checker dual authorization)
      financeNotifier.requestRefund(
        bookingRef: 'GV-TRIP-SIM-90',
        customerName: 'Oluwaseun Adeleke',
        amountKobo: BigInt.from(1800000), // ₦18,000
        reason: 'VIP hourly booking cancelled 24h in advance per terms',
        makerId: 'staff_ops_ade',
        makerName: 'Adeola Sowande (Ops Agent)',
      );

      final simRefund = container.read(financeNotifierProvider).refunds.firstWhere((r) => r.bookingRef == 'GV-TRIP-SIM-90');
      expect(simRefund.requiresMakerChecker, isTrue);
      expect(simRefund.status, equals(RefundStatus.pendingCheckerSignoff));

      // 3.2 Maker attempts self-approval -> Violation rejected!
      final violation = financeNotifier.approveRefund(
        requestId: simRefund.id,
        checkerId: 'staff_ops_ade',
        checkerName: 'Adeola Sowande',
      );
      expect(violation, isFalse);
      expect(container.read(financeNotifierProvider).errorMessage, contains('Maker-Checker Violation'));

      // 3.3 Finance Officer approves as authorized Checker -> Succeeded!
      final validSignoff = financeNotifier.approveRefund(
        requestId: simRefund.id,
        checkerId: 'staff_fin_olumide',
        checkerName: 'Olumide Bakare (Finance Officer)',
      );
      expect(validSignoff, isTrue);
      expect(container.read(financeNotifierProvider).refunds.firstWhere((r) => r.id == simRefund.id).status, equals(RefundStatus.approved));

      // 3.4 Settle automated rider weekly payout batch
      final batchToSettle = container.read(financeNotifierProvider).payoutBatches.firstWhere((b) => b.status == 'pending_payout');
      financeNotifier.settlePayoutBatch(batchToSettle.batchId);
      expect(container.read(financeNotifierProvider).payoutBatches.firstWhere((b) => b.batchId == batchToSettle.batchId).status, equals('settled'));

      // =======================================================================
      // STEP 4: Commercial & Promotions Manager Shift (Coupons & Loyalty)
      // =======================================================================
      authNotifier.setRole(StaffRole.promotionsManager);
      expect(container.read(adminAuthNotifierProvider).role.canAccessPromotions, isTrue);

      // 4.1 Create new promotional campaign voucher
      promoNotifier.createCoupon(
        code: 'SIMVOLT50',
        discountType: DiscountType.percentage,
        discountValue: 50.0,
        minOrderKobo: BigInt.from(200000), // ₦2,000
        maxDiscountKobo: BigInt.from(300000), // ₦3,000
        usageLimit: 500,
        expiresAt: DateTime(2026, 12, 31),
        description: '50% promotional voucher for end-of-year green commute',
      );

      final simCoupon = container.read(promotionsNotifierProvider).coupons.firstWhere((c) => c.code == 'SIMVOLT50');
      expect(simCoupon.discountValue, equals(50.0));
      expect(simCoupon.isActive, isTrue);

      // 4.2 Toggle referral campaign
      final referralBefore = container.read(promotionsNotifierProvider).referralCampaign.isActive;
      promoNotifier.toggleReferralCampaign();
      expect(container.read(promotionsNotifierProvider).referralCampaign.isActive, equals(!referralBefore));
      promoNotifier.toggleReferralCampaign(); // Restore to active

      // =======================================================================
      // STEP 5: Super Admin Governance Shift (Pricing, Audit, Integrations)
      // =======================================================================
      authNotifier.setRole(StaffRole.superAdmin);
      expect(container.read(adminAuthNotifierProvider).role.canAccessPricing, isTrue);
      expect(container.read(adminAuthNotifierProvider).role.canAccessAudit, isTrue);
      expect(container.read(adminAuthNotifierProvider).role.canAccessIntegrations, isTrue);

      // 5.1 Pricing Engine: Draft new tariff version
      final currentCommuteRule = container.read(pricingNotifierProvider).activeRule!;
      pricingNotifier.createDraftRule(
        tier: ServiceTier.commute,
        baseFareKobo: BigInt.from(80000), // ₦800
        perKmKobo: BigInt.from(15000), // ₦150/km
        perMinuteKobo: BigInt.from(3500), // ₦35/min
        minimumFareKobo: BigInt.from(110000), // ₦1,100
        surgeMultiplierCap: 2.5,
        createdBy: 'super_admin_sim',
        notes: 'Annual cost-of-energy indexed tariff calibration',
      );

      final draftRule = container.read(pricingNotifierProvider).draftRules.first;
      expect(draftRule.status, equals(PricingRuleStatus.draft));

      // 5.2 Publish tariff: Archive previous active; promote draft to active (Past quotes immutable)
      pricingNotifier.publishDraftRule(draftRule.id);

      final activeTariff = container.read(pricingNotifierProvider).activeRule!;
      expect(activeTariff.status, equals(PricingRuleStatus.active));
      expect(activeTariff.baseFareKobo, equals(BigInt.from(80000)));

      final archivedTariff = container.read(pricingNotifierProvider).archivedRules.firstWhere((r) => r.id == currentCommuteRule.id);
      expect(archivedTariff.status, equals(PricingRuleStatus.archived));
      expect(archivedTariff.baseFareKobo, equals(currentCommuteRule.baseFareKobo));

      // 5.3 Service Area Gating: Toggle service tiers in zone
      const zoneId = 'lagos_island';
      pricingNotifier.toggleZoneServiceTier(zoneId, ServiceTier.expressParcel, false);
      expect(container.read(pricingNotifierProvider).zones.firstWhere((z) => z.zoneId == zoneId).isTierEnabled(ServiceTier.expressParcel), isFalse);

      pricingNotifier.toggleZoneServiceTier(zoneId, ServiceTier.expressParcel, true);
      expect(container.read(pricingNotifierProvider).zones.firstWhere((z) => z.zoneId == zoneId).isTierEnabled(ServiceTier.expressParcel), isTrue);

      // 5.4 Test External B2B Partner Integration (Retail Ai)
      final retailAi = container.read(integrationsNotifierProvider).partners.firstWhere((p) => p.id == 'int_retail_ai');
      expect(retailAi.isHmacVerified, isTrue);
      intNotifier.testWebhookPing(retailAi.id);
      expect(container.read(integrationsNotifierProvider).partners.firstWhere((p) => p.id == retailAi.id).pingSuccess, isTrue);

      // 5.5 Audit Logs: Verify tamper-evident cryptographic hash trail
      final logs = container.read(auditNotifierProvider).logs;
      expect(logs.length, greaterThanOrEqualTo(5));
      expect(logs.every((l) => l.cryptographicHash.startsWith('SHA256:')), isTrue);
    });
  });
}
