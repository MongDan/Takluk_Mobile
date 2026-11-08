import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/security/device_info_service.dart';
import '../../../../core/widgets/push_page_header.dart';
import '../../../../core/widgets/takluk_button.dart';
import '../../../../core/widgets/takluk_toast.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class DeviceManagementScreen extends ConsumerStatefulWidget {
  const DeviceManagementScreen({super.key});

  @override
  ConsumerState<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends ConsumerState<DeviceManagementScreen> {
  String _deviceModel = 'Memuat…';
  String _deviceId = 'Memuat…';

  @override
  void initState() {
    super.initState();
    _loadDevice();
  }

  Future<void> _loadDevice() async {
    final infoService = ref.read(deviceInfoServiceProvider);
    final model = await infoService.getDeviceModel();
    final id = await infoService.getDeviceId();
    if (mounted) {
      setState(() {
        _deviceModel = model;
        _deviceId = id;
      });
    }
  }

  void _resetDeviceBinding() {
    TaklukToast.show(context, 'Pengikatan perangkat berhasil di-reset');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: TaklukColors.bg,
      appBar: const PushPageHeader(title: 'Perangkat Aktif'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security Info Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TaklukColors.tintWarm,
                borderRadius: TaklukRadius.cardBR,
                border: Border.all(color: TaklukColors.accent.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(LucideIcons.shieldCheck, color: TaklukColors.accent, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kebijakan Single Device Binding',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: TaklukColors.ink,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Untuk menjaga keamanan materi dan mencegah akun dipakai bergantian, 1 akun Takluk hanya dapat login di 1 perangkat fisik pada saat yang sama.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: TaklukColors.muted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Perangkat Yang Terdaftar Saat Ini',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: TaklukColors.ink,
              ),
            ),
            const SizedBox(height: 12),

            // Active Device Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: TaklukColors.surface,
                borderRadius: TaklukRadius.cardBR,
                border: Border.all(color: TaklukColors.primary.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: TaklukColors.primary.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: TaklukColors.tint,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(LucideIcons.smartphone, color: TaklukColors.primary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _deviceModel,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: TaklukColors.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: TaklukColors.success.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Perangkat Sah Utama',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: TaklukColors.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: TaklukColors.line),
                  const SizedBox(height: 10),
                  _infoRow('Device ID:', _deviceId.length > 20 ? '${_deviceId.substring(0, 20)}…' : _deviceId),
                  const SizedBox(height: 6),
                  _infoRow('Terakhir Sinkron:', 'Hari ini (Aktif)'),
                  const SizedBox(height: 6),
                  _infoRow('Pemilik Akun:', user?.fullName ?? 'Aisyah Putri'),
                ],
              ),
            ),
            const SizedBox(height: 28),

            TaklukButton(
              label: 'Pindahkan Sesi ke Perangkat Ini',
              variant: ButtonVariant.secondary,
              icon: LucideIcons.refreshCw,
              onPressed: _resetDeviceBinding,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: TaklukColors.muted),
        ),
        Text(
          value,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: TaklukColors.ink),
        ),
      ],
    );
  }
}

