import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class LocalImage extends StatelessWidget {
  const LocalImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final String? path;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty || !File(path!).existsSync()) {
      return Container(
        width: width,
        height: height,
        color: AppColors.paperDeep,
        alignment: Alignment.center,
        child: const Icon(Icons.image_outlined, color: AppColors.muted),
      );
    }
    return Image.file(
      File(path!),
      fit: fit,
      width: width,
      height: height,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, error, stackTrace) => Container(
        width: width,
        height: height,
        color: AppColors.paperDeep,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_outlined, color: AppColors.muted),
      ),
    );
  }
}
