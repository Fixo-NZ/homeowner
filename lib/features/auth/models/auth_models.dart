import 'package:json_annotation/json_annotation.dart';
import '../../../core/models/home_owner_model.dart';

part 'auth_models.g.dart';

@JsonSerializable()
class LoginRequest {
  final String? email;
  final String? phone;
  final String password;

  const LoginRequest({
    this.email,
    this.phone,
    required this.password,
  }) : assert(email != null || phone != null, 'Either email or phone must be provided');

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() {
    return {
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
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
  @JsonKey(name: 'middle_name')
  final String? middleName;
  final String email;
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
    this.phone,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
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
  final String? message;
  final Map<String, List<String>>? errors;

  const ApiError({this.message, this.errors});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    final rawErrors = json['details'] ?? json['errors'];
    return ApiError(
      message: json['message'] as String?,
      errors: rawErrors != null
          ? (rawErrors as Map<String, dynamic>).map(
              (k, v) => MapEntry(k, List<String>.from(v)),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'errors': errors,
      };
}