import '../../domain/entities/deputy.dart';

class DeputyDto {
  const DeputyDto({
    required this.slug,
    required this.nom,
    required this.prenom,
    required this.photoUrl,
    required this.groupName,
  });

  final String slug;
  final String nom;
  final String prenom;
  final String? photoUrl;
  final String? groupName;

  factory DeputyDto.fromJson(Map<String, dynamic> json) {
    final group = json['group'] as Map<String, dynamic>?;

    return DeputyDto(
      slug: (json['slug'] as String?) ?? '',
      nom: (json['nom'] as String?) ?? '',
      prenom: (json['prenom'] as String?) ?? '',
      photoUrl: json['photo_url'] as String?,
      groupName: group?['nom'] as String?,
    );
  }

  Deputy toDomain() {
    return Deputy(
      slug: slug,
      nom: nom,
      prenom: prenom,
      photoUrl: photoUrl,
      groupName: groupName,
    );
  }
}
