import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/push_page_header.dart';
import '../../../../core/widgets/takluk_button.dart';
import '../../../../core/widgets/takluk_toast.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ReferralScreen extends ConsumerWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final code = user?.referralCode ?? 'AISYAH23';

    return Scaffold(
      backgroundColor: TaklukColors.bg,
      appBar: const PushPageHeader(title: 'Program Referral'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: TaklukColors.tintWarm,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🎁', style: TextStyle(fontSize: 44)),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ajak Teman, Belajar Lebih Hemat!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: TaklukColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bagikan kode referral unikmu kepada teman sekelas di kampus. Dapatkan bonus hari langganan gratis!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: TaklukColors.muted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Referral Code Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TaklukColors.surface,
                borderRadius: TaklukRadius.cardBR,
                border: Border.all(color: TaklukColors.line),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'KODE REFERRAL KAMU',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: TaklukColors.muted,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: code));
                      TaklukToast.show(context, 'Kode $code berhasil disalin!');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: TaklukColors.tint,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: TaklukColors.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            code,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: TaklukColors.primary,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(LucideIcons.copy, size: 18, color: TaklukColors.primary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ketuk untuk menyalin',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: TaklukColors.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Benefit Explanation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TaklukColors.surface,
                borderRadius: TaklukRadius.cardBR,
                border: Border.all(color: TaklukColors.line),
              ),
              child: Column(
                children: [
                  _benefitRow(
                    icon: LucideIcons.tag,
                    title: 'Temanmu Dapat Diskon',
                    desc: 'Teman yang memakai kodemu mendapatkan potongan langsung Rp5.000 saat checkout pertama.',
                  ),
                  const SizedBox(height: 14),
                  _benefitRow(
                    icon: LucideIcons.calendarCheck,
                    title: 'Kamu Dapat +7 Hari Gratis',
                    desc: 'Masa aktif langgananmu otomatis bertambah 7 hari untuk setiap teman yang berhasil berlangganan.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            TaklukButton(
              label: 'Salin & Bagikan ke WhatsApp',
              icon: LucideIcons.share2,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: 'Yuk taklukkan ujian kampus bareng Takluk! Pakai kode referral saya "$code" buat dapat diskon langganan: https://takluk.id'));
                TaklukToast.show(context, 'Pesan referral berhasil disalin ke clipboard');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _benefitRow({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: TaklukColors.tintWarm,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: TaklukColors.accent, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: TaklukColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: TaklukColors.muted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

