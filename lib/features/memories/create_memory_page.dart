import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/trip.dart';
import '../../data/repositories/travel_app_state.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/photo_picker_field.dart';

class CreateMemoryPage extends StatefulWidget {
  const CreateMemoryPage({super.key, this.tripId});

  final String? tripId;

  @override
  State<CreateMemoryPage> createState() => _CreateMemoryPageState();
}

class _CreateMemoryPageState extends State<CreateMemoryPage> {
  final _title = TextEditingController();
  final _content = TextEditingController();
  final _location = TextEditingController();
  final _tagInput = TextEditingController();
  late String? _tripId = widget.tripId;
  DateTime _date = DateTime.now();
  List<PhotoDraft> _photos = [];
  List<String> _tags = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _tripId = widget.tripId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final trips = context.read<TravelAppState>().trips;
    if (_tripId == null && trips.isNotEmpty) {
      _tripId = trips.first.id;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    _location.dispose();
    _tagInput.dispose();
    super.dispose();
  }

  void _addTags() {
    final parts = _tagInput.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty);
    setState(() {
      _tags = {..._tags, ...parts}.toList();
      _tagInput.clear();
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final trips = context.read<TravelAppState>().trips;
    final tripId = _tripId ?? (trips.isNotEmpty ? trips.first.id : null);
    if (tripId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a trip before adding a memory.')),
      );
      return;
    }
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Give this memory a title.')),
      );
      return;
    }
    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one photo — memories start with pictures.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final memory = await context.read<TravelAppState>().createMemory(
            tripId: tripId,
            title: _title.text.trim(),
            content: _content.text.trim(),
            location: _location.text.trim(),
            date: _date,
            tags: _tags,
            photos: _photos.map((p) => p.toPending()).toList(),
          );
      if (!mounted) return;
      context.go('/memories/${memory.id}');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't save this memory. Please try again.")),
      );
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trips = context.watch<TravelAppState>().trips;

    return Scaffold(
      appBar: AppBar(title: const Text('Add a memory')),
      body: trips.isEmpty
          ? EmptyState(
              title: 'Start with a trip',
              description: 'Create a trip first, then fill it with memories.',
              actionLabel: 'Create a trip',
              onAction: () => context.push('/trips/new'),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                Text(
                  'Photos first. A few words. The rest is atmosphere.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.muted,
                      ),
                ),
                const SizedBox(height: 20),
                PhotoPickerField(
                  photos: _photos,
                  onChanged: (photos) => setState(() => _photos = photos),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _title,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Shibuya After Dark',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _content,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Tell the story…',
                    hintText: 'The streets were packed, neon everywhere…',
                    alignLabelWithHint: true,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _tripId,
                  decoration: const InputDecoration(labelText: 'Which trip?'),
                  items: trips
                      .map(
                        (Trip t) => DropdownMenuItem(
                          value: t.id,
                          child: Text(t.title),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _tripId = v),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _location,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'Tokyo, Japan',
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined, size: 18),
                  label: Text(
                    '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _tagInput,
                        decoration: const InputDecoration(
                          labelText: 'Tags',
                          hintText: 'Tokyo, Food, Night',
                        ),
                        onSubmitted: (_) => _addTags(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: _addTags,
                      child: const Text('Add'),
                    ),
                  ],
                ),
                if (_tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tags
                        .map(
                          (t) => TagChip(
                            t,
                            onDeleted: () => setState(() => _tags.remove(t)),
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 28),
                PrimaryButton(
                  label: _saving ? 'Saving…' : 'Save memory',
                  expanded: true,
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
    );
  }
}
