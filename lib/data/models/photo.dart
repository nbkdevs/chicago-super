class Photo {
  Photo({
    required this.id,
    required this.memoryId,
    required this.filePath,
    this.thumbnailPath,
    this.caption = '',
    required this.sortOrder,
    required this.width,
    required this.height,
  });

  final String id;
  final String memoryId;
  final String filePath;
  final String? thumbnailPath;
  final String caption;
  final int sortOrder;
  final int width;
  final int height;

  double get aspectRatio => width <= 0 || height <= 0 ? 0.75 : width / height;

  String get displayPath => thumbnailPath ?? filePath;

  Map<String, Object?> toMap() => {
        'id': id,
        'memory_id': memoryId,
        'file_path': filePath,
        'thumbnail_path': thumbnailPath,
        'caption': caption,
        'sort_order': sortOrder,
        'width': width,
        'height': height,
      };

  factory Photo.fromMap(Map<String, Object?> map) {
    return Photo(
      id: map['id'] as String,
      memoryId: map['memory_id'] as String,
      filePath: map['file_path'] as String,
      thumbnailPath: map['thumbnail_path'] as String?,
      caption: (map['caption'] as String?) ?? '',
      sortOrder: map['sort_order'] as int? ?? 0,
      width: map['width'] as int? ?? 1000,
      height: map['height'] as int? ?? 1200,
    );
  }
}
