import 'package:json_annotation/json_annotation.dart';

part 'tradie_model.g.dart';

@JsonSerializable()
class TradieModel {
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
  @JsonKey(name: 'business_name')
  final String? businessName;
  @JsonKey(name: 'license_number')
  final String? licenseNumber;
  @JsonKey(name: 'insurance_details')
  final String? insuranceDetails;
  @JsonKey(name: 'years_experience')
  final int? yearsExperience;
  @JsonKey(name: 'hourly_rate')
  final double? hourlyRate;
  @JsonKey(name: 'availability_status')
  final String availabilityStatus;
  @JsonKey(name: 'service_radius')
  final int serviceRadius;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const TradieModel({
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
    this.businessName,
    this.licenseNumber,
    this.insuranceDetails,
    this.yearsExperience,
    this.hourlyRate,
    this.availabilityStatus = 'available',
    this.serviceRadius = 50,
    this.createdAt,
    this.updatedAt,
  });

  factory TradieModel.fromJson(Map<String, dynamic> json) =>
      _$TradieModelFromJson(json);

  Map<String, dynamic> toJson() => _$TradieModelToJson(this);

  String get fullName => '$firstName ${middleName ?? ''} $lastName'.trim();

  TradieModel copyWith({
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
    return TradieModel(
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
      businessName: businessName ?? this.businessName,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      insuranceDetails: insuranceDetails ?? this.insuranceDetails,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      serviceRadius: serviceRadius ?? this.serviceRadius,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
