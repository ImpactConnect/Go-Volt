# Go-Volts Customer App: Ride Flow Specification

**Document ID:** GV-CUST-RIDE-001  
**Version:** 1.0  
**Date:** October 2026  
**Status:** Working specification for product, UI/UX and engineering  
**Platform:** Flutter mobile app, Android and iOS

## 1. Purpose

This document defines the Go-Volts customer Ride flow before individual ride-booking screen visuals are produced. It covers the customer journey, screen inventory, components, suggested dimensions, content hierarchy, interactions, validation, API/data requirements, booking and payment states, dispatch updates, responsive behaviour, exceptional states and acceptance criteria.

It is based on the Go-Volts Developer Concept Note v1.1 and Technical Specification v1.2. Exact fares, ride categories, cancellation fees, payment policies and dispatch rules remain backend/Product decisions. Generated screen images are visual references, not sources of authoritative data.

### 1.1 Source-defined ride journey

The concept note defines these stages:

1. Pickup and destination
2. Map selection
3. Fare estimate
4. Ride options, where applicable
5. Booking confirmation
6. Searching for rider
7. Rider assigned
8. Driver approaching
9. Active trip
10. Trip completed
11. Rating and receipt

Required ride UI elements include a map, pickup and destination fields, saved locations, location pin, fare breakdown, payment selector, coupon field, eligible wallet balance, points redemption where enabled, booking confirmation, cancellation policy and safety controls.

### 1.2 Normative language

- **MUST:** required for correctness, safety or security.
- **SHOULD:** recommended unless there is a documented reason not to.
- **MAY:** optional or dependent on a product decision.
- **Proposed:** recommendation requiring approval.
- **Decision required:** Product or Operations must confirm before production.

---

# PART A: RIDE FLOW OVERVIEW

## 2. Ride flow goals

The customer should be able to:

- Set a valid pickup and destination.
- Confirm that the route is serviceable.
- Select an eligible ride category, where applicable.
- Review a server-generated fare estimate.
- Select an eligible payment method and optional discount/credit.
- Confirm the booking.
- Follow rider matching and assignment.
- See rider and vehicle details after assignment.
- Track the rider's arrival and the active trip.
- Access approved support and safety features.
- Review the completed trip, receipt and rating request.

### 2.1 Experience principles

- Keep pickup and destination entry simple.
- Make the map useful without allowing it to overwhelm the form.
- Keep the primary action visible and easy to reach.
- Explain unavailable routes and failed requests clearly.
- Show fares only when a valid backend quote exists.
- Do not display rider identity or vehicle information before assignment is confirmed.
- Do not imply that a ride is confirmed before the backend accepts the booking.
- Do not display a stale quote as current.
- Do not encourage unsafe phone interaction while travelling.

## 3. End-to-end flow

```text
HOME
  -> Pickup and destination entry
  -> Map selection / location confirmation
  -> Route preview and serviceability
  -> Ride options (if applicable)
  -> Fare and payment review
  -> Booking review and confirmation
  -> Searching for rider
  -> Rider assigned
  -> Driver approaching
  -> Active trip
  -> Trip completed
  -> Receipt and rating
```

Alternative paths:

- Route not serviceable -> explain and allow location changes.
- No ride options -> explain and allow retry or edit.
- Quote expired -> refresh quote and request customer review.
- No riders available -> show recovery options.
- Rider declines/cancels -> return to matching or show recovery options.
- Customer cancels -> apply server cancellation policy and show result.
- Payment fails -> retry or choose another eligible method.
- Booking expires -> explain and start a new quote.
- Trip interrupted -> show status, support and incident actions.
- Emergency reported -> enter approved safety escalation flow.

## 4. Ride screen inventory

| ID | Screen | Purpose |
|---|---|---|
| RIDE-01 | Pickup and Destination Entry | Enter journey endpoints |
| RIDE-02 | Map Location Picker | Pinpoint and confirm a location |
| RIDE-03 | Route Preview and Serviceability | Review route and service coverage |
| RIDE-04 | Ride Options | Select an eligible category, if applicable |
| RIDE-05 | Fare and Payment Review | Review quote, discount, wallet credit and payment |
| RIDE-06 | Booking Review | Confirm journey, amount and terms |
| RIDE-07 | Searching for Rider | Show matching progress |
| RIDE-08 | Rider Assigned | Show assigned rider and vehicle |
| RIDE-09 | Driver Approaching | Track rider approaching pickup |
| RIDE-10 | Active Trip | Show trip progress and safety controls |
| RIDE-11 | Trip Completed | Confirm completion and final amount |
| RIDE-12 | Receipt | Show final trip/payment breakdown |
| RIDE-13 | Rate Your Trip | Collect rating and feedback |

Some states may be combined into one screen if the experience remains clear.

---

# PART B: GLOBAL RIDE DESIGN SYSTEM

## 5. Visual direction

Use the approved dark-green Go-Volts direction from the current screen concepts.

Suggested tokens (proposed, subject to design approval):

