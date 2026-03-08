
class Folder {

  Folder({
    required this.id,
    required this.name,
    required this.photosCount,
    this.previewUrls = const <String>[],
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
      previewUrls: (json['preview_urls'] is List)
          ? (json['preview_urls'] as List<dynamic>)
              .map((dynamic e) => e.toString())
              .where((String e) => e.isNotEmpty)
              .take(4)
              .toList()
          : const <String>[],
    );
  }
  final String id;
  final String name;
  final int photosCount;
  final List<String> previewUrls;
  final int amount;
}
