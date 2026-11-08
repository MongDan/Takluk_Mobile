import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/takluk_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _slides = const [
    _SlideData(
      icon: '🎓',
      title: 'Belajar Dari Kakak Tingkat Terbaik',
      description:
          'Video micro-learning 5-10 menit dari asisten lab dan mahasiswa IPK tinggi kampusmu sendiri (UNRI, UIN Suska, PCR, UIR).',
      color: TaklukColors.primary,
    ),
    _SlideData(
      icon: '📝',
      title: 'Bedah Soal UTS/UAS Lokal',
      description:
          'Pembahasan soal ujian nyata dari dosen kampus lokal dengan cara pengerjaan cepat dan langkah terstruktur.',
      color: TaklukColors.accent,
    ),
    _SlideData(
      icon: '🔒',
      title: 'Aman, Cepat & Terlindungi',
      description:
          'Konten video dilindungi teknologi antipembajakan. Pembayaran instan QRIS dan akses cepat maksimal 3 langkah.',
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
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: TextButton(
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
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: slide.color.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              slide.icon,
                              style: const TextStyle(fontSize: 54),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
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
                        const SizedBox(height: 14),
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
                      ],
                    ),
                  );
                },
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
                    label: _currentPage == _slides.length - 1 ? 'Mulai Sekarang' : 'Lanjut',
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

class _SlideData {
  final String icon;
  final String title;
  final String description;
  final Color color;

  const _SlideData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

