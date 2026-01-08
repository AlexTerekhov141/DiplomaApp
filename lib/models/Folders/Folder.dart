
class Folder {

  Folder({
    required this.id,
    required this.name,
    required this.photosCount,
    this.amount = 0
  });

  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      id: json['id'],
      name: json['name'],
      photosCount: json['photos_count'],
    );
  }
  final String id;
  final String name;
  final int photosCount;
  final int amount;
}