| Token | Suggested value | Usage |
|---|---|---|
| `color.background` | `#071B19` | Main background |
| `color.surface` | `#103B32` | Cards and panels |
| `color.surfaceElevated` | `#172A27` | Inputs and elevated panels |
| `color.primary` | `#4FE681` | Primary CTA and highlights |
| `color.primaryPressed` | `#31C968` | Pressed CTA |
| `color.textPrimary` | `#F5FAF6` | Main text |
| `color.textSecondary` | `#A8B9B1` | Supporting text |
| `color.border` | `#31534A` | Dividers and outlines |

Use approved warning, error and success colours. Never rely on colour alone to communicate status.

### 5.1 Typography

| Style | Size | Weight | Usage |
|---|---:|---|---|
| Screen headline | 26-30 sp | Bold | Main screen title |
| Section title | 18-20 sp | Semibold | Section heading |
| Card title | 15-17 sp | Semibold | Card labels |
| Body | 14-16 sp | Regular | Supporting text |
| Caption | 12-13 sp | Regular | Hints and metadata |
| Button | 14-16 sp | Semibold | Button label |
| Fare amount | 24-30 sp | Bold | Prominent fare |

Support text scaling and test larger accessibility font settings.

### 5.2 Spacing and shape

| Token | Suggested value |
|---|---:|
| Screen horizontal margin | 20 dp |
| Compact horizontal margin | 16 dp |
| Section gap | 20-24 dp |
| Card padding | 14-16 dp |
| Small component gap | 8 dp |
| Standard component gap | 12 dp |
| Card radius | 16-20 dp |
| Input radius | 12-14 dp |
| Button height | 50-54 dp |
| Minimum touch target | 48 x 48 dp |

### 5.3 Shared components

Create reusable components for:

- Ride top bar and back button
- Location search field
- Pickup and destination rows
- Swap locations control
- Map canvas, map pin and current-location button
- Saved location chip and recent search row
- Route summary and serviceability banner
- Ride category card
- Fare breakdown row
- Coupon entry row
- Wallet credit selector
- Payment method selector
- Primary CTA and bottom action panel
- Booking status chip
- Rider profile and vehicle detail cards
- ETA display and trip progress timeline
- Safety and support actions
- Loading skeleton, empty state and error state
- Confirmation dialog and bottom sheet

Components should support default, loading, disabled, error and selected states where relevant.

---

# PART C: INDIVIDUAL SCREEN SPECIFICATIONS

## 6. RIDE-01: Pickup and Destination Entry

**Purpose:** Let the customer enter where the ride starts and ends.

### Layout and hierarchy

1. Top bar with back action and title.
2. Pickup field.
3. Destination field.
4. Swap locations control.
5. Map preview or map region.
6. Saved locations.
7. Recent searches/suggestions.
8. Bottom Continue CTA.

Primary content is pickup and destination. Map preview and saved places are secondary. Recent searches and helper text are tertiary.

### Suggested dimensions

| Component | Dimensions |
|---|---|
| Top bar | 52-60 dp |
| Location input | 56-64 dp |
| Gap between fields | 10-12 dp |
| Swap control | 40-48 dp touch target |
| Saved location chip | 40-48 dp |
| Recent result row | 60-72 dp |
| Bottom CTA | 50-54 dp |
| Horizontal margin | 20 dp |

### Interactions and validation

- Tap a field to search or choose current location.
- Typing displays place/address suggestions.
- Selecting a saved location fills the active field.
- Swap exchanges pickup and destination.
- Current-location action requests device location only when needed.
- Continue is disabled until both locations are valid.
- Changing either location invalidates the previous route quote.
- Selected locations must resolve to usable coordinates and display labels.
- Do not accept arbitrary unvalidated text as a confirmed location.
- Explain when a selected point is outside the service area.
- If location permission is denied, allow manual search.

### API/data requirements

Integrations may include a Places autocomplete/search provider, geocoding provider, customer saved-address endpoint and service-area lookup.

Illustrative location object:

```json
{
  "place_id": "provider_place_id",
  "label": "Display address",
  "latitude": 0.0,
  "longitude": 0.0,
  "source": "search",
  "address_components": {
    "locality": "City",
    "area": "Area",
    "country": "Country"
  }
}
```

This is a suggested client model, not a confirmed backend schema.

### States

Empty fields, typing/searching, suggestions, no results, permission denied, GPS unavailable, network error and selected location outside service area.

## 7. RIDE-02: Map Location Picker

**Purpose:** Let the customer precisely place or adjust pickup or destination.

### Layout

- Full-screen map.
- Search bar at top.
- Fixed centre pin or draggable marker.
- Current-location control.
- Address confirmation panel at bottom.
- Confirm Location CTA.

### Suggested dimensions

| Component | Dimensions |
|---|---|
| Map | Remaining screen height |
| Search bar | 52-56 dp |
| Map controls | 44-48 dp |
| Bottom confirmation panel | 150-210 dp |
| Confirm button | 50-54 dp |
| Bottom panel radius | 20-24 dp top corners |

### Interactions

- Pan and zoom map.
- Move map under a fixed pin, or drag pin, depending on selected interaction model.
- Reverse geocode selected coordinate.
- Show resolved address in bottom panel.
- Confirm returns the location to the previous screen.
- Current-location control recentres map when permission is available.
- Search on map and select a suggestion.
- Do not save an address unless the customer explicitly chooses Save.

