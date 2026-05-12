import 'dart:convert';

import 'package:categorize_app/models/CleanUp/CleanupSeggestionStatus.dart';
import 'package:categorize_app/models/CleanUp/CleanupStats.dart';
import 'package:categorize_app/models/CleanUp/CleanupSuggestion.dart';
import 'package:categorize_app/models/CleanUp/CleanupSuggestionGroup.dart';
import 'package:categorize_app/models/CleanUp/CleanupSuggestionType.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'CleanupStorage.dart';

class SqfliteCleanupStorage implements CleanupStorage {
  static const String _databaseName = 'cleanup_storage1.db';
  static const String _tableName = 'cleanup_suggestions';
  static const int _databaseVersion = 1;
  static const int _maxSqlVariables = 900;

  Database? _database;

  Future<Database> get _db async {
    final Database? current = _database;
    if (current != null) {
      return current;
    }

    final Database opened = await _openDatabase();
    _database = opened;
    return opened;
  }

  Future<Database> _openDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String databasePath = p.join(databasesPath, _databaseName);

    return openDatabase(
      databasePath,
      version: _databaseVersion,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            asset_id TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            status TEXT NOT NULL,
            score REAL NOT NULL,
            reason TEXT NOT NULL,
            group_id TEXT,
            features_json TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE INDEX idx_cleanup_suggestions_type
          ON $_tableName(type)
        ''');

        await db.execute('''
          CREATE INDEX idx_cleanup_suggestions_status
          ON $_tableName(status)
        ''');

        await db.execute('''
          CREATE INDEX idx_cleanup_suggestions_group_id
          ON $_tableName(group_id)
        ''');
      },
    );
  }

  @override
  Future<void> clear() async {
    final Database db = await _db;
    await db.delete(_tableName);
  }

  Iterable<List<T>> _chunks<T>(List<T> items, int size) sync* {
    for (int start = 0; start < items.length; start += size) {
      final int end = start + size > items.length ? items.length : start + size;
      yield items.sublist(start, end);
    }
  }

  @override
  Future<void> deleteMissingAssets(Set<String> existingAssetIds) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      _tableName,
      columns: <String>['asset_id'],
    );

    final List<String> staleIds = rows
        .map((Map<String, Object?> row) => row['asset_id'].toString())
        .where((String assetId) => !existingAssetIds.contains(assetId))
        .toList();

    if (staleIds.isEmpty) {
      return;
    }

    final Batch batch = db.batch();
    for (final List<String> chunk in _chunks(staleIds, _maxSqlVariables)) {
      final String placeholders = List<String>.filled(
        chunk.length,
        '?',
      ).join(',');
      batch.delete(
        _tableName,
        where: 'asset_id IN ($placeholders)',
        whereArgs: chunk,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<CleanupStats> getStats() async {
    final Database db = await _db;

    final int total = await _countRows(db);
    final int suggested = await _countRows(
      db,
      status: CleanupSuggestionStatus.suggested,
    );
    final int trashed = await _countRows(
      db,
      status: CleanupSuggestionStatus.trashed,
    );
    final int kept = await _countRows(
      db,
      status: CleanupSuggestionStatus.kept,
    );

    return CleanupStats(
      total: total,
      suggested: suggested,
      trashed: trashed,
      kept: kept,
    );
  }

  @override
  Future<CleanupSuggestion?> getSuggestion(String assetId) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      _tableName,
      where: 'asset_id = ?',
      whereArgs: <Object?>[assetId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return _rowToSuggestion(rows.first);
  }

  @override
  Future<List<CleanupSuggestionGroup>> getSuggestionGroups() async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.rawQuery(
      '''
      SELECT type, COUNT(*) AS count
      FROM $_tableName
      WHERE status = ?
      GROUP BY type
      ORDER BY count DESC
      ''',
      <Object?>[CleanupSuggestionStatus.suggested.name],
    );

    final List<CleanupSuggestionGroup> groups = <CleanupSuggestionGroup>[];

    for (final Map<String, Object?> row in rows) {
      final CleanupSuggestionType? type = _typeFromName(
        row['type']?.toString(),
      );
      if (type == null) {
        continue;
      }

      final List<String> previewAssetIds = await _previewAssetIds(db, type);

      groups.add(
        CleanupSuggestionGroup(
          type: type,
          title: _titleForType(type),
          subtitle: _subtitleForType(type),
          count: (row['count'] as num?)?.toInt() ?? 0,
          previewAssetIds: previewAssetIds,
        ),
      );
    }

    return groups;
  }

  @override
  Future<List<CleanupSuggestion>> getSuggestionsByType(CleanupSuggestionType type,) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      _tableName,
      where: 'type = ? AND status = ?',
      whereArgs: <Object?>[
        type.name,
        CleanupSuggestionStatus.suggested.name,
      ],
      orderBy: 'score DESC, updated_at DESC',
    );

    return rows.map(_rowToSuggestion).toList();
  }

  @override
  Future<void> updateAllStatus(CleanupSuggestionStatus status) async {
    final Database db = await _db;
    await db.update(
      _tableName,
      _statusUpdateRow(status),
      where: 'status = ?',
      whereArgs: <Object?>[CleanupSuggestionStatus.suggested.name],
    );
  }

  @override
  Future<void> updateStatus(String assetId, CleanupSuggestionStatus status,) async {
    final Database db = await _db;
    await db.update(
      _tableName,
      _statusUpdateRow(status),
      where: 'asset_id = ?',
      whereArgs: <Object?>[assetId],
    );
  }

  @override
  Future<void> updateStatusByType(CleanupSuggestionType type, CleanupSuggestionStatus status,) async {
    final Database db = await _db;
    await db.update(
      _tableName,
      _statusUpdateRow(status),
      where: 'type = ? AND status = ?',
      whereArgs: <Object?>[
        type.name,
        CleanupSuggestionStatus.suggested.name,
      ],
    );
  }

  @override
  Future<void> upsertSuggestion(CleanupSuggestion suggestion) async {
    await upsertSuggestions(<CleanupSuggestion>[suggestion]);
  }

  @override
  Future<void> upsertSuggestions(List<CleanupSuggestion> suggestions) async {
    if (suggestions.isEmpty) {
      return;
    }

    final Database db = await _db;
    final Batch batch = db.batch();

    for (final CleanupSuggestion suggestion in suggestions) {
      batch.insert(
        _tableName,
        _suggestionToRow(suggestion),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<int> _countRows(Database db, {CleanupSuggestionStatus? status,}) async {
    final List<Map<String, Object?>> rows = status == null
        ? await db.rawQuery('SELECT COUNT(*) AS count FROM $_tableName')
        : await db.rawQuery(
            '''
            SELECT COUNT(*) AS count
            FROM $_tableName
            WHERE status = ?
            ''',
            <Object?>[status.name],
          );

    return Sqflite.firstIntValue(rows) ?? 0;
  }

  Future<List<String>> _previewAssetIds(Database db, CleanupSuggestionType type,) async {
    final List<Map<String, Object?>> rows = await db.query(
      _tableName,
      columns: <String>['asset_id'],
      where: 'type = ? AND status = ?',
      whereArgs: <Object?>[
        type.name,
        CleanupSuggestionStatus.suggested.name,
      ],
      orderBy: 'score DESC, updated_at DESC',
      limit: 4,
    );

    return rows
        .map((Map<String, Object?> row) => row['asset_id'].toString())
        .toList();
  }

  Map<String, Object?> _suggestionToRow(CleanupSuggestion suggestion) {
    return <String, Object?>{
      'asset_id': suggestion.assetId,
      'type': suggestion.type.name,
      'status': suggestion.status.name,
      'score': suggestion.score,
      'reason': suggestion.reason,
      'group_id': suggestion.groupId,
      'features_json': jsonEncode(suggestion.features ?? <String, dynamic>{}),
      'created_at': suggestion.createdAt.toIso8601String(),
      'updated_at': suggestion.updatedAt.toIso8601String(),
    };
  }

  CleanupSuggestion _rowToSuggestion(Map<String, Object?> row) {
    return CleanupSuggestion(
      assetId: row['asset_id'].toString(),
      type: _typeFromName(row['type']?.toString()) ??
          CleanupSuggestionType.badQuality,
      status: _statusFromName(row['status']?.toString()) ??
          CleanupSuggestionStatus.suggested,
      score: (row['score'] as num?)?.toDouble() ?? 0.0,
      reason: (row['reason'] ?? '').toString(),
      createdAt: _parseDate(row['created_at']),
      updatedAt: _parseDate(row['updated_at']),
      groupId: row['group_id']?.toString(),
      features: _decodeFeatures(row['features_json']),
    );
  }

  Map<String, Object?> _statusUpdateRow(CleanupSuggestionStatus status) {
    return <String, Object?>{
      'status': status.name,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> _decodeFeatures(Object? raw) {
    final String json = (raw ?? '{}').toString();
    try {
      final Object? decoded = jsonDecode(json);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map(
          (dynamic key, dynamic value) => MapEntry<String, dynamic>(
            key.toString(),
            value,
          ),
        );
      }
    } catch (_) {}

    return <String, dynamic>{};
  }

  DateTime _parseDate(Object? raw) {
    final String value = (raw ?? '').toString();
    return DateTime.tryParse(value) ?? DateTime.now();
  }

  CleanupSuggestionType? _typeFromName(String? name) {
    if (name == null || name.isEmpty) {
      return null;
    }

    for (final CleanupSuggestionType type in CleanupSuggestionType.values) {
      if (type.name == name) {
        return type;
      }
    }

    return null;
  }

  CleanupSuggestionStatus? _statusFromName(String? name) {
    if (name == null || name.isEmpty) {
      return null;
    }

    for (final CleanupSuggestionStatus status
        in CleanupSuggestionStatus.values) {
      if (status.name == name) {
        return status;
      }
    }

    return null;
  }

  String _titleForType(CleanupSuggestionType type) {
    return switch (type) {
      CleanupSuggestionType.expired => 'Expired items',
      CleanupSuggestionType.badQuality => 'Bad photos',
      CleanupSuggestionType.duplicate => 'Possible duplicates',
      CleanupSuggestionType.screenshot => 'Screenshots',
      CleanupSuggestionType.document => 'Documents',
    };
  }

  String _subtitleForType(CleanupSuggestionType type) {
    return switch (type) {
      CleanupSuggestionType.expired =>
        'Announcements, tickets, or screenshots with past dates',
      CleanupSuggestionType.badQuality =>
        'Blurry, dark, overexposed, or low-contrast images',
      CleanupSuggestionType.duplicate =>
        'Photos that look similar to nearby shots',
      CleanupSuggestionType.screenshot =>
        'Screenshots that may no longer be useful',
      CleanupSuggestionType.document =>
        'Scans, receipts, tickets, or document-like images',
    };
  }
}
