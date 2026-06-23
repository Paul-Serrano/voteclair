import 'package:flutter/material.dart';

import '../../domain/entities/group.dart';

class GroupStatsCard extends StatelessWidget {
  const GroupStatsCard({required this.group, super.key});

  final Group group;

  @override
  Widget build(BuildContext context) {
    final stats = group.stats;
    final totalVotes = stats.totalVotes;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiques du groupe',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _StatsGrid(group: group),
            const SizedBox(height: 16),
            Text(
              'Repartition des votes',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            _VoteProgressRow(
              label: 'POUR',
              value: stats.votesPour,
              total: totalVotes,
              color: Colors.green,
            ),
            _VoteProgressRow(
              label: 'CONTRE',
              value: stats.votesContre,
              total: totalVotes,
              color: Colors.red,
            ),
            _VoteProgressRow(
              label: 'ABSTENTION',
              value: stats.votesAbstention,
              total: totalVotes,
              color: Colors.orange,
            ),
            _VoteProgressRow(
              label: 'ABSENT',
              value: stats.votesAbsent,
              total: totalVotes,
              color: Colors.blueGrey,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    final stats = group.stats;
    final items = <_StatItem>[
      _StatItem('Membres', group.membresCount),
      _StatItem('Presence', stats.presence),
      _StatItem('Presence solennelle', stats.presenceSolennelle),
      _StatItem('Loyaute', stats.loyaute),
      _StatItem('Cohesion', stats.cohesion),
      _StatItem('Participation', stats.participation),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  item.value.toString(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VoteProgressRow extends StatelessWidget {
  const _VoteProgressRow({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  final String label;
  final int value;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = total <= 0 ? 0.0 : (value / total).clamp(0, 1).toDouble();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              Text('$value'),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress,
            color: color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  const _StatItem(this.label, this.value);

  final String label;
  final int value;
}
