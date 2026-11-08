import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/enums.dart';
import '../../../core/domain/models/transaction_model.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) => PaymentRepository());

class PaymentRepository {
  final List<TransactionModel> _transactions = [];

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);

  VoucherModel validateVoucher(String code) {
    final clean = code.toUpperCase().trim();
    if (AppConstants.vouchers.containsKey(clean)) {
      final discount = AppConstants.vouchers[clean]!;
      return VoucherModel(
        code: clean,
        discountAmount: discount,
        isValid: true,
        message: 'Voucher berhasil digunakan! Hemat Rp${_formatRupiah(discount)}',
      );
    }
    return const VoucherModel(
      code: '',
      discountAmount: 0,
      isValid: false,
      message: 'Kode voucher tidak valid atau sudah habis',
    );
  }

  Future<TransactionModel> createQrisTransaction({
    required String userId,
    String? voucherCode,
    required int discountAmount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final base = AppConstants.subscriptionPrice;
    final finalAmount = (base - discountAmount).clamp(0, base);
    final txId = 'tx-${DateTime.now().millisecondsSinceEpoch}';
    final invoice = 'INV-TKL-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().millisecond}';

    final tx = TransactionModel(
      id: txId,
      invoiceNumber: invoice,
      userId: userId,
      voucherCode: voucherCode,
      baseAmount: base,
      discountAmount: discountAmount,
      finalAmount: finalAmount,
      paymentStatus: PaymentStatus.PENDING,
      qrisString: '00020101021226590014ID.CO.QRIS.WWW0118936000020112345678020812345678520458125303360540${finalAmount}5802ID5913TAKLUK EDTECH6009PEKANBARU61052829362190115${invoice}6304ABCD',
      expiresAt: DateTime.now().add(const Duration(minutes: AppConstants.qrisTimerMinutes)),
      createdAt: DateTime.now(),
    );

    _transactions.insert(0, tx);
    return tx;
  }

  Future<bool> simulatePaymentSuccess(String transactionId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final idx = _transactions.indexWhere((t) => t.id == transactionId);
    if (idx >= 0) {
      _transactions[idx] = TransactionModel(
        id: _transactions[idx].id,
        invoiceNumber: _transactions[idx].invoiceNumber,
        userId: _transactions[idx].userId,
        voucherCode: _transactions[idx].voucherCode,
        baseAmount: _transactions[idx].baseAmount,
        discountAmount: _transactions[idx].discountAmount,
        finalAmount: _transactions[idx].finalAmount,
        paymentStatus: PaymentStatus.SUCCESS,
        qrisString: _transactions[idx].qrisString,
        expiresAt: _transactions[idx].expiresAt,
        paidAt: DateTime.now(),
        createdAt: _transactions[idx].createdAt,
      );
      return true;
    }
    return false;
  }

  String _formatRupiah(int val) {
    return val.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}

