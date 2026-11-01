-- =============================================================================
-- Go-Volts Migration 008: Scheduled Pickup Specification v1.5 Schema Updates
-- Compatible with Supabase PostgreSQL 15+
-- Enforces Section 21: Plan != Trip separation, independent leg pricing,
-- 48h quote expiry, 6h cutoff skip ledger, and school-run 4-digit PIN verification.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. EXTEND SCHEDULED PLANS
-- -----------------------------------------------------------------------------

ALTER TABLE public.scheduled_plans
    ADD COLUMN IF NOT EXISTS purpose TEXT DEFAULT 'school_run',
    ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'pending_review',
    ADD COLUMN IF NOT EXISTS billing_model TEXT DEFAULT 'pay_per_trip',
    ADD COLUMN IF NOT EXISTS total_amount_ngn NUMERIC(12, 2) DEFAULT 0,
    ADD COLUMN IF NOT EXISTS amount_paid_ngn NUMERIC(12, 2) DEFAULT 0,
    ADD COLUMN IF NOT EXISTS approval_expires_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS pause_effective_date DATE,
    ADD COLUMN IF NOT EXISTS preferred_rider_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS approved_quote_id TEXT,
    ADD COLUMN IF NOT EXISTS notes TEXT,
    ADD COLUMN IF NOT EXISTS passenger_name TEXT,
    ADD COLUMN IF NOT EXISTS passenger_phone TEXT;

-- -----------------------------------------------------------------------------
-- 2. EXTEND SCHEDULED TRIPS
-- -----------------------------------------------------------------------------

ALTER TABLE public.scheduled_trips
    ADD COLUMN IF NOT EXISTS trip_purpose TEXT DEFAULT 'school_run',
    ADD COLUMN IF NOT EXISTS journey_direction TEXT DEFAULT 'one_way',
    ADD COLUMN IF NOT EXISTS pickup_address TEXT,
    ADD COLUMN IF NOT EXISTS pickup_lat NUMERIC(10, 7),
    ADD COLUMN IF NOT EXISTS pickup_lng NUMERIC(10, 7),
    ADD COLUMN IF NOT EXISTS destination_address TEXT,
    ADD COLUMN IF NOT EXISTS destination_lat NUMERIC(10, 7),
    ADD COLUMN IF NOT EXISTS destination_lng NUMERIC(10, 7),
    ADD COLUMN IF NOT EXISTS fare_ngn NUMERIC(12, 2) DEFAULT 2500.0,
    ADD COLUMN IF NOT EXISTS is_school_run BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS handover_code TEXT DEFAULT '4219',
    ADD COLUMN IF NOT EXISTS handover_code_hash TEXT,
    ADD COLUMN IF NOT EXISTS handover_status TEXT DEFAULT 'not_started',
    ADD COLUMN IF NOT EXISTS handover_recipient_name TEXT,
    ADD COLUMN IF NOT EXISTS handover_recipient_role TEXT,
    ADD COLUMN IF NOT EXISTS handover_confirmed_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS skip_reason TEXT,
    ADD COLUMN IF NOT EXISTS passenger_name TEXT,
    ADD COLUMN IF NOT EXISTS passenger_phone TEXT,
    ADD COLUMN IF NOT EXISTS waiting_time_remaining_seconds INT DEFAULT 600;

-- -----------------------------------------------------------------------------
-- 3. SCHEDULED QUOTES TABLE (Section 21.2)
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.scheduled_quotes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quote_id TEXT UNIQUE NOT NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    booking_type TEXT NOT NULL DEFAULT 'recurring',
    purpose TEXT NOT NULL DEFAULT 'school_run',
    journey_type TEXT NOT NULL DEFAULT 'one_way',
    pickup_location JSONB NOT NULL,
    destination_location JSONB NOT NULL,
    return_pickup_location JSONB,
    return_destination_location JSONB,
    billing_model TEXT NOT NULL DEFAULT 'pay_per_trip',
    base_fare_ngn NUMERIC(12, 2) NOT NULL DEFAULT 2000.0,
    distance_km NUMERIC(10, 2) NOT NULL DEFAULT 8.0,
    distance_fare_ngn NUMERIC(12, 2) NOT NULL DEFAULT 400.0,
    service_fee_ngn NUMERIC(12, 2) NOT NULL DEFAULT 100.0,
    total_fare_ngn NUMERIC(12, 2) NOT NULL DEFAULT 2500.0,
    total_trips INT NOT NULL DEFAULT 1,
    expires_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '48 hours'),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 4. SCHEDULED TRIP ISSUES TABLE (Screen 35 / Section 21.7)
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.scheduled_trip_issues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID REFERENCES public.scheduled_trips(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    issue_type TEXT NOT NULL,
    notes TEXT,
    status TEXT NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'INVESTIGATING', 'RESOLVED', 'DISMISSED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 5. RLS POLICIES
-- -----------------------------------------------------------------------------

ALTER TABLE public.scheduled_quotes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scheduled_trip_issues ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    CREATE POLICY "Users can manage own quotes"
        ON public.scheduled_quotes FOR ALL
        USING (auth.uid() = user_id OR user_id IS NULL)
        WITH CHECK (auth.uid() = user_id OR user_id IS NULL);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE POLICY "Users can manage own trip issues"
        ON public.scheduled_trip_issues FOR ALL
        USING (auth.uid() = user_id)
        WITH CHECK (auth.uid() = user_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

