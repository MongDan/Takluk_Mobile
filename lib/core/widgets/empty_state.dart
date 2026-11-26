import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_theme.dart';
import 'takluk_button.dart';

/// State kosong / error ringan.
///
/// Bila [useLottie] aktif, akan menampilkan animasi Lottie
/// `assets/lottie/empty_box3.json` di tengah layar (dipakai saat data hasil
/// fetch dari backend benar-benar kosong).
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool useLottie;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.useLottie = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (useLottie)
              SizedBox(
                width: 200,
                height: 200,
                child: Lottie.asset(
                  'assets/lottie/empty_box3.json',
                  repeat: true,
                  animate: true,
                ),
              )
            else ...[
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: TaklukColors.tint,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36, color: TaklukColors.primary),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: TaklukColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: TaklukColors.muted,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              TaklukButton(
                label: actionLabel!,
                onPressed: onAction,
                fullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
