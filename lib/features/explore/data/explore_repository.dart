import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/mock_data.dart';
import '../../../core/domain/models/video_model.dart';
import '../../../core/constants/enums.dart';

final exploreRepositoryProvider = Provider<ExploreRepository>((ref) => ExploreRepository());

class ExploreRepository {
  List<VideoModel> searchVideos({
    String? query,
    String? courseId,
    VideoCategory? category,
  }) {
    var results = MockData.videos.where((v) => v.isPublished).toList();

    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      results = results.where((v) =>
          v.title.toLowerCase().contains(q) ||
          (v.courseName?.toLowerCase().contains(q) ?? false) ||
          (v.universityTag?.label.toLowerCase().contains(q) ?? false) ||
          (v.tutorName?.toLowerCase().contains(q) ?? false)
      ).toList();
    }

    if (courseId != null) {
      results = results.where((v) => v.courseId == courseId).toList();
    }

    if (category != null) {
      results = results.where((v) => v.category == category).toList();
    }

    return results;
  }
}

