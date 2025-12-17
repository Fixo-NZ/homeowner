// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_applicant_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobApplicant _$JobApplicantFromJson(Map<String, dynamic> json) => JobApplicant(
      id: (json['id'] as num).toInt(),
      tradieId: (json['tradie_id'] as num).toInt(),
      message: json['message'] as String?,
      status: json['status'] as String,
      appliedAt: json['applied_at'] as String,
      tradie: json['tradie'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$JobApplicantToJson(JobApplicant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tradie_id': instance.tradieId,
      'message': instance.message,
      'status': instance.status,
      'applied_at': instance.appliedAt,
      'tradie': instance.tradie,
    };

ApplicantActionResponse _$ApplicantActionResponseFromJson(
        Map<String, dynamic> json) =>
    ApplicantActionResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'],
    );

Map<String, dynamic> _$ApplicantActionResponseToJson(
        ApplicantActionResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };
