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
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      symbol: json['symbol'] as String,
      semesterTarget: json['semester_target'] as int,
      description: json['description'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      isPublished: json['is_published'] as bool? ?? true,
      videoCount: json['video_count'] as int? ?? 0,
      freeVideoCount: json['free_video_count'] as int? ?? 0,
    );
  }
}
