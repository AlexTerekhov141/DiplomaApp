class CleanupStats {
  const CleanupStats({
    required this.total,
    required this.suggested,
    required this.trashed,
    required this.kept,
  });

  final int total;
  final int suggested;
  final int trashed;
  final int kept;
}
