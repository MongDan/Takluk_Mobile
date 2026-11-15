import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/domain/models/hub_service_model.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/takluk_bottom_sheet.dart';
import '../../../../core/widgets/takluk_button.dart';
import '../../../../core/widgets/takluk_input.dart';
import '../../../../core/widgets/takluk_toast.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/hub_repository.dart';

/// Form reservasi layanan fisik Panam Academy Hub
/// (`POST /api/hub/book`).
class HubBookingSheet extends ConsumerStatefulWidget {
  final HubServiceModel service;

  const HubBookingSheet({super.key, required this.service});

  static Future<void> show(BuildContext context, HubServiceModel service) {
    return TaklukBottomSheet.show(
      context: context,
      maxHeightFraction: 0.9,
      child: HubBookingSheet(service: service),
    );
  }

  @override
  ConsumerState<HubBookingSheet> createState() => _HubBookingSheetState();
}

class _HubBookingSheetState extends ConsumerState<HubBookingSheet> {
  late final TextEditingController _nameController;
  final _whatsappController = TextEditingController();
  final _notesController = TextEditingController();
  late University _university;
  DateTime? _preferredDate;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _whatsappController.text = user?.phoneNumber ?? '';
    _university = user?.university ?? University.UIN_SUSKA;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _whatsappController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatTanggalIndo(DateTime date) {
    const namaHari = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const namaBulan = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${namaHari[date.weekday - 1]}, ${date.day} '
        '${namaBulan[date.month - 1]} ${date.year}';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _preferredDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: TaklukColors.primary,
            onPrimary: Colors.white,
            onSurface: TaklukColors.ink,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _preferredDate = picked);
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final whatsapp = _whatsappController.text.trim();

    if (name.length < 3) {
      TaklukToast.show(context, 'Nama lengkap minimal 3 karakter', isError: true);
      return;
    }
    if (!RegExp(r'^(\+62|62|0)8[1-9][0-9]{6,10}$').hasMatch(whatsapp)) {
      TaklukToast.show(context, 'Nomor WhatsApp tidak valid', isError: true);
      return;
    }
    if (_preferredDate == null) {
      TaklukToast.show(context, 'Pilih tanggal reservasi', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final booking = await ref.read(hubRepositoryProvider).book(
            serviceId: widget.service.id,
            fullName: name,
            whatsapp: whatsapp,
            university: _university.value,
            preferredDate: DateFormat('yyyy-MM-dd').format(_preferredDate!),
            notes: _notesController.text,
          );

      if (!mounted) return;
      setState(() => _isSubmitting = false);
      TaklukToast.show(
        context,
        'Reservasi ${booking.bookingCode} berhasil dibuat!',
      );
      Navigator.of(context).pop();
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      TaklukToast.show(context, error.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      TaklukToast.show(context, 'Gagal membuat reservasi', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.service;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service.name,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: TaklukColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            service.tagline,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: TaklukColors.muted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${service.priceFormatted} • ${service.unit}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: TaklukColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          TaklukInput(
            label: 'Nama Lengkap',
            hint: 'Nama sesuai KTM',
            controller: _nameController,
          ),
          const SizedBox(height: 14),
          TaklukInput(
            label: 'Nomor WhatsApp',
            hint: '08xxxxxxxxxx',
            controller: _whatsappController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          const Text(
            'Kampus',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: TaklukColors.muted,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<University>(
            value: _university,
            isExpanded: true,
            decoration: const InputDecoration(),
            items: University.values
                .map(
                  (u) => DropdownMenuItem(
                    value: u,
                    child: Text(
                      u.label,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: TaklukColors.ink,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _university = value);
            },
          ),
          const SizedBox(height: 14),
          const Text(
            'Tanggal Reservasi',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: TaklukColors.muted,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: TaklukColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: TaklukColors.line),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.calendar,
                    size: 16,
                    color: TaklukColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _preferredDate == null
                        ? 'Pilih tanggal'
                        : _formatTanggalIndo(_preferredDate!),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: _preferredDate == null
                          ? TaklukColors.muted
                          : TaklukColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          TaklukInput(
            label: 'Catatan (opsional)',
            hint: 'Materi yang ingin dibahas, jumlah peserta, dll.',
            controller: _notesController,
            maxLength: 250,
          ),
          const SizedBox(height: 20),
          TaklukButton(
            label: 'Kirim Reservasi',
            icon: LucideIcons.send,
            isLoading: _isSubmitting,
            onPressed: _isSubmitting ? null : _submit,
          ),
        ],
      ),
    );
  }
}

