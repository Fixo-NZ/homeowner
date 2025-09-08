# Tradie App

A Flutter application for tradies to connect with homeowners in New Zealand, built with scalability to expand to other countries.

## Features

- **Authentication**: Login and registration for tradies
- **MVVM Architecture**: Clean separation of concerns with feature-based organization
- **State Management**: Riverpod for reactive state management
- **HTTP Client**: Dio for API communication with interceptors
- **Routing**: Go Router for declarative navigation
- **Secure Storage**: Flutter Secure Storage for token management
- **JSON Serialization**: Automated code generation for API models

## Architecture

The app follows a feature-based MVVM architecture with clean separation:

```
lib/
├── core/
│   ├── constants/       # API endpoints and app constants
│   ├── models/          # Shared data models (TradieModel, etc.)
│   ├── network/         # HTTP client, interceptors, API results
│   ├── router/          # App routing configuration
│   └── theme/           # App theming (colors, text styles, dimensions)
├── features/
│   └── auth/
│       ├── models/      # Auth-specific models (LoginRequest, AuthResponse)
│       ├── repositories/# Data layer (AuthRepository)
│       ├── viewmodels/  # Business logic (AuthViewModel)
│       └── views/       # UI screens (LoginScreen, RegisterScreen)
└── main.dart
```

## Developer Setup

### Prerequisites

- Flutter SDK (3.9.0 or higher)
- Dart SDK
- Laravel API server (separate project)
- IDE with Flutter support (VS Code, Android Studio, or IntelliJ)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd tradie
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code for JSON serialization**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
   > **Note**: This step is crucial! The app uses code generation for JSON serialization. Always run this after pulling changes that include new models.

4. **Update API configuration**
   Update the base URL in `lib/core/constants/api_constants.dart`:
   ```dart
   static const String baseUrl = 'http://10.0.2.2:8000/api';
   ```

### First Time Setup Issues

If you encounter build errors related to missing `.g.dart` files:

1. **Check for missing generated files**:
   ```bash
   find lib -name "*.g.dart"
   ```

2. **Clean and regenerate**:
   ```bash
   flutter clean
   flutter pub get
   dart run build_runner clean
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **If models have circular dependencies**, temporarily comment out problematic imports, generate files, then restore them.

### Laravel API Endpoints

The app expects the following endpoints from your Laravel API:

- `POST /auth/login` - Tradie login
- `POST /auth/register` - Tradie registration  
- `POST /auth/logout` - Logout
- `POST /auth/refresh` - Refresh token

### Tradie Model

Based on the Laravel migration, the tradie model includes:

- Personal info: first_name, middle_name, last_name, email, phone
- Profile: avatar, bio, business_name, license_number
- Location: address, city, region, postal_code, latitude, longitude
- Business: insurance_details, years_experience, hourly_rate
- Availability: availability_status, service_radius

## Running the App

```bash
flutter run
```

## Development Guide

### Project Structure Guidelines

- **Feature-based organization**: Each feature (auth, profile, jobs) has its own folder
- **Shared code in core**: Common mposis, utilities, and configurations
- **Consistent naming**: Use snake_case for files, PascalCase for classes

### Adding New Features

1. **Create feature folder structure**:
   ```
   lib/features/your_feature/
   ├── models/          # Feature-specific models
   ├── repositories/    # Data access layer
   ├── viewmodels/      # Business logic
   └── views/           # UI screens and widgets
   ```

2. **Add models with JSON serialization**:
   ```dart
   import 'package:json_annotation/json_annotation.dart';
   
   part 'your_model.g.dart';
   
   @JsonSerializable()
   class YourModel {
     final String field;
     
     const YourModel({required this.field});
     
     factory YourModel.fromJson(Map<String, dynamic> json) =>
         _$YourModelFromJson(json);
     
     Map<String, dynamic> toJson() => _$YourModelToJson(this);
   }
   ```

3. **Generate code after adding models**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Create repository for data access**:
   ```dart
   class YourRepository {
     final DioClient _dioClient;
     
     YourRepository(this._dioClient);
     
     Future<ApiResult<YourModel>> getData() async {
       // Implementation
     }
   }
   ```

5. **Create ViewModel with Riverpod**:
   ```dart
   class YourViewModel extends StateNotifier<AsyncValue<YourModel>> {
     final YourRepository _repository;
     
     YourViewModel(this._repository) : super(const AsyncValue.loading());
     
     Future<void> loadData() async {
       // Implementation
     }
   }
   ```

### Code Generation Workflow

**When to run code generation**:
- After adding new `@JsonSerializable()` models
- After modifying existing model fields
- After pulling changes from other developers
- When you see "Target of URI hasn't been generated" errors

**Commands**:
```bash
# Standard build (incremental)
dart run build_runner build

# Clean build (recommended for conflicts)
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on changes)
dart run build_runner watch

# Clean generated files
dart run build_runner clean
```

### Common Issues and Solutions

**1. "Target of URI hasn't been generated" errors**
```bash
# Solution: Run code generation
dart run build_runner build --delete-conflicting-outputs
```

**2. Circular dependency during code generation**
- Temporarily comment out problematic imports
- Generate files for individual models first
- Restore imports and regenerate

**3. Build conflicts**
```bash
# Clean everything and start fresh
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

**4. Missing model files**
- Check if the model file exists in the expected location
- Verify import paths are correct
- Ensure the model has proper `@JsonSerializable()` annotation

### State Management with Riverpod

**Provider patterns used**:
- `StateNotifierProvider` for complex state with business logic
- `FutureProvider` for async data fetching
- `Provider` for simple dependencies

**Example ViewModel setup**:
```dart
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AsyncValue<AuthState>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthViewModel(repository);
});
```

### API Integration

**Repository pattern**:
- Use `ApiResult<T>` for consistent error handling
- Implement proper error mapping from HTTP responses
- Use dependency injection with Riverpod

**Example API call**:
```dart
Future<ApiResult<AuthResponse>> login(LoginRequest request) async {
  try {
    final response = await _dioClient.post('/auth/login', data: request.toJson());
    return ApiResult.success(AuthResponse.fromJson(response.data));
  } catch (e) {
    return ApiResult.failure(ApiError.fromException(e));
  }
}
```

## Dependencies

### Core Dependencies
- **flutter_riverpod** (^2.4.9): State management and dependency injection
- **dio** (^5.4.0): HTTP client for API communication
- **go_router** (^12.1.3): Declarative routing
- **json_annotation** (^4.8.1): JSON serialization annotations
- **flutter_secure_storage** (^9.0.0): Secure token storage
- **formz** (^0.6.1): Form validation

### Development Dependencies
- **build_runner** (^2.4.7): Code generation runner
- **json_serializable** (^6.7.1): JSON serialization code generator
- **flutter_lints** (^5.0.0): Dart linting rules

## Testing

### Running Tests
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/auth/auth_viewmodel_test.dart
```

### Test Structure
```
test/
├── features/
│   └── auth/
│       ├── models/
│       ├── repositories/
│       └── viewmodels/
├── core/
│   └── network/
└── helpers/
    └── test_helpers.dart
```

## Deployment

### Build for Production

**Android**:
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

**iOS**:
```bash
flutter build ios --release
```

### Environment Configuration

Create different configurations for development, staging, and production:

1. **Create environment files**:
   - `lib/core/config/dev_config.dart`
   - `lib/core/config/staging_config.dart`
   - `lib/core/config/prod_config.dart`

2. **Use build flavors** for different environments

## Contributing

### Code Style
- Follow Dart/Flutter conventions
- Use meaningful variable and function names
- Add comments for complex business logic
- Keep functions small and focused

### Git Workflow
1. Create feature branch from `develop`
2. Make changes and test thoroughly
3. Run code generation if needed
4. Create pull request to `develop`
5. Ensure CI passes before merging

### Before Committing
```bash
# Format code
dart format .

# Analyze code
flutter analyze

# Run tests
flutter test

# Generate code if needed
dart run build_runner build --delete-conflicting-outputs
```

## Troubleshooting

### Common Build Issues

**1. Gradle build failures (Android)**
- Clean project: `flutter clean`
- Check Android SDK and build tools versions
- Verify `android/gradle.properties` settings

**2. iOS build failures**
- Clean project: `flutter clean`
- Delete `ios/Pods` and `ios/Podfile.lock`
- Run `cd ios && pod install`

**3. Code generation issues**
- Check model annotations are correct
- Verify import paths
- Run clean build: `dart run build_runner clean && dart run build_runner build`

### Performance Tips
- Use `const` constructors where possible
- Implement proper `dispose` methods
- Use `ListView.builder` for large lists
- Optimize image loading and caching

## Next Steps & Roadmap

### Phase 1 (Current)
- ✅ Authentication system
- ✅ Basic MVVM architecture
- ✅ API integration setup

### Phase 2 (Upcoming)
- [ ] Tradie profile management
- [ ] Job posting and browsing
- [ ] Search and filtering
- [ ] Basic messaging system

### Phase 3 (Future)
- [ ] Real-time messaging
- [ ] Location services and mapping
- [ ] Push notifications
- [ ] Payment integration
- [ ] Rating and review system

### Phase 4 (Advanced)
- [ ] Multi-country support
- [ ] Advanced analytics
- [ ] Admin dashboard integration
- [ ] Offline support
