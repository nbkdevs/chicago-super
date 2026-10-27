import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utilities/date_formatters.dart';
import '../../data/models/memory_entry.dart';
import 'local_image.dart';

class MemoryCard extends StatelessWidget {
  const MemoryCard({
    super.key,
    required this.memory,
    required this.onTap,
  });

  final MemoryEntry memory;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final photo = memory.coverPhoto;
    final ratio = photo?.aspectRatio ?? 0.75;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: ratio.clamp(0.55, 1.35),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Hero(
                tag: 'memory-cover-${memory.id}',
                child: LocalImage(path: photo?.displayPath),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            memory.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              height: 1.2,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            [
              if (memory.location.isNotEmpty) memory.location,
              if (memory.tripTitle != null) memory.tripTitle!,
            ].join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Text(
            DateFormatters.feedDate(memory.date),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
          ),
        ],
      ),
    );
  }
}
