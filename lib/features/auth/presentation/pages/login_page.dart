import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waqf_insight/config/routes/app_router.dart';
import 'package:waqf_insight/core/widgets/animated_logo.dart';
import 'package:waqf_insight/core/widgets/auth_background.dart';
import 'package:waqf_insight/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:waqf_insight/features/auth/presentation/bloc/auth_event.dart';
import 'package:waqf_insight/features/auth/presentation/bloc/auth_state.dart';
import 'package:waqf_insight/features/splash/presentation/widgets/splash_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  late AnimationController _formController;
  late Animation<double> _formSlide;
  late Animation<double> _formFade;

  @override
  void initState() {
    super.initState();
    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _formSlide = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeOutCubic),
    );
    _formFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _formController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
      ),
    );
    _formController.forward();
  }

  @override
  void dispose() {
    _formController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            LoginSubmittedEvent(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SplashColors.backgroundLight,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'مرحباً بك، ${state.user.name}',
                  style: GoogleFonts.cairo(),
                ),
                backgroundColor: SplashColors.deepGreen,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.of(context).pushReplacementNamed(AppRouter.home);
          } else if (state is Unauthenticated && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage!,
                  style: GoogleFonts.cairo(),
                ),
                backgroundColor: Colors.red.shade800,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return AuthBackground(
            child: Stack(
              children: [
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Column(
                        children: [
                          const AnimatedLogo(size: 130),
                          const SizedBox(height: 20),
                          Text(
                            'ديوان الوقف السني العراقي',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: SplashColors.textPrimaryLight,
                              shadows: [
                                Shadow(
                                  color: SplashColors.gold.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'هيئة إدارة واستثمار أموال الوقف السني',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: SplashColors.textSecondaryLight.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 28),
                          AnimatedBuilder(
                            animation: _formController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _formSlide.value),
                                child: Opacity(
                                  opacity: _formFade.value,
                                  child: child,
                                ),
                              );
                            },
                            child: _LoginCard(
                              formKey: _formKey,
                              emailController: _emailController,
                              passwordController: _passwordController,
                              passwordVisible: _passwordVisible,
                              onTogglePassword: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                              onSubmit: _submitLogin,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                if (state is AuthLoading)
                  Container(
                    color: SplashColors.backgroundLight.withValues(alpha: 0.7),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: SplashColors.surfaceLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: SplashColors.gold.withValues(alpha: 0.35),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: SplashColors.greenSoft.withValues(alpha: 0.5),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 36,
                              height: 36,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: SplashColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'جاري تسجيل الدخول...',
                              style: GoogleFonts.cairo(
                                color: SplashColors.textPrimaryLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.passwordVisible,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool passwordVisible;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        color: SplashColors.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: SplashColors.gold.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: SplashColors.greenSoft.withValues(alpha: 0.6),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'تسجيل الدخول',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: SplashColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'أدخل بيانات حسابك للمتابعة',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: SplashColors.textSecondaryLight.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 24),
            _AuthTextField(
              controller: emailController,
              label: 'البريد الإلكتروني',
              hint: 'example@waqf.gov.iq',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال البريد الإلكتروني';

                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _AuthTextField(
              controller: passwordController,
              label: 'كلمة المرور',
              hint: '••••••••',
              icon: Icons.lock_outline,
              obscureText: !passwordVisible,
              textDirection: TextDirection.ltr,
              suffixIcon: IconButton(
                icon: Icon(
                  passwordVisible ? Icons.visibility_off : Icons.visibility,
                  color: SplashColors.textSecondaryLight,
                  size: 20,
                ),
                onPressed: onTogglePassword,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال كلمة المرور';
                }
                if (value.length < 6) {
                  return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [
                    SplashColors.deepGreen,
                    Color(0xFF006B35),
                    SplashColors.goldDark,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: SplashColors.gold.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'دخول',
                  style: GoogleFonts.cairo(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.textDirection,
    this.suffixIcon,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextDirection? textDirection;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textDirection: textDirection,
      style: GoogleFonts.cairo(
        color: SplashColors.textPrimaryLight,
        fontSize: 15,
      ),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: GoogleFonts.cairo(
          color: SplashColors.textSecondaryLight,
        ),
        hintStyle: GoogleFonts.cairo(
          color: SplashColors.textSecondaryLight.withValues(alpha: 0.45),
        ),
        prefixIcon: Icon(
          icon,
          color: SplashColors.textPrimaryLight,
          size: 22,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: SplashColors.mintLight.withValues(alpha: 0.5),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: SplashColors.greenSoft,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: SplashColors.textPrimaryLight,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
        errorStyle: GoogleFonts.cairo(fontSize: 12),
      ),
    );
  }
}
