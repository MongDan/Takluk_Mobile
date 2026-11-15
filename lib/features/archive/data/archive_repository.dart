import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/enums.dart';
import '../../../core/domain/models/archive_question_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/json_utils.dart';

final archiveRepositoryProvider = Provider<ArchiveRepository>((ref) {
  return ArchiveRepository(ref.watch(apiClientProvider));
});

class ArchiveRepository {
  final ApiClient _api;

  ArchiveRepository(this._api);

  /// `GET /api/archives` — bank soal UTS/UAS.
  Future<List<ArchiveQuestionModel>> getQuestions({
    String? courseId,
    University? university,
    ExamType? examType,
  }) async {
    final data = await _api.get(
      ApiEndpoints.archives,
      query: {
        'course_id': courseId,
        'university_tag': university?.value,
        'exam_type': examType?.value,
      },
    );

    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((row) => ArchiveQuestionModel.fromJson(asJsonMap(row)))
        .toList();
  }

  /// `POST /api/archives/:id/evaluate` — kunci jawaban & pembahasan.
  Future<ArchiveEvaluationModel> evaluate({
    required String questionId,
    required String selectedKey,
  }) async {
    final data = await _api.post(
      ApiEndpoints.archiveEvaluate(questionId),
      data: {'selected_key': selectedKey},
    );
    return ArchiveEvaluationModel.fromJson(asJsonMap(data));
  }
}


