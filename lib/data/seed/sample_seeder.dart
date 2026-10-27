import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../models/trip.dart';
import '../repositories/travel_repository.dart';

class SampleSeeder {
  SampleSeeder(this._repo);

  final TravelRepository _repo;
  final _uuid = const Uuid();

  Future<void> seedIfNeeded() async {
    final flagged = await _repo.getSetting(AppConstants.seededFlag);
    if (flagged == '1') return;
    final legacy = await _repo.getSetting('seeded_v1');
    if (legacy == '1') {
      await _repo.setSetting(AppConstants.seededFlag, '1');
      return;
    }

    final japanCover = await _repo.photoStorage.saveFromAsset(
      'assets/sample/japan-cover.jpg',
      'seed_japan_cover.jpg',
    );

    final japan = await _insertTrip(
      title: 'Japan 2026',
      destination: 'Tokyo · Kyoto · Osaka',
      start: DateTime(2026, 9, 12),
      end: DateTime(2026, 9, 26),
      cover: japanCover,
      description:
          'Sample trip — explore it, then add your own journeys from the Trips tab.',
    );

    await _memory(
      tripId: japan.id,
      title: 'Shibuya After Dark',
      content:
          'The streets were packed, neon everywhere, and somehow we kept walking for hours.',
      location: 'Shibuya, Tokyo',
      date: DateTime(2026, 9, 14),
      tags: ['Tokyo', 'Night', 'City'],
      assets: const [
        ('assets/sample/shibuya-1.jpg', 1200, 1600),
        ('assets/sample/shibuya-2.jpg', 1200, 900),
      ],
      saved: true,
    );
    await _memory(
      tripId: japan.id,
      title: 'First Morning in Kyoto',
      content:
          'Incense at the gate, golden light on temple wood, and a quiet that felt earned.',
      location: 'Asakusa, Tokyo',
      date: DateTime(2026, 9, 13),
      tags: ['Temple', 'Morning'],
      assets: const [
        ('assets/sample/sensoji-1.jpg', 1400, 1000),
      ],
    );

    await _repo.setSetting(AppConstants.seededFlag, '1');
  }

  Future<Trip> _insertTrip({
    required String title,
    required String destination,
    required DateTime start,
    required DateTime end,
    required String cover,
    required String description,
  }) {
    return _repo.createTrip(
      title: title,
      destination: destination,
      startDate: start,
      endDate: end,
      coverPhotoPath: cover,
      description: description,
    );
  }

  Future<void> _memory({
    required String tripId,
    required String title,
    required String content,
    required String location,
    required DateTime date,
    required List<String> tags,
    required List<(String, int, int)> assets,
    bool saved = false,
  }) async {
    final pending = <PendingPhoto>[];
    for (var i = 0; i < assets.length; i++) {
      final (asset, w, h) = assets[i];
      final path = await _repo.photoStorage.saveFromAsset(
        asset,
        'seed_${_uuid.v4().substring(0, 8)}.jpg',
      );
      pending.add(PendingPhoto(sourcePath: path, width: w, height: h));
    }
    final memory = await _repo.createMemory(
      tripId: tripId,
      title: title,
      content: content,
      location: location,
      date: date,
      tags: tags,
      photos: pending,
    );
    if (saved) await _repo.toggleSaved(memory.id);
  }
}
