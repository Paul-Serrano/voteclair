import '../../domain/entities/recent_activity.dart';

class RecentActivityDto {
  const RecentActivityDto({
    this.lastScrutinDate,
    this.lastScrutinTitle,
  });

  final DateTime? lastScrutinDate;
  final String? lastScrutinTitle;

  factory RecentActivityDto.fromJson(Map<String, dynamic> json) {
    return RecentActivityDto(
      lastScrutinDate: json['last_scrutin_date'] is String
          ? DateTime.tryParse(json['last_scrutin_date'] as String)
          : null,
      lastScrutinTitle: json['last_scrutin_title'] as String?,
    );
  }

  RecentActivity toDomain() {
    return RecentActivity(
      lastScrutinDate: lastScrutinDate,
      lastScrutinTitle: lastScrutinTitle,
    );
  }
}
