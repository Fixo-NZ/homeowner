@echo off

echo ================================
echo Running Flutter Tests
echo ================================

REM Install dependencies
call flutter pub get

REM Generate mocks
call flutter pub run build_runner build --delete-conflicting-outputs

REM Run tests
call flutter test

echo.
echo ================================
echo Running Laravel Tests
echo ================================

cd laravel_admin_api

REM Install dependencies
call composer install --no-interaction --prefer-dist --optimize-autoloader

REM Run migrations
call php artisan migrate --env=testing --force

REM Run tests
call php artisan test

cd ..

echo.
echo ================================
echo All Tests Complete!
echo ================================

pause
