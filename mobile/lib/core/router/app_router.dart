import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/deputies/presentation/deputies_list_page.dart';
import '../../features/deputies/presentation/pages/deputy_details_page.dart';
import '../../features/deputies/presentation/pages/deputy_votes_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/scrutins/presentation/scrutin_detail_page.dart';
import '../../features/scrutins/presentation/scrutins_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
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
        path: '/scrutins/:id',
        name: 'scrutin-detail',
        builder: (context, state) {
          final scrutinId = state.pathParameters['id'] ?? '';
          return ScrutinDetailPage(scrutinId: scrutinId);
        },
      ),
    ],
  );
});
