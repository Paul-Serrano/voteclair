// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:voteclair_mobile/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:voteclair_mobile/features/dashboard/domain/entities/dashboard_group.dart';
import 'package:voteclair_mobile/features/dashboard/domain/entities/dashboard_scrutin.dart';
import 'package:voteclair_mobile/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:voteclair_mobile/features/dashboard/domain/entities/recent_activity.dart';
import 'package:voteclair_mobile/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:voteclair_mobile/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:voteclair_mobile/main.dart';

class FakeDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardData> getDashboard() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return DashboardData(
      stats: const DashboardStats(
        deputies: 577,
        groups: 11,
        scrutins: 2543,
        votes: 1245789,
      ),
      latestScrutins: [
        DashboardScrutin(
          id: 'test-1',
          numero: 100,
          titre: 'Test Scrutin',
          date: DateTime.now(),
          sort: 'Adopté',
        ),
      ],
      topGroups: [
        const DashboardGroup(
          slug: 'test-group',
          nom: 'Test Group',
          couleur: '#FF0000',
          membersCount: 50,
        ),
      ],
      recentActivity: RecentActivity(
        lastScrutinDate: DateTime.now(),
        lastScrutinTitle: 'Test Recent Scrutin',
      ),
    );
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr_FR');
  });

  testWidgets('Home screen is displayed', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardRepositoryProvider
              .overrideWithValue(FakeDashboardRepository()),
        ],
        child: const VoteClairApp(),
      ),
    );

    // Wait for the dashboard to load
    await tester.pumpAndSettle();

    expect(find.text('VoteClair'), findsAtLeastNWidgets(1));
    expect(find.text('Statistiques'), findsOneWidget);
  });
}
