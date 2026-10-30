import 'package:api_client/api_client.dart';
import 'package:app_config/app_config.dart';
import 'package:customer_app/src/core/providers/api_providers.dart';
import 'package:customer_app/src/features/account/presentation/account_screen.dart';
import 'package:customer_app/src/features/account/presentation/support_screen.dart';
import 'package:customer_app/src/features/wallet/application/wallet_notifier.dart';
import 'package:customer_app/src/features/wallet/data/wallet_repository.dart';
import 'package:customer_app/src/features/wallet/presentation/rewards_screen.dart';
import 'package:customer_app/src/features/wallet/presentation/top_up_screen.dart';
import 'package:customer_app/src/features/wallet/presentation/wallet_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testConfig = AppConfig.dev();
  final testApiClient = ApiClient(config: testConfig);
  final testWalletRepo = WalletRepository(apiClient: testApiClient);

  group('Phase 1D WalletNotifier Unit Tests', () {
    test('initializes balance, transactions, loyalty rewards and coupons', () async {
      final notifier = WalletNotifier(repository: testWalletRepo);
      await notifier.loadWallet();

      expect(notifier.state.wallet.balance, greaterThanOrEqualTo(14000.0));
      expect(notifier.state.transactions.isNotEmpty, isTrue);
      expect(notifier.state.loyalty, isNotNull);
      expect(notifier.state.loyalty!.pointsBalance, 4200);
      expect(notifier.state.coupons.isNotEmpty, isTrue);
    });

    test('completes top-up and updates wallet balance atomically', () async {
      final notifier = WalletNotifier(repository: testWalletRepo);
      await notifier.loadWallet();

      final initialBalance = notifier.state.wallet.balance;
      const topUpAmount = 5000.0;
      final ok = await notifier.completeTopUp('TEST-PSTK-01', topUpAmount);

      expect(ok, isTrue);
      expect(notifier.state.wallet.balance, equals(initialBalance + topUpAmount));
      expect(notifier.state.transactions.first.amount, equals(topUpAmount));
      expect(notifier.state.transactions.first.isCredit, isTrue);
    });

    test('converts Eco-Points to wallet credit with correct rate', () async {
      final notifier = WalletNotifier(repository: testWalletRepo);
      await notifier.loadWallet();

      final initialBalance = notifier.state.wallet.balance;
      const pointsToRedeem = 1000;
      const expectedCredit = 100.0; // 1000 / 10 = 100

      final ok = await notifier.redeemLoyaltyPoints(pointsToRedeem);
      expect(ok, isTrue);
      expect(notifier.state.wallet.balance, equals(initialBalance + expectedCredit));
      expect(notifier.state.loyalty!.pointsBalance, equals(3200));
    });
  });

  group('Phase 1D Presentation & Widget Tests', () {
    testWidgets('WalletScreen renders available balance, policy disclaimer and transactions',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1000));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(testConfig),
            apiClientProvider.overrideWithValue(testApiClient),
            walletRepositoryProvider.overrideWithValue(testWalletRepo),
          ],
          child: const MaterialApp(
            home: WalletScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('My Wallet'), findsOneWidget);
      expect(find.text('Available Balance'), findsOneWidget);
      expect(find.textContaining('14500'), findsWidgets);
      expect(find.textContaining('Ride-wallet credit only'), findsOneWidget);
      expect(find.text('Eco-Rewards'), findsOneWidget);
      expect(find.text('Recent Transactions'), findsOneWidget);
      expect(find.textContaining('Paystack Card Top-Up'), findsWidgets);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('TopUpScreen renders presets, custom amount input and payment channels',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1000));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(testConfig),
            apiClientProvider.overrideWithValue(testApiClient),
            walletRepositoryProvider.overrideWithValue(testWalletRepo),
          ],
          child: const MaterialApp(
            home: TopUpScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('Top Up Wallet'), findsOneWidget);
      expect(find.text('Select or Enter Amount'), findsOneWidget);
      expect(find.text('₦1k'), findsOneWidget);
      expect(find.text('₦2k'), findsOneWidget);
      expect(find.text('₦5k'), findsOneWidget);
      expect(find.text('₦10k'), findsOneWidget);
      expect(find.text('Debit / Credit Card (Paystack)'), findsOneWidget);
      expect(find.text('Proceed to Pay ₦2000'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('RewardsScreen renders points balance, referral code and active coupons',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1200));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(testConfig),
            apiClientProvider.overrideWithValue(testApiClient),
            walletRepositoryProvider.overrideWithValue(testWalletRepo),
          ],
          child: const MaterialApp(
            home: RewardsScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Rewards & Eco-Points'), findsOneWidget);
      expect(find.text('4200'), findsOneWidget);
      expect(find.text('Invite Friends & Earn'), findsOneWidget);
      expect(find.text('VOLT-ALEX99'), findsOneWidget);
      expect(find.text('Available Vouchers & Coupons'), findsOneWidget);
      expect(find.textContaining('VOLTFIRST'), findsWidgets);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('AccountScreen renders profile, verified badge and carbon avoidance metrics',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1400));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(testConfig),
            apiClientProvider.overrideWithValue(testApiClient),
          ],
          child: const MaterialApp(
            home: AccountScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Account & Settings'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
      expect(find.textContaining('28.4 kg CO₂ Emissions Avoided'), findsOneWidget);
      expect(find.text('Saved Places'), findsOneWidget);
      expect(find.text('Wallet & Payments'), findsOneWidget);
      expect(find.text('Safety Centre & Emergency SOS'), findsOneWidget);
      expect(find.text('Help & Customer Support'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('SupportScreen renders 24/7 hotline, category chips and logs inquiries',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1200));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(testConfig),
            apiClientProvider.overrideWithValue(testApiClient),
          ],
          child: const MaterialApp(
            home: SupportScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Help & Support Center'), findsOneWidget);
      expect(find.text('24/7 Operations Support'), findsOneWidget);
      expect(find.text('Call +234 1 800 4686'), findsOneWidget);
      expect(find.text('Frequently Asked Questions'), findsOneWidget);
      expect(find.text('Send a Message to Support'), findsOneWidget);
      expect(find.text('Submit Support Ticket'), findsOneWidget);

      // Enter message and submit
      await tester.enterText(
        find.byType(TextField),
        'Inquiry about school-run route in Victoria Island.',
      );
      await tester.pump();

      await tester.tap(find.text('Submit Support Ticket'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Inquiry Logged Successfully'), findsOneWidget);
      expect(find.textContaining('CASE-SUP-'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });
  });
}
