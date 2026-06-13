import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waqf_insight/config/routes/app_router.dart';
import 'package:waqf_insight/core/di/injection_container.dart';
import 'package:waqf_insight/core/theme/theme_cubit.dart';
import 'package:waqf_insight/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:waqf_insight/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:waqf_insight/features/auth/presentation/bloc/auth_event.dart';
import 'package:waqf_insight/features/auth/presentation/bloc/auth_state.dart';
import 'package:waqf_insight/features/profile/presentation/widgets/change_password_sheet.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated && state.errorMessage == null) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.auth,
            (_) => false,
          );
        } else if (state is Unauthenticated && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is! Authenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = state.user;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final isDark = context.watch<ThemeCubit>().isDark;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'الملف الشخصي',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            child: Column(
              children: [
                _ProfileHeader(
                  name: user.name,
                  jobTitle: user.jobTitle,
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 24),
                _InfoSection(
                  title: 'البيانات الشخصية',
                  children: [
                    _InfoTile(
                      icon: Icons.person_outline,
                      label: 'الاسم الكامل',
                      value: user.name,
                    ),
                    _InfoTile(
                      icon: Icons.email_outlined,
                      label: 'البريد الإلكتروني',
                      value: user.email,
                    ),
                    _InfoTile(
                      icon: Icons.phone_outlined,
                      label: 'الهاتف',
                      value: user.phone ?? '—',
                    ),
                    _InfoTile(
                      icon: Icons.work_outline,
                      label: 'المسمى الوظيفي',
                      value: user.jobTitle ?? '—',
                    ),
                    _InfoTile(
                      icon: Icons.business_outlined,
                      label: 'القسم',
                      value: user.department ?? '—',
                    ),
                    _InfoTile(
                      icon: Icons.verified_user_outlined,
                      label: 'الدور',
                      value: user.roles.isEmpty
                          ? '—'
                          : user.roles.join(' • '),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _InfoSection(
                  title: 'الإعدادات',
                  children: [
                    _SettingsTile(
                      icon: isDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      title: 'وضع العرض',
                      subtitle: isDark ? 'داكن' : 'فاتح',
                      trailing: Switch.adaptive(
                        value: isDark,
                        onChanged: (_) {
                          context.read<ThemeCubit>().toggleTheme();
                        },
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'تغيير كلمة المرور',
                      subtitle: 'تحديث كلمة مرور الحساب',
                      onTap: () => _showChangePasswordSheet(context),
                    ),
                    _SettingsTile(
                      icon: Icons.logout_rounded,
                      title: 'تسجيل الخروج',
                      subtitle: 'إنهاء الجلسة الحالية',
                      isDestructive: true,
                      onTap: () => _confirmLogout(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => ChangePasswordSheet(
        onSubmit: (current, newPass) async {
          final result = await sl<ChangePasswordUseCase>()(
            ChangePasswordParams(
              currentPassword: current,
              newPassword: newPass,
            ),
          );
          return result.fold(
            (failure) => failure.message,
            (_) => null,
          );
        },
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تسجيل الخروج', style: GoogleFonts.cairo()),
        content: Text(
          'هل أنت متأكد من تسجيل الخروج؟',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('خروج', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(const LogoutRequestedEvent());
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.jobTitle,
    required this.colorScheme,
  });

  final String name;
  final String? jobTitle;
  final ColorScheme colorScheme;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.12),
            colorScheme.secondary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.secondary],
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _initials,
                style: GoogleFonts.cairo(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          if (jobTitle != null) ...[
            const SizedBox(height: 4),
            Text(
              jobTitle!,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 10),
          child: Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.12),
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 22, color: colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isDestructive ? colorScheme.error : colorScheme.primary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDestructive
                          ? colorScheme.error
                          : colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(
                Icons.chevron_left_rounded,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
          ],
        ),
      ),
    );
  }
}
