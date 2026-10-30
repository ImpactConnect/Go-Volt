-- =============================================================================
-- Go-Volts Migration 005: Partner Integrations, API Credentials, Idempotency, & Webhooks
-- Compatible with Supabase PostgreSQL 15+ & Technical Specification §20.7
-- =============================================================================

-- Ensure required crypto extension is available in extensions schema
CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA extensions;

-- -----------------------------------------------------------------------------
-- 1. PARTNER INTEGRATIONS
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.partner_integrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    merchant_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    integration_key TEXT UNIQUE NOT NULL, -- e.g. int_live_49f8a3c8
    display_name TEXT NOT NULL,
    legal_business_name TEXT NOT NULL,
    partner_type TEXT NOT NULL DEFAULT 'ecommerce' CHECK (partner_type IN (
        'ecommerce', 'retail_store', 'marketplace_order_source', 'other'
    )),
    connector_type TEXT NOT NULL DEFAULT 'go_volts_api' CHECK (connector_type IN (
        'go_volts_api', 'shopify_plugin', 'woocommerce_plugin', 'custom_adapter'
    )),
    environment TEXT NOT NULL DEFAULT 'sandbox' CHECK (environment IN ('sandbox', 'production')),
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN (
        'draft', 'pending_verification', 'testing', 'active', 'suspended', 'revoked', 'error'
    )),
    partner_tenant_id TEXT,
    partner_base_url TEXT,
    callback_url TEXT,
    callback_signing_secret TEXT NOT NULL DEFAULT ('whsec_' || replace(gen_random_uuid()::text, '-', '') || replace(gen_random_uuid()::text, '-', '')),
    technical_contact_email TEXT NOT NULL,
    operational_contact TEXT,
    enabled_services TEXT[] NOT NULL DEFAULT '{"DELIVERY_INSTANT"}',
    allowed_scopes TEXT[] NOT NULL DEFAULT '{"deliveries:create", "deliveries:read", "deliveries:quote", "deliveries:cancel"}',
    rate_limit_per_minute INT NOT NULL DEFAULT 60,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 2. PARTNER API CREDENTIALS
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.partner_api_credentials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    partner_integration_id UUID NOT NULL REFERENCES public.partner_integrations(id) ON DELETE CASCADE,
    credential_name TEXT NOT NULL,
    key_prefix TEXT NOT NULL, -- e.g. 'volt_live_49f8' or 'volt_test_99a1'
    secret_hash TEXT NOT NULL, -- SHA-256 hex string of full API key
    scopes TEXT[] NOT NULL DEFAULT '{"deliveries:create", "deliveries:read", "deliveries:quote", "deliveries:cancel"}',
    environment TEXT NOT NULL CHECK (environment IN ('sandbox', 'production')),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    expires_at TIMESTAMPTZ,
    last_used_at TIMESTAMPTZ,
    revoked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_partner_creds_prefix_env
    ON public.partner_api_credentials(key_prefix, environment, is_active);

-- -----------------------------------------------------------------------------
-- 3. PARTNER IDEMPOTENCY RECORDS
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.partner_idempotency_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    partner_integration_id UUID NOT NULL REFERENCES public.partner_integrations(id) ON DELETE CASCADE,
    idempotency_key TEXT NOT NULL,
    request_path TEXT NOT NULL,
    request_hash TEXT NOT NULL, -- SHA-256 of raw request body
    response_status_code INT NOT NULL,
    response_headers JSONB NOT NULL DEFAULT '{}'::jsonb,
    response_body JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '24 hours'),
    UNIQUE(partner_integration_id, idempotency_key)
);

CREATE INDEX IF NOT EXISTS idx_partner_idempotency_lookup
    ON public.partner_idempotency_records(partner_integration_id, idempotency_key, expires_at);

-- -----------------------------------------------------------------------------
-- 4. EXTEND BOOKINGS TABLE FOR PARTNERS
-- -----------------------------------------------------------------------------

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'bookings' AND column_name = 'partner_integration_id'
    ) THEN
        ALTER TABLE public.bookings
            ADD COLUMN partner_integration_id UUID REFERENCES public.partner_integrations(id) ON DELETE SET NULL,
            ADD COLUMN external_reference TEXT,
            ADD COLUMN delivery_otp TEXT;
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_bookings_partner_ext_ref
    ON public.bookings(partner_integration_id, external_reference);

-- -----------------------------------------------------------------------------
-- 5. PARTNER WEBHOOK DELIVERIES (Transactional Outbox)
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.partner_webhook_deliveries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    partner_integration_id UUID NOT NULL REFERENCES public.partner_integrations(id) ON DELETE CASCADE,
    booking_id UUID REFERENCES public.bookings(id) ON DELETE SET NULL,
    event_type TEXT NOT NULL,
    event_version INT NOT NULL DEFAULT 1,
    payload JSONB NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN (
        'pending', 'delivering', 'succeeded', 'retrying', 'dead_letter'
    )),
    attempt_count INT NOT NULL DEFAULT 0,
    next_attempt_at TIMESTAMPTZ,
    last_http_status INT,
    last_error TEXT,
    delivered_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_webhook_deliveries_pending
    ON public.partner_webhook_deliveries(status, next_attempt_at, created_at)
    WHERE status IN ('pending', 'retrying');

-- -----------------------------------------------------------------------------
-- 6. AUTOMATIC WEBHOOK ENQUEUE TRIGGER ON BOOKINGS
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.handle_partner_booking_webhook()
RETURNS TRIGGER AS $$
DECLARE
    integration_record RECORD;
    v_event_type TEXT;
    v_webhook_payload JSONB;
