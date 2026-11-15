import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/domain/models/transaction_model.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/push_page_header.dart';
import '../../../../core/widgets/takluk_button.dart';
import '../../../../core/widgets/takluk_toast.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/payment_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _voucherController = TextEditingController();
  VoucherModel? _appliedVoucher;
  String? _voucherError;
  bool _isLoading = false;

  void _applyVoucher(String code) {
    final clean = code.trim().toUpperCase();
    if (clean.isEmpty) return;

    // Backend memvalidasi kuota & nominal voucher saat invoice dibuat.
    setState(() {
      _appliedVoucher = VoucherModel(
        code: clean,
        message: 'Voucher akan divalidasi oleh server saat membuat tagihan.',
      );
      _voucherError = null;
      _voucherController.text = clean;
    });
    TaklukToast.show(
      context,
      'Voucher $clean akan divalidasi saat tagihan dibuat',
    );
  }

  void _removeVoucher() {
    setState(() {
      _appliedVoucher = null;
      _voucherController.clear();
      _voucherError = null;
    });
  }

  Future<void> _proceedToQris() async {
    final user = ref.read(authProvider).user;
    if (user == null) {
      TaklukToast.show(context, 'Silakan masuk terlebih dahulu', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final tx = await ref.read(paymentRepositoryProvider).createQris(
            voucherCode: _appliedVoucher?.code,
          );

      ref.read(currentTransactionProvider.notifier).state = tx;
      ref.invalidate(transactionHistoryProvider);

      if (mounted) {
        setState(() => _isLoading = false);
        context.push('/qris/${tx.invoiceNumber}');
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (error.code == 'VOUCHER_INVALID' ||
            error.code == 'VOUCHER_QUOTA_EXCEEDED') {
          _appliedVoucher = null;
          _voucherError = error.message;
        }
      });
      TaklukToast.show(context, error.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      TaklukToast.show(context, 'Gagal membuat tagihan QRIS', isError: true);
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
    _voucherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final basePrice = AppConstants.subscriptionPrice;

    return Scaffold(
      backgroundColor: TaklukColors.bg,
      appBar: const PushPageHeader(title: 'Ringkasan Langganan'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan Card
            Container(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: TaklukColors.accent,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Text(
                          'Paket Bulanan',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Text(
                        'Akses 30 Hari',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Takluk Pass Mahasiswa',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _planFeature('Akses ke semua video konsep & bedah soal'),
                  _planFeature('Bank arsip soal UTS/UAS kampus lokal'),
                  _planFeature('Kuis latihan interaktif & pembahasan lengkap'),
                  _planFeature('Catatan & ringkasan rumus digital'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Voucher Input Section
            const Text(
              'Punya Kode Voucher?',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: TaklukColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _voucherController,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: TaklukColors.ink,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Contoh: PANAM10',
                      errorText: _voucherError,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                if (_appliedVoucher == null)
                  GestureDetector(
                    onTap: () => _applyVoucher(_voucherController.text),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: TaklukColors.primary,
                        borderRadius: TaklukRadius.cardBR,
                      ),
                      child: const Center(
                        child: Text(
                          'Terapkan',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: _removeVoucher,
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: TaklukColors.error.withOpacity(0.1),
                        borderRadius: TaklukRadius.cardBR,
                        border: Border.all(color: TaklukColors.error),
                      ),
                      child: const Center(
                        child: Text(
                          'Hapus',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: TaklukColors.error,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Promo Voucher Suggestions
            Wrap(
              spacing: 8,
              children: [
                _promoChip('PANAM10', 'Diskon Rp10.000'),
                _promoChip('UINSUSKA', 'Diskon Rp5.000'),
              ],
            ),
            const SizedBox(height: 24),

            // Price Details Breakdown
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: TaklukColors.surface,
                borderRadius: TaklukRadius.cardBR,
                border: Border.all(color: TaklukColors.line),
              ),
              child: Column(
                children: [
                  _priceRow('Harga Normal', 'Rp${_formatRupiah(basePrice)}'),
                  if (_appliedVoucher != null) ...[
                    const SizedBox(height: 10),
                    _priceRow(
                      'Voucher ${_appliedVoucher!.code}',
                      'Divalidasi server',
                      isDiscount: true,
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Divider(color: TaklukColors.line),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Pembayaran',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: TaklukColors.ink,
                        ),
                      ),
                      Text(
                        'Rp${_formatRupiah(basePrice)}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: TaklukColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pay Button
            TaklukButton(
              label: 'Bayar dengan QRIS Instan',
              icon: LucideIcons.qrCode,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _proceedToQris,
            ),
            const SizedBox(height: 12),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(LucideIcons.shieldCheck, size: 14, color: TaklukColors.success),
                  SizedBox(width: 6),
                  Text(
                    'Didukung semua e-Wallet & M-Banking (QRIS)',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: TaklukColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _planFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(LucideIcons.check, size: 16, color: TaklukColors.accent),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _promoChip(String code, String benefit) {
    final isSelected = _appliedVoucher?.code == code;
    return GestureDetector(
      onTap: () => _applyVoucher(code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? TaklukColors.tintWarm : TaklukColors.tint,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? TaklukColors.accent : TaklukColors.line,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.tag, size: 12, color: TaklukColors.primary),
            const SizedBox(width: 6),
            Text(
              '$code • $benefit',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? TaklukColors.accent : TaklukColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: TaklukColors.muted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDiscount ? TaklukColors.success : TaklukColors.ink,
          ),
        ),
      ],
    );
  }
}

