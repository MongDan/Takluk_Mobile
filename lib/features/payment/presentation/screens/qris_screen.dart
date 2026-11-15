import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/domain/models/transaction_model.dart';
import '../../../../core/widgets/push_page_header.dart';
import '../../../../core/widgets/takluk_button.dart';
import '../../../../core/widgets/takluk_toast.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/payment_provider.dart';

class QrisScreen extends ConsumerStatefulWidget {
  final String transactionId;

  const QrisScreen({super.key, required this.transactionId});

  @override
  ConsumerState<QrisScreen> createState() => _QrisScreenState();
}

class _QrisScreenState extends ConsumerState<QrisScreen> {
  TransactionModel? _transaction;
  Timer? _timer;
  Timer? _pollTimer;
  Duration _timeLeft = const Duration(minutes: 15);
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadTransaction();
    _startTimer();
  }

  Future<void> _loadTransaction() async {
    final current = ref.read(currentTransactionProvider);
    if (current != null && current.invoiceNumber == widget.transactionId) {
      _transaction = current;
    } else {
      try {
        final status = await ref
            .read(paymentRepositoryProvider)
            .checkStatus(widget.transactionId);
        _transaction = TransactionModel(
          id: status.invoiceNumber,
          invoiceNumber: status.invoiceNumber,
          finalAmount: status.finalAmount,
          paymentStatus: status.paymentStatus,
          expiresAt: status.expiresAt ??
              DateTime.now().add(const Duration(minutes: 15)),
          createdAt: DateTime.now(),
        );
      } on ApiException {
        _transaction = null;
      }
    }

    if (_transaction != null) {
      final diff = _transaction!.expiresAt.difference(DateTime.now());
      _timeLeft = diff.isNegative ? Duration.zero : diff;
    }
    if (mounted) setState(() {});
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          if (_timeLeft.inSeconds > 0) {
            _timeLeft -= const Duration(seconds: 1);
          } else {
            _timer?.cancel();
          }
        });
      }
    });

    // Polling ringan status invoice ke backend (mis. webhook Midtrans masuk).
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _pollStatus());
  }

  Future<void> _pollStatus() async {
    final tx = _transaction;
    if (tx == null || _isProcessing) return;

    try {
      final status =
          await ref.read(paymentRepositoryProvider).checkStatus(tx.invoiceNumber);
      if (!mounted) return;

      if (status.isPaid) {
        _timer?.cancel();
        _pollTimer?.cancel();
        await ref.read(authProvider.notifier).refreshProfile();
        if (mounted) context.go('/payment-success');
      } else if (status.paymentStatus == PaymentStatus.EXPIRED) {
        _timer?.cancel();
        setState(() => _timeLeft = Duration.zero);
      }
    } catch (_) {
      // Abaikan error polling; timer akan mencoba lagi.
    }
  }

  Future<void> _handlePaymentSuccess() async {
    final tx = _transaction;
    if (tx == null) {
      TaklukToast.show(context, 'Transaksi tidak ditemukan', isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final repo = ref.read(paymentRepositoryProvider);
      await repo.simulatePaymentSuccess(
        invoiceNumber: tx.invoiceNumber,
        grossAmount: tx.finalAmount,
      );
      final status = await repo.checkStatus(tx.invoiceNumber);

      if (!mounted) return;

      if (status.isPaid) {
        _timer?.cancel();
        _pollTimer?.cancel();
        await ref.read(authProvider.notifier).refreshProfile();
        if (!mounted) return;
        setState(() => _isProcessing = false);
        context.go('/payment-success');
        return;
      }

      setState(() => _isProcessing = false);
      TaklukToast.show(
        context,
        'Pembayaran belum tercatat. Coba cek status lagi sebentar.',
        isError: true,
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      TaklukToast.show(context, error.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      TaklukToast.show(context, 'Gagal memverifikasi transaksi', isError: true);
    }
  }

  String _formatRupiah(int val) {
    return val.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = _timeLeft.inMinutes;
    final s = _timeLeft.inSeconds % 60;
    final isExpired = _timeLeft.inSeconds <= 0;

    return Scaffold(
      backgroundColor: TaklukColors.bg,
      appBar: const PushPageHeader(title: 'Pembayaran QRIS'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Column(
          children: [
            // Timer Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isExpired ? TaklukColors.error.withOpacity(0.1) : TaklukColors.tintWarm,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: isExpired ? TaklukColors.error : TaklukColors.accent.withOpacity(0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.clock,
                    size: 16,
                    color: isExpired ? TaklukColors.error : TaklukColors.accent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isExpired
                        ? 'Waktu Pembayaran Habis'
                        : 'Selesaikan dalam ${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isExpired ? TaklukColors.error : TaklukColors.ink,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // QRIS Render Box
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: TaklukColors.surface,
                borderRadius: TaklukRadius.cardBR,
                border: Border.all(color: TaklukColors.line),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: TaklukColors.tint,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'QRIS Standar Nasional',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: TaklukColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_transaction?.qrisString != null && !isExpired)
                    QrImageView(
                      data: _transaction!.qrisString!,
                      version: QrVersions.auto,
                      size: 220,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: TaklukColors.ink,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: TaklukColors.ink,
                      ),
                    )
                  else
                    Container(
                      width: 220,
                      height: 220,
                      color: TaklukColors.tint,
                      child: const Center(
                        child: Text(
                          'QR Code Kedaluwarsa',
                          style: TextStyle(fontFamily: 'Poppins', color: TaklukColors.muted),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'Total Tagihan: Rp${_formatRupiah(_transaction?.finalAmount ?? 25000)}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: TaklukColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No. Invoice: ${_transaction?.invoiceNumber ?? '-'}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: TaklukColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Payment Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TaklukColors.surface,
                borderRadius: TaklukRadius.cardBR,
                border: Border.all(color: TaklukColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cara Pembayaran:',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: TaklukColors.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _stepRow('1', 'Buka aplikasi e-Wallet (GoPay, OVO, DANA) atau M-Banking kamu'),
                  _stepRow('2', 'Pilih menu Scan / Bayar QRIS'),
                  _stepRow('3', 'Arahkan kamera ke kode QR di atas'),
                  _stepRow('4', 'Pastikan nama penerima "TAKLUK EDTECH" dan nominal sesuai'),
                  _stepRow('5', 'Konfirmasi & selesaikan pembayaran'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Simulation Button (for Demo & Testing)
            TaklukButton(
              label: 'Simulasi Bayar Lunas (Webhook)',
              icon: LucideIcons.checkCircle2,
              isLoading: _isProcessing,
              onPressed: isExpired || _isProcessing ? null : _handlePaymentSuccess,
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepRow(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: TaklukColors.tint,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                num,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: TaklukColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: TaklukColors.muted,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

