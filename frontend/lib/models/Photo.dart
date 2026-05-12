import 'package:json_annotation/json_annotation.dart';

part 'Photo.g.dart';

@JsonSerializable(createFactory: false)
class Photo {

  Photo({
    required this.id,
    required this.image,
    required this.assetId,
    required this.categoryId,
    required this.category,
    required this.qualityScore,
    required this.tags,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    final dynamic rawCategory = json['category'];
    final List<dynamic> rawTags = json['tags'] as List<dynamic>? ?? <dynamic>[];

    return Photo(
      id: json['id'] as int,
      image: (json['image'] ?? '').toString(),
      assetId: (json['asset_id'] ?? '').toString(),
      categoryId: _categoryIdFromJson(rawCategory),
      category: _categoryNameFromJson(rawCategory),
      qualityScore: (json['quality_score'] ?? 0).toDouble(),
      tags: _tagsFromJson(rawTags),
    );
  }
  final int id;
  final String image;
  final String assetId;
  final String? categoryId;
  final String category;

  @JsonKey(name: 'quality_score')
  final double qualityScore;

  final List<String> tags;

  Map<String, dynamic> toJson() => _$PhotoToJson(this);

  static String? _categoryIdFromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return json['id']?.toString();
    }
    return null;
  }

  static String _categoryNameFromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return (json['name'] ?? '').toString();
    }
    return '';
  }

  static List<String> _tagsFromJson(List<dynamic> json) {
    return json
        .map((tag) => _normalizeTag((tag['name'] ?? '').toString()))
        .expand((List<String> e) => e)
        .toSet()
        .toList();
  }

  static List<String> _normalizeTag(String name) {
    return name
        .replaceAll('"', '')
        .split(',')
        .map((String e) => e.trim())
        .where((String e) => e.isNotEmpty)
        .toList();
  }
}
