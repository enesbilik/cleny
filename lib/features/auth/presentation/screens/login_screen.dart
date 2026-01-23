import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/onesignal_service.dart';
import '../../../../shared/providers/app_state_provider.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Giriş ekranı
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;
  bool _isLogin = true; // true = giriş, false = kayıt
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final result = _isLogin
        ? await authService.signInWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          )
        : await authService.signUpWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
          );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      if (result.needsEmailConfirmation) {
        // Email doğrulaması gerekiyor
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _successMessage = l10n.registrationSuccessVerifyEmail;
          _isLogin = true; // Giriş moduna geç
        });
        _showMessage(l10n.emailVerificationRequired, isError: false);
        // Formu temizle
        _passwordController.clear();
      } else {
        // Direkt giriş yapıldı - snackbar göstermeden yönlendir
        _navigateAfterAuth();
      }
    } else {
      setState(() => _errorMessage = result.error);
    }
  }

  Future<void> _handleGoogleAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final result = await authService.signInWithGoogle();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      _navigateAfterAuth();
    } else {
      setState(() => _errorMessage = result.error);
    }
  }

  Future<void> _handleAppleAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final result = await authService.signInWithApple();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      _navigateAfterAuth();
    } else {
      setState(() => _errorMessage = result.error);
    }
  }

  Future<void> _navigateAfterAuth() async {
    if (!mounted) return;
    
    // OneSignal'a kullanıcıyı kaydet (push notifications için)
    await OneSignalService.syncCurrentUser();
    
    // Supabase'den onboarding durumunu kontrol et
    await ref.read(appStateProvider.notifier).checkOnboardingFromSupabase();
    
    if (!mounted) return;
    
    final appState = ref.read(appStateProvider);
    if (appState.isOnboardingCompleted) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Logo
              Center(child: _Logo()),

              const SizedBox(height: 40),

              // Başlık
              Text(
                _isLogin ? l10n.loginWelcome : l10n.createAccount,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _isLogin
                    ? l10n.loginSubtitle
                    : l10n.startCleaningJourney,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Başarı mesajı
              if (_successMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.success.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: TextStyle(color: AppColors.success, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),

              // Hata mesajı
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline, color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: AppColors.error, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // İsim (sadece kayıt)
                    if (!_isLogin)
                      _TextField(
                        controller: _nameController,
                        label: l10n.name,
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.nameRequired;
                          }
                          return null;
                        },
                      ),
                    if (!_isLogin) const SizedBox(height: 16),

                    // Email
                    _TextField(
                      controller: _emailController,
                      label: l10n.email,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.emailRequired;
                        }
                        if (!value.contains('@')) {
                          return l10n.enterValidEmail;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Şifre
                    _TextField(
                      controller: _passwordController,
                      label: l10n.password,
                      icon: Icons.lock_outline,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.passwordRequired;
                        }
                        if (value.length < 6) {
                          return l10n.passwordMinLength;
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Giriş/Kayıt butonu
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleEmailAuth,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_isLogin ? l10n.signIn : l10n.signUp),
                ),
              ),

              const SizedBox(height: 16),

              // Giriş/Kayıt geçişi
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLogin ? l10n.dontHaveAccount : l10n.alreadyHaveAccount,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : () {
                      setState(() {
                        _isLogin = !_isLogin;
                        _errorMessage = null;
                        _successMessage = null;
                      });
                    },
                    child: Text(_isLogin ? l10n.signUp : l10n.signIn),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Veya ayırıcı
              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.surfaceVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10n.orContinueWith,
                      style: TextStyle(color: AppColors.textHint),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.surfaceVariant)),
                ],
              ),

              const SizedBox(height: 24),

              // Google ile giriş
              _SocialButton(
                icon: Icons.g_mobiledata_rounded,
                iconColor: Colors.red,
                label: l10n.continueWithGoogle,
                onTap: _isLoading ? null : _handleGoogleAuth,
              ),

              // Apple ile giriş (sadece iOS)
              if (Platform.isIOS) ...[
                const SizedBox(height: 12),
                _SocialButton(
                  icon: Icons.apple,
                  label: l10n.continueWithApple,
                  onTap: _isLoading ? null : _handleAppleAuth,
                  isBlack: true,
                ),
              ],

            ],
          ),
        ),
      ),
    );
  }
}

/// Logo widget
class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.home_rounded,
        size: 40,
        color: Colors.white,
      ),
    );
  }
}

/// Text field widget
class _TextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _TextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  });

  @override
  State<_TextField> createState() => _TextFieldState();
}

class _TextFieldState extends State<_TextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscureText && _obscureText,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(widget.icon, color: AppColors.textSecondary),
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textHint,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
      ),
    );
  }
}

/// Sosyal giriş butonu
class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final VoidCallback? onTap;
  final bool isBlack;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.isBlack = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: isBlack ? Colors.black : Colors.white,
          foregroundColor: isBlack ? Colors.white : AppColors.textPrimary,
          side: BorderSide(
            color: isBlack ? Colors.black : AppColors.surfaceVariant,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: isBlack ? Colors.white : iconColor),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
