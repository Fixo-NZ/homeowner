# Flutter-Laravel Integration Fixes

**Date:** Integration Fixes Applied  
**Purpose:** Connect Flutter app to Laravel API backend based on updated Service model structure

---

## Summary of Changes

All Flutter models, repositories, and API endpoints have been updated to match the Laravel API structure we fixed in the backend.

---

## Files Modified

### 1. ✅ Service Model (`lib/features/booking_create_update_cancel/models/service_model.dart`)

**Changes:**
- Updated to match Laravel Service model structure (homeowner job requests)
- Added fields: `homeownerId`, `jobCategoryId`, `jobDescription`, `location`, `status`, `rating`
- Added `ServiceCategory` class for category relationship
- Updated `fromJson` to parse Laravel API response structure
- Added legacy getters (`name`, `description`) for backward compatibility
- Fixed date parsing to use `created_at`/`updated_at` from Laravel

**Before:**
```dart
class Service {
  final int id;
  final String name;
  final String description;
  final String? icon;
}
```

**After:**
```dart
class Service {
  final int id;
  final int homeownerId;
  final int jobCategoryId;
  final String jobDescription;
  final String location;
  final String status;
  final int? rating;
  final ServiceCategory? category;
  // ...
}
```

---

### 2. ✅ API Constants (`lib/core/constants/api_constants.dart`)

**Changes:**
- Added Job Request endpoints: `/jobs`, `/jobs/{id}`, `/jobs/{id}/recommend-tradies`
- Added Booking endpoints: `/bookings/history`, `/bookings/{id}/cancel`
- Organized endpoints by feature

**New Endpoints:**
```dart
// Job Request Endpoints
static const String jobsEndpoint = '/jobs';
static String jobById(int id) => '/jobs/$id';
static String jobRecommendTradies(int jobId) => '/jobs/$jobId/recommend-tradies';

// Booking Endpoints
static const String bookingsEndpoint = '/bookings';
static String bookingHistory = '/bookings/history';
static String cancelBooking(int id) => '/bookings/$id/cancel';
```

---

### 3. ✅ TradieRepository (`lib/features/fetch_tradies/repositories/tradie_repository.dart`)

**Changes:**
- Fixed `fetchJobs()` to use `/jobs` endpoint (was using `/services`)
- Fixed `fetchJobDetail()` to use `/jobs/{jobId}` endpoint
- Fixed `fetchRecommendedTradies()` to use `/jobs/{jobId}/recommend-tradies` endpoint
- Updated response parsing to handle Laravel API structure: `{ success: true, data: [...] }`

**Before:**
```dart
final resp = await _dio.get('/services'); // Wrong endpoint
```

**After:**
```dart
final resp = await _dio.get('/jobs'); // Correct endpoint
final resp = await _dio.get('/jobs/$jobId/recommend-tradies'); // For recommendations
```

---

### 4. ✅ TradieModel (`lib/features/fetch_tradies/models/tradie_model.dart`)

**Changes:**
- Added new fields: `distance`, `availability`, `serviceRadius`, `city`, `region`, `avatar`
- Updated `fromJson` to handle Laravel API response structure
- Added parsing for `distance_km`, `average_rating`, `business_name`, `services` list
- Handles both old and new API response formats

**New Fields:**
```dart
final double? distance; // Distance in km from job location
final String? availability; // availability_status from API
final int? serviceRadius; // service_radius_km from API
final String? city;
final String? region;
final String? avatar;
```

**Laravel API Response Structure:**
```json
{
  "id": 1,
  "name": "James Electric",
  "business_name": "Auckland Electric Co",
  "distance_km": 2.5,
  "average_rating": 4.5,
  "total_reviews": 10,
  "hourly_rate": 85.00,
  "availability": "available",
  "service_radius_km": 50,
  "city": "Auckland",
  "region": "Auckland",
  "services": ["Electrical Installation", "Electrical Repair"],
  "avatar": "https://..."
}
```

---

### 5. ✅ BookingModel (`lib/features/booking_create_update_cancel/models/booking_model.dart`)

**Changes:**
- Updated `fromJson` to handle different Laravel response structures
- Added support for nested response: `{ booking: {...} }` or `{ data: {...} }`
- Improved error handling for date parsing
- Handles missing fields gracefully

**Response Handling:**
```dart
final bookingData = json['booking'] ?? json['data'] ?? json;
```

---

### 6. ✅ Tradie Model (Booking) (`lib/features/booking_create_update_cancel/models/tradie_model.dart`)

**Changes:**
- Updated to parse Laravel API response structure
- Handles `first_name`/`last_name` combination for name
- Parses `average_rating` from API
- Formats `hourly_rate` as currency string
- Handles `distance_km` from API
- Uses `availability_status` for `availableToday`

**Laravel Response Fields:**
- `first_name`, `last_name` → `name`
- `average_rating` → `rating`
- `hourly_rate` → `hourlyRate` (formatted)
- `distance_km` → `distance`
- `availability_status` → `availableToday`

---

### 7. ✅ ServiceModel (UrgentBooking) (`lib/features/urgentBooking/models/service_model.dart`)

**Changes:**
- Fixed date parsing to use `created_at`/`updated_at` (Laravel format)
- Falls back to `createdAt`/`updatedAt` for backward compatibility

**Before:**
```dart
createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
```

**After:**
```dart
createdAt: json['created_at'] != null
    ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
    : (json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now()),
```

---

### 8. ✅ BookingRepository (`lib/features/booking_create_update_cancel/repositories/booking_repository.dart`)

**Changes:**
- Added `getBookingHistory()` method for `/bookings/history` endpoint
- Returns grouped bookings: `{ 'upcoming': [...], 'past': [...] }`
- Updated response parsing to handle Laravel API structure

**New Method:**
```dart
Future<Map<String, List<Booking>>> getBookingHistory() async {
  // Returns { 'upcoming': [...], 'past': [...] }
}
```

---

## API Endpoint Mapping

### Laravel API → Flutter Endpoints

| Feature | Laravel Endpoint | Flutter Usage |
|---------|-----------------|---------------|
| **Job Requests** | `GET /api/jobs` | `TradieRepository.fetchJobs()` |
| **Job Details** | `GET /api/jobs/{id}` | `TradieRepository.fetchJobDetail(id)` |
| **Tradie Recommendations** | `GET /api/jobs/{id}/recommend-tradies` | `TradieRepository.fetchRecommendedTradies(id)` |
| **Services (Job Requests)** | `GET /api/services` | For homeowner job requests |
| **Bookings** | `GET /api/bookings` | `BookingRepository.getBookings()` |
| **Booking History** | `GET /api/bookings/history` | `BookingRepository.getBookingHistory()` |
| **Create Booking** | `POST /api/bookings` | `BookingRepository.createBooking()` |
| **Update Booking** | `PUT /api/bookings/{id}` | `BookingRepository.updateBooking()` |
| **Cancel Booking** | `POST /api/bookings/{id}/cancel` | `BookingRepository.cancelBooking(id)` |

---

## Response Structure Handling

### Laravel API Response Formats

**1. Success Response:**
```json
{
  "success": true,
  "data": [...],
  "count": 5
}
```

**2. Error Response:**
```json
{
  "success": false,
  "message": "Error message",
  "errors": {
    "field": ["Error 1", "Error 2"]
  }
}
```

**3. Paginated Response:**
```json
{
  "success": true,
  "data": {
    "data": [...],
    "current_page": 1,
    "total": 10
  }
}
```

All repositories now handle these response structures correctly.

---

## Testing Checklist

### ✅ Fetch Tradies Functionality

- [ ] Test fetching job requests: `GET /api/jobs`
- [ ] Test fetching job details: `GET /api/jobs/{id}`
- [ ] Test fetching tradie recommendations: `GET /api/jobs/{id}/recommend-tradies`
- [ ] Verify tradie data displays correctly (name, rating, distance, hourly rate)
- [ ] Verify services list displays for each tradie

### ✅ Booking Functionality

- [ ] Test fetching bookings: `GET /api/bookings`
- [ ] Test fetching booking history: `GET /api/bookings/history`
- [ ] Test creating booking: `POST /api/bookings`
- [ ] Test updating booking: `PUT /api/bookings/{id}`
- [ ] Test canceling booking: `POST /api/bookings/{id}/cancel`
- [ ] Verify booking data displays correctly (tradie, service, dates, status)

### ✅ Service/Job Request Functionality

- [ ] Test fetching services: `GET /api/services`
- [ ] Verify service data matches Laravel structure
- [ ] Verify category relationship loads correctly
- [ ] Verify homeowner relationship loads correctly

---

## Key Integration Points

### 1. Authentication
- All API calls use Bearer token authentication
- Token is automatically added via `DioClient` interceptor
- Token stored in secure storage

### 2. Error Handling
- All repositories use `ApiResult<T>` for type-safe error handling
- `Failure` class includes `message`, `statusCode`, and `errors`
- Network errors are properly caught and displayed

### 3. Date Parsing
- All date fields now parse both Laravel format (`created_at`) and legacy format (`createdAt`)
- Handles null dates gracefully

### 4. Response Parsing
- Handles multiple response structures:
  - Direct data: `{ data: [...] }`
  - Wrapped data: `{ success: true, data: [...] }`
  - Nested data: `{ booking: {...} }` or `{ data: {...} }`
  - Direct lists: `[...]`

---

## Breaking Changes

### ⚠️ Service Model Structure

**Old Structure:**
- `name` - Service name
- `description` - Service description
- `icon` - Service icon

**New Structure:**
- `homeownerId` - Homeowner who created the request
- `jobCategoryId` - Category of the job
- `jobDescription` - Description of the job
- `location` - Job location
- `status` - Job status (Pending, InProgress, Completed, Cancelled)
- `rating` - Job rating (1-5)

**Migration:**
- Legacy getters `name` and `description` return `jobDescription` for backward compatibility
- Update UI code to use new field names where needed

### ⚠️ Endpoint Changes

**Old:**
- `/services` for job requests
- `/services/{id}/recommend-tradies` for recommendations

**New:**
- `/jobs` for job requests
- `/jobs/{id}/recommend-tradies` for recommendations
- `/services` for homeowner job requests (different concept)

---

## Next Steps

1. **Test in Emulator:**
   - Run the Flutter app
   - Test fetching tradies for a job request
   - Test creating a booking
   - Test viewing booking history

2. **Verify Data Flow:**
   - Check that tradie recommendations appear correctly
   - Verify booking creation works
   - Confirm booking updates and cancellations work

3. **UI Updates (if needed):**
   - Update any UI that displays service data to use new field names
   - Ensure tradie details display all new fields (distance, availability, etc.)

---

## Files Summary

### Modified Files:
1. ✅ `lib/features/booking_create_update_cancel/models/service_model.dart`
2. ✅ `lib/core/constants/api_constants.dart`
3. ✅ `lib/features/fetch_tradies/repositories/tradie_repository.dart`
4. ✅ `lib/features/fetch_tradies/models/tradie_model.dart`
5. ✅ `lib/features/booking_create_update_cancel/models/booking_model.dart`
6. ✅ `lib/features/booking_create_update_cancel/models/tradie_model.dart`
7. ✅ `lib/features/urgentBooking/models/service_model.dart`
8. ✅ `lib/features/booking_create_update_cancel/repositories/booking_repository.dart`

### Unchanged Files (Already Compatible):
- ✅ `lib/features/booking_create_update_cancel/viewmodels/booking_viewmodel.dart`
- ✅ `lib/features/fetch_tradies/viewmodels/tradie_viewmodel.dart`
- ✅ `lib/core/network/dio_client.dart`

---

**End of Documentation**

