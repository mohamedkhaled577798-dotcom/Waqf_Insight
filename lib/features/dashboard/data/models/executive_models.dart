import 'package:waqf_insight/core/utils/json_parse_helpers.dart';

class ExecutiveOverviewModel {
  const ExecutiveOverviewModel({
    required this.briefing,
    required this.alerts,
    required this.trends,
    this.generatedAt,
  });

  final ChairmanBriefingModel briefing;
  final ChairmanAlertsModel alerts;
  final ChairmanTrendsModel trends;
  final DateTime? generatedAt;

  factory ExecutiveOverviewModel.fromJson(Map<String, dynamic> json) {
    return ExecutiveOverviewModel(
      briefing: ChairmanBriefingModel.fromJson(
        json['briefing'] as Map<String, dynamic>? ?? {},
      ),
      alerts: ChairmanAlertsModel.fromJson(
        json['alerts'] as Map<String, dynamic>? ?? {},
      ),
      trends: ChairmanTrendsModel.fromJson(
        json['trends'] as Map<String, dynamic>? ?? {},
      ),
      generatedAt: parseJsonDateTime(json['generatedAt']),
    );
  }
}

class ChairmanBriefingModel {
  const ChairmanBriefingModel({
    required this.totalAlertCount,
    required this.lines,
  });

  final int totalAlertCount;
  final List<ChairmanBriefingLineModel> lines;

  factory ChairmanBriefingModel.fromJson(Map<String, dynamic> json) {
    final raw = json['lines'] as List<dynamic>? ?? [];
    return ChairmanBriefingModel(
      totalAlertCount: parseJsonInt(json['totalAlertCount']),
      lines: raw
          .map((e) => ChairmanBriefingLineModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ChairmanBriefingLineModel {
  const ChairmanBriefingLineModel({
    required this.category,
    required this.text,
    required this.count,
    this.amount,
    required this.severity,
  });

  final String category;
  final String text;
  final int count;
  final double? amount;
  final String severity;

  factory ChairmanBriefingLineModel.fromJson(Map<String, dynamic> json) {
    return ChairmanBriefingLineModel(
      category: json['category'] as String? ?? '',
      text: json['text'] as String? ?? '',
      count: parseJsonInt(json['count']),
      amount: json['amount'] != null ? parseJsonDouble(json['amount']) : null,
      severity: json['severity'] as String? ?? 'info',
    );
  }
}

class ChairmanAlertsModel {
  const ChairmanAlertsModel({
    required this.totalCount,
    required this.items,
  });

  final int totalCount;
  final List<ChairmanAlertItemModel> items;

  factory ChairmanAlertsModel.fromJson(Map<String, dynamic> json) {
    final raw = json['items'] as List<dynamic>? ?? [];
    return ChairmanAlertsModel(
      totalCount: parseJsonInt(json['totalCount']),
      items: raw
          .map((e) => ChairmanAlertItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ChairmanAlertItemModel {
  const ChairmanAlertItemModel({
    required this.id,
    required this.category,
    required this.severity,
    required this.title,
    required this.description,
    required this.count,
    this.amount,
    this.actionTarget,
    required this.samples,
  });

  final String id;
  final String category;
  final String severity;
  final String title;
  final String description;
  final int count;
  final double? amount;
  final String? actionTarget;
  final List<ChairmanAlertDetailModel> samples;

  bool get hasIssue => count > 0;

  factory ChairmanAlertItemModel.fromJson(Map<String, dynamic> json) {
    final raw = json['samples'] as List<dynamic>? ?? [];
    return ChairmanAlertItemModel(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? '',
      severity: json['severity'] as String? ?? 'info',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      count: parseJsonInt(json['count']),
      amount: json['amount'] != null ? parseJsonDouble(json['amount']) : null,
      actionTarget: json['actionTarget'] as String?,
      samples: raw
          .map((e) => ChairmanAlertDetailModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ChairmanAlertDetailModel {
  const ChairmanAlertDetailModel({
    required this.id,
    required this.label,
    this.subLabel,
    this.date,
    this.amount,
  });

  final String id;
  final String label;
  final String? subLabel;
  final DateTime? date;
  final double? amount;

  factory ChairmanAlertDetailModel.fromJson(Map<String, dynamic> json) {
    return ChairmanAlertDetailModel(
      id: '${json['id']}',
      label: json['label'] as String? ?? '',
      subLabel: json['subLabel'] as String?,
      date: parseJsonDateTime(json['date']),
      amount: json['amount'] != null ? parseJsonDouble(json['amount']) : null,
    );
  }
}

class ChairmanTrendsModel {
  const ChairmanTrendsModel({required this.metrics});

  final List<ChairmanTrendMetricModel> metrics;

  factory ChairmanTrendsModel.fromJson(Map<String, dynamic> json) {
    final raw = json['metrics'] as List<dynamic>? ?? [];
    return ChairmanTrendsModel(
      metrics: raw
          .map((e) => ChairmanTrendMetricModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ChairmanTrendMetricModel {
  const ChairmanTrendMetricModel({
    required this.key,
    required this.label,
    required this.currentValue,
    required this.previousValue,
    required this.changePercent,
    required this.isCurrency,
    required this.higherIsBetter,
  });

  final String key;
  final String label;
  final double currentValue;
  final double previousValue;
  final double changePercent;
  final bool isCurrency;
  final bool higherIsBetter;

  bool get isPositiveTrend =>
      higherIsBetter ? changePercent >= 0 : changePercent <= 0;

  factory ChairmanTrendMetricModel.fromJson(Map<String, dynamic> json) {
    return ChairmanTrendMetricModel(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      currentValue: parseJsonDouble(json['currentValue']),
      previousValue: parseJsonDouble(json['previousValue']),
      changePercent: parseJsonDouble(json['changePercent']),
      isCurrency: json['isCurrency'] as bool? ?? false,
      higherIsBetter: json['higherIsBetter'] as bool? ?? true,
    );
  }
}

class ChairmanCalendarModel {
  const ChairmanCalendarModel({
    required this.year,
    required this.month,
    required this.events,
  });

  final int year;
  final int month;
  final List<ChairmanCalendarEventModel> events;

  factory ChairmanCalendarModel.fromJson(Map<String, dynamic> json) {
    final raw = json['events'] as List<dynamic>? ?? [];
    return ChairmanCalendarModel(
      year: parseJsonInt(json['year']),
      month: parseJsonInt(json['month']),
      events: raw
          .map((e) => ChairmanCalendarEventModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ChairmanCalendarEventModel {
  const ChairmanCalendarEventModel({
    required this.id,
    required this.eventType,
    required this.date,
    required this.title,
    this.subtitle,
    required this.severity,
    this.relatedId,
  });

  final String id;
  final String eventType;
  final DateTime date;
  final String title;
  final String? subtitle;
  final String severity;
  final String? relatedId;

  factory ChairmanCalendarEventModel.fromJson(Map<String, dynamic> json) {
    return ChairmanCalendarEventModel(
      id: '${json['id']}',
      eventType: json['eventType'] as String? ?? '',
      date: parseJsonDateTime(json['date']) ?? DateTime.now(),
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      severity: json['severity'] as String? ?? 'info',
      relatedId: json['relatedId']?.toString(),
    );
  }
}
