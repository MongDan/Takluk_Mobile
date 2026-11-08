import '../../constants/enums.dart';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String nim;
  final University university;
  final int semester;
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
      subscriptionValidUntil != null && subscriptionValidUntil!.isAfter(DateTime.now());

  int? get daysRemaining {
    if (!isSubscribed) return null;
    return subscriptionValidUntil!.difference(DateTime.now()).inDays;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      nim: json['nim'] as String,
      university: University.fromValue(json['university'] as String),
      semester: json['semester'] as int,
      phoneNumber: json['phone_number'] as String?,
      role: UserRole.values.firstWhere((e) => e.value == json['role'], orElse: () => UserRole.STUDENT),
      activeDeviceId: json['active_device_id'] as String?,
      deviceUpdatedAt: json['device_updated_at'] != null ? DateTime.parse(json['device_updated_at']) : null,
      referralCode: json['referral_code'] as String,
      referredById: json['referred_by_id'] as String?,
      subscriptionValidUntil: json['subscription_valid_until'] != null ? DateTime.parse(json['subscription_valid_until']) : null,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'full_name': fullName,
    'nim': nim,
    'university': university.value,
    'semester': semester,
    'phone_number': phoneNumber,
    'role': role.value,
    'active_device_id': activeDeviceId,
    'referral_code': referralCode,
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
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      activeDeviceId: activeDeviceId ?? this.activeDeviceId,
      deviceUpdatedAt: deviceUpdatedAt ?? this.deviceUpdatedAt,
      referralCode: referralCode ?? this.referralCode,
      referredById: referredById ?? this.referredById,
      subscriptionValidUntil: subscriptionValidUntil ?? this.subscriptionValidUntil,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
