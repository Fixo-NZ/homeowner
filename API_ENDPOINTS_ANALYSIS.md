# Laravel API Endpoints Analysis

## Current Status

### ✅ Existing Laravel Endpoints (Working)

#### `/api/bookings` - Used by `features/booking_create_update_cancel`
- **GET `/api/bookings`** - List all bookings for homeowner
  - Returns: `[...]` (direct array)
  - ✅ **Flutter code matches perfectly**
  
- **POST `/api/bookings`** - Create booking
  - Requires: `tradie_id`, `service_id`, `booking_start`, `booking_end`
  - Returns: `{ success: true, message: "...", booking: {...} }`
  - ✅ **Flutter code matches perfectly**
  
- **GET `/api/bookings/{id}`** - Get booking details
  - Returns: `{...}` (direct booking object)
  - ✅ **Flutter code matches perfectly**
  
- **PUT `/api/bookings/{id}`** - Update booking
  - Requires: `booking_start`, `booking_end`
  - Returns: `{ success: true, message: "...", booking: {...} }`
  - ✅ **Flutter code matches perfectly**
  
- **POST `/api/bookings/{id}/cancel`** - Cancel booking
  - Returns: `{ success: true, message: "...", booking: {...} }`
  - ✅ **Flutter code matches perfectly**

### ❌ Missing Laravel Endpoints (Needed by `features/urgentBooking`)

#### `/api/services` - **DOES NOT EXIST**
- **GET `/api/services`** - List all services
  - Needed by: `UrgentBookingRepository.fetchServices()`
  - **Status**: ❌ Missing
  
- **POST `/api/services`** - Create service
  - Needed by: `UrgentBookingRepository.createService()`
  - **Status**: ❌ Missing
  
- **GET `/api/services/{id}`** - Get service details
  - Needed by: `UrgentBookingRepository.getServiceById()`
  - **Status**: ❌ Missing
  
- **PUT `/api/services/{id}`** - Update service
  - Needed by: `UrgentBookingRepository.updateService()`
  - **Status**: ❌ Missing
  
- **DELETE `/api/services/{id}`** - Delete service
  - Needed by: `UrgentBookingRepository.deleteService()`
  - **Status**: ❌ Missing

#### `/api/urgent-bookings` - **DOES NOT EXIST**
- **GET `/api/urgent-bookings`** - List urgent bookings
  - Needed by: `UrgentBookingRepository.fetchUrgentBookings()`
  - **Status**: ❌ Missing
  
- **POST `/api/urgent-bookings`** - Create urgent booking
  - Needed by: `UrgentBookingRepository.createUrgentBooking()`
  - **Status**: ❌ Missing
  
- **GET `/api/urgent-bookings/{id}`** - Get urgent booking
  - Needed by: `UrgentBookingRepository.getUrgentBookingById()`
  - **Status**: ❌ Missing
  
- **PUT `/api/urgent-bookings/{id}`** - Update urgent booking
  - Needed by: `UrgentBookingRepository.updateUrgentBooking()`
  - **Status**: ❌ Missing

#### `/api/services/{id}/recommend-tradies` - **DOES NOT EXIST**
- **GET `/api/services/{id}/recommend-tradies`** - Get tradie recommendations
  - Needed by: `UrgentBookingRepository.getTradieRecommendations()`
  - **Status**: ❌ Missing

#### `/api/urgent-bookings/{id}/recommendations` - **DOES NOT EXIST**
- **GET `/api/urgent-bookings/{id}/recommendations`** - Get booking recommendations
  - Needed by: `UrgentBookingRepository.getBookingRecommendations()`
  - **Status**: ❌ Missing

## Relationship Analysis

### Laravel Models
- **`Service`** model exists (has `name`, `description`, `category`, `is_active`)
- **`Booking`** model exists (has `homeowner_id`, `tradie_id`, `service_id`, `booking_start`, `booking_end`, `status`)
- **`Booking`** belongs to **`Service`** (via `service_id`)

### Current Flow in Flutter
1. **`booking_flow_screen.dart`** creates:
   - ✅ Regular booking via `/api/bookings` (WORKS)
   - ❌ Urgent booking via `/api/urgent-bookings` (FAILS - endpoint doesn't exist)

2. **`booking_create_update_cancel`** feature:
   - ✅ Fully functional with existing Laravel endpoints
   - ✅ All CRUD operations work correctly

3. **`urgentBooking`** feature:
   - ❌ Cannot fetch services (no `/api/services`)
   - ❌ Cannot create urgent bookings (no `/api/urgent-bookings`)
   - ❌ Cannot get tradie recommendations (no `/api/services/{id}/recommend-tradies`)

## Solutions

### Option 1: Add Missing Endpoints to Laravel (Recommended)
Add the following endpoints to Laravel:
- `/api/services` (GET, POST)
- `/api/services/{id}` (GET, PUT, DELETE)
- `/api/urgent-bookings` (GET, POST)
- `/api/urgent-bookings/{id}` (GET, PUT)
- `/api/services/{id}/recommend-tradies` (GET)

### Option 2: Map Urgent Bookings to Regular Bookings
Since urgent bookings and regular bookings are similar, we could:
- Use `/api/bookings` for urgent bookings
- Add a `priority` or `is_urgent` field to regular bookings
- This would require Laravel changes (which user said not to do)

### Option 3: Comment Out Missing Features
- Comment out `/api/services` calls
- Comment out `/api/urgent-bookings` calls
- Keep only the regular booking functionality working

## Recommendation

**Since the user said not to modify Laravel**, we should:
1. ✅ Keep `booking_create_update_cancel` working (it already works perfectly)
2. ⚠️ Handle missing endpoints gracefully in `urgentBooking` feature
3. 📝 Document what needs to be added to Laravel for full functionality

