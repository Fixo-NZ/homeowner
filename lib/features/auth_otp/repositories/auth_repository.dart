import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../models/auth_models.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();
  final SecureStorageService _storage = SecureStorageService();

  /// Request OTP for phone number
  Future<OtpResponse> requestOtp(String phoneNumber) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.requestOtp,
        data: {'phone': phoneNumber}, // Laravel expects 'phone' not 'phone_number'
      );

      final responseData = response.data as Map<String, dynamic>;
      
      // Laravel returns { success: true, message: "...", otp_code: "123456" }
      return OtpResponse(
        success: responseData['success'] as bool? ?? true,
        message: responseData['message'] as String? ?? 'OTP sent successfully',
        otpCode: responseData['otp_code'] as String?,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Verify OTP code
  Future<OtpVerificationResponse> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.verifyOtp,
        data: {'phone': phoneNumber, 'otp_code': otp}, // Laravel expects 'phone' and 'otp_code'
      );

      final responseData = response.data as Map<String, dynamic>;
      
      // Parse Laravel response structure
      User? user;
      String? token;
      
      if (responseData['status'] == 'existing_user') {
        // Extract user from data.user
        if (responseData['data'] != null && 
            responseData['data'] is Map<String, dynamic> &&
            responseData['data']['user'] != null) {
          final userData = responseData['data']['user'] as Map<String, dynamic>;
          
          // Laravel verify-otp returns simplified user object, but we need full user
          // So we'll fetch the full user profile after getting the token
          // For now, create a minimal user object
          user = User(
            id: userData['id'] as int? ?? 0, // May not be present in verify-otp response
            firstName: userData['first_name'] as String? ?? '',
            lastName: userData['last_name'] as String? ?? '',
            email: userData['email'] as String? ?? '',
            phone: userData['phone'] as String?, // Can be null
            status: userData['status'] as String? ?? 'active',
            middleName: userData['middle_name'] as String?,
            address: userData['address'] as String?,
            city: userData['city'] as String?,
            region: userData['region'] as String?,
            postalCode: userData['postal_code'] as String?,
          );
        }
        
        // Extract token from authorisation.access_token
        if (responseData['authorisation'] != null &&
            responseData['authorisation'] is Map<String, dynamic>) {
          token = responseData['authorisation']['access_token'] as String?;
        }
        
        // Save token and user data
        if (token != null) {
          await _storage.saveToken(token);
          
          // Fetch full user profile after getting token
          try {
            final fullUser = await getCurrentUser();
            user = fullUser;
            await _storage.saveUserData(jsonEncode(fullUser.toJson()));
          } catch (e) {
            // If fetching full user fails, save the partial user data
            if (user != null) {
              await _storage.saveUserData(jsonEncode(user.toJson()));
            }
          }
        } else if (user != null) {
          await _storage.saveUserData(jsonEncode(user.toJson()));
        }
      }
      
      final otpResponse = OtpVerificationResponse(
        status: responseData['status'] as String? ?? 'new_user',
        message: responseData['message'] as String? ?? '',
        user: user,
        token: token,
      );

      return otpResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// Login with email and password
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      final responseData = response.data as Map<String, dynamic>;
      
      // Debug: Print the actual response structure
      print('🔍 Login Response Structure: $responseData');
      
      // Laravel can return various structures:
      // 1. { success: true, data: { user: {...}, token: "..." } }
      // 2. { success: true, data: { user: {...} }, token: "..." }
      // 3. { success: true, data: { user: {...}, authorisation: { access_token: "..." } } }
      // 4. { user: {...}, token: "..." } (direct structure)
      // 5. { success: true, data: {...} } where data IS the user object
      User? user;
      String? token;
      
      // First, try to get user from nested data.user
      Map<String, dynamic>? userJson;
      if (responseData['data'] != null && responseData['data'] is Map<String, dynamic>) {
        final data = responseData['data'] as Map<String, dynamic>;
        
        // Check if data itself is the user object (no nested 'user' key)
        if (data.containsKey('id') && 
            (data.containsKey('first_name') || data.containsKey('firstName') || 
             data.containsKey('email'))) {
          // data IS the user object
          userJson = data;
          print('✅ Found user directly in data: $userJson');
        } 
        // Check if data.user exists
        else if (data['user'] != null && data['user'] is Map<String, dynamic>) {
          userJson = data['user'] as Map<String, dynamic>;
          print('✅ Found user in data.user: $userJson');
        }
        
        // Try to get token from data.token or data.authorisation.access_token
        if (data['token'] != null) {
          token = data['token'] as String?;
          print('✅ Found token in data.token');
        } else if (data['authorisation'] != null && 
                   data['authorisation'] is Map<String, dynamic>) {
          final auth = data['authorisation'] as Map<String, dynamic>;
          token = auth['access_token'] as String?;
          print('✅ Found token in data.authorisation.access_token');
        }
      }
      
      // Fallback: check if user is at root level
      if (userJson == null && responseData['user'] != null && 
          responseData['user'] is Map<String, dynamic>) {
        userJson = responseData['user'] as Map<String, dynamic>;
        print('✅ Found user at root level');
      }
      
      // Fallback: check if token is at root level
      if (token == null && responseData['token'] != null) {
        token = responseData['token'] as String?;
        print('✅ Found token at root level');
      }
      
      // Fallback: check authorisation at root level
      if (token == null && responseData['authorisation'] != null && 
          responseData['authorisation'] is Map<String, dynamic>) {
        final auth = responseData['authorisation'] as Map<String, dynamic>;
        token = auth['access_token'] as String?;
        print('✅ Found token in root authorisation');
      }
      
      // Parse user if we found userJson
      if (userJson != null) {
        try {
          print('🔍 Parsing user from JSON: $userJson');
          // Manually create User object with fallback values for required fields
          // This handles cases where Laravel returns null for required fields
          user = User(
            id: userJson['id'] as int? ?? 0,
            firstName: userJson['first_name'] as String? ?? 
                      userJson['firstName'] as String? ?? '',
            lastName: userJson['last_name'] as String? ?? 
                     userJson['lastName'] as String? ?? '',
            email: userJson['email'] as String? ?? '',
            phone: userJson['phone'] as String?, // Can be null
            middleName: userJson['middle_name'] as String? ?? 
                       userJson['middleName'] as String?,
            address: userJson['address'] as String?,
            city: userJson['city'] as String?,
            region: userJson['region'] as String? ?? 
                   userJson['state'] as String?,
            postalCode: userJson['postal_code'] as String? ?? 
                       userJson['postalCode'] as String? ?? 
                       userJson['zip_code'] as String?,
            status: userJson['status'] as String? ?? 'active',
            createdAt: userJson['created_at'] as String? ?? 
                      userJson['createdAt'] as String?,
            updatedAt: userJson['updated_at'] as String? ?? 
                      userJson['updatedAt'] as String?,
          );
          
          print('✅ User parsed successfully: id=${user.id}, email=${user.email}, firstName=${user.firstName}');
          
          // Validate that we have at least the essential fields
          // Note: phone is optional (can be null), so we don't validate it
          if (user.id == 0 || user.firstName.isEmpty || user.lastName.isEmpty || 
              user.email.isEmpty) {
            print('❌ Missing required user fields. User: $user');
            throw Exception('Missing required user fields. User JSON: $userJson');
          }
        } catch (e, stackTrace) {
          print('❌ Error parsing user: $e');
          throw Exception('Failed to parse user data: $e\nUser JSON: $userJson\nStack: $stackTrace');
        }
      }
      
      if (user == null) {
        print('❌ User data not found in login response');
        throw Exception('User data not found in login response. Response: ${responseData.toString()}');
      }
      
      if (token == null || token.isEmpty) {
        print('❌ Token not found. Current token value: $token');
        throw Exception('Token not found in login response. Response: ${responseData.toString()}');
      }
      
      print('✅ Login successful! User: ${user.email}, Token: ${token.substring(0, 20)}...');
      
      final loginResponse = LoginResponse(
        user: user,
        token: token,
        message: responseData['message'] as String? ?? 'Login successful',
      );

      // Save token and user data
      await _storage.saveToken(token);
      await _storage.saveUserData(jsonEncode(user.toJson()));

      return loginResponse;
    } on DioException catch (e) {
      // Handle Dio errors (network, HTTP errors, etc.)
      String errorMessage = 'Login failed';
      if (e.response != null) {
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic>) {
          errorMessage = errorData['message'] as String? ?? 
                        errorData['error'] as String? ?? 
                        'Login failed: ${e.response?.statusCode}';
        } else {
          errorMessage = 'Login failed: ${e.response?.statusCode} - ${e.response?.statusMessage}';
        }
      } else {
        errorMessage = e.message ?? 'Network error during login';
      }
      throw Exception(errorMessage);
    } catch (e) {
      // Re-throw with more context
      throw Exception('Login error: ${e.toString()}');
    }
  }

  /// Register new user
  Future<RegistrationResponse> register(RegistrationRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        data: request.toJson(),
      );

      final responseData = response.data as Map<String, dynamic>;
      
      // Laravel returns { success: true, data: { user: {...}, token: "..." } }
      final data = responseData['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Invalid registration response');
      }
      
      // Parse user with fallback values to handle null fields
      final userJson = data['user'] as Map<String, dynamic>?;
      if (userJson == null) {
        throw Exception('User data not found in registration response');
      }
      
      final user = User(
        id: userJson['id'] as int? ?? 0,
        firstName: userJson['first_name'] as String? ?? 
                  userJson['firstName'] as String? ?? '',
        lastName: userJson['last_name'] as String? ?? 
                 userJson['lastName'] as String? ?? '',
        email: userJson['email'] as String? ?? '',
        phone: userJson['phone'] as String?, // Can be null
        middleName: userJson['middle_name'] as String? ?? 
                   userJson['middleName'] as String?,
        address: userJson['address'] as String?,
        city: userJson['city'] as String?,
        region: userJson['region'] as String? ?? 
               userJson['state'] as String?,
        postalCode: userJson['postal_code'] as String? ?? 
                   userJson['postalCode'] as String? ?? 
                   userJson['zip_code'] as String?,
        status: userJson['status'] as String? ?? 'active',
        createdAt: userJson['created_at'] as String? ?? 
                  userJson['createdAt'] as String?,
        updatedAt: userJson['updated_at'] as String? ?? 
                  userJson['updatedAt'] as String?,
      );
      
      final token = data['token'] as String? ?? 
                   responseData['token'] as String?;
      
      if (token == null || token.isEmpty) {
        throw Exception('Token not found in registration response');
      }
      
      final registrationResponse = RegistrationResponse(
        user: user,
        token: token,
        message: responseData['message'] as String? ?? 'Registration successful',
      );

      // Save token and user data
      await _storage.saveToken(token);
      await _storage.saveUserData(
        jsonEncode(user.toJson()),
      );

      return registrationResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// Request password reset OTP
  Future<PasswordResetResponse> requestPasswordReset(String email) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.resetPasswordRequest,
        data: {'email': email},
      );

      return PasswordResetResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Reset password with OTP
  /// Note: Laravel route is PUT /homeowner/reset-password (no userId in URL, uses authenticated user)
  Future<void> resetPassword({
    required int userId, // Not used in URL but kept for compatibility
    required String otp, // Not used by Laravel API, but kept for compatibility
    required String newPassword,
  }) async {
    try {
      // Laravel expects PUT request to /homeowner/reset-password with new_password
      await _apiClient.put(
        '/homeowner/reset-password', // Laravel route doesn't include userId
        data: {
          'new_password': newPassword,
          'new_password_confirmation': newPassword,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get current user information
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiConstants.me);
      final responseData = response.data as Map<String, dynamic>;
      
      // Laravel returns { success: true, data: { user: {...} } }
      final data = responseData['data'] as Map<String, dynamic>?;
      if (data == null || data['user'] == null) {
        throw Exception('Invalid user response');
      }
      
      final user = User.fromJson(data['user'] as Map<String, dynamic>);

      // Update stored user data
      await _storage.saveUserData(jsonEncode(user.toJson()));

      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout);
    } catch (e) {
      // Continue with local logout even if API call fails
    } finally {
      // Clear all stored data
      await _storage.clearAll();
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _storage.getToken();
    return token != null && token.isNotEmpty;
  }

  /// Get stored user data
  Future<User?> getStoredUser() async {
    try {
      final userDataString = await _storage.getUserData();
      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get stored token
  Future<String?> getStoredToken() async {
    return await _storage.getToken();
  }
}
