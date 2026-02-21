# Requirements Document

## Introduction

A production-ready Hall Booking Platform built with Flutter (Android, iOS, Web), Supabase (PostgreSQL, Auth, Storage, Realtime), Razorpay (Payments), Mapbox (Location & Maps), and Firebase Cloud Messaging (Push Notifications). The platform enables users to discover nearby halls via GPS, book time slots with configurable durations, and pay securely. Hall owners manage listings and availability, while admins oversee platform operations. The system enforces strict role-based access control, prevents double bookings at the database level, and is designed to scale from 100 to 100,000 users.

## Glossary

- **Platform**: The Hall Booking Platform application encompassing Flutter clients and Supabase backend
- **User**: A customer who searches for, books, and pays for hall time slots
- **Hall_Owner**: A registered user who owns and manages one or more hall listings
- **Admin**: A platform administrator with full access to manage halls, users, and analytics
- **Hall**: A bookable venue listed on the platform with location, amenities, pricing, and images
- **Slot**: A discrete time block for a specific hall on a specific date (available, booked, or blocked)
- **Booking**: A reservation linking a User to a Slot with payment and status tracking
- **RLS**: Row-Level Security policies enforced at the Supabase/PostgreSQL level
- **RBAC**: Role-Based Access Control for User, Hall_Owner, and Admin roles
- **PostGIS**: PostgreSQL spatial extension for geographic queries
- **Razorpay**: Payment gateway for processing payments in India
- **FCM**: Firebase Cloud Messaging for push notifications
- **Mapbox**: Mapping and location services provider
- **Slot_Duration**: Configurable length of a booking slot (1hr, 2hr, custom)
- **Approval_Status**: Hall listing state (pending, approved, rejected)
- **Payment_Status**: Payment state (pending, completed, failed, refunded)
- **Booking_Status**: Booking state (pending, confirmed, cancelled, completed)

## Requirements

### Requirement 1: User Authentication and Registration

**User Story:** As a user, I want to register and log in using OTP or Google authentication, so that I can securely access the platform.

#### Acceptance Criteria

1. WHEN a user provides a valid phone number, THE Platform SHALL send a one-time password via SMS and allow login upon correct OTP entry
2. WHEN a user selects Google sign-in, THE Platform SHALL authenticate via Google OAuth and create or link the user account
3. WHEN authentication succeeds, THE Platform SHALL issue a JWT token via Supabase Auth and store the session securely on the device
4. WHEN a new user registers, THE Platform SHALL create a user record with role set to "user" by default in the users table
5. IF authentication fails after 3 consecutive attempts, THEN THE Platform SHALL temporarily lock the account for 15 minutes and display an informative message
6. WHEN a user logs out, THE Platform SHALL invalidate the session token and redirect to the login screen

### Requirement 2: Location-Based Hall Discovery

**User Story:** As a user, I want to discover halls near my current location, so that I can find convenient venues to book.

#### Acceptance Criteria

1. WHEN the app launches for the first time, THE Platform SHALL request location permission from the user
2. WHEN location permission is granted, THE Platform SHALL retrieve the user GPS coordinates and query halls within a 2km radius using PostGIS
3. WHEN displaying nearby halls, THE Platform SHALL sort results by distance from the user location (nearest first)
4. WHEN the user toggles to map view, THE Platform SHALL render hall locations as markers on a Mapbox map centered on the user position
5. WHEN the user toggles to list view, THE Platform SHALL display halls as cards showing name, distance, base price, rating, and thumbnail image
6. IF location permission is denied, THEN THE Platform SHALL display a message explaining the need for location access and provide a manual address search fallback
7. WHEN the user scrolls the hall list, THE Platform SHALL load additional results using pagination with a page size of 20 items
8. WHEN the user types in the search field, THE Platform SHALL debounce input by 300ms before executing the search query

### Requirement 3: Hall Details and Information Display

**User Story:** As a user, I want to view detailed information about a hall, so that I can make an informed booking decision.

#### Acceptance Criteria

