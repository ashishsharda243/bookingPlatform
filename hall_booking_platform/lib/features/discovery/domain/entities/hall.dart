import 'package:freezed_annotation/freezed_annotation.dart';

part 'hall.freezed.dart';
part 'hall.g.dart';

@freezed
class Hall with _$Hall {
  const factory Hall({
    required String id,
    required String ownerId,
    required String name,
    required String description,
    @Default(0.0) double lat,
    @Default(0.0) double lng,
    required String address,
    required List<String> amenities,
    @Default(60) int slotDurationMinutes,
    @Default(0.0) double basePrice,
    required String approvalStatus,
    @Default(true) bool isActive,
    required DateTime createdAt,
    double? distance,
    double? averageRating,
    List<String>? imageUrls,
    @JsonKey(name: 'google_map_link') String? googleMapLink,
  }) = _Hall;

  factory Hall.fromJson(Map<String, dynamic> json) => _$HallFromJson(json);
}
