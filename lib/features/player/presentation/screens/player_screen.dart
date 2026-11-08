import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/domain/mock_data.dart';
import '../../../../core/domain/models/video_model.dart';
import '../../../../core/domain/models/watch_history_model.dart';
import '../../../../core/security/screen_security.dart';
import '../../../../core/widgets/push_page_header.dart';
import '../../../../core/widgets/takluk_segmented_control.dart';
import '../../../../core/widgets/takluk_toast.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final String videoId;

  const PlayerScreen({super.key, required this.videoId});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen>
    with SingleTickerProviderStateMixin {
  late VideoModel _video;
  bool _isPlaying = true;
  double _currentPositionSec = 0;
  Timer? _playbackTimer;
  Timer? _watermarkTimer;
  Timer? _heartbeatTimer;

  // Watermark position
  double _watermarkX = 0.2;
  double _watermarkY = 0.3;
  final Random _random = Random();

  // Screen protection state
  bool _isScreenCaptured = false;
  StreamSubscription<bool>? _captureSubscription;

  // Selected sub-tab: 0 = Bab, 1 = Catatan Rumus
  int _selectedTabIndex = 0;

  // Bookmark pop animation
  late AnimationController _bookmarkAnimCtrl;
  late Animation<double> _bookmarkScale;

  @override
  void initState() {
    super.initState();
    _video = MockData.videos.firstWhere(
      (v) => v.id == widget.videoId,
      orElse: () => MockData.videos.first,
    );

    // Initialize security
    ScreenSecurity.enableSecureMode();
    _captureSubscription = ScreenSecurity.onScreenCaptureChanged.listen((captured) {
      if (mounted) setState(() => _isScreenCaptured = captured);
    });

    // Check last position from history
    final history = MockData.watchHistories.where((w) => w.videoId == _video.id).firstOrNull;
    if (history != null) {
      _currentPositionSec = history.lastPositionSec.toDouble();
    }

    // Bookmark animation
    _bookmarkAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bookmarkScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _bookmarkAnimCtrl, curve: Curves.easeInOut));

    // Playback loop
    _playbackTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isPlaying && mounted) {
        setState(() {
          if (_currentPositionSec < _video.durationSeconds) {
            _currentPositionSec += 1;
          } else {
            _isPlaying = false;
            _syncProgress(isCompleted: true);
          }
        });
      }
    });

    // Watermark random position timer (every 4 seconds)
    _watermarkTimer = Timer.periodic(const Duration(seconds: AppConstants.watermarkIntervalSec), (_) {
      if (mounted) {
        setState(() {
          _watermarkX = 0.1 + _random.nextDouble() * 0.6;
          _watermarkY = 0.1 + _random.nextDouble() * 0.6;
        });
      }
    });

    // Progress sync heartbeat every 30 seconds
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: AppConstants.progressSyncIntervalSec),
      (_) => _syncProgress(),
    );
  }

  void _syncProgress({bool isCompleted = false}) {
    final user = ref.read(authProvider).user;
    final idx = MockData.watchHistories.indexWhere((w) => w.videoId == _video.id);
    final completed = isCompleted || (_currentPositionSec / _video.durationSeconds >= AppConstants.completionThreshold);

    if (idx >= 0) {
      MockData.watchHistories[idx] = MockData.watchHistories[idx].copyWith(
        lastPositionSec: _currentPositionSec.toInt(),
        totalWatchedSec: MockData.watchHistories[idx].totalWatchedSec + AppConstants.progressSyncIntervalSec,
        isCompleted: completed,
        lastWatchedAt: DateTime.now(),
      );
    } else {
      MockData.watchHistories.add(WatchHistoryModel(
        id: 'wh-${DateTime.now().millisecondsSinceEpoch}',
        userId: user?.id ?? 'usr-demo-001',
        videoId: _video.id,
        lastPositionSec: _currentPositionSec.toInt(),
        totalWatchedSec: _currentPositionSec.toInt(),
        isCompleted: completed,
        lastWatchedAt: DateTime.now(),
        videoTitle: _video.title,
        courseSymbol: _video.courseSymbol,
        videoDurationSeconds: _video.durationSeconds,
        courseName: _video.courseName,
      ));
    }
  }

  void _toggleBookmark() {
    _bookmarkAnimCtrl.forward(from: 0);
    final user = ref.read(authProvider).user;
    final idx = MockData.watchHistories.indexWhere((w) => w.videoId == _video.id);

    if (idx >= 0) {
      final newVal = !MockData.watchHistories[idx].isBookmarked;
      MockData.watchHistories[idx] = MockData.watchHistories[idx].copyWith(isBookmarked: newVal);
      TaklukToast.show(context, newVal ? 'Disimpan ke Bookmark' : 'Dihapus dari Bookmark');
    } else {
      MockData.watchHistories.add(WatchHistoryModel(
        id: 'wh-${DateTime.now().millisecondsSinceEpoch}',
        userId: user?.id ?? 'usr-demo-001',
        videoId: _video.id,
        isBookmarked: true,
        lastWatchedAt: DateTime.now(),
        videoTitle: _video.title,
        courseSymbol: _video.courseSymbol,
        videoDurationSeconds: _video.durationSeconds,
        courseName: _video.courseName,
      ));
      TaklukToast.show(context, 'Disimpan ke Bookmark');
    }
    setState(() {});
  }

  @override
  void dispose() {
    _syncProgress();
    _playbackTimer?.cancel();
    _watermarkTimer?.cancel();
    _heartbeatTimer?.cancel();
    _captureSubscription?.cancel();
    _bookmarkAnimCtrl.dispose();
    ScreenSecurity.disableSecureMode();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final isBookmarked = MockData.watchHistories.any((w) => w.videoId == _video.id && w.isBookmarked);

    return Scaffold(
      backgroundColor: TaklukColors.bg,
      appBar: PushPageHeader(
        title: _video.courseName ?? 'Materi Pembelajaran',
        actions: [
          IconButton(
            icon: Icon(
              _isScreenCaptured ? LucideIcons.shieldAlert : LucideIcons.shieldCheck,
              color: _isScreenCaptured ? TaklukColors.error : TaklukColors.primary,
            ),
            tooltip: 'Simulasi Keamanan Layar',
            onPressed: () {
              setState(() => _isScreenCaptured = !_isScreenCaptured);
              TaklukToast.show(
                context,
                _isScreenCaptured
                    ? '⚠️ Simulasi perekaman layar aktif (layar diblokir)'
                    : '🛡️ Proteksi layar aman (FLAG_SECURE)',
                isError: _isScreenCaptured,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 16:9 Video Player Box
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                // Video Surface
                Container(
                  color: Colors.black,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _video.courseSymbol ?? '∫',
                          style: TextStyle(
                            fontSize: 48,
                            color: Colors.white.withOpacity(0.18),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Streaming HLS Terenkripsi',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // DRM Protection Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.shield, color: TaklukColors.accent, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'Dilindungi',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Dynamic Moving Watermark (Name • NIM • Email)
                Positioned(
                  left: MediaQuery.of(context).size.width * _watermarkX,
                  top: (MediaQuery.of(context).size.width * (9 / 16)) * _watermarkY,
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 600),
                      opacity: 0.35,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${user?.fullName ?? 'Aisyah Putri'} • ${user?.nim ?? '12250312345'} • ${user?.email ?? 'demo@takluk.id'}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Black Screen Block when screen recording detected
                if (_isScreenCaptured)
                  Container(
                    color: Colors.black,
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(LucideIcons.shieldAlert, color: TaklukColors.error, size: 42),
                          SizedBox(height: 12),
                          Text(
                            'Perekaman Layar Terdeteksi & Diblokir',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Konten Takluk dilindungi hak cipta demi menjaga karya tutor.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Player Controls Overlay
                if (!_isScreenCaptured)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(14, 20, 14, 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.85),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Progress Bar
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                              trackHeight: 3,
                              activeTrackColor: TaklukColors.accent,
                              inactiveTrackColor: Colors.white30,
                              thumbColor: TaklukColors.accent,
                            ),
                            child: Slider(
                              value: _currentPositionSec.clamp(0, _video.durationSeconds.toDouble()),
                              min: 0,
                              max: _video.durationSeconds.toDouble(),
                              onChanged: (val) {
                                setState(() => _currentPositionSec = val);
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => setState(() => _isPlaying = !_isPlaying),
                                    child: Icon(
                                      _isPlaying ? LucideIcons.pause : LucideIcons.play,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${_formatTime(_currentPositionSec.toInt())} / ${_formatTime(_video.durationSeconds)}',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '1.0x',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  const Icon(LucideIcons.maximize, color: Colors.white, size: 16),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Video Info & Interactive Actions
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _video.title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: TaklukColors.ink,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _toggleBookmark,
                      child: AnimatedBuilder(
                        animation: _bookmarkScale,
                        builder: (context, child) => Transform.scale(
                          scale: _bookmarkScale.value,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isBookmarked ? TaklukColors.tintWarm : TaklukColors.tint,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isBookmarked ? LucideIcons.bookmarkMinus : LucideIcons.bookmark,
                              size: 20,
                              color: isBookmarked ? TaklukColors.accent : TaklukColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: TaklukColors.tint,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _video.category.label,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: TaklukColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tutor: ${_video.tutorName ?? 'Asisten Lab'}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: TaklukColors.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tabs: Bab vs Catatan/Rumus
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TaklukSegmentedControl(
              segments: const ['Daftar Bab', 'Catatan & Rumus'],
              selectedIndex: _selectedTabIndex,
              onChanged: (i) => setState(() => _selectedTabIndex = i),
            ),
          ),
          const SizedBox(height: 12),

          // Tab content
          Expanded(
            child: _selectedTabIndex == 0 ? _buildChaptersTab() : _buildNotesTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildChaptersTab() {
    if (_video.chapters.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada penanda bab untuk video ini',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: TaklukColors.muted),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _video.chapters.length,
      itemBuilder: (context, index) {
        final chapter = _video.chapters[index];
        final isActive = _currentPositionSec >= chapter.startSecond &&
            (index == _video.chapters.length - 1 ||
                _currentPositionSec < _video.chapters[index + 1].startSecond);

        return GestureDetector(
          onTap: () {
            setState(() {
              _currentPositionSec = chapter.startSecond.toDouble();
              _isPlaying = true;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? TaklukColors.tintWarm : TaklukColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive ? TaklukColors.accent.withOpacity(0.5) : TaklukColors.line,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isActive ? LucideIcons.playCircle : LucideIcons.circle,
                  size: 18,
                  color: isActive ? TaklukColors.accent : TaklukColors.muted,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    chapter.title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? TaklukColors.ink : TaklukColors.ink,
                    ),
                  ),
                ),
                Text(
                  chapter.formattedStart,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? TaklukColors.accent : TaklukColors.muted,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotesTab() {
    final markdown = _video.summaryMarkdown ?? '### Belum ada catatan\nCatatan dan ringkasan rumus akan segera ditambahkan oleh tutor.';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TaklukColors.surface,
          borderRadius: TaklukRadius.cardBR,
          border: Border.all(color: TaklukColors.line),
        ),
        child: MarkdownBody(
          data: markdown,
          styleSheet: MarkdownStyleSheet(
            h1: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: TaklukColors.ink),
            h2: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700, color: TaklukColors.ink),
            h3: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: TaklukColors.ink),
            p: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: TaklukColors.ink, height: 1.5),
            code: const TextStyle(fontFamily: 'monospace', fontSize: 12, backgroundColor: TaklukColors.tint),
          ),
        ),
      ),
    );
  }
}

