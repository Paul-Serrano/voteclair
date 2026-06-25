class SearchResults {
  const SearchResults({
    this.deputies = const <SearchDeputyResult>[],
    this.groups = const <SearchGroupResult>[],
    this.scrutins = const <SearchScrutinResult>[],
  });

  final List<SearchDeputyResult> deputies;
  final List<SearchGroupResult> groups;
  final List<SearchScrutinResult> scrutins;

  bool get isEmpty => deputies.isEmpty && groups.isEmpty && scrutins.isEmpty;
}

class SearchDeputyResult {
  const SearchDeputyResult({
    required this.slug,
    required this.prenom,
    required this.nom,
    this.photoUrl,
    this.group,
  });

  final String slug;
  final String prenom;
  final String nom;
  final String? photoUrl;
  final String? group;

  String get fullName => '$prenom $nom'.trim();
}

class SearchGroupResult {
  const SearchGroupResult({
    required this.slug,
    required this.nom,
    required this.membersCount,
    this.couleur,
  });

  final String slug;
  final String nom;
  final String? couleur;
  final int membersCount;
}

class SearchScrutinResult {
  const SearchScrutinResult({
    required this.id,
    required this.numero,
    required this.titre,
    required this.importanceScore,
    this.date,
    this.sort,
  });

  final String id;
  final int numero;
  final String titre;
  final int importanceScore;
  final String? date;
  final String? sort;
}
