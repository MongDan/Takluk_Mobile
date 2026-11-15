import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/takluk_button.dart';
import '../../../../core/widgets/takluk_logo.dart';

/// Halaman pengenalan aplikasi: tampil setelah splash dan sebelum login.
///
/// Tiga fase: apa itu Takluk & manfaatnya, cara belajar, lalu keamanan konten.
/// Semua ikon memakai Lucide (2D minimalis) agar konsisten dengan layar lain.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    _SlideData(
      icon: LucideIcons.graduationCap,
      eyebrow: 'Pengenalan',
      title: 'Apa itu Takluk?',
      description:
          'Takluk (RuangKuliah Hub) adalah platform belajar digital untuk mahasiswa: video micro-learning, bedah soal UTS/UAS, dan bimbingan offline di Panam Hub.',
      points: [
        'Materi dari kakak tingkat & asisten lab kampusmu',
        'Video singkat 5-10 menit, mudah diulang',
        'Belajar dari mana saja lewat HP',
      ],
      color: TaklukColors.primary,
    ),
    _SlideData(
      icon: LucideIcons.target,
      eyebrow: 'Manfaat',
      title: 'Belajar Lebih Terarah',
      description:
          'Fokus pada materi yang benar-benar keluar di ujian. Setiap video disusun sesuai kurikulum kampus lokal (UNRI, UIN Suska, PCR, UIR).',
      points: [
        'Bedah soal UTS/UAS dengan langkah terstruktur',
        'Katalog mata kuliah momok tersusun rapi',
        'Lanjutkan tontonan & simpan video favorit',
      ],
      color: TaklukColors.accent,
    ),
    _SlideData(
      icon: LucideIcons.shieldCheck,
      eyebrow: 'Keamanan',
      title: 'Aman, Cepat & Terlindungi',
      description:
          'Konten video dilindungi teknologi antipembajakan, akun terikat ke perangkatmu, dan pembayaran QRIS selesai dalam hitungan detik.',
      points: [
        'Proteksi konten & watermark identitas',
        'Satu akun untuk satu perangkat aktif',
        'Langganan instan lewat QRIS',
      ],
      color: TaklukColors.success,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TaklukColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  const TaklukLogo(size: 30, radius: 9, showShadow: false),
                  const SizedBox(width: 8),
                  const Text(
                    'Takluk',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: TaklukColors.ink,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go('/auth'),
                    child: const Text(
                      'Lewati',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: TaklukColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _slides.length,
                itemBuilder: (context, index) =>
                    _SlideContent(slide: _slides[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _slides.length,
                    effect: const ExpandingDotsEffect(
                      dotWidth: 8,
                      dotHeight: 8,
                      activeDotColor: TaklukColors.primary,
                      dotColor: TaklukColors.tint,
                      expansionFactor: 3,
                    ),
                  ),
                  const SizedBox(height: 28),
                  TaklukButton(
                    label: _currentPage == _slides.length - 1
                        ? 'Mulai Sekarang'
                        : 'Lanjut',
                    onPressed: () {
                      if (_currentPage < _slides.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
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
    );
  }
}

/// Isi satu fase pengenalan: ikon 2D minimalis, judul, penjelasan, manfaat.
class _SlideContent extends StatelessWidget {
  final _SlideData slide;

  const _SlideContent({required this.slide});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: slide.color.withOpacity(0.10),
                  shape: BoxShape.circle,
                  border: Border.all(color: slide.color.withOpacity(0.20)),
                ),
                child: Center(
                  child: Icon(slide.icon, size: 52, color: slide.color),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                slide.eyebrow.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: slide.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                slide.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: TaklukColors.ink,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                slide.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: TaklukColors.muted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              ...slide.points.map(
                (point) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        LucideIcons.checkCircle2,
                        size: 16,
                        color: slide.color,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          point,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: TaklukColors.ink,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideData {
  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;
  final List<String> points;
  final Color color;

  const _SlideData({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.points,
    required this.color,
  });
}
