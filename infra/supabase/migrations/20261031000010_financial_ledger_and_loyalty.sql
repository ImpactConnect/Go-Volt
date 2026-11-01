-- =============================================================================
-- Go-Volts Migration 010: Financial Ledger, Loyalty, Coupons & Referrals
-- Master Technical Specification v1.5 §5.8, §5.9 & §8
-- =============================================================================

-- 1. Double-Entry General Ledger Accounts
CREATE TABLE IF NOT EXISTS public.ledger_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    account_type TEXT NOT NULL CHECK (account_type IN ('asset', 'liability', 'income', 'expense', 'equity')),
    currency TEXT NOT NULL DEFAULT 'NGN',
    owner_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Immutable Ledger Transactions
CREATE TABLE IF NOT EXISTS public.ledger_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_reference TEXT UNIQUE NOT NULL,
    transaction_type TEXT NOT NULL,
    source_type TEXT NOT NULL,
    source_id TEXT NOT NULL,
    idempotency_key TEXT UNIQUE,
    status TEXT NOT NULL CHECK (status IN ('pending', 'posted', 'reversed')),
    description TEXT NOT NULL,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    posted_at TIMESTAMPTZ
);

-- 3. Balanced Ledger Entries (Debits == Credits per transaction)
CREATE TABLE IF NOT EXISTS public.ledger_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ledger_transaction_id UUID NOT NULL REFERENCES public.ledger_transactions(id) ON DELETE CASCADE,
    ledger_account_id UUID NOT NULL REFERENCES public.ledger_accounts(id),
    side TEXT NOT NULL CHECK (side IN ('debit', 'credit')),
    amount_minor BIGINT NOT NULL CHECK (amount_minor > 0),
    currency TEXT NOT NULL DEFAULT 'NGN',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ledger_entries_tx ON public.ledger_entries(ledger_transaction_id);
CREATE INDEX IF NOT EXISTS idx_ledger_entries_acc ON public.ledger_entries(ledger_account_id, created_at DESC);

-- 4. Atomic Wallet Reservations (Prevents double spending during pending checkout)
CREATE TABLE IF NOT EXISTS public.wallet_reservations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    booking_id UUID,
    amount_kobo BIGINT NOT NULL CHECK (amount_kobo > 0),
    status TEXT NOT NULL CHECK (status IN ('reserved', 'consumed', 'released', 'expired')),
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_wallet_reservations_user ON public.wallet_reservations(wallet_user_id, status);

-- 5. Loyalty Accounts
CREATE TABLE IF NOT EXISTS public.loyalty_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    points_balance INT NOT NULL DEFAULT 0 CHECK (points_balance >= 0),
    tier_name TEXT NOT NULL DEFAULT 'Starter (Level 1)',
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'closed')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. Loyalty Earning Rules
CREATE TABLE IF NOT EXISTS public.loyalty_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    earning_event TEXT NOT NULL,
    points_delta INT NOT NULL CHECK (points_delta > 0),
    description TEXT NOT NULL DEFAULT '',
    status TEXT NOT NULL DEFAULT 'published' CHECK (status IN ('draft', 'published', 'retired')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 7. Loyalty Transactions (Immutable Point Journal)
CREATE TABLE IF NOT EXISTS public.loyalty_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    loyalty_account_id UUID NOT NULL REFERENCES public.loyalty_accounts(id) ON DELETE CASCADE,
    transaction_type TEXT NOT NULL CHECK (transaction_type IN ('earn', 'redeem', 'expire', 'reverse', 'adjustment')),
    points_delta INT NOT NULL,
    source_event_id TEXT,
    idempotency_key TEXT UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_loyalty_tx_account ON public.loyalty_transactions(loyalty_account_id, created_at DESC);

-- 7b. Admin Loyalty Conversion Rules (§5.9)
-- Admin controls conversion rate (points to kobo), minimum threshold, maximum cap, and preset choices.
CREATE TABLE IF NOT EXISTS public.loyalty_conversion_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    points_required INT NOT NULL DEFAULT 10 CHECK (points_required > 0),
    credit_amount_kobo BIGINT NOT NULL DEFAULT 100 CHECK (credit_amount_kobo > 0),
    minimum_points INT NOT NULL DEFAULT 200 CHECK (minimum_points > 0),
    maximum_points INT CHECK (maximum_points IS NULL OR maximum_points >= minimum_points),
    preset_points INT[] NOT NULL DEFAULT '{200, 500, 1000, 2500}',
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'archived')),
    version INT NOT NULL DEFAULT 1,
    effective_from TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    effective_to TIMESTAMPTZ,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 8. Coupons & Campaign Vouchers
CREATE TABLE IF NOT EXISTS public.coupons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    discount_type TEXT NOT NULL CHECK (discount_type IN ('fixed', 'percentage')),
    discount_value NUMERIC NOT NULL CHECK (discount_value > 0),
    min_order_amount_kobo BIGINT NOT NULL DEFAULT 0,
    max_discount_kobo BIGINT,
    starts_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ends_at TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'expired')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 9. Referral Campaigns & Attributions
