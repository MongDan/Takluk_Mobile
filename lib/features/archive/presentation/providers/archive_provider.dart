import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/domain/models/archive_question_model.dart';
import '../../data/archive_repository.dart';

/// Filter bank soal: kampus + jenis ujian.
typedef ArchiveFilter = ({University? university, ExamType? examType});

/// `GET /api/archives` dengan filter kampus & jenis ujian.
final archiveQuestionsProvider =
    FutureProvider.family<List<ArchiveQuestionModel>, ArchiveFilter>(
  (ref, filter) {
    return ref.watch(archiveRepositoryProvider).getQuestions(
          university: filter.university,
          examType: filter.examType,
        );
  },
);

/// Soal untuk satu mata kuliah (dipakai halaman kuis).
final courseArchiveQuestionsProvider =
    FutureProvider.family<List<ArchiveQuestionModel>, String>(
  (ref, courseId) {
    return ref.watch(archiveRepositoryProvider).getQuestions(courseId: courseId);
  },
);
