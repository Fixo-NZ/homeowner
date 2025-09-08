import 'package:json_annotation/json_annotation.dart';

part 'home_owner_model.g.dart';

@JsonSerializable()
class HomeOwnerModel {
  final int? id;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'middle_name')
  final String? middleName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String email;
  final String? phone;
  final String? avatar;
  final String? bio;
  final String? address;
  final String? city;
  final String? region;
  @JsonKey(name: 'postal_code')
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const HomeOwnerModel({
    this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.email,
    this.phone,
    this.avatar,
    this.bio,
    this.address,
    this.city,
    this.region,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  factory HomeOwnerModel.fromJson(Map<String, dynamic> json) =>
      _$HomeOwnerModelFromJson(json);

  Map<String, dynamic> toJson() => _$HomeOwnerModelToJson(this);

  String get fullName => '$firstName ${middleName ?? ''} $lastName'.trim();

  HomeOwnerModel copyWith({
    int? id,
    String? firstName,
    String? middleName,
    String? lastName,
    String? email,
    String? phone,
    String? avatar,
    String? bio,
    String? address,
    String? city,
    String? region,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? businessName,
    String? licenseNumber,
    String? insuranceDetails,
    int? yearsExperience,
    double? hourlyRate,
    String? availabilityStatus,
    int? serviceRadius,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HomeOwnerModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      address: address ?? this.address,
      city: city ?? this.city,
      region: region ?? this.region,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
