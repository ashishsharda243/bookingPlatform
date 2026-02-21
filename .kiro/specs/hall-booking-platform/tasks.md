# Implementation Plan: Hall Booking Platform

## Overview

Incremental implementation of the Hall Booking Platform using Flutter + Supabase. Tasks are ordered to build foundational layers first (core, data models, services), then feature modules (auth, discovery, booking, payment, owner, admin), and finally integration and wiring. Each task builds on previous ones with no orphaned code.

## Tasks

- [x] 1. Project scaffolding and core setup
  - [x] 1.1 Initialize Flutter project and configure dependencies
    - Create Flutter project with `flutter create`
    - Add dependencies to `pubspec.yaml`: `supabase_flutter`, `flutter_riverpod`, `riverpod_annotation`, `go_router`, `dio`, `freezed`, `freezed_annotation`, `json_annotation`, `build_runner`, `json_serializable`, `mapbox_gl`, `razorpay_flutter`, `firebase_messaging`, `geolocator`, `image_picker`, `image_compressor`, `cached_network_image`, `dartz`, `glados`, `mocktail`, `intl`
    - Configure `build.yaml` for Freezed code generation
    - _Requirements: 20.1, 20.2, 20.3, 20.4, 20.5_

  - [x] 1.2 Create directory structure and core module
    - Create `lib/core/constants/`, `lib/core/errors/`, `lib/core/theme/`, `lib/core/utils/`, `lib/core/widgets/`
    - Implement `Failure` sealed class with all error variants (ServerFailure, NetworkFailure, AuthFailure, ValidationFailure, ConflictFailure, ForbiddenFailure, NotFoundFailure, UnknownFailure)
    - Implement app theme with colors, typography, and spacing constants
    - Implement shared widgets: `LoadingIndicator`, `ErrorWidget` with retry, `EmptyStateWidget`
    - _Requirements: 20.1, 20.6, 19.2, 19.3, 19.4_

  - [x] 1.3 Set up Supabase service and Dio client
    - Create `lib/services/supabase_service.dart` with initialization and client access
    - Create `lib/services/dio_client.dart` with base URL, auth interceptor (JWT injection), and `ErrorInterceptor`
    - Configure Dio interceptor to map HTTP status codes to `Failure` types (401→AuthFailure, 403→ForbiddenFailure, 409→ConflictFailure)
    - _Requirements: 20.4, 20.6, 16.4, 16.5_

- [x] 2. Domain entities and data models
  - [x] 2.1 Create Freezed domain entities
    - Implement `AppUser`, `Hall`, `Slot`, `Booking`, `Payment`, `Review`, `EarningsReport`, `AnalyticsDashboard` as Freezed classes with `fromJson`/`toJson`
    - Run `build_runner` to generate `.freezed.dart` and `.g.dart` files
    - _Requirements: 20.5, 17.1, 17.4_

  - [ ]* 2.2 Write property tests for model serialization round-trip
    - **Property 26: Freezed model serialization round-trip**
    - For each entity, test that `Entity.fromJson(entity.toJson())` produces an equivalent object using glados generators
    - **Validates: Requirements 20.5**

  - [x] 2.3 Create repository interfaces
    - Implement abstract classes: `AuthRepository`, `DiscoveryRepository`, `BookingRepository`, `PaymentRepository`, `OwnerHallRepository`, `AdminRepository`, `ReviewRepository`
    - All methods return `Future<Either<Failure, T>>`
    - _Requirements: 20.1_

