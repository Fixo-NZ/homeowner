import 'package:json_annotation/json_annotation.dart';

part 'job_applicant_models.g.dart';

@JsonSerializable()
class JobApplicant {
  final int id;
  @JsonKey(name: 'tradie_id')
  final int tradieId;
  final String? message;
  final String status;
  @JsonKey(name: 'applied_at')
  final String appliedAt;
  final Map<String, dynamic>? tradie;

  const JobApplicant({
    required this.id,
    required this.tradieId,
    this.message,
    required this.status,
    required this.appliedAt,
    this.tradie,
  });

  JobApplicant copyWith({
    int? id,
    int? tradieId,
    String? message,
    String? status,
    String? appliedAt,
    Map<String, dynamic>? tradie,
  }) {
    return JobApplicant(
      id: id ?? this.id,
      tradieId: tradieId ?? this.tradieId,
      message: message ?? this.message,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      tradie: tradie ?? this.tradie,
    );
  }

  factory JobApplicant.fromJson(Map<String, dynamic> json) =>
      _$JobApplicantFromJson(json);
  Map<String, dynamic> toJson() => _$JobApplicantToJson(this);

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
}

@JsonSerializable()
class ApplicantActionResponse {
  final bool success;
  final String message;
  final dynamic data;

  const ApplicantActionResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  

  factory ApplicantActionResponse.fromJson(Map<String, dynamic> json) =>
      _$ApplicantActionResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ApplicantActionResponseToJson(this);
}