BEGIN
    -- Only trigger for partner-originated bookings
    IF NEW.partner_integration_id IS NULL THEN
        RETURN NEW;
    END IF;

    -- Fetch integration details (callback_url, status)
    SELECT id, callback_url, status INTO integration_record
    FROM public.partner_integrations
    WHERE id = NEW.partner_integration_id;

    -- If partner is inactive or has no webhook URL, skip
    IF integration_record.id IS NULL OR integration_record.callback_url IS NULL OR integration_record.status != 'active' THEN
        RETURN NEW;
    END IF;

    -- Determine event type
    IF TG_OP = 'INSERT' THEN
        v_event_type := 'delivery.created.v1';
    ELSIF TG_OP = 'UPDATE' AND (OLD.status IS DISTINCT FROM NEW.status) THEN
        IF NEW.status = 'ASSIGNED' THEN
            v_event_type := 'delivery.rider_assigned.v1';
        ELSIF NEW.status = 'ARRIVED_AT_PICKUP' THEN
            v_event_type := 'delivery.arrived_pickup.v1';
        ELSIF NEW.status = 'IN_PROGRESS' THEN
            v_event_type := 'delivery.in_transit.v1';
        ELSIF NEW.status = 'COMPLETED' THEN
            v_event_type := 'delivery.delivered.v1';
        ELSIF NEW.status = 'CANCELLED' THEN
            v_event_type := 'delivery.cancelled.v1';
        ELSIF NEW.status = 'FAILED' THEN
            v_event_type := 'delivery.failed.v1';
        ELSE
            RETURN NEW;
        END IF;
    ELSE
        RETURN NEW;
    END IF;

    -- Assemble standard event payload
    v_webhook_payload := jsonb_build_object(
        'id', ('evt_' || replace(gen_random_uuid()::text, '-', '')),
        'type', v_event_type,
        'created_at', NOW(),
        'integration_id', NEW.partner_integration_id,
        'data', jsonb_build_object(
            'delivery_id', NEW.id,
            'tracking_reference', NEW.booking_reference,
            'external_reference', NEW.external_reference,
            'status', NEW.status,
            'recipient_name', NEW.recipient_name,
            'delivery_otp', NEW.delivery_otp,
            'rider_id', NEW.rider_id,
            'updated_at', NOW()
        )
    );

    -- Insert into transactional outbox
    INSERT INTO public.partner_webhook_deliveries (
        partner_integration_id,
        booking_id,
        event_type,
        payload,
        status,
        next_attempt_at
    ) VALUES (
        NEW.partner_integration_id,
        NEW.id,
        v_event_type,
        v_webhook_payload,
        'pending',
        NOW()
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_partner_booking_webhook ON public.bookings;
CREATE TRIGGER trg_partner_booking_webhook
    AFTER INSERT OR UPDATE OF status ON public.bookings
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_partner_booking_webhook();

-- -----------------------------------------------------------------------------
-- 7. ROW LEVEL SECURITY (RLS)
-- -----------------------------------------------------------------------------

ALTER TABLE public.partner_integrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.partner_api_credentials ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.partner_idempotency_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.partner_webhook_deliveries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Merchants manage own integrations"
    ON public.partner_integrations FOR ALL
    USING (auth.uid() = merchant_id)
    WITH CHECK (auth.uid() = merchant_id);

CREATE POLICY "Merchants view own credentials"
    ON public.partner_api_credentials FOR SELECT
    USING (partner_integration_id IN (
        SELECT id FROM public.partner_integrations WHERE merchant_id = auth.uid()
    ));

CREATE POLICY "Merchants view own webhook deliveries"
    ON public.partner_webhook_deliveries FOR SELECT
    USING (partner_integration_id IN (
        SELECT id FROM public.partner_integrations WHERE merchant_id = auth.uid()
    ));

-- -----------------------------------------------------------------------------
-- 8. SEED DEFAULT SANDBOX PARTNER & API CREDENTIAL
-- -----------------------------------------------------------------------------

DO $$
DECLARE
    v_admin_id UUID;
    v_partner_id UUID;
    v_test_key TEXT := 'volt_test_99a1b2c3d4e5f60718293a4b5c6d7e8';
    v_test_hash TEXT;
BEGIN
    SELECT id INTO v_admin_id FROM public.profiles LIMIT 1;
    v_test_hash := encode(extensions.digest(v_test_key::bytea, 'sha256'), 'hex');

    -- Insert Default Retail AI Sandbox Partner
    INSERT INTO public.partner_integrations (
        id,
        merchant_id,
        integration_key,
        display_name,
        legal_business_name,
        partner_type,
        environment,
        status,
        callback_url,
        callback_signing_secret,
        technical_contact_email
    ) VALUES (
        '11111111-2222-3333-4444-555555555555',
        v_admin_id,
        'int_sand_retailai_001',
        'Retail AI Sandbox',
        'Retail AI Commerce Nigeria Ltd',
        'ecommerce',
        'sandbox',
        'active',
        'https://api.retail-ai.ng/webhooks/govolts',
        'whsec_908f7e6d5c4b3a210fedcba987654321',
        'integrations@retail-ai.ng'
    ) ON CONFLICT (id) DO NOTHING;

    -- Insert Sandbox API Key
    INSERT INTO public.partner_api_credentials (
        partner_integration_id,
        credential_name,
        key_prefix,
        secret_hash,
        scopes,
        environment,
        is_active
    ) VALUES (
        '11111111-2222-3333-4444-555555555555',
        'Retail AI Sandbox Test Key',
        'volt_test_99a1',
        v_test_hash,
        ARRAY['deliveries:create', 'deliveries:read', 'deliveries:quote', 'deliveries:cancel'],
        'sandbox',
        TRUE
    ) ON CONFLICT DO NOTHING;
END $$;
