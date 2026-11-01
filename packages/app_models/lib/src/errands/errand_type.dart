/// Supported primary errand service types (v1.6 §1562 & ME-02).
enum ErrandType {
  buyItems(
    'BUY_ITEMS',
    'Buy Items From a Shop',
    'We\'ll go to a shop or market, buy your items and deliver.',
  ),
  pickupPackage(
    'PICKUP_PACKAGE',
    'Pick Up a Package',
    'We\'ll collect a package and deliver it to you.',
  ),
  otherErrand(
    'OTHER_ERRAND',
    'Other Errand',
    'Tell us what you need help with.',
  );

  const ErrandType(this.code, this.title, this.description);

  final String code;
  final String title;
  final String description;

  static ErrandType fromString(String? raw) {
    if (raw == null) return ErrandType.buyItems;
    final normalized = raw.trim().toUpperCase();
    return ErrandType.values.firstWhere(
      (e) => e.code == normalized || e.name.toUpperCase() == normalized,
      orElse: () => ErrandType.buyItems,
    );
  }
}

