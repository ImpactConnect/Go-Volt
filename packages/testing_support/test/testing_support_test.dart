import 'package:flutter_test/flutter_test.dart';
import 'package:testing_support/testing_support.dart';

void main() {
  group('TestFixtures', () {
    test('provides complete valid test fixtures', () {
      expect(TestFixtures.customerProfile.id, isNotEmpty);
      expect(TestFixtures.riderProfile.isRider, isTrue);
      expect(TestFixtures.locationPickup.latitude, isPositive);
      expect(TestFixtures.locationDropoff.longitude, isPositive);
      expect(TestFixtures.quote.isExpired, isFalse);
      expect(TestFixtures.booking.hasAssignedRider, isTrue);
      expect(TestFixtures.wallet.availableBalance, isPositive);
    });
  });
}
