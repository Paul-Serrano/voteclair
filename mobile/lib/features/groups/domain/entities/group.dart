class Group {
  const Group({
    required this.id,
    required this.slug,
    required this.nom,
    required this.nomComplet,
    this.couleur,
    this.logoUrl,
    this.position,
    required this.membresCount,
    required this.stats,
  });

  final String id;
  final String slug;
  final String nom;
  final String nomComplet;
  final String? couleur;
  final String? logoUrl;
  final String? position;
  final int membresCount;
  final GroupStats stats;
}

class GroupStats {
  const GroupStats({
    required this.presence,
    required this.presenceSolennelle,
    required this.loyaute,
    required this.cohesion,
    required this.participation,
    required this.votesPour,
    required this.votesContre,
    required this.votesAbstention,
    required this.votesAbsent,
  });

  final int presence;
  final int presenceSolennelle;
  final int loyaute;
  final int cohesion;
  final int participation;
  final int votesPour;
  final int votesContre;
  final int votesAbstention;
  final int votesAbsent;

  int get totalVotes => votesPour + votesContre + votesAbstention + votesAbsent;
}
