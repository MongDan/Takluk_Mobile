import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

/// Komponen Shimmer Skeleton Loading dengan palet Takluk.
class TaklukShimmer extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const TaklukShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? const Color(0xFFE9E5F3),
      highlightColor: highlightColor ?? const Color(0xFFFBFBFE),
      child: child,
    );
  }

  /// Skeleton kotak atau lingkaran dengan radius sudut.
  static Widget box({
    required double width,
    required double height,
    double borderRadius = 12,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  /// Skeleton kartu horizontal mata kuliah (Home Screen).
  static Widget courseCards({int count = 3}) {
    return TaklukShimmer(
      child: SizedBox(
        height: 124,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: count,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, __) => Container(
            width: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: TaklukRadius.cardBR,
            ),
          ),
        ),
      ),
    );
  }

  /// Skeleton daftar baris video (Home, Explore, Bookmark).
  static Widget videoRows({int count = 4}) {
    return TaklukShimmer(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => Container(
          height: 84,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: TaklukRadius.cardBR,
          ),
        ),
      ),
    );
  }

  /// Skeleton kartu banner / countdown / hub info.
  static Widget card({
    double height = 120,
    double borderRadius = 16,
    EdgeInsetsGeometry margin = const EdgeInsets.symmetric(horizontal: 20),
  }) {
    return TaklukShimmer(
      child: Container(
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

