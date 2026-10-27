import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../data/models/memory_entry.dart';
import 'memory_card.dart';

class MasonryMemoryGrid extends StatelessWidget {
  const MasonryMemoryGrid({
    super.key,
    required this.memories,
    required this.onTap,
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 100),
  });

  final List<MemoryEntry> memories;
  final void Function(MemoryEntry memory) onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      padding: padding,
      crossAxisCount: 2,
      mainAxisSpacing: 18,
      crossAxisSpacing: 12,
      itemCount: memories.length,
      itemBuilder: (context, index) {
        final memory = memories[index];
        return MemoryCard(
          memory: memory,
          onTap: () => onTap(memory),
        );
      },
    );
  }
}
