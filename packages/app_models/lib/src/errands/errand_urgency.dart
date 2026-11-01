/// Urgency levels for errands and custom tasks (ME-C01 & Screen C2).
enum ErrandUrgency {
  standard('STANDARD', 'Standard (same day)'),
  express('EXPRESS', 'Express (urgent)');

  const ErrandUrgency(this.code, this.label);

  final String code;
  final String label;

  static ErrandUrgency fromString(String? raw) {
    if (raw == null) return ErrandUrgency.standard;
    final normalized = raw.trim().toUpperCase();
    return ErrandUrgency.values.firstWhere(
      (u) => u.code == normalized || u.name.toUpperCase() == normalized,
      orElse: () => ErrandUrgency.standard,
    );
  }
}

