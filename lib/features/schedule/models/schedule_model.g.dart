// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OfferResponse _$OfferResponseFromJson(Map<String, dynamic> json) =>
    OfferResponse(
      offers: (json['offers'] as List<dynamic>)
          .map((e) => OfferModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OfferResponseToJson(OfferResponse instance) =>
    <String, dynamic>{
      'offers': instance.offers.map((e) => e.toJson()).toList(),
    };

OfferModel _$OfferModelFromJson(Map<String, dynamic> json) => OfferModel(
  id: (json['id'] as num).toInt(),
  homeownerId: (json['homeowner_id'] as num).toInt(),
  serviceCategoryId: (json['service_category_id'] as num).toInt(),
  tradieId: (json['tradie_id'] as num).toInt(),
  jobType: json['job_type'] as String,
  preferredDate: json['preferred_date'] as String?,
  frequency: json['frequency'] as String?,
  startDate: json['start_date'] as String?,
  endDate: json['end_date'] as String?,
  title: json['title'] as String,
  jobSize: json['job_size'] as String,
  description: json['description'] as String,
  address: json['address'] as String,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  status: json['status'] as String,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  startTime: json['start_time'] as String,
  endTime: json['end_time'] as String,
  rescheduledAt: json['rescheduled_at'] as String?,
  photoUrls: (json['photo_urls'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  tradie: Tradie.fromJson(json['tradie'] as Map<String, dynamic>),
  category: Category.fromJson(json['category'] as Map<String, dynamic>),
  photos: (json['photos'] as List<dynamic>?)
      ?.map((e) => Photo.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OfferModelToJson(OfferModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'homeowner_id': instance.homeownerId,
      'service_category_id': instance.serviceCategoryId,
      'tradie_id': instance.tradieId,
      'job_type': instance.jobType,
      'preferred_date': instance.preferredDate,
      'frequency': instance.frequency,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'title': instance.title,
      'job_size': instance.jobSize,
      'description': instance.description,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'status': instance.status,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'rescheduled_at': instance.rescheduledAt,
      'photo_urls': instance.photoUrls,
      'tradie': instance.tradie.toJson(),
      'category': instance.category.toJson(),
      'photos': instance.photos?.map((e) => e.toJson()).toList(),
    };

Tradie _$TradieFromJson(Map<String, dynamic> json) => Tradie(
  id: (json['id'] as num).toInt(),
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  middleName: json['middle_name'] as String?,
  email: json['email'] as String,
  address: json['address'] as String,
  phone: json['phone'] as String,
);

Map<String, dynamic> _$TradieToJson(Tradie instance) => <String, dynamic>{
  'id': instance.id,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'middle_name': instance.middleName,
  'email': instance.email,
  'address': instance.address,
  'phone': instance.phone,
};

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String,
  icon: json['icon'] as String,
  status: json['status'] as String,
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'icon': instance.icon,
  'status': instance.status,
};

Photo _$PhotoFromJson(Map<String, dynamic> json) => Photo(
  id: (json['id'] as num).toInt(),
  jobOfferId: (json['job_offer_id'] as num).toInt(),
  filePath: json['file_path'] as String,
  originalName: json['original_name'] as String,
  fileSize: (json['file_size'] as num).toInt(),
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  url: json['url'] as String,
);

Map<String, dynamic> _$PhotoToJson(Photo instance) => <String, dynamic>{
  'id': instance.id,
  'job_offer_id': instance.jobOfferId,
  'file_path': instance.filePath,
  'original_name': instance.originalName,
  'file_size': instance.fileSize,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'url': instance.url,
};
