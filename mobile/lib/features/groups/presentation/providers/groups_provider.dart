import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/group_summary.dart';
import 'group_details_provider.dart';

final groupsProvider = FutureProvider<List<GroupSummary>>((ref) async {
  return ref.watch(groupRepositoryProvider).fetchGroups();
});
