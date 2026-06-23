class GroupMember {
  const GroupMember({
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

  String get fullName => '$prenom $nom'.trim();
}
