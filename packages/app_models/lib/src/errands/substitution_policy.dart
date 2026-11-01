/// Customer substitution policies for shopping errands (v1.6 §1716-1723 & ME-A03).
enum SubstitutionPolicy {
  doNotSubstitute(
    'DO_NOT_SUBSTITUTE',
    'Do not substitute',
    'Buy only the listed items.',
  ),
  contactFirst(
    'CONTACT_FIRST',
    'Contact me first',
    'Call or chat me before replacing any unavailable item.',
  ),
  similarAlternative(
    'SIMILAR_ALTERNATIVE',
    'Choose a similar alternative',
    'Buy a similar item within my budget.',
  );

  const SubstitutionPolicy(this.code, this.title, this.description);

  final String code;
  final String title;
  final String description;

  static SubstitutionPolicy fromString(String? raw) {
    if (raw == null) return SubstitutionPolicy.contactFirst;
    final normalized = raw.trim().toUpperCase();
    return SubstitutionPolicy.values.firstWhere(
      (p) => p.code == normalized || p.name.toUpperCase() == normalized,
      orElse: () => SubstitutionPolicy.contactFirst,
    );
  }
}

