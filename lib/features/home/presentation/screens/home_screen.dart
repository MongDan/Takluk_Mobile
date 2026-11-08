import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/domain/mock_data.dart';
import '../../../../core/widgets/takluk_toast.dart';
import '../../../../core/widgets/video_row_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/home_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _countdownTimer;
  Duration _countdown = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _updateCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  void _updateCountdown() {
    final diff = MockData.nextExamDate.difference(DateTime.now());
    if (mounted) setState(() => _countdown = diff.isNegative ? Duration.zero : diff);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final courses = ref.watch(coursesProvider);
    final popularVideos = ref.watch(popularVideosProvider);
    final continueWatching = ref.watch(continueWatchingProvider);

    return Scaffold(
      backgroundColor: TaklukColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: TaklukSpacing.bottomSafe),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, ${user?.fullName.split(' ').first ?? 'Mahasiswa'} 👋',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: TaklukColors.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${user?.university.label ?? 'Kampus'} • Semester ${user?.semester ?? '-'}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: TaklukColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/profile'),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: TaklukGradients.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: TaklukColors.primary.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'A',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () => context.go('/explore'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: TaklukColors.surface,
                      borderRadius: TaklukRadius.cardBR,
                      border: Border.all(color: TaklukColors.line),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.search, size: 18, color: TaklukColors.muted),
                        const SizedBox(width: 12),
                        Text(
                          'Cari materi Kalkulus, Statistika, UTS…',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: TaklukColors.muted.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSubscriptionCard(user),
              ),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildCountdownWidget(),
              ),
              const SizedBox(height: 20),

              if (continueWatching.isNotEmpty) ...[
                _sectionHeader('Lanjut Menonton', icon: LucideIcons.playCircle),
                const SizedBox(height: 10),
                ...continueWatching.map((wh) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: VideoRowCard(
                    title: wh.videoTitle ?? 'Video Materi',
                    subtitle: wh.courseName ?? '',
                    duration: _formatDuration(wh.videoDurationSeconds ?? 0),
                    symbol: wh.courseSymbol ?? '∫',
                    progress: wh.progress,
                    onTap: () => context.push('/player/${wh.videoId}'),
                  ),
                )),
                const SizedBox(height: 20),
              ],

              _sectionHeader('Katalog Mata Kuliah Momok', icon: LucideIcons.bookOpen),
              const SizedBox(height: 12),
              courses.when(
                data: (list) => SizedBox(
                  height: 136,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => _CourseCard(
                      course: list[i],
                      onTap: () => context.go('/explore'),
                    ),
                  ),
                ),
                loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
                error: (e, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

              _sectionHeader('Rekomendasi Bedah Soal Populer 🔥', icon: LucideIcons.flame),
              const SizedBox(height: 10),
              popularVideos.when(
                data: (list) => Column(
                  children: list.map((v) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: VideoRowCard(
                      title: v.title,
                      subtitle: '${v.courseName} • ${v.category.label}',
                      duration: v.formattedDuration,
                      symbol: v.courseSymbol ?? '📚',
                      isLocked: !v.isFree && !(user?.isSubscribed ?? false),
                      isFree: v.isFree,
                      onTap: () {
                        if (v.isFree || (user?.isSubscribed ?? false)) {
                          context.push('/player/${v.id}');
                        } else {
                          context.push('/checkout');
                        }
                      },
                    ),
                  )).toList(),
                ),
                loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
                error: (e, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildReferralBanner(),
              ),
              const SizedBox(height: 24),

              _sectionHeader('Layanan Offline Panam Academy Hub 🏫'),
              const SizedBox(height: 12),
              SizedBox(
                height: 148,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _HubInfoCard(
                      title: 'Crash Course H-7 Ujian',
                      subtitle: 'Bimbingan intensif 3 hari sebelum ujian',
                      price: 'Rp150.000/paket',
                      icon: '📖',
                      onTap: () => TaklukToast.show(context, 'Pendaftaran Crash Course dapat melalui Admin Kasir Panam Hub'),
                    ),
                    const SizedBox(width: 12),
                    _HubInfoCard(
                      title: 'Bootcamp Olah Data Skripsi',
                      subtitle: 'Bimbingan SPSS & SEM-PLS sampai lulus',
                      price: 'Rp450.000/peserta',
                      icon: '📊',
                      onTap: () => TaklukToast.show(context, 'Pendaftaran Bootcamp Olah Data dapat melalui Admin Kasir Panam Hub'),
                    ),
                    const SizedBox(width: 12),
                    _HubInfoCard(
                      title: 'Quiet Study Space',
                      subtitle: 'Ruang belajar ber-AC, hening & WiFi cepat',
                      price: 'Pass Harian Rp20.000',
                      icon: '🤫',
                      onTap: () => TaklukToast.show(context, 'Tiket harian Quiet Study Space tersedia langsung di lokasi Panam Hub'),
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

  Widget _buildSubscriptionCard(user) {
    final isSubscribed = user?.isSubscribed ?? false;
    return GestureDetector(
      onTap: () {
        if (!isSubscribed) context.push('/checkout');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: TaklukGradients.primary,
          borderRadius: TaklukRadius.heroBR,
          boxShadow: [
            BoxShadow(
              color: TaklukColors.primary.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSubscribed ? TaklukColors.accent : Colors.white24,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSubscribed ? LucideIcons.sparkles : LucideIcons.lock,
                        size: 13,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isSubscribed ? 'Pelanggan Aktif' : 'Akses Terbatas',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isSubscribed)
                  const Text(
                    'Rp49.000/bln',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: TaklukColors.accent,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              isSubscribed
                  ? 'Akses penuh ke semua materi & bedah soal'
                  : 'Buka Semua Modul & Bedah Soal Kampus',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isSubscribed
                  ? 'Masa aktif langganan tersisa ${user?.daysRemaining ?? 0} hari lagi'
                  : 'Pelajari trik cepat lulus ujian dari asisten lab terbaik',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
            if (!isSubscribed) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: TaklukColors.accent,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Berlangganan Sekarang',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(LucideIcons.arrowRight, size: 14, color: Colors.white),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownWidget() {
    final days = _countdown.inDays;
    final hours = _countdown.inHours % 24;
    final minutes = _countdown.inMinutes % 60;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TaklukColors.tintWarm,
        borderRadius: TaklukRadius.cardBR,
        border: Border.all(color: TaklukColors.accent.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: TaklukColors.accent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.clock, color: TaklukColors.accent, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hitung Mundur ${MockData.nextExamLabel}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: TaklukColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Siapkan pemahaman konsepmu dari sekarang!',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: TaklukColors.muted,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _CountdownBox(value: '$days', label: 'Hari'),
                    const SizedBox(width: 8),
                    _CountdownBox(value: '${hours.toString().padLeft(2, '0')}', label: 'Jam'),
                    const SizedBox(width: 8),
                    _CountdownBox(value: '${minutes.toString().padLeft(2, '0')}', label: 'Menit'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralBanner() {
    final user = ref.read(authProvider).user;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TaklukColors.surface,
        borderRadius: TaklukRadius.cardBR,
        border: Border.all(color: TaklukColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: TaklukColors.tint,
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.gift, color: TaklukColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ajak Teman, Raih Diskon!',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: TaklukColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Kode kamu: ${user?.referralCode ?? 'AISYAH23'}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: TaklukColors.primary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/referral'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: TaklukColors.primary,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Text(
                'Buka',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: TaklukColors.primary),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: TaklukColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}

class _CountdownBox extends StatelessWidget {
  final String value;
  final String label;
  const _CountdownBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: TaklukColors.accent.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: TaklukColors.ink,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, color: TaklukColors.muted),
        ),
      ],
    );
  }
}

class _CourseCard extends StatefulWidget {
  final dynamic course;
  final VoidCallback onTap;
  const _CourseCard({required this.course, required this.onTap});

  @override
  State<_CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<_CourseCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.96).animate(_controller),
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(14),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: TaklukGradients.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    widget.course.symbol,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.course.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: TaklukColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.course.videoCount} Modul Video',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: TaklukColors.muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HubInfoCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String price;
  final String icon;
  final VoidCallback onTap;

  const _HubInfoCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_HubInfoCard> createState() => _HubInfoCardState();
}

class _HubInfoCardState extends State<_HubInfoCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.96).animate(_ctrl),
        child: Container(
          width: 190,
          padding: const EdgeInsets.all(14),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.icon, style: const TextStyle(fontSize: 26)),
                  Text(
                    widget.price,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: TaklukColors.accent,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: TaklukColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: TaklukColors.muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

