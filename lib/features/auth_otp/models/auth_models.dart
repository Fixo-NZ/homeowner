import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

/// User model representing a homeowner
@JsonSerializable()
class User {
  final int id;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'middle_name')
  final String? middleName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String email;
  final String? phone; // Made nullable since Laravel can return null
  final String? address;
  final String? city;
  @JsonKey(name: 'region')
  final String? region; // Laravel uses 'region' not 'state'
  @JsonKey(name: 'postal_code')
  final String? postalCode; // Laravel uses 'postal_code' not 'zip_code'
  final String? status; // Laravel returns 'status' (string like 'active') not 'is_active' (bool)
  
  // Computed property for backward compatibility
  bool get isActive => status == 'active';
  
  // Backward compatibility getters
  String? get state => region;
  String? get zipCode => postalCode;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  User({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.email,
    this.phone, // Made nullable since Laravel can return null
    this.address,
    this.city,
    this.region,
    this.postalCode,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  String get fullName {
    if (middleName != null && middleName!.isNotEmpty) {
      return '$firstName $middleName $lastName';
    }
    return '$firstName $lastName';
  }
}

/// Login response model
@JsonSerializable()
class LoginResponse {
  final User user;
  final String token;
  final String message;

  LoginResponse({
    required this.user,
    required this.token,
    required this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

/// OTP request response model
@JsonSerializable()
class OtpResponse {
  final bool success;
  final String message;
  @JsonKey(name: 'otp_code')
  final String? otpCode; // Laravel returns 'otp_code' in response

  OtpResponse({
    required this.success,
    required this.message,
    this.otpCode,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) =>
      _$OtpResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OtpResponseToJson(this);
  
  // Backward compatibility getter
  String? get otp => otpCode;
}

/// OTP verification response model
@JsonSerializable()
class OtpVerificationResponse {
  final String status;
  final String message;
  final User? user;
  final String? token;

  OtpVerificationResponse({
    required this.status,
    required this.message,
    this.user,
    this.token,
  });

  factory OtpVerificationResponse.fromJson(Map<String, dynamic> json) =>
      _$OtpVerificationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OtpVerificationResponseToJson(this);

  bool get isNewUser => status == 'new_user';
  bool get isExistingUser => status == 'existing_user';
}

/// Registration request model
@JsonSerializable()
class RegistrationRequest {
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'middle_name')
  final String? middleName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String email;
  final String phone;
  final String password;
  @JsonKey(name: 'password_confirmation')
  final String passwordConfirmation;
  final String? address;
  final String? city;
  final String? state;
  @JsonKey(name: 'zip_code')
  final String? zipCode;

  RegistrationRequest({
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
    this.address,
    this.city,
    this.state,
    this.zipCode,
  });

  factory RegistrationRequest.fromJson(Map<String, dynamic> json) =>
      _$RegistrationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegistrationRequestToJson(this);
}

/// Registration response model
@JsonSerializable()
class RegistrationResponse {
  final User user;
  final String token;
  final String message;

  RegistrationResponse({
    required this.user,
    required this.token,
    required this.message,
  });

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) =>
      _$RegistrationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RegistrationResponseToJson(this);
}

/// Password reset request model
@JsonSerializable()
class PasswordResetRequest {
  final String email;

  PasswordResetRequest({required this.email});

  factory PasswordResetRequest.fromJson(Map<String, dynamic> json) =>
      _$PasswordResetRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PasswordResetRequestToJson(this);
}

/// Password reset response model
@JsonSerializable()
class PasswordResetResponse {
  final String message;
  final String? otp; // Only in development/testing

  PasswordResetResponse({required this.message, this.otp});

  factory PasswordResetResponse.fromJson(Map<String, dynamic> json) =>
      _$PasswordResetResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PasswordResetResponseToJson(this);
}

/// Generic API response model
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);
}
