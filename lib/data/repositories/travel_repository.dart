import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../models/memory_entry.dart';
import '../models/photo.dart';
import '../models/trip.dart';
import 'backup_service.dart';
import 'photo_storage.dart';

class TravelRepository {
  TravelRepository({
    AppDatabase? database,
    PhotoStorage? photoStorage,
  })  : _dbProvider = database ?? AppDatabase.instance,
        _photos = photoStorage ?? PhotoStorage();

  final AppDatabase _dbProvider;
  final PhotoStorage _photos;
  final _uuid = const Uuid();

  Future<Database> get _db => _dbProvider.database;

  Future<String> getSetting(String key, {String fallback = ''}) async {
    final db = await _db;
    final rows = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return fallback;
    return rows.first['value'] as String? ?? fallback;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await _db;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Trip>> getTrips() async {
    final db = await _db;
    final rows = await db.query('trips', orderBy: 'start_date DESC');
    final trips = <Trip>[];
    for (final row in rows) {
      trips.add(await _enrichTrip(row));
    }
    return trips;
  }

  Future<Trip?> getTrip(String id) async {
    final db = await _db;
    final rows = await db.query('trips', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return _enrichTrip(rows.first);
  }

  Future<Trip> _enrichTrip(Map<String, Object?> row) async {
    final db = await _db;
    final id = row['id'] as String;
    final memories = await db.query(
      'memories',
      columns: ['id', 'location'],
      where: 'trip_id = ?',
      whereArgs: [id],
    );
    final places = memories
        .map((m) => (m['location'] as String?)?.trim() ?? '')
        .where((l) => l.isNotEmpty)
        .toSet()
        .length;
    return Trip.fromMap(
      row,
      memoryCount: memories.length,
      placeCount: places,
    );
  }

  Future<Trip> createTrip({
    required String title,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    String? coverPhotoPath,
    String description = '',
  }) async {
    final now = DateTime.now();
    final trip = Trip(
      id: _uuid.v4(),
      title: title.trim(),
      destination: destination.trim(),
      startDate: startDate,
      endDate: endDate,
      coverPhotoPath: coverPhotoPath,
      description: description.trim(),
      createdAt: now,
      updatedAt: now,
    );
    final db = await _db;
    await db.insert('trips', trip.toMap());
    return trip;
  }

  Future<void> updateTrip(Trip trip) async {
    final db = await _db;
    await db.update(
      'trips',
      trip.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [trip.id],
    );
  }

  Future<void> deleteTrip(String id) async {
    final memories = await getMemoriesForTrip(id);
    for (final memory in memories) {
      await deleteMemory(memory.id);
    }
    final trip = await getTrip(id);
    await _photos.deleteIfExists(trip?.coverPhotoPath);
    final db = await _db;
    await db.delete('trips', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<MemoryEntry>> getFeedMemories({String? query}) async {
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT m.*, t.title AS trip_title
      FROM memories m
      INNER JOIN trips t ON t.id = m.trip_id
      ORDER BY m.date DESC, m.created_at DESC
    ''');
    var memories = <MemoryEntry>[];
    for (final row in rows) {
      memories.add(await _hydrateMemory(row));
    }
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      memories = memories.where((m) {
        final hay = [
          m.title,
          m.content,
          m.location,
          m.tripTitle ?? '',
          ...m.tags,
        ].join(' ').toLowerCase();
        return hay.contains(q);
      }).toList();
    }
    return memories.where((m) => m.photos.isNotEmpty).toList();
  }

  Future<List<MemoryEntry>> getMemoriesForTrip(String tripId) async {
    final db = await _db;
    final rows = await db.query(
      'memories',
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'date ASC, created_at ASC',
    );
    final memories = <MemoryEntry>[];
    for (final row in rows) {
      memories.add(await _hydrateMemory(row));
    }
    return memories;
  }

  Future<List<MemoryEntry>> getSavedMemories() async {
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT m.*, t.title AS trip_title
      FROM memories m
      INNER JOIN trips t ON t.id = m.trip_id
      WHERE m.is_saved = 1
      ORDER BY m.date DESC
    ''');
    final memories = <MemoryEntry>[];
    for (final row in rows) {
      memories.add(await _hydrateMemory(row));
    }
    return memories;
  }

  Future<MemoryEntry?> getMemory(String id) async {
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT m.*, t.title AS trip_title
      FROM memories m
      INNER JOIN trips t ON t.id = m.trip_id
      WHERE m.id = ?
      LIMIT 1
    ''', [id]);
    if (rows.isEmpty) return null;
    return _hydrateMemory(rows.first);
  }

  Future<MemoryEntry> _hydrateMemory(Map<String, Object?> row) async {
    final id = row['id'] as String;
    final photos = await getPhotosForMemory(id);
    final tags = await getTagsForMemory(id);
    return MemoryEntry.fromMap(
      row,
      photos: photos,
      tags: tags,
      tripTitle: row['trip_title'] as String?,
    );
  }

  Future<List<Photo>> getPhotosForMemory(String memoryId) async {
    final db = await _db;
    final rows = await db.query(
      'photos',
      where: 'memory_id = ?',
      whereArgs: [memoryId],
      orderBy: 'sort_order ASC',
    );
    return rows.map(Photo.fromMap).toList();
  }

  Future<List<Photo>> getPhotosForTrip(String tripId) async {
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT p.*
      FROM photos p
      INNER JOIN memories m ON m.id = p.memory_id
      WHERE m.trip_id = ?
      ORDER BY m.date ASC, p.sort_order ASC
    ''', [tripId]);
    return rows.map(Photo.fromMap).toList();
  }

  Future<List<String>> getTagsForMemory(String memoryId) async {
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT t.name
      FROM tags t
      INNER JOIN memory_tags mt ON mt.tag_id = t.id
      WHERE mt.memory_id = ?
      ORDER BY t.name ASC
    ''', [memoryId]);
    return rows.map((r) => r['name'] as String).toList();
  }

  Future<MemoryEntry> createMemory({
    required String tripId,
    required String title,
    required String content,
    required String location,
    required DateTime date,
    required List<String> tags,
    required List<PendingPhoto> photos,
  }) async {
    final now = DateTime.now();
    final memory = MemoryEntry(
      id: _uuid.v4(),
      tripId: tripId,
      title: title.trim(),
      content: content.trim(),
      location: location.trim(),
      date: date,
      createdAt: now,
      updatedAt: now,
    );
    final db = await _db;
    await db.insert('memories', memory.toMap());
    await _setTags(memory.id, tags);
    final savedPhotos = <Photo>[];
    for (var i = 0; i < photos.length; i++) {
      final pending = photos[i];
      final path = await _photos.saveFromFile(File(pending.sourcePath));
      final photo = Photo(
        id: _uuid.v4(),
        memoryId: memory.id,
        filePath: path,
        thumbnailPath: path,
        caption: pending.caption,
        sortOrder: i,
        width: pending.width,
        height: pending.height,
      );
      await db.insert('photos', photo.toMap());
      savedPhotos.add(photo);
    }
    await db.update(
      'trips',
      {'updated_at': now.toIso8601String()},
      where: 'id = ?',
      whereArgs: [tripId],
    );
    return memory.copyWith(photos: savedPhotos, tags: tags);
  }

  Future<void> toggleSaved(String memoryId) async {
    final memory = await getMemory(memoryId);
    if (memory == null) return;
    final db = await _db;
    await db.update(
      'memories',
      {
        'is_saved': memory.isSaved ? 0 : 1,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [memoryId],
    );
  }

  Future<void> deleteMemory(String id) async {
    final photos = await getPhotosForMemory(id);
    for (final photo in photos) {
      await _photos.deleteIfExists(photo.filePath);
      await _photos.deleteIfExists(photo.thumbnailPath);
    }
    final db = await _db;
    await db.delete('memory_tags', where: 'memory_id = ?', whereArgs: [id]);
    await db.delete('photos', where: 'memory_id = ?', whereArgs: [id]);
    await db.delete('memories', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> _setTags(String memoryId, List<String> tags) async {
    final db = await _db;
    await db.delete('memory_tags', where: 'memory_id = ?', whereArgs: [memoryId]);
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

  Future<File> exportFullBackup() async {
    final backup = BackupService(
      database: _dbProvider,
      photoStorage: _photos,
    );
    return backup.exportArchive(
      loadTrips: () async {
        final trips = await getTrips();
        return trips.map((t) => t.toMap()).toList();
      },
      loadMemoriesWithMeta: () async {
        final trips = await getTrips();
        final allMemories = <Map<String, dynamic>>[];
        for (final trip in trips) {
          final memories = await getMemoriesForTrip(trip.id);
          for (final memory in memories) {
            allMemories.add({
              ...memory.toMap(),
              'tags': memory.tags,
              'photos': memory.photos.map((p) => p.toMap()).toList(),
              'trip_title': trip.title,
            });
          }
        }
        return allMemories;
      },
    );
  }

  Future<String> exportTripMarkdown(String tripId) async {
    final trip = await getTrip(tripId);
    if (trip == null) return '';
    final memories = await getMemoriesForTrip(tripId);
    final buffer = StringBuffer()
      ..writeln('# ${trip.title}')
      ..writeln()
      ..writeln('**${trip.destination}**')
      ..writeln()
      ..writeln('${trip.startDate.toIso8601String().split('T').first} — ${trip.endDate.toIso8601String().split('T').first}')
      ..writeln();
    if (trip.description.isNotEmpty) {
      buffer.writeln(trip.description);
      buffer.writeln();
    }
    for (final memory in memories) {
      buffer
        ..writeln('## ${memory.title}')
        ..writeln()
        ..writeln('- Date: ${memory.date.toIso8601String().split('T').first}')
        ..writeln('- Location: ${memory.location}')
        ..writeln();
      if (memory.content.isNotEmpty) {
        buffer.writeln(memory.content);
        buffer.writeln();
      }
      if (memory.tags.isNotEmpty) {
        buffer.writeln('Tags: ${memory.tags.join(', ')}');
        buffer.writeln();
      }
    }
    return buffer.toString();
  }

  Future<void> importFullBackup(File archiveFile) async {
    final bytes = await archiveFile.readAsBytes();
    final backup = BackupService(
      database: _dbProvider,
      photoStorage: _photos,
    );
    await backup.importArchiveBytes(bytes);
  }

  PhotoStorage get photoStorage => _photos;
}

class PendingPhoto {
  PendingPhoto({
    required this.sourcePath,
    this.caption = '',
    this.width = 1200,
    this.height = 1600,
  });

  final String sourcePath;
  final String caption;
  final int width;
  final int height;
}
