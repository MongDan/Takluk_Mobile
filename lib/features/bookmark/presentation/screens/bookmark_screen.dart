import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/takluk_toast.dart';
import '../../../../core/widgets/video_row_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/data/progress_repository.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../progress/presentation/providers/progress_provider.dart';

class BookmarkScreen extends ConsumerStatefulWidget {
  const BookmarkScreen({super.key});

  @override
  ConsumerState<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends ConsumerState<BookmarkScreen> {
  Future<void> _removeBookmark(String videoId) async {
    try {
      await ref.read(progressRepositoryProvider).setBookmark(videoId, false);
      ref.invalidate(bookmarksProvider);
      ref.invalidate(continueWatchingProvider);
      if (mounted) TaklukToast.show(context, 'Dihapus dari Bookmark');
    } on ApiException catch (error) {
      if (mounted) TaklukToast.show(context, error.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final bookmarksAsync = ref.watch(bookmarksProvider);

    return Scaffold(
      backgroundColor: TaklukColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Video Tersimpan',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: TaklukColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Koleksi materi penting untuk ditonton ulang saat H-1 ujian',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: TaklukColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: bookmarksAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => EmptyState(
                  icon: LucideIcons.wifiOff,
                  title: 'Gagal Memuat Bookmark',
                  subtitle: error.toString(),
                  actionLabel: 'Coba Lagi',
                  onAction: () => ref.invalidate(bookmarksProvider),
                ),
                data: (bookmarks) {
                  if (bookmarks.isEmpty) {
                    return EmptyState(
                      icon: LucideIcons.bookmark,
                      title: 'Belum Ada Video Tersimpan',
                      subtitle:
                          'Klik ikon bookmark pada video yang ingin kamu tonton ulang nanti',
                      actionLabel: 'Jelajah Materi Sekarang',
                      onAction: () => context.go('/explore'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      TaklukSpacing.bottomSafe,
                    ),
                    itemCount: bookmarks.length,
                    itemBuilder: (context, index) {
                      final item = bookmarks[index];
                      final isLocked =
                          !item.isFree && !(user?.isSubscribed ?? false);

                      return VideoRowCard(
                        title: item.videoTitle ?? 'Video Materi',
                        subtitle: item.courseName ?? 'Materi',
                        duration: _formatDuration(
                          item.videoDurationSeconds ?? 0,
                        ),
                        symbol: item.courseSymbol ?? '',
                        isBookmarked: true,
                        isLocked: isLocked,
                        isFree: item.isFree,
                        onTap: () {
                          if (isLocked) {
                            context.push('/checkout');
                          } else {
                            context.push('/player/${item.videoId}');
                          }
                        },
                        onBookmarkTap: () => _removeBookmark(item.videoId),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}


