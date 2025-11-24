import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:homeowner/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:homeowner/features/auth/repositories/auth_repository.dart';
import 'package:homeowner/features/auth/models/auth_models.dart';
import 'package:homeowner/core/models/home_owner_model.dart';
import 'package:homeowner/core/network/api_result.dart';

import 'auth_viewmodel_test.mocks.dart';

extension AuthViewModelTestExtension on AuthViewModel {
  set testState(AuthState newState) => state = newState;
}

@GenerateMocks([AuthRepository])
void main() {
  provideDummy<ApiResult<AuthResponse>>(
    Failure(message: 'Default Mockito Failure'),
  );

  late MockAuthRepository mockAuthRepository;
  late AuthViewModel authViewModel;

  final testUser = HomeOwnerModel(
    id: 1,
    firstName: 'Test',
    lastName: 'User',
    email: 'sample@email.com',
  );

  final authResponse = AuthResponse(
    accessToken: "token123",
    tokenType: "Bearer",
    expiresIn: 3600,
    user: testUser,
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(mockAuthRepository.isLoggedIn()).thenAnswer((_) async => false);
    
    authViewModel = AuthViewModel(mockAuthRepository); 

    authViewModel.testState = const AuthState(isInitialized: true);
  });

  group('AuthViewModel Login', () {
    final loginRequest = LoginRequest(email: 'sample@email.com', password: 'password');
    
    test('Correct updates state correctly on successful login (email)', () async {
      when(mockAuthRepository.login(any))
          .thenAnswer((_) async => Success(authResponse));
      
      final result = await authViewModel.login('test@email.com', 'password');

      expect(result, true);
      expect(authViewModel.state.isLoading, false);
      expect(authViewModel.state.isAuthenticated, true);
      expect(authViewModel.state.user, testUser);
      
      verify(mockAuthRepository.login(any)).called(1);
    });

    test('Wrong updates state correctly on failed login (ApiResult Failure)', () async {
      const errorMessage = "Invalid credentials";
      final failureResult = Failure<AuthResponse>(message: errorMessage);

      when(mockAuthRepository.login(any))
          .thenAnswer((_) async => failureResult);

      final result = await authViewModel.login('wrong@email.com', 'wrong');

      expect(result, false);
      expect(authViewModel.state.isLoading, false);
      expect(authViewModel.state.isAuthenticated, false);
      expect(authViewModel.state.error, errorMessage);
    });
  });
}