CREATE TABLE IF NOT EXISTS public.referral_campaigns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    referrer_reward_kobo BIGINT NOT NULL DEFAULT 50000, -- ₦500
    referred_reward_kobo BIGINT NOT NULL DEFAULT 50000, -- ₦500
    referrer_reward_points INT NOT NULL DEFAULT 500,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'archived')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.referrals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID REFERENCES public.referral_campaigns(id) ON DELETE SET NULL,
    referrer_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    referred_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    referral_code TEXT NOT NULL,
    referred_name TEXT NOT NULL DEFAULT '',
    status TEXT NOT NULL DEFAULT 'registered' CHECK (status IN ('registered', 'pending_qualification', 'qualified', 'rewarded', 'rejected')),
    reward_amount_kobo BIGINT NOT NULL DEFAULT 50000,
    rewarded_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_referrals_referrer ON public.referrals(referrer_user_id, status);

-- Enable RLS
ALTER TABLE public.ledger_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ledger_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ledger_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallet_reservations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loyalty_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loyalty_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loyalty_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loyalty_conversion_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coupons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.referral_campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.referrals ENABLE ROW LEVEL SECURITY;

-- Read policies
DO $$ BEGIN
    CREATE POLICY "Allow public read on active loyalty conversion rules"
        ON public.loyalty_conversion_rules FOR SELECT
        USING (status = 'active');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE POLICY "Users view own wallet reservations"
        ON public.wallet_reservations FOR SELECT
        USING (auth.uid() = wallet_user_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE POLICY "Users view own loyalty account"
        ON public.loyalty_accounts FOR SELECT
        USING (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE POLICY "Allow public read on active coupons"
        ON public.coupons FOR SELECT
        USING (status = 'active');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE POLICY "Users view own referrals"
        ON public.referrals FOR SELECT
        USING (auth.uid() = referrer_user_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- -----------------------------------------------------------------------------
-- SEED INITIAL LEDGER ACCOUNTS & RULES
-- -----------------------------------------------------------------------------

INSERT INTO public.ledger_accounts (code, name, account_type, currency, active)
VALUES
    ('1010-CLEARING-PAYSTACK', 'Paystack Payment Gateway Clearing', 'asset', 'NGN', TRUE),
    ('2010-CUSTOMER-WALLET-LIABILITY', 'Customer Go-Volts Ride Wallet Credit Liability', 'liability', 'NGN', TRUE),
    ('4010-RIDE-REVENUE', 'Go-Volts Electric Ride & Parcel Revenue', 'income', 'NGN', TRUE),
    ('5010-LOYALTY-EXPENSE', 'Customer Loyalty & Eco-Points Redemption Expense', 'expense', 'NGN', TRUE),
    ('5020-REFERRAL-PROMO-EXPENSE', 'Customer Referral Bonus Expense', 'expense', 'NGN', TRUE)
ON CONFLICT (code) DO NOTHING;

-- Seed Active Promotional Coupons
INSERT INTO public.coupons (code, title, discount_type, discount_value, min_order_amount_kobo, max_discount_kobo, starts_at, ends_at, status)
VALUES
    ('VOLTFIRST', '₦500 Off First 3 Clean EV Rides', 'fixed', 50000, 150000, 50000, NOW(), NOW() + INTERVAL '30 days', 'active'),
    ('CLEANLEKKI', '₦1,000 Off Scheduled Commutes', 'fixed', 100000, 500000, 100000, NOW(), NOW() + INTERVAL '60 days', 'active'),
    ('SCHOOLDROP', '₦2,500 Off School Run Monthly Package', 'fixed', 250000, 10000000, 250000, NOW(), NOW() + INTERVAL '90 days', 'active'),
    ('ECOSEND', '20% Off Eco-Parcel Delivery Across Lagos', 'percentage', 20, 100000, 80000, NOW(), NOW() + INTERVAL '45 days', 'active')
ON CONFLICT (code) DO NOTHING;

-- Seed Loyalty Earning Rules
INSERT INTO public.loyalty_rules (name, earning_event, points_delta, description, status)
VALUES
    ('Clean EV Ride Completion', 'completed_paid_ride', 15, 'Earn 15 Eco-Points for every completed zero-emission ride.', 'published'),
    ('Off-Peak Green Travel', 'completed_off_peak_ride', 25, 'Earn 25 Eco-Points during off-peak hours (11:00 AM - 3:00 PM).', 'published'),
    ('Weekly Scheduled Commute', 'completed_scheduled_week', 100, 'Earn 100 bonus Eco-Points upon completing 5 scheduled pickup trips.', 'published'),
    ('Battery Swap Kiosk Visit', 'battery_swap_visit', 20, 'Earn 20 Eco-Points when your ride swaps batteries at a solar kiosk.', 'published');

-- Seed Default Referral Campaign
INSERT INTO public.referral_campaigns (name, referrer_reward_kobo, referred_reward_kobo, referrer_reward_points, status)
VALUES
    ('Lagos Clean Energy Pioneer Campaign', 50000, 50000, 500, 'active');

-- Seed Admin Loyalty Conversion Rule (Default: 10 pts = ₦1, Min: 200 pts, Presets: 200, 500, 1000, 2500)
INSERT INTO public.loyalty_conversion_rules (
    points_required,
    credit_amount_kobo,
    minimum_points,
    maximum_points,
    preset_points,
    status,
    version
) VALUES (
    10,
    100,
    200,
    10000,
    '{200, 500, 1000, 2500}',
    'active',
    1
);
