// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earnings_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EarningEntryImpl _$$EarningEntryImplFromJson(Map<String, dynamic> json) =>
    _$EarningEntryImpl(
      hallId: json['hall_id'] as String,
      hallName: json['hall_name'] as String,
      revenue: (json['revenue'] as num).toDouble(),
      bookingCount: (json['booking_count'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$$EarningEntryImplToJson(_$EarningEntryImpl instance) =>
    <String, dynamic>{
      'hall_id': instance.hallId,
      'hall_name': instance.hallName,
      'revenue': instance.revenue,
      'booking_count': instance.bookingCount,
      'date': instance.date.toIso8601String(),
    };

_$EarningsReportImpl _$$EarningsReportImplFromJson(Map<String, dynamic> json) =>
    _$EarningsReportImpl(
      grossRevenue: (json['gross_revenue'] as num).toDouble(),
      commissionAmount: (json['commission_amount'] as num).toDouble(),
      netEarnings: (json['net_earnings'] as num).toDouble(),
      commissionPercentage: (json['commission_percentage'] as num).toDouble(),
      entries: (json['entries'] as List<dynamic>)
          .map((e) => EarningEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$EarningsReportImplToJson(
  _$EarningsReportImpl instance,
) => <String, dynamic>{
  'gross_revenue': instance.grossRevenue,
  'commission_amount': instance.commissionAmount,
  'net_earnings': instance.netEarnings,
  'commission_percentage': instance.commissionPercentage,
  'entries': instance.entries.map((e) => e.toJson()).toList(),
};
