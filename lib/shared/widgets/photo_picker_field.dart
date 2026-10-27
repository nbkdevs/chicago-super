import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../data/repositories/travel_repository.dart';
import '../../shared/widgets/local_image.dart';

class PhotoDraft {
  PhotoDraft({
    required this.path,
    this.width = 1200,
    this.height = 1600,
  });

  final String path;
  final int width;
  final int height;

  PendingPhoto toPending() => PendingPhoto(
        sourcePath: path,
        width: width,
        height: height,
      );
}

class PhotoPickerField extends StatefulWidget {
  const PhotoPickerField({
    super.key,
    required this.photos,
    required this.onChanged,
    this.multiple = true,
    this.label = 'Add photos',
  });

  final List<PhotoDraft> photos;
  final ValueChanged<List<PhotoDraft>> onChanged;
  final bool multiple;
  final String label;

  @override
  State<PhotoPickerField> createState() => _PhotoPickerFieldState();
}

class _PhotoPickerFieldState extends State<PhotoPickerField> {
  final _picker = ImagePicker();
  bool _busy = false;

  Future<void> _pick(ImageSource source) async {
    setState(() => _busy = true);
    try {
      if (widget.multiple && source == ImageSource.gallery) {
        final files = await _picker.pickMultiImage(imageQuality: 88);
        if (files.isEmpty) return;
        final next = [
          ...widget.photos,
          ...files.map((f) => PhotoDraft(path: f.path)),
        ];
        widget.onChanged(next);
      } else {
        final file = await _picker.pickImage(source: source, imageQuality: 88);
        if (file == null) return;
        final draft = PhotoDraft(path: file.path);
        widget.onChanged(
          widget.multiple ? [...widget.photos, draft] : [draft],
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't add this photo. Try selecting it again.")),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pick(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pick(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: _busy ? null : _showSheet,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.cream.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.border, style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                Text(
                  widget.label,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  _busy ? 'Adding…' : 'Camera or gallery',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        if (widget.photos.isNotEmpty) ...[
          const SizedBox(height: 14),
          SizedBox(
            height: 120,
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.photos.length,
              onReorderItem: (oldIndex, newIndex) {
                final items = [...widget.photos];
                final item = items.removeAt(oldIndex);
                items.insert(newIndex, item);
                widget.onChanged(items);
              },
              itemBuilder: (context, index) {
                final photo = widget.photos[index];
                return Padding(
                  key: ValueKey(photo.path),
                  padding: const EdgeInsets.only(right: 10),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: AspectRatio(
                          aspectRatio: 3 / 4,
                          child: LocalImage(path: photo.path),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () {
                            final next = [...widget.photos]..removeAt(index);
                            widget.onChanged(next);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            color: AppColors.ink.withValues(alpha: 0.65),
                            child: const Icon(Icons.close, size: 14, color: AppColors.cream),
                          ),
                        ),
                      ),
                      if (index == 0)
                        Positioned(
                          left: 4,
                          bottom: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            color: AppColors.ink.withValues(alpha: 0.65),
                            child: const Text(
                              'COVER',
                              style: TextStyle(
                                color: AppColors.cream,
                                fontSize: 9,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Long-press and drag to reorder',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

/// Ensures file still exists helper for cover selection.
bool photoFileExists(String path) => File(path).existsSync();
