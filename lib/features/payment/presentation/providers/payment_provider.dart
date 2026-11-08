import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/models/transaction_model.dart';
import '../../data/payment_repository.dart';
export '../../data/payment_repository.dart';

final paymentProvider = Provider<PaymentRepository>((ref) {
  return ref.read(paymentRepositoryProvider);
});

final currentTransactionProvider = StateProvider<TransactionModel?>((ref) => null);

