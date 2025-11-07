// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_posting_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) =>
    CategoryModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$CategoryModelToJson(CategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'icon': instance.icon,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

ServiceModel _$ServiceModelFromJson(Map<String, dynamic> json) => ServiceModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  status: json['status'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ServiceModelToJson(ServiceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

JobPostRequest _$JobPostRequestFromJson(Map<String, dynamic> json) =>
    JobPostRequest(
      jobType: $enumDecode(_$JobTypeEnumMap, json['job_type']),
      frequency: $enumDecodeNullable(_$FrequencyEnumMap, json['frequency']),
      preferredDate: json['preferred_date'] == null
          ? null
          : DateTime.parse(json['preferred_date'] as String),
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      title: json['title'] as String,
      jobSize: $enumDecode(_$JobSizeEnumMap, json['job_size']),
      description: json['description'] as String?,
      address: json['address'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      photos: (json['photos'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      services: (json['services'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      categoryId: (json['service_category_id'] as num).toInt(),
      homeownerId: (json['homeowner_id'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$JobPostRequestToJson(JobPostRequest instance) =>
    <String, dynamic>{
      'job_type': _$JobTypeEnumMap[instance.jobType]!,
      'frequency': _$FrequencyEnumMap[instance.frequency],
      'preferred_date': instance.preferredDate?.toIso8601String(),
      'start_date': instance.startDate?.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'title': instance.title,
      'job_size': _$JobSizeEnumMap[instance.jobSize]!,
      'description': instance.description,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'photos': instance.photos,
      'services': instance.services,
      'service_category_id': instance.categoryId,
      'homeowner_id': instance.homeownerId,
    };

const _$JobTypeEnumMap = {
  JobType.standard: 'standard',
  JobType.urgent: 'urgent',
  JobType.recurrent: 'recurrent',
};

const _$FrequencyEnumMap = {
  Frequency.daily: 'daily',
  Frequency.weekly: 'weekly',
  Frequency.monthly: 'monthly',
  Frequency.quarterly: 'quarterly',
  Frequency.yearly: 'yearly',
  Frequency.custom: 'custom',
};

const _$JobSizeEnumMap = {
  JobSize.small: 'small',
  JobSize.medium: 'medium',
  JobSize.large: 'large',
};

JobPostResponse _$JobPostResponseFromJson(Map<String, dynamic> json) =>
    JobPostResponse(
      id: (json['id'] as num).toInt(),
      homeownerId: (json['homeowner_id'] as num).toInt(),
      jobType: json['job_type'] as String,
      frequency: json['frequency'] as String?,
      preferredDate: json['preferred_date'] == null
          ? null
          : DateTime.parse(json['preferred_date'] as String),
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      title: json['title'] as String,
      jobSize: json['job_size'] as String,
      description: json['description'] as String?,
      address: json['address'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      photoUrls: (json['photoUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      services: (json['services'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      photos: (json['photos'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$JobPostResponseToJson(JobPostResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'homeowner_id': instance.homeownerId,
      'job_type': instance.jobType,
      'frequency': instance.frequency,
      'preferred_date': instance.preferredDate?.toIso8601String(),
      'start_date': instance.startDate?.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'title': instance.title,
      'job_size': instance.jobSize,
      'description': instance.description,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'photoUrls': instance.photoUrls,
      'services': instance.services,
      'photos': instance.photos,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

ApiError _$ApiErrorFromJson(Map<String, dynamic> json) => ApiError(
  message: json['message'] as String,
  errors: (json['errors'] as Map<String, dynamic>?)?.map(
    (k, e) =>
        MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
  ),
);

Map<String, dynamic> _$ApiErrorToJson(ApiError instance) => <String, dynamic>{
  'message': instance.message,
  'errors': instance.errors,
};
