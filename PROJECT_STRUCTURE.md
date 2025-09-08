# Project Structure

This document outlines the improved file structure for the Tradie Flutter app, designed for scalability and maintainability.

## Architecture Overview

The project follows a **Feature-First Architecture** combined with **MVVM pattern** and **Clean Architecture principles**.

```
lib/
├── core/                           # Core functionality shared across features
│   ├── config/                     # App configuration
│   ├── constants/                  # App constants
│   ├── network/                    # Network layer (Dio, API results)
│   ├── router/                     # App routing configuration
│   └── theme/                      # Global theming system
├── features/                       # Feature modules
│   ├── auth/                       # Authentication feature
│   ├── dashboard/                  # Dashboard feature
│   ├── profile/                    # Profile management (future)
│   ├── jobs/                       # Job management (future)
│   └── ...                         # Other features
├── shared/                         # Shared components across features
│   ├── data/                       # Shared data models
│   └── presentation/               # Shared UI components
└── main.dart                       # App entry point
```

## Detailed Structure

### Core Layer (`lib/core/`)

Contains fundamental app functionality that's used across multiple features.

#### Configuration (`lib/core/config/`)
- `app_config.dart` - App-wide configuration constants

#### Constants (`lib/core/constants/`)
- `api_constants.dart` - API endpoints and headers

#### Network (`lib/core/network/`)
- `dio_client.dart` - HTTP client configuration with interceptors
- `api_result.dart` - Generic API response wrapper

#### Router (`lib/core/router/`)
- `app_router.dart` - Go Router configuration with auth guards

#### Theme (`lib/core/theme/`)
- `app_theme.dart` - Complete Material 3 theme configuration
- `app_colors.dart` - Color palette and semantic colors
- `app_text_styles.dart` - Typography system
- `app_dimensions.dart` - Spacing, sizing, and layout constants

### Features Layer (`lib/features/`)

Each feature is self-contained with its own data, presentation, and business logic.

#### Feature Structure Template
```
feature_name/
├── data/
│   ├── models/                     # Data models specific to feature
│   ├── repositories/               # Data repositories
│   └── datasources/                # API/local data sources (future)
├── domain/                         # Business logic (future)
│   ├── entities/                   # Domain entities
│   ├── repositories/               # Repository interfaces
│   └── usecases/                   # Business use cases
└── presentation/
    ├── screens/                    # UI screens
    ├── widgets/                    # Feature-specific widgets
    └── viewmodels/                 # State management (Riverpod)
```

#### Current Features

**Authentication (`lib/features/auth/`)**
- Login and registration functionality
- JWT token management
- User session handling

**Dashboard (`lib/features/dashboard/`)**
- Main dashboard with quick actions
- User welcome section
- Navigation to other features

### Shared Layer (`lib/shared/`)

Contains reusable components used across multiple features.

#### Data (`lib/shared/data/`)
- `models/` - Shared data models (e.g., TradieModel)

#### Presentation (`lib/shared/presentation/`)
- `widgets/` - Reusable UI components
  - `custom_button.dart` - Configurable button component
  - `custom_text_field.dart` - Enhanced text input field
  - `custom_card.dart` - Consistent card component
  - `loading_overlay.dart` - Loading state overlay

## Theming System

### Global Theme Configuration

The theming system is centralized and easily customizable:

1. **Colors** (`app_colors.dart`)
   - Primary, secondary, and accent colors
   - Semantic colors (success, warning, error)
   - Tradie-specific brand colors
   - Light/dark mode support

2. **Typography** (`app_text_styles.dart`)
   - Material 3 text styles
   - Custom app-specific styles
   - Consistent font weights and sizes

3. **Dimensions** (`app_dimensions.dart`)
   - Spacing constants
   - Component sizes
   - Layout breakpoints
   - Elevation levels

4. **Theme Application** (`app_theme.dart`)
   - Complete Material 3 theme
   - Component-specific theming
   - Light and dark theme variants

### Usage Examples

```dart
// Using theme colors
Container(
  color: AppColors.primary,
  child: Text(
    'Hello',
    style: AppTextStyles.titleLarge.copyWith(
      color: AppColors.onPrimary,
    ),
  ),
)

// Using dimensions
Padding(
  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
  child: SizedBox(
    height: AppDimensions.buttonHeight,
    child: CustomButton.primary(text: 'Submit'),
  ),
)
```

## Benefits of This Structure

### 1. Scalability
- Easy to add new features without affecting existing code
- Clear separation of concerns
- Modular architecture

### 2. Maintainability
- Feature-based organization makes code easy to find
- Consistent patterns across features
- Centralized theming for easy updates

### 3. Testability
- Each feature can be tested independently
- Clear dependencies between layers
- Mockable repositories and services

### 4. Team Collaboration
- Multiple developers can work on different features simultaneously
- Clear ownership boundaries
- Consistent code organization

### 5. Reusability
- Shared components reduce code duplication
- Common patterns can be extracted to shared layer
- Theme system ensures visual consistency

## Adding New Features

To add a new feature (e.g., "jobs"):

1. Create feature directory: `lib/features/jobs/`
2. Add data layer: models, repositories
3. Add presentation layer: screens, widgets, viewmodels
4. Update router with new routes
5. Add navigation from existing features

## Theme Customization

To customize the app theme:

1. Update colors in `app_colors.dart`
2. Modify text styles in `app_text_styles.dart`
3. Adjust dimensions in `app_dimensions.dart`
4. The changes will automatically apply app-wide

## Code Generation

Run code generation after adding new models:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Best Practices

1. **Feature Independence**: Features should not directly depend on each other
2. **Shared Components**: Extract common UI patterns to shared widgets
3. **Consistent Theming**: Always use theme constants instead of hardcoded values
4. **State Management**: Use Riverpod providers for state management
5. **Error Handling**: Use the ApiResult pattern for consistent error handling
6. **Navigation**: Use Go Router for type-safe navigation
7. **Testing**: Write tests for each feature's business logic