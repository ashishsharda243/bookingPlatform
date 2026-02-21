// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SlotImpl _$$SlotImplFromJson(Map<String, dynamic> json) => _$SlotImpl(
  id: json['id'] as String,
  hallId: json['hall_id'] as String,
  date: DateTime.parse(json['date'] as String),
  startTime: json['start_time'] as String,
  endTime: json['end_time'] as String,
  status: json['status'] as String,
);

Map<String, dynamic> _$$SlotImplToJson(_$SlotImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hall_id': instance.hallId,
      'date': instance.date.toIso8601String(),
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'status': instance.status,
    };
