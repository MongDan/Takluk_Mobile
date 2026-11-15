import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/models/watch_history_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/json_utils.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository(ref.watch(apiClientProvider));
});

/// Progres belajar & bookmark (butuh JWT + X-Device-ID).
class ProgressRepository {
  final ApiClient _api;

  /// Cache posisi terakhir agar toggle bookmark tidak mereset progres tonton.
  final Map<String, int> _lastPositions = {};
  final Set<String> _bookmarkedVideoIds = {};

  ProgressRepository(this._api);

  /// `POST /api/progress/sync` — heartbeat 30 detik.
  Future<WatchHistoryModel> sync({
    required String videoId,
    required int lastPositionSec,
    int watchedDeltaSec = 0,
    bool? isBookmarked,
  }) async {
    final data = await _api.post(
      ApiEndpoints.progressSync,
      data: {
        'video_id': videoId,
        'last_position_sec': lastPositionSec,
        'watched_delta_sec': watchedDeltaSec,
        if (isBookmarked != null) 'is_bookmarked': isBookmarked,
      },
    );

    final history = WatchHistoryModel.fromJson(asJsonMap(data));
    _lastPositions[videoId] = lastPositionSec;
    if (isBookmarked != null) {
      if (isBookmarked) {
        _bookmarkedVideoIds.add(videoId);
      } else {
        _bookmarkedVideoIds.remove(videoId);
      }
    }
    return history;
  }

  /// `GET /api/progress/resume` — 5 video terakhir yang belum selesai.
  Future<List<WatchHistoryModel>> getResumeWatching() async {
    final data = await _api.get(ApiEndpoints.progressResume);
    final list = _mapList(data, isBookmarked: false);
    for (final item in list) {
      _lastPositions[item.videoId] = item.lastPositionSec;
    }
    return list;
  }

  /// `GET /api/progress/bookmarks`
  Future<List<WatchHistoryModel>> getBookmarks() async {
    final data = await _api.get(ApiEndpoints.bookmarks);
    final list = _mapList(data, isBookmarked: true);
    for (final item in list) {
      _lastPositions[item.videoId] = item.lastPositionSec;
      _bookmarkedVideoIds.add(item.videoId);
    }
    return list;
  }

  bool isBookmarked(String videoId) => _bookmarkedVideoIds.contains(videoId);

  int lastPositionOf(String videoId) => _lastPositions[videoId] ?? 0;

  /// Toggle bookmark lewat endpoint sync (backend belum punya endpoint khusus).
  Future<void> setBookmark(String videoId, bool isBookmarked) async {
    await sync(
      videoId: videoId,
      lastPositionSec: lastPositionOf(videoId),
      isBookmarked: isBookmarked,
    );
  }

  List<WatchHistoryModel> _mapList(dynamic data, {required bool isBookmarked}) {
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((row) => WatchHistoryModel.fromProgressVideoJson(
              asJsonMap(row),
              isBookmarked: isBookmarked,
            ))
        .toList();
  }
}
