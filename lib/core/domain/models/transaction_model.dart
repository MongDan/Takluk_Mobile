import '../../constants/enums.dart';
import '../../network/json_utils.dart';

class TransactionModel {
  final String id;
  final String invoiceNumber;
  final String userId;
  final String? voucherCode;
  final int baseAmount;
  final int discountAmount;
  final int finalAmount;
  final PaymentStatus paymentStatus;
  final String? externalPgId;
  final String? qrisString;
  final DateTime expiresAt;
  final DateTime? paidAt;
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.invoiceNumber,
    this.userId = '',
    this.voucherCode,
    this.baseAmount = 25000,
    this.discountAmount = 0,
    required this.finalAmount,
    this.paymentStatus = PaymentStatus.PENDING,
    this.externalPgId,
    this.qrisString,
    required this.expiresAt,
    this.paidAt,
    required this.createdAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Duration get timeRemaining {
    final diff = expiresAt.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Dipakai untuk respons `POST /api/payments/qris` maupun
  /// `GET /api/payments/history`.
  factory TransactionModel.fromJson(
    Map<String, dynamic> json, {
    String userIdFallback = '',
  }) {
    final invoiceNumber = pickString(json, ['invoice_number', 'invoiceNumber']);
    return TransactionModel(
      id: pickString(json, ['id'], fallback: invoiceNumber),
      invoiceNumber: invoiceNumber,
      userId: pickString(json, ['user_id', 'userId'], fallback: userIdFallback),
      voucherCode: pickStringOrNull(json, ['voucher_code', 'voucherCode']),
      baseAmount: pickInt(json, ['base_amount', 'baseAmount'], fallback: 25000),
      discountAmount: pickInt(json, ['discount_amount', 'discountAmount']),
      finalAmount: pickInt(json, ['final_amount', 'finalAmount']),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.value == pickString(json, ['payment_status', 'paymentStatus']),
        orElse: () => PaymentStatus.PENDING,
      ),
      externalPgId: pickStringOrNull(json, ['external_pg_id', 'externalPgId']),
      qrisString: pickStringOrNull(json, ['qris_string', 'qrisString']),
      expiresAt: pickDate(json, ['expires_at', 'expiresAt']) ??
          DateTime.now().add(const Duration(minutes: 15)),
      paidAt: pickDate(json, ['paid_at', 'paidAt']),
      createdAt: pickDate(json, ['created_at', 'createdAt']) ?? DateTime.now(),
    );
  }

  TransactionModel copyWith({
    PaymentStatus? paymentStatus,
    DateTime? paidAt,
  }) {
    return TransactionModel(
      id: id,
      invoiceNumber: invoiceNumber,
      userId: userId,
      voucherCode: voucherCode,
      baseAmount: baseAmount,
      discountAmount: discountAmount,
      finalAmount: finalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      externalPgId: externalPgId,
      qrisString: qrisString,
      expiresAt: expiresAt,
      paidAt: paidAt ?? this.paidAt,
      createdAt: createdAt,
    );
  }
}

class VoucherModel {
  final String code;
  final String? message;
  final bool isValid;

  const VoucherModel({
    required this.code,
    this.message,
    this.isValid = true,
  });
}

