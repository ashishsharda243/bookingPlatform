-- ============================================================
-- Hall Booking Platform - Soft Delete Halls Migration
-- ============================================================
-- Adds an `is_active` flag to halls to allow safe soft-deletion
-- without breaking foreign keys (bookings, slots).
-- Updates the `get_nearby_halls` function to only return
-- active halls.
-- ============================================================

-- 1. Add `is_active` flag to halls, default to true
ALTER TABLE halls
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

-- 2. Update existing RPC `get_nearby_halls` to filter by `is_active = true`
CREATE OR REPLACE FUNCTION get_nearby_halls(
    p_lat DOUBLE PRECISION,
    p_lng DOUBLE PRECISION,
    p_radius_km DOUBLE PRECISION DEFAULT 2.0,
    p_limit INTEGER DEFAULT 20,
    p_offset INTEGER DEFAULT 0
) RETURNS TABLE (
    id UUID,
    owner_id UUID,
    name TEXT,
    description TEXT,
    lat DOUBLE PRECISION,
    lng DOUBLE PRECISION,
    address TEXT,
    amenities JSONB,
    slot_duration_minutes INTEGER,
    base_price DECIMAL,
    approval_status TEXT,
    created_at TIMESTAMPTZ,
    distance_km DOUBLE PRECISION
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        h.id, h.owner_id, h.name, h.description,
        ST_Y(h.location::geometry) AS lat,
        ST_X(h.location::geometry) AS lng,
        h.address, h.amenities, h.slot_duration_minutes,
        h.base_price, h.approval_status, h.created_at,
        ST_Distance(h.location, ST_MakePoint(p_lng, p_lat)::geography) / 1000.0 AS distance_km
    FROM halls h
    WHERE h.approval_status = 'approved'
      AND h.is_active = true
      AND ST_DWithin(h.location, ST_MakePoint(p_lng, p_lat)::geography, p_radius_km * 1000)
    ORDER BY distance_km ASC
    LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;
