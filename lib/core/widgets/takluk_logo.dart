import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../theme/app_theme.dart';

/// Logo Takluk yang dipakai konsisten di splash, pengenalan, dan halaman login.
///
/// Sumber gambar: [AppConstants.splashLogoAsset] (assets/images/splash_logo.png).
/// Bila file belum tersedia, widget otomatis memakai logo vektor bawaan
/// sehingga aplikasi tetap berjalan.
class TaklukLogo extends StatelessWidget {
  final double size;
  final double radius;
  final bool showShadow;

  const TaklukLogo({
    super.key,
    this.size = 84,
    this.radius = 22,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final logo = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        AppConstants.splashLogoAsset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) =>
            _FallbackLogo(size: size, radius: radius),
      ),
    );

    if (!showShadow) return logo;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: TaklukColors.primary.withOpacity(0.25),
            blurRadius: size * 0.24,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: logo,
    );
  }
}

/// Logo vektor cadangan bila aset gambar belum tersedia.
class _FallbackLogo extends StatelessWidget {
  final double size;
  final double radius;

  const _FallbackLogo({required this.size, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: TaklukGradients.primary,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, color: TaklukColors.accent, size: size * 0.33),
            SizedBox(width: size * 0.05),
            Container(
              padding: EdgeInsets.all(size * 0.05),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: TaklukColors.primary,
                size: size * 0.19,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
