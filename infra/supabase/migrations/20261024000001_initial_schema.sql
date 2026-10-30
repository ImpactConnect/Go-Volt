-- =============================================================================
-- Go-Volts Initial Database Schema Migration
-- Compatible with Supabase PostgreSQL 15+
-- =============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- -----------------------------------------------------------------------------
-- 1. PROFILES & ROLES
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    phone_number TEXT NOT NULL UNIQUE,
    email TEXT,
    avatar_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('customer', 'rider', 'merchant', 'admin', 'super_admin', 'support_agent')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, role)
);

CREATE TABLE IF NOT EXISTS public.user_devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    fcm_token TEXT NOT NULL,
    platform TEXT NOT NULL CHECK (platform IN ('android', 'ios', 'web')),
    device_model TEXT,
    last_active_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, fcm_token)
);

-- -----------------------------------------------------------------------------
-- 2. SERVICE CONFIGURATION & GEOGRAPHY
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.service_types (
    code TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('RIDE', 'DELIVERY')),
    is_scheduled BOOLEAN NOT NULL DEFAULT FALSE,
    base_fare NUMERIC(12, 2) NOT NULL,
    per_km_rate NUMERIC(12, 2) NOT NULL,
    per_minute_rate NUMERIC(12, 2) NOT NULL,
    platform_fee NUMERIC(12, 2) NOT NULL DEFAULT 50.00,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS public.service_areas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    city TEXT NOT NULL DEFAULT 'Lagos',
    state TEXT NOT NULL DEFAULT 'Lagos',
    country_code TEXT NOT NULL DEFAULT 'NG',
    boundary_polygon JSONB, -- GeoJSON polygon
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.package_categories (
    code TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    max_weight_kg NUMERIC(6, 2) NOT NULL DEFAULT 20.00,
    requires_fragile_handling BOOLEAN NOT NULL DEFAULT FALSE
);

-- -----------------------------------------------------------------------------
-- 3. QUOTES & BOOKINGS
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.quotes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    service_code TEXT NOT NULL REFERENCES public.service_types(code),
    pickup_address TEXT NOT NULL,
    pickup_lat NUMERIC(10, 7) NOT NULL,
    pickup_lng NUMERIC(10, 7) NOT NULL,
    dropoff_address TEXT NOT NULL,
    dropoff_lat NUMERIC(10, 7) NOT NULL,
    dropoff_lng NUMERIC(10, 7) NOT NULL,
    distance_km NUMERIC(8, 2) NOT NULL,
    duration_minutes INT NOT NULL,
    base_fare NUMERIC(12, 2) NOT NULL,
    distance_fare NUMERIC(12, 2) NOT NULL,
    time_fare NUMERIC(12, 2) NOT NULL,
    platform_fee NUMERIC(12, 2) NOT NULL,
    total_fare NUMERIC(12, 2) NOT NULL,
    currency TEXT NOT NULL DEFAULT 'NGN',
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_reference TEXT NOT NULL UNIQUE,
    user_id UUID NOT NULL REFERENCES public.profiles(id),
    rider_id UUID REFERENCES public.profiles(id),
    service_code TEXT NOT NULL REFERENCES public.service_types(code),
    status TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN (
        'DRAFT', 'PENDING', 'SEARCHING_RIDER', 'ASSIGNED', 'ARRIVED_AT_PICKUP',
        'IN_PROGRESS', 'ARRIVED_AT_DROPOFF', 'COMPLETED', 'CANCELLED', 'FAILED'
    )),
    pickup_address TEXT NOT NULL,
    pickup_lat NUMERIC(10, 7) NOT NULL,
    pickup_lng NUMERIC(10, 7) NOT NULL,
    dropoff_address TEXT NOT NULL,
    dropoff_lat NUMERIC(10, 7) NOT NULL,
    dropoff_lng NUMERIC(10, 7) NOT NULL,
    scheduled_time TIMESTAMPTZ,
    package_category_code TEXT REFERENCES public.package_categories(code),
    package_weight_kg NUMERIC(6, 2),
    recipient_name TEXT,
    recipient_phone TEXT,
    instructions TEXT,
    cancellation_reason TEXT,
    total_amount NUMERIC(12, 2) NOT NULL,
    payment_method TEXT NOT NULL DEFAULT 'WALLET',
    payment_status TEXT NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.booking_status_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    previous_status TEXT,
    new_status TEXT NOT NULL,
    actor_id UUID REFERENCES public.profiles(id),
    actor_role TEXT,
    metadata JSONB DEFAULT '{}'::JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 4. WALLETS & TRANSACTIONS
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.wallets (
    user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    balance NUMERIC(14, 2) NOT NULL DEFAULT 0.00 CHECK (balance >= 0),
    locked_balance NUMERIC(14, 2) NOT NULL DEFAULT 0.00 CHECK (locked_balance >= 0),
    currency TEXT NOT NULL DEFAULT 'NGN',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.wallet_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_user_id UUID NOT NULL REFERENCES public.wallets(user_id),
    amount NUMERIC(14, 2) NOT NULL CHECK (amount > 0),
    type TEXT NOT NULL CHECK (type IN ('CREDIT', 'DEBIT', 'LOCK', 'RELEASE', 'REFUND')),
    reference TEXT NOT NULL UNIQUE,
    description TEXT NOT NULL,
    booking_id UUID REFERENCES public.bookings(id),
    status TEXT NOT NULL DEFAULT 'COMPLETED',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 5. OUTBOX PATTERN (Guaranteed event delivery)
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.outbox_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type TEXT NOT NULL,
    aggregate_type TEXT NOT NULL,
    aggregate_id TEXT NOT NULL,
    payload JSONB NOT NULL,
    status TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'PROCESSED', 'FAILED')),
    retry_count INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    processed_at TIMESTAMPTZ
);

