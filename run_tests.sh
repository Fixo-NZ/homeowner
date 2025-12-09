#!/bin/bash

echo "================================"
echo "Running Flutter Tests"
echo "================================"

# Install dependencies
flutter pub get

# Generate mocks
flutter pub run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

echo ""
echo "================================"
echo "Running Laravel Tests"
echo "================================"

cd laravel_admin_api

# Install dependencies
composer install --no-interaction --prefer-dist --optimize-autoloader

# Run migrations
php artisan migrate --env=testing --force

# Run tests
php artisan test

cd ..

echo ""
echo "================================"
echo "All Tests Complete!"
echo "================================"
