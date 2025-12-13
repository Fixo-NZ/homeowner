import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/home_owner_model.dart';
import '../models/auth_models.dart';
import '../repositories/auth_repository.dart';
import '../../../core/network/api_result.dart';

// Auth state
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final HomeOwnerModel? user;
  final String? error;
  final Map<String, List<String>>? fieldErrors;
  final bool isInitialized;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
    this.fieldErrors,
    this.isInitialized = false,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    HomeOwnerModel? user,
    String? error,
    Map<String, List<String>>? fieldErrors,
    bool? isInitialized,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
      fieldErrors: fieldErrors,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

// Auth ViewModel
class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  bool _initializedOnce = false; // ⚡ guard to prevent infinite loop

  AuthViewModel(this._authRepository) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    if (_initializedOnce) return; // ⚡ prevent multiple calls
    _initializedOnce = true;

    // Start the auth check asynchronously and only after that change state
    final isLoggedIn = await _authRepository.isLoggedIn();

    // Simulate a small delay to ensure the splash screen is visible for a reasonable time
    await Future.delayed(const Duration(seconds: 1)); // this is optional

    // If logged in, also get user info
    HomeOwnerModel? user;
    if (isLoggedIn) {
      // You might need to add a method to get current user from API
      // or store it during login
    }

    state = state.copyWith(
      isAuthenticated: isLoggedIn,
      isInitialized: true,
    );
  }

  Future<bool> login(String email, String password) async {
  state = state.copyWith(isLoading: true, error: null, fieldErrors: null);

  final request = LoginRequest(
    email: email,
    password: password,
  );
  final result = await _authRepository.login(request);

  print(result);

  switch (result) {
    case Success<AuthResponse>():
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: result.data.user,
        isInitialized: true, 
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


  Future<bool> register({
    required String firstName,
    String? middleName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
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
          isAuthenticated: true,
          user: result.data.user,
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

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _authRepository.logout();
    state = const AuthState(isInitialized: true);
  }

  void clearError() {
    state = state.copyWith(error: null, fieldErrors: null);
  }
}

// Providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthViewModel(authRepository);
});
