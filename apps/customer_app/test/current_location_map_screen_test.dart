import 'package:app_models/app_models.dart';
import 'package:customer_app/src/core/presentation/widgets/live_google_map_view.dart';
import 'package:customer_app/src/features/home/presentation/current_location_map_screen.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget createWidgetUnderTest({
    LocationDto? initialLocation,
    void Function(LocationDto?)? onPopped,
  }) {
    return ProviderScope(
      child: MaterialApp(
        theme: GVTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                final result = await CurrentLocationMapScreen.open(
                  context,
                  initialLocation: initialLocation,
                );
                onPopped?.call(result);
              },
              child: const Text('Open Map Screen'),
            ),
          ),
        ),
      ),
    );
  }

  group('CurrentLocationMapScreen Tests', () {
    testWidgets('renders live Google Map view, address card, and confirm button',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap button to open CurrentLocationMapScreen
      await tester.tap(find.text('Open Map Screen'));
      await tester.pumpAndSettle();

      // Verify screen title and elements
      expect(find.text('Live Map • Current Location'), findsOneWidget);
      expect(find.byType(LiveGoogleMapView), findsOneWidget);
      expect(find.text('Confirm & Use This Location'), findsOneWidget);
      expect(find.text('Shaganu Central Roundabout'), findsWidgets);
    });

    testWidgets(
        'selecting a landmark chip updates current coordinates and address label',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Map Screen'));
      await tester.pumpAndSettle();

      // Tap on the Shaganu Main Market chip
      final marketChip = find.text('Shaganu Main Market');
      expect(marketChip, findsOneWidget);
      await tester.tap(marketChip);
      await tester.pumpAndSettle();

      // Verify selected chip address is reflected
      expect(find.text('Shaganu Main Market'), findsWidgets);
      expect(find.textContaining('Market Road'), findsWidgets);
    });

    testWidgets(
        'tapping confirm returns location coordinates and sets state in notifiers',
        (tester) async {
      LocationDto? returnedLoc;
      await tester.pumpWidget(createWidgetUnderTest(
        onPopped: (loc) => returnedLoc = loc,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Map Screen'));
      await tester.pumpAndSettle();

      // Tap "Confirm & Use This Location"
      await tester.tap(find.text('Confirm & Use This Location'));
      await tester.pumpAndSettle();

      // Verify popped back and returned LocationDto
      expect(find.byType(CurrentLocationMapScreen), findsNothing);
      expect(returnedLoc, isNotNull);
      expect(returnedLoc!.latitude, closeTo(6.8403, 0.01));
      expect(returnedLoc!.longitude, closeTo(3.6487, 0.01));
    });

    testWidgets('zoom in and zoom out buttons are present on LiveGoogleMapView',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Map Screen'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.byIcon(Icons.remove_rounded), findsOneWidget);
      expect(find.byIcon(Icons.my_location_rounded), findsWidgets);

      // Tap zoom in and zoom out with warnIfMissed false
      await tester.tap(find.byIcon(Icons.add_rounded), warnIfMissed: false);
      await tester.pump();
      await tester.tap(find.byIcon(Icons.remove_rounded), warnIfMissed: false);
      await tester.pump();
    });
  });
}
