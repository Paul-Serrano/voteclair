class Deputy {
  const Deputy({
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

  String get fullName => '$prenom $nom'.trim();
}
