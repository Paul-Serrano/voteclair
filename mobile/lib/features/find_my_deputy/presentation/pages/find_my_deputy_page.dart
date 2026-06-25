import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../domain/entities/find_my_deputy_result.dart';
import '../providers/find_my_deputy_provider.dart';
import '../widgets/deputy_result_card.dart';
import '../widgets/postal_code_search_card.dart';

class FindMyDeputyPage extends ConsumerWidget {
  const FindMyDeputyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(findMyDeputyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Trouver mon député')),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PostalCodeSearchCard(
            initialPostalCode: state.postalCode,
            initialInstitutionId: state.institutionId,
            isLoading: state.isLoading,
            onPostalCodeChanged: (value) => ref.read(findMyDeputyProvider.notifier).setPostalCode(value),
            onInstitutionIdChanged: (value) => ref.read(findMyDeputyProvider.notifier).setInstitutionId(value),
            onFind: () => ref.read(findMyDeputyProvider.notifier).find(),
          ),
          const SizedBox(height: 16),
          if (state.errorMessage == 'postal_code_invalid')
            const _MessageCard(text: 'Entrez un code postal à 5 chiffres.')
          else if (state.errorMessage != null)
            _MessageCard(text: _errorText(state.errorMessage!))
          else if (state.isIdle)
            const _MessageCard(text: 'Entrez votre code postal.')
          else if (state.result == null && !state.isLoading)
            const _MessageCard(text: 'Aucun représentant trouvé.')
          else if (state.result != null) ...[
            _ContextCard(result: state.result!),
            const SizedBox(height: 16),
            ...state.result!.deputies.map((deputy) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DeputyResultCard(deputy: deputy),
                )),
          ],
        ],
      ),
    );
  }

  String _errorText(String error) {
    if (error.contains('404')) {
      return 'Aucun représentant trouvé.';
    }
    return 'Une erreur est survenue.';
  }
}

class _ContextCard extends StatelessWidget {
  const _ContextCard({required this.result});

  final FindMyDeputyResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Résultat', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Code postal: ${result.postalCode}'),
            Text('Institution: ${result.institution?.nom ?? '-'}'),
            Text('Circonscription: ${result.circonscription?.nom ?? '-'}'),
          ],
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(text),
      ),
    );
  }
}