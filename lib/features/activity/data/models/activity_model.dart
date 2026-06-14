class ActivityModel {
  const ActivityModel({
    required this.id,
    required this.action,
    required this.entityType,
    this.entityId,
    this.description,
    this.module,
    this.userName,
    this.userId,
    required this.performedAt,
  });

  final String id;
  final String action;
  final String entityType;
  final String? entityId;
  final String? description;
  final String? module;
  final String? userName;
  final String? userId;
  final DateTime performedAt;

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: '${json['id'] ?? ''}',
      action: json['action'] as String? ?? '',
      entityType: json['entityType'] as String? ?? '',
      entityId: json['entityId'] as String?,
      description: json['description'] as String?,
      module: json['module'] as String?,
      userName: json['userName'] as String?,
      userId: json['userId'] as String?,
      performedAt: DateTime.tryParse(json['performedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  String get actionLabel => _translateToken(action, _actionLabels);

  String get entityTypeLabel => _translateToken(entityType, _entityLabels);

  String get moduleLabel {
    if (module == null || module!.trim().isEmpty) return 'عام';
    return _translateToken(module!, _moduleLabels);
  }

  String get displayText {
    if (description != null && description!.trim().isNotEmpty) {
      return description!.trim();
    }
    return '${actionLabel} — ${entityTypeLabel}';
  }

  static String _translateToken(String value, Map<String, String> map) {
    final key = value.trim();
    if (key.isEmpty) return '—';
    return map[key] ?? map[key.toLowerCase()] ?? key;
  }

  static const _actionLabels = {
    'Create': 'إنشاء',
    'Update': 'تعديل',
    'Delete': 'حذف',
    'Login': 'تسجيل دخول',
    'Logout': 'تسجيل خروج',
    'Approve': 'موافقة',
    'Reject': 'رفض',
    'Assign': 'إسناد',
    'Complete': 'إكمال',
    'Cancel': 'إلغاء',
  };

  static const _entityLabels = {
    'Property': 'عقار',
    'Contract': 'عقد',
    'Tenant': 'مستأجر',
    'User': 'مستخدم',
    'Employee': 'موظف',
    'Inspector': 'مفتش',
    'MaintenanceRequest': 'طلب صيانة',
    'InspectionTask': 'مهمة تفتيش',
    'LegalCase': 'قضية',
    'Project': 'مشروع',
    'Approval': 'موافقة',
  };

  static const _moduleLabels = {
    'Properties': 'الأملاك',
    'Contracts': 'العقود',
    'Revenue': 'الإيرادات',
    'Auth': 'الدخول',
    'Staff': 'الموظفون',
    'Maintenance': 'الصيانة',
    'Inspection': 'التفتيش',
    'Legal': 'القضايا',
    'Projects': 'المشاريع',
  };
}
