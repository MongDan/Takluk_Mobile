import '../../constants/enums.dart';

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
    required this.userId,
    this.voucherCode,
    this.baseAmount = 49000,
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

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      invoiceNumber: json['invoice_number'] as String,
      userId: json['user_id'] as String,
      voucherCode: json['voucher_code'] as String?,
      baseAmount: json['base_amount'] as int? ?? 49000,
      discountAmount: json['discount_amount'] as int? ?? 0,
      finalAmount: json['final_amount'] as int,
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.value == json['payment_status'],
        orElse: () => PaymentStatus.PENDING,
      ),
      externalPgId: json['external_pg_id'] as String?,
      qrisString: json['qris_string'] as String?,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class VoucherModel {
  final String code;
  final int discountAmount;
  final bool isValid;
  final String? message;

  const VoucherModel({
    required this.code,
    required this.discountAmount,
    this.isValid = true,
    this.message,
  });
}
