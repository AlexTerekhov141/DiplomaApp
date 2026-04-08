enum RoastSeverity { high, medium, low }

class RoastIssue {
  const RoastIssue({
    required this.title,
    required this.whyItHurts,
    required this.howToFix,
    required this.severity,
  });

  final String title;
  final String whyItHurts;
  final String howToFix;
  final RoastSeverity severity;
}