import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/tradie_model.dart';
import '../models/auth_models.dart';
import '../repositories/auth_repository.dart';
import '../../../core/network/api_result.dart';

// Auth state
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final TradieModel? user;
  final String? error;
  final Map<String, List<String>>? fieldErrors;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
    this.fieldErrors,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    TradieModel? user,
    String? error,
    Map<String, List<String>>? fieldErrors,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
      fieldErrors: fieldErrors,
    );
  }
}

// Auth ViewModel
class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await _authRepository.isLoggedIn();
    state = state.copyWith(isAuthenticated: isLoggedIn);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null, fieldErrors: null);

    final request = LoginRequest(email: email, password: password);
    final result = await _authRepository.login(request);

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
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null, fieldErrors: null);
  }
}

// Providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((
  ref,
) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthViewModel(authRepository);
});
