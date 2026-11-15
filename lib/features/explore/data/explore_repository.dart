import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/enums.dart';
import '../../../core/domain/models/video_model.dart';
import '../../home/data/home_repository.dart';

final exploreRepositoryProvider = Provider<ExploreRepository>((ref) {
  return ExploreRepository(ref.watch(homeRepositoryProvider));
});

class ExploreRepository {
  final HomeRepository _home;

  ExploreRepository(this._home);

  /// `GET /api/courses/videos` + filter kata kunci di sisi klien
  /// (backend belum menyediakan parameter pencarian teks).
  Future<List<VideoModel>> searchVideos({
    String? query,
    String? courseId,
    VideoCategory? category,
  }) async {
    final results = await _home.getVideos(
      courseId: courseId,
      category: category,
    );

    if (query == null || query.trim().isEmpty) return results;

    final q = query.toLowerCase().trim();
    return results.where((video) {
      return video.title.toLowerCase().contains(q) ||
          (video.courseName?.toLowerCase().contains(q) ?? false) ||
          (video.tutorName?.toLowerCase().contains(q) ?? false) ||
          (video.universityTag?.label.toLowerCase().contains(q) ?? false);
    }).toList();
  }
}


