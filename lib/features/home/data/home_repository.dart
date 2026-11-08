import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/mock_data.dart';
import '../../../core/domain/models/course_model.dart';
import '../../../core/domain/models/video_model.dart';
import '../../../core/domain/models/watch_history_model.dart';
import '../../../core/constants/enums.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) => HomeRepository());

class HomeRepository {
  Future<List<CourseModel>> getCourses() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockData.courses;
  }

  Future<List<VideoModel>> getPopularVideos() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockData.videos.where((v) => v.category != VideoCategory.MATERI).take(4).toList();
  }

  List<WatchHistoryModel> getContinueWatching() {
    return MockData.watchHistories
        .where((w) => !w.isCompleted && w.lastPositionSec > 0)
        .toList()
      ..sort((a, b) => b.lastWatchedAt.compareTo(a.lastWatchedAt));
  }
}

