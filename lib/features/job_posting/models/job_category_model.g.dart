// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobCategory _$JobCategoryFromJson(Map<String, dynamic> json) => JobCategory(
  id: (json['id'] as num).toInt(),
  icon: json['icon'] as String,
  categoryName: json['categoryName'] as String,
  categorySubtitle: json['categorySubtitle'] as String,
  services: (json['services'] as List<dynamic>)
      .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$JobCategoryToJson(JobCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'icon': instance.icon,
      'categoryName': instance.categoryName,
      'categorySubtitle': instance.categorySubtitle,
      'services': instance.services,
    };
