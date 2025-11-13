# Feedback Feature Architecture

This document describes the structure and organization of the Feedback feature for the Homeowner application.

## Overview

The feedback feature is built using a clean architecture pattern with clear separation of concerns:

- **Models**: Data structures and API serialization
- **Repositories**: API communication and data fetching
- **ViewModels**: State management and business logic
- **Views**: UI components and screens

## Directory Structure

```
lib/features/feedback/
├── models/
│   ├── review.dart
│   ├── contractor.dart
│   └── models.dart (barrel export)
├── repositories/
│   └── feedback_repository.dart
├── viewmodels/
│   └── feedback_viewmodel.dart
└── views/
    ├── service_reviews_screen.dart
    ├── contractor_review_screen.dart
    ├── components/
    │   ├── top_bar.dart
    │   ├── header_section.dart
    │   ├── tab_list.dart
    │   ├── service_ratings.dart
    │   ├── star_rating.dart
    │   ├── overall_rating_section.dart
    │   ├── rate_service_form.dart
    │   ├── rating_row.dart
    │   ├── review_success_page.dart
    │   └── review_success_page.dart
    └── views.dart (barrel export)
```

## Architecture Layers

### 1. Models (`lib/features/feedback/models/`)

#### `review.dart`
Data model representing a service review.

**Properties:**
- `name`: Reviewer name
- `rating`: Overall rating (1-5)
- `date`: Review submission date
- `comment`: Review text
- `likes`: Number of likes
- `isLiked`: Whether current user liked it
- `isEdited`: Whether review was edited
- `mediaFiles`: List of attached photos/videos
- `contractorId`: ID of reviewed contractor

**Methods:**
- `fromJson()`: Deserialize from API response
- `toJson()`: Serialize for API request

#### `contractor.dart`
Data model representing a service contractor.

**Properties:**
- `id`: Unique identifier
- `name`: Contractor name
- `specialty`: Service type (Plumber, Electrician, etc.)
- `avatar`: Avatar initials
- `rating`: Average rating
- `completedJobs`: Number of completed jobs

**Methods:**
- `fromJson()`: Deserialize from API response
- `toJson()`: Serialize for API request

### 2. Repository (`lib/features/feedback/repositories/`)

#### `feedback_repository.dart`
Handles all API communication and data operations.

**Base Configuration:**
- **Base URL**: `/api/feedback`
- **Reviews Endpoint**: `/api/feedback/reviews`
- **Contractors Endpoint**: `/api/feedback/contractors`

**Main Methods:**
- `fetchAllReviews()`: Get all reviews
- `fetchAllContractors()`: Get all contractors
- `submitReview(Review review)`: Submit new review
- `deleteReview(String reviewId)`: Delete review by ID
- `updateReview(String reviewId, Review review)`: Update existing review
- `toggleLike(String reviewId)`: Toggle like on review
- `getReviewsByRating(int rating)`: Filter reviews by rating
- `getContractorById(String contractorId)`: Get contractor details

**Error Handling:**
- Converts DioExceptions to user-friendly error messages
- Handles network timeouts, connection errors, and server errors

### 3. ViewModel (`lib/features/feedback/viewmodels/`)

#### `feedback_viewmodel.dart`
State management using `ChangeNotifier` (part of Provider package).

**State Properties:**
- `activeTab`: Current tab (reviews/rate)
- `isReviewSubmitted`: Review submission status
- `selectedFilter`: Selected rating filter
- `showUsername`: Whether to display username
- `selectedMedia`: Selected media files (max 5)
- `selectedContractor`: Currently selected contractor ID
- `viewingContractor`: Contractor being reviewed
- `commentValue`: Review comment text
- `overallRating`, `qualityRating`, `responseRating`: Individual ratings
- `isLoading`: Loading state for API calls
- `errorMessage`: Error message from failed API calls

**Methods:**
- `setActiveTab(String tab)`: Switch between tabs
- `setComment(String val)`: Update comment text
- `setOverallRating(int val)`: Set overall rating
- `setQualityRating(int val)`: Set quality rating
- `setResponseRating(int val)`: Set response rating
- `toggleUsername(bool val)`: Toggle username visibility
- `selectContractor(String? id)`: Select contractor
- `handleContractorClick(String contractorId)`: Handle contractor selection
- `resetForm()`: Clear all form fields
- `toggleLike(int index)`: Like/unlike review
- `deleteReview(int index)`: Delete review
- `pickMedia(BuildContext context)`: Launch media picker
- `removeMedia(int index)`: Remove selected media file
- `submitReview()`: Submit review with API call
- `backFromContractor()`: Go back from contractor screen
- `submitAnother()`: Prepare for another review
- `viewAllReviews()`: Go back to reviews tab
- `loadReviews()`: Fetch reviews from API
- `loadContractors()`: Fetch contractors from API

