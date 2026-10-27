import 'package:flutter/foundation.dart';

import '../models/memory_entry.dart';
import '../models/trip.dart';
import '../repositories/travel_repository.dart';
import '../seed/sample_seeder.dart';

class TravelAppState extends ChangeNotifier {
  TravelAppState(this._repo);

  final TravelRepository _repo;

  bool loading = true;
  String? error;
  List<Trip> trips = [];
  List<MemoryEntry> feed = [];
  List<MemoryEntry> saved = [];
  String searchQuery = '';

  TravelRepository get repository => _repo;

  Future<void> initialize() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await SampleSeeder(_repo).seedIfNeeded();
      await refresh();
    } catch (e) {
      error = 'Couldn’t open your scrapbook. Try restarting the app.';
      loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    trips = await _repo.getTrips();
    feed = await _repo.getFeedMemories(query: searchQuery);
    saved = await _repo.getSavedMemories();
    loading = false;
    error = null;
    notifyListeners();
  }

  Future<void> setSearch(String query) async {
    searchQuery = query;
    feed = await _repo.getFeedMemories(query: query);
    notifyListeners();
  }

  Future<Trip?> getTrip(String id) => _repo.getTrip(id);

  Future<List<MemoryEntry>> memoriesForTrip(String tripId) =>
      _repo.getMemoriesForTrip(tripId);

  Future<MemoryEntry?> getMemory(String id) => _repo.getMemory(id);

  Future<Trip> createTrip({
    required String title,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    String? coverPhotoPath,
    String description = '',
  }) async {
    final trip = await _repo.createTrip(
      title: title,
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      coverPhotoPath: coverPhotoPath,
      description: description,
    );
    await refresh();
    return trip;
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
    final memory = await _repo.createMemory(
      tripId: tripId,
      title: title,
      content: content,
      location: location,
      date: date,
      tags: tags,
      photos: photos,
    );
    await refresh();
    return memory;
  }

  Future<void> toggleSaved(String memoryId) async {
    await _repo.toggleSaved(memoryId);
    await refresh();
  }

  Future<void> deleteMemory(String memoryId) async {
    await _repo.deleteMemory(memoryId);
    await refresh();
  }

  Future<void> deleteTrip(String tripId) async {
    await _repo.deleteTrip(tripId);
    await refresh();
  }
}