### Data and technical requirements

- Map rendering provider.
- Geocoding and reverse-geocoding provider.
- Optional service-area boundary lookup.
- Coordinates, resolved address and place ID.
- Map provider key restricted by platform/app identifier.

Map selection does not create a booking. The selected coordinate must be used in the quote request. If map tiles fail, provide address search and retry where possible.

## 8. RIDE-03: Route Preview and Serviceability

**Purpose:** Show the route and establish whether the journey can be served.

### Layout

- Map with pickup and destination markers.
- Route line.
- Pickup and destination labels.
- Approximate distance and journey duration, if supplied.
- Serviceability message.
- Continue action.

### Suggested dimensions

| Component | Dimensions |
|---|---|
| Map region | 45-60% of usable height |
| Route summary panel | 160-220 dp |
| Location rows | 44-56 dp each |
| Status banner | 44-64 dp |
| CTA | 50-54 dp |

### Interactions and rules

- Customer can edit pickup or destination.
- Map can be panned and zoomed.
- Continue only when route is serviceable and the required check succeeds.
- If route is not serviceable, explain and offer location editing.
- If route calculation fails, allow retry.

### Data requirements

Route distance/duration, service-area coverage, ride availability, quote eligibility inputs and selected coordinates. Backend serviceability is authoritative. A client-side boundary check may improve responsiveness but cannot be the final decision.

## 9. RIDE-04: Ride Options

**Purpose:** Present eligible ride categories where multiple categories exist.

This screen is conditional. If only one category exists in the service area, Product may skip this screen and proceed to fare review.

### Layout

1. Top bar and route summary.
2. Heading: Choose your ride.
3. Eligible ride category cards.
4. Each card: icon/image, category name, description/capacity, estimated fare and pickup time if available.
5. Bottom selection summary and Continue CTA.

### Suggested dimensions

| Component | Dimensions |
|---|---|
| Route summary | 72-96 dp |
| Ride option card | 84-112 dp |
| Card padding | 12-16 dp |
| Vehicle image/icon | 44-56 dp |
| Fare label | 18-22 sp |
| Continue button | 50-54 dp |

### Interactions and data

- Select one eligible category.
- Selected card has clear border/colour and accessibility state.
- Changing category requests a new quote if category affects price.
- Continue disabled until valid selection.
- Do not show unavailable categories as selectable.
- Do not invent capacity, vehicle type or fare data.

Data fields: category ID, name, description, icon/image, passenger capacity or approved attributes, service-area availability, pricing reference, estimated pickup time and eligibility restrictions.

## 10. RIDE-05: Fare and Payment Review

**Purpose:** Let the customer review the quote and choose how to pay.

### Layout and hierarchy

1. Route summary.
2. Selected ride category.
3. Fare estimate and breakdown.
4. Coupon entry.
5. Eligible ride-wallet credit.
6. Points redemption, only if enabled.
7. Payment method selection.
8. Final amount due.
9. Continue CTA.

The final payable amount is the most prominent content. Quote validity, payment selection, discounts and detailed fare components follow.

### Suggested dimensions

| Component | Dimensions |
|---|---|
| Route summary card | 80-110 dp |
| Fare summary card | 120-180 dp |
| Fare row | 32-40 dp |
| Coupon field | 52-56 dp |
| Wallet option row | 56-68 dp |
| Payment method row | 60-72 dp |
| Final payable panel | 76-100 dp |
| CTA | 50-54 dp |

### Fare display

The backend may return configured components such as base fare, distance charge, time charge, approved fee/surcharge, discount, eligible wallet credit and remaining payable amount. Only display components returned by the backend. Do not invent a fee line.

### Coupon behaviour

- Customer enters code and taps Apply.
- Backend validates against route, category, customer and campaign rules.
- Show applied, invalid, expired or ineligible state.
- Changing route/category may invalidate coupon.
- Validation alone must not consume the coupon.
- Reserve/consume only at the backend-defined booking transaction point.

### Wallet and points behaviour

- Show only eligible ride-wallet balance.
- Distinguish balance types if the product has more than one.
- Customer selection must stay within backend-provided eligibility and balance.
- Backend calculates final amount.
- Loyalty points are not money. If points redemption is enabled, use the approved redemption flow and show conversion clearly.
- Loyalty-derived ride-wallet credit must not be presented as cash-withdrawable or transferable.

### Payment behaviour

- Show only methods enabled for the customer and booking.
- Payment options may include Paystack-supported methods and eligible ride-wallet credit, subject to final policy.
- If wallet does not cover the full fare, show remaining amount.
- Explain when a secure external checkout step follows.
- Backend/provider webhook confirms payment. Do not trust client redirect as payment proof.

### API requirements

Documented endpoints:

- `POST /api/v1/pricing/quotes`
- `POST /api/v1/coupons/validate`
- `GET /api/v1/wallet`
- `GET /api/v1/loyalty`
- `POST /api/v1/loyalty/redemption-quotes`, if points redemption is enabled.

Quote response should include quote ID, status, currency, amount in minor units, breakdown, expiry, pricing terms, eligible wallet credit and remaining payable amount.

Illustrative response only:

```json
{
  "data": {
    "quote_id": "quote_uuid",
    "status": "valid",
    "currency": "NGN",
    "total_amount_minor": 450000,
    "expires_at": "2026-10-30T13:10:00Z",
    "breakdown": [
      {"code": "base_fare", "label": "Base fare", "amount_minor": 250000},
      {"code": "distance_charge", "label": "Distance", "amount_minor": 200000}
    ],
    "eligible_wallet_credit_minor": 100000,
    "coupon_discount_minor": 0,
    "payable_amount_minor": 350000
  },
  "meta": {"request_id": "req_example"}
}
```

Sample amounts are illustrative, not Go-Volts pricing.

### Financial rules

- Use integer minor units for NGN (kobo).
- Never use floating-point arithmetic for money.
- Client submits selections, not a trusted total.
- Backend recalculates and validates all amounts.
- Payment state is separate from booking state.
- Release wallet/coupon reservations on failed/expired flows according to backend rules.

## 11. RIDE-06: Booking Review and Confirmation

**Purpose:** Give the customer a final chance to verify journey, price and terms.

### Layout

- Pickup and destination.
- Route/ride category.
- Fare and payable amount.
- Payment method.
- Coupon and wallet credit summary.
- Cancellation policy summary.
- Relevant service terms.
- Confirm Ride CTA.

### Suggested dimensions

| Component | Dimensions |
|---|---|
| Location summary | 100-140 dp |
| Ride category summary | 72-96 dp |
| Fare panel | 100-150 dp |
| Policy note | 48-80 dp, content-dependent |
| CTA | 50-54 dp |

### Interactions and API

- Edit pickup/destination returns to location entry and invalidates stale quote.
- Edit payment returns to payment selection.
- Confirm Ride submits booking using valid quote ID.
- Disable CTA during submission.
- Generate a unique idempotency key.
- On timeout, check booking/request status before retrying with a new key.
- Repeated taps must not create duplicate bookings.

Documented endpoint: `POST /api/v1/bookings`.

Illustrative request:

```json
{
  "quote_id": "quote_uuid",
  "booking_type": "ride",
  "pickup": {
    "label": "Pickup address",
    "latitude": 0.0,
    "longitude": 0.0
  },
  "destination": {
    "label": "Destination address",
    "latitude": 0.0,
    "longitude": 0.0
  },
  "ride_category_id": "category_uuid",
  "payment_selection": {
    "method": "paystack",
    "wallet_credit_minor": 0
  },
  "coupon_code": null
}
```

Send an `Idempotency-Key` header. The backend verifies quote ownership/expiry, route, category, availability, price, coupon and payment policy.

Handle: booking created, payment required, quote expired, route unavailable, duplicate request and validation error.

## 12. RIDE-07: Searching for Rider

**Purpose:** Show that the booking has been created and rider matching is underway.

### Layout and dimensions

- Map or branded search illustration: 35-50% of screen.
- Status heading: 22-26 sp.
- Supporting message: 14-16 sp.
- Route summary: 80-110 dp.
- Bottom action panel: 120-170 dp.
- Cancel button: 48-52 dp.

### Behaviour

- Show only after backend confirms booking creation and matching state.
- Display clear searching status.
- Update from backend events or polling.
- Do not invent countdowns or guarantee assignment time.
- Cancellation calls backend and shows actual result.
- No-rider and matching-timeout states have recovery actions.
- Booking expiry must be explained.

Documented endpoints include `GET /api/v1/bookings/{id}` and `POST /api/v1/bookings/{id}/cancel`.

## 13. RIDE-08: Rider Assigned

**Purpose:** Introduce assigned rider and vehicle after dispatch acceptance is confirmed.

### Layout

- Map with pickup point and rider marker.
- Status: Rider assigned.
- Rider profile card.
- Vehicle details.
- Estimated arrival.
- Pickup address.
- Contact options.
- Share trip, Help and safety entry points where enabled.

### Suggested dimensions

| Component | Dimensions |
|---|---|
| Map | 42-58% of usable height |
| Rider card | 112-150 dp |
| Avatar | 48-60 dp |
| Vehicle row | 48-60 dp |
| Contact action | 44-48 dp |
| Bottom panel | 180-240 dp |

### Rider card data

Only backend-authorized fields: rider display name, profile photo, rating if approved, vehicle make/model or description, colour, plate number, ETA and masked call/chat action.

Do not expose rider identity before assignment is committed. Do not expose personal phone numbers when masked contact is available. Update visible assignment if rider is reassigned.

## 14. RIDE-09: Driver Approaching

**Purpose:** Help the customer understand rider location and estimated arrival.

### Layout

- Live map.
- Rider and pickup markers.
- ETA label.
- Rider/vehicle summary.
- Pickup address.
- Contact, share trip and Help actions.

### Behaviour and data

- Show latest authorized rider location.
- Show last-updated time when location is stale.
- ETA must come from routing/dispatch and be treated as an estimate.
- Do not animate a marker as if it were live when updates are unavailable.
- If rider is delayed, show neutral status and support.
- Handle cancellation and reassignment.

Required data: booking status, assigned rider, approved profile, vehicle, rider coordinates/timestamp, pickup coordinates, ETA and ETA update timestamp.

