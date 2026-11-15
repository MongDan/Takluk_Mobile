import '../../constants/enums.dart';
import '../../network/json_utils.dart';

class ArchiveQuestionModel {
  final String id;
  final String courseId;
  final String? courseTitle;
  final String? courseSymbol;
  final University universityTag;
  final ExamType examType;
  final String academicYear;
  final String questionMarkdown;
  final List<QuestionOption> options;
  final String? correctKey;
  final String? explanationMd;
  final String? relatedVideoId;

  const ArchiveQuestionModel({
    required this.id,
    required this.courseId,
    this.courseTitle,
    this.courseSymbol,
    required this.universityTag,
    required this.examType,
    required this.academicYear,
    required this.questionMarkdown,
    required this.options,
    this.correctKey,
    this.explanationMd,
    this.relatedVideoId,
  });

  factory ArchiveQuestionModel.fromJson(Map<String, dynamic> json) {
    return ArchiveQuestionModel(
      id: pickString(json, ['id']),
      courseId: pickString(json, ['course_id', 'courseId']),
      courseTitle: pickStringOrNull(json, ['course_title', 'courseTitle']),
      courseSymbol: pickStringOrNull(json, ['course_symbol', 'courseSymbol']),
      universityTag: University.fromValue(
        pickString(json, ['university_tag', 'universityTag'], fallback: 'LAINNYA'),
      ),
      examType: ExamType.values.firstWhere(
        (e) => e.value == pickString(json, ['exam_type', 'examType']),
        orElse: () => ExamType.UTS,
      ),
      academicYear: pickString(json, ['academic_year', 'academicYear']),
      questionMarkdown:
          pickString(json, ['question_markdown', 'questionMarkdown']),
      options: pickMapList(json, ['options_json', 'optionsJson', 'options'])
          .map(QuestionOption.fromJson)
          .toList(),
      correctKey: pickStringOrNull(json, ['correct_key', 'correctKey']),
      explanationMd: pickStringOrNull(json, ['explanation_md', 'explanationMd']),
      relatedVideoId:
          pickStringOrNull(json, ['related_video_id', 'relatedVideoId']),
    );
  }

  /// Melengkapi soal dengan hasil evaluasi dari
  /// `POST /api/archives/:id/evaluate`.
  ArchiveQuestionModel withEvaluation(ArchiveEvaluationModel evaluation) {
    return ArchiveQuestionModel(
      id: id,
      courseId: courseId,
      courseTitle: courseTitle,
      courseSymbol: courseSymbol,
      universityTag: universityTag,
      examType: examType,
      academicYear: academicYear,
      questionMarkdown: questionMarkdown,
      options: options,
      correctKey: evaluation.correctKey,
      explanationMd: evaluation.explanationMd,
      relatedVideoId: evaluation.relatedVideoId ?? relatedVideoId,
    );
  }
}

class QuestionOption {
  final String key;
  final String text;

  const QuestionOption({required this.key, required this.text});

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      key: pickString(json, ['key']),
      text: pickString(json, ['text']),
    );
  }
}

/// Respons `POST /api/archives/:id/evaluate`.
class ArchiveEvaluationModel {
  final String questionId;
  final String selectedKey;
  final bool isCorrect;
  final String correctKey;
  final String? explanationMd;
  final String? relatedVideoId;

  const ArchiveEvaluationModel({
    required this.questionId,
    required this.selectedKey,
    required this.isCorrect,
    required this.correctKey,
    this.explanationMd,
    this.relatedVideoId,
  });

  factory ArchiveEvaluationModel.fromJson(Map<String, dynamic> json) {
    return ArchiveEvaluationModel(
      questionId: pickString(json, ['question_id', 'questionId']),
      selectedKey: pickString(json, ['selected_key', 'selectedKey']),
      isCorrect: pickBool(json, ['is_correct', 'isCorrect']),
      correctKey: pickString(json, ['correct_key', 'correctKey']),
      explanationMd: pickStringOrNull(json, ['explanation_md', 'explanationMd']),
      relatedVideoId:
          pickStringOrNull(json, ['related_video_id', 'relatedVideoId']),
    );
  }
}

