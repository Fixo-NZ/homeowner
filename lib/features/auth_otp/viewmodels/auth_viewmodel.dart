import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../repositories/auth_repository.dart';
import '../models/auth_models.dart';

/// Auth state class
class AuthState {
  final User? user;
  final String? token;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    String? token,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

/// Auth view model provider
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>(
  (ref) => AuthViewModel(),
);

/// Auth view model
class AuthViewModel extends StateNotifier<AuthState> {
  AuthViewModel() : super(AuthState()) {
    _init();
  }

  final AuthRepository _repository = AuthRepository();

  /// Initialize auth state from storage
  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    try {
      final isAuthenticated = await _repository.isAuthenticated();
      if (isAuthenticated) {
        final user = await _repository.getStoredUser();
        final token = await _repository.getStoredToken();
        state = state.copyWith(
          user: user,
          token: token,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to initialize auth',
        isLoading: false,
      );
    }
  }

  /// Login with email and password
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.login(
        email: email,
        password: password,
      );

      state = state.copyWith(
        user: response.user,
        token: response.token,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: _parseError(e), isLoading: false);
      rethrow;
    }
  }

  /// Register new user
  Future<void> register(RegistrationRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.register(request);

      // Verify token is saved before updating state
      final token = await DioClient.instance.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token not saved after registration');
      }

      state = state.copyWith(
        user: response.user,
        token: response.token,
        isAuthenticated: true,
        isLoading: false,
      );
      
      print('✅ [AUTH] Registration successful - user authenticated: ${response.user.email}');
      print('✅ [AUTH] Token in state: ${state.token?.substring(0, state.token!.length > 20 ? 20 : state.token!.length)}...');
    } catch (e) {
      state = state.copyWith(error: _parseError(e), isLoading: false);
      rethrow;
    }
  }

  /// Request password reset
  Future<PasswordResetResponse> requestPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.requestPasswordReset(email);
      state = state.copyWith(isLoading: false);
      return response;
    } catch (e) {
      state = state.copyWith(error: _parseError(e), isLoading: false);
      rethrow;
    }
  }

  /// Reset password
  Future<void> resetPassword({
    required int userId,
    required String otp,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.resetPassword(
        userId: userId,
        otp: otp,
        newPassword: newPassword,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: _parseError(e), isLoading: false);
      rethrow;
    }
  }

  /// Refresh user data
  Future<void> refreshUser() async {
    state = state.copyWith(isLoading: true);
    try {
      final isAuthenticated = await _repository.isAuthenticated();
      if (isAuthenticated) {
        final user = await _repository.getCurrentUser();
        final token = await _repository.getStoredToken();
        state = state.copyWith(
          user: user,
          token: token,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: _parseError(e), isLoading: false);
    }
  }

  /// Logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.logout();
      state = AuthState();
    } catch (e) {
      // Even if logout fails on server, clear local state
      state = AuthState();
    }
  }

  /// Parse error message
  String _parseError(dynamic error) {
    final errorString = error.toString();
    
    // Check for specific error messages first
    if (errorString.contains('User data not found') || 
        errorString.contains('Token not found') ||
        errorString.contains('Failed to parse user')) {
      return errorString.replaceAll('Exception: ', '').replaceAll('Login error: ', '');
    }
    
    if (errorString.contains('401') || errorString.contains('Unauthorized')) {
      return 'Invalid email or password. Please try again.';
    } else if (errorString.contains('422')) {
      return 'Validation error. Please check your input.';
    } else if (errorString.contains('404')) {
      return 'User not found. Please check your email.';
    } else if (errorString.contains('500')) {
      return 'Server error. Please try again later.';
    } else if (errorString.contains('Network') || errorString.contains('SocketException')) {
      return 'Network error. Please check your connection.';
    }
    
    // Return the actual error message if it's informative
    if (errorString.length < 200) {
      return errorString.replaceAll('Exception: ', '');
    }
    
    return 'An error occurred. Please try again.';
  }
}
