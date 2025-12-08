# 📋 Guide: Populate Bookings in Database

**Purpose:** Create sample bookings data for testing  
**Database:** PostgreSQL  
**Method:** SQL Scripts + Laravel Seeder

---

## 🎯 Two Ways to Populate Bookings

### Method 1: Using SQL Scripts (Quick & Direct)

#### Step 1: Connect to PostgreSQL

```bash
# Windows (using psql)
psql -U postgres -d your_database_name

# Or using pgAdmin
# Open pgAdmin and connect to your database
```

#### Step 2: Run SQL Script

```sql
-- First, check if you have homeowners, tradies, and services
SELECT COUNT(*) as homeowners FROM homeowners;
SELECT COUNT(*) as tradies FROM tradies;
SELECT COUNT(*) as services FROM services;

-- Get IDs to use for bookings
SELECT id, email FROM homeowners LIMIT 5;
SELECT id, first_name, last_name FROM tradies LIMIT 5;
SELECT id, homeowner_id, job_description FROM services LIMIT 5;

-- Create sample bookings
INSERT INTO bookings (
    homeowner_id,
    tradie_id,
    service_id,
    booking_start,
    booking_end,
    status,
    booking_number,
    created_at,
    updated_at
) VALUES
-- Booking 1: Upcoming (Pending)
(
    (SELECT id FROM homeowners ORDER BY id LIMIT 1 OFFSET 0),
    (SELECT id FROM tradies ORDER BY id LIMIT 1 OFFSET 0),
    (SELECT id FROM services ORDER BY id LIMIT 1 OFFSET 0),
    NOW() + INTERVAL '3 days',
    NOW() + INTERVAL '3 days 2 hours',
    'pending',
    'BK-' || LPAD(nextval('bookings_id_seq'::regclass)::text, 6, '0'),
    NOW(),
    NOW()
),
-- Booking 2: Upcoming (Confirmed)
(
    (SELECT id FROM homeowners ORDER BY id LIMIT 1 OFFSET 0),
    (SELECT id FROM tradies ORDER BY id LIMIT 1 OFFSET 1),
    (SELECT id FROM services ORDER BY id LIMIT 1 OFFSET 1),
    NOW() + INTERVAL '5 days',
    NOW() + INTERVAL '5 days 3 hours',
    'confirmed',
    'BK-' || LPAD(nextval('bookings_id_seq'::regclass)::text, 6, '0'),
    NOW(),
    NOW()
),
-- Booking 3: Past (Completed)
(
    (SELECT id FROM homeowners ORDER BY id LIMIT 1 OFFSET 0),
    (SELECT id FROM tradies ORDER BY id LIMIT 1 OFFSET 2),
    (SELECT id FROM services ORDER BY id LIMIT 1 OFFSET 2),
    NOW() - INTERVAL '5 days',
    NOW() - INTERVAL '5 days 2 hours',
    'completed',
    'BK-' || LPAD(nextval('bookings_id_seq'::regclass)::text, 6, '0'),
    NOW() - INTERVAL '5 days',
    NOW() - INTERVAL '1 day'
),
-- Booking 4: Active (In Progress)
(
    (SELECT id FROM homeowners ORDER BY id LIMIT 1 OFFSET 0),
    (SELECT id FROM tradies ORDER BY id LIMIT 1 OFFSET 0),
    (SELECT id FROM services ORDER BY id LIMIT 1 OFFSET 0),
    NOW() - INTERVAL '1 hour',
    NOW() + INTERVAL '2 hours',
    'active',
    'BK-' || LPAD(nextval('bookings_id_seq'::regclass)::text, 6, '0'),
    NOW() - INTERVAL '2 days',
    NOW()
);

-- Verify bookings were created
SELECT 
    b.id,
    b.booking_number,
    b.status,
    h.email as homeowner_email,
    t.first_name || ' ' || t.last_name as tradie_name,
    s.job_description,
    b.booking_start,
    b.booking_end
FROM bookings b
JOIN homeowners h ON b.homeowner_id = h.id
JOIN tradies t ON b.tradie_id = t.id
JOIN services s ON b.service_id = s.id
ORDER BY b.booking_start DESC;
```

---

### Method 2: Using Laravel Seeder (Recommended for Production)

#### Step 1: Create Seeder

Create file: `database/seeders/BookingSeeder.php`

