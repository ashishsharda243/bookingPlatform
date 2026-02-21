import 'package:freezed_annotation/freezed_annotation.dart';

part 'hall_create_request.freezed.dart';
part 'hall_create_request.g.dart';

@freezed
class HallCreateRequest with _$HallCreateRequest {
  const factory HallCreateRequest({
    required String name,
    required String description,
    required double lat,
    required double lng,
    required String address,
    required List<String> amenities,
    required int slotDurationMinutes,
    required double basePrice,
    @JsonKey(name: 'google_map_link') String? googleMapLink,
  }) = _HallCreateRequest;

  factory HallCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$HallCreateRequestFromJson(json);
}
