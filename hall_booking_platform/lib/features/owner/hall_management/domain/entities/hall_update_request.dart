import 'package:freezed_annotation/freezed_annotation.dart';

part 'hall_update_request.freezed.dart';
part 'hall_update_request.g.dart';

@freezed
class HallUpdateRequest with _$HallUpdateRequest {
  const factory HallUpdateRequest({
    String? name,
    String? description,
    double? lat,
    double? lng,
    String? address,
    List<String>? amenities,
    int? slotDurationMinutes,
    double? basePrice,
    @JsonKey(name: 'google_map_link') String? googleMapLink,
  }) = _HallUpdateRequest;

  factory HallUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$HallUpdateRequestFromJson(json);
}
