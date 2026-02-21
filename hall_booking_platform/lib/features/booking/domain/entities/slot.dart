import 'package:freezed_annotation/freezed_annotation.dart';

part 'slot.freezed.dart';
part 'slot.g.dart';

@freezed
class Slot with _$Slot {
  const factory Slot({
    required String id,
    required String hallId,
    required DateTime date,
    required String startTime,
    required String endTime,
    required String status,
  }) = _Slot;

  factory Slot.fromJson(Map<String, dynamic> json) => _$SlotFromJson(json);
}
