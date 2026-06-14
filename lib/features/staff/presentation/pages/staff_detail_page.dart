import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:waqf_insight/core/di/injection_container.dart';
import 'package:waqf_insight/core/utils/contact_launcher.dart';
import 'package:waqf_insight/features/staff/data/models/staff_models.dart';
import 'package:waqf_insight/features/staff/domain/entities/staff_detail_args.dart';
import 'package:waqf_insight/features/staff/domain/repositories/staff_repository.dart';

class StaffDetailPage extends StatefulWidget {
  const StaffDetailPage({super.key, required this.args});

  final StaffDetailArgs args;

  @override
  State<StaffDetailPage> createState() => _StaffDetailPageState();
}

class _StaffDetailPageState extends State<StaffDetailPage> {
  StaffDetailModel? _detail;
  StaffMemberModel? _preview;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _preview = widget.args.preview;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await sl<StaffRepository>().getStaffDetail(widget.args.userId);
    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _loading = false;
        _error = failure.message;
      }),
      (detail) => setState(() {
        _loading = false;
        _detail = detail;
      }),
    );
  }

  Future<void> _contact(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e', style: GoogleFonts.cairo())),
      );
    }
  }

  String _formatDate(DateTime date) => DateFormat('yyyy/MM/dd').format(date);

  String _formatDateTime(DateTime date) =>
      DateFormat('yyyy/MM/dd HH:mm').format(date.toLocal());

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final display = _detail ?? _preview;

    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الموظف', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
      ),
      body: _loading && display == null
          ? const Center(child: CircularProgressIndicator())
          : _error != null && display == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, style: GoogleFonts.cairo()),
                      FilledButton(
                        onPressed: _load,
                        child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
                      ),
                    ],
                  ),
                )
              : display == null
                  ? Center(child: Text('غير موجود', style: GoogleFonts.cairo()))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      children: [
                        if (_error != null && _detail == null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12, bottom: 8),
                            child: Material(
                              color: colorScheme.errorContainer.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline, color: colorScheme.error),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'تعذّر تحميل التفاصيل الكاملة — عرض البيانات المتاحة',
                                        style: GoogleFonts.cairo(fontSize: 12),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: _load,
                                      child: Text('إعادة', style: GoogleFonts.cairo()),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        _HeaderCard(member: display),
                        const SizedBox(height: 16),
                        _ContactSection(
                          phone: display.phone,
                          email: display.email,
                          onWhatsApp: () => _contact(
                            () => ContactLauncher.openWhatsApp(
                              display.phone!,
                              message: 'السلام عليكم ${display.fullName}',
                            ),
                          ),
                          onEmail: () => _contact(
                            () => ContactLauncher.openEmail(
                              display.email!,
                              subject: 'Waqf Insight',
                            ),
                          ),
                          onCall: display.phone != null
                              ? () => _contact(
                                    () => ContactLauncher.callPhone(display.phone!),
                                  )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        if (display.responsibilities.isNotEmpty)
                          _SectionCard(
                            title: 'المسؤوليات',
                            icon: Icons.task_alt_rounded,
                            child: Column(
                              children: [
                                for (final item in display.responsibilities)
                                  _BulletItem(text: item),
                              ],
                            ),
                          ),
                        if (_detail != null) ...[
                          if (_detail!.roles.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _SectionCard(
                              title: 'الأدوار',
                              icon: Icons.shield_rounded,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _detail!.roles
                                    .map(
                                      (r) => Chip(
                                        label: Text(
                                          r,
                                          style: GoogleFonts.cairo(fontSize: 11),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                          if (_detail!.permissions.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _SectionCard(
                              title: 'الصلاحيات',
                              icon: Icons.key_rounded,
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: _detail!.permissions
                                    .map(
                                      (p) => _MiniTag(
                                        label: p,
                                        color: colorScheme.secondary,
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                          if (_detail!.governorates.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _SectionCard(
                              title: 'المحافظات',
                              icon: Icons.map_rounded,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _detail!.governorates
                                    .map(
                                      (g) => _MiniTag(
                                        label: g,
                                        color: colorScheme.primary,
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          _SectionCard(
                            title: 'معلومات إضافية',
                            icon: Icons.info_outline_rounded,
                            child: Column(
                              children: [
                                if (_detail!.department != null)
                                  _InfoRow(label: 'القسم', value: _detail!.department!),
                                if (_detail!.companyName != null)
                                  _InfoRow(label: 'الشركة', value: _detail!.companyName!),
                                if (_detail!.specialization != null)
                                  _InfoRow(label: 'التخصص', value: _detail!.specialization!),
                                if (_detail!.assignedTasksCount != null)
                                  _InfoRow(
                                    label: 'المهام',
                                    value: '${_detail!.assignedTasksCount}',
                                  ),
                                if (_detail!.hireDate != null)
                                  _InfoRow(
                                    label: 'تاريخ التعيين',
                                    value: _formatDate(_detail!.hireDate!),
                                  ),
                                if (_detail!.lastActivityAt != null)
                                  _InfoRow(
                                    label: 'آخر نشاط',
                                    value: _formatDateTime(_detail!.lastActivityAt!),
                                  ),
                                _InfoRow(
                                  label: 'الحالة',
                                  value: _detail!.isActive ? 'نشط' : 'غير نشط',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.member});

  final StaffMemberModel member;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.78)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              member.initials,
              style: GoogleFonts.cairo(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (member.jobTitle != null)
                  Text(
                    member.jobTitle!,
                    style: GoogleFonts.cairo(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                  ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [
                    _HeaderChip(label: member.staffType),
                    if (!member.isActive) const _HeaderChip(label: 'غير نشط'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(color: Colors.white, fontSize: 11),
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({
    required this.phone,
    required this.email,
    required this.onWhatsApp,
    required this.onEmail,
    this.onCall,
  });

  final String? phone;
  final String? email;
  final VoidCallback onWhatsApp;
  final VoidCallback onEmail;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    final hasPhone = phone != null && phone!.trim().isNotEmpty;
    final hasEmail = email != null && email!.trim().isNotEmpty;

    if (!hasPhone && !hasEmail) {
      return Material(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Text(
            'لا توجد بيانات تواصل مسجّلة',
            style: GoogleFonts.cairo(),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasPhone)
          FilledButton.icon(
            onPressed: onWhatsApp,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.chat_rounded),
            label: Text(
              'تواصل عبر واتساب',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
            ),
          ),
        if (hasPhone && hasEmail) const SizedBox(height: 10),
        if (hasEmail)
          OutlinedButton.icon(
            onPressed: onEmail,
            icon: const Icon(Icons.email_outlined),
            label: Text('إرسال بريد', style: GoogleFonts.cairo()),
          ),
        if (hasPhone) ...[
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: onCall,
            icon: const Icon(Icons.phone_rounded),
            label: Text(phone!, style: GoogleFonts.cairo()),
          ),
        ],
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  const _BulletItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(text, style: GoogleFonts.cairo())),
        ],
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(fontSize: 10, color: color),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(child: Text(value, style: GoogleFonts.cairo())),
        ],
      ),
    );
  }
}