1. WHEN a user selects a hall from the list or map, THE Platform SHALL navigate to a detail screen showing name, description, address, amenities, base price, slot duration, images, and reviews
2. WHEN displaying hall images, THE Platform SHALL show images in a scrollable carousel with lazy loading and compressed thumbnails
3. WHEN displaying reviews, THE Platform SHALL show the average rating and a paginated list of individual reviews with rating, comment, and reviewer name
4. WHEN the hall detail screen loads, THE Platform SHALL display the hall location on an embedded Mapbox map

### Requirement 4: Slot Selection and Booking Creation

**User Story:** As a user, I want to select available time slots and create bookings, so that I can reserve a hall for my event.

#### Acceptance Criteria

1. WHEN a user navigates to slot selection for a hall, THE Platform SHALL display a date picker and available slots for the selected date
2. WHEN displaying slots, THE Platform SHALL show each slot start time, end time, and status (available or unavailable)
3. WHEN a user selects an available slot and confirms, THE Platform SHALL create a booking record with status "pending" and mark the slot as "booked" within a single database transaction
4. THE Platform SHALL enforce a unique constraint on the combination of hall_id, date, and start_time to prevent double bookings at the database level
5. IF two users attempt to book the same slot simultaneously, THEN THE Platform SHALL use database transaction locking so that only the first transaction succeeds and the second receives a conflict error
6. WHEN a booking is created, THE Platform SHALL calculate the total price based on the hall base price and slot duration
7. IF a slot is no longer available when the user confirms, THEN THE Platform SHALL display an error message and refresh the slot availability view

### Requirement 5: Payment Processing

**User Story:** As a user, I want to pay for my booking securely through Razorpay, so that my reservation is confirmed.

#### Acceptance Criteria

1. WHEN a booking is created with status "pending", THE Platform SHALL generate a Razorpay order with the booking total price
2. WHEN the Razorpay payment is completed on the client, THE Platform SHALL verify the payment signature on the server side before confirming
3. WHEN payment verification succeeds, THE Platform SHALL update the booking status to "confirmed", the slot status to "booked", and create a payment record with the razorpay_payment_id
4. IF payment verification fails, THEN THE Platform SHALL mark the booking as "failed", release the slot back to "available", and display an error to the user
5. IF a pending booking payment is not completed within 10 minutes, THEN THE Platform SHALL expire the booking and release the slot
6. WHEN a payment is recorded, THE Platform SHALL store the payment amount, razorpay_payment_id, and status in the payments table

### Requirement 6: Booking History and Management

**User Story:** As a user, I want to view my booking history and manage my reservations, so that I can track past and upcoming events.

#### Acceptance Criteria

1. WHEN a user navigates to booking history, THE Platform SHALL display a list of all bookings sorted by date (newest first) with hall name, date, time, status, and price
2. WHEN a user selects a booking, THE Platform SHALL display full booking details including hall information, slot details, payment status, and booking status
3. WHEN a user cancels a booking at least 24 hours before the slot start time, THE Platform SHALL update the booking status to "cancelled" and release the slot back to "available"
4. IF a user attempts to cancel a booking less than 24 hours before the slot start time, THEN THE Platform SHALL reject the cancellation and display the cancellation policy

### Requirement 7: User Reviews and Ratings

**User Story:** As a user, I want to leave reviews and ratings for halls I have booked, so that I can share my experience with other users.

#### Acceptance Criteria

1. WHEN a user has a completed booking for a hall, THE Platform SHALL allow the user to submit a review with a rating (1-5) and an optional comment
2. THE Platform SHALL enforce that each user can submit only one review per hall
3. WHEN a review is submitted, THE Platform SHALL update the hall average rating based on all reviews for that hall
4. IF a user attempts to review a hall without a completed booking, THEN THE Platform SHALL reject the review submission

### Requirement 8: Push Notifications

**User Story:** As a user, I want to receive push notifications about my bookings, so that I stay informed about confirmations and reminders.

#### Acceptance Criteria

1. WHEN a booking is confirmed, THE Platform SHALL send a push notification to the user via FCM with booking details
2. WHEN a booking slot start time is 1 hour away, THE Platform SHALL send a reminder push notification to the user via FCM
3. WHEN a new booking is created for a hall, THE Platform SHALL send a push notification to the Hall_Owner via FCM with booking details
4. WHEN the app is installed, THE Platform SHALL register the device FCM token and associate it with the authenticated user

