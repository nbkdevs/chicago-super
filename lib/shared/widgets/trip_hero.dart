import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utilities/date_formatters.dart';
import '../../data/models/trip.dart';
import 'local_image.dart';

class TripHero extends StatelessWidget {
  const TripHero({super.key, required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final place = trip.destination.split('·').first.trim().toUpperCase();
    final days = DateFormatters.dayCount(trip.startDate, trip.endDate);

    return Column(
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.46,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'trip-cover-${trip.id}',
                child: LocalImage(path: trip.coverPhotoPath),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x3325231F),
                      Color(0x9925231F),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 28,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.cream.withValues(alpha: 0.85),
                            letterSpacing: 2.2,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      trip.title,
                      style: GoogleFonts.playfairDisplay(
                        color: AppColors.cream,
                        fontSize: 40,
                        height: 1.05,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      DateFormatters.tripRange(trip.startDate, trip.endDate),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.cream.withValues(alpha: 0.9),
                          ),
                    ),
                    if (trip.description.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        trip.description,
                        style: GoogleFonts.caveat(
                          color: AppColors.cream.withValues(alpha: 0.95),
                          fontSize: 22,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          color: AppColors.cream.withValues(alpha: 0.7),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              _Stat(value: '${trip.memoryCount}', label: trip.memoryCount == 1 ? 'memory' : 'memories'),
              const SizedBox(width: 28),
              _Stat(value: '${trip.placeCount}', label: trip.placeCount == 1 ? 'place' : 'places'),
              const SizedBox(width: 28),
              _Stat(value: '$days', label: days == 1 ? 'day' : 'days'),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          value,
          style: GoogleFonts.playfairDisplay(
            fontSize: 26,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
