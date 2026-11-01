-- Migration: 20261031000007_operating_locations
-- Creates the operating_locations table and seeds the initial operating city.
-- Admin panel provisions cities/states through CRUD on this table.

CREATE TABLE IF NOT EXISTS public.operating_locations (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  state           text        NOT NULL,
  city            text        NOT NULL,
  is_active       boolean     NOT NULL DEFAULT true,
  -- 'fully_supported' | 'limited' | 'coming_soon'
  status          text        NOT NULL DEFAULT 'fully_supported',
  status_description text,
  available_services text[]   NOT NULL DEFAULT ARRAY[
    'instant_ride',
    'instant_delivery'
  ],
  -- Approximate centre coordinates of the city for map pinning
  center_lat      double precision,
  center_lng      double precision,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),
  UNIQUE(state, city)
);

-- Auto-update updated_at on row change
CREATE OR REPLACE FUNCTION public.set_operating_locations_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_operating_locations_updated_at ON public.operating_locations;
CREATE TRIGGER trg_operating_locations_updated_at
  BEFORE UPDATE ON public.operating_locations
  FOR EACH ROW EXECUTE PROCEDURE public.set_operating_locations_updated_at();

-- ── Row-Level Security ─────────────────────────────────────────────────────────
ALTER TABLE public.operating_locations ENABLE ROW LEVEL SECURITY;

-- Any authenticated or anonymous user can read active locations
CREATE POLICY "public_read_active_locations"
  ON public.operating_locations
  FOR SELECT
  USING (is_active = true);

-- Only service-role (backend / admin) can mutate rows
CREATE POLICY "service_role_manage_locations"
  ON public.operating_locations
  FOR ALL
  USING (auth.role() = 'service_role');

-- ── Seed: Ogun / Shaganu ──────────────────────────────────────────────────────
-- Set business operating city: State: Ogun, City: Shaganu
INSERT INTO public.operating_locations (
  state,
  city,
  is_active,
  status,
  status_description,
  available_services,
  center_lat,
  center_lng
) VALUES (
  'Ogun',
  'Shaganu',
  true,
  'fully_supported',
  'Fully supported',
  ARRAY[
    'instant_ride',
    'instant_delivery',
    'scheduled_ride',
    'scheduled_pickup'
  ],
  6.8403,    -- Shaganu, Ogun State latitude
  3.6487     -- Shaganu, Ogun State longitude
),
(
  'Ogun',
  'Shagamu',
  true,
  'fully_supported',
  'Fully supported',
  ARRAY[
    'instant_ride',
    'instant_delivery',
    'scheduled_ride',
    'scheduled_pickup'
  ],
  6.8403,    -- Sagamu / Shagamu latitude
  3.6487     -- Sagamu / Shagamu longitude
)
ON CONFLICT (state, city) DO UPDATE SET
  is_active           = EXCLUDED.is_active,
  status              = EXCLUDED.status,
  status_description  = EXCLUDED.status_description,
  available_services  = EXCLUDED.available_services,
  center_lat          = EXCLUDED.center_lat,
  center_lng          = EXCLUDED.center_lng,
  updated_at          = now();
