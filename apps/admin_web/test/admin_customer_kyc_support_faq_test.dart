import 'helpers/test_seeds.dart';
import 'package:admin_web/src/core/auth/admin_auth_notifier.dart';
import 'package:admin_web/src/core/auth/admin_role.dart';
import 'package:admin_web/src/features/customers/application/customer_verification_notifier.dart';
import 'package:admin_web/src/features/customers/presentation/customer_verification_screen.dart';
import 'package:admin_web/src/features/customers/presentation/widgets/customer_document_modal.dart';
import 'package:admin_web/src/features/support/application/support_safety_notifier.dart';
import 'package:admin_web/src/features/support/domain/support_safety_models.dart';
import 'package:admin_web/src/features/support/presentation/support_safety_screen.dart';
import 'package:admin_web/src/features/support/presentation/widgets/faq_editor_modal.dart';
import 'package:admin_web/src/features/support/presentation/widgets/support_ticket_chat_modal.dart';
import 'package:app_models/app_models.dart' hide TicketStatus;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget createTestApp(Widget home, {StaffRole role = StaffRole.admin}) {
  return ProviderScope(
    overrides: [
      adminAuthNotifierProvider.overrideWith((ref) {
        final notifier = AdminAuthNotifier();
        notifier.setRole(role);
        return notifier;
      }),
      customerVerificationNotifierProvider.overrideWith((ref) {
        final notifier = CustomerVerificationNotifier();
        notifier.seedForTest();
        return notifier;
      }),
      supportSafetyNotifierProvider.overrideWith((ref) {
        final notifier = SupportSafetyNotifier(ref);
        notifier.seedForTest();
        return notifier;
      }),
    ],
    child: MaterialApp(
      home: home,
    ),
  );
}