Use selective Supabase Realtime or an authenticated backend WebSocket/SSE gateway. Do not expose public subscriptions to rider location.

## 15. RIDE-10: Active Trip

**Purpose:** Show trip progress, destination context and approved safety/support actions.

### Layout and dimensions

- Map with route/current rider position: 50-65% of usable height.
- Trip status panel: 100-140 dp.
- Destination row: 56-72 dp.
- Compact rider card: 72-100 dp.
- Safety/action touch targets: 48-56 dp.

### Interactions

- Share trip through approved secure sharing flow.
- Help opens support options linked to active booking.
- SOS/emergency control, if enabled, enters approved safety escalation.
- Critical actions require deliberate confirmation to reduce accidental activation.
- Do not encourage phone interaction while vehicle is moving.
- Trip completion is recorded by authorized rider/backend workflow, not customer-side control.

Data: trip status/events, authorized rider location, route/destination, ETA, rider/vehicle display info, safety configuration and last location update.

## 16. RIDE-11: Trip Completed

**Purpose:** Confirm ride completion and show final trip summary.

### Layout

- Completion indicator.
- “Trip completed” message.
- Pickup/destination summary.
- Final amount.
- Payment status.
- View Receipt CTA.
- Rate Trip CTA.

### Behaviour

- Show completed only after backend confirms terminal trip state.
- Final amount comes from finalized trip and ledger data.
- If final fare differs from estimate, explain that this is the final amount and provide breakdown in receipt.
- If payment is pending, show the actual payment state.
- Do not award points locally. Show points only after backend confirms eligibility/credit.

## 17. RIDE-12: Receipt

**Purpose:** Provide a reliable record of completed ride and financial outcome.

Content:

- Go-Volts branding.
- Booking/trip reference.
- Date and time.
- Pickup and destination.
- Ride category.
- Rider/vehicle details where approved.
- Final fare breakdown.
- Coupon/discount.
- Eligible wallet credit applied.
- Payment method.
- Amount paid and payment status.
- Support link.

Receipt values come from finalized trip, payment and ledger records. If data is unavailable, show retry rather than generating an estimated receipt. Sharing/download must use an approved secure implementation.

## 18. RIDE-13: Rate Your Trip

**Purpose:** Collect structured feedback after completion.

### Layout

- “How was your ride?” prompt.
- Rating control.
- Optional feedback tags.
- Optional free-text comment.
- Submit button.
- Skip action if Product allows.

### Interactions

- Rating scale is configured by Product.
- Feedback tags may be configured by backend.
- Validate text length and sanitize input.
- Prevent duplicate submissions.
- Show confirmation after success.
- Link rating to completed booking and authenticated customer.

The rating endpoint must be agreed in OpenAPI. Do not treat an unapproved endpoint as existing.

---

# PART D: BOOKING, PAYMENT AND DISPATCH LOGIC

## 19. Booking lifecycle

The Technical Specification defines this common lifecycle:

```text
draft -> quoted -> awaiting_payment OR ready_for_dispatch
      -> searching_rider -> rider_assigned -> in_progress -> completed
```

Alternative terminal states: `cancelled`, `failed`, `expired`.

For rides, documented transitions include:

- `ready_for_dispatch` after selected payment authorization policy succeeds.
- `rider_assigned` after rider acceptance.
- `rider_arrived` when rider confirms pickup location.
- `in_progress` after passenger pickup confirmation.
- `completed` after trip completion and final fare rules are applied.

Payment status is separate from booking status. Never infer payment success from a client redirect.

### 19.1 Customer-facing status mapping

| Backend state | Suggested customer label |
|---|---|
| `draft` | Preparing your ride |
| `quoted` | Fare ready |
| `awaiting_payment` | Payment required |
| `ready_for_dispatch` | Confirmed |
| `searching_rider` | Finding a rider |
| `rider_assigned` | Rider assigned |
| `rider_arrived` | Rider has arrived |
| `in_progress` | Trip in progress |
| `completed` | Trip completed |
| `cancelled` | Booking cancelled |
| `failed` | Booking unsuccessful |
| `expired` | Booking expired |

Customer labels may differ from internal enums, but mapping must be explicit.

## 20. State transition enforcement

Backend transition logic must check allowed prior state, authorized actor/ownership, required evidence, side effects, emitted event, idempotency and cancellation/refund consequences.

Persist status change, status event and outbox event in one transaction. Use row locks or optimistic version checks to prevent conflicting transitions.

## 21. Cancellation

Customer cancellation is allowed only in states permitted by configured policy.

The app must show applicable cancellation information, explain fees/refund consequences returned by backend, require deliberate confirmation and display actual result. Do not promise a refund before processing is confirmed.

Documented endpoint: `POST /api/v1/bookings/{id}/cancel`.

Cancellation fees and free-cancellation windows are Product/Operations decisions, not hardcoded UI rules.

## 22. Dispatch

The customer app does not implement rider matching. It creates a booking and observes backend state.

Backend/dispatch owns:
- Eligible rider selection.
- Job offers.
- Acceptance.
- Assignment commit.
- Offer expiry and reassignment.
- Rider arrival.
- Customer-safe booking updates.

