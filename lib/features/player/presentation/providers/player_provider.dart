import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/models/video_model.dart';
import '../../../../core/network/api_exception.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/data/home_repository.dart';

/// `GET /api/courses/videos/:id` — metadata video + bab + ringkasan.
final videoDetailProvider =
    FutureProvider.family<VideoModel, String>((ref, videoId) {
  return ref.watch(homeRepositoryProvider).getVideoDetail(videoId);
});

/// `GET /api/courses/videos/:id/play` — Signed HLS URL (butuh login).
final videoPlaybackProvider =
    FutureProvider.family<VideoPlaybackModel, String>((ref, videoId) async {
  final userId = ref.watch(authProvider.select((state) => state.user?.id));
  if (userId == null) {
    throw const ApiException(
      code: 'UNAUTHORIZED',
      message: 'Silakan masuk terlebih dahulu untuk memutar video.',
      statusCode: 401,
    );
  }
  return ref.watch(homeRepositoryProvider).getPlayback(videoId);
});
