import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/widgets/takluk_button.dart';
import '../../../../core/widgets/takluk_input.dart';
import '../../../../core/widgets/takluk_segmented_control.dart';
import '../../../../core/widgets/takluk_toast.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  int _tabIndex = 0; // 0: Masuk, 1: Daftar
  bool _showOtp = false;

  final _loginEmailController = TextEditingController();

  final _regNameController = TextEditingController();
  final _regNimController = TextEditingController();
  final _regEmailController = TextEditingController();
  University _regUniversity = University.UIN_SUSKA;
  int _regSemester = 3;

  final _otpController = TextEditingController();
  String? _otpError;
  String _currentEmail = '';
  bool _isRegistering = false;

  String? _loginEmailError;
  String? _regNameError;
  String? _regNimError;
  String? _regEmailError;

  bool _validateLogin() {
    final email = _loginEmailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _loginEmailError = 'Masukkan email yang valid');
      return false;
    }
    setState(() => _loginEmailError = null);
    return true;
  }

  bool _validateRegister() {
    bool valid = true;
    if (_regNameController.text.trim().isEmpty) {
      _regNameError = 'Nama lengkap wajib diisi';
      valid = false;
    } else {
      _regNameError = null;
    }
    if (_regNimController.text.trim().isEmpty) {
      _regNimError = 'NIM wajib diisi';
      valid = false;
    } else {
      _regNimError = null;
    }
    final email = _regEmailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _regEmailError = 'Masukkan email yang valid';
      valid = false;
    } else {
      _regEmailError = null;
    }
    setState(() {});
    return valid;
  }

  Future<void> _handleSubmit() async {
    if (_tabIndex == 0) {
      if (!_validateLogin()) return;
      _currentEmail = _loginEmailController.text.trim();
      _isRegistering = false;
    } else {
      if (!_validateRegister()) return;
      _currentEmail = _regEmailController.text.trim();
      _isRegistering = true;
    }

    final success = await ref.read(authProvider.notifier).requestOtp(_currentEmail);
    if (success && mounted) {
      setState(() {
        _showOtp = true;
        _otpController.clear();
        _otpError = null;
      });
      TaklukToast.show(context, 'Kode OTP 6 digit telah dikirim ke $_currentEmail');
    }
  }

  Future<void> _handleVerifyOtp() async {
    if (_otpController.text.length != 6) {
      setState(() => _otpError = 'Masukkan 6 digit kode OTP');
      return;
    }

    final success = await ref.read(authProvider.notifier).verifyOtp(
      email: _currentEmail,
      otpCode: _otpController.text,
      fullName: _isRegistering ? _regNameController.text.trim() : null,
      nim: _isRegistering ? _regNimController.text.trim() : null,
      university: _isRegistering ? _regUniversity.value : null,
      semester: _isRegistering ? _regSemester : null,
    );

    if (success && mounted) {
      context.go('/home');
    } else if (mounted) {
      setState(() => _otpError = 'Kode OTP salah. Gunakan kode demo: 123456');
      HapticFeedback.heavyImpact();
    }
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _regNameController.dispose();
    _regNimController.dispose();
    _regEmailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: TaklukColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: TaklukGradients.primary,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: TaklukColors.primary.withOpacity(0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.school, color: TaklukColors.accent, size: 22),
                            const SizedBox(width: 2),
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.play_arrow_rounded, color: TaklukColors.primary, size: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Takluk',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: TaklukColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Center(
                    child: Text(
                      'Bimbingan Belajar VOD & Panam Hub',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: TaklukColors.muted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  if (_showOtp)
                    _buildOtpSection(authState)
                  else ...[
                    TaklukSegmentedControl(
                      segments: const ['Masuk', 'Daftar'],
                      selectedIndex: _tabIndex,
                      onChanged: (i) => setState(() => _tabIndex = i),
                    ),
                    const SizedBox(height: 20),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _tabIndex == 0 ? _buildLoginForm() : _buildRegisterForm(),
                    ),
                    const SizedBox(height: 20),
                    TaklukButton(
                      label: _tabIndex == 0 ? 'Kirim Kode OTP' : 'Daftar & Kirim OTP',
                      onPressed: authState.status == AuthStatus.loading ? null : _handleSubmit,
                      isLoading: authState.status == AuthStatus.loading,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Expanded(child: Divider(color: TaklukColors.line)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'atau coba langsung',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: TaklukColors.muted.withOpacity(0.8),
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: TaklukColors.line)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TaklukButton(
                      label: 'Masuk dengan Akun Demo',
                      variant: ButtonVariant.secondary,
                      icon: LucideIcons.userCheck,
                      onPressed: () async {
                        await ref.read(authProvider.notifier).loginAsDemo();
                        if (mounted) context.go('/home');
                      },
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: TaklukColors.tintWarm,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Aisyah Putri • NIM 12250312345 • UIN Suska • Smtr 3',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: TaklukColors.ink,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      key: const ValueKey('login_form'),
      children: [
        TaklukInput(
          label: 'Email Terdaftar',
          hint: 'aisyah@demo.takluk.id',
          controller: _loginEmailController,
          keyboardType: TextInputType.emailAddress,
          errorText: _loginEmailError,
          suffixIcon: const Icon(LucideIcons.mail, size: 18, color: TaklukColors.muted),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      key: const ValueKey('register_form'),
      children: [
        TaklukInput(
          label: 'Nama Lengkap',
          hint: 'Aisyah Putri',
          controller: _regNameController,
          errorText: _regNameError,
          suffixIcon: const Icon(LucideIcons.user, size: 18, color: TaklukColors.muted),
        ),
        const SizedBox(height: 14),
        TaklukInput(
          label: 'NIM (Nomor Induk Mahasiswa)',
          hint: '12250312345',
          controller: _regNimController,
          keyboardType: TextInputType.number,
          errorText: _regNimError,
          suffixIcon: const Icon(LucideIcons.creditCard, size: 18, color: TaklukColors.muted),
        ),
        const SizedBox(height: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kampus Asal',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: TaklukColors.muted,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: TaklukColors.surface,
                borderRadius: TaklukRadius.cardBR,
                border: Border.all(color: TaklukColors.line),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<University>(
                  isExpanded: true,
                  value: _regUniversity,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: TaklukColors.ink,
                  ),
                  items: [
                    University.UNRI,
                    University.UIN_SUSKA,
                    University.PCR,
                    University.UIR,
                    University.UMRI,
                    University.LAINNYA,
                  ]
                      .map((u) => DropdownMenuItem(value: u, child: Text(u.label)))
                      .toList(),
                  onChanged: (v) => setState(() => _regUniversity = v!),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Semester',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: TaklukColors.muted,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: TaklukColors.surface,
                borderRadius: TaklukRadius.cardBR,
                border: Border.all(color: TaklukColors.line),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: _regSemester,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: TaklukColors.ink,
                  ),
                  items: List.generate(8, (i) => i + 1)
                      .map((s) => DropdownMenuItem(value: s, child: Text('Semester $s')))
                      .toList(),
                  onChanged: (v) => setState(() => _regSemester = v!),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TaklukInput(
          label: 'Email Kampus / Pribadi',
          hint: 'aisyah@uin-suska.ac.id',
          controller: _regEmailController,
          keyboardType: TextInputType.emailAddress,
          errorText: _regEmailError,
          suffixIcon: const Icon(LucideIcons.mail, size: 18, color: TaklukColors.muted),
        ),
      ],
    );
  }

  Widget _buildOtpSection(AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() {
            _showOtp = false;
            _otpController.clear();
            _otpError = null;
          }),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(LucideIcons.arrowLeft, size: 18, color: TaklukColors.primary),
              SizedBox(width: 6),
              Text(
                'Ganti Email',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: TaklukColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Verifikasi Email OTP',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: TaklukColors.ink,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Kode 6 digit telah dikirim ke:\n$_currentEmail',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: TaklukColors.muted,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            final hasChar = _otpController.text.length > index;
            final isCurrent = _otpController.text.length == index;
            return Container(
              width: 46,
              height: 54,
              decoration: BoxDecoration(
                color: TaklukColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _otpError != null
                      ? TaklukColors.error
                      : (isCurrent
                          ? TaklukColors.primary
                          : (hasChar ? TaklukColors.primary.withOpacity(0.5) : TaklukColors.line)),
                  width: isCurrent ? 2 : 1.2,
                ),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: TaklukColors.primary.withOpacity(0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  hasChar ? _otpController.text[index] : '',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: TaklukColors.ink,
                  ),
                ),
              ),
            );
          }),
        ),
        SizedBox(
          height: 0,
          child: TextField(
            controller: _otpController,
            autofocus: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (v) {
              setState(() => _otpError = null);
              if (v.length == 6) {
                _handleVerifyOtp();
              }
            },
            decoration: const InputDecoration(counterText: ''),
          ),
        ),
        if (_otpError != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(LucideIcons.alertCircle, size: 14, color: TaklukColors.error),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _otpError!,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: TaklukColors.error,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 24),
        TaklukButton(
          label: 'Verifikasi & Masuk',
          onPressed: authState.otpVerifying ? null : _handleVerifyOtp,
          isLoading: authState.otpVerifying,
        ),
        const SizedBox(height: 16),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: TaklukColors.tintWarm,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '💡 Demo OTP: 123456 (Pengikatan Perangkat Otomatis)',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: TaklukColors.ink,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

