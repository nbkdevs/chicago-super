import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/repositories/travel_app_state.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/photo_picker_field.dart';

class CreateTripPage extends StatefulWidget {
  const CreateTripPage({super.key});

  @override
  State<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  final _title = TextEditingController();
  final _destination = TextEditingController();
  final _description = TextEditingController();
  DateTime? _start;
  DateTime? _end;
  List<PhotoDraft> _photos = [];
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _destination.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool start}) async {
    final now = DateTime.now();
    final initial = start ? (_start ?? now) : (_end ?? _start ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.terracotta,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() {
      if (start) {
        _start = picked;
        if (_end != null && _end!.isBefore(picked)) _end = picked;
      } else {
        _end = picked;
      }
    });
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    final destination = _destination.text.trim();
    if (title.isEmpty || destination.isEmpty || _start == null || _end == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a name, destination, and dates.')),
      );
      return;
    }
    if (_end!.isBefore(_start!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after the start date.')),
      );
      return;
    }

    setState(() => _saving = true);
    final state = context.read<TravelAppState>();
    try {
      String? cover;
      if (_photos.isNotEmpty) {
        cover = await state.repository.photoStorage.saveFromFile(
          File(_photos.first.path),
        );
      }
      final trip = await state.createTrip(
            title: title,
            destination: destination,
            startDate: _start!,
            endDate: _end!,
            coverPhotoPath: cover,
            description: _description.text.trim(),
          );
      if (!mounted) return;
      context.go('/trips/${trip.id}');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't create this trip. Please try again.")),
      );
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a trip'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Text(
            'Just the essentials — a name, a place, a cover photo.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _title,
            decoration: const InputDecoration(
              labelText: 'Trip name',
              hintText: 'Japan 2026',
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _destination,
            decoration: const InputDecoration(
              labelText: 'Destination',
              hintText: 'Japan',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickDate(start: true),
                  child: Text(
                    _start == null
                        ? 'Start date'
                        : '${_start!.year}-${_start!.month.toString().padLeft(2, '0')}-${_start!.day.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickDate(start: false),
                  child: Text(
                    _end == null
                        ? 'End date'
                        : '${_end!.year}-${_end!.month.toString().padLeft(2, '0')}-${_end!.day.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _description,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'A short note (optional)',
              hintText: 'A few unforgettable weeks…',
            ),
          ),
          const SizedBox(height: 20),
          PhotoPickerField(
            photos: _photos,
            multiple: false,
            label: 'Add a cover photo',
            onChanged: (photos) => setState(() => _photos = photos),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: _saving ? 'Creating…' : 'Create trip',
            expanded: true,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}
