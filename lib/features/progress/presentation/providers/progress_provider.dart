import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/models/watch_history_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/data/progress_repository.dart';

/// Daftar materi tersimpan dari `GET /api/progress/bookmarks`.
final bookmarksProvider = FutureProvider<List<WatchHistoryModel>>((ref) async {
  final userId = ref.watch(authProvider.select((state) => state.user?.id));
  if (userId == null) return const [];
  return ref.watch(progressRepositoryProvider).getBookmarks();
});
