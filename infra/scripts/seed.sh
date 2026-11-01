#!/usr/bin/env bash
# ==============================================================================
# Go_Volt Database Seed Script
# Seeds default test data for local development and integration testing
# ==============================================================================

set -euo pipefail

DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-govolts_db}"
DB_USER="${DB_USER:-govolts_user}"
DB_PASSWORD="${DB_PASSWORD:-govolts_secret_password}"

export PGPASSWORD="${DB_PASSWORD}"

echo "⚡ [Go_Volt] Seeding operational test data into ${DB_NAME}..."

psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -v ON_ERROR_STOP=1 <<-EOSQL
  -- Seed Service Areas / Hubs
  INSERT INTO service_zones (id, name, city, center_lat, center_lng, is_active)
  VALUES 
    ('zone_lekki', 'Lekki Phase 1', 'Lagos', 6.4474, 3.4700, true),
    ('zone_vi', 'Victoria Island', 'Lagos', 6.4281, 3.4219, true),
    ('zone_ikeja', 'Ikeja City Mall', 'Lagos', 6.6018, 3.3515, true)
  ON CONFLICT (id) DO NOTHING;

  -- Seed Battery Swap Stations
  INSERT INTO battery_swap_stations (id, name, zone_id, address, latitude, longitude, total_slots, available_batteries, is_operational)
  VALUES
    ('STN-VI-01', 'Victoria Island Central Hub', 'zone_vi', 'Plot 883 Saka Tinubu Street', 6.4290, 3.4225, 10, 8, true),
    ('STN-LEKKI-02', 'Lekki Phase 1 Hub', 'zone_lekki', '14 Admiralty Way, Lekki', 6.4480, 3.4710, 12, 10, true),
    ('STN-IKEJA-03', 'Ikeja City Mall Hub', 'zone_ikeja', 'Alausa, Ikeja', 6.6020, 3.3520, 8, 7, true)
  ON CONFLICT (id) DO NOTHING;

  -- Seed Electric Vehicles
  INSERT INTO vehicles (id, plate_number, model, battery_capacity_kwh, current_soc, status)
  VALUES
    ('veh_001', 'LAG-882-VOLT', 'Ampersand E-Moped Cargo Pro', 3.5, 94, 'ACTIVE'),
    ('veh_002', 'LAG-104-VOLT', 'Ampersand E-Moped Passenger', 3.0, 88, 'ACTIVE'),
    ('veh_003', 'LAG-239-VOLT', 'Spiro Commuter EV', 2.8, 98, 'ACTIVE')
  ON CONFLICT (id) DO NOTHING;

  -- Seed Operating Locations
  INSERT INTO operating_locations (state, city, is_active, status, status_description, available_services, center_lat, center_lng)
  VALUES 
    ('Ogun', 'Shaganu', true, 'fully_supported', 'Fully supported', ARRAY['instant_ride','instant_delivery','scheduled_ride','scheduled_pickup'], 6.8403, 3.6487),
    ('Ogun', 'Shagamu', true, 'fully_supported', 'Fully supported', ARRAY['instant_ride','instant_delivery','scheduled_ride','scheduled_pickup'], 6.8403, 3.6487)
  ON CONFLICT (state, city) DO NOTHING;

  -- Seed Dynamic Ride Categories (2 Bikes + 3 Cars)
  INSERT INTO ride_categories (id, code, name, description, passenger_capacity, capacity_label, base_fare_kobo, eta_minutes, features, icon_key, is_available, display_order, status)
  VALUES
    ('cat_bike_std', 'bike_standard', 'GoRide Moto', 'Fast and affordable solo rides on electric two-wheelers', 1, '1 Seat (Helmet provided)', 120000, 2, '["Helmet provided", "1 Passenger", "Fastest in traffic", "Zero emission"]'::jsonb, 'electric_bike', true, 1, 'active'),
    ('cat_bike_plus', 'bike_plus', 'GoRide Moto Plus', 'Top-rated electric bike rider with sanitized helmet & hairnet', 1, '1 Seat (Premium)', 180000, 2, '["Sanitized helmet", "Top-rated rider", "Express lane", "Zero emission"]'::jsonb, 'electric_bike', true, 2, 'active'),
    ('cat_car_std', 'standard', 'GoRide Standard', 'Affordable, reliable everyday electric car rides', 3, '3 Seats', 280000, 2, '["AC", "3 Seats", "Trusted drivers"]'::jsonb, 'electric_car', true, 3, 'active'),
    ('cat_car_plus', 'plus', 'GoRide Plus', 'More comfort and legroom in premium electric sedans', 4, '4 Seats', 350000, 3, '["AC", "Extra legroom", "Top rated", "Quiet ride"]'::jsonb, 'electric_car', true, 4, 'active'),
    ('cat_car_xl', 'xl', 'GoRide XL', 'Bigger 6-seater electric vehicles for groups or extra luggage', 6, '6 Seats', 450000, 4, '["AC", "6 Seats", "Spacious trunk", "Group trips"]'::jsonb, 'electric_car', true, 5, 'active')
  ON CONFLICT (code) DO NOTHING;

  -- Seed Default Admin User
  INSERT INTO users (id, email, full_name, role, status)
  VALUES
    ('usr_admin_001', 'admin@govolts.ng', 'Go_Volt Fleet Admin', 'SUPER_ADMIN', 'ACTIVE')
  ON CONFLICT (id) DO NOTHING;
EOSQL

echo "🎉 [Go_Volt] Database seed completed successfully!"
