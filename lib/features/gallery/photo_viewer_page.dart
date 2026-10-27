import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/photo.dart';

class PhotoViewerPage extends StatefulWidget {
  const PhotoViewerPage({
    super.key,
    required this.photos,
    this.initialIndex = 0,
    this.title,
  });

  final List<Photo> photos;
  final int initialIndex;
  final String? title;

  @override
  State<PhotoViewerPage> createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends State<PhotoViewerPage> {
  late final PageController _controller;
  late int _index;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photos[_index];
    return Scaffold(
      backgroundColor: AppColors.photoBg,
      body: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: Stack(
          children: [
            PhotoViewGallery.builder(
              pageController: _controller,
              itemCount: widget.photos.length,
              onPageChanged: (i) => setState(() => _index = i),
              backgroundDecoration: const BoxDecoration(color: AppColors.photoBg),
              builder: (context, index) {
                final item = widget.photos[index];
                return PhotoViewGalleryPageOptions(
                  imageProvider: FileImage(File(item.filePath)),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 3,
                  heroAttributes: PhotoViewHeroAttributes(tag: 'photo-${item.id}'),
                );
              },
            ),
            if (_showControls) ...[
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: AppColors.cream),
                      ),
                      const Spacer(),
                      Text(
                        '${_index + 1} / ${widget.photos.length}',
                        style: const TextStyle(color: AppColors.cream),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 36,
                child: Column(
                  children: [
                    if (widget.title != null)
                      Text(
                        widget.title!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.cream,
                          fontSize: 16,
                        ),
                      ),
                    if (photo.caption.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        photo.caption,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.cream.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
