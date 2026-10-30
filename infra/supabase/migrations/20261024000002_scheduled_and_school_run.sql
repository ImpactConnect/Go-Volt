-- =============================================================================
-- Go-Volts Migration 002: Scheduled Plans, School-Run, & Entitlement Ledger
-- Compatible with Supabase PostgreSQL 15+
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. SCHEDULED PLANS & SUBSCRIPTIONS
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.scheduled_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    service_code TEXT NOT NULL REFERENCES public.service_types(code),
    plan_name TEXT NOT NULL,
    plan_type TEXT NOT NULL CHECK (plan_type IN ('COMMUTER_PASS', 'SCHOOL_RUN', 'CUSTOM_RECURRING')),
    pickup_address TEXT NOT NULL,
    pickup_lat NUMERIC(10, 7) NOT NULL,
    pickup_lng NUMERIC(10, 7) NOT NULL,
    dropoff_address TEXT NOT NULL,
    dropoff_lat NUMERIC(10, 7) NOT NULL,
    dropoff_lng NUMERIC(10, 7) NOT NULL,
    days_of_week INT[] NOT NULL DEFAULT '{1,2,3,4,5}', -- 1=Mon, 5=Fri
    pickup_time TIME NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    auto_renew BOOLEAN NOT NULL DEFAULT TRUE,
    total_trips_allocated INT NOT NULL DEFAULT 20,
    trips_remaining INT NOT NULL DEFAULT 20 CHECK (trips_remaining >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 2. SCHOOL-RUN PROFILES & AUTHORIZED GUARDIANS
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.school_run_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    student_name TEXT NOT NULL,
    school_name TEXT NOT NULL,
    grade_or_class TEXT,
    school_address TEXT NOT NULL,
    school_lat NUMERIC(10, 7) NOT NULL,
    school_lng NUMERIC(10, 7) NOT NULL,
    pickup_gate TEXT,
    emergency_phone TEXT NOT NULL,
    pickup_authorization_code TEXT NOT NULL, -- Daily rotating or static safe PIN
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.authorized_guardians (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    school_profile_id UUID NOT NULL REFERENCES public.school_run_profiles(id) ON DELETE CASCADE,
    guardian_name TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    relationship TEXT NOT NULL,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 3. SCHEDULED TRIP OCCURRENCES & ENTITLEMENT LEDGER
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.scheduled_trips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plan_id UUID NOT NULL REFERENCES public.scheduled_plans(id) ON DELETE CASCADE,
    scheduled_date DATE NOT NULL,
    scheduled_time TIME NOT NULL,
    status TEXT NOT NULL DEFAULT 'SCHEDULED' CHECK (status IN (
        'SCHEDULED', 'ASSIGNED', 'IN_PROGRESS', 'COMPLETED', 'SKIPPED', 'CANCELLED'
    )),
    booking_id UUID REFERENCES public.bookings(id) ON DELETE SET NULL,
    rider_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(plan_id, scheduled_date)
);

CREATE TABLE IF NOT EXISTS public.trip_entitlement_ledger (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES public.scheduled_plans(id) ON DELETE CASCADE,
    trip_id UUID REFERENCES public.scheduled_trips(id) ON DELETE SET NULL,
    entry_type TEXT NOT NULL CHECK (entry_type IN ('ALLOCATION', 'USAGE', 'ROLLOVER', 'REFUND')),
    credit_amount INT NOT NULL, -- +1 for refund/alloc, -1 for usage
    description TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 4. ROW LEVEL SECURITY (RLS) POLICIES
-- -----------------------------------------------------------------------------

ALTER TABLE public.scheduled_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.school_run_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.authorized_guardians ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scheduled_trips ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trip_entitlement_ledger ENABLE ROW LEVEL SECURITY;

-- Customers can view and manage their own scheduled plans
CREATE POLICY "Users can manage own scheduled plans"
    ON public.scheduled_plans FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Customers can view and manage their school-run profiles
CREATE POLICY "Users can manage own school profiles"
    ON public.school_run_profiles FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Guardians viewable only through school profile ownership
CREATE POLICY "Users can manage authorized guardians"
    ON public.authorized_guardians FOR ALL
    USING (EXISTS (
        SELECT 1 FROM public.school_run_profiles sp
        WHERE sp.id = authorized_guardians.school_profile_id
        AND sp.user_id = auth.uid()
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM public.school_run_profiles sp
        WHERE sp.id = authorized_guardians.school_profile_id
        AND sp.user_id = auth.uid()
    ));

-- Scheduled trips viewable by plan owner or assigned rider
CREATE POLICY "Users view own scheduled trips"
    ON public.scheduled_trips FOR SELECT
    USING (EXISTS (
        SELECT 1 FROM public.scheduled_plans p
        WHERE p.id = scheduled_trips.plan_id
        AND (p.user_id = auth.uid() OR scheduled_trips.rider_id = auth.uid())
    ));

-- Entitlement ledger viewable by plan owner
CREATE POLICY "Users view own entitlement ledger"
    ON public.trip_entitlement_ledger FOR SELECT
    USING (auth.uid() = user_id);
