import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/deputy.dart';
import '../providers/deputy_details_provider.dart';

class DeputyDetailsPage extends ConsumerWidget {
  const DeputyDetailsPage({required this.slug, super.key});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deputyAsync = ref.watch(deputyDetailsProvider(slug));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiche depute'),
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.go('/deputies');
          },
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Retour',
        ),
      ),
      body: deputyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 40),
                const SizedBox(height: 12),
                const Text(
                  'Impossible de charger ce depute.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.invalidate(deputyDetailsProvider(slug)),
                  child: const Text('Reessayer'),
                ),
              ],
            ),
          ),
        ),
        data: (deputy) => _DetailsContent(deputy: deputy),
      ),
    );
  }
}

class _DetailsContent extends StatelessWidget {
  const _DetailsContent({required this.deputy});

  final Deputy deputy;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _HeaderCard(deputy: deputy),
        const SizedBox(height: 16),
        _GeneralInfoCard(deputy: deputy),
        const SizedBox(height: 16),
        if (_twitterHandle(deputy.twitter) != null)
          FilledButton.icon(
            onPressed: () => _openXProfile(context, _twitterHandle(deputy.twitter)!),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Voir sur X'),
          ),
        if (_twitterHandle(deputy.twitter) != null) const SizedBox(height: 16),
        _TextSection(title: 'Qui est ce depute ?', content: deputy.resumeIa),
        const SizedBox(height: 12),
        _TextSection(title: 'Parcours', content: deputy.parcoursIa),
        const SizedBox(height: 12),
        _TextSection(title: 'Positions cles', content: deputy.positionsClesIa),
        const SizedBox(height: 12),
        _TextSection(title: 'Faits notables', content: deputy.faitsNotablesIa),
        const SizedBox(height: 16),
        _StatsSection(deputy: deputy),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => context.push('/deputies/${deputy.slug}/votes'),
          child: const Text('Voir les votes'),
        ),
      ],
    );
  }

  String? _twitterHandle(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    var value = raw.trim();
    value = value.replaceFirst(RegExp(r'^https?://(www\.)?x\.com/'), '');
    value = value.replaceFirst(RegExp(r'^https?://(www\.)?twitter\.com/'), '');
    value = value.replaceFirst('@', '');

    return value.isEmpty ? null : value;
  }

  Future<void> _openXProfile(BuildContext context, String handle) async {
    final uri = Uri.parse('https://x.com/$handle');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir le lien X.')),
      );
    }
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.deputy});

  final Deputy deputy;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              foregroundImage: _networkImageOrNull(deputy.photoUrl),
              child: const Icon(Icons.person_outline, size: 36),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deputy.prenom,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    deputy.nom,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (_toColor(deputy.groupColor) != null)
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _toColor(deputy.groupColor),
                          ),
                        ),
                      if (_toColor(deputy.groupColor) != null) const SizedBox(width: 8),
                      Expanded(
                        child: Text(deputy.groupName ?? 'Groupe inconnu'),
                      ),
                    ],
                  ),
                ],
              ),
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

  Color? _toColor(String? hex) {
    if (hex == null || hex.trim().isEmpty) {
      return null;
    }

    final normalized = hex.replaceFirst('#', '').trim();
    if (normalized.length != 6) {
      return null;
    }

    final value = int.tryParse('FF$normalized', radix: 16);
    if (value == null) {
      return null;
    }

    return Color(value);
  }
}

class _GeneralInfoCard extends StatelessWidget {
  const _GeneralInfoCard({required this.deputy});

  final Deputy deputy;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Informations generales', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _InfoRow(label: 'Profession', value: deputy.profession),
            _InfoRow(label: 'Circonscription', value: deputy.circonscriptionName),
            _InfoRow(
              label: 'Departement',
              value: _formatDepartement(deputy.departement, deputy.departementName),
            ),
          ],
        ),
      ),
    );
  }

  String? _formatDepartement(String? code, String? name) {
    if ((code == null || code.isEmpty) && (name == null || name.isEmpty)) {
      return null;
    }

    if (code != null && code.isNotEmpty && name != null && name.isNotEmpty) {
      return '$code - $name';
    }

    return (code == null || code.isEmpty) ? name : code;
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value == null || value!.isEmpty ? '-' : value!)),
        ],
      ),
    );
  }
}

class _TextSection extends StatelessWidget {
  const _TextSection({required this.title, required this.content});

  final String title;
  final String? content;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(content == null || content!.isEmpty ? 'Information non disponible.' : content!),
          ],
        ),
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.deputy});

  final Deputy deputy;

  @override
  Widget build(BuildContext context) {
    final stats = <_StatItem>[
      _StatItem('Presence', deputy.statsPresence),
      _StatItem('Presence solennels', deputy.statsPresenceSolennel),
      _StatItem('Loyaute', deputy.statsLoyaute),
      _StatItem('Participation', deputy.statsParticipation),
      _StatItem('Interventions', deputy.statsInterventions),
      _StatItem('Amendements', deputy.statsAmendements),
      _StatItem('Amendements adoptes', deputy.statsAmendementsAdoptes),
      _StatItem('Questions', deputy.statsQuestions),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Statistiques', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.2,
          ),
          itemBuilder: (context, index) {
            final stat = stats[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat.label,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stat.value?.toString() ?? '-',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _StatItem {
  const _StatItem(this.label, this.value);

  final String label;
  final int? value;
}
