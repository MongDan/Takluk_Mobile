import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/models/profile_models.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/profile_repository.dart';

/// `GET /api/profile/device`
final deviceInfoProvider = FutureProvider<DeviceBindingModel>((ref) async {
  final userId = ref.watch(authProvider.select((state) => state.user?.id));
  if (userId == null) {
    throw StateError('Silakan masuk terlebih dahulu.');
  }
  return ref.watch(profileRepositoryProvider).getDeviceInfo();
});

/// `GET /api/profile/referral`
final referralProvider = FutureProvider<ReferralModel>((ref) async {
  final userId = ref.watch(authProvider.select((state) => state.user?.id));
  if (userId == null) {
    throw StateError('Silakan masuk terlebih dahulu.');
  }
  return ref.watch(profileRepositoryProvider).getReferralInfo();
});
