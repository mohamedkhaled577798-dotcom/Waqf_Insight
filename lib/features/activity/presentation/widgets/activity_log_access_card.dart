import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waqf_insight/config/routes/app_router.dart';
import 'package:waqf_insight/features/splash/presentation/widgets/splash_colors.dart';

class ActivityLogAccessCard extends StatelessWidget {
  const ActivityLogAccessCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, AppRouter.recentActivity),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF6A1B9A).withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4527A0), Color(0xFF6A1B9A)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.history_rounded, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سجل العمليات',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'متابعة آخر الإجراءات والتغييرات في النظام',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: colorScheme.onSurface.withValues(alpha: 0.65),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: SplashColors.goldDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
