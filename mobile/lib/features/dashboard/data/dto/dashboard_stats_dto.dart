import '../../domain/entities/dashboard_stats.dart';

class DashboardStatsDto {
  const DashboardStatsDto({
    required this.deputies,
    required this.groups,
    required this.scrutins,
    required this.votes,
  });

  final int deputies;
  final int groups;
  final int scrutins;
  final int votes;

  factory DashboardStatsDto.fromJson(Map<String, dynamic> json) {
    return DashboardStatsDto(
      deputies: (json['deputies'] as num?)?.toInt() ?? 0,
      groups: (json['groups'] as num?)?.toInt() ?? 0,
      scrutins: (json['scrutins'] as num?)?.toInt() ?? 0,
      votes: (json['votes'] as num?)?.toInt() ?? 0,
    );
  }

  DashboardStats toDomain() {
    return DashboardStats(
      deputies: deputies,
      groups: groups,
      scrutins: scrutins,
      votes: votes,
    );
  }
}