Customer app handles no riders, rider decline/cancellation, reassignment and expiry.

---

# PART E: API AND DATA REQUIREMENTS

## 23. API conventions

The Technical Specification establishes Supabase Auth, Bearer JWT authentication, backend JWT validation, standard success/error envelopes, OpenAPI 3.1, cursor pagination and idempotency for booking/payment operations.

Do not trust client-supplied user ID or role as proof of access.

## 24. Documented endpoints relevant to Ride

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/api/v1/catalogue/services?lat=&lng=` | Enabled services at a location |
| POST | `/api/v1/pricing/quotes` | Calculate fare quote |
| POST | `/api/v1/bookings` | Create booking from valid quote |
| GET | `/api/v1/bookings/{id}` | Read own booking/status |
| GET | `/api/v1/bookings` | Paginated own booking history |
| POST | `/api/v1/bookings/{id}/cancel` | Request cancellation |
| POST | `/api/v1/bookings/{id}/payment-intents` | Initialize remaining payment |
| GET | `/api/v1/payments/{id}` | Read payment status |
| GET | `/api/v1/wallet` | Ride-credit balance and rules |
| GET | `/api/v1/loyalty` | Points and eligible rules |
| POST | `/api/v1/coupons/validate` | Validate coupon against booking draft |
| POST | `/api/v1/support/tickets` | Create support ticket |

The existing specification does not establish exact endpoints for map autocomplete, route geometry or live rider location. Define those integrations separately or use an approved provider SDK.

## 25. Quote request/response requirements

Quote request should contain pickup/destination coordinates, resolved labels or place IDs where needed, ride category if selected, service type and applicable booking options.

Quote response should include:
- Quote ID and status.
- Currency.
- Total amount in minor units.
- Breakdown items.
- Discount.
- Eligible wallet credit.
- Remaining payable amount.
- Expiry.
- Pricing terms and category context.

The quote belongs to the authenticated customer and journey details. If journey changes, refresh quote.

## 26. Booking creation requirements

Booking creation must require an authenticated customer and valid unexpired quote; validate locations, category, availability, price, coupon and wallet credit; apply payment policy; accept an `Idempotency-Key`; and return booking reference plus authoritative booking/payment state.

Illustrative request only:

```json
{
  "quote_id": "quote_uuid",
  "booking_type": "ride",
  "pickup": {
    "label": "Pickup address",
    "latitude": 0.0,
    "longitude": 0.0
  },
  "destination": {
    "label": "Destination address",
    "latitude": 0.0,
    "longitude": 0.0
  },
  "ride_category_id": "category_uuid",
  "payment_selection": {
    "method": "paystack",
    "wallet_credit_minor": 0
  },
  "coupon_code": null
}
```

The exact request contract must be confirmed in OpenAPI.

## 27. Live update requirements

Use an authenticated booking-scoped update channel, such as selective Supabase Realtime or backend WebSocket/SSE.

Potential events:
- Booking status changed.
- Rider assigned/reassigned.
- Rider arrived.
- Trip started/completed.
- Booking cancelled.
- Payment state changed.

Rider location must be visible only to the assigned customer and only when operationally appropriate.

---

# PART F: CUSTOMER DATA MODELS

## 28. Suggested client view models

- `RideLocation`
- `SavedLocation`
- `RoutePreview`
- `RideCategory`
- `RideAvailability`
- `FareQuote`
- `FareLineItem`
- `CouponValidation`
- `WalletCreditEligibility`
- `PaymentOption`
- `RideBooking`
- `BookingStatusEvent`
- `AssignedRider`
- `AssignedVehicle`
- `RiderLiveLocation`
- `TripSummary`
- `TripReceipt`
- `TripRating`

These are proposed client model names, not exact database table names.

### 28.1 Key fields

**RideLocation:** label, latitude, longitude, provider place ID, address components and source.

**FareQuote:** quote ID, currency, total minor units, breakdown, discount, wallet credit, payable amount, expiry and status.

**RideBooking:** booking ID/reference, pickup/destination snapshots, category, quote reference, booking state, payment state/reference, timestamps and cancellation metadata.

**AssignedRider:** rider ID, approved display name, permitted profile image/rating and masked contact route.

**AssignedVehicle:** vehicle description, colour, registration/plate display and approved attributes.

**BookingStatusEvent:** event ID, booking ID, prior/new state, actor type, timestamp and customer-safe message.

---

# PART G: RESPONSIVE BEHAVIOUR

## 29. Breakpoints

| Width | Layout |
|---|---|
| Below 360 dp | Compact phone |
| 360-599 dp | Standard phone |
| 600-839 dp | Expanded/tablet |
| 840 dp and above | Wide tablet |

Validate against supported devices.

## 30. Compact phones

- Use 16 dp margins if 20 dp crowds the layout.
- Use full-width location inputs and bottom panels.
- Keep one clear primary CTA.
- Keep map controls clear of system gestures and bottom sheets.
- Use scrollable panels when content exceeds height.
- Prevent fare/status text from sitting under system navigation.

## 31. Standard phones

- Use 20 dp horizontal margins.
- Use full-screen map with a bottom sheet for location/fare details.
- Keep primary action fixed at bottom where practical.
- Make pickup/destination and final fare easy to review.
- Make switching between map and form straightforward.

## 32. Tablets

- Do not stretch phone cards to full width.
- Centre content or use a map-and-details split layout.
- Put map on larger side and location/route/fare panel in a constrained side column.
- Set maximum width for forms/cards.
- Preserve the same content hierarchy.

## 33. General responsive rules

- Use `LayoutBuilder` and shared responsive utilities.
- Respect safe areas and system insets.
- Use flexible constraints, not device-name checks.
- Support keyboard resize and scroll-to-focused-field.
- Support text scaling.
- Avoid fixed-height containers around long addresses/errors.
- Maintain 48 x 48 dp minimum touch targets.
- Test landscape, long place names, large text and map-control overlap.

---

# PART H: PERMISSIONS, LOCATION AND PRIVACY

## 34. Location permission strategy

The concept note says permissions should be explained in context, not requested immediately at first launch.

For Ride:
1. Explain why location helps set pickup.
2. Request foreground location permission when customer chooses current location.
3. If denied, allow manual search and map selection.
4. If permanently denied, explain how to open device settings without blocking manual entry.
5. Request background location only if a separately approved requirement needs it.

## 35. Privacy requirements

- Collect only location data needed for ride experience.
- Do not expose rider/customer personal data beyond the booking relationship.
- Do not expose rider location to customers not assigned to that rider.
- Secure trip-sharing links and limit their scope/duration.
- Restrict receipt and booking access to owner or authorized support roles.
- Apply retention policy to location history and trip events.

---

# PART I: LOADING, ERROR AND EXCEPTION STATES

## 36. Required states

| Situation | Expected behaviour |
|---|---|
| Location search loading | Suggestions skeleton/loading |
| No location results | Explain and allow another search |
| GPS unavailable | Offer manual search |
| Route calculation loading | Show progress |
| Route not serviceable | Explain and allow location changes |
| Quote loading | Fare skeleton; disable continue |
| Quote expired | Refresh and request review |
| No ride category | Explain no eligible options |
| Coupon invalid | Show concise reason; allow removal |
| Wallet credit unavailable | Explain without blocking other payment |
| Payment pending | Show pending and recheck backend |
| Payment failed | Retry or choose another method |
| Booking request timeout | Check idempotent request status before retry |
| No riders available | Explain and offer retry/cancel |
| Rider cancelled | Show reassignment/recovery |
| Rider location stale | Show last updated; do not fake movement |
| Network lost | Show connection notice and retry/reconnect |
| Booking expired | Explain and start new request |
| Trip interrupted | Show support/incident options |
| Emergency action | Enter approved emergency process |

Error messages should say what happened and what the customer can do next. Avoid stack traces, raw provider errors and unconfirmed refund/assignment promises.

---

# PART J: FLUTTER IMPLEMENTATION

## 37. Suggested feature structure

```text
features/
└── ride/
    ├── data/
    │   ├── datasources/
    │   ├── dto/
    │   ├── repositories/
    │   └── providers/
    ├── domain/
    │   ├── entities/
    │   ├── repositories/
    │   └── usecases/
    └── presentation/
        ├── screens/
        ├── widgets/
        └── providers/
