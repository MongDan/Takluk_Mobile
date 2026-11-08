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
  });

  double get progress {
    if (videoDurationSeconds == null || videoDurationSeconds == 0) return 0;
    return lastPositionSec / videoDurationSeconds!;
  }

  factory WatchHistoryModel.fromJson(Map<String, dynamic> json) {
    return WatchHistoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      videoId: json['video_id'] as String,
      lastPositionSec: json['last_position_sec'] as int? ?? 0,
      totalWatchedSec: json['total_watched_sec'] as int? ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
      lastWatchedAt: DateTime.parse(json['last_watched_at'] as String),
      videoTitle: json['video_title'] as String?,
      courseSymbol: json['course_symbol'] as String?,
      videoDurationSeconds: json['video_duration_seconds'] as int?,
      courseName: json['course_name'] as String?,
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
    );
  }
}
