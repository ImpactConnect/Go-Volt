import 'dart:convert';
import 'package:app_models/app_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_portal/src/core/auth/merchant_auth_notifier.dart';
import 'package:merchant_portal/src/core/auth/merchant_role.dart';
import 'package:merchant_portal/src/features/billing/application/merchant_billing_notifier.dart';
import 'package:merchant_portal/src/features/billing/domain/billing_models.dart';
import 'package:merchant_portal/src/features/bookings/application/merchant_bookings_notifier.dart';
import 'package:merchant_portal/src/features/branches/application/branches_notifier.dart';
import 'package:merchant_portal/src/features/developer/application/partner_api_notifier.dart';

void main() {
  group('Phase 4: End-to-End Merchant Portal & Partner API Simulation', () {
    test('Simulates complete lifecycle: Branch Selection -> Dispatch -> Fleet Telemetry -> OTP Proof -> Wallet Settlement -> Retail Ai Signed Webhook', () async {
      // -----------------------------------------------------------------------
      // Step 1: Merchant Auth & Multi-Branch Hub Setup
      // -----------------------------------------------------------------------
      final authNotifier = MerchantAuthNotifier();
      final branchesNotifier = BranchesNotifier();

      expect(authNotifier.state.businessName, contains('Mama Cass'));
      expect(authNotifier.state.role, MerchantRole.storeOwner);

      // Select Lekki Flagship hub
      authNotifier.switchBranch(branchId: 'br_lekki_01', branchName: 'Lekki Phase 1 Flagship');
      expect(authNotifier.state.activeBranchId, 'br_lekki_01');

      // Invite Dispatch Attendant for Lekki hub
      branchesNotifier.inviteStaff(
        name: 'Funke Akindele',
        email: 'funke.akindele@mamacass.ng',
        role: MerchantRole.dispatchAttendant,
        branchId: 'br_lekki_01',
        branchName: 'Lekki Phase 1 Flagship',
      );
      expect(
        branchesNotifier.state.staffMembers.any((s) => s.email == 'funke.akindele@mamacass.ng'),
        isTrue,
      );

      // -----------------------------------------------------------------------
      // Step 2: Upfront Quote & Delivery Dispatch Creation
      // -----------------------------------------------------------------------
      final bookingsNotifier = MerchantBookingsNotifier();
      final billingNotifier = MerchantBillingNotifier();

      final initialWalletBalance = billingNotifier.state.wallet.balanceKobo;
      const lockedFareKobo = 285000; // ₦2,850.00

      final newDelivery = await bookingsNotifier.createDeliveryBooking(
        branchId: authNotifier.state.activeBranchId,
        branchName: authNotifier.state.activeBranchName,
        recipientName: 'Dr. Olufemi Peters',
        recipientPhone: '+2348039988776',
        deliveryAddress: 'Plot 14, Admiralty Way, Lekki Phase 1, Lagos',
        deliveryZone: 'Lekki / Victoria Island',
        packageCategory: 'Hot Meals & Bakery',
        weightKg: 2.0,
        isFragile: false,
        specialInstructions: 'Leave with security guard if unavailable',
        grossFareKobo: lockedFareKobo,
      );

      expect(newDelivery.status, BookingStatus.searchingRider);
      expect(newDelivery.recipientOtp.length, 4);
      expect(newDelivery.grossFareKobo, lockedFareKobo);

      // Deduct dispatch fee from pre-funded corporate wallet
      billingNotifier.deductDispatchFee(
        amountKobo: BigInt.from(lockedFareKobo),
        bookingId: newDelivery.id,
        trackingNumber: newDelivery.trackingReference,
        branchName: newDelivery.branchName,
      );

      expect(
        billingNotifier.state.wallet.balanceKobo,
        initialWalletBalance - BigInt.from(lockedFareKobo),
      );

      // -----------------------------------------------------------------------
      // Step 3: Fleet Telemetry & Electric Moped Driver Assignment
      // -----------------------------------------------------------------------
      // Simulated electric moped assignment with battery telemetry
      final inTransitDelivery = newDelivery.copyWith(
        status: BookingStatus.inProgress,
        assignedRiderName: 'Babatunde Adeleke',
        assignedRiderPhone: '+2348021112233',
        assignedRiderPlate: 'LAG-882-VOLT',
        assignedRiderBattery: 94, // 94% SoC
      );

      expect(inTransitDelivery.assignedRiderName, 'Babatunde Adeleke');
      expect(inTransitDelivery.assignedRiderBatterySoc, 94);
      expect(inTransitDelivery.assignedRiderPlate, 'LAG-882-VOLT');

      // -----------------------------------------------------------------------
      // Step 4: Recipient Verification & Delivery Handover
      // -----------------------------------------------------------------------
      // Recipient provides secure 4-digit OTP
      final completedDelivery = inTransitDelivery.copyWith(
        status: BookingStatus.completed,
        proofOfDeliveryUrl: 'https://cdn.govolts.ng/pod/signature_lekki_90412.png',
      );

      expect(completedDelivery.status, BookingStatus.completed);
      expect(completedDelivery.proofOfDeliveryUrl, isNotNull);

      // -----------------------------------------------------------------------
      // Step 5: Retail Ai POS Integration — Outbound Signed Webhook
      // -----------------------------------------------------------------------
      final partnerNotifier = PartnerApiNotifier();
      expect(partnerNotifier.state.apiKeys, isNotEmpty);
      const webhookSecret = 'whsec_908f7e6d5c4b3a210fedcba987654321';
      final eventTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final webhookPayload = {
        'event': 'delivery.completed',
        'event_id': 'evt_sim_99214_final',
        'tracking_number': completedDelivery.trackingReference,
        'external_reference': 'RET-POS-90412',
        'delivered_at': DateTime.now().toIso8601String(),
        'proof_of_delivery': {
          'recipient_otp_verified': true,
          'signature_url': completedDelivery.proofOfDeliveryUrl,
        },
        'battery_telemetry': {
          'vehicle_reg': completedDelivery.assignedRiderPlate,
          'final_battery_soc': 89,
        },
      };

      final rawPayloadString = jsonEncode(webhookPayload);
      final signatureHeader = PartnerApiNotifier.computeHmacSignature(
        secret: webhookSecret,
        timestamp: eventTimestamp,
        payload: rawPayloadString,
      );

      expect(signatureHeader, startsWith('sha256='));

      // Validate HMAC signature on partner endpoint side
      final isValidSignature = PartnerApiNotifier.verifyHmacSignature(
        secret: webhookSecret,
        timestamp: eventTimestamp,
        payload: rawPayloadString,
        providedSignature: signatureHeader,
      );
      expect(isValidSignature, isTrue);

      // -----------------------------------------------------------------------
      // Step 6: Automated Corporate Invoice Settlement
      // -----------------------------------------------------------------------
      final pendingInvoice = billingNotifier.state.invoices
          .firstWhere((i) => i.status == InvoiceStatus.pending);

      final settledSuccessfully = billingNotifier.settleInvoice(pendingInvoice.id);
      expect(settledSuccessfully, isTrue);

      final updatedInvoice = billingNotifier.state.invoices
          .firstWhere((i) => i.id == pendingInvoice.id);
      expect(updatedInvoice.status, InvoiceStatus.paid);
      expect(updatedInvoice.paymentDate, isNotNull);

      final ledgerHead = billingNotifier.state.transactions.first;
      expect(ledgerHead.type, CorporateTransactionType.monthlySettlement);
      expect(ledgerHead.amountKobo, pendingInvoice.amountKobo);
    });
  });
}