### 4. Views (`lib/features/feedback/views/`)

#### Main Screens

**`service_reviews_screen.dart`**
Main feedback screen with tab navigation.
- Displays reviews tab or review form
- Shows success page after submission
- Uses Provider for state consumption

**`contractor_review_screen.dart`**
Dedicated screen for reviewing a specific contractor.
- Shows contractor details
- Handles review submission
- Displays success confirmation

#### Components

**`top_bar.dart`**
Navigation bar with back and home buttons.

**`header_section.dart`**
Page header with title and subtitle.

**`tab_list.dart`**
Tab switcher between Reviews and Rate Service.

**`service_ratings.dart`**
Displays all reviews with filtering and interaction.
- Overall rating section
- Rating filter chips
- Recent reviews list
- Like/delete functionality

**`star_rating.dart`**
Reusable star rating display widget.

**`overall_rating_section.dart`**
Shows average rating and rating distribution.

**`rate_service_form.dart`**
Form for submitting new reviews.
- Contractor selection
- Comment input
- Media upload (max 5 files)
- Rating input for 3 categories
- Username visibility toggle

**`rating_row.dart`**
Reusable row for individual rating input.

**`review_success_page.dart`**
Success confirmation page after review submission.

## Usage

### Setup in main.dart

```dart
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'lib/features/feedback/repositories/feedback_repository.dart';
import 'lib/features/feedback/viewmodels/feedback_viewmodel.dart';
import 'lib/features/feedback/views/views.dart';

// In your MultiProvider:
MultiProvider(
  providers: [
    Provider(create: (_) => Dio()), // Dio instance
    Provider(
      create: (context) => FeedbackRepository(
        dio: context.read<Dio>(),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => FeedbackViewModel(
        repository: context.read<FeedbackRepository>(),
      ),
    ),
  ],
  child: const MyApp(),
)
```

### GoRouter Configuration

```dart
GoRoute(
  path: '/feedback',
  builder: (context, state) => const ServiceReviewsScreen(),
  routes: [
    GoRoute(
      path: 'contractor/:id',
      builder: (context, state) {
        // Extract contractor ID and navigate
        return const ContractorReviewScreen(
          contractor: selectedContractor,
        );
      },
    ),
  ],
),
```

## API Endpoints

The repository uses the following endpoints (configure base URL in your Dio instance):

```
GET    /api/feedback/reviews                    # Get all reviews
GET    /api/feedback/reviews?rating=5           # Get reviews by rating
POST   /api/feedback/reviews                    # Submit new review
PUT    /api/feedback/reviews/{id}               # Update review
DELETE /api/feedback/reviews/{id}               # Delete review
PATCH  /api/feedback/reviews/{id}/like          # Toggle like

GET    /api/feedback/contractors                # Get all contractors
GET    /api/feedback/contractors/{id}           # Get contractor details
```

## State Management Flow

```
User Interaction (UI)
        ↓
   ViewModel Method
        ↓
   Repository Call (Dio)
        ↓
   API Response
        ↓
   Update ViewModel State
        ↓
   notifyListeners()
        ↓
   Consumer Rebuilds (UI)
```

## Error Handling

The repository handles the following error scenarios:

- **Connection Timeout**: "Connection timeout. Please check your internet connection."
- **Send Timeout**: "Send timeout. Please try again."
- **Receive Timeout**: "Receive timeout. Please try again."
- **Bad Response**: "Server error: {status code}"
- **Request Cancelled**: "Request cancelled."
- **Unknown Error**: "An unexpected error occurred."

## Media Handling

- Maximum 5 files per review
- Supported formats:
  - Images: JPG, PNG, etc.
  - Videos: MP4, MOV
- Files are displayed as thumbnails
- Video files show play icon overlay

## Key Features

1. **Review Submission**
   - Rate across 3 categories
   - Add comments and media
   - Option to show/hide username

2. **Review Browsing**
   - Filter by rating (1-5 stars)
   - View average ratings
   - Like reviews

3. **Review Management**
   - Delete own reviews
   - Report other reviews

4. **Contractor Profiles**
   - View contractor details
   - See rating and job count
   - Submit reviews for contractors

## Dependencies

- `flutter/material.dart`: UI framework
- `provider`: State management
- `dio`: HTTP client
- `go_router`: Navigation
- `image_picker`: Media selection

## Testing

Consider testing:
- ViewModel state changes
- Repository API calls (mock Dio)
- Widget builds with different states
- Form validation
- Media upload limits

## Future Improvements

1. Add image compression before upload
2. Implement review edit functionality
3. Add review moderation
4. Cache reviews locally
5. Implement offline support
6. Add review sorting options
7. Implement real-time notifications
