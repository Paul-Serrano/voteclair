import '../../domain/entities/search_results.dart';

class SearchResultsDto {
  const SearchResultsDto({
    required this.deputies,
    required this.groups,
    required this.scrutins,
  });

  final List<SearchDeputyResultDto> deputies;
  final List<SearchGroupResultDto> groups;
  final List<SearchScrutinResultDto> scrutins;

  factory SearchResultsDto.fromJson(Map<String, dynamic> json) {
    return SearchResultsDto(
      deputies: (json['deputies'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(SearchDeputyResultDto.fromJson)
          .toList(growable: false),
      groups: (json['groups'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(SearchGroupResultDto.fromJson)
          .toList(growable: false),
      scrutins: (json['scrutins'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(SearchScrutinResultDto.fromJson)
          .toList(growable: false),
    );
  }

  SearchResults toDomain() {
    return SearchResults(
      deputies: deputies.map((item) => item.toDomain()).toList(growable: false),
      groups: groups.map((item) => item.toDomain()).toList(growable: false),
      scrutins: scrutins.map((item) => item.toDomain()).toList(growable: false),
    );
  }
}

class SearchDeputyResultDto {
  const SearchDeputyResultDto({
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

  factory SearchDeputyResultDto.fromJson(Map<String, dynamic> json) {
    return SearchDeputyResultDto(
      slug: (json['slug'] as String?) ?? '',
      prenom: (json['prenom'] as String?) ?? '',
      nom: (json['nom'] as String?) ?? '',
      photoUrl: json['photo_url'] as String?,
      group: json['group'] as String?,
    );
  }

  SearchDeputyResult toDomain() {
    return SearchDeputyResult(
      slug: slug,
      prenom: prenom,
      nom: nom,
      photoUrl: photoUrl,
      group: group,
    );
  }
}

class SearchGroupResultDto {
  const SearchGroupResultDto({
    required this.slug,
    required this.nom,
    required this.membersCount,
    this.couleur,
  });

  final String slug;
  final String nom;
  final String? couleur;
  final int membersCount;

  factory SearchGroupResultDto.fromJson(Map<String, dynamic> json) {
    return SearchGroupResultDto(
      slug: (json['slug'] as String?) ?? '',
      nom: (json['nom'] as String?) ?? '',
      couleur: json['couleur'] as String?,
      membersCount: _asInt(json['members_count']) ?? 0,
    );
  }

  SearchGroupResult toDomain() {
    return SearchGroupResult(
      slug: slug,
      nom: nom,
      couleur: couleur,
      membersCount: membersCount,
    );
  }
}

class SearchScrutinResultDto {
  const SearchScrutinResultDto({
    required this.id,
    required this.titre,
    this.date,
    this.sort,
  });

  final String id;
  final String titre;
  final String? date;
  final String? sort;

  factory SearchScrutinResultDto.fromJson(Map<String, dynamic> json) {
    return SearchScrutinResultDto(
      id: (json['id'] as String?) ?? '',
      titre: (json['titre'] as String?) ?? '',
      date: json['date'] as String?,
      sort: json['sort'] as String?,
    );
  }

  SearchScrutinResult toDomain() {
    return SearchScrutinResult(
      id: id,
      titre: titre,
      date: date,
      sort: sort,
    );
  }
}

int? _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}
