import '../../constants/enums.dart';

class ArchiveQuestionModel {
  final String id;
  final String courseId;
  final University universityTag;
  final ExamType examType;
  final String academicYear;
  final String questionMarkdown;
  final List<QuestionOption> options;
  final String correctKey;
  final String explanationMd;
  final String? relatedVideoId;

  const ArchiveQuestionModel({
    required this.id,
    required this.courseId,
    required this.universityTag,
    required this.examType,
    required this.academicYear,
    required this.questionMarkdown,
    required this.options,
    required this.correctKey,
    required this.explanationMd,
    this.relatedVideoId,
  });

  factory ArchiveQuestionModel.fromJson(Map<String, dynamic> json) {
    return ArchiveQuestionModel(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      universityTag: University.fromValue(json['university_tag'] as String),
      examType: ExamType.values.firstWhere((e) => e.value == json['exam_type']),
      academicYear: json['academic_year'] as String,
      questionMarkdown: json['question_markdown'] as String,
      options: (json['options_json'] as List<dynamic>)
          .map((o) => QuestionOption.fromJson(o as Map<String, dynamic>))
          .toList(),
      correctKey: json['correct_key'] as String,
      explanationMd: json['explanation_md'] as String,
      relatedVideoId: json['related_video_id'] as String?,
    );
  }
}

class QuestionOption {
  final String key;
  final String text;

  const QuestionOption({required this.key, required this.text});

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      key: json['key'] as String,
      text: json['text'] as String,
    );
  }
}
