# Testing Guide

This document provides instructions for running unit tests for the feedback features.

## Flutter Tests

### Prerequisites
- Flutter SDK installed
- Dependencies installed: `flutter pub get`

### Running Tests

Run all tests:
```bash
flutter test
```

Run specific test file:
```bash
flutter test test/features/feedback/models/review_test.dart
```

Run tests with coverage:
```bash
flutter test --coverage
```

View coverage report:
```bash
# Install lcov (if not already installed)
# On macOS: brew install lcov
# On Ubuntu: sudo apt-get install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open in browser
open coverage/html/index.html
```

### Test Structure

```
test/
├── features/
│   └── feedback/
│       ├── models/
│       │   ├── review_test.dart
│       │   └── contractor_test.dart
│       ├── repositories/
│       │   └── feedback_repository_test.dart
│       └── viewmodels/
│           └── feedback_viewmodel_test.dart
└── widget_test.dart
```

### Generating Mocks

The tests use `mockito` for mocking dependencies. To generate mock files:

1. Add `build_runner` and `mockito` to `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.7
```

2. Run the build command:
```bash
flutter pub run build_runner build
```

This will generate `.mocks.dart` files next to your test files.

## Laravel/PHP Tests

### Prerequisites
- PHP 8.1 or higher
- Composer dependencies installed
- Database configured for testing

### Setup

1. Create a test database:
```bash
cd laravel_admin_api
cp .env .env.testing
```

2. Update `.env.testing` with test database credentials:
```env
DB_CONNECTION=mysql
DB_DATABASE=homeowner_test
DB_USERNAME=root
DB_PASSWORD=
```

3. Run migrations for test database:
```bash
php artisan migrate --env=testing
```

### Running Tests

Run all tests:
```bash
cd laravel_admin_api
php artisan test
```

Run specific test file:
```bash
php artisan test --filter ReviewTest
```

Run tests with coverage (requires Xdebug):
```bash
php artisan test --coverage
```

Run only unit tests:
```bash
php artisan test --testsuite=Unit
```

Run only feature tests:
```bash
php artisan test --testsuite=Feature
```

### Test Structure

```
laravel_admin_api/tests/
├── Feature/
│   └── Api/
│       └── ReviewControllerTest.php
└── Unit/
    └── Models/
        └── ReviewTest.php
```

## Test Coverage

### Flutter Test Coverage

The Flutter tests cover:
- ✅ Review model serialization/deserialization
- ✅ Contractor model serialization/deserialization
- ✅ Repository API calls (fetch, submit, delete, like)
- ✅ ViewModel state management
- ✅ ViewModel business logic
- ✅ Error handling

### Laravel Test Coverage

The Laravel tests cover:
- ✅ Review model relationships
- ✅ Review model scopes and methods
- ✅ API endpoints (GET, POST, DELETE, PATCH)
- ✅ Request validation
- ✅ Response format
- ✅ Anonymous reviews
- ✅ Like/unlike functionality
- ✅ Data type conversions (string IDs)

## Continuous Integration

### GitHub Actions Example

Create `.github/workflows/test.yml`:

```yaml
name: Tests

on: [push, pull_request]

jobs:
  flutter-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      - run: flutter pub get
      - run: flutter test

  laravel-tests:
    runs-on: ubuntu-latest
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: password
          MYSQL_DATABASE: homeowner_test
        ports:
          - 3306:3306
    steps:
      - uses: actions/checkout@v3
      - uses: shivammathur/setup-php@v2
        with:
          php-version: '8.1'
      - run: cd laravel_admin_api && composer install
      - run: cd laravel_admin_api && php artisan test
```

## Best Practices

1. **Write tests first** - Follow TDD principles when adding new features
2. **Keep tests isolated** - Each test should be independent
3. **Use factories** - Use factories for creating test data
4. **Mock external dependencies** - Don't make real API calls in tests
5. **Test edge cases** - Include tests for error conditions
6. **Maintain coverage** - Aim for >80% code coverage
7. **Run tests before commits** - Ensure all tests pass before pushing

## Troubleshooting

### Flutter Tests

**Issue**: Mock generation fails
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

**Issue**: Tests fail with "Bad state: No test is currently running"
- Ensure you're using `testWidgets` for widget tests and `test` for unit tests

### Laravel Tests

**Issue**: Database connection errors
- Check `.env.testing` configuration
- Ensure test database exists
- Run migrations: `php artisan migrate --env=testing`

**Issue**: Factory not found
- Run `composer dump-autoload`
- Check factory namespace and class name

## Additional Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Laravel Testing Documentation](https://laravel.com/docs/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [PHPUnit Documentation](https://phpunit.de/documentation.html)
