import 'package:voteclair_mobile/features/deputies/domain/entities/deputy.dart';
import 'package:voteclair_mobile/features/deputies/domain/entities/deputy_vote.dart';
import 'package:voteclair_mobile/features/deputies/domain/entities/paginated_votes.dart';
import 'package:voteclair_mobile/features/deputies/domain/repositories/deputy_repository.dart';

class FakeDeputyRepository implements DeputyRepository {
  FakeDeputyRepository({
    this.deputies = const <Deputy>[],
    this.deputyBySlug = const <String, Deputy>{},
    this.votesBySlugAndPage = const <String, Map<int, PaginatedVotes>>{},
    this.fetchDeputiesDelay,
    this.getBySlugDelay,
    this.getVotesDelay,
    this.throwOnFetchDeputies = false,
    this.throwOnGetBySlug = false,
    this.throwOnGetVotes = false,
  });

  final List<Deputy> deputies;
  final Map<String, Deputy> deputyBySlug;
  final Map<String, Map<int, PaginatedVotes>> votesBySlugAndPage;
  final Duration? fetchDeputiesDelay;
  final Duration? getBySlugDelay;
  final Duration? getVotesDelay;
  final bool throwOnFetchDeputies;
  final bool throwOnGetBySlug;
  final bool throwOnGetVotes;

  @override
  Future<List<Deputy>> fetchDeputies() async {
    if (fetchDeputiesDelay != null) {
      await Future<void>.delayed(fetchDeputiesDelay!);
    }
    if (throwOnFetchDeputies) {
      throw Exception('fetch_deputies_error');
    }
    return deputies;
  }

  @override
  Future<Deputy> getBySlug(String slug) async {
    if (getBySlugDelay != null) {
      await Future<void>.delayed(getBySlugDelay!);
    }
    if (throwOnGetBySlug) {
      throw Exception('get_by_slug_error');
    }
    return deputyBySlug[slug] ??
        (deputies.isNotEmpty ? deputies.first : _fallbackDeputy(slug));
  }

  @override
  Future<PaginatedVotes> getVotes(String slug, int page) async {
    if (getVotesDelay != null) {
      await Future<void>.delayed(getVotesDelay!);
    }
    if (throwOnGetVotes) {
      throw Exception('get_votes_error');
    }

    final pages = votesBySlugAndPage[slug] ?? const <int, PaginatedVotes>{};
    return pages[page] ??
        const PaginatedVotes(
          votes: <DeputyVote>[],
          currentPage: 1,
          lastPage: 1,
        );
  }

  Deputy _fallbackDeputy(String slug) {
    return Deputy(
      slug: slug,
      nom: 'Inconnu',
      prenom: 'Depute',
      photoUrl: null,
      groupName: 'Groupe inconnu',
    );
  }
}
