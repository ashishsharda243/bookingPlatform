-- ============================================================
-- Hall Booking Platform - Database Functions Migration
-- ============================================================
-- Creates atomic booking function with row-level locking
-- and geo-spatial nearby halls query function using PostGIS.
-- ============================================================

-- -----------------------------------------------------------
-- create_booking: Atomic slot reservation with FOR UPDATE lock
-- Prevents double bookings via pessimistic locking.
-- Requirements: 4.3, 4.4, 4.5
-- -----------------------------------------------------------
CREATE OR REPLACE FUNCTION create_booking(
    p_user_id UUID,
    p_hall_id UUID,
    p_slot_id UUID,
    p_total_price DECIMAL
) RETURNS UUID AS $$
DECLARE
    v_booking_id UUID;
    v_slot_status TEXT;
BEGIN
    -- Lock the slot row to prevent concurrent modifications
    SELECT status INTO v_slot_status
    FROM slots
    WHERE id = p_slot_id AND hall_id = p_hall_id
    FOR UPDATE;

    IF v_slot_status IS NULL THEN
        RAISE EXCEPTION 'Slot not found';
    END IF;

    IF v_slot_status != 'available' THEN
        RAISE EXCEPTION 'Slot is no longer available (current status: %)', v_slot_status;
    END IF;

    -- Update slot status to booked
    UPDATE slots SET status = 'booked' WHERE id = p_slot_id;

    -- Create booking record with pending status
    INSERT INTO bookings (user_id, hall_id, slot_id, total_price, payment_status, booking_status)
    VALUES (p_user_id, p_hall_id, p_slot_id, p_total_price, 'pending', 'pending')
    RETURNING id INTO v_booking_id;

    RETURN v_booking_id;
END;
$$ LANGUAGE plpgsql;


-- -----------------------------------------------------------
-- get_nearby_halls: PostGIS-based proximity search
-- Returns approved halls within a radius, sorted by distance,
-- with pagination support.
-- Requirements: 2.2, 2.3
-- -----------------------------------------------------------
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
      AND ST_DWithin(h.location, ST_MakePoint(p_lng, p_lat)::geography, p_radius_km * 1000)
    ORDER BY distance_km ASC
    LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;
