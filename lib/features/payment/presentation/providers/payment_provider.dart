import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/models/transaction_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/payment_repository.dart';
export '../../data/payment_repository.dart';

final paymentProvider = Provider<PaymentRepository>((ref) {
  return ref.watch(paymentRepositoryProvider);
});

final currentTransactionProvider = StateProvider<TransactionModel?>((ref) => null);

/// Riwayat transaksi dari `GET /api/payments/history`.
final transactionHistoryProvider =
    FutureProvider<List<TransactionModel>>((ref) async {
  final userId = ref.watch(authProvider.select((state) => state.user?.id));
  if (userId == null) return const [];
  return ref.watch(paymentRepositoryProvider).getHistory();
});


