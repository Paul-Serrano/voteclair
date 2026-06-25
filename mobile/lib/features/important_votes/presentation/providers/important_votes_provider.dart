import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../data/repositories/important_votes_repository_impl.dart';
import '../../domain/entities/important_vote_item.dart';
import '../../domain/repositories/important_votes_repository.dart';

final importantVotesRepositoryProvider = Provider<ImportantVotesRepository>((ref) {
  return ImportantVotesRepositoryImpl(ref.watch(apiClientProvider));
});

final importantVotesProvider = FutureProvider<List<ImportantVoteItem>>((ref) async {
  final repository = ref.watch(importantVotesRepositoryProvider);
  return repository.getImportantVotes(limit: 20);
});

final importantVotesPreviewProvider = FutureProvider<List<ImportantVoteItem>>((ref) async {
  final all = await ref.watch(importantVotesProvider.future);
  final sorted = [...all]..sort((a, b) => b.numero.compareTo(a.numero));
  return sorted.take(5).toList(growable: false);
});
