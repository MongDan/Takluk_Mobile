import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

class VideoRowCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String duration;
  final String symbol;
  final bool isLocked;
  final bool isBookmarked;
  final bool isFree;
  final double? progress;
  final VoidCallback onTap;
  final VoidCallback? onBookmarkTap;

  const VideoRowCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.symbol,
    this.isLocked = false,
    this.isBookmarked = false,
    this.isFree = false,
    this.progress,
    required this.onTap,
    this.onBookmarkTap,
  });

  @override
  State<VideoRowCard> createState() => _VideoRowCardState();
}

class _VideoRowCardState extends State<VideoRowCard>
    with TickerProviderStateMixin {
  late AnimationController _tapController;
  late AnimationController _bookmarkController;
  late Animation<double> _bookmarkScale;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _bookmarkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bookmarkScale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(
          tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
        parent: _bookmarkController, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(VideoRowCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBookmarked && !oldWidget.isBookmarked) {
      _bookmarkController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _tapController.dispose();
    _bookmarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _tapController.forward(),
      onTapUp: (_) {
        _tapController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _tapController.reverse(),
      child: ScaleTransition(
        scale:
            Tween<double>(begin: 1.0, end: 0.96).animate(_tapController),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: TaklukColors.surface,
            borderRadius: TaklukRadius.cardBR,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 96,
                height: 64,
                decoration: BoxDecoration(
                  gradient: TaklukGradients.primary,
                  borderRadius: TaklukRadius.thumbnailBR,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (widget.symbol.isEmpty)
                      const Icon(LucideIcons.bookOpen,
                          size: 24, color: Colors.white70)
                    else
                      Text(
                        widget.symbol,
                        style: const TextStyle(
                          fontSize: 28,
                          color: Colors.white70,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    if (widget.isLocked)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: TaklukRadius.thumbnailBR,
                        ),
                        child: const Center(
                          child: Icon(LucideIcons.lock,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    if (widget.isFree)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: TaklukColors.accent,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Text(
                            'GRATIS',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                    if (widget.progress != null)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(12),
                          ),
                          child: LinearProgressIndicator(
                            value: widget.progress!,
                            minHeight: 3,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation(
                                TaklukColors.accent),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: TaklukColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.subtitle} • ${widget.duration}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: TaklukColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              // Bookmark
              if (widget.onBookmarkTap != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    _bookmarkController.forward(from: 0);
                    widget.onBookmarkTap!();
                  },
                  child: AnimatedBuilder(
                    animation: _bookmarkScale,
                    builder: (context, child) => Transform.scale(
                      scale: _bookmarkScale.value,
                      child: Icon(
                        widget.isBookmarked
                            ? LucideIcons.bookmarkMinus
                            : LucideIcons.bookmark,
                        size: 20,
                        color: widget.isBookmarked
                            ? TaklukColors.accent
                            : TaklukColors.muted,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
