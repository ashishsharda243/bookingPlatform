// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hall_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HallCreateRequestImpl _$$HallCreateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$HallCreateRequestImpl(
  name: json['name'] as String,
  description: json['description'] as String,
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
  address: json['address'] as String,
  amenities: (json['amenities'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  slotDurationMinutes: (json['slot_duration_minutes'] as num).toInt(),
  basePrice: (json['base_price'] as num).toDouble(),
  googleMapLink: json['google_map_link'] as String?,
);

Map<String, dynamic> _$$HallCreateRequestImplToJson(
  _$HallCreateRequestImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'lat': instance.lat,
  'lng': instance.lng,
  'address': instance.address,
  'amenities': instance.amenities,
  'slot_duration_minutes': instance.slotDurationMinutes,
  'base_price': instance.basePrice,
  if (instance.googleMapLink case final value?) 'google_map_link': value,
};
