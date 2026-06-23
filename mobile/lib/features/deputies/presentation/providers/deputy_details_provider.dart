import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/deputy.dart';
import 'deputies_provider.dart';

final deputyDetailsProvider = FutureProvider.family<Deputy, String>((ref, slug) async {
  return ref.watch(deputyRepositoryProvider).getBySlug(slug);
});
