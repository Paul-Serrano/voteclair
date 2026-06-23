import 'package:voteclair_mobile/features/deputies/domain/entities/deputy.dart';
import 'package:voteclair_mobile/features/deputies/domain/entities/paginated_deputies.dart';
import 'package:voteclair_mobile/features/deputies/domain/entities/deputy_vote.dart';
import 'package:voteclair_mobile/features/deputies/domain/entities/paginated_votes.dart';
import 'package:voteclair_mobile/features/deputies/domain/repositories/deputy_repository.dart';

class FakeDeputyRepository implements DeputyRepository {
  FakeDeputyRepository({
    this.deputies = const <Deputy>[],
    this.deputiesByPageAndGroup = const <String, Map<int, PaginatedDeputies>>{},
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
  final Map<String, Map<int, PaginatedDeputies>> deputiesByPageAndGroup;
  final Map<String, Deputy> deputyBySlug;
  final Map<String, Map<int, PaginatedVotes>> votesBySlugAndPage;
  final Duration? fetchDeputiesDelay;
  final Duration? getBySlugDelay;
  final Duration? getVotesDelay;
  final bool throwOnFetchDeputies;
  final bool throwOnGetBySlug;
  final bool throwOnGetVotes;

  @override
  Future<PaginatedDeputies> fetchDeputies(
    int page, {
    String group = '',
    String search = '',
  }) async {
    if (fetchDeputiesDelay != null) {
      await Future<void>.delayed(fetchDeputiesDelay!);
    }
    if (throwOnFetchDeputies) {
      throw Exception('fetch_deputies_error');
    }

    final key = group.trim();
    final groupedPages = deputiesByPageAndGroup[key] ?? const <int, PaginatedDeputies>{};
    final groupedResult = groupedPages[page];
    if (groupedResult != null) {
      return groupedResult;
    }

    if (page == 1) {
      var filtered = key.isEmpty
          ? deputies
          : deputies.where((item) => item.groupSlug == key).toList(growable: false);

      final needle = search.trim().toLowerCase();
      if (needle.isNotEmpty) {
        filtered = filtered
            .where((item) => item.nom.toLowerCase().contains(needle) || item.prenom.toLowerCase().contains(needle))
            .toList(growable: false);
      }

      return PaginatedDeputies(deputies: filtered, currentPage: 1, lastPage: 1);
    }

    return const PaginatedDeputies(deputies: <Deputy>[], currentPage: 1, lastPage: 1);
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
