import 'package:json_annotation/json_annotation.dart';
import 'service_model.dart';

part 'job_category_model.g.dart';

@JsonSerializable()
class JobCategory {
  final int id;
  final String icon;
  final String categoryName;
  final String categorySubtitle;
  final List<ServiceModel> services;

  JobCategory({
    required this.id,
    required this.icon,
    required this.categoryName,
    required this.categorySubtitle,
    required this.services,
  }); 

  factory JobCategory.fromJson(Map<String, dynamic> json) => _$JobCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$JobCategoryToJson(this);
}




