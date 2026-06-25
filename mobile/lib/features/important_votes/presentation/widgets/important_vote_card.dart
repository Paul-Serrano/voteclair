import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/important_vote_item.dart';

class ImportantVoteCard extends StatelessWidget {
  const ImportantVoteCard({
    required this.item,
    this.onTap,
    this.compact = false,
    super.key,
  });

  final ImportantVoteItem item;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scoreLabel = _scoreLabel(item.importanceScore);
    final sortLabel = _sortLabel(item.sort);
    final date = item.dateScrutin;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.titre,
                      maxLines: compact ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  if (onTap != null) const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    visualDensity: const VisualDensity(horizontal: -2, vertical: -3),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: const Color(0xFFFFE9C2),
                    side: const BorderSide(color: Color(0xFFB26A00)),
                    label: Text(
                      scoreLabel,
                      style: const TextStyle(
                        color: Color(0xFF7A4300),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Chip(
                    visualDensity: const VisualDensity(horizontal: -2, vertical: -3),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    label: Text(sortLabel),
                  ),
                  if (date != null)
                    Text(
                      DateFormat('d MMM yyyy', 'fr_FR').format(date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Score: ${item.importanceScore}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _scoreLabel(int score) {
    if (score >= 150) {
      return 'Très important';
    }
    if (score >= 100) {
      return 'Important';
    }

    return 'À surveiller';
  }

  String _sortLabel(String? sort) {
    return switch ((sort ?? '').toUpperCase()) {
      'ADOPTE' => 'Adopté',
      'REJETE' => 'Rejeté',
      _ => '-',
    };
  }
}
