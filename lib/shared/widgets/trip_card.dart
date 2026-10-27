import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utilities/date_formatters.dart';
import '../../data/models/trip.dart';
import 'local_image.dart';

class TripCard extends StatelessWidget {
  const TripCard({
    super.key,
    required this.trip,
    required this.onTap,
  });

  final Trip trip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Hero(
                tag: 'trip-cover-${trip.id}',
                child: LocalImage(path: trip.coverPhotoPath),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            trip.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              height: 1.15,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            trip.destination,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            '${DateFormatters.tripRange(trip.startDate, trip.endDate)} · ${trip.memoryCount} ${trip.memoryCount == 1 ? 'memory' : 'memories'}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
