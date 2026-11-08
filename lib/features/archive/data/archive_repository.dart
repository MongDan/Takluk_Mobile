import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/mock_data.dart';
import '../../../core/domain/models/archive_question_model.dart';
import '../../../core/constants/enums.dart';

final archiveRepositoryProvider = Provider<ArchiveRepository>((ref) => ArchiveRepository());

class ArchiveRepository {
  List<ArchiveQuestionModel> getQuestions({
    String? courseId,
    University? university,
    ExamType? examType,
  }) {
    var list = MockData.archiveQuestions;

    if (courseId != null) {
      list = list.where((q) => q.courseId == courseId).toList();
    }
    if (university != null) {
      list = list.where((q) => q.universityTag == university).toList();
    }
    if (examType != null) {
      list = list.where((q) => q.examType == examType).toList();
    }

    return list;
  }
}

