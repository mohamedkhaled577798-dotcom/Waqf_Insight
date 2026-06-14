import 'package:waqf_insight/core/utils/json_parse_helpers.dart';
import 'package:waqf_insight/features/dashboard/data/models/dashboard_stats_models.dart';

class StaffMemberModel {
  const StaffMemberModel({
    required this.userId,
    required this.fullName,
    this.email,
    this.phone,
    this.jobTitle,
    this.department,
    required this.roles,
    required this.staffType,
    required this.isActive,
    required this.responsibilities,
    this.assignedTasksCount,
    this.lastActivityAt,
  });

  final String userId;
  final String fullName;
  final String? email;
  final String? phone;
  final String? jobTitle;
  final String? department;
  final List<String> roles;
  final String staffType;
  final bool isActive;
  final List<String> responsibilities;
  final int? assignedTasksCount;
  final DateTime? lastActivityAt;

  factory StaffMemberModel.fromJson(Map<String, dynamic> json) {
    return StaffMemberModel(
      userId: '${json['userId'] ?? ''}',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      jobTitle: json['jobTitle'] as String?,
      department: json['department'] as String?,
      roles: (json['roles'] as List<dynamic>? ?? [])
          .map((e) => '$e')
          .toList(),
      staffType: json['staffType'] as String? ?? 'موظف',
      isActive: json['isActive'] as bool? ?? true,
      responsibilities: (json['responsibilities'] as List<dynamic>? ?? [])
          .map((e) => '$e')
          .toList(),
      assignedTasksCount: json['assignedTasksCount'] != null
          ? parseJsonInt(json['assignedTasksCount'])
          : null,
      lastActivityAt: json['lastActivityAt'] != null
          ? DateTime.tryParse(json['lastActivityAt'] as String)
          : null,
    );
  }

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.isNotEmpty ? parts.first[0] : '?';
    }
    return '${parts.first[0]}${parts.last[0]}';
  }
}

class StaffDetailModel extends StaffMemberModel {
  const StaffDetailModel({
    required super.userId,
    required super.fullName,
    super.email,
    super.phone,
    super.jobTitle,
    super.department,
    required super.roles,
    required super.staffType,
    required super.isActive,
    required super.responsibilities,
    super.assignedTasksCount,
    super.lastActivityAt,
    required this.permissions,
    required this.governorates,
    this.companyName,
    this.specialization,
    this.hireDate,
    this.createdAt,
  });

  final List<String> permissions;
  final List<String> governorates;
  final String? companyName;
  final String? specialization;
  final DateTime? hireDate;
  final DateTime? createdAt;

  factory StaffDetailModel.fromJson(Map<String, dynamic> json) {
    return StaffDetailModel(
      userId: '${json['userId'] ?? ''}',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      jobTitle: json['jobTitle'] as String?,
      department: json['department'] as String?,
      roles: (json['roles'] as List<dynamic>? ?? [])
          .map((e) => '$e')
          .toList(),
      staffType: json['staffType'] as String? ?? 'موظف',
      isActive: json['isActive'] as bool? ?? true,
      responsibilities: (json['responsibilities'] as List<dynamic>? ?? [])
          .map((e) => '$e')
          .toList(),
      assignedTasksCount: json['assignedTasksCount'] != null
          ? parseJsonInt(json['assignedTasksCount'])
          : null,
      lastActivityAt: json['lastActivityAt'] != null
          ? DateTime.tryParse(json['lastActivityAt'] as String)
          : null,
      permissions: (json['permissions'] as List<dynamic>? ?? [])
          .map((e) => '$e')
          .toList(),
      governorates: (json['governorates'] as List<dynamic>? ?? [])
          .map((e) => '$e')
          .toList(),
      companyName: json['companyName'] as String?,
      specialization: json['specialization']?.toString(),
      hireDate: json['hireDate'] != null
          ? DateTime.tryParse(json['hireDate'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}

class StaffListResult {
  const StaffListResult({
    required this.members,
    this.overview,
  });

  final List<StaffMemberModel> members;
  final StaffOverviewModel? overview;
}
