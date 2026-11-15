import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/models/course_model.dart';
import '../../../core/domain/models/video_model.dart';
import '../../../core/constants/enums.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/json_utils.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.watch(apiClientProvider));
});

/// Sumber data katalog mata kuliah & video dari backend Takluk.
class HomeRepository {
  final ApiClient _api;

  HomeRepository(this._api);

  /// `GET /api/courses`
  Future<List<CourseModel>> getCourses() async {
    final data = await _api.get(ApiEndpoints.courses);
    return _asList(data).map(CourseModel.fromJson).toList();
  }

  /// `GET /api/courses/videos`
  Future<List<VideoModel>> getVideos({
    String? courseId,
    VideoCategory? category,
    University? university,
  }) async {
    final data = await _api.get(
      ApiEndpoints.videos,
      query: {
        'course_id': courseId,
        'category': category?.value,
        'university_tag': university?.value,
      },
    );
    return _asList(data).map(VideoModel.fromJson).toList();
  }

  /// `GET /api/courses/videos/:id`
  Future<VideoModel> getVideoDetail(String videoId) async {
    final data = await _api.get(ApiEndpoints.videoDetail(videoId));
    return VideoModel.fromJson(asJsonMap(data));
  }

  /// `GET /api/courses/videos/:id/play` (butuh JWT + X-Device-ID).
  Future<VideoPlaybackModel> getPlayback(String videoId) async {
    final data = await _api.get(ApiEndpoints.videoPlay(videoId));
    return VideoPlaybackModel.fromJson(asJsonMap(data));
  }

  List<Map<String, dynamic>> _asList(dynamic data) {
    if (data is List) {
      return data.whereType<Map>().map(asJsonMap).toList();
    }
    return const [];
  }
}


