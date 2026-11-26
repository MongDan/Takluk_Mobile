import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/models/payment_status_model.dart';
import '../../../core/domain/models/transaction_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/json_utils.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(ref.watch(apiClientProvider));
});

class PaymentRepository {
  final ApiClient _api;

  PaymentRepository(this._api);

  /// `POST /api/payments/qris` — buat invoice & Dynamic QRIS Rp25.000.
  /// Voucher divalidasi sepenuhnya oleh backend.
  Future<TransactionModel> createQris({String? voucherCode}) async {
    final data = await _api.post(
      ApiEndpoints.paymentsQris,
      data: {
        if (voucherCode != null && voucherCode.trim().isNotEmpty)
          'voucher_code': voucherCode.trim().toUpperCase(),
      },
    );
    return TransactionModel.fromJson(asJsonMap(data));
  }

  /// `GET /api/payments/history`
  Future<List<TransactionModel>> getHistory() async {
    final data = await _api.get(ApiEndpoints.paymentsHistory);
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((row) => TransactionModel.fromJson(asJsonMap(row)))
        .toList();
  }

  /// `GET /api/payments/:invoice_number/status` — polling ringan.
  Future<PaymentStatusModel> checkStatus(String invoiceNumber) async {
    final data = await _api.get(ApiEndpoints.paymentStatus(invoiceNumber));
    return PaymentStatusModel.fromJson(asJsonMap(data));
  }
}
