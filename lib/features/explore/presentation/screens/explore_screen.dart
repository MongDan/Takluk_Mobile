import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/domain/models/course_model.dart';
import '../../../../core/domain/models/video_model.dart';
import '../../../../core/domain/models/watch_history_model.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/takluk_chip.dart';
import '../../../../core/widgets/takluk_toast.dart';
import '../../../../core/widgets/video_row_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/takluk_shimmer.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/data/progress_repository.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../progress/presentation/providers/progress_provider.dart';
import '../../data/explore_repository.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();
  String? _selectedCourseId;
  VideoCategory? _selectedCategory;
  List<VideoModel> _results = [];
  bool _isLoading = false;
  String? _error;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _performSearch());
  }

  Future<void> _performSearch() async {
    if (!mounted) return;
    final repo = ref.read(exploreRepositoryProvider);
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await repo.searchVideos(
        query: _searchController.text,
        courseId: _selectedCourseId,
        category: _selectedCategory,
      );
      if (!mounted) return;
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _toggleBookmark(VideoModel video, bool currentlyBookmarked) async {
    try {
      await ref
          .read(progressRepositoryProvider)
          .setBookmark(video.id, !currentlyBookmarked);
      ref.invalidate(bookmarksProvider);
      ref.invalidate(continueWatchingProvider);
      if (mounted) {
        TaklukToast.show(
          context,
          currentlyBookmarked ? 'Dihapus dari Bookmark' : 'Disimpan ke Bookmark',
        );
      }
    } on ApiException catch (error) {
      if (mounted) TaklukToast.show(context, error.message, isError: true);
    }
  }

  void _onQueryChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _performSearch);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final courses =
        ref.watch(coursesProvider).valueOrNull ?? const <CourseModel>[];
    final bookmarks =
        ref.watch(bookmarksProvider).valueOrNull ?? const <WatchHistoryModel>[];

    return Scaffold(
      backgroundColor: TaklukColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'Jelajah Materi',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: TaklukColors.ink,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: _onQueryChanged,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: TaklukColors.ink),
                decoration: InputDecoration(
                  hintText: 'Cari materi, dosen, atau kampus (UNRI, UIN)…',
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: TaklukColors.muted.withOpacity(0.6),
                  ),
                  prefixIcon: const Icon(LucideIcons.search, size: 18, color: TaklukColors.muted),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(LucideIcons.x, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch();
                          },
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  TaklukChip(
                    label: 'Semua Matkul',
                    isActive: _selectedCourseId == null,
                    onTap: () {
                      _selectedCourseId = null;
                      _performSearch();
                    },
                  ),
                  const SizedBox(width: 8),
                  ...courses.map((c) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TaklukChip(
                      label: '${c.symbol} ${c.title}',
                      isActive: _selectedCourseId == c.id,
                      onTap: () {
                        _selectedCourseId = _selectedCourseId == c.id ? null : c.id;
                        _performSearch();
                      },
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  TaklukChip(
                    label: 'Semua Kategori',
                    isActive: _selectedCategory == null,
                    onTap: () {
                      _selectedCategory = null;
                      _performSearch();
                    },
                  ),
                  const SizedBox(width: 8),
                  ...VideoCategory.values.map((c) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TaklukChip(
                      label: c.label,
                      isActive: _selectedCategory == c,
                      onTap: () {
                        _selectedCategory = _selectedCategory == c ? null : c;
                        _performSearch();
                      },
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? TaklukShimmer.videoRows(count: 6)
                  : _error != null
                      ? EmptyState(
                          icon: LucideIcons.wifiOff,
                          title: 'Gagal Memuat Materi',
                          subtitle: _error!,
                          actionLabel: 'Coba Lagi',
                          onAction: _performSearch,
                        )
                      : _results.isEmpty
                  ? EmptyState(
                      icon: LucideIcons.searchX,
                      title: 'Materi Tidak Ditemukan',
                      subtitle: 'Coba ganti kata kunci atau reset filter mata kuliah di atas',
                      actionLabel: 'Reset Pencarian',
                      onAction: () {
                        setState(() {
                          _searchController.clear();
                          _selectedCourseId = null;
                          _selectedCategory = null;
                          _performSearch();
                        });
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, TaklukSpacing.bottomSafe),
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final video = _results[index];
                        final isBookmarked = bookmarks.any((w) => w.videoId == video.id);
                        return VideoRowCard(
                          title: video.title,
                          subtitle: '${video.courseName} • ${video.category.label}',
                          duration: video.formattedDuration,
                          symbol: video.courseSymbol ?? '',
                          isLocked: !video.isFree && !(user?.isSubscribed ?? false),
                          isFree: video.isFree,
                          isBookmarked: isBookmarked,
                          onTap: () {
                            if (video.isFree || (user?.isSubscribed ?? false)) {
                              context.push('/player/${video.id}');
                            } else {
                              context.push('/checkout');
                            }
                          },
                          onBookmarkTap: () =>
                              _toggleBookmark(video, isBookmarked),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

