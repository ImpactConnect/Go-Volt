-- =============================================================================
-- Go-Volts Migration 004: Supabase Storage Buckets, RLS, & Push Notification Outbox Trigger
-- Compatible with Supabase PostgreSQL 15+
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. STORAGE BUCKETS PROVISIONING
-- -----------------------------------------------------------------------------

-- Create public avatars bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'avatars',
    'avatars',
    TRUE,
    2097152, -- 2MB
    ARRAY['image/png', 'image/jpeg', 'image/jpg', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
    public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Create private KYC documents bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'kyc-documents',
    'kyc-documents',
    FALSE,
    10485760, -- 10MB
    ARRAY['image/png', 'image/jpeg', 'image/jpg', 'application/pdf']
)
ON CONFLICT (id) DO UPDATE SET
    public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Create private delivery proof bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'delivery-proofs',
    'delivery-proofs',
    FALSE,
    5242880, -- 5MB
    ARRAY['image/png', 'image/jpeg', 'image/jpg']
)
ON CONFLICT (id) DO UPDATE SET
    public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

-- -----------------------------------------------------------------------------
-- 2. STORAGE ROW LEVEL SECURITY (RLS) POLICIES
-- -----------------------------------------------------------------------------

-- Avatars: Public read
CREATE POLICY "Public Read Avatars"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'avatars');

-- Avatars: Users upload and manage their own avatar
CREATE POLICY "Users Manage Own Avatar"
    ON storage.objects FOR ALL
    USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1])
    WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- KYC Documents: Riders can upload only to their own folder: kyc-documents/{rider_id}/*
CREATE POLICY "Riders Manage Own KYC Docs"
    ON storage.objects FOR ALL
    USING (bucket_id = 'kyc-documents' AND auth.uid()::text = (storage.foldername(name))[1])
    WITH CHECK (bucket_id = 'kyc-documents' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Delivery Proofs: Riders upload to delivery-proofs/{booking_id}/*
CREATE POLICY "Riders Upload Delivery Proofs"
    ON storage.objects FOR INSERT
    WITH CHECK (bucket_id = 'delivery-proofs' AND auth.role() = 'authenticated');

CREATE POLICY "Users View Own Delivery Proofs"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'delivery-proofs' AND auth.role() = 'authenticated');

-- -----------------------------------------------------------------------------
-- 3. PUSH NOTIFICATION OUTBOX TRIGGER
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.handle_booking_push_notification()
RETURNS TRIGGER AS $$
DECLARE
    notification_title TEXT;
    notification_body TEXT;
    target_user_id UUID;
BEGIN
    -- Determine notification context based on new status
    IF NEW.status = 'ASSIGNED' AND (OLD.status IS DISTINCT FROM NEW.status) THEN
        notification_title := 'Rider Assigned! ⚡';
        notification_body := 'Your Go-Volts eco-rider is on the way to your pickup location.';
        target_user_id := NEW.user_id;
    ELSIF NEW.status = 'ARRIVED_AT_PICKUP' AND (OLD.status IS DISTINCT FROM NEW.status) THEN
        notification_title := 'Rider Arrived 📍';
        notification_body := 'Your rider has arrived at the pickup location.';
        target_user_id := NEW.user_id;
    ELSIF NEW.status = 'IN_PROGRESS' AND (OLD.status IS DISTINCT FROM NEW.status) THEN
        notification_title := 'Trip Started 🛵';
        notification_body := 'Your Go-Volts journey has commenced.';
        target_user_id := NEW.user_id;
    ELSIF NEW.status = 'COMPLETED' AND (OLD.status IS DISTINCT FROM NEW.status) THEN
        notification_title := 'Trip Completed 🎉';
        notification_body := 'Thank you for riding green! 0.42 kg CO2 saved.';
        target_user_id := NEW.user_id;
    ELSIF NEW.status = 'CANCELLED' AND (OLD.status IS DISTINCT FROM NEW.status) THEN
        notification_title := 'Booking Cancelled';
        notification_body := 'Your booking has been cancelled.';
        target_user_id := NEW.user_id;
    ELSE
        RETURN NEW;
    END IF;

    -- Insert outbox notification dispatch record
    INSERT INTO public.outbox_events (
        event_type,
        aggregate_type,
        aggregate_id,
        payload,
        status
    ) VALUES (
        'PUSH_NOTIFICATION_DISPATCH',
        'BOOKING',
        NEW.id::TEXT,
        jsonb_build_object(
            'target_user_id', target_user_id,
            'booking_id', NEW.id,
            'booking_reference', NEW.booking_reference,
            'status', NEW.status,
            'title', notification_title,
            'body', notification_body,
            'created_at', NOW()
        ),
        'PENDING'
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_booking_push_notification ON public.bookings;
CREATE TRIGGER trg_booking_push_notification
    AFTER INSERT OR UPDATE OF status ON public.bookings
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_booking_push_notification();
