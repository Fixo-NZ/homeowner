import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:homeowner/features/auth/repositories/auth_repository.dart';
import 'package:homeowner/features/auth/models/auth_models.dart';
import 'package:homeowner/core/network/api_result.dart';
import 'package:homeowner/core/network/dio_client.dart';

import 'auth_repo_test.mocks.dart';

@GenerateMocks([DioClient, Dio, FlutterSecureStorage])
void main() {
  late MockDioClient mockDioClient;
  late MockDio mockDio;
  late MockFlutterSecureStorage mockSecureStorage;
  late AuthRepository authRepository;

  setUp(() {
    mockDioClient = MockDioClient();
    mockDio = MockDio();
    mockSecureStorage = MockFlutterSecureStorage();
    
    when(mockDioClient.dio).thenReturn(mockDio);
        
    when(mockDioClient.setToken(any)).thenAnswer((_) async {}); 
    
    authRepository = AuthRepository.withClient(mockDioClient, mockSecureStorage); 
  });

  group('AuthRepository Login', () {
    test('Successful login returns AuthResponse with token', () async {
      final loginRequest = LoginRequest(email: 'sample@email.com', password: 'password');
      final mockResponse = Response(
        requestOptions: RequestOptions(path: '/api/auth/login'),
        statusCode: 200,
        data: {
          'success': true,
          'data': {
            'user': {
              'id': 1,
              'first_name': 'Test',
              'last_name': 'User',
              'email': 'sample@email.com',
            },
            'token': 'mockToken123',
          },
        },
      );

      when(mockDio.post(any, data: anyNamed('data'))).thenAnswer((_) async => mockResponse);

      final result = await authRepository.login(loginRequest);

      expect(result, isA<Success<AuthResponse>>());

      final success = result as Success<AuthResponse>;

      expect(success.data.accessToken, equals('mockToken123')); 
      expect(success.data.user.email, equals('sample@email.com'));
      
      verify(mockDioClient.setToken('mockToken123')).called(1);
    });

    test('Failed login returns Failure with error message', () async {
      final loginRequest = LoginRequest(email: 'wrong@email.com', password: 'wrong');
      when(mockDio.post(any, data: anyNamed('data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/auth/login'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/auth/login'),
            statusCode: 401,
            data: { 
              'message': 'The provided credentials are incorrect.',
              'errors': null,
            },
          ),
        ),
      );

      final result = await authRepository.login(loginRequest);

      expect(result, isA<Failure>());
      final failure = result as Failure;
      expect(failure.message, contains('incorrect')); 
    });
  });
}