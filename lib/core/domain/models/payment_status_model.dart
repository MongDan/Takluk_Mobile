import '../../constants/enums.dart';
import '../../network/json_utils.dart';

/// Respons `GET /api/payments/:invoice_number/status`.
class PaymentStatusModel {
  final String invoiceNumber;
  final PaymentStatus paymentStatus;
  final bool isPaid;
  final DateTime? paidAt;
  final int finalAmount;
  final DateTime? expiresAt;
  final DateTime? subscriptionValidUntil;

  const PaymentStatusModel({
    required this.invoiceNumber,
    required this.paymentStatus,
    required this.isPaid,
    this.paidAt,
    required this.finalAmount,
    this.expiresAt,
    this.subscriptionValidUntil,
  });

  factory PaymentStatusModel.fromJson(Map<String, dynamic> json) {
    return PaymentStatusModel(
      invoiceNumber: pickString(json, ['invoice_number', 'invoiceNumber']),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.value == pickString(json, ['payment_status', 'paymentStatus']),
        orElse: () => PaymentStatus.PENDING,
      ),
      isPaid: pickBool(json, ['is_paid', 'isPaid']),
      paidAt: pickDate(json, ['paid_at', 'paidAt']),
      finalAmount: pickInt(json, ['final_amount', 'finalAmount']),
      expiresAt: pickDate(json, ['expires_at', 'expiresAt']),
      subscriptionValidUntil: pickDate(
        json,
        ['subscription_valid_until', 'subscriptionValidUntil'],
      ),
    );
  }
}
