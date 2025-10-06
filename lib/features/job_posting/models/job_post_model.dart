import 'package:json_annotation/json_annotation.dart';


part 'job_post_model.g.dart';

@JsonSerializable()
class JobPost {
  final int id;
  final String homeownerName;
  final String jobType;
  final String frequency;
  final DateTime timeSpan;
  final String jobTitle;
  final String services;
  final String jobSize;
  final String jobDescription;
  final String homeAddress;
  final String jobPhotos;
  

  JobPost({
    required this.id,
    required this.homeownerName,
    required this.jobType,
    required this.frequency,
    required this.timeSpan,
    required this.jobTitle,
    required this.services,
    required this.jobSize,
    required this.jobDescription,
    required this.homeAddress,
    required this.jobPhotos
  }); 

  factory JobPost.fromJson(Map<String, dynamic> json) => _$JobPostFromJson(json);
  Map<String, dynamic> toJson() => _$JobPostToJson(this);
}




