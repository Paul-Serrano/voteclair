import '../../domain/entities/dashboard_scrutin.dart';

class DashboardScrutinDto {
  const DashboardScrutinDto({
    required this.id,
    required this.numero,
    required this.titre,
    required this.date,
    required this.sort,
    required this.importanceScore,
  });

  final String id;
  final int numero;
  final String titre;
  final DateTime date;
  final String sort;
  final int importanceScore;

  factory DashboardScrutinDto.fromJson(Map<String, dynamic> json) {
    return DashboardScrutinDto(
      id: (json['id'] as String?) ?? '',
      numero: (json['numero'] as num?)?.toInt() ?? 0,
      titre: (json['titre'] as String?) ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      sort: (json['sort'] as String?) ?? '',
      importanceScore: (json['importance_score'] as num?)?.toInt() ?? 0,
    );
  }

  DashboardScrutin toDomain() {
    return DashboardScrutin(
      id: id,
      numero: numero,
      titre: titre,
      date: date,
      sort: sort,
      importanceScore: importanceScore,
    );
  }
}
