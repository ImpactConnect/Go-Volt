import 'package:customer_app/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CustomerApp launches and displays Splash branding',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CustomerApp(),
      ),
    );

    // Initial frame displays Splash
    expect(find.text('Go-Volts'), findsOneWidget);
    expect(find.text('Cleaner Cities. Brighter Future.'), findsOneWidget);
    expect(find.text('v1.0.0 • 100% Electric Ecosystem'), findsOneWidget);

    // Drain pending splash screen delay timer & settle transitions
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