- [x] 3. Database schema and Supabase setup
  - [x] 3.1 Create SQL migration files
    - Write migration for `users`, `halls` (with PostGIS geography), `hall_images`, `slots` (with unique constraint on hall_id+date+start_time), `bookings`, `payments`, `reviews`, `platform_config` tables
    - Include all CHECK constraints, foreign keys, and indexes (spatial index on halls.location, index on slots hall_id+date)
    - _Requirements: 17.1, 17.2, 17.3, 17.4_

  - [x] 3.2 Create RLS policies
    - Write RLS policies for all tables: users (own data + admin), halls (approved public + owner own + admin), bookings (own + owner's hall bookings + admin), slots (public read + owner/admin write), reviews (public read + own insert), payments (own + admin), platform_config (admin only)
    - _Requirements: 16.1, 16.2, 16.3_

  - [x] 3.3 Create database functions
    - Implement `create_booking` function with SELECT FOR UPDATE locking, slot status check, atomic slot update + booking insert
    - Implement `get_nearby_halls` function with PostGIS ST_DWithin and ST_Distance, sorted by distance, with pagination
    - _Requirements: 4.3, 4.4, 4.5, 2.2, 2.3_

  - [ ]* 3.4 Write property tests for geo-query and booking functions
    - **Property 2: Geo-filter radius correctness** - For any set of hall locations and user position, returned halls are within 2km
    - **Property 7: Slot uniqueness constraint** - For any duplicate (hall_id, date, start_time), insert fails
    - **Property 8: Concurrent booking serialization** - For any two concurrent booking calls on same slot, exactly one succeeds
    - **Validates: Requirements 2.2, 4.4, 4.5, 17.2**

- [x] 4. Checkpoint - Core foundation
  - Ensure all tests pass, ask the user if questions arise.

- [x] 5. Authentication feature
  - [x] 5.1 Implement auth data layer
    - Create `AuthRemoteDataSource` using Supabase Auth for OTP sign-in (`signInWithOtp`), OTP verification (`verifyOTP`), Google sign-in (`signInWithIdToken`), sign-out, and auth state stream
    - Implement `AuthRepositoryImpl` mapping Supabase responses to `Either<Failure, AppUser>`
    - On new registration, insert user record with role="user" into users table
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.6_

  - [x] 5.2 Implement auth presentation layer
    - Create `AuthNotifier` Riverpod provider managing auth state
    - Create `SplashScreen` checking auth state and redirecting
    - Create `LoginScreen` with phone number input + OTP entry, Google sign-in button
    - Create `OtpVerificationScreen` with OTP input and countdown timer
    - _Requirements: 1.1, 1.2, 1.5_

  - [ ]* 5.3 Write property test for default role
    - **Property 1: New user default role invariant**
    - For any new user registration, the created user record has role="user"
    - **Validates: Requirements 1.4**

  - [x] 5.4 Implement GoRouter with role-based guards
    - Create `AppRouter` with routes for all screens grouped by role
    - Implement redirect logic: unauthenticated → login, role mismatch → appropriate home
    - Define route guards checking user role for owner and admin routes
    - _Requirements: 20.3, 16.4, 16.5_

- [x] 6. Discovery feature
  - [x] 6.1 Implement discovery data layer
    - Create `DiscoveryRemoteDataSource` calling `get_nearby_halls` RPC, hall detail query with images and reviews join
    - Implement `DiscoveryRepositoryImpl` with pagination support (page, pageSize)
    - Implement search with text matching on hall name/description/address
    - _Requirements: 2.2, 2.3, 2.7, 2.8, 3.1_

  - [x] 6.2 Implement location service
    - Create `LocationService` using `geolocator` package for GPS coordinates
    - Handle permission request, denied state, and manual fallback
    - _Requirements: 2.1, 2.6_

  - [x] 6.3 Implement Mapbox service
    - Create `MapboxService` for map initialization and marker rendering
    - _Requirements: 2.4, 3.4_

  - [x] 6.4 Implement discovery presentation layer
    - Create `HomeScreen` with map/list toggle, search bar with 300ms debounce
    - Create `HallListView` with paginated card list (name, distance, price, rating, thumbnail)
    - Create `HallMapView` with Mapbox markers for nearby halls
    - Create `HallDetailScreen` with image carousel, amenities, reviews, embedded map, and "Book Now" button
    - _Requirements: 2.3, 2.4, 2.5, 2.7, 2.8, 3.1, 3.2, 3.3, 3.4, 19.1, 19.5, 19.6_

  - [ ]* 6.5 Write property tests for discovery
    - **Property 3: Distance sorting invariant** - For any list of halls, distance[i] <= distance[i+1]
    - **Property 4: Pagination size bound** - For any page, result count <= 20
    - **Property 5: Average rating correctness** - For any set of reviews, average = sum/count
    - **Property 24: Search visibility filter** - For any search result, all halls have approval_status="approved"
    - **Validates: Requirements 2.3, 2.7, 3.3, 7.3, 13.4**

- [x] 7. Booking feature
  - [x] 7.1 Implement booking data layer
    - Create `BookingRemoteDataSource` calling `create_booking` RPC, slot queries by hall+date, user booking history with joins
    - Implement `BookingRepositoryImpl` with slot availability check, booking creation, cancellation logic (24hr check), and pagination
    - Implement price calculation: total_price = hall.base_price per slot
    - _Requirements: 4.1, 4.2, 4.3, 4.6, 6.1, 6.2, 6.3, 6.4_

  - [x] 7.2 Implement booking presentation layer
    - Create `SlotSelectionScreen` with date picker and slot grid (available/unavailable visual states)
    - Create `BookingConfirmationScreen` showing hall, slot, price summary with confirm button
    - Create `BookingHistoryScreen` with paginated list sorted newest first
    - Create `BookingDetailScreen` showing full booking info, cancel button (conditionally visible)
    - _Requirements: 4.1, 4.2, 6.1, 6.2, 19.2, 19.4_

  - [ ]* 7.3 Write property tests for booking
    - **Property 6: Atomic booking state transition** - For any available slot, after booking: slot=booked, booking=pending
    - **Property 9: Price calculation correctness** - For any hall base_price, total matches expected
    - **Property 14: Booking history sort order** - For any booking list, created_at[i] >= created_at[i+1]
    - **Property 15: Cancellation time boundary** - For any booking >= 24hrs out, cancel succeeds; < 24hrs, rejected
    - **Validates: Requirements 4.3, 4.6, 5.1, 6.1, 6.3, 6.4**

- [x] 8. Payment feature
  - [x] 8.1 Implement Razorpay service
    - Create `RazorpayService` wrapping `razorpay_flutter` plugin
    - Handle payment success, failure, and external wallet callbacks
    - _Requirements: 5.1_

  - [x] 8.2 Implement payment Edge Function
    - Create `supabase/functions/verify-payment/index.ts` Edge Function
    - Verify Razorpay signature using HMAC-SHA256: `hmac_sha256(razorpay_key_secret, order_id + "|" + payment_id)`
    - On success: update booking_status to "confirmed", create payment record
    - On failure: update booking_status to "failed", release slot to "available"
    - _Requirements: 5.2, 5.3, 5.4, 5.6_

  - [x] 8.3 Implement booking expiry Edge Function
    - Create `supabase/functions/expire-bookings/index.ts` Edge Function
    - Query bookings with status "pending" and created_at > 10 minutes ago
    - Update booking_status to "cancelled", release slots to "available"
    - Configure pg_cron to run every 5 minutes
    - _Requirements: 5.5_

  - [x] 8.4 Implement payment data layer and presentation
    - Create `PaymentRemoteDataSource` calling verify-payment Edge Function
    - Implement `PaymentRepositoryImpl`
    - Create `PaymentScreen` integrating Razorpay checkout flow with loading and result states
    - Wire booking confirmation → Razorpay → verification → success/failure screens
    - _Requirements: 5.1, 5.2, 5.3, 5.4_

  - [ ]* 8.5 Write property tests for payment
    - **Property 10: Payment signature verification** - For any valid HMAC input, verification passes; tampered input fails
    - **Property 11: Payment success state transition** - After successful verification: booking=confirmed, payment record exists
    - **Property 12: Payment failure state transition** - After failed verification: booking=failed, slot=available
    - **Property 13: Booking expiry** - Pending bookings > 10min old get cancelled, slots released
    - **Validates: Requirements 5.2, 5.3, 5.4, 5.5**

- [x] 9. Checkpoint - Core user flow complete
  - Ensure all tests pass, ask the user if questions arise.

- [x] 10. Reviews feature
  - [x] 10.1 Implement review data layer and presentation
    - Create `ReviewRemoteDataSource` with submit review (check completed booking, enforce unique user+hall), get hall reviews with pagination
    - Implement `ReviewRepositoryImpl`
    - Create `ReviewFormWidget` with star rating selector and comment input
    - Create `ReviewListWidget` with paginated reviews
    - Wire review submission from `HallDetailScreen` (only visible for users with completed bookings)
    - _Requirements: 7.1, 7.2, 7.3, 3.3_

  - [ ]* 10.2 Write property tests for reviews
    - **Property 16: Review authorization and uniqueness** - Review succeeds only with completed booking; second review rejected
    - **Validates: Requirements 7.1, 7.2**

- [x] 11. Notifications feature
  - [x] 11.1 Implement FCM service and notification Edge Function
    - Create `FcmService` for token registration, foreground message handling, background handler setup
    - Create `supabase/functions/send-notification/index.ts` Edge Function using Firebase Admin SDK
    - Register FCM token on login, associate with user record
    - Trigger notifications from verify-payment function (booking confirmed → user + owner)
    - Implement booking reminder: schedule notification 1hr before slot start
    - _Requirements: 8.1, 8.2, 8.3, 8.4_

- [x] 12. User profile feature
  - [x] 12.1 Implement profile data layer and presentation
    - Create `ProfileRemoteDataSource` with get/update profile, upload profile image (compress to max 500KB via Supabase Storage)
    - Implement `ProfileRepositoryImpl`
    - Create `ProfileScreen` displaying name, phone, email, profile picture with edit capability
    - _Requirements: 9.1, 9.2, 9.3, 18.2_

  - [ ]* 12.2 Write property test for profile update
    - **Property 17: Profile update round-trip** - For any valid update, reading back returns updated values
    - **Validates: Requirements 9.2**

- [x] 13. Hall Owner features
  - [x] 13.1 Implement owner hall management
    - Create `OwnerHallRemoteDataSource` with create hall (pending status), update hall (preserve approval_status), upload images (max 10, compress, store in Supabase Storage)
    - Implement `OwnerHallRepositoryImpl`
    - Create `OwnerDashboardScreen` with hall list and add button
    - Create `AddEditHallScreen` with form for all hall fields, image picker, slot duration selector (validated 30-480 min)
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6_

  - [x] 13.2 Implement owner availability management
    - Implement block/unblock date range logic: create blocked slots, unblock only non-booked slots, reject blocking booked slots
    - Create `AvailabilityCalendarScreen` showing available/booked/blocked slots per date
    - Create date range picker for block/unblock actions
    - _Requirements: 11.1, 11.2, 11.3, 11.4_

  - [x] 13.3 Implement owner bookings and earnings
    - Implement owner booking list (all bookings for owned halls, sorted by date)
    - Implement earnings calculation: gross revenue, commission deduction (from platform_config), net earnings by period
    - Create `OwnerBookingsScreen` with booking list
    - Create `EarningsReportScreen` with period selector (daily/weekly/monthly) and revenue breakdown
    - _Requirements: 12.1, 12.2, 12.3, 12.4_

  - [ ]* 13.4 Write property tests for owner features
    - **Property 18: New hall pending status invariant** - New halls have approval_status="pending", correct owner_id
    - **Property 19: Hall edit preserves approval status** - Editing a hall does not change approval_status
    - **Property 20: Slot duration validation** - Values in [30, 480] accepted, outside rejected
    - **Property 21: Block/unblock slot integrity** - Blocked slots are "blocked"; unblock only changes "blocked" to "available", not "booked"
    - **Property 22: Cannot block booked slots** - Block attempt on confirmed-booking slot is rejected
    - **Property 23: Earnings calculation** - net = gross * (1 - commission/100)
    - **Validates: Requirements 10.2, 10.3, 10.6, 11.1, 11.2, 11.4, 12.3**

- [x] 14. Admin features
  - [x] 14.1 Implement admin hall approval
    - Create `AdminRemoteDataSource` with get pending halls, approve hall (set approved), reject hall (set rejected + reason)
    - Implement `AdminRepositoryImpl`
    - Create `HallApprovalScreen` with pending hall list and approve/reject actions
    - _Requirements: 13.1, 13.2, 13.3_

  - [x] 14.2 Implement admin user management
    - Implement get users (paginated), update user role, deactivate user (set is_active=false, cancel active bookings)
    - Create `UserManagementScreen` with user list, role change dropdown, deactivate button
    - _Requirements: 14.1, 14.2, 14.3_

  - [x] 14.3 Implement admin analytics and commission
    - Implement analytics queries: total bookings, total revenue, active users, active halls by period
    - Implement commission get/set from platform_config table
    - Create `AnalyticsDashboardScreen` with period selector and stat cards
    - Create `CommissionManagementScreen` with current rate display and update form
    - _Requirements: 15.1, 15.2, 15.3_

  - [ ]* 14.4 Write property test for role-based access
    - **Property 25: Role-based data access** - Users see only own bookings/profile; owners see only own halls/slots; admins see all
    - **Validates: Requirements 16.1, 16.2, 16.3**

- [x] 15. Checkpoint - All features implemented
  - Ensure all tests pass, ask the user if questions arise.

- [x] 16. Performance optimizations and polish
  - [x] 16.1 Implement caching and performance features
    - Add client-side caching for hall listings and profile data with 5-minute TTL using Riverpod `keepAlive` and `Timer`
    - Implement lazy loading for all image widgets using `cached_network_image`
    - Implement image compression utility (max 500KB) for profile and hall image uploads
    - Add database connection pooling configuration in Supabase project settings
    - _Requirements: 18.1, 18.2, 18.3, 18.5_

  - [x] 16.2 Implement responsive UI and animations
    - Add responsive breakpoints for mobile and web layouts using `LayoutBuilder`
    - Implement page transitions using `GoRouter` custom transitions
    - Add loading shimmer effects for list and detail screens
    - Ensure consistent card layout, spacing, and typography across all screens
    - _Requirements: 19.1, 19.2, 19.5, 19.6_

- [x] 17. Integration wiring and final validation
  - [x] 17.1 Wire complete booking flow end-to-end
    - Connect: Hall discovery → Hall detail → Slot selection → Booking confirmation → Razorpay payment → Payment verification → Booking confirmed → Notification sent
    - Ensure all navigation routes are registered in GoRouter
    - Ensure all providers are properly scoped and disposed
    - _Requirements: 4.3, 5.1, 5.2, 5.3, 8.1_

  - [x] 17.2 Wire owner and admin flows
    - Connect: Owner dashboard → Add/edit hall → Image upload → Availability management → Bookings → Earnings
    - Connect: Admin dashboard → Hall approval → User management → Analytics → Commission
    - Ensure role-based route guards prevent unauthorized navigation
    - _Requirements: 10.1, 11.3, 12.1, 13.1, 14.1, 15.1, 16.4, 16.5_

  - [ ]* 17.3 Write integration tests for critical flows
    - Test complete booking flow: search → select → book → pay → confirm
    - Test owner flow: create hall → upload images → manage availability
    - Test admin flow: approve hall → appears in search
    - _Requirements: 4.3, 5.3, 10.2, 13.2_

- [x] 18. Final checkpoint - All tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document (26 properties)
- Unit tests validate specific examples and edge cases
- Supabase Edge Functions are written in TypeScript; all Flutter code is Dart
- Run `dart run build_runner build` after creating/modifying Freezed models
