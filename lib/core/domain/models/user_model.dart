import '../../constants/enums.dart';
import '../../network/json_utils.dart';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String nim;
  final University university;
  final int semester;
  final String? major;
  final String? phoneNumber;
  final UserRole role;
  final String? activeDeviceId;
  final DateTime? deviceUpdatedAt;
  final String referralCode;
  final String? referredById;
  final DateTime? subscriptionValidUntil;
  final bool isActive;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.nim,
    required this.university,
    required this.semester,
    this.major,
    this.phoneNumber,
    this.role = UserRole.STUDENT,
    this.activeDeviceId,
    this.deviceUpdatedAt,
    required this.referralCode,
    this.referredById,
    this.subscriptionValidUntil,
    this.isActive = true,
    required this.createdAt,
  });

  bool get isSubscribed =>
      subscriptionValidUntil != null &&
      subscriptionValidUntil!.isAfter(DateTime.now());

  int? get daysRemaining {
    if (!isSubscribed) return null;
    return subscriptionValidUntil!.difference(DateTime.now()).inDays;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: pickString(json, ['id']),
      email: pickString(json, ['email']),
      fullName: pickString(json, ['full_name', 'fullName'], fallback: 'Mahasiswa'),
      nim: pickString(json, ['nim']),
      university: University.fromValue(
        pickString(json, ['university'], fallback: 'LAINNYA'),
      ),
      semester: pickInt(json, ['semester'], fallback: 1),
      major: pickStringOrNull(json, ['major']),
      phoneNumber: pickStringOrNull(json, ['phone_number', 'phoneNumber']),
      role: UserRole.values.firstWhere(
        (e) => e.value == pickString(json, ['role'], fallback: 'STUDENT'),
        orElse: () => UserRole.STUDENT,
      ),
      activeDeviceId:
          pickStringOrNull(json, ['active_device_id', 'activeDeviceId']),
      deviceUpdatedAt:
          pickDate(json, ['device_updated_at', 'deviceUpdatedAt']),
      referralCode: pickString(json, ['referral_code', 'referralCode']),
      referredById: pickStringOrNull(json, ['referred_by_id', 'referredById']),
      subscriptionValidUntil:
          pickDate(json, ['subscription_valid_until', 'subscriptionValidUntil']),
      isActive: pickBool(json, ['is_active', 'isActive'], fallback: true),
      createdAt:
          pickDate(json, ['created_at', 'createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'nim': nim,
        'university': university.value,
        'semester': semester,
        'major': major,
        'phone_number': phoneNumber,
        'role': role.value,
        'active_device_id': activeDeviceId,
        'device_updated_at': deviceUpdatedAt?.toIso8601String(),
        'referral_code': referralCode,
        'referred_by_id': referredById,
        'subscription_valid_until': subscriptionValidUntil?.toIso8601String(),
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
      };

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? nim,
    University? university,
    int? semester,
    String? major,
    String? phoneNumber,
    UserRole? role,
    String? activeDeviceId,
    DateTime? deviceUpdatedAt,
    String? referralCode,
    String? referredById,
    DateTime? subscriptionValidUntil,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      nim: nim ?? this.nim,
      university: university ?? this.university,
      semester: semester ?? this.semester,
      major: major ?? this.major,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      activeDeviceId: activeDeviceId ?? this.activeDeviceId,
      deviceUpdatedAt: deviceUpdatedAt ?? this.deviceUpdatedAt,
      referralCode: referralCode ?? this.referralCode,
      referredById: referredById ?? this.referredById,
      subscriptionValidUntil:
          subscriptionValidUntil ?? this.subscriptionValidUntil,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

