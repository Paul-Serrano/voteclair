import '../../domain/entities/group_member.dart';

class GroupMemberDto {
  const GroupMemberDto({
    required this.slug,
    required this.nom,
    required this.prenom,
    this.photoUrl,
    this.statsPresence,
  });

  final String slug;
  final String nom;
  final String prenom;
  final String? photoUrl;
  final int? statsPresence;

  factory GroupMemberDto.fromJson(Map<String, dynamic> json) {
    return GroupMemberDto(
      slug: (json['slug'] as String?) ?? '',
      nom: (json['nom'] as String?) ?? '',
      prenom: (json['prenom'] as String?) ?? '',
      photoUrl: json['photo_url'] as String?,
      statsPresence: _asInt(json['stats_presence']),
    );
  }

  GroupMember toDomain() {
    return GroupMember(
      slug: slug,
      nom: nom,
      prenom: prenom,
      photoUrl: photoUrl,
      statsPresence: statsPresence,
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
