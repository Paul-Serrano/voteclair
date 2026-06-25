import 'package:voteclair_mobile/features/scrutins/domain/entities/paginated_votes.dart';
import 'package:voteclair_mobile/features/scrutins/domain/entities/paginated_scrutins.dart';
import 'package:voteclair_mobile/features/scrutins/domain/entities/scrutin.dart';
import 'package:voteclair_mobile/features/scrutins/domain/entities/scrutin_vote.dart';
import 'package:voteclair_mobile/features/scrutins/domain/repositories/scrutin_repository.dart';

class FakeScrutinRepository implements ScrutinRepository {
  FakeScrutinRepository({
    this.scrutinsByPage = const <int, PaginatedScrutins>{},
    this.scrutinById = const <String, Scrutin>{},
    this.votesByScrutinAndPage = const <String, Map<int, PaginatedVotes>>{},
    this.getByIdDelay,
    this.getVotesDelay,
    this.getScrutinsDelay,
    this.throwOnFetchScrutins = false,
    this.throwOnGetById = false,
    this.throwOnGetVotes = false,
  });

  final Map<int, PaginatedScrutins> scrutinsByPage;
  final Map<String, Scrutin> scrutinById;
  final Map<String, Map<int, PaginatedVotes>> votesByScrutinAndPage;
  final Duration? getByIdDelay;
  final Duration? getVotesDelay;
  final Duration? getScrutinsDelay;
  final bool throwOnFetchScrutins;
  final bool throwOnGetById;
  final bool throwOnGetVotes;

  @override
  Future<PaginatedScrutins> fetchScrutins(
    int page, {
    String search = '',
    String importanceFilter = 'all',
    String sortMode = 'numero_desc',
  }) async {
    if (getScrutinsDelay != null) {
      await Future<void>.delayed(getScrutinsDelay!);
    }
    if (throwOnFetchScrutins) {
      throw Exception('fetch_scrutins_error');
    }

    final pageData = scrutinsByPage[page] ??
        PaginatedScrutins(scrutins: <Scrutin>[_fallbackScrutin('scrutin-$page')], currentPage: 1, lastPage: 1);

    final normalized = search.trim().toLowerCase();
    if (normalized.isEmpty) {
      return pageData;
    }

    final filtered = pageData.scrutins.where((scrutin) {
      return scrutin.titre.toLowerCase().contains(normalized) ||
          (scrutin.institution?.nom.toLowerCase().contains(normalized) ?? false);
    }).toList(growable: false);

    return PaginatedScrutins(
      scrutins: filtered,
      currentPage: pageData.currentPage,
      lastPage: filtered.isEmpty ? 1 : pageData.lastPage,
    );
  }

  @override
  Future<Scrutin> getById(String id) async {
    if (getByIdDelay != null) {
      await Future<void>.delayed(getByIdDelay!);
    }
    if (throwOnGetById) {
      throw Exception('get_by_id_error');
    }

    return scrutinById[id] ?? _fallbackScrutin(id);
  }

  @override
  Future<PaginatedVotes> getVotes(String scrutinId, int page) async {
    if (getVotesDelay != null) {
      await Future<void>.delayed(getVotesDelay!);
    }
    if (throwOnGetVotes) {
      throw Exception('get_votes_error');
    }

    final pages = votesByScrutinAndPage[scrutinId] ?? const <int, PaginatedVotes>{};
    return pages[page] ??
      const PaginatedVotes(votes: <ScrutinVote>[], currentPage: 1, lastPage: 1);
  }

  Scrutin _fallbackScrutin(String id) {
    return Scrutin(
      id: id,
      numero: 1,
      date: '2026-06-10',
      titre: 'Scrutin inconnu',
      sort: 'REJETE',
      importanceScore: 0,
      institution: const ScrutinInstitution(
        id: 'inst',
        slug: 'assemblee-nationale',
        nom: 'Assemblée nationale',
        pays: 'France',
      ),
      resultats: const ScrutinResultats(
        pour: 0,
        contre: 0,
        abstention: 0,
        nonVotant: 0,
        total: 0,
      ),
    );
  }
}