```

Screen files may include location entry, map picker, route preview, options, fare/payment, review, searching, assigned, approaching, active, completed, receipt and rating.

## 38. State management

Use Riverpod and typed immutable state. Separate:
- Location search.
- Selected pickup/destination.
- Map selection.
- Route/serviceability.
- Ride category.
- Quote.
- Coupon/wallet/payment selection.
- Booking submission.
- Booking status/live updates.
- Rider location.
- Completion/receipt.

Do not put the entire workflow in one unstructured widget state or place API calls inside build methods.

## 39. Suggested routes

| Screen | Proposed route |
|---|---|
| Location entry | `/ride/locations` |
| Map picker | `/ride/location-picker` |
| Route preview | `/ride/route` |
| Ride options | `/ride/options` |
| Fare/payment | `/ride/fare` |
| Booking review | `/ride/review` |
| Searching | `/ride/:bookingId/searching` |
| Assigned | `/ride/:bookingId/assigned` |
| Approaching | `/ride/:bookingId/approaching` |
| Active trip | `/ride/:bookingId/active` |
| Completed | `/ride/:bookingId/completed` |
| Receipt | `/ride/:bookingId/receipt` |
| Rating | `/ride/:bookingId/rating` |

These route names are proposals. Align them with final `go_router` setup.

If app closes/restarts during a booking, reload authoritative booking state from backend. Do not rely only on in-memory navigation state.

---

# PART K: SCREENSHOT DESIGN PLAN

## 40. Image generation sequence

Create screen screenshots in this order:

### Group 1: Journey setup
1. Pickup and Destination Entry
2. Map Location Picker
3. Route Preview and Serviceability

### Group 2: Ride selection and fare
4. Ride Options
5. Fare and Payment Review
6. Booking Review and Confirmation

### Group 3: Dispatch and trip
7. Searching for Rider
8. Rider Assigned
9. Driver Approaching
10. Active Trip

### Group 4: Completion
11. Trip Completed
12. Receipt
13. Rate Your Trip

Each screenshot should show one screen clearly or a small related group. Use the dark green/charcoal theme with vivid green CTAs, consistent status bar, safe areas, typography, spacing and navigation. Use illustrative sample data, not claims about actual fares or live riders. Avoid tiny text and crowded collages. Include important loading/error/disabled states where they materially change the design.

---

# PART L: QA AND ACCEPTANCE

## 41. Functional checklist

### Location and route
- [ ] Customer can enter pickup and destination.
- [ ] Customer can search and select suggestions.
- [ ] Customer can use saved locations.
- [ ] Customer can select a point on map.
- [ ] Manual entry works when location permission is denied.
- [ ] Customer can swap locations.
- [ ] Changing either location invalidates previous quote.
- [ ] Backend confirms route serviceability.

### Ride options and quote
- [ ] Only eligible categories are shown.
- [ ] Category selection refreshes quote when needed.
- [ ] Quote is server-generated.
- [ ] Quote expiry is enforced.
- [ ] Fare breakdown matches backend.
- [ ] Coupon validation is server-side.
- [ ] Wallet credit eligibility is server-side.
- [ ] Money uses integer minor units.

### Booking and payment
- [ ] Booking references valid quote.
- [ ] Booking creation is idempotent.
- [ ] Repeated taps do not create duplicate bookings.
- [ ] Timeout checks status before retry.
- [ ] Payment and booking states are separate.
- [ ] Client redirect is not treated as payment proof.
- [ ] Cancellation policy is displayed and backend-enforced.

### Dispatch and live trip
- [ ] Searching appears only after booking creation is confirmed.
- [ ] Rider details appear only after assignment.
- [ ] Reassignment updates customer view.
- [ ] Rider location is scoped to assigned booking.
- [ ] Stale location is handled honestly.
- [ ] Arrival and trip-start statuses are correct.
- [ ] Active trip exposes approved safety/support actions.
- [ ] Completion is backend-authoritative.

### Completion and responsive
- [ ] Final fare uses finalized trip/ledger data.
- [ ] Receipt matches payment/ledger records.
- [ ] Rating links to completed booking.
- [ ] Duplicate rating is prevented.
- [ ] Compact phone, standard phone and tablet layouts work.
- [ ] Large text and keyboard do not cause clipping.
- [ ] Touch targets meet minimum size.
- [ ] Status is not communicated by colour alone.

## 42. Definition of done

The Ride flow is ready for detailed screenshot design and engineering handoff when:

1. Product approves the end-to-end ride journey.
2. Ride categories and service-area rules are confirmed.
3. Fare/payment policy owners approve quote and checkout behaviour.
4. Cancellation policy is defined.
5. Map/location provider decision is confirmed.
6. API contracts cover quote, booking creation, cancellation, booking detail and live updates.
7. Realtime authorization and rider-location privacy rules are defined.
8. All screen states have a design treatment.
9. Design screenshots are reviewed against this specification.
10. QA covers normal, failure and exceptional journeys.

---

# PART M: PRODUCT DECISIONS TO CONFIRM

## 43. Open decisions

| Decision | Why it matters |
|---|---|
| Ride categories at launch | Determines Ride Options screen/pricing |
| Skip options screen for one category? | Determines navigation |
| Can pickup be outside service area? | Determines validation |
| Must destination be in same service area? | Determines route eligibility |
| Exact quote validity duration | Determines expiry UX |
| Fare components/surcharge rules | Determines fare breakdown |
| Payment authorization policy | Determines dispatch start |
| Can wallet credit combine with external payment? | Determines checkout |
| Is points redemption enabled for rides? | Determines loyalty control |
| Coupon reservation/consumption point | Prevents duplicate/lost coupon |
| Cancellation windows/fees | Determines cancellation UX |
| No-rider retry policy | Determines recovery state |
| Rider contact method | Determines call/chat integration |
| Trip share availability/link expiry | Determines safety UX |
| SOS availability/escalation destination | Determines emergency UX |
| Live location update frequency | Affects map and battery/network |
| Rating scale/feedback tags | Determines rating screen |
| Can customer add a stop or edit destination after booking? | Affects pricing/state complexity |

## 44. Source-derived requirements vs proposed decisions

### Source-derived
- Ride screens include pickup/destination, map selection, fare estimate, ride options where applicable, confirmation, matching, rider assignment, approaching, active trip, completion, rating and receipt.
- Ride UI includes map, locations, saved locations, pin, fare breakdown, payment selector, coupon, eligible wallet balance, points redemption where enabled, cancellation policy and safety controls.
- Backend generates pricing quotes.
- Booking creation uses a valid quote and idempotency.
- Payment state is separate from booking state.
- Rider information is shown after confirmed assignment.
- Trip sharing and SOS are available when enabled.
- Receipts use finalized trip and ledger data.
- Booking and dispatch state transitions are backend-controlled.

### Proposed in this document
- Screen IDs and route names.
- Component dimensions, spacing and typography.
- Dark-green token values.
- Conditional screen grouping/skipping.
- Illustrative request/response examples.
- Suggested Flutter feature structure and client view-model names.
- Suggested map/form and tablet layouts.

Confirm proposed items with Product and Engineering before treating them as fixed requirements.

---

**End of document.**
