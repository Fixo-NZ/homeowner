import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../models/auth_models.dart';

/// OTP state class
class OtpState {
  final bool isLoading;
  final String? error;
  final String? phoneNumber;
  final String? otpCode;
  final OtpResponse? otpResponse;
  final OtpVerificationResponse? verificationResponse;

  OtpState({
    this.isLoading = false,
    this.error,
    this.phoneNumber,
    this.otpCode,
    this.otpResponse,
    this.verificationResponse,
  });

  OtpState copyWith({
    bool? isLoading,
    String? error,
    String? phoneNumber,
    String? otpCode,
    OtpResponse? otpResponse,
    OtpVerificationResponse? verificationResponse,
  }) {
    return OtpState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otpCode: otpCode ?? this.otpCode,
      otpResponse: otpResponse ?? this.otpResponse,
      verificationResponse: verificationResponse ?? this.verificationResponse,
    );
  }
}

/// OTP view model provider
final otpViewModelProvider = StateNotifierProvider<OtpViewModel, OtpState>(
  (ref) => OtpViewModel(),
);

/// OTP view model
class OtpViewModel extends StateNotifier<OtpState> {
  OtpViewModel() : super(OtpState());

  final AuthRepository _repository = AuthRepository();

  /// Request OTP
  Future<void> requestOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.requestOtp(phoneNumber);
      state = state.copyWith(
        phoneNumber: phoneNumber,
        otpResponse: response,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: _parseError(e), isLoading: false);
      rethrow;
    }
  }

  /// Verify OTP
  Future<OtpVerificationResponse> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.verifyOtp(
        phoneNumber: phoneNumber,
        otp: otp,
      );

      state = state.copyWith(
        verificationResponse: response,
        otpCode: otp,
        isLoading: false,
      );

      return response;
    } catch (e) {
      state = state.copyWith(error: _parseError(e), isLoading: false);
      rethrow;
    }
  }

  /// Reset state
  void reset() {
    state = OtpState();
  }

  /// Parse error message
  String _parseError(dynamic error) {
    if (error.toString().contains('400')) {
      return 'Invalid OTP code';
    } else if (error.toString().contains('404')) {
      return 'Phone number not found';
    } else if (error.toString().contains('429')) {
      return 'Too many requests. Please try again later.';
    } else if (error.toString().contains('Network')) {
      return 'Network error. Please check your connection.';
    }
    return 'An error occurred. Please try again.';
  }
}
