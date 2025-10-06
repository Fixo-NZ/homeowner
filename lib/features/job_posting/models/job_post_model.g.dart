// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobPost _$JobPostFromJson(Map<String, dynamic> json) => JobPost(
  id: (json['id'] as num).toInt(),
  homeownerName: json['homeownerName'] as String,
  jobType: json['jobType'] as String,
  frequency: json['frequency'] as String,
  timeSpan: DateTime.parse(json['timeSpan'] as String),
  jobTitle: json['jobTitle'] as String,
  services: json['services'] as String,
  jobSize: json['jobSize'] as String,
  jobDescription: json['jobDescription'] as String,
  homeAddress: json['homeAddress'] as String,
  jobPhotos: json['jobPhotos'] as String,
);

Map<String, dynamic> _$JobPostToJson(JobPost instance) => <String, dynamic>{
  'id': instance.id,
  'homeownerName': instance.homeownerName,
  'jobType': instance.jobType,
  'frequency': instance.frequency,
  'timeSpan': instance.timeSpan.toIso8601String(),
  'jobTitle': instance.jobTitle,
  'services': instance.services,
  'jobSize': instance.jobSize,
  'jobDescription': instance.jobDescription,
  'homeAddress': instance.homeAddress,
  'jobPhotos': instance.jobPhotos,
};