```php
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Booking;
use App\Models\Homeowner;
use App\Models\Tradie;
use App\Models\Service;
use Carbon\Carbon;

class BookingSeeder extends Seeder
{
    public function run()
    {
        // Get first homeowner (or use specific ID)
        $homeowner = Homeowner::first();
        if (!$homeowner) {
            $this->command->error('No homeowners found. Please seed homeowners first.');
            return;
        }

        // Get tradies
        $tradies = Tradie::take(3)->get();
        if ($tradies->isEmpty()) {
            $this->command->error('No tradies found. Please seed tradies first.');
            return;
        }

        // Get services for this homeowner
        $services = Service::where('homeowner_id', $homeowner->id)->take(3)->get();
        if ($services->isEmpty()) {
            $this->command->error('No services found for homeowner. Please create services first.');
            return;
        }

        // Create bookings
        $bookings = [
            [
                'homeowner_id' => $homeowner->id,
                'tradie_id' => $tradies[0]->id,
                'service_id' => $services[0]->id ?? $services->first()->id,
                'booking_start' => Carbon::now()->addDays(3),
                'booking_end' => Carbon::now()->addDays(3)->addHours(2),
                'status' => 'pending',
            ],
            [
                'homeowner_id' => $homeowner->id,
                'tradie_id' => $tradies[1]->id ?? $tradies[0]->id,
                'service_id' => $services[1]->id ?? $services->first()->id,
                'booking_start' => Carbon::now()->addDays(5),
                'booking_end' => Carbon::now()->addDays(5)->addHours(3),
                'status' => 'confirmed',
            ],
            [
                'homeowner_id' => $homeowner->id,
                'tradie_id' => $tradies[2]->id ?? $tradies[0]->id,
                'service_id' => $services[2]->id ?? $services->first()->id,
                'booking_start' => Carbon::now()->subDays(5),
                'booking_end' => Carbon::now()->subDays(5)->addHours(2),
                'status' => 'completed',
            ],
        ];

        foreach ($bookings as $bookingData) {
            $booking = Booking::create($bookingData);
            $this->command->info("Created booking: {$booking->booking_number} - {$booking->status}");
        }

        $this->command->info('Bookings seeded successfully!');
    }
}
```

#### Step 2: Run Seeder

```bash
cd C:\Users\Ricardo\fixo_laravel\laravel_admin_api

# Run specific seeder
php artisan db:seed --class=BookingSeeder

# Or add to DatabaseSeeder and run all
php artisan db:seed
```

---

## 🔍 Verify Bookings

### Check in PostgreSQL:

```sql
SELECT 
    b.id,
    b.booking_number,
    b.status,
    h.email as homeowner,
    CONCAT(t.first_name, ' ', t.last_name) as tradie,
    s.job_description as service,
    b.booking_start,
    b.booking_end
FROM bookings b
LEFT JOIN homeowners h ON b.homeowner_id = h.id
LEFT JOIN tradies t ON b.tradie_id = t.id
LEFT JOIN services s ON b.service_id = s.id
ORDER BY b.booking_start DESC;
```

### Check via API:

```bash
# Get your token first (login)
curl -X POST http://10.0.2.2:8000/api/homeowner/login \
  -H "Content-Type: application/json" \
  -d '{"email":"your_email@example.com","password":"your_password"}'

# Use the token to get bookings
curl -X GET http://10.0.2.2:8000/api/bookings \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json"
```

---

## 🎯 Dynamic Booking Creation (Via App)

The best way is to create bookings through the app:

1. **Login** as homeowner
2. **Create a Service Request** (`/urgent-booking/create`)
3. **Get Tradie Recommendations** for that service
4. **Book a Tradie** through the booking flow
5. **Booking is automatically created** in the database

---

## 📝 Quick SQL Script for Testing

If you want to quickly add test bookings, run this SQL:

```sql
-- Replace with actual IDs from your database
DO $$
DECLARE
    v_homeowner_id INTEGER;
    v_tradie_id INTEGER;
    v_service_id INTEGER;
BEGIN
    -- Get IDs (adjust OFFSET as needed)
    SELECT id INTO v_homeowner_id FROM homeowners ORDER BY id LIMIT 1;
    SELECT id INTO v_tradie_id FROM tradies ORDER BY id LIMIT 1;
    SELECT id INTO v_service_id FROM services WHERE homeowner_id = v_homeowner_id LIMIT 1;
    
    -- Create booking
    IF v_homeowner_id IS NOT NULL AND v_tradie_id IS NOT NULL AND v_service_id IS NOT NULL THEN
        INSERT INTO bookings (
            homeowner_id,
            tradie_id,
            service_id,
            booking_start,
            booking_end,
            status,
            created_at,
            updated_at
        ) VALUES (
            v_homeowner_id,
            v_tradie_id,
            v_service_id,
            NOW() + INTERVAL '2 days',
            NOW() + INTERVAL '2 days 2 hours',
            'pending',
            NOW(),
            NOW()
        );
        
        RAISE NOTICE 'Booking created successfully!';
    ELSE
        RAISE NOTICE 'Missing required data. Check homeowners, tradies, and services.';
    END IF;
END $$;
```

---

## ✅ After Populating

1. **Refresh the app** or navigate back to bookings screen
2. **Check console logs** for booking count
3. **Bookings should appear** in the list

---

**Status:** ✅ Ready to populate bookings!

