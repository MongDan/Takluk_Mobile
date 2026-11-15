import '../../network/json_utils.dart';

class CourseModel {
  final String id;
  final String slug;
  final String title;
  final String symbol;
  final int semesterTarget;
  final String? description;
  final int sortOrder;
  final bool isPublished;
  final int videoCount;
  final int freeVideoCount;

  const CourseModel({
    required this.id,
    required this.slug,
    required this.title,
    required this.symbol,
    required this.semesterTarget,
    this.description,
    this.sortOrder = 0,
    this.isPublished = true,
    this.videoCount = 0,
    this.freeVideoCount = 0,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: pickString(json, ['id']),
      slug: pickString(json, ['slug']),
      title: pickString(json, ['title']),
      symbol: pickString(json, ['symbol']),
      semesterTarget: pickInt(json, ['semester_target', 'semesterTarget']),
      description: pickStringOrNull(json, ['description']),
      sortOrder: pickInt(json, ['sort_order', 'sortOrder']),
      isPublished: pickBool(json, ['is_published', 'isPublished'], fallback: true),
      videoCount: pickInt(json, ['video_count', 'videoCount']),
      freeVideoCount: pickInt(json, ['free_video_count', 'freeVideoCount']),
    );
  }
}

