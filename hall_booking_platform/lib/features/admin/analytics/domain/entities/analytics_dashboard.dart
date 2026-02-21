import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_dashboard.freezed.dart';
part 'analytics_dashboard.g.dart';

@freezed
class AnalyticsDashboard with _$AnalyticsDashboard {
  const factory AnalyticsDashboard({
    required int totalBookings,
    required double totalRevenue,
    required int activeUsers,
    required int activeHalls,
    required String period,
  }) = _AnalyticsDashboard;

  factory AnalyticsDashboard.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsDashboardFromJson(json);
}
