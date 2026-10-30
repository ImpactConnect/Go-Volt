-- =============================================================================
-- Go-Volts Migration 006: Partner Corporate Wallets & Atomic Dispatch Ledger
-- Compatible with Supabase PostgreSQL 15+ & Technical Specification §20.7
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. PARTNER CORPORATE WALLETS
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.partner_wallets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    partner_integration_id UUID NOT NULL REFERENCES public.partner_integrations(id) ON DELETE CASCADE UNIQUE,
    balance_kobo BIGINT NOT NULL DEFAULT 0 CHECK (balance_kobo >= 0),
    credit_limit_kobo BIGINT NOT NULL DEFAULT 0 CHECK (credit_limit_kobo >= 0),
    currency TEXT NOT NULL DEFAULT 'NGN',
    billing_mode TEXT NOT NULL DEFAULT 'PREPAID' CHECK (billing_mode IN ('PREPAID', 'POSTPAID')),
    auto_topup_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 2. PARTNER WALLET TRANSACTIONS (LEDGER)
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.partner_wallet_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    partner_wallet_id UUID NOT NULL REFERENCES public.partner_wallets(id) ON DELETE CASCADE,
    partner_integration_id UUID NOT NULL REFERENCES public.partner_integrations(id) ON DELETE CASCADE,
    amount_kobo BIGINT NOT NULL CHECK (amount_kobo > 0),
    type TEXT NOT NULL CHECK (type IN ('CREDIT', 'DEBIT', 'REFUND', 'ADJUSTMENT')),
    reference TEXT NOT NULL UNIQUE,
    description TEXT NOT NULL,
    booking_id UUID REFERENCES public.bookings(id) ON DELETE SET NULL,
    status TEXT NOT NULL DEFAULT 'COMPLETED' CHECK (status IN ('PENDING', 'COMPLETED', 'FAILED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_partner_wallets_integration ON public.partner_wallets(partner_integration_id);
CREATE INDEX IF NOT EXISTS idx_partner_wallet_tx_integration ON public.partner_wallet_transactions(partner_integration_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_partner_wallet_tx_ref ON public.partner_wallet_transactions(reference);

-- -----------------------------------------------------------------------------
-- 3. ROW LEVEL SECURITY
-- -----------------------------------------------------------------------------

ALTER TABLE public.partner_wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.partner_wallet_transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow service role full access on partner_wallets"
    ON public.partner_wallets
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Allow service role full access on partner_wallet_transactions"
    ON public.partner_wallet_transactions
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- -----------------------------------------------------------------------------
-- 4. ATOMIC DISPATCH & LEDGER RPC FUNCTION
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.dispatch_partner_delivery(
    p_integration_id UUID,
    p_booking_id UUID,
    p_booking_reference TEXT,
    p_external_reference TEXT,
    p_gross_fare_kobo BIGINT,
    p_pickup_address TEXT,
    p_pickup_lat DOUBLE PRECISION,
    p_pickup_lng DOUBLE PRECISION,
    p_dropoff_address TEXT,
    p_dropoff_lat DOUBLE PRECISION,
    p_dropoff_lng DOUBLE PRECISION,
    p_recipient_name TEXT,
    p_recipient_phone TEXT,
    p_delivery_otp TEXT,
    p_instructions TEXT
) RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_wallet RECORD;
    v_available_kobo BIGINT;
    v_user_id UUID;
    v_merchant_id UUID;
    v_new_balance_kobo BIGINT;
BEGIN
    -- Check if partner exists
    SELECT merchant_id INTO v_merchant_id
    FROM public.partner_integrations
    WHERE id = p_integration_id;

    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'success', false,
            'error_code', 'INTEGRATION_NOT_FOUND',
            'message', 'Partner integration was not found.'
        );
    END IF;

    -- Lock and retrieve partner wallet
    SELECT * INTO v_wallet
    FROM public.partner_wallets
    WHERE partner_integration_id = p_integration_id
    FOR UPDATE;

    -- If no wallet row exists, automatically provision one with default sandbox or production balance
    IF v_wallet IS NULL THEN
        INSERT INTO public.partner_wallets (
            partner_integration_id,
            balance_kobo,
            credit_limit_kobo,
            billing_mode
        ) VALUES (
            p_integration_id,
            50000000, -- 500,000 NGN starter credit for seamless testing
            10000000,
            'PREPAID'
        )
        RETURNING * INTO v_wallet;
    END IF;

    -- Calculate total available funds considering credit limit if in POSTPAID mode
    IF v_wallet.billing_mode = 'POSTPAID' THEN
        v_available_kobo := v_wallet.balance_kobo + v_wallet.credit_limit_kobo;
    ELSE
        v_available_kobo := v_wallet.balance_kobo;
    END IF;

    -- Enforce balance sufficiency
    IF v_available_kobo < p_gross_fare_kobo THEN
        RETURN jsonb_build_object(
            'success', false,
            'error_code', 'INSUFFICIENT_WALLET_BALANCE',
            'message', 'Corporate wallet balance is insufficient for this delivery fare.',
            'available_balance_kobo', v_available_kobo,
            'required_fare_kobo', p_gross_fare_kobo
        );
    END IF;

    -- Determine user_id for bookings foreign key (fallback to existing profile)
    IF v_merchant_id IS NOT NULL THEN
        v_user_id := v_merchant_id;
    ELSE
        SELECT id INTO v_user_id FROM public.profiles LIMIT 1;
        IF v_user_id IS NULL THEN
            v_user_id := p_integration_id;
        END IF;
    END IF;

    -- 1. Deduct fare from corporate wallet
    v_new_balance_kobo := v_wallet.balance_kobo - p_gross_fare_kobo;
    UPDATE public.partner_wallets
    SET balance_kobo = v_new_balance_kobo,
        updated_at = NOW()
    WHERE id = v_wallet.id;

    -- 2. Insert debit ledger entry
    INSERT INTO public.partner_wallet_transactions (
        partner_wallet_id,
        partner_integration_id,
        amount_kobo,
        type,
        reference,
        description,
        booking_id,
        status
    ) VALUES (
        v_wallet.id,
        p_integration_id,
        p_gross_fare_kobo,
        'DEBIT',
        'WAL-DEB-' || p_booking_reference,
        'Partner Delivery Dispatch: ' || p_booking_reference,
        p_booking_id,
        'COMPLETED'
    );

    -- 3. Insert delivery booking
    INSERT INTO public.bookings (
        id,
        booking_reference,
        external_reference,
        user_id,
        partner_integration_id,
        service_code,
        status,
        pickup_address,
        pickup_lat,
        pickup_lng,
        dropoff_address,
        dropoff_lat,
        dropoff_lng,
        recipient_name,
        recipient_phone,
        delivery_otp,
        instructions,
        total_amount,
        payment_method,
        payment_status
    ) VALUES (
        p_booking_id,
        p_booking_reference,
        p_external_reference,
        v_user_id,
        p_integration_id,
        'DELIVERY_INSTANT',
        'SEARCHING_RIDER',
        p_pickup_address,
        p_pickup_lat,
        p_pickup_lng,
        p_dropoff_address,
        p_dropoff_lat,
        p_dropoff_lng,
        p_recipient_name,
        p_recipient_phone,
        p_delivery_otp,
        p_instructions,
        (p_gross_fare_kobo::NUMERIC / 100.0),
        'CORPORATE_WALLET',
        'COMPLETED'
    );

    RETURN jsonb_build_object(
        'success', true,
        'booking_id', p_booking_id,
        'booking_reference', p_booking_reference,
        'external_reference', p_external_reference,
        'gross_fare_kobo', p_gross_fare_kobo,
        'remaining_balance_kobo', v_new_balance_kobo
    );
END;
$$;

-- -----------------------------------------------------------------------------
-- 5. SEED SANDBOX PARTNER WALLET
-- -----------------------------------------------------------------------------

INSERT INTO public.partner_wallets (
    partner_integration_id,
    balance_kobo,
    credit_limit_kobo,
    currency,
    billing_mode
) VALUES (
    '11111111-2222-3333-4444-555555555555',
    50000000, -- 500,000 NGN
    100000000, -- 1,000,000 NGN
    'NGN',
    'PREPAID'
) ON CONFLICT (partner_integration_id) DO NOTHING;
