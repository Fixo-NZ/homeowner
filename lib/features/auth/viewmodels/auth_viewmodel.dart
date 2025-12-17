import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/home_owner_model.dart';
import '../models/auth_models.dart';
import '../repositories/auth_repository.dart';
import '../../../core/network/api_result.dart';

//AUTHSTATE
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final HomeOwnerModel? user;
  final String? error;
  final Map<String, List<String>>? fieldErrors;
  final bool isInitialized;
  final String? errorCode;
  final bool isPasswordResetRequested;
  final bool isRegistered;
  final String? pendingEmail;
  final bool? isEmailVerified;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
    this.fieldErrors,
    this.isInitialized = false,
    this.errorCode,
    this.isPasswordResetRequested = false,
    this.isRegistered = false,
    this.pendingEmail,
    this.isEmailVerified,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    HomeOwnerModel? user,
    String? error,
    Map<String, List<String>>? fieldErrors,
    bool? isInitialized,
    String? errorCode,
    bool? isPasswordResetRequested,
    bool? isRegistered,
    String? pendingEmail,
    bool? isEmailVerified,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
      fieldErrors: fieldErrors,
      isInitialized: isInitialized ?? this.isInitialized,
      errorCode: errorCode ?? this.errorCode,
      isPasswordResetRequested:
          isPasswordResetRequested ?? this.isPasswordResetRequested,
      isRegistered: isRegistered ?? this.isRegistered,
      pendingEmail: pendingEmail ?? this.pendingEmail,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}

// AUTH VIEWMODEL
class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final minDelay = Future.delayed(const Duration(seconds: 1));
    final isLoggedIn = await _authRepository.isLoggedIn();

    await minDelay;

      if (isLoggedIn) {
      final userResult = await _authRepository.fetchCurrentUser();

      switch (userResult) {
        case Success<HomeOwnerModel>():
          final user = userResult.data;
          state = state.copyWith(
            isAuthenticated: true,
            isInitialized: true,
            user: user,
            isEmailVerified: user.emailVerifiedAt != null,
          );
          print('AuthViewModel: initial auth check - logged in; user fetched');
          break;
        case Failure<HomeOwnerModel>():
          print('AuthViewModel: fetchCurrentUser failed during startup: ${userResult.message}');
          await _authRepository.logout();
          state = state.copyWith(isInitialized: true, isAuthenticated: false, isEmailVerified: false);
          break;
      }
    } else {
      state = state.copyWith(isInitialized: true);
      print('AuthViewModel: initial auth check - not logged in');
    }
  }

  // LOGIN
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null, fieldErrors: null);

    final result =
        await _authRepository.login(LoginRequest(email: email, password: password));

    switch (result) {
      case Success<AuthResponse>():
        final user = result.data.user;

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
          isEmailVerified: user.emailVerifiedAt != null,
        );
        return true;

      case Failure<AuthResponse>():
        state = state.copyWith(
          isLoading: false,
          error: result.message,
          fieldErrors: result.errors,
          errorCode: result.code,
        );
        return false;
    }
  }

  // REGISTER
  Future<bool> register({
    required String firstName,
    String? middleName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
  }) async {
    state = state.copyWith(isLoading: true, error: null, fieldErrors: null);

    final request = RegisterRequest(
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      phone: phone,
    );

    final result = await _authRepository.register(request);

    switch (result) {
      case Success<AuthResponse>():
        state = state.copyWith(
          isLoading: false,
          isRegistered: true,
          pendingEmail: email,
          isEmailVerified: false,
        );
        return true;

      case Failure<AuthResponse>():
        state = state.copyWith(
          isLoading: false,
          error: result.message,
          fieldErrors: result.errors,
        );
        return false;
    }
  }

  // REQUEST RESET PASSWORD
  Future<bool> requestPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, error: null, fieldErrors: null);

    final result = await _authRepository.requestPasswordReset(email);

    switch (result) {
      case Success():
        state = state.copyWith(
          isLoading: false,
          isPasswordResetRequested: true,
          pendingEmail: email,
        );
        print('AuthViewModel: password reset requested for $email');
        return true;

      case Failure():
        state = state.copyWith(
          isLoading: false,
          error: result.message,
          fieldErrors: result.errors,
        );
        print('AuthViewModel: password reset failed for $email; error=${result.message}');
        return false;
    }
  }

  void acknowledgePasswordResetRequestHandled() {
    state = state.copyWith(isPasswordResetRequested: false);
  }

  void acknowledgeRegistrationHandled() {
    state = state.copyWith(isRegistered: false);
  }

  // VERIFIFICATION
  Future<bool> verifyOtp({
    required String email,
    required String otp,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.verifyResetPasswordOtp(email, otp);

    switch (result) {
      case Success():
        state = state.copyWith(isLoading: false);
        return true;

      case Failure():
        state = state.copyWith(
          isLoading: false,
          error: result.message,
          fieldErrors: result.errors,
        );
        return false;
    }
  }

  // RESET PASSWORD
  Future<bool> resetPassword({
    required String email,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.resetPassword(
      email: email,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );

    switch (result) {
      case Success():
        state = state.copyWith(isLoading: false);
        return true;

      case Failure():
        state = state.copyWith(
          isLoading: false,
          error: result.message,
          fieldErrors: result.errors,
        );
        return false;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _authRepository.logout();
    state = const AuthState(isInitialized: true);
  }

  void clearError() {
    state = state.copyWith(error: null, fieldErrors: null, errorCode: null);
  }
}

// PROVIDERS
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthViewModel(repo);
});
