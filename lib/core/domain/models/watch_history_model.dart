import '../../constants/enums.dart';
import '../../network/json_utils.dart';

class WatchHistoryModel {
  final String id;
  final String userId;
  final String videoId;
  final int lastPositionSec;
  final int totalWatchedSec;
  final bool isCompleted;
  final bool isBookmarked;
  final DateTime lastWatchedAt;
  // Joined fields
  final String? videoTitle;
  final String? courseSymbol;
  final int? videoDurationSeconds;
  final String? courseName;
  final bool isFree;
  final VideoCategory? category;
  final University? universityTag;

  const WatchHistoryModel({
    required this.id,
    required this.userId,
    required this.videoId,
    this.lastPositionSec = 0,
    this.totalWatchedSec = 0,
    this.isCompleted = false,
    this.isBookmarked = false,
    required this.lastWatchedAt,
    this.videoTitle,
    this.courseSymbol,
    this.videoDurationSeconds,
    this.courseName,
    this.isFree = false,
    this.category,
    this.universityTag,
  });

  double get progress {
    if (videoDurationSeconds == null || videoDurationSeconds == 0) return 0;
    return (lastPositionSec / videoDurationSeconds!).clamp(0, 1);
  }

  factory WatchHistoryModel.fromJson(Map<String, dynamic> json) {
    return WatchHistoryModel(
      id: pickString(json, ['id']),
      userId: pickString(json, ['user_id', 'userId']),
      videoId: pickString(json, ['video_id', 'videoId']),
      lastPositionSec: pickInt(json, ['last_position_sec', 'lastPositionSec']),
      totalWatchedSec: pickInt(json, ['total_watched_sec', 'totalWatchedSec']),
      isCompleted: pickBool(json, ['is_completed', 'isCompleted']),
      isBookmarked: pickBool(json, ['is_bookmarked', 'isBookmarked']),
      lastWatchedAt:
          pickDate(json, ['last_watched_at', 'lastWatchedAt']) ?? DateTime.now(),
      videoTitle: pickStringOrNull(json, ['video_title', 'videoTitle']),
      courseSymbol: pickStringOrNull(json, ['course_symbol', 'courseSymbol']),
      videoDurationSeconds: pickIntOrNull(
        json,
        ['video_duration_seconds', 'videoDurationSeconds'],
      ),
      courseName: pickStringOrNull(json, ['course_name', 'courseName']),
      isFree: pickBool(json, ['is_free', 'isFree']),
      category: pickStringOrNull(json, ['category']) != null
          ? VideoCategory.values.firstWhere(
              (e) => e.value == pickString(json, ['category']),
              orElse: () => VideoCategory.MATERI,
            )
          : null,
      universityTag:
          pickStringOrNull(json, ['university_tag', 'universityTag']) != null
              ? University.fromValue(
                  pickString(json, ['university_tag', 'universityTag']),
                )
              : null,
    );
  }

  /// Memetakan baris `GET /api/progress/resume` atau `/bookmarks`.
  /// Backend mengirim data video (bukan data watch_history mentah).
  factory WatchHistoryModel.fromProgressVideoJson(
    Map<String, dynamic> json, {
    required bool isBookmarked,
  }) {
    final videoId = pickString(json, ['video_id', 'videoId', 'id']);
    return WatchHistoryModel(
      id: videoId,
      userId: pickString(json, ['user_id', 'userId']),
      videoId: videoId,
      lastPositionSec: pickInt(json, ['last_position_sec', 'lastPositionSec']),
      totalWatchedSec: pickInt(json, ['total_watched_sec', 'totalWatchedSec']),
      isCompleted: pickBool(json, ['is_completed', 'isCompleted']),
      isBookmarked: isBookmarked,
      lastWatchedAt:
          pickDate(json, ['last_watched_at', 'lastWatchedAt']) ?? DateTime.now(),
      videoTitle: pickStringOrNull(json, ['title', 'video_title', 'videoTitle']),
      courseSymbol: pickStringOrNull(json, ['course_symbol', 'courseSymbol']),
      videoDurationSeconds: pickIntOrNull(
        json,
        ['duration_seconds', 'durationSeconds', 'videoDurationSeconds'],
      ),
      courseName: pickStringOrNull(
        json,
        ['course_title', 'courseTitle', 'course_name', 'courseName'],
      ),
      isFree: pickBool(json, ['is_free', 'isFree']),
      category: pickStringOrNull(json, ['category']) != null
          ? VideoCategory.values.firstWhere(
              (e) => e.value == pickString(json, ['category']),
              orElse: () => VideoCategory.MATERI,
            )
          : null,
      universityTag:
          pickStringOrNull(json, ['university_tag', 'universityTag']) != null
              ? University.fromValue(
                  pickString(json, ['university_tag', 'universityTag']),
                )
              : null,
    );
  }

  WatchHistoryModel copyWith({
    bool? isBookmarked,
    int? lastPositionSec,
    int? totalWatchedSec,
    bool? isCompleted,
    DateTime? lastWatchedAt,
  }) {
    return WatchHistoryModel(
      id: id,
      userId: userId,
      videoId: videoId,
      lastPositionSec: lastPositionSec ?? this.lastPositionSec,
      totalWatchedSec: totalWatchedSec ?? this.totalWatchedSec,
      isCompleted: isCompleted ?? this.isCompleted,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      lastWatchedAt: lastWatchedAt ?? this.lastWatchedAt,
      videoTitle: videoTitle,
      courseSymbol: courseSymbol,
      videoDurationSeconds: videoDurationSeconds,
      courseName: courseName,
      isFree: isFree,
      category: category,
      universityTag: universityTag,
    );
  }
}

