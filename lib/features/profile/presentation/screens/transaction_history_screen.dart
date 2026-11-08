import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/push_page_header.dart';
import '../../../payment/data/payment_repository.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key});

  String _formatRupiah(int val) {
    return val.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(paymentRepositoryProvider);
    final transactions = repo.transactions;

    return Scaffold(
      backgroundColor: TaklukColors.bg,
      appBar: const PushPageHeader(title: 'Riwayat Transaksi'),
      body: transactions.isEmpty
          ? const EmptyState(
              icon: LucideIcons.receipt,
              title: 'Belum Ada Transaksi',
              subtitle: 'Riwayat pembayaran langganan QRIS kamu akan muncul di sini',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final isSuccess = tx.paymentStatus == PaymentStatus.SUCCESS;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TaklukColors.surface,
                    borderRadius: TaklukRadius.cardBR,
                    border: Border.all(color: TaklukColors.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tx.invoiceNumber,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: TaklukColors.ink,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isSuccess
                                  ? TaklukColors.success.withOpacity(0.12)
                                  : TaklukColors.tintWarm,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tx.paymentStatus.label,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSuccess ? TaklukColors.success : TaklukColors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Paket Takluk Pass Mahasiswa (30 Hari)',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: TaklukColors.muted,
                        ),
                      ),
                      if (tx.voucherCode != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Voucher: ${tx.voucherCode} (-Rp${_formatRupiah(tx.discountAmount)})',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: TaklukColors.success,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      const Divider(color: TaklukColors.line),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Dibayar:',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: TaklukColors.muted,
                            ),
                          ),
                          Text(
                            'Rp${_formatRupiah(tx.finalAmount)}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: TaklukColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

