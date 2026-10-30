# Go-Volts Customer App Prototype: Screen Flow Guide

**Purpose:** Explain the proposed customer-app screen journeys shown in the accompanying Go-Volts design boards.

**Brand direction:** Premium, clean mobility experience using dark green, black, white, and bright lime-green accents. The images are concept presentation boards generated to communicate the screen layout and flow. They are not screenshots exported directly from the editable Figma file, and they do not represent a tested interactive prototype.

## Image boards

- `01_go_volts_ride_booking_flow.png`  
  Main ride-booking journey: Home Dashboard → Set Locations → Choose a Ride → Payment Method → Finding a Rider.
- `02_go_volts_service_and_scheduled_pickup_overview.png`  
  Broader overview of onboarding, service discovery, parcel delivery, and scheduled pickup/school-run concepts. This is a reference board with multiple flow sections, not a strict five-screen board.
- `03_go_volts_ride_booking_alternate_overview.png`  
  Alternate ride-booking concept board for comparing the visual direction and key states. This is a reference board, not a strict five-screen board.

## 1. Main ride-booking flow

### Screen 1: Home Dashboard
**Goal:** Give customers a clear starting point for all major services.

Key elements:
- Destination search
- Ride, Deliver, Scheduled Pickup, and Top Up shortcuts
- Saved places and recent activity
- Bottom navigation for Home, Trips, Wallet, and Account

**User action:** The customer taps Ride or enters a destination.

**Next:** Set Your Locations.

### Screen 2: Set Your Locations
**Goal:** Capture the route before presenting ride choices.

Key elements:
- Pickup location
- Drop-off location
- Map and route preview
- Optional additional stop
- Confirm Locations button

**User action:** The customer confirms pickup and destination details.

**Next:** Choose a Ride.

### Screen 3: Choose a Ride
**Goal:** Help the customer compare service levels before committing.

Key elements:
- Available ride classes such as Bike, Plus, Comfort, and XL
- Indicative fare and estimated arrival/time details
- Optional rider note
- Continue to Payment button

**User action:** The customer selects a suitable ride option.

**Next:** Payment Method.

### Screen 4: Payment Method
**Goal:** Make the expected cost and payment choice clear before booking.

Key elements:
- Trip summary and route distance
- Fare breakdown and total
- Wallet, card, and bank-transfer options
- Optional promo code
- Confirm & Book button

**User action:** The customer reviews the fare, chooses a payment method, and confirms the booking.

**Important:** Any amounts shown in the concept images are illustrative design content only. They must not be treated as approved Go-Volts fares or live quotes. A production app should use a server-calculated quote and clearly handle payment success, failure, and pending states.

**Next:** Finding a Rider, then Driver Assigned / Live Tracking when a driver accepts.

### Screen 5: Finding a Rider
**Goal:** Confirm that the booking is being matched and communicate its current status.

Key elements:
- Search/matching status
- Clear progress states
- Cancel booking option before assignment, subject to the cancellation policy

**User action:** The customer waits for matching or cancels if permitted.

**Next:** Driver Assigned & Live Tracking. Once assigned, show driver details, vehicle information, estimated arrival, contact options, safety tools, and trip sharing as appropriate.

## 2. Parcel delivery flow

1. **Package details:** Customer chooses a package category and provides a concise description.
2. **Sender and recipient:** Capture pickup, recipient contact, and delivery address details.
3. **Delivery option:** Show eligible service levels, estimated delivery windows, and a quote.
4. **Payment:** Customer reviews the total and completes the selected payment flow.
5. **Tracking and proof of delivery:** Show delivery status milestones and, where supported, proof of delivery.

**Design principle:** Keep delivery status understandable without exposing more personal information than is needed. Validate recipient contact and address information before dispatch.

## 3. Scheduled Pickup and school-run flow

Scheduled Pickup is not the same as an instant ride. It needs a plan request, operations review, quote, payment, and activation states.

1. **Choose plan type:** One-off future trip, recurring plan, or school run.
2. **Plan details:** Capture pickup/drop-off locations, days, times, frequency, and relevant passenger or guardian details.
3. **Schedule:** Review the requested days and pickup/drop-off times.
4. **Submit for review:** The request enters an operations review queue. It is not active yet.
5. **Review and quote:** Operations confirms feasibility and issues a quote.
6. **Await approval / payment:** After approval, show the quote and the payment deadline.
7. **Payment and activation:** The plan activates only after the payment provider confirms successful payment. Do not mark a plan active based only on a client-side success screen.
8. **Plan management:** Show active status, upcoming trips, plan details, renewal actions, and permitted skip/cancel actions.
9. **Trip status:** Show each scheduled trip's status and driver assignment when available.
10. **School-run handover:** Show clear milestones such as pickup confirmed, on the way, and drop-off confirmed. Use verified parent/guardian and authorised-recipient records plus the agreed handover protocol.

### Scheduled-plan business rules to preserve
- A submitted plan must remain **Pending Review** until operations reviews it.
- The customer receives a quote only after review.
- The quote has a 48-hour payment window, as specified in the product requirements.
- The plan becomes active only after verified successful payment.
- Renewal is manual unless a later product decision explicitly changes this.
- Skip requests close 6 hours before the scheduled pickup.
- The no-show waiting period is 10 minutes.
- One-way and round-trip legs are treated as separate entitlements.
- School-run safeguards include a verified parent/guardian, an authorised recipient, and a documented handover protocol.
- Baseline school-run flow uses milestone notifications; continuous live GPS tracking is not required.

## 4. Recommended prototype links

When wiring the editable Figma prototype, connect these primary actions:

- Home Dashboard → Set Your Locations
- Set Your Locations → Choose a Ride
- Choose a Ride → Payment Method
- Payment Method → Finding a Rider
- Finding a Rider → Driver Assigned / Live Tracking
- Home Dashboard → Parcel Delivery Booking
- Home Dashboard → Scheduled Pickup
- Scheduled Pickup → Plan Review / Quote → Payment → Plan Management
- Plan Management → Upcoming Trip → School-Run Handover Status
- Home Dashboard → Wallet, Rewards & Referrals, and Trip History

Use a back action on secondary screens and provide clear empty, loading, error, payment-pending, payment-failed, and successful states where relevant.

## 5. Presentation notes

- These are visual concept boards, not a final specification of every screen.
- Text, names, maps, prices, driver profiles, and addresses in the generated images are illustrative placeholders.
- Replace sample content with approved product copy and verified data before implementation.
- Use the editable Figma file as the source for future design refinement; the boards are presentation aids.
