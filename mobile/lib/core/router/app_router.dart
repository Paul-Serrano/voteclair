import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/deputies/presentation/deputies_list_page.dart';
import '../../features/deputies/presentation/pages/deputy_details_page.dart';
import '../../features/deputies/presentation/pages/deputy_votes_page.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/groups/presentation/groups_page.dart';
import '../../features/groups/presentation/pages/groups_list_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/scrutins/presentation/pages/scrutin_details_page.dart';
import '../../features/scrutins/presentation/scrutins_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (context, state) => const FavoritesPage(),
      ),
      GoRoute(
        path: '/deputies',
        name: 'deputies',
        builder: (context, state) => const DeputiesListPage(),
      ),
      GoRoute(
        path: '/deputies/:slug',
        name: 'deputy-detail',
        builder: (context, state) {
          final slug = state.pathParameters['slug'] ?? '';
          return DeputyDetailsPage(slug: slug);
        },
      ),
      GoRoute(
        path: '/deputies/:slug/votes',
        name: 'deputy-votes',
        builder: (context, state) {
          final slug = state.pathParameters['slug'] ?? '';
          return DeputyVotesPage(slug: slug);
        },
      ),
      GoRoute(
        path: '/scrutins',
        name: 'scrutins',
        builder: (context, state) => const ScrutinsPage(),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: '/groups',
        name: 'groups',
        builder: (context, state) => const GroupsListPage(),
      ),
      GoRoute(
        path: '/groups/:slug',
        name: 'group-detail',
        builder: (context, state) {
          final slug = state.pathParameters['slug'] ?? '';
          return GroupsPage(slug: slug);
        },
      ),
      GoRoute(
        path: '/scrutins/:id',
        name: 'scrutin-detail',
        builder: (context, state) {
          final scrutinId = state.pathParameters['id'] ?? '';
          return ScrutinDetailsPage(scrutinId: scrutinId);
        },
      ),
    ],
  );
});
