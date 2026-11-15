import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/takluk_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class PaymentSuccessScreen extends ConsumerStatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  ConsumerState<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends ConsumerState<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _checkAnimController;
  late Animation<double> _checkScaleAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();

    _checkAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _checkScaleAnimation = CurvedAnimation(
      parent: _checkAnimController,
      curve: Curves.elasticOut,
    );
    _checkAnimController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _checkAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: TaklukColors.bg,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Confetti blaster
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              TaklukColors.primary,
              TaklukColors.accent,
              TaklukColors.success,
              Color(0xFF6B47C9),
            ],
            numberOfParticles: 30,
            gravity: 0.15,
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Check Circle
                    ScaleTransition(
                      scale: _checkScaleAnimation,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: TaklukColors.success,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: TaklukColors.success.withOpacity(0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            LucideIcons.check,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    const Text(
                      'Pembayaran Berhasil!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: TaklukColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selamat, ${user?.fullName ?? 'Mahasiswa'}! Akun kamu kini berstatus Pelanggan Aktif selama 30 hari ke depan.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: TaklukColors.muted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Active Subscription Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: TaklukColors.surface,
                        borderRadius: TaklukRadius.cardBR,
                        border: Border.all(color: TaklukColors.line),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: const [
                              Icon(LucideIcons.sparkles, color: TaklukColors.accent, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Akses Materi Telah Terbuka',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: TaklukColors.ink,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _benefitRow('Semua modul video & bedah soal dapat ditonton'),
                          _benefitRow('Bank soal UTS & UAS dapat diakses lengkap'),
                          _benefitRow('Kuis interaktif tanpa batas'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    TaklukButton(
                      label: 'Mulai Belajar Sekarang →',
                      onPressed: () => context.go('/home'),
                    ),
                    const SizedBox(height: 12),
                    TaklukButton(
                      label: 'Lihat Riwayat Transaksi',
                      variant: ButtonVariant.secondary,
                      onPressed: () => context.push('/transaction-history'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _benefitRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(LucideIcons.checkCheck, size: 16, color: TaklukColors.success),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: TaklukColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

