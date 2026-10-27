class Trip {
  Trip({
    required this.id,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.coverPhotoPath,
    this.description = '',
    required this.createdAt,
    required this.updatedAt,
    this.memoryCount = 0,
    this.placeCount = 0,
  });

  final String id;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String? coverPhotoPath;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int memoryCount;
  final int placeCount;

  Trip copyWith({
    String? title,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? coverPhotoPath,
    String? description,
    DateTime? updatedAt,
    int? memoryCount,
    int? placeCount,
  }) {
    return Trip(
      id: id,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      coverPhotoPath: coverPhotoPath ?? this.coverPhotoPath,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      memoryCount: memoryCount ?? this.memoryCount,
      placeCount: placeCount ?? this.placeCount,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'destination': destination,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'cover_photo_path': coverPhotoPath,
        'description': description,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Trip.fromMap(Map<String, Object?> map, {int memoryCount = 0, int placeCount = 0}) {
    return Trip(
      id: map['id'] as String,
      title: map['title'] as String,
      destination: map['destination'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      coverPhotoPath: map['cover_photo_path'] as String?,
      description: (map['description'] as String?) ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      memoryCount: memoryCount,
      placeCount: placeCount,
    );
  }
}
