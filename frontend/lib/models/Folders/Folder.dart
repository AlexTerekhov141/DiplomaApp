
class Folder {

  Folder({
    required this.id,
    required this.name,
    required this.photosCount,
    this.amount = 0
  });

  factory Folder.fromJson(Map<String, dynamic> json) {
    final dynamic rawCount =
        json['photos_count'] ?? json['photosCount'] ?? json['count'] ?? 0;
    final int photosCount = rawCount is int
        ? rawCount
        : int.tryParse(rawCount.toString()) ?? 0;

    return Folder(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      photosCount: photosCount,
    );
  }
  final String id;
  final String name;
  final int photosCount;
  final int amount;
}
