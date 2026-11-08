import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _ringController1;
  late AnimationController _ringController2;
  late AnimationController _ringController3;
  late AnimationController _progressController;
  late AnimationController _floatController;
  late Animation<double> _progressAnimation;
  Timer? _delayTimer1;
  Timer? _delayTimer2;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    _ringController1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _ringController2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _delayTimer1 = Timer(const Duration(milliseconds: 400), () {
      if (mounted) _ringController2.repeat();
    });

    _ringController3 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _delayTimer2 = Timer(const Duration(milliseconds: 800), () {
      if (mounted) _ringController3.repeat();
    });

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat(reverse: true);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _progressController.forward();

    _navTimer = Timer(const Duration(milliseconds: 2800), () {
      if (mounted) {
        ref.read(authProvider.notifier).checkAuthStatus().then((_) {
          final auth = ref.read(authProvider);
          if (auth.status == AuthStatus.authenticated) {
            context.go('/home');
          } else {
            context.go('/onboarding');
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _delayTimer1?.cancel();
    _delayTimer2?.cancel();
    _navTimer?.cancel();
    _ringController1.dispose();
    _ringController2.dispose();
    _ringController3.dispose();
    _progressController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TaklukColors.bg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _PulseRing(controller: _ringController1, size: 200),
                  _PulseRing(controller: _ringController2, size: 160),
                  _PulseRing(controller: _ringController3, size: 120),
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      gradient: TaklukGradients.primary,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: TaklukColors.primary.withOpacity(0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.school, color: TaklukColors.accent, size: 28),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.play_arrow_rounded, color: TaklukColors.primary, size: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ...List.generate(4, (i) {
                    return AnimatedBuilder(
                      animation: _floatController,
                      builder: (context, child) {
                        final angle = (i * pi / 2) + (_floatController.value * pi * 0.25);
                        final radius = 90 + sin(_floatController.value * pi) * 8;
                        return Positioned(
                          left: 110 + cos(angle) * radius - 4,
                          top: 110 + sin(angle) * radius - 4,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: i % 2 == 0 ? TaklukColors.primary : TaklukColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Takluk',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: TaklukColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'RuangKuliah Hub',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: TaklukColors.muted,
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _progressAnimation.value,
                          minHeight: 4,
                          backgroundColor: TaklukColors.tint,
                          valueColor: const AlwaysStoppedAnimation(TaklukColors.accent),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Memuat…',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: TaklukColors.muted.withOpacity(0.7),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  final AnimationController controller;
  final double size;

  const _PulseRing({required this.controller, required this.size});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          width: size * (0.6 + controller.value * 0.4),
          height: size * (0.6 + controller.value * 0.4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: TaklukColors.primary.withOpacity(0.3 * (1 - controller.value)),
              width: 2,
            ),
          ),
        );
      },
    );
  }
}

