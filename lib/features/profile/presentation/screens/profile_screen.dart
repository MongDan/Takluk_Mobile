import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/takluk_bottom_sheet.dart';
import '../../../../core/widgets/takluk_button.dart';
import '../../../../core/widgets/takluk_toast.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final isSubscribed = user?.isSubscribed ?? false;

    return Scaffold(
      backgroundColor: TaklukColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: TaklukSpacing.bottomSafe),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Text(
                  'Profil Saya',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: TaklukColors.ink,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Mahasiswa Profile Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: TaklukGradients.primary,
                    borderRadius: TaklukRadius.cardBR,
                    boxShadow: [
                      BoxShadow(
                        color: TaklukColors.primary.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: TaklukColors.accent, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'A',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: TaklukColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.fullName ?? 'Aisyah Putri',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'NIM: ${user?.nim ?? '12250312345'}',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.85),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${user?.university.label ?? 'UIN Suska'} • Semester ${user?.semester ?? '3'}',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status Langganan',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isSubscribed
                                    ? 'Aktif (${user?.daysRemaining ?? 0} hari lagi)'
                                    : 'Belum Berlangganan',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isSubscribed ? TaklukColors.accent : Colors.white,
                                ),
                              ),
                            ],
                          ),
                          if (!isSubscribed)
                            GestureDetector(
                              onTap: () => context.push('/checkout'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: TaklukColors.accent,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Text(
                                  'Langganan',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Menu Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _menuItem(
                      icon: LucideIcons.receipt,
                      title: 'Riwayat Transaksi',
                      subtitle: 'Daftar invoice dan pembayaran QRIS',
                      onTap: () => context.push('/transaction-history'),
                    ),
                    _menuItem(
                      icon: LucideIcons.gift,
                      title: 'Kode Referral Saya',
                      subtitle: 'Ajak teman dan dapatkan diskon langganan',
                      onTap: () => context.push('/referral'),
                    ),
                    _menuItem(
                      icon: LucideIcons.smartphone,
                      title: 'Manajemen Perangkat Aktif',
                      subtitle: 'Single Device Binding (1 akun = 1 perangkat)',
                      onTap: () => context.push('/device-management'),
                    ),
                    _menuItem(
                      icon: LucideIcons.helpCircle,
                      title: 'Bantuan & Panam Hub',
                      subtitle: 'Lokasi fisik, jam buka, dan WhatsApp admin',
                      onTap: () => _showHelpBottomSheet(context),
                    ),
                    _menuItem(
                      icon: LucideIcons.refreshCcw,
                      title: 'Reset Data Mode Demo',
                      subtitle: 'Kembalikan status awal akun demo Aisyah',
                      onTap: () {
                        ref.read(authProvider.notifier).resetDemoData();
                        TaklukToast.show(context, 'Data demo berhasil di-reset');
                      },
                    ),
                    const SizedBox(height: 12),
                    _menuItem(
                      icon: LucideIcons.logOut,
                      title: 'Keluar',
                      subtitle: 'Hapus sesi login di perangkat ini',
                      isDestructive: true,
                      onTap: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) {
                          context.go('/auth');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: TaklukColors.surface,
        borderRadius: TaklukRadius.cardBR,
        border: Border.all(color: TaklukColors.line),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDestructive ? TaklukColors.error.withOpacity(0.1) : TaklukColors.tint,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: isDestructive ? TaklukColors.error : TaklukColors.primary,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDestructive ? TaklukColors.error : TaklukColors.ink,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            color: TaklukColors.muted,
          ),
        ),
        trailing: const Icon(LucideIcons.chevronRight, size: 16, color: TaklukColors.muted),
      ),
    );
  }

  void _showHelpBottomSheet(BuildContext context) {
    TaklukBottomSheet.show(
      context: context,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bantuan & Panam Hub',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: TaklukColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '📍 Alamat Offline Hub:\nJl. HR. Soebrantas, Panam (Dekat Kampus UNRI & UIN Suska), Pekanbaru, Riau.',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: TaklukColors.ink, height: 1.5),
            ),
            const SizedBox(height: 10),
            const Text(
              '⏰ Jam Operasional Quiet Study Space:\nSenin - Sabtu: 08.00 - 22.00 WIB\nMinggu: 10.00 - 20.00 WIB',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: TaklukColors.ink, height: 1.5),
            ),
            const SizedBox(height: 10),
            const Text(
              '💬 Layanan WhatsApp Kasir:\n0812-3456-7890 (Info Crash Course, Bootcamp, & pass)',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: TaklukColors.ink, height: 1.5),
            ),
            const SizedBox(height: 20),
            TaklukButton(
              label: 'Tutup',
              variant: ButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

