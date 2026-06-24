import '../../domain/entities/activity_item.dart';

class ActivityItemDto {
  const ActivityItemDto({
    required this.deputy,
    required this.latestVote,
  });

  final ActivityDeputyDto deputy;
  final ActivityVoteDto latestVote;

  factory ActivityItemDto.fromJson(Map<String, dynamic> json) {
    final deputyJson = json['deputy'];
    final voteJson = json['latest_vote'];

    if (deputyJson is! Map<String, dynamic> || voteJson is! Map<String, dynamic>) {
      throw Exception('Invalid favorites activity item payload');
    }

    return ActivityItemDto(
      deputy: ActivityDeputyDto.fromJson(deputyJson),
      latestVote: ActivityVoteDto.fromJson(voteJson),
    );
  }

  ActivityItem toDomain() {
    return ActivityItem(
      deputy: deputy.toDomain(),
      latestVote: latestVote.toDomain(),
    );
  }
}

class ActivityDeputyDto {
  const ActivityDeputyDto({
    required this.slug,
    required this.nom,
    required this.prenom,
    required this.photoUrl,
  });

  final String slug;
  final String nom;
  final String prenom;
  final String? photoUrl;

  factory ActivityDeputyDto.fromJson(Map<String, dynamic> json) {
    return ActivityDeputyDto(
      slug: (json['slug'] as String?) ?? '',
      nom: (json['nom'] as String?) ?? '',
      prenom: (json['prenom'] as String?) ?? '',
      photoUrl: json['photo_url'] as String?,
    );
  }

  ActivityDeputy toDomain() {
    return ActivityDeputy(
      slug: slug,
      nom: nom,
      prenom: prenom,
      photoUrl: photoUrl,
    );
  }
}

class ActivityVoteDto {
  const ActivityVoteDto({
    required this.id,
    required this.position,
    required this.scrutin,
  });

  final String id;
  final String position;
  final ActivityScrutinDto scrutin;

  factory ActivityVoteDto.fromJson(Map<String, dynamic> json) {
    final scrutinJson = json['scrutin'];
    if (scrutinJson is! Map<String, dynamic>) {
      throw Exception('Invalid favorites activity scrutin payload');
    }

    return ActivityVoteDto(
      id: (json['id'] as Object?)?.toString() ?? '',
      position: ((json['position'] as String?) ?? 'NON_VOTANT').toUpperCase(),
      scrutin: ActivityScrutinDto.fromJson(scrutinJson),
    );
  }

  ActivityVote toDomain() {
    return ActivityVote(
      id: id,
      position: position,
      scrutin: scrutin.toDomain(),
    );
  }
}

class ActivityScrutinDto {
  const ActivityScrutinDto({
    required this.id,
    required this.titre,
    required this.date,
  });

  final String id;
  final String titre;
  final DateTime? date;

  factory ActivityScrutinDto.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date'] as String?;

    return ActivityScrutinDto(
      id: (json['id'] as String?) ?? '',
      titre: (json['titre'] as String?) ?? '',
      date: rawDate == null ? null : DateTime.tryParse(rawDate),
    );
  }

  ActivityScrutin toDomain() {
    return ActivityScrutin(
      id: id,
      titre: titre,
      date: date,
    );
  }
}
