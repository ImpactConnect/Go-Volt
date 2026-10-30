-- =============================================================================
-- Go-Volts Migration 003: Rider Fleet, KYC Documents, Earnings, & Battery Swaps
-- Compatible with Supabase PostgreSQL 15+ & Technical Specification §5.6
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. RIDER PROFILES & VEHICLES
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.rider_profiles (
    user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    onboarding_status TEXT NOT NULL DEFAULT 'PENDING' CHECK (onboarding_status IN (
        'PENDING', 'DOCUMENTS_SUBMITTED', 'TRAINING_PASSED', 'APPROVED', 'REJECTED'
    )),
    approval_status TEXT NOT NULL DEFAULT 'PENDING' CHECK (approval_status IN (
        'PENDING', 'APPROVED', 'SUSPENDED', 'REJECTED'
    )),
    availability_status TEXT NOT NULL DEFAULT 'OFFLINE' CHECK (availability_status IN (
        'OFFLINE', 'ONLINE', 'ON_TRIP', 'ON_BREAK'
    )),
    service_capabilities TEXT[] NOT NULL DEFAULT '{"RIDE_INSTANT", "DELIVERY_INSTANT"}',
    current_vehicle_id UUID,
    rating_average NUMERIC(3, 2) NOT NULL DEFAULT 5.00,
    completed_jobs_count INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.rider_vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rider_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    vehicle_type TEXT NOT NULL CHECK (vehicle_type IN ('ELECTRIC_SCOOTER', 'ELECTRIC_BIKE', 'CARGO_EV')),
    registration_number TEXT NOT NULL UNIQUE,
    make TEXT NOT NULL,
    model TEXT NOT NULL,
    colour TEXT NOT NULL,
    capacity_kg NUMERIC(6, 2) NOT NULL DEFAULT 25.00,
    status TEXT NOT NULL DEFAULT 'PENDING_VERIFICATION' CHECK (status IN (
        'PENDING_VERIFICATION', 'ACTIVE', 'INACTIVE', 'MAINTENANCE'
    )),
    verified_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.rider_presence (
    rider_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    is_online BOOLEAN NOT NULL DEFAULT FALSE,
    latitude NUMERIC(10, 7),
    longitude NUMERIC(10, 7),
    service_area_id UUID REFERENCES public.service_areas(id) ON DELETE SET NULL,
    last_heartbeat_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    active_booking_id UUID REFERENCES public.bookings(id) ON DELETE SET NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 2. RIDER KYC DOCUMENTS & COMPLIANCE
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.rider_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rider_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    document_type TEXT NOT NULL CHECK (document_type IN (
        'DRIVERS_LICENSE', 'LASRRA_CARD', 'POLICE_REPORT', 'GUARANTOR_FORM', 'VEHICLE_REGISTRATION'
    )),
    storage_path TEXT NOT NULL, -- Private Supabase Storage object key
    file_name TEXT NOT NULL,
    file_size_bytes BIGINT,
    mime_type TEXT DEFAULT 'application/pdf',
    status TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN (
        'PENDING', 'UNDER_REVIEW', 'APPROVED', 'REJECTED', 'EXPIRED'
    )),
    rejection_reason TEXT,
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    reviewed_by UUID REFERENCES public.profiles(id),
    reviewed_at TIMESTAMPTZ,
    expires_at DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 3. RIDER EARNINGS & SETTLEMENT ENTRIES
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.rider_earnings_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rider_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    booking_id UUID REFERENCES public.bookings(id) ON DELETE SET NULL,
    gross_amount NUMERIC(12, 2) NOT NULL,
    platform_commission NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    net_earnings NUMERIC(12, 2) NOT NULL,
    entry_type TEXT NOT NULL CHECK (entry_type IN (
        'TRIP_FARE', 'TIP', 'SURGE_BONUS', 'WEEKLY_PAYOUT', 'INSTANT_PAYOUT', 'ADJUSTMENT'
    )),
    reference TEXT NOT NULL UNIQUE,
    settlement_status TEXT NOT NULL DEFAULT 'SETTLED' CHECK (settlement_status IN (
        'PENDING', 'SETTLED', 'FAILED', 'DISPUTED'
    )),
    metadata JSONB DEFAULT '{}'::JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 4. BATTERY SWAP STATIONS & RESERVATIONS
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.battery_swap_stations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    latitude NUMERIC(10, 7) NOT NULL,
    longitude NUMERIC(10, 7) NOT NULL,
    total_slots INT NOT NULL DEFAULT 12,
    available_batteries INT NOT NULL DEFAULT 8,
    operating_status TEXT NOT NULL DEFAULT 'ONLINE' CHECK (operating_status IN ('ONLINE', 'BUSY', 'MAINTENANCE', 'OFFLINE')),
    operating_hours TEXT NOT NULL DEFAULT '6:00 AM - 10:00 PM',
    distance_km NUMERIC(5, 2),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.battery_slot_reservations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    station_id UUID NOT NULL REFERENCES public.battery_swap_stations(id) ON DELETE CASCADE,
    rider_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    slot_number INT,
    status TEXT NOT NULL DEFAULT 'RESERVED' CHECK (status IN ('RESERVED', 'COMPLETED', 'EXPIRED', 'CANCELLED')),
    reserved_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 5. ROW LEVEL SECURITY (RLS) POLICIES
-- -----------------------------------------------------------------------------

ALTER TABLE public.rider_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rider_vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rider_presence ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rider_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rider_earnings_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.battery_swap_stations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.battery_slot_reservations ENABLE ROW LEVEL SECURITY;

-- Rider profiles: riders can view/update own profile
CREATE POLICY "Riders manage own profile"
    ON public.rider_profiles FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Rider vehicles: riders manage own vehicles
CREATE POLICY "Riders manage own vehicles"
    ON public.rider_vehicles FOR ALL
    USING (auth.uid() = rider_id)
    WITH CHECK (auth.uid() = rider_id);

-- Rider presence: riders manage own presence
CREATE POLICY "Riders manage own presence"
    ON public.rider_presence FOR ALL
    USING (auth.uid() = rider_id)
    WITH CHECK (auth.uid() = rider_id);

-- Rider documents: only the owner rider and admins can view/submit
CREATE POLICY "Riders can view and submit own documents"
    ON public.rider_documents FOR ALL
    USING (auth.uid() = rider_id)
    WITH CHECK (auth.uid() = rider_id);

-- Rider earnings: riders can only view their own earnings
CREATE POLICY "Riders view own earnings entries"
    ON public.rider_earnings_entries FOR SELECT
    USING (auth.uid() = rider_id);

-- Battery swap stations are public to all authenticated riders
CREATE POLICY "Authenticated users view swap stations"
    ON public.battery_swap_stations FOR SELECT
    USING (auth.role() = 'authenticated');

-- Battery reservations managed by the reserving rider
CREATE POLICY "Riders manage own battery reservations"
    ON public.battery_slot_reservations FOR ALL
    USING (auth.uid() = rider_id)
    WITH CHECK (auth.uid() = rider_id);

-- Seed initial Lagos EV swap stations
INSERT INTO public.battery_swap_stations (name, address, latitude, longitude, total_slots, available_batteries, operating_status)
VALUES
    ('Marina Hub Station', 'Marina Bus Terminal, Lagos Island', 6.4531, 3.3958, 16, 12, 'ONLINE'),
    ('Yaba Tech Hub Station', 'Commercial Avenue, Yaba', 6.5182, 3.3768, 12, 7, 'ONLINE'),
    ('Ikeja City Mall Hub', 'Alausa, Ikeja', 6.6133, 3.3582, 20, 15, 'ONLINE'),
    ('Lekki Phase 1 Hub', 'Admiralty Way, Lekki', 6.4474, 3.4723, 14, 9, 'ONLINE')
ON CONFLICT DO NOTHING;
