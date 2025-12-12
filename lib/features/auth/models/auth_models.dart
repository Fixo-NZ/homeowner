import 'package:json_annotation/json_annotation.dart';
import '../../../core/models/home_owner_model.dart';

part 'auth_models.g.dart';

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() {
    return {
      if (email.isNotEmpty) 'email': email,
      'password': password,
    };
  }
}

@JsonSerializable()
class RegisterRequest {
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'middle_name', includeIfNull: true)
  final String? middleName;
  final String email;
  @JsonKey(name: 'email_verified_at')
  final String? emailVerifiedAt;
  final String password;
  @JsonKey(name: 'password_confirmation')
  final String passwordConfirmation;
  final String? phone;

  const RegisterRequest({
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.phone,
    this.emailVerifiedAt,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class OtpRequest {
  final String email;
  final String otp;

  const OtpRequest({
    required this.email,
    required this.otp,
  });

  factory OtpRequest.fromJson(Map<String, dynamic> json) =>
      _$OtpRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OtpRequestToJson(this);
}

@JsonSerializable()
class OtpVerifyResponse {
  final bool success;
  final String? status;
  final String? message;

  const OtpVerifyResponse({
    required this.success,
    this.status,
    this.message,
  });

  factory OtpVerifyResponse.fromJson(Map<String, dynamic> json) =>
      _$OtpVerifyResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OtpVerifyResponseToJson(this);
}

@JsonSerializable()
class AuthResponse {
  @JsonKey(name: 'token')
  final String accessToken;
  @JsonKey(name: 'token_type')
  final String? tokenType;
  @JsonKey(name: 'expires_in')
  final int? expiresIn;

  final HomeOwnerModel user;

  const AuthResponse({
    required this.accessToken,
    this.tokenType,
    this.expiresIn,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable()
class ApiError {
  final String? code;
  final String? message;
  final Map<String, List<String>>? details;

  const ApiError({this.code, this.message, this.details});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    final error = json['error'] as Map<String, dynamic>?;

    return ApiError(
      code: error?['code'] as String?,
      message: error?['message'] as String?,
      details: error?['details'] != null
          ? (error!['details'] as Map<String, dynamic>).map(
              (k, v) => MapEntry(k, List<String>.from(v)),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
        'details': details,
      };
}