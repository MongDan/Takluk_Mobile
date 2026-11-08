import '../../constants/enums.dart';

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
    return VideoModel(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      tutorId: json['tutor_id'] as String,
      title: json['title'] as String,
      category: VideoCategory.values.firstWhere(
        (e) => e.value == json['category'],
        orElse: () => VideoCategory.MATERI,
      ),
      universityTag: json['university_tag'] != null
          ? University.fromValue(json['university_tag'])
          : null,
      durationSeconds: json['duration_seconds'] as int,
      cfVideoUid: json['cf_video_uid'] as String,
      summaryMarkdown: json['summary_markdown'] as String?,
      isFree: json['is_free'] as bool? ?? false,
      isPublished: json['is_published'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
      tutorName: json['tutor_name'] as String?,
      courseName: json['course_name'] as String?,
      courseSymbol: json['course_symbol'] as String?,
      chapters: (json['chapters'] as List<dynamic>?)
          ?.map((c) => VideoChapter.fromJson(c))
          .toList() ?? [],
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

  factory VideoChapter.fromJson(Map<String, dynamic> json) {
    return VideoChapter(
      id: json['id'] as String,
      videoId: json['video_id'] as String,
      title: json['title'] as String,
      startSecond: json['start_second'] as int,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }
}