void main() {
  group('Customer KYC & Identity Verification Queue Tests (§A4)', () {
    test('CustomerVerificationNotifier loads seeds, filters, approves, and rejects', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(customerVerificationNotifierProvider.notifier);
      notifier.seedForTest();
      var state = container.read(customerVerificationNotifierProvider);

      expect(state.totalSubmitted, equals(5));
      expect(state.pendingCount, equals(2));
      expect(state.verifiedCount, equals(1));
      expect(state.actionRequiredCount, equals(1));
      expect(state.rejectedCount, equals(1));

      // Test Search
      notifier.search('Alexander');
      state = container.read(customerVerificationNotifierProvider);
      expect(state.filteredCustomers.length, equals(1));
      expect(state.filteredCustomers.first.fullName, equals('Alexander Cole'));

      notifier.search('');

      // Test Status Filter
      notifier.filterByStatus(VerificationStatus.pending);
      state = container.read(customerVerificationNotifierProvider);
      expect(state.filteredCustomers.length, equals(2));
      expect(state.filteredCustomers.every((c) => c.status == VerificationStatus.pending), isTrue);

      notifier.filterByStatus(null);

      // Test Approve
      final successApprove = await notifier.approveVerification(
        customerId: 'CUST-001',
        reviewerName: 'Admin Adeola',
      );
      expect(successApprove, isTrue);
      state = container.read(customerVerificationNotifierProvider);
      final alex = state.customers.firstWhere((c) => c.id == 'CUST-001');
      expect(alex.status, equals(VerificationStatus.verified));
      expect(alex.verifiedAt, isNotNull);
      expect(state.actionMessage, contains('APPROVED'));

      // Test Request Action
      final successAction = await notifier.requestAction(
        customerId: 'CUST-004',
        reason: 'Utility bill is older than 3 months.',
        reviewerName: 'Admin Adeola',
      );
      expect(successAction, isTrue);
      state = container.read(customerVerificationNotifierProvider);
      final fola = state.customers.firstWhere((c) => c.id == 'CUST-004');
      expect(fola.status, equals(VerificationStatus.actionRequired));
      expect(fola.rejectionReason, equals('Utility bill is older than 3 months.'));

      // Test Reject
      final successReject = await notifier.rejectVerification(
        customerId: 'CUST-001',
        reason: 'Fraudulent identity document detected.',
        reviewerName: 'Admin Adeola',
      );
      expect(successReject, isTrue);
      state = container.read(customerVerificationNotifierProvider);
      expect(state.customers.firstWhere((c) => c.id == 'CUST-001').status, equals(VerificationStatus.rejected));
    });

    testWidgets('CustomerVerificationScreen renders KPI cards, table, and document modal', (tester) async {
      tester.view.physicalSize = const Size(2400, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(const CustomerVerificationScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Customer Identity & KYC Verification'), findsOneWidget);
      expect(find.text('TOTAL APPLICATIONS'), findsOneWidget);
      expect(find.text('PENDING VERIFICATION'), findsOneWidget);
      expect(find.text('VERIFIED CUSTOMERS'), findsOneWidget);
      expect(find.text('ACTION REQUIRED'), findsOneWidget);

      // Verify seeded customers in table
      expect(find.text('Alexander Cole'), findsOneWidget);
      expect(find.text('Dr. Aisha Adeleke'), findsOneWidget);

      // Tap "Review Docs" on first customer
      final reviewDocsBtn = find.text('Review Docs').first;
      await tester.ensureVisible(reviewDocsBtn);
      await tester.tap(reviewDocsBtn);
      await tester.pumpAndSettle();

      // Verify CustomerDocumentModal is open
      expect(find.byType(CustomerDocumentModal), findsOneWidget);
      expect(find.text('SUBMITTED VERIFICATION DOCUMENTS'), findsOneWidget);
      expect(find.text('Approve & Verify'), findsOneWidget);
      expect(find.text('Request Action'), findsOneWidget);
      expect(find.text('Reject Verification'), findsOneWidget);

      // Approve customer from modal
      await tester.tap(find.text('Approve & Verify'));
      await tester.pumpAndSettle();

      // Modal closed and verified action banner displayed
      expect(find.byType(CustomerDocumentModal), findsNothing);
      expect(find.textContaining('APPROVED'), findsOneWidget);
    });
  });

  group('Live Support Ticket Chat & FAQ Knowledge Base CMS Tests (§D1 - §D5)', () {
    test('SupportSafetyNotifier handles agent replies, ticket status, and FAQ CMS CRUD', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(supportSafetyNotifierProvider.notifier);
      notifier.seedForTest();
      var state = container.read(supportSafetyNotifierProvider);

      expect(state.tickets.length, equals(5));
      expect(state.faqs.length, equals(6));

      // Test Agent Reply
      final replySuccess = await notifier.sendAgentReply(
        ticketId: 'tick_802',
        message: 'We have credited ₦300 back to your Go-Volts wallet.',
        agentName: 'Officer Babatunde',
        agentId: 'agent_007',
      );
      expect(replySuccess, isTrue);
      state = container.read(supportSafetyNotifierProvider);
      final ticket802 = state.tickets.firstWhere((t) => t.id == 'tick_802');
      expect(ticket802.messages.length, equals(2));
      expect(ticket802.messages.last.senderRole, equals('agent'));
      expect(ticket802.messages.last.message, contains('credited ₦300'));
      expect(ticket802.status, equals(TicketStatus.inProgress));

      // Test FAQ Creation
      notifier.addFaq(
        category: 'Market Errand',
        question: 'Can I request delivery from local street markets?',
        answer: 'Yes, shoppers can procure items from major recognized local open markets in Lagos and Kaduna.',
      );
      state = container.read(supportSafetyNotifierProvider);
      expect(state.faqs.length, equals(7));
      expect(state.faqs.any((f) => f.question.contains('local street markets')), isTrue);

      // Test FAQ Category Filtering
      notifier.filterFaqsByCategory('Wallet');
      state = container.read(supportSafetyNotifierProvider);
      expect(state.filteredFaqs.every((f) => f.category == 'Wallet'), isTrue);

      // Test FAQ Deletion
      final faqToDelete = state.faqs.first;
      notifier.deleteFaq(faqToDelete.id);
      state = container.read(supportSafetyNotifierProvider);
      expect(state.faqs.any((f) => f.id == faqToDelete.id), isFalse);
    });

    testWidgets('SupportSafetyScreen renders 3 tabs: Tickets, Safety Incidents, and FAQ CMS', (tester) async {
      tester.view.physicalSize = const Size(2400, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(const SupportSafetyScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Support Helpdesk & Safety Operations'), findsOneWidget);
      expect(find.text('PUBLISHED FAQS'), findsOneWidget);

      // Check Tab 0: Tickets
      expect(find.text('Customer & Rider Inquiries Queue'), findsOneWidget);
      expect(find.text('Chat (2)'), findsWidgets);

      // Tap Chat button to open SupportTicketChatModal
      final chatBtn = find.text('Chat (2)').first;
      await tester.ensureVisible(chatBtn);
      await tester.tap(chatBtn);
      await tester.pumpAndSettle();

      expect(find.byType(SupportTicketChatModal), findsOneWidget);
      expect(find.text('Type official response to customer...'), findsOneWidget);
      expect(find.text('Send Reply'), findsOneWidget);

      // Send reply
      await tester.enterText(find.byType(TextField).last, 'We are on it.');
      await tester.tap(find.text('Send Reply'));
      await tester.pumpAndSettle();

      // Close modal
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Switch to Tab 2: FAQ Knowledge Base CMS
      final faqTab = find.widgetWithText(ChoiceChip, 'FAQ Knowledge Base CMS (6)');
      expect(faqTab, findsOneWidget);
      await tester.tap(faqTab);
      await tester.pumpAndSettle();

      expect(find.text('Help Centre Knowledge Base (CMS)'), findsOneWidget);
      expect(find.text('Publish New FAQ Article'), findsOneWidget);

      // Tap Publish New FAQ Article to open modal
      await tester.tap(find.text('Publish New FAQ Article'));
      await tester.pumpAndSettle();

      expect(find.byType(FaqEditorModal), findsOneWidget);
      expect(find.text('Publish to Customer App'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });
  });

  group('Staff RBAC Authorization Tests for Customer Verification', () {
    test('StaffRole correctly permits opsAgent, safetyOfficer, admin, superAdmin and restricts finance', () {
      expect(StaffRole.opsAgent.canAccessCustomers, isTrue);
      expect(StaffRole.safetyOfficer.canAccessCustomers, isTrue);
      expect(StaffRole.admin.canAccessCustomers, isTrue);
      expect(StaffRole.superAdmin.canAccessCustomers, isTrue);
      expect(StaffRole.finance.canAccessCustomers, isFalse);
      expect(StaffRole.promotionsManager.canAccessCustomers, isFalse);
    });
  });
}
