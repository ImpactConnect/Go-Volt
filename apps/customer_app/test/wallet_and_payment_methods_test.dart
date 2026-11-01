import 'package:api_client/api_client.dart';
import 'package:app_config/app_config.dart';
import 'package:customer_app/src/core/providers/api_providers.dart';
import 'package:customer_app/src/features/wallet/application/wallet_notifier.dart';
import 'package:customer_app/src/features/wallet/data/wallet_repository.dart';
import 'package:customer_app/src/features/wallet/presentation/coupons_screen.dart';
import 'package:customer_app/src/features/wallet/presentation/saved_payment_methods_screen.dart';
import 'package:customer_app/src/features/wallet/presentation/top_up_screen.dart';
import 'package:customer_app/src/features/wallet/presentation/wallet_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testConfig = AppConfig.dev();
  final testApiClient = ApiClient(config: testConfig);
  final testWalletRepo =
      WalletRepository(apiClient: testApiClient, useSeedData: true);

  group('SavedPaymentMethodsScreen Tests (Screen W04 & Master Tech Spec §8.8)', () {
    testWidgets('renders dedicated NUBAN account, clean empty cards state, and links card via Paystack tokenization',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 900));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(testConfig),
            apiClientProvider.overrideWithValue(testApiClient),
            walletRepositoryProvider.overrideWithValue(testWalletRepo),
          ],
          child: const MaterialApp(
            home: SavedPaymentMethodsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Dedicated Virtual Bank Account
      expect(find.text('Dedicated Bank Account'), findsOneWidget);
      expect(find.textContaining('Providus Bank'), findsOneWidget);

      // Verify Saved Cards - Initially empty without hardcoded fake cards
      expect(find.text('Saved Debit Cards'), findsOneWidget);
      expect(find.text('No Saved Cards'), findsOneWidget);
      expect(find.textContaining('Cards are tokenized securely through Paystack'), findsOneWidget);

      // Tap "Add Card"
      await tester.tap(find.text('Add Card'));
      await tester.pumpAndSettle();

      // Verify Paystack PCI-DSS Tokenization Modal opens (NO manual PAN or CVV fields)
      expect(find.text('Link Card via Paystack'), findsWidgets);
      expect(find.textContaining('PCI-DSS Level 1 Encrypted'), findsOneWidget);
      expect(find.textContaining('Go-Volt never stores your card number or CVV'), findsOneWidget);

      // Tap Proceed to Paystack Secure Checkout
      await tester.tap(find.text('Proceed to Paystack Secure Checkout'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Verify tokenized card added securely to list with Default badge
      expect(find.textContaining('Mastercard •••• 4242'), findsOneWidget);
      expect(find.text('Default'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });
  });

  group('CouponsScreen Tests (Screen W07)', () {
    testWidgets('renders active coupons and applies valid promo code',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 900));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(testConfig),
            apiClientProvider.overrideWithValue(testApiClient),
            walletRepositoryProvider.overrideWithValue(testWalletRepo),
          ],
          child: const MaterialApp(
            home: CouponsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Header & Input Box
      expect(find.text('Coupons & Promos'), findsOneWidget);
      expect(find.text('Have a Promo Code?'), findsOneWidget);

      // Verify Active Coupons List
      expect(find.text('VOLTFIRST'), findsOneWidget);
      expect(find.text('CLEANLEKKI'), findsOneWidget);

      // Enter Promo Code
      await tester.enterText(find.byType(TextField), 'VOLT500');
      await tester.tap(find.text('Apply'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Verify success snackbar
      expect(find.textContaining('Voucher "VOLT500" applied!'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });
  });

  group('Wallet Screen Enhanced Features (Screen W01 & W03)', () {
    testWidgets('filter chips filter transactions and tapping transaction opens details modal',
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

      await tester.pumpAndSettle();

      // Verify Quick Action Tiles
      expect(find.text('Top Up'), findsWidgets);
      expect(find.text('Payment Cards'), findsOneWidget);
      expect(find.text('Eco-Rewards'), findsOneWidget);
      expect(find.text('Coupons & Promos'), findsOneWidget);

      // Verify Filter Chips
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Rides & Delivery'), findsOneWidget);
      expect(find.text('Redemptions'), findsOneWidget);

      // Tap "Top-Up" chip
      await tester.tap(find.text('Top-Up'));
      await tester.pumpAndSettle();

      // Only credit transactions should be visible
      expect(find.textContaining('Paystack Card Top-Up'), findsWidgets);

      // Tap on the transaction tile to open details
      await tester.tap(find.textContaining('Paystack Card Top-Up').first);
      await tester.pumpAndSettle();

      // Verify Transaction Details Sheet
      expect(find.text('Transaction Details'), findsOneWidget);
      expect(find.text('Transaction Type'), findsOneWidget);
      expect(find.text('Credit / Top-Up'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('TopUpScreen supports Bank Transfer virtual NUBAN flow',
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

      await tester.pumpAndSettle();

      // Select Bank Transfer channel
      await tester.tap(find.text('Bank Transfer (Virtual NUBAN)'));
      await tester.pumpAndSettle();

      // Tap Proceed
      await tester.tap(find.textContaining('Proceed to Pay'));
      await tester.pumpAndSettle();

      // Verify Bank Transfer Modal
      expect(find.text('Bank Transfer Top-Up'), findsOneWidget);
      expect(find.text('9928 1039 48'), findsOneWidget);

      // Tap "I Have Completed the Transfer"
      await tester.tap(find.text('I Have Completed the Transfer'));
      await tester.pumpAndSettle();

      // Verify Top-Up Successful
      expect(find.text('Top-Up Successful!'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });
  });
}