-- -----------------------------------------------------------------------------
-- 6. ROW LEVEL SECURITY (RLS) POLICIES
-- -----------------------------------------------------------------------------

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.booking_status_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallet_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.outbox_events ENABLE ROW LEVEL SECURITY;

-- Profiles: users read and update their own profile
CREATE POLICY "Users can view own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

-- Bookings: Customers see their own bookings; assigned riders see their assigned bookings
CREATE POLICY "Customers view own bookings"
    ON public.bookings FOR SELECT
    USING (auth.uid() = user_id OR auth.uid() = rider_id);

CREATE POLICY "Customers create own bookings"
    ON public.bookings FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Wallets: Users view only their own wallet and transactions
CREATE POLICY "Users view own wallet"
    ON public.wallets FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users view own transactions"
    ON public.wallet_transactions FOR SELECT
    USING (auth.uid() = wallet_user_id);

-- Seed initial service types
INSERT INTO public.service_types (code, name, category, is_scheduled, base_fare, per_km_rate, per_minute_rate, platform_fee)
VALUES
    ('RIDE_INSTANT', 'Ride Electric', 'RIDE', FALSE, 400.00, 150.00, 25.00, 50.00),
    ('RIDE_SCHEDULED', 'Scheduled Ride', 'RIDE', TRUE, 600.00, 160.00, 25.00, 50.00),
    ('DELIVERY_INSTANT', 'Send Package', 'DELIVERY', FALSE, 350.00, 120.00, 15.00, 50.00),
    ('PICKUP_SCHEDULED', 'Scheduled Pickup', 'DELIVERY', TRUE, 500.00, 130.00, 15.00, 50.00)
ON CONFLICT (code) DO NOTHING;

-- Seed package categories
INSERT INTO public.package_categories (code, name, max_weight_kg, requires_fragile_handling)
VALUES
    ('DOCUMENTS', 'Documents & Letters', 5.0, FALSE),
    ('ELECTRONICS', 'Electronics & Gadgets', 15.0, TRUE),
    ('CLOTHING', 'Clothing & Apparel', 20.0, FALSE),
    ('FOOD', 'Food & Groceries', 15.0, FALSE),
    ('FRAGILE', 'Fragile Goods', 10.0, TRUE),
    ('GENERAL', 'General Parcel', 25.0, FALSE)
ON CONFLICT (code) DO NOTHING;