### Requirement 9: User Profile Management

**User Story:** As a user, I want to manage my profile information, so that my account details are up to date.

#### Acceptance Criteria

1. WHEN a user navigates to the profile screen, THE Platform SHALL display the user name, phone number, email, and profile picture
2. WHEN a user updates profile fields, THE Platform SHALL validate the input and persist changes to the users table
3. WHEN a user uploads a profile picture, THE Platform SHALL compress the image and store it in Supabase Storage

### Requirement 10: Hall Owner - Hall Listing Management

**User Story:** As a hall owner, I want to add and edit my hall listings, so that users can discover and book my venues.

#### Acceptance Criteria

1. WHEN a Hall_Owner navigates to the add hall screen, THE Platform SHALL display a form for name, description, address, amenities, slot duration (1hr, 2hr, or custom minutes), and base price
2. WHEN a Hall_Owner submits a new hall, THE Platform SHALL create a hall record with approval_status set to "pending" and associate it with the Hall_Owner user id
3. WHEN a Hall_Owner edits an existing hall, THE Platform SHALL update the hall record and retain the current approval_status
4. WHEN a Hall_Owner uploads hall images, THE Platform SHALL compress images, store them in Supabase Storage, and create hall_images records linked to the hall
5. THE Platform SHALL allow a Hall_Owner to upload a maximum of 10 images per hall
6. WHEN a Hall_Owner sets the slot duration, THE Platform SHALL validate that the duration is between 30 minutes and 480 minutes

### Requirement 11: Hall Owner - Availability and Slot Management

**User Story:** As a hall owner, I want to manage my hall availability and block dates, so that I control when my hall is bookable.

#### Acceptance Criteria

1. WHEN a Hall_Owner selects a date range to block, THE Platform SHALL create slot records with status "blocked" for all time slots within that range
2. WHEN a Hall_Owner unblocks a date range, THE Platform SHALL update the slot status from "blocked" to "available" for slots without existing bookings
3. WHEN a Hall_Owner views the availability calendar, THE Platform SHALL display a calendar view showing available, booked, and blocked slots for each date
4. IF a Hall_Owner attempts to block a slot that has an existing confirmed booking, THEN THE Platform SHALL reject the block action and display the conflicting booking details

### Requirement 12: Hall Owner - Bookings and Earnings

**User Story:** As a hall owner, I want to view bookings for my halls and track earnings, so that I can manage my business.

#### Acceptance Criteria

1. WHEN a Hall_Owner navigates to the bookings view, THE Platform SHALL display all bookings for halls owned by that Hall_Owner sorted by date
2. WHEN a Hall_Owner navigates to the earnings report, THE Platform SHALL display total earnings, earnings by hall, and earnings by time period (daily, weekly, monthly)
3. THE Platform SHALL calculate Hall_Owner earnings as total booking revenue minus the platform commission percentage
4. WHEN displaying earnings, THE Platform SHALL show both gross revenue and net earnings after commission deduction

### Requirement 13: Admin - Hall Approval and Management

**User Story:** As an admin, I want to approve or reject hall listings, so that only quality venues are available on the platform.

#### Acceptance Criteria

1. WHEN an Admin navigates to the hall approval queue, THE Platform SHALL display all halls with approval_status "pending" sorted by submission date
2. WHEN an Admin approves a hall, THE Platform SHALL update the hall approval_status to "approved" and make the hall visible in search results
3. WHEN an Admin rejects a hall, THE Platform SHALL update the hall approval_status to "rejected" and notify the Hall_Owner with the rejection reason
4. THE Platform SHALL restrict hall visibility in user search results to only halls with approval_status "approved"

### Requirement 14: Admin - User Management

**User Story:** As an admin, I want to manage platform users, so that I can handle account issues and enforce policies.

#### Acceptance Criteria

1. WHEN an Admin navigates to user management, THE Platform SHALL display a paginated list of all users with name, role, email, phone, and registration date
2. WHEN an Admin changes a user role, THE Platform SHALL update the user role in the users table and enforce the new RBAC permissions immediately
3. WHEN an Admin deactivates a user account, THE Platform SHALL prevent the user from logging in and mark existing active bookings as cancelled

