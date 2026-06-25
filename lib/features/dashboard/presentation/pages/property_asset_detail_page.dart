import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waqf_insight/config/routes/app_router.dart';
import 'package:waqf_insight/core/di/injection_container.dart';
import 'package:waqf_insight/core/utils/format_helpers.dart';
import 'package:waqf_insight/features/dashboard/data/models/property_asset_models.dart';
import 'package:waqf_insight/features/dashboard/domain/entities/dashboard_section.dart';
import 'package:waqf_insight/features/dashboard/domain/repositories/dashboard_repository.dart';

class PropertyAssetDetailPage extends StatefulWidget {
  const PropertyAssetDetailPage({super.key, required this.args});

  final PropertyAssetDetailArgs args;

  @override
  State<PropertyAssetDetailPage> createState() => _PropertyAssetDetailPageState();
}

class _PropertyAssetDetailPageState extends State<PropertyAssetDetailPage> {
  PropertyAssetDetailModel? _detail;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await sl<DashboardRepository>().getPropertyAssetDetail(widget.args.assetId);
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _loading = false;
        _error = f.message;
      }),
      (r) => setState(() {
        _loading = false;
        _detail = r.data;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.args.title ?? 'تفاصيل الملك',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          ),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(child: Text('الملك', style: GoogleFonts.cairo(fontSize: 12))),
              Tab(child: Text('الربط', style: GoogleFonts.cairo(fontSize: 12))),
              Tab(child: Text('العقود', style: GoogleFonts.cairo(fontSize: 12))),
              Tab(child: Text('الإيرادات', style: GoogleFonts.cairo(fontSize: 12))),
              Tab(child: Text('الديون', style: GoogleFonts.cairo(fontSize: 12))),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!, style: GoogleFonts.cairo()))
                : _detail == null
                    ? Center(child: Text('الملك غير موجود', style: GoogleFonts.cairo()))
                    : TabBarView(
                        children: [
                          _AssetTab(d: _detail!),
                          _LinkTab(d: _detail!),
                          _ContractsTab(d: _detail!),
                          _RevenueTab(d: _detail!),
                          _DebtsTab(d: _detail!),
                        ],
                      ),
      ),
    );
  }
}

class _AssetTab extends StatelessWidget {
  const _AssetTab({required this.d});
  final PropertyAssetDetailModel d;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _row('رقم الملك', d.assetCode),
        _row('الاسم التجاري', d.commercialName),
        _row('الموقع', d.location),
        _row('المساحة', d.rentedArea != null ? '${d.rentedArea!.toStringAsFixed(0)} م²' : null),
        _row('الإيجار السنوي', d.annualRent != null ? formatIraqiCurrency(d.annualRent!) : null),
        _row('حالة الإشغال', d.occupancyStatus),
        _row('نوع الاستعمال', d.usageTypeName),
        _row('نوع الملك', d.ownershipTypeName),
      ],
    );
  }
}

class _LinkTab extends StatelessWidget {
  const _LinkTab({required this.d});
  final PropertyAssetDetailModel d;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (d.propertyMissing)
          Card(
            color: Colors.amber.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text('الملك مرتبط بعقار غير موجود في النظام', style: GoogleFonts.cairo()),
            ),
          ),
        _row('العقار', d.propertyName),
        _row('رقم العقار (عق)', d.propertyAqarId ?? d.pendingAqarId),
        _row('الوقف', d.waqfName),
        if (d.propertyId != null && !d.propertyMissing)
          FilledButton(
            onPressed: () => Navigator.pushNamed(
              context,
              AppRouter.propertyDetail,
              arguments: PropertyDetailArgs(propertyId: d.propertyId!),
            ),
            child: Text('تفاصيل العقار', style: GoogleFonts.cairo()),
          ),
        if (d.mutawallis.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('المتولّون', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          ...d.mutawallis.map((m) => ListTile(
                title: Text('${m['name']}', style: GoogleFonts.cairo()),
                subtitle: Text('${m['periodLabel']}', style: GoogleFonts.cairo(fontSize: 12)),
              )),
        ],
        if (d.propertyPartners.isNotEmpty || d.waqfPartners.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('الشركاء', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          ...[...d.propertyPartners, ...d.waqfPartners].map((p) => ListTile(
                title: Text('${p['name']}', style: GoogleFonts.cairo()),
                subtitle: Text('${p['periodLabel']}', style: GoogleFonts.cairo(fontSize: 12)),
              )),
        ],
      ],
    );
  }
}

class _ContractsTab extends StatelessWidget {
  const _ContractsTab({required this.d});
  final PropertyAssetDetailModel d;

  @override
  Widget build(BuildContext context) {
    final all = [...d.tenantContracts, ...d.collectionContracts, ...d.investorContracts];
    if (all.isEmpty) {
      return Center(child: Text('لا توجد عقود', style: GoogleFonts.cairo()));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: all.length,
      itemBuilder: (_, i) {
        final c = all[i];
        return Card(
          child: ListTile(
            title: Text(c.label, style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
            subtitle: Text(
              '${c.partyName ?? '—'} • ${c.status}\n${c.startDate.toString().substring(0, 10)} — ${c.endDate.toString().substring(0, 10)}',
              style: GoogleFonts.cairo(fontSize: 12),
            ),
            trailing: Text(formatIraqiCurrency(c.outstandingAmount), style: GoogleFonts.cairo(fontSize: 11)),
          ),
        );
      },
    );
  }
}

class _RevenueTab extends StatelessWidget {
  const _RevenueTab({required this.d});
  final PropertyAssetDetailModel d;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _row('إجمالي المحصّل', formatIraqiCurrency(d.totalRevenue)),
        const SizedBox(height: 12),
        ...d.revenues.map((r) => ListTile(
              title: Text(formatIraqiCurrency(parseAmount(r['grossAmount'])), style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
              subtitle: Text('${r['transactionDate']?.toString().substring(0, 10) ?? ''} — ${r['description'] ?? ''}',
                  style: GoogleFonts.cairo(fontSize: 12)),
            )),
      ],
    );
  }

  double parseAmount(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse('$v') ?? 0;
  }
}

class _DebtsTab extends StatelessWidget {
  const _DebtsTab({required this.d});
  final PropertyAssetDetailModel d;

  @override
  Widget build(BuildContext context) {
    if (d.debts.isEmpty) {
      return Center(child: Text('لا توجد ديون مستحقة', style: GoogleFonts.cairo()));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _row('إجمالي الديون', formatIraqiCurrency(d.totalDebt)),
        ...d.debts.map((debt) => Card(
              child: ListTile(
                title: Text('${debt['debtKind']}', style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                subtitle: Text('${debt['partyName']} — ${debt['contractLabel']}', style: GoogleFonts.cairo(fontSize: 12)),
                trailing: Text(formatIraqiCurrency(parseAmount(debt['outstanding'])), style: GoogleFonts.cairo()),
              ),
            )),
      ],
    );
  }

  double parseAmount(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse('$v') ?? 0;
  }
}

Widget _row(String label, String? value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
        Expanded(child: Text(value ?? '—', style: GoogleFonts.cairo(fontSize: 13))),
      ],
    ),
  );
}
