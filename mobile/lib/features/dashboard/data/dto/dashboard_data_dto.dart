import '../../domain/entities/dashboard_data.dart';
import 'dashboard_group_dto.dart';
import 'dashboard_scrutin_dto.dart';
import 'dashboard_stats_dto.dart';
import 'recent_activity_dto.dart';

class DashboardDataDto {
  const DashboardDataDto({
    required this.stats,
    required this.latestScrutins,
    required this.topGroups,
    required this.recentActivity,
  });

  final DashboardStatsDto stats;
  final List<DashboardScrutinDto> latestScrutins;
  final List<DashboardGroupDto> topGroups;
  final RecentActivityDto recentActivity;

  factory DashboardDataDto.fromJson(Map<String, dynamic> json) {
    final statsJson = json['stats'] as Map<String, dynamic>? ?? {};
    final latestScrutinsJson =
        json['latest_scrutins'] as List<dynamic>? ?? [];
    final topGroupsJson = json['top_groups'] as List<dynamic>? ?? [];
    final recentActivityJson =
        json['recent_activity'] as Map<String, dynamic>? ?? {};

    return DashboardDataDto(
      stats: DashboardStatsDto.fromJson(statsJson),
      latestScrutins: latestScrutinsJson
          .cast<Map<String, dynamic>>()
          .map(DashboardScrutinDto.fromJson)
          .toList(),
      topGroups: topGroupsJson
          .cast<Map<String, dynamic>>()
          .map(DashboardGroupDto.fromJson)
          .toList(),
      recentActivity: RecentActivityDto.fromJson(recentActivityJson),
    );
  }

  DashboardData toDomain() {
    return DashboardData(
      stats: stats.toDomain(),
      latestScrutins:
          latestScrutins.map((dto) => dto.toDomain()).toList(),
      topGroups: topGroups.map((dto) => dto.toDomain()).toList(),
      recentActivity: recentActivity.toDomain(),
    );
  }
}
