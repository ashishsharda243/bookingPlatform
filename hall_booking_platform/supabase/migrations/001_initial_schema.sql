-- ============================================================
-- Hall Booking Platform - Initial Schema Migration
-- ============================================================
-- Enables PostGIS, creates all tables with constraints,
-- foreign keys, indexes, and seeds default platform config.
-- ============================================================

-- Enable PostGIS extension for geographic queries
CREATE EXTENSION IF NOT EXISTS postgis;

-- -----------------------------------------------------------
-- Users table
-- -----------------------------------------------------------
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'owner', 'admin')),
    name TEXT NOT NULL,
    phone TEXT UNIQUE NOT NULL,
    email TEXT,
    profile_image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    fcm_token TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- -----------------------------------------------------------
-- Halls table with PostGIS geography
-- -----------------------------------------------------------
CREATE TABLE halls (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES users(id),
    name TEXT NOT NULL,
    description TEXT,
    location GEOGRAPHY(POINT, 4326) NOT NULL,
    address TEXT NOT NULL,
    amenities JSONB DEFAULT '[]',
    slot_duration_minutes INTEGER NOT NULL CHECK (slot_duration_minutes BETWEEN 30 AND 480),
    base_price DECIMAL(10,2) NOT NULL CHECK (base_price > 0),
    approval_status TEXT NOT NULL DEFAULT 'pending' CHECK (approval_status IN ('pending', 'approved', 'rejected')),
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Spatial index for geo queries
CREATE INDEX idx_halls_location ON halls USING GIST(location);
-- Index for filtering by approval status
CREATE INDEX idx_halls_approval ON halls(approval_status);

-- -----------------------------------------------------------
-- Hall images
-- -----------------------------------------------------------
CREATE TABLE hall_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hall_id UUID NOT NULL REFERENCES halls(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- -----------------------------------------------------------
-- Slots with unique constraint for double-booking prevention
-- -----------------------------------------------------------
CREATE TABLE slots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hall_id UUID NOT NULL REFERENCES halls(id),
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status TEXT NOT NULL DEFAULT 'available' CHECK (status IN ('available', 'booked', 'blocked')),
    UNIQUE(hall_id, date, start_time)
);

-- Composite index for slot lookups by hall and date
CREATE INDEX idx_slots_hall_date ON slots(hall_id, date);

-- -----------------------------------------------------------
-- Bookings
-- -----------------------------------------------------------
CREATE TABLE bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    hall_id UUID NOT NULL REFERENCES halls(id),
    slot_id UUID NOT NULL REFERENCES slots(id),
    total_price DECIMAL(10,2) NOT NULL,
    payment_status TEXT NOT NULL DEFAULT 'pending' CHECK (payment_status IN ('pending', 'completed', 'failed', 'refunded')),
    booking_status TEXT NOT NULL DEFAULT 'pending' CHECK (booking_status IN ('pending', 'confirmed', 'cancelled', 'completed')),
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_bookings_user ON bookings(user_id);
CREATE INDEX idx_bookings_hall ON bookings(hall_id);

-- -----------------------------------------------------------
-- Payments
-- -----------------------------------------------------------
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES bookings(id),
    razorpay_payment_id TEXT,
    razorpay_order_id TEXT,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
    amount DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- -----------------------------------------------------------
-- Reviews with one-review-per-user-per-hall constraint
-- -----------------------------------------------------------
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    hall_id UUID NOT NULL REFERENCES halls(id),
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(user_id, hall_id)
);

-- -----------------------------------------------------------
-- Platform configuration
-- -----------------------------------------------------------
CREATE TABLE platform_config (
    key TEXT PRIMARY KEY,
    value JSONB NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Seed default commission percentage
INSERT INTO platform_config (key, value) VALUES ('commission_percentage', '10');
