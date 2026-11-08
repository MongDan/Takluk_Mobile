import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/models/course_model.dart';
import '../../../../core/domain/models/video_model.dart';
import '../../../../core/domain/models/watch_history_model.dart';
import '../../data/home_repository.dart';

final coursesProvider = FutureProvider<List<CourseModel>>((ref) {
  return ref.read(homeRepositoryProvider).getCourses();
});

final popularVideosProvider = FutureProvider<List<VideoModel>>((ref) {
  return ref.read(homeRepositoryProvider).getPopularVideos();
});

final continueWatchingProvider = Provider<List<WatchHistoryModel>>((ref) {
  return ref.read(homeRepositoryProvider).getContinueWatching();
});

