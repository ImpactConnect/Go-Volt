-- =============================================================================
-- Go-Volts Migration 009: Ride Categories Dynamic Catalogue (v1.3 §5.4 & §6.8.1)
-- Dynamically managed ride options for bikes and cars configured by admin.
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.ride_categories (
    id TEXT PRIMARY KEY,
    code TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    passenger_capacity INT NOT NULL DEFAULT 3,
    capacity_label TEXT NOT NULL DEFAULT '3 Seats',
    base_fare_kobo BIGINT NOT NULL,
    eta_minutes INT NOT NULL DEFAULT 3,
    features JSONB NOT NULL DEFAULT '[]'::jsonb,
    icon_key TEXT NOT NULL DEFAULT 'electric_car',
    image_url TEXT,
    service_area_id UUID REFERENCES public.service_areas(id) ON DELETE SET NULL,
    pricing_rule_id UUID,
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    display_order INT NOT NULL DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('draft', 'active', 'inactive', 'archived')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for ordering and availability lookups
CREATE INDEX IF NOT EXISTS idx_ride_categories_status_order
    ON public.ride_categories (status, display_order)
    WHERE is_available = TRUE;

-- Enable RLS
ALTER TABLE public.ride_categories ENABLE ROW LEVEL SECURITY;

-- Public/Customer read policy (any authenticated or anonymous user can view active ride categories)
DO $$ BEGIN
    CREATE POLICY "Allow public read on active ride categories"
        ON public.ride_categories FOR SELECT
        USING (status = 'active' AND is_available = TRUE);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- Admin write policy (service role or admin users)
DO $$ BEGIN
    CREATE POLICY "Allow admin full access to ride categories"
        ON public.ride_categories FOR ALL
        USING (auth.jwt() ->> 'role' = 'service_role' OR auth.jwt() ->> 'email' LIKE '%@govolts.ng')
        WITH CHECK (auth.jwt() ->> 'role' = 'service_role' OR auth.jwt() ->> 'email' LIKE '%@govolts.ng');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- -----------------------------------------------------------------------------
-- SEED 5 RIDE OPTIONS (2 BIKES + 3 CARS)
-- -----------------------------------------------------------------------------

INSERT INTO public.ride_categories (
    id, code, name, description, passenger_capacity, capacity_label,
    base_fare_kobo, eta_minutes, features, icon_key, is_available, display_order, status
)
VALUES
    -- 1. Bike Option 1: GoRide Moto
    (
        'cat_bike_std',
        'bike_standard',
        'GoRide Moto',
        'Fast and affordable solo rides on electric two-wheelers',
        1,
        '1 Seat (Helmet provided)',
        120000, -- ₦1,200
        2,
        '["Helmet provided", "1 Passenger", "Fastest in traffic", "Zero emission"]'::jsonb,
        'electric_bike',
        TRUE,
        1,
        'active'
    ),
    -- 2. Bike Option 2: GoRide Moto Plus
    (
        'cat_bike_plus',
        'bike_plus',
        'GoRide Moto Plus',
        'Top-rated electric bike rider with sanitized helmet & hairnet',
        1,
        '1 Seat (Premium)',
        180000, -- ₦1,800
        2,
        '["Sanitized helmet", "Top-rated rider", "Express lane", "Zero emission"]'::jsonb,
        'electric_bike',
        TRUE,
        2,
        'active'
    ),
    -- 3. Car Option 1: GoRide Standard
    (
        'cat_car_std',
        'standard',
        'GoRide Standard',
        'Affordable, reliable everyday electric car rides',
        3,
        '3 Seats',
        280000, -- ₦2,800
        2,
        '["AC", "3 Seats", "Trusted drivers"]'::jsonb,
        'electric_car',
        TRUE,
        3,
        'active'
    ),
    -- 4. Car Option 2: GoRide Plus
    (
        'cat_car_plus',
        'plus',
        'GoRide Plus',
        'More comfort and legroom in premium electric sedans',
        4,
        '4 Seats',
        350000, -- ₦3,500
        3,
        '["AC", "Extra legroom", "Top rated", "Quiet ride"]'::jsonb,
        'electric_car',
        TRUE,
        4,
        'active'
    ),
    -- 5. Car Option 3: GoRide XL
    (
        'cat_car_xl',
        'xl',
        'GoRide XL',
        'Bigger 6-seater electric vehicles for groups or extra luggage',
        6,
        '6 Seats',
        450000, -- ₦4,500
        4,
        '["AC", "6 Seats", "Spacious trunk", "Group trips"]'::jsonb,
        'electric_car',
        TRUE,
        5,
        'active'
    )
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    passenger_capacity = EXCLUDED.passenger_capacity,
    capacity_label = EXCLUDED.capacity_label,
    base_fare_kobo = EXCLUDED.base_fare_kobo,
    eta_minutes = EXCLUDED.eta_minutes,
    features = EXCLUDED.features,
    icon_key = EXCLUDED.icon_key,
    is_available = EXCLUDED.is_available,
    display_order = EXCLUDED.display_order,
    status = EXCLUDED.status,
    updated_at = NOW();
