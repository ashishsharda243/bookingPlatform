-- ============================================================
-- Hall Booking Platform - Row-Level Security Policies
-- ============================================================
-- Enables RLS on all tables and creates policies enforcing:
--   - Users: own data + admin full access
--   - Halls: approved public read + owner own + admin full
--   - Hall images: public read + owner manage own + admin full
--   - Bookings: own + owner's hall bookings + admin full
--   - Slots: public read + owner/admin write
--   - Reviews: public read + own insert
--   - Payments: own + admin
--   - Platform config: admin only
-- Requirements: 16.1, 16.2, 16.3
-- ============================================================

-- -----------------------------------------------------------
-- Users: read own profile, admin reads/updates all
-- -----------------------------------------------------------
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY users_select ON users FOR SELECT USING (
    auth.uid() = id OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);

CREATE POLICY users_update ON users FOR UPDATE USING (
    auth.uid() = id OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);

-- -----------------------------------------------------------
-- Halls: public read approved, owner modifies own, admin all
-- -----------------------------------------------------------
ALTER TABLE halls ENABLE ROW LEVEL SECURITY;

CREATE POLICY halls_select ON halls FOR SELECT USING (
    approval_status = 'approved' OR
    owner_id = auth.uid() OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);

CREATE POLICY halls_insert ON halls FOR INSERT WITH CHECK (
    owner_id = auth.uid() AND
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('owner', 'admin'))
);

CREATE POLICY halls_update ON halls FOR UPDATE USING (
    owner_id = auth.uid() OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);

-- -----------------------------------------------------------
-- Hall images: public read, owner insert/delete own, admin all
-- -----------------------------------------------------------
ALTER TABLE hall_images ENABLE ROW LEVEL SECURITY;

CREATE POLICY hall_images_select ON hall_images FOR SELECT USING (true);

CREATE POLICY hall_images_insert ON hall_images FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM halls WHERE halls.id = hall_images.hall_id AND halls.owner_id = auth.uid()) OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);

CREATE POLICY hall_images_delete ON hall_images FOR DELETE USING (
    EXISTS (SELECT 1 FROM halls WHERE halls.id = hall_images.hall_id AND halls.owner_id = auth.uid()) OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);

-- -----------------------------------------------------------
-- Slots: public read, owner manages own hall slots, admin all
-- -----------------------------------------------------------
ALTER TABLE slots ENABLE ROW LEVEL SECURITY;

CREATE POLICY slots_select ON slots FOR SELECT USING (true);

CREATE POLICY slots_insert ON slots FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM halls WHERE halls.id = slots.hall_id AND halls.owner_id = auth.uid()) OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);

CREATE POLICY slots_update ON slots FOR UPDATE USING (
    EXISTS (SELECT 1 FROM halls WHERE halls.id = slots.hall_id AND halls.owner_id = auth.uid()) OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);

-- -----------------------------------------------------------
-- Bookings: user reads own, owner reads hall bookings, admin all
-- -----------------------------------------------------------
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;

CREATE POLICY bookings_select ON bookings FOR SELECT USING (
    user_id = auth.uid() OR
    EXISTS (SELECT 1 FROM halls WHERE halls.id = bookings.hall_id AND halls.owner_id = auth.uid()) OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);

CREATE POLICY bookings_insert ON bookings FOR INSERT WITH CHECK (
    user_id = auth.uid()
);

-- -----------------------------------------------------------
-- Reviews: public read, user inserts own
-- -----------------------------------------------------------
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY reviews_select ON reviews FOR SELECT USING (true);

CREATE POLICY reviews_insert ON reviews FOR INSERT WITH CHECK (user_id = auth.uid());

-- -----------------------------------------------------------
-- Payments: user reads own (via booking), admin reads all
-- -----------------------------------------------------------
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY payments_select ON payments FOR SELECT USING (
    EXISTS (SELECT 1 FROM bookings WHERE bookings.id = payments.booking_id AND bookings.user_id = auth.uid()) OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);

-- -----------------------------------------------------------
-- Platform config: admin only
-- -----------------------------------------------------------
ALTER TABLE platform_config ENABLE ROW LEVEL SECURITY;

CREATE POLICY config_select ON platform_config FOR SELECT USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);

CREATE POLICY config_update ON platform_config FOR UPDATE USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);
