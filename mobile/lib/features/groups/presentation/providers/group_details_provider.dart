import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../data/repositories/group_repository_impl.dart';
import '../../domain/entities/group.dart';
import '../../domain/repositories/group_repository.dart';

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepositoryImpl(ref.watch(apiClientProvider));
});

final groupDetailsProvider = FutureProvider.family<Group, String>((ref, slug) async {
  return ref.watch(groupRepositoryProvider).getBySlug(slug);
});
