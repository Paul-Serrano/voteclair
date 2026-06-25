import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/find_my_deputy_result.dart';

class DeputyResultCard extends StatelessWidget {
  const DeputyResultCard({required this.deputy, super.key});

  final FindMyDeputyDeputy deputy;

  @override
  Widget build(BuildContext context) {
    final group = deputy.group;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  foregroundImage: _networkImageOrNull(deputy.photoUrl),
                  child: const Icon(Icons.person_outline),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(deputy.fullName, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(deputy.profession ?? 'Profession indisponible'),
                      if (group != null) ...[
                        const SizedBox(height: 4),
                        Text(group.nom),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatChip(label: 'Présence', value: _percent(deputy.statsPresence)),
                _StatChip(label: 'Loyauté', value: _percent(deputy.statsLoyaute)),
                _StatChip(label: 'Participation', value: _count(deputy.statsParticipation)),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () => context.push('/deputies/${deputy.slug}'),
              child: const Text('Voir la fiche député'),
            ),
            const SizedBox(height: 16),
            Text('5 derniers votes', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (deputy.latestVotes.isEmpty)
              const Text('Aucun vote disponible.')
            else
              Column(
                children: deputy.latestVotes
                    .take(5)
                    .map(
                      (vote) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          onTap: () => context.push('/scrutins/${vote.scrutin.id}'),
                          leading: _PositionDot(position: vote.position),
                          title: Text(vote.scrutin.titre),
                          subtitle: Text('Scrutin ${vote.scrutin.numero ?? '-'} • ${_sortLabel(vote.scrutin.sort)}'),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
          ],
        ),
      ),
    );
  }

  ImageProvider<Object>? _networkImageOrNull(String? url) {
    if (url == null || url.trim().isEmpty) {
      return null;
    }

    return NetworkImage(url);
  }

  String _percent(int? value) => value == null ? '-' : '$value%';

  String _count(int? value) => value == null ? '-' : value.toString();

  String _sortLabel(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'ADOPTE':
        return 'Adopté';
      case 'REJETE':
        return 'Rejeté';
      default:
        return '-';
    }
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}

class _PositionDot extends StatelessWidget {
  const _PositionDot({required this.position});

  final String position;

  @override
  Widget build(BuildContext context) {
    final color = switch (position.toUpperCase()) {
      'POUR' => Colors.green,
      'CONTRE' => Colors.red,
      'ABSTENTION' => Colors.orange,
      _ => Theme.of(context).colorScheme.outline,
    };

    return CircleAvatar(radius: 10, backgroundColor: color);
  }
}