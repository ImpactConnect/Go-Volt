import 'package:admin_web/src/core/auth/admin_auth_notifier.dart';
import 'package:admin_web/src/core/auth/admin_role.dart';
import 'package:admin_web/src/features/audit/application/audit_notifier.dart';
import 'package:admin_web/src/features/audit/domain/audit_models.dart';
import 'package:admin_web/src/features/finance/application/finance_notifier.dart';
import 'package:admin_web/src/features/finance/domain/finance_models.dart';
import 'package:admin_web/src/features/finance/presentation/finance_management_screen.dart';
import 'package:admin_web/src/features/integrations/application/integrations_notifier.dart';
import 'package:admin_web/src/features/promotions/application/promotions_notifier.dart';
import 'package:admin_web/src/features/promotions/domain/promotion_models.dart';
import 'package:admin_web/src/features/support/application/support_safety_notifier.dart';
import 'package:admin_web/src/features/support/domain/support_safety_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Finance & Maker-Checker Dual Approval Tests (§6.8)', () {
    test('Refunds >= ₦10,000 require Maker-Checker dual approval; self-approval is rejected', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(financeNotifierProvider.notifier);

      // 1. Request refund >= ₦10,000 (e.g. ₦12,500 = 1,250,000 kobo)
      notifier.requestRefund(
        bookingRef: 'GV-TRIP-9901',
        customerName: 'Aisha Bello',
        amountKobo: BigInt.from(1250000), // ₦12,500
        reason: 'Motorcycle powertrain failure midway on Lekki-Epe expressway',
        makerId: 'staff_ops_kemi',
        makerName: 'Kemi Balogun (Ops Agent)',
      );

      final stateAfterRequest = container.read(financeNotifierProvider);
      final newRefund = stateAfterRequest.refunds.firstWhere((r) => r.bookingRef == 'GV-TRIP-9901');
      expect(newRefund.requiresMakerChecker, isTrue);
      expect(newRefund.status, equals(RefundStatus.pendingCheckerSignoff));

      // 2. Violation attempt: Maker (Kemi) tries to approve her own refund
      final selfApprovalSuccess = notifier.approveRefund(
        requestId: newRefund.id,
        checkerId: 'staff_ops_kemi', // Same as makerId!
        checkerName: 'Kemi Balogun (Ops Agent)',
      );

      expect(selfApprovalSuccess, isFalse);
      expect(container.read(financeNotifierProvider).errorMessage, contains('Maker-Checker Violation'));
      expect(container.read(financeNotifierProvider).refunds.firstWhere((r) => r.id == newRefund.id).status,
          equals(RefundStatus.pendingCheckerSignoff));

      // 3. Valid Maker-Checker Dual Approval: Finance officer (Olumide) approves as distinct Checker
      final validApprovalSuccess = notifier.approveRefund(
        requestId: newRefund.id,
        checkerId: 'staff_fin_olumide', // Distinct from makerId
        checkerName: 'Olumide Bakare (Finance Officer)',
      );

      expect(validApprovalSuccess, isTrue);
      final approvedRefund = container.read(financeNotifierProvider).refunds.firstWhere((r) => r.id == newRefund.id);
      expect(approvedRefund.status, equals(RefundStatus.approved));
      expect(approvedRefund.checkerId, equals('staff_fin_olumide'));
      expect(approvedRefund.checkerTimestamp, isNotNull);
    });

    test('Refunds < ₦10,000 require single review and allow approval', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(financeNotifierProvider.notifier);

      // Request refund < ₦10,000 (e.g. ₦3,000 = 300,000 kobo)
      notifier.requestRefund(
        bookingRef: 'GV-B2B-1122',
        customerName: 'Chidi Mokeme',
        amountKobo: BigInt.from(300000), // ₦3,000
        reason: 'Delivery arrived with dented external carton',
        makerId: 'staff_ops_ade',
        makerName: 'Adeola Sowande',
      );

      final newRefund = container.read(financeNotifierProvider).refunds.firstWhere((r) => r.bookingRef == 'GV-B2B-1122');
      expect(newRefund.requiresMakerChecker, isFalse);
      expect(newRefund.status, equals(RefundStatus.pendingReview));

      final success = notifier.approveRefund(
        requestId: newRefund.id,
        checkerId: 'staff_ops_ade',
        checkerName: 'Adeola Sowande',
      );
      expect(success, isTrue);
      expect(container.read(financeNotifierProvider).refunds.firstWhere((r) => r.id == newRefund.id).status, equals(RefundStatus.approved));
    });

    test('Settling payout batch updates batch status to settled', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(financeNotifierProvider.notifier);
      final pendingBatch = container.read(financeNotifierProvider).payoutBatches.firstWhere((b) => b.status == 'pending_payout');

      notifier.settlePayoutBatch(pendingBatch.batchId);
      final settledBatch = container.read(financeNotifierProvider).payoutBatches.firstWhere((b) => b.batchId == pendingBatch.batchId);
      expect(settledBatch.status, equals('settled'));
      expect(settledBatch.settledAt, isNotNull);
    });

    testWidgets('FinanceManagementScreen renders refund queue and ledger KPIs', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: GVTheme.darkTheme,
            home: const Scaffold(
              body: FinanceManagementScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Finance & Dual Maker-Checker Reconciliation'), findsOneWidget);
      expect(find.text('GROSS PLATFORM GMV'), findsOneWidget);
      expect(find.text('PENDING MAKER-CHECKER'), findsOneWidget);
      expect(find.byKey(const Key('initiate_refund_btn')), findsOneWidget);
    });
  });

  group('Promotions, Support, Audit & Integrations Tests', () {
    test('PromotionsNotifier creates coupon and toggles active status', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(promotionsNotifierProvider.notifier);

      notifier.createCoupon(
        code: 'VOLTFLASH',
        discountType: DiscountType.percentage,
        discountValue: 30.0,
        minOrderKobo: BigInt.from(150000), // ₦1,500
        maxDiscountKobo: BigInt.from(250000), // ₦2,500
        usageLimit: 300,
        expiresAt: DateTime(2026, 12, 1),
        description: 'Flash sale for rainy season EV commutes',
      );

      final created = container.read(promotionsNotifierProvider).coupons.firstWhere((c) => c.code == 'VOLTFLASH');
      expect(created.discountValue, equals(30.0));
      expect(created.isActive, isTrue);

      notifier.toggleCouponStatus('VOLTFLASH');
      expect(container.read(promotionsNotifierProvider).coupons.firstWhere((c) => c.code == 'VOLTFLASH').isActive, isFalse);
    });

    test('PromotionsNotifier dynamically updates loyalty point valuation, thresholds and presets', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(promotionsNotifierProvider.notifier);

      notifier.updateLoyaltyConfig(
        pointsPerHundredNairaSpent: 8,
        pointsRequired: 20,
        creditAmountKobo: 100, // 20 pts = ₦1
        minRedemptionPoints: 300,
        maxRedemptionPoints: 5000,
        presetPoints: [300, 600, 1200, 2400],
      );

      final config = container.read(promotionsNotifierProvider).loyaltyConfig;
      expect(config.pointsPerHundredNairaSpent, equals(8));
      expect(config.pointsRequired, equals(20));
      expect(config.minRedemptionPoints, equals(300));
      expect(config.maxRedemptionPoints, equals(5000));
      expect(config.presetPoints, equals([300, 600, 1200, 2400]));
      expect(config.formattedRate, equals('20 pts = ₦1'));
      expect(config.formattedPresetChips, equals('300, 600, 1200, 2400'));
    });

    test('SupportSafetyNotifier resolves tickets and gates confidential safety incidents', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(supportSafetyNotifierProvider.notifier);

      // Resolve a general support ticket
      final ticket = container.read(supportSafetyNotifierProvider).tickets.first;
      notifier.resolveTicket(ticket.id);
      expect(container.read(supportSafetyNotifierProvider).tickets.firstWhere((t) => t.id == ticket.id).status, equals(TicketStatus.resolved));

      // As SuperAdmin / Safety Officer, append investigation note
      container.read(adminAuthNotifierProvider.notifier).setRole(StaffRole.safetyOfficer);
      final incident = container.read(supportSafetyNotifierProvider).incidents.first;
      final initialNotesCount = incident.investigationNotes.length;

      notifier.addSafetyInvestigationNote(incident.id, 'Parent verified safe arrival via secondary security PIN');
      final updatedIncident = container.read(supportSafetyNotifierProvider).incidents.firstWhere((i) => i.id == incident.id);
      expect(updatedIncident.investigationNotes.length, equals(initialNotesCount + 1));
      expect(updatedIncident.investigationNotes.last, contains('secondary security PIN'));

      // Mark safety incident resolved
      notifier.resolveSafetyIncident(incident.id);
      expect(container.read(supportSafetyNotifierProvider).incidents.firstWhere((i) => i.id == incident.id).status, equals(SafetyIncidentStatus.resolved));
    });

    test('AuditNotifier filters by category and search query', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(auditNotifierProvider.notifier);

      expect(container.read(auditNotifierProvider).filteredLogs.length, equals(4));

      // Filter by dispatch override category
      notifier.setCategory(AuditCategory.dispatchOverride);
      expect(container.read(auditNotifierProvider).filteredLogs.length, equals(1));
      expect(container.read(auditNotifierProvider).filteredLogs.first.category, equals(AuditCategory.dispatchOverride));

      // Reset and search
      notifier.setCategory(null);
      notifier.setSearchQuery('Olumide');
      expect(container.read(auditNotifierProvider).filteredLogs.length, equals(1));
      expect(container.read(auditNotifierProvider).filteredLogs.first.actorName, contains('Olumide'));
    });

    test('IntegrationsNotifier toggles partner and dispatches test ping', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(integrationsNotifierProvider.notifier);
      final partner = container.read(integrationsNotifierProvider).partners.firstWhere((p) => p.id == 'int_retail_ai');

      expect(partner.isActive, isTrue);
      expect(partner.isHmacVerified, isTrue);

      notifier.togglePartner(partner.id);
      expect(container.read(integrationsNotifierProvider).partners.firstWhere((p) => p.id == partner.id).isActive, isFalse);

      notifier.togglePartner(partner.id);
      expect(container.read(integrationsNotifierProvider).partners.firstWhere((p) => p.id == partner.id).isActive, isTrue);

      notifier.testWebhookPing(partner.id);
      expect(container.read(integrationsNotifierProvider).partners.firstWhere((p) => p.id == partner.id).pingSuccess, isTrue);
    });
  });
}
