import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/models/course_model.dart';
import '../../../../core/domain/models/video_model.dart';
import '../../../../core/domain/models/watch_history_model.dart';
import '../../../../core/domain/models/hub_service_model.dart';
import '../../../../core/constants/enums.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../hub/data/hub_repository.dart';
import '../../data/home_repository.dart';
import '../../data/progress_repository.dart';

final coursesProvider = FutureProvider<List<CourseModel>>((ref) {
  return ref.watch(homeRepositoryProvider).getCourses();
});

/// Video bedah soal populer untuk beranda.
final popularVideosProvider = FutureProvider<List<VideoModel>>((ref) {
  return ref.watch(homeRepositoryProvider).getVideos(category: VideoCategory.UTS);
});

/// Lanjut menonton — butuh login (JWT + device binding).
final continueWatchingProvider = FutureProvider<List<WatchHistoryModel>>((ref) async {
  final userId = ref.watch(authProvider.select((state) => state.user?.id));
  if (userId == null) return const [];
  return ref.watch(progressRepositoryProvider).getResumeWatching();
});

/// Katalog layanan offline Panam Academy Hub.
final hubServicesProvider = FutureProvider<HubCatalogModel>((ref) {
  return ref.watch(hubRepositoryProvider).getServices();
});


