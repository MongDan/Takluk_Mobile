import '../../network/json_utils.dart';

/// Respons `GET /api/profile/device` dan `POST /api/profile/device/reset`.
class DeviceBindingModel {
  final String? activeDeviceId;
  final DateTime? deviceUpdatedAt;
  final String? policy;
  final bool canReset;
  final bool otpSent;
  final bool deviceResetSuccess;
  final String? newDeviceId;
  final String message;

  const DeviceBindingModel({
    this.activeDeviceId,
    this.deviceUpdatedAt,
    this.policy,
    this.canReset = true,
    this.otpSent = false,
    this.deviceResetSuccess = false,
    this.newDeviceId,
    this.message = '',
  });

  factory DeviceBindingModel.fromJson(Map<String, dynamic> json) {
    return DeviceBindingModel(
      activeDeviceId:
          pickStringOrNull(json, ['active_device_id', 'activeDeviceId']),
      deviceUpdatedAt:
          pickDate(json, ['device_updated_at', 'deviceUpdatedAt']),
      policy: pickStringOrNull(json, ['policy']),
      canReset: pickBool(json, ['can_reset', 'canReset'], fallback: true),
      otpSent: pickBool(json, ['otp_sent', 'otpSent']),
      deviceResetSuccess:
          pickBool(json, ['device_reset_success', 'deviceResetSuccess']),
      newDeviceId: pickStringOrNull(json, ['new_device_id', 'newDeviceId']),
      message: pickString(json, ['message']),
    );
  }
}

/// Respons `GET /api/profile/referral`.
class ReferralModel {
  final String referralCode;
  final String shareMessage;
  final int totalReferredUsers;
  final int bonusDaysEarned;
  final String rewardRule;

  const ReferralModel({
    required this.referralCode,
    required this.shareMessage,
    required this.totalReferredUsers,
    required this.bonusDaysEarned,
    required this.rewardRule,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      referralCode: pickString(json, ['referral_code', 'referralCode']),
      shareMessage: pickString(json, ['share_message', 'shareMessage']),
      totalReferredUsers:
          pickInt(json, ['total_referred_users', 'totalReferredUsers']),
      bonusDaysEarned:
          pickInt(json, ['bonus_days_earned', 'bonusDaysEarned']),
      rewardRule: pickString(json, ['reward_rule', 'rewardRule']),
    );
  }
}
