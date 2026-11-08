import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/domain/mock_data.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/video_row_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class BookmarkScreen extends ConsumerStatefulWidget {
  const BookmarkScreen({super.key});

  @override
  ConsumerState<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends ConsumerState<BookmarkScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final bookmarks = MockData.watchHistories.where((w) => w.isBookmarked).toList();

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
                  Text(
                    'Koleksi materi penting untuk ditonton ulang saat H-1 ujian',
                    style: const TextStyle(
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
              child: bookmarks.isEmpty
                  ? EmptyState(
                      icon: LucideIcons.bookmark,
                      title: 'Belum Ada Video Tersimpan',
                      subtitle: 'Klik ikon bookmark pada video yang ingin kamu tonton ulang nanti',
                      actionLabel: 'Jelajah Materi Sekarang',
                      onAction: () => context.go('/explore'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, TaklukSpacing.bottomSafe),
                      itemCount: bookmarks.length,
                      itemBuilder: (context, index) {
                        final item = bookmarks[index];
                        final video = MockData.videos.firstWhere(
                          (v) => v.id == item.videoId,
                          orElse: () => MockData.videos.first,
                        );

                        return VideoRowCard(
                          title: item.videoTitle ?? video.title,
                          subtitle: item.courseName ?? video.courseName ?? 'Materi',
                          duration: _formatDuration(item.videoDurationSeconds ?? video.durationSeconds),
                          symbol: item.courseSymbol ?? video.courseSymbol ?? '📚',
                          isBookmarked: true,
                          isLocked: !video.isFree && !(user?.isSubscribed ?? false),
                          isFree: video.isFree,
                          onTap: () {
                            if (video.isFree || (user?.isSubscribed ?? false)) {
                              context.push('/player/${video.id}');
                            } else {
                              context.push('/checkout');
                            }
                          },
                          onBookmarkTap: () {
                            setState(() {
                              final idx = MockData.watchHistories.indexWhere((w) => w.id == item.id);
                              if (idx >= 0) {
                                MockData.watchHistories[idx] = MockData.watchHistories[idx].copyWith(isBookmarked: false);
                              }
                            });
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

