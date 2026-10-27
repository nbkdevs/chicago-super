import 'photo.dart';

class MemoryEntry {
  MemoryEntry({
    required this.id,
    required this.tripId,
    required this.title,
    required this.content,
    required this.location,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.isSaved = false,
    this.tags = const [],
    this.photos = const [],
    this.tripTitle,
  });

  final String id;
  final String tripId;
  final String title;
  final String content;
  final String location;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSaved;
  final List<String> tags;
  final List<Photo> photos;
  final String? tripTitle;

  Photo? get coverPhoto => photos.isEmpty ? null : photos.first;

  MemoryEntry copyWith({
    String? title,
    String? content,
    String? location,
    DateTime? date,
    DateTime? updatedAt,
    bool? isSaved,
    List<String>? tags,
    List<Photo>? photos,
    String? tripTitle,
  }) {
    return MemoryEntry(
      id: id,
      tripId: tripId,
      title: title ?? this.title,
      content: content ?? this.content,
      location: location ?? this.location,
      date: date ?? this.date,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSaved: isSaved ?? this.isSaved,
      tags: tags ?? this.tags,
      photos: photos ?? this.photos,
      tripTitle: tripTitle ?? this.tripTitle,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'trip_id': tripId,
        'title': title,
        'content': content,
        'location': location,
        'date': date.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'is_saved': isSaved ? 1 : 0,
      };

  factory MemoryEntry.fromMap(
    Map<String, Object?> map, {
    List<String> tags = const [],
    List<Photo> photos = const [],
    String? tripTitle,
  }) {
    return MemoryEntry(
      id: map['id'] as String,
      tripId: map['trip_id'] as String,
      title: map['title'] as String,
      content: (map['content'] as String?) ?? '',
      location: (map['location'] as String?) ?? '',
      date: DateTime.parse(map['date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isSaved: (map['is_saved'] as int? ?? 0) == 1,
      tags: tags,
      photos: photos,
      tripTitle: tripTitle,
    );
  }
}
