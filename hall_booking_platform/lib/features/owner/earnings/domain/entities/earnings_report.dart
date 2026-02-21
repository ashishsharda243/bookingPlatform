import 'package:freezed_annotation/freezed_annotation.dart';

part 'earnings_report.freezed.dart';
part 'earnings_report.g.dart';

@freezed
class EarningEntry with _$EarningEntry {
  const factory EarningEntry({
    required String hallId,
    required String hallName,
    required double revenue,
    required int bookingCount,
    required DateTime date,
  }) = _EarningEntry;

  factory EarningEntry.fromJson(Map<String, dynamic> json) =>
      _$EarningEntryFromJson(json);
}

@freezed
class EarningsReport with _$EarningsReport {
  const factory EarningsReport({
    required double grossRevenue,
    required double commissionAmount,
    required double netEarnings,
    required double commissionPercentage,
    required List<EarningEntry> entries,
  }) = _EarningsReport;

  factory EarningsReport.fromJson(Map<String, dynamic> json) =>
      _$EarningsReportFromJson(json);
}
