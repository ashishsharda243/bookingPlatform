# Codebase Summary & Change Log

## Project Architecture
The project is a **Flutter** application following a **Feature-First** architecture with **Riverpod** for state management and **Supabase** for the backend.

### Key Technologies
- **Framework:** Flutter (Dart 3.6.0)
- **State Management:** `flutter_riverpod` with `riverpod_annotation` & `riverpod_generator`.
- **Backend & Auth:** `supabase_flutter`.
- **Navigation:** `go_router`.
- **Networking:** `dio` (though Supabase client handles most data).
- **Maps:** `flutter_map` (with `latlong2`).
- **Code Generation:** `freezed`, `json_serializable`, `build_runner`.

## Directory Structure
The `lib/` directory is organized as follows:

```
lib/
├── core/               # Shared utilities, widgets, theme, errors
├── features/           # Feature-specific code (Vertical Slices)
│   ├── admin/          # Admin panel features
│   ├── auth/           # Authentication (Login, Sign-up)
│   ├── booking/        # Booking logic (booking.dart entity)
│   ├── discovery/      # Hall discovery (hall.dart entity)
│   ├── owner/          # Hall owner features
│   ├── payment/        # Payment integration (Razorpay)
│   ├── profile/        # User profile management
│   └── reviews/        # Ratings and reviews
├── routing/            # AppRouter configuration
├── services/           # External services (Supabase, Location, FCM)
└── main.dart           # Entry point (Initializes Supabase, Riverpod Scope)
```

## Key Entities & Data Models

### Hall (`lib/features/discovery/domain/entities/hall.dart`)
Represents a bookable hall.
- **Fields:** `id`, `ownerId`, `name`, `description`, `lat`, `lng`, `address`, `amenities`, `slotDurationMinutes`, `basePrice`, `approvalStatus`.
- **Usage:** Used in discovery/search features and owner management.

### Booking (`lib/features/booking/domain/entities/booking.dart`)
Represents a user's booking.
- **Fields:** `id`, `userId`, `hallId`, `slotId`, `totalPrice`, `paymentStatus`, `bookingStatus`.
- **Relationships:** Contains optional `Hall` and `Slot` objects.

## Infrastructure
- **SupabaseService:** (`lib/services/supabase_service.dart`)
  - Initializes Supabase with `SUPABASE_URL` and `SUPABASE_ANON_KEY` from environment variables (`.env`).
  - Exposes `client` and `auth` getters.
  - Provides Riverpod providers: `supabaseClientProvider` and `supabaseAuthProvider`.

## Observations
- The code uses code generation heavily (`freezed`, `riverpod_generator`) for type safety and boilerplate reduction.
- Error handling is centralized in `core/errors`.
- The app supports role-based features (User, Owner, Admin).

---

## Change Log

### [Initial Analysis]
- Analyzed codebase structure and dependencies.
- Documented key entities (`Hall`, `Booking`) and services (`SupabaseService`).
- Created `summary.md` to track future changes.

### [Execution]
- Attempted to run on macOS; failed due to missing desktop support.
- Successfully ran the app on **Chrome** (`flutter run -d chrome`). App launched and navigated to `/home`.

### New Features Implementation Details
- **2026-02-19:**
    - Analyzed codebase for `hall_booking_platform`.
    - Identified missing macOS support configuration.
    - Successfully ran the app on Chrome.
- **2026-02-20:**
    - **Feature: Google Map Link**: Added `googleMapLink` to `Hall` entity and `AddEditHallScreen`. Updated `HallDetailScreen` to display the link.
    - **Feature: Home Screen Photo**: Updated `HallCard` to use a `_DefaultCover` fallback widget when images are missing or fail to load.
    - **Feature: Range Filter**: Added `minPrice`, `maxPrice`, `maxDistance` filters to `DiscoveryRepository` and `DiscoveryRemoteDataSource`. Added `FilterStateProvider` and `_FilterBottomSheet` in `HomeScreen`.
    - **Feature: Manual Location Selection**:
        - Updated `UserLocationNotifier` to support manual location override.
        - Created `LocationPickerScreen` using `flutter_map` for selecting location on a map.
        - Updated `LocationPickerScreen` to fetch current location using `LocationService`.
        - Updated `HomeScreen` to display current location status and allow switching between GPS and manual location.
        - Fixed `HomeScreen` location visibility and reset logic.
    - **Fixes**:
        - Added `@JsonKey(name: 'google_map_link')` to `Hall` and `HallCreateRequest` to fix data persistence issues.
        - Verified app compilation and execution on Chrome.
    - **Fix: Booking & Slots**:
        - Fixed `FirebaseException` during booking by making FcmService robust on web.
        - Fixed Slot Visibility issue (auto-create slots for new halls).
        - Fixed `TypeError` in booking by handling null values in Hall/Booking entities.
    - **Feature: Skip Payment**:
        - Implemented direct booking confirmation, bypassing Razorpay for testing/offline payments.
    - **Fix: Edge Function URL**:
        - Updated `PaymentRemoteDataSource` to call `dynamic-task` instead of `create-order` to match user's deployment.
    - **Configuration Change**:
        - Disabled JWT Verification on `dynamic-task` for testing. **MUST RE-ENABLE BEFORE PRODUCTION.**
- **2026-02-21:**
    - **Feature: Hall Soft Deletion**:
        - Created SQL Migration `007_soft_delete_halls.sql` adding `is_active BOOLEAN DEFAULT true` to `halls`.
        - Updated `get_nearby_halls` Postgres RPC to mandate `is_active = true`.
        - Updated `Hall` entity in `lib/features/discovery/domain/entities/hall.dart` with `isActive`.
        - Implemented `deleteHall` in `OwnerHallRemoteDataSource`, `OwnerHallRepositoryImpl`, and `OwnerDashboardNotifier` to flip `is_active` to false instead of deleting the row (violating foreign keys).
        - Added delete trash icon and confirmation dialog to `_HallCard` in `OwnerDashboardScreen`.
    - **Feature: SPA Web Compilation & Vercel Publishing**:
        - Fixed `pubspec.yaml` SDK constraints from `^3.6.0` to `^3.10.0` and removed invalid `mapbox_gl` path overrides.
        - Built the Flutter web app for production using `flutter build web --release`.
        - Created `/build/web/vercel.json` with a rewrite rule `{"source": "/(.*)", "destination": "/index.html"}` to fix SPA 404 routing errors on Vercel upon browser refresh.
    - **Fix: Direct Booking Edge Function**:
        - Edge function `create-order` deployed to handle direct booking confirmations, skipping Razorpay flow.
        - Resolved missing CORS headers and "Failed to fetch" errors.
    - **Critical Issue: OS-Level Corruption**:
        - Several files (e.g. `scaffold_with_navbar.dart`, `app_constants.dart`, `failure.dart`) and the entire `.git` object repository suffered null-byte/0-byte OS-level corruption (exit code 138 Bus Errors) during high disk I/O. 
        - Tracked and restored all dart source files from Git HEAD where possible to save the workspace state.
        - Git repository index and objects remain unrecoverable by standard CLI tools.