### Requirement 15: Admin - Analytics and Commission

**User Story:** As an admin, I want to view platform analytics and manage commission rates, so that I can monitor and optimize platform performance.

#### Acceptance Criteria

1. WHEN an Admin navigates to the analytics dashboard, THE Platform SHALL display total bookings, total revenue, active users, and active halls for configurable time periods
2. WHEN an Admin sets or updates the commission percentage, THE Platform SHALL apply the new rate to all future bookings
3. THE Platform SHALL store the commission percentage as a platform configuration value accessible only by Admin users

### Requirement 16: Role-Based Access Control and Security

**User Story:** As a platform operator, I want strict role-based access control, so that each user type can only access authorized resources.

#### Acceptance Criteria

1. THE Platform SHALL enforce Row-Level Security policies in Supabase so that User records can only read their own bookings and profile
2. THE Platform SHALL enforce RLS policies so that Hall_Owner records can only modify halls and slots belonging to their own listings
3. THE Platform SHALL enforce RLS policies so that Admin records have full read and write access to all tables
4. WHEN an unauthenticated request is made to a protected endpoint, THE Platform SHALL return a 401 Unauthorized response
5. WHEN an authenticated user attempts to access a resource outside their role permissions, THE Platform SHALL return a 403 Forbidden response
6. THE Platform SHALL validate all JWT tokens on every API request before processing

### Requirement 17: Data Model and Database Integrity

**User Story:** As a developer, I want a well-structured database with referential integrity, so that data remains consistent and reliable.

#### Acceptance Criteria

1. THE Platform SHALL enforce foreign key constraints between bookings and users, bookings and halls, bookings and slots, hall_images and halls, payments and bookings, and reviews and users/halls
2. THE Platform SHALL enforce a unique constraint on (hall_id, date, start_time) in the slots table to prevent duplicate slot entries
3. THE Platform SHALL use PostGIS geography type for hall lat/lng columns and maintain a spatial index for efficient geo queries
4. THE Platform SHALL store hall amenities as a JSONB column in the halls table
5. WHEN a hall is deleted, THE Platform SHALL cascade-delete associated hall_images records and prevent deletion if active bookings exist

### Requirement 18: Performance and Scalability

**User Story:** As a platform operator, I want the application to perform well and scale, so that the user experience remains smooth as the platform grows.

#### Acceptance Criteria

1. THE Platform SHALL implement lazy loading for images and paginated lists across all screens
2. THE Platform SHALL compress images to a maximum of 500KB before uploading to Supabase Storage
3. THE Platform SHALL implement client-side caching for hall listings and user profile data with a cache TTL of 5 minutes
4. WHEN the platform scales beyond 10,000 users, THE Platform SHALL support Redis caching for frequently accessed queries
5. THE Platform SHALL use database connection pooling via Supabase to handle concurrent requests efficiently

### Requirement 19: UI/UX Standards

**User Story:** As a user, I want a modern, responsive, and intuitive interface, so that I can use the platform comfortably on any device.

#### Acceptance Criteria

1. THE Platform SHALL implement a responsive layout that adapts to mobile (Android, iOS) and web screen sizes
2. THE Platform SHALL display appropriate loading indicators during asynchronous operations
3. THE Platform SHALL display empty state illustrations when lists contain no items
4. THE Platform SHALL display user-friendly error messages with retry options when operations fail
5. THE Platform SHALL implement smooth page transitions and animations using Flutter built-in animation framework
6. THE Platform SHALL use a consistent card-based layout for hall listings with uniform spacing and typography

### Requirement 20: Application Architecture

**User Story:** As a developer, I want a clean, maintainable architecture, so that the codebase is easy to extend and test.

#### Acceptance Criteria

1. THE Platform SHALL follow clean architecture with separation into core, features, data, domain, presentation, and services layers
2. THE Platform SHALL use Riverpod for state management across all features
3. THE Platform SHALL use GoRouter for declarative routing with role-based route guards
4. THE Platform SHALL use Dio for all HTTP API calls with interceptors for authentication and error handling
5. THE Platform SHALL use Freezed for immutable data model generation with JSON serialization
6. THE Platform SHALL implement a centralized error handling mechanism that catches, logs, and presents errors consistently
