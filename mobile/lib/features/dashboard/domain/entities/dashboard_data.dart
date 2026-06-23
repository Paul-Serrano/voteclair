import 'dashboard_group.dart';
import 'dashboard_scrutin.dart';
import 'dashboard_stats.dart';
import 'recent_activity.dart';

class DashboardData {
  const DashboardData({
    required this.stats,
    required this.latestScrutins,
    required this.topGroups,
    required this.recentActivity,
  });

  final DashboardStats stats;
  final List<DashboardScrutin> latestScrutins;
  final List<DashboardGroup> topGroups;
  final RecentActivity recentActivity;
}
