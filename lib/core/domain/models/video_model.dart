import '../../constants/enums.dart';
import '../../network/json_utils.dart';

class VideoModel {
  final String id;
  final String courseId;
  final String tutorId;
  final String title;
  final VideoCategory category;
  final University? universityTag;
  final int durationSeconds;
  final String cfVideoUid;
  final String? summaryMarkdown;
  final bool isFree;
  final bool isPublished;
  final int sortOrder;
  final String? tutorName;
  final String? tutorBio;
  final String? courseName;
  final String? courseSymbol;
  final List<VideoChapter> chapters;

  const VideoModel({
    required this.id,
    required this.courseId,
    required this.tutorId,
    required this.title,
    required this.category,
    this.universityTag,
    required this.durationSeconds,
    required this.cfVideoUid,
    this.summaryMarkdown,
    this.isFree = false,
    this.isPublished = true,
    this.sortOrder = 0,
    this.tutorName,
    this.tutorBio,
    this.courseName,
    this.courseSymbol,
    this.chapters = const [],
  });

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    final videoId = pickString(json, ['id']);
    final chapters = pickMapList(json, ['chapters'])
        .map((chapter) =>
            VideoChapter.fromJson(chapter, fallbackVideoId: videoId))
        .toList();

    return VideoModel(
      id: videoId,
      courseId: pickString(json, ['course_id', 'courseId']),
      tutorId: pickString(json, ['tutor_id', 'tutorId']),
      title: pickString(json, ['title']),
      category: VideoCategory.values.firstWhere(
        (e) => e.value == pickString(json, ['category'], fallback: 'MATERI'),
        orElse: () => VideoCategory.MATERI,
      ),
      universityTag:
          pickStringOrNull(json, ['university_tag', 'universityTag']) != null
              ? University.fromValue(
                  pickString(json, ['university_tag', 'universityTag']),
                )
              : null,
      durationSeconds: pickInt(json, ['duration_seconds', 'durationSeconds']),
      cfVideoUid: pickString(json, ['cf_video_uid', 'cfVideoUid']),
      summaryMarkdown:
          pickStringOrNull(json, ['summary_markdown', 'summaryMarkdown']),
      isFree: pickBool(json, ['is_free', 'isFree']),
      isPublished:
          pickBool(json, ['is_published', 'isPublished'], fallback: true),
      sortOrder: pickInt(json, ['sort_order', 'sortOrder']),
      tutorName: pickStringOrNull(json, ['tutor_name', 'tutorName']),
      tutorBio: pickStringOrNull(json, ['tutor_bio', 'tutorBio']),
      courseName: pickStringOrNull(
        json,
        ['course_name', 'courseName', 'course_title', 'courseTitle'],
      ),
      courseSymbol: pickStringOrNull(json, ['course_symbol', 'courseSymbol']),
      chapters: chapters,
    );
  }
}

class VideoChapter {
  final String id;
  final String videoId;
  final String title;
  final int startSecond;
  final int sortOrder;

  const VideoChapter({
    required this.id,
    required this.videoId,
    required this.title,
    required this.startSecond,
    this.sortOrder = 0,
  });

  String get formattedStart {
    final min = startSecond ~/ 60;
    final sec = startSecond % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  factory VideoChapter.fromJson(
    Map<String, dynamic> json, {
    String fallbackVideoId = '',
  }) {
    return VideoChapter(
      id: pickString(json, ['id']),
      videoId: pickString(
        json,
        ['video_id', 'videoId'],
        fallback: fallbackVideoId,
      ),
      title: pickString(json, ['title']),
      startSecond: pickInt(json, ['start_second', 'startSecond']),
      sortOrder: pickInt(json, ['sort_order', 'sortOrder']),
    );
  }
}

/// Respons `GET /api/courses/videos/:id/play`
/// (Signed HLS URL Bunny.net, berlaku 2 jam).
class VideoPlaybackModel {
  final String videoId;
  final String title;
  final VideoCategory category;
  final University? universityTag;
  final int durationSeconds;
  final bool isFree;
  final String hlsStreamUrl;
  final String embedPlayerUrl;
  final String? thumbnailUrl;
  final int expiresInSeconds;
  final String? summaryMarkdown;
  final List<VideoChapter> chapters;

  const VideoPlaybackModel({
    required this.videoId,
    required this.title,
    required this.category,
    this.universityTag,
    required this.durationSeconds,
    required this.isFree,
    required this.hlsStreamUrl,
    required this.embedPlayerUrl,
    this.thumbnailUrl,
    required this.expiresInSeconds,
    this.summaryMarkdown,
    this.chapters = const [],
  });

  factory VideoPlaybackModel.fromJson(Map<String, dynamic> json) {
    final videoId = pickString(json, ['video_id', 'videoId']);
    return VideoPlaybackModel(
      videoId: videoId,
      title: pickString(json, ['title']),
      category: VideoCategory.values.firstWhere(
        (e) => e.value == pickString(json, ['category'], fallback: 'MATERI'),
        orElse: () => VideoCategory.MATERI,
      ),
      universityTag:
          pickStringOrNull(json, ['university_tag', 'universityTag']) != null
              ? University.fromValue(
                  pickString(json, ['university_tag', 'universityTag']),
                )
              : null,
      durationSeconds: pickInt(json, ['duration_seconds', 'durationSeconds']),
      isFree: pickBool(json, ['is_free', 'isFree']),
      hlsStreamUrl: pickString(json, ['hls_stream_url', 'hlsStreamUrl']),
      embedPlayerUrl: pickString(json, ['embed_player_url', 'embedPlayerUrl']),
      thumbnailUrl: pickStringOrNull(json, ['thumbnail_url', 'thumbnailUrl']),
      expiresInSeconds:
          pickInt(json, ['expires_in_seconds', 'expiresInSeconds']),
      summaryMarkdown:
          pickStringOrNull(json, ['summary_markdown', 'summaryMarkdown']),
      chapters: pickMapList(json, ['chapters'])
          .map((chapter) =>
              VideoChapter.fromJson(chapter, fallbackVideoId: videoId))
          .toList(),
    );
  }
}

