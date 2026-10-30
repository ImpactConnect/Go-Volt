import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Go-Volts Send: Step 2 Design System Components Widget Tests', () {
    testWidgets('GVDeliveryTypeCard renders title, description, icon and selection indicator', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GVDeliveryTypeCard(
              title: 'Standard Delivery',
              description: 'Delivery within 2 - 4 hours',
              icon: Icons.inventory_2_rounded,
              isSelected: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Standard Delivery'), findsOneWidget);
      expect(find.text('Delivery within 2 - 4 hours'), findsOneWidget);
      expect(find.byIcon(Icons.inventory_2_rounded), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.tap(find.text('Standard Delivery'));
      expect(tapped, isTrue);
    });

    testWidgets('GVPackageCategoryGrid renders 6 items and highlights selected category', (tester) async {
      String selected = 'DOCUMENTS';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return GVPackageCategoryGrid(
                  items: GVPackageCategoryGrid.defaultItems,
                  selectedCode: selected,
                  onSelected: (code) => setState(() => selected = code),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Documents'), findsOneWidget);
      expect(find.text('Electronics'), findsOneWidget);
      expect(find.text('Fragile'), findsOneWidget);

      await tester.tap(find.text('Fragile'));
      await tester.pumpAndSettle();
      expect(selected, 'FRAGILE');
    });

    testWidgets('GVWeightStepper handles increment and decrement within limits', (tester) async {
      double currentWeight = 1.5;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return GVWeightStepper(
                  weightKg: currentWeight,
                  onChanged: (val) => setState(() => currentWeight = val),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('1.5 kg'), findsOneWidget);

      // Increment
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(currentWeight, 2.0);
      expect(find.text('2.0 kg'), findsOneWidget);

      // Decrement
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();
      expect(currentWeight, 1.5);
    });

    testWidgets('GVSpecialHandlingToggles renders switches and triggers changes', (tester) async {
      final options = [
        const GVHandlingOptionItem(
          code: 'FRAGILE',
          label: 'Fragile (Handle with care)',
          isEnabled: true,
        ),
        const GVHandlingOptionItem(
          code: 'KEEP_UPRIGHT',
          label: 'Keep upright',
          isEnabled: false,
        ),
      ];

      String? toggledCode;
      bool? toggledVal;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GVSpecialHandlingToggles(
              options: options,
              onChanged: (code, val) {
                toggledCode = code;
                toggledVal = val;
              },
            ),
          ),
        ),
      );

      expect(find.text('Fragile (Handle with care)'), findsOneWidget);
      expect(find.text('Keep upright'), findsOneWidget);

      // Toggle switch
      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(2));
      await tester.tap(switches.last);
      expect(toggledCode, 'KEEP_UPRIGHT');
      expect(toggledVal, isTrue);
    });

    testWidgets('GVRecipientFormCard renders form inputs, address and save switch', (tester) async {
      final nameCtrl = TextEditingController(text: 'John Doe');
      final phoneCtrl = TextEditingController(text: '0803 123 4567');
      final noteCtrl = TextEditingController(text: 'Shop B12');
      bool saveRecipient = true;
      bool editTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: GVRecipientFormCard(
                nameController: nameCtrl,
                phoneController: phoneCtrl,
                deliveryAddress: 'Palms Mall, Lekki, Lagos',
                onEditAddress: () => editTapped = true,
                additionalInfoController: noteCtrl,
                saveAsRecipient: saveRecipient,
                onSaveAsRecipientChanged: (v) => saveRecipient = v,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Full name'), findsOneWidget);
      expect(find.text('Phone number'), findsOneWidget);
      expect(find.text('+234'), findsOneWidget);
      expect(find.text('Palms Mall, Lekki, Lagos'), findsOneWidget);
      expect(find.text('Save as recipient'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.edit_outlined));
      expect(editTapped, isTrue);
    });

    testWidgets('GVParcelReviewCard renders delivery details, package summary and price breakdown', (tester) async {
      bool editTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: GVParcelReviewCard(
                pickupAddress: 'Eko Hotel and Suites, Victoria Island, Lagos',
                deliveryAddress: 'Palms Mall, Lekki, Lagos',
                packageTitle: 'Fragile item - 1.5 kg - Small',
                handlingTag: 'Fragile (Handle with care)',
                deliveryTypeTitle: 'Standard Delivery - 2 - 4 hours',
                baseFareLabel: '₦2,000',
                distanceFareLabel: '₦300',
                distanceLabel: '12.4 km',
                handlingFareLabel: '₦200',
                insuranceFareLabel: '₦0',
                totalFareLabel: '₦2,500',
                onEditDeliveryDetails: () => editTapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Delivery details'), findsOneWidget);
      expect(find.text('Eko Hotel and Suites, Victoria Island, Lagos'), findsOneWidget);
      expect(find.text('Palms Mall, Lekki, Lagos'), findsOneWidget);
      expect(find.text('Fragile item - 1.5 kg - Small'), findsOneWidget);
      expect(find.text('₦2,500'), findsOneWidget);

      await tester.tap(find.text('Edit'));
      expect(editTapped, isTrue);
    });

    testWidgets('GVParcelHandoverCard renders illustration and milestone timeline', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: GVParcelHandoverCard(
                pickupAddress: 'Eko Hotel and Suites',
                pickupTime: '10:05 AM',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Parcel picked up!'), findsOneWidget);
      expect(find.text('Handover Confirmed'), findsOneWidget);
      expect(find.textContaining('10:05 AM • Eko Hotel and Suites'), findsOneWidget);
      expect(find.text('On the way'), findsOneWidget);
    });

    testWidgets('GVProofOfDeliveryCard renders celebratory badge, handover info and receipt button', (tester) async {
      bool viewReceiptTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: GVProofOfDeliveryCard(
                recipientName: 'John Doe',
                deliveryAddress: 'Palms Mall, Lekki, Lagos',
                deliveredAtLabel: 'Oct 29, 2026, 10:45 AM',
                onViewReceipt: () => viewReceiptTapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Delivered successfully!'), findsOneWidget);
      expect(find.text('Your parcel has been delivered.'), findsOneWidget);
      expect(find.textContaining('John Doe\nPalms Mall, Lekki, Lagos'), findsOneWidget);
      expect(find.text('Oct 29, 2026, 10:45 AM'), findsOneWidget);
      expect(find.text('View receipt'), findsOneWidget);

      await tester.tap(find.text('View receipt'));
      expect(viewReceiptTapped, isTrue);
    });
  });
}

