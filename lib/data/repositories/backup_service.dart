import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../database/app_database.dart';
import 'photo_storage.dart';

/// Full scrapbook backup: JSON manifest + image files in a zip archive.
class BackupService {
  BackupService({
    AppDatabase? database,
    PhotoStorage? photoStorage,
  })  : _dbProvider = database ?? AppDatabase.instance,
        _photos = photoStorage ?? PhotoStorage();

  static const backupVersion = 2;
  static const manifestName = 'manifest.json';
  static const mediaPrefix = 'media/';

  final AppDatabase _dbProvider;
  final PhotoStorage _photos;
  final _uuid = const Uuid();

  Future<Database> get _db => _dbProvider.database;

  Future<File> exportArchive({
    required Future<List<Map<String, Object?>>> Function() loadTrips,
    required Future<List<Map<String, dynamic>>> Function() loadMemoriesWithMeta,
  }) async {
    final pathMap = <String, String>{};
    var mediaIndex = 0;

    Future<String?> archivePathFor(String? localPath) async {
      if (localPath == null || localPath.isEmpty) return null;
      final file = File(localPath);
      if (!await file.exists()) return null;
      final existing = pathMap[localPath];
      if (existing != null) return existing;
      mediaIndex++;
      final ext = p.extension(localPath);
      final safeExt = ext.isEmpty ? '.jpg' : ext;
      final entry = '$mediaPrefix${mediaIndex.toString().padLeft(4, '0')}$safeExt';
      pathMap[localPath] = entry;
      return entry;
    }

    final tripsRaw = await loadTrips();
    final trips = <Map<String, dynamic>>[];
    for (final raw in tripsRaw) {
      final map = Map<String, dynamic>.from(raw);
      final cover = map['cover_photo_path'] as String?;
      map['cover_archive_path'] = await archivePathFor(cover);
      trips.add(map);
    }

    final memoriesRaw = await loadMemoriesWithMeta();
    final memories = <Map<String, dynamic>>[];
    for (final raw in memoriesRaw) {
      final map = Map<String, dynamic>.from(raw);
      final photos = (map['photos'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      for (final photo in photos) {
        photo['archive_path'] = await archivePathFor(photo['file_path'] as String?);
        final thumb = photo['thumbnail_path'] as String?;
        if (thumb != null && thumb.isNotEmpty) {
          photo['thumbnail_archive_path'] = await archivePathFor(thumb);
        }
      }
      map['photos'] = photos;
      memories.add(map);
    }

    final manifest = {
      'format': 'travel_pal_backup',
      'version': backupVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'app': AppStrings.appName,
      'trips': trips,
      'memories': memories,
    };

    final archive = Archive();
    final manifestBytes = utf8.encode(const JsonEncoder.withIndent('  ').convert(manifest));
    archive.addFile(ArchiveFile(manifestName, manifestBytes.length, manifestBytes));

    for (final entry in pathMap.entries) {
      final bytes = await File(entry.key).readAsBytes();
      archive.addFile(ArchiveFile(entry.value, bytes.length, bytes));
    }

    final zipBytes = ZipEncoder().encode(archive);

    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, AppConstants.backupsDir));
    if (!await dir.exists()) await dir.create(recursive: true);
    final file = File(
      p.join(
        dir.path,
        'travel_pal_backup_${DateTime.now().millisecondsSinceEpoch}.travelpal.zip',
      ),
    );
    await file.writeAsBytes(zipBytes, flush: true);
    return file;
  }

  Future<void> importArchiveBytes(Uint8List bytes) async {
    final archive = ZipDecoder().decodeBytes(bytes);
    ArchiveFile? manifestFile;
    for (final file in archive.files) {
      if (file.name == manifestName) {
        manifestFile = file;
        break;
      }
    }
    if (manifestFile == null) {
      throw FormatException('Backup is missing $manifestName.');
    }

    final manifest = jsonDecode(utf8.decode(manifestFile.content as List<int>))
        as Map<String, dynamic>;
    if (manifest['format'] != 'travel_pal_backup') {
      throw FormatException('Unrecognized backup format.');
    }

    final mediaFiles = <String, List<int>>{};
    for (final file in archive.files) {
      if (file.name.startsWith(mediaPrefix) && file.isFile) {
        mediaFiles[file.name] = file.content as List<int>;
      }
    }

    await _clearScrapbookData();

    Future<String?> restorePath(String? archivePath) async {
      if (archivePath == null || archivePath.isEmpty) return null;
      final data = mediaFiles[archivePath];
      if (data == null) return null;
      final name = p.basename(archivePath);
      return _photos.saveBytes(data, 'restore_$name');
    }

    final db = await _db;
    final trips = manifest['trips'] as List<dynamic>? ?? [];
    for (final raw in trips) {
      final map = Map<String, dynamic>.from(raw as Map);
      final coverArchive = map.remove('cover_archive_path') as String?;
      final coverLocal = await restorePath(coverArchive);
      final tripRow = Map<String, Object?>.from(map)
        ..remove('memory_count')
        ..remove('place_count');
      tripRow['cover_photo_path'] = coverLocal ?? tripRow['cover_photo_path'];
      await db.insert('trips', tripRow, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    final memories = manifest['memories'] as List<dynamic>? ?? [];
    for (final raw in memories) {
      final map = Map<String, dynamic>.from(raw as Map);
      final tags = (map.remove('tags') as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList();
      final photos = (map.remove('photos') as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      map.remove('trip_title');

      final memoryRow = Map<String, Object?>.from(map);
      await db.insert(
        'memories',
        memoryRow,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await _setTags(db, memoryRow['id'] as String, tags);

      for (final photo in photos) {
        final fileArchive = photo.remove('archive_path') as String?;
        final thumbArchive = photo.remove('thumbnail_archive_path') as String?;
        photo.remove('file_path');
        photo.remove('thumbnail_path');
        final filePath = await restorePath(fileArchive);
        final thumbPath = await restorePath(thumbArchive);
        if (filePath == null) continue;
        final photoRow = Map<String, Object?>.from(photo)
          ..['file_path'] = filePath
          ..['thumbnail_path'] = thumbPath;
        await db.insert(
          'photos',
          photoRow,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }

  Future<void> _clearScrapbookData() async {
    final db = await _db;
    final trips = await db.query('trips');
    for (final row in trips) {
      final cover = row['cover_photo_path'] as String?;
      await _photos.deleteIfExists(cover);
    }
    final photoRows = await db.query('photos');
    for (final row in photoRows) {
      await _photos.deleteIfExists(row['file_path'] as String?);
      await _photos.deleteIfExists(row['thumbnail_path'] as String?);
    }
    await db.delete('memory_tags');
    await db.delete('photos');
    await db.delete('memories');
    await db.delete('trips');
    await db.delete('tags');
  }

  Future<void> _setTags(Database db, String memoryId, List<String> tags) async {
    for (final raw in tags) {
      final name = raw.trim();
      if (name.isEmpty) continue;
      final existing = await db.query(
        'tags',
        where: 'LOWER(name) = ?',
        whereArgs: [name.toLowerCase()],
        limit: 1,
      );
      String tagId;
      if (existing.isEmpty) {
        tagId = _uuid.v4();
        await db.insert('tags', {'id': tagId, 'name': name});
      } else {
        tagId = existing.first['id'] as String;
      }
      await db.insert(
        'memory_tags',
        {'memory_id': memoryId, 'tag_id': tagId},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }
}
