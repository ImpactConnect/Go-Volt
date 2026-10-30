# Go-Volts Customer App

## Detailed Screen Specifications and Interactive Prototype Flow

**Version:** 1.0 \| **Status:** UX specification draft \| **Brand:**
Cleaner Rides. Brighter Future. / Same Streets. Built for Comfort.

## 1. Purpose and scope

This document converts the approved Go-Volts visual direction into a
practical customer-app specification for Figma design and prototyping.
It covers authentication, Home, location search, rides, parcel delivery,
Scheduled Pickup, wallet and rewards, notifications, account, safety and
support. It is a UX handoff document, not an editable Figma file or
production application.

Prices, availability, eligibility, fees, loyalty conversion values and
policy outcomes must come from approved backend configuration. Do not
hardcode them into UI designs.

## 2. Brand and design foundations

### Visual direction

Use the supplied logo and campaign art as the brand reference. The UI
should feel energetic, premium, safe and locally relevant: - Deep green
and near-black hero surfaces. - Bright green primary actions and
selected states. - White/light cards for operational content. - Green
gradients, restrained glossy highlights, layered shadows and occasional
3D illustrations. - Clear maps, timelines and status chips. - Reserve
rich 3D art for hero/promo areas. Keep forms, payment, maps and safety
screens uncluttered.

Do not place long text on busy artwork. Use a solid or dark translucent
surface behind text when necessary.

### Suggested design tokens

These are proposed starting values based on the supplied visual
direction; confirm against original brand assets before final handoff.

  Token             Suggested value   Use
  ----------------- ----------------- --------------------------------------
  Brand Green       `#00C853`         Primary actions, active icons
  Deep Green        `#064E3B`         Headers, dark surfaces
  Lime Highlight    `#A7F432`         Selected accents, progress
  Accent Green      `#22D17A`         Success, secondary emphasis
  Near Black        `#0B0F0D`         Dark surfaces, primary text on light
  Deep Slate        `#1F2937`         Secondary neutral
  Soft Background   `#F3F6F4`         App canvas
  White             `#FFFFFF`         Cards, text on dark
  Error             `#DC2626`         Errors/destructive actions
  Warning           `#F59E0B`         Pending/attention
  Info              `#2563EB`         Informational statuses

Typography: Poppins or a similarly legible geometric sans-serif, subject
to licensing and rendering. Define Display, H1, H2, H3, Body, Body
Small, Label, Caption and Button styles. Use an 8-point spacing system,
readable contrast, platform safe areas, text scaling and minimum 44 × 44
logical-pixel tap targets where practical. Format currency as `₦` and
dates/times consistently for the selected locale.

### Reusable components

-   `GVTopBar`: back, title, optional help/action.
-   Primary, secondary, outlined and destructive buttons.
-   `GVServiceCard`: icon/illustration, title, description, chevron.
-   `GVLocationField`: pickup/drop-off, saved-place shortcut,
    validation.
-   `GVMapPanel`: map, route line, markers, recenter.
-   `GVPriceBreakdown`: fare, fees, discounts, total and estimate label.
-   `GVPaymentMethodRow`: enabled payment methods.
-   `GVStatusChip`: Pending, Active, Assigned, Delayed, Completed,
    Cancelled.
-   `GVTripCard`, `GVDriverCard`, `GVTimeline`.
-   `GVEmptyState`, `GVErrorState`, `GVOfflineBanner`,
    `GVConfirmationSheet`.
-   `GVPromoBanner`, `GVBottomNavigation`, `GVFormField`,
    `GVLoadingSkeleton`.

Every interactive component should define relevant default, pressed,
focused, disabled, loading, success and error states. Do not communicate
status through colour alone.

## 3. Navigation architecture

Bottom navigation: - **Home:** services, search, recent places and
active activity. - **Trips:** active, upcoming and past ride/delivery
trips. - **Plans:** recurring/school-run plans, quotes, subscriptions
and entitlements. - **Wallet:** balance, top-ups, transactions and
eligible ride-wallet credits. - **Account:** profile, addresses, payment
methods, authorised contacts, settings and support.

Hide the bottom bar during full-screen authentication and selected
focused checkout/safety flows. Preserve valid form input when navigating
back unless the user explicitly discards it.

Global interaction rules: - Require authentication for booking, payment,
wallet and plan management. - Ask for location permission in context;
manual search and map-pin selection must remain possible if denied. -
Never show a blank screen: provide loading, empty, offline or
recoverable error states. - Disable repeated taps during consequential
requests and use idempotency for booking/payment operations. - Confirm
before destructive actions. - Never present a driver, fare, ETA, payment
or booking as confirmed until the backend confirms it. - Explain
estimates and show final pricing before the customer commits.

## 4. Detailed screen specifications

### A. Authentication and onboarding

**A01 Splash** - Logo, tagline, dark-green gradient, subtle motion. -
Check session, version/maintenance and network; route to Home or
Welcome. - Include startup failure/update states; respect reduced-motion
settings.

**A02 Welcome** - Brand headline, concise benefits, 3D rider
illustration, `Get started`, `Sign in`. - Get started → A03; Sign in →
A04.

**A03 Create account** - Full name, phone, optional email if supported,
password, terms/privacy consent. - Validate required fields and
phone/password formats. Preserve valid inputs. - Handle existing phone,
invalid input, network error and rate limits.

**A04 Login** - Approved identifier and authentication method; login,
forgot password, create account. - Handle invalid credentials, rate
limiting, offline and expired session.

**A05 OTP verification** - Masked destination, code input, resend
countdown, change number. - Limit attempts/resends; never log OTP.
Handle incorrect, expired and resend states.

**A06 Profile setup** - Name and optional profile image/contact
details. - Allow optional steps to be skipped; show upload
progress/failure.

**A07 Location permission** - Explain why location helps pickup
accuracy. - Enable location, Not now, or open settings if previously
denied. - Manual location entry remains available.

### B. Home and location

**H01 Home dashboard** Layout: branded top bar and notification badge;
greeting; "Where are you going?" search; Ride, Deliver and Scheduled
Pickup cards; quick actions for wallet/upcoming trips/plans; active
trip/plan card; recent places/activity; optional dismissible promo;
bottom navigation. - Search → H03; Ride → R01; Deliver → D01; Scheduled
Pickup → SP01. - Active trip → trip detail/tracking; active plan → SP11;
notifications → H06. - First-time, returning, active-booking,
no-activity, loading, offline and service-unavailable states.

**H02 Service selector** - Ride, Deliver and Scheduled Pickup cards with
clear descriptions. - Hide/disable unsupported services in the current
service area with an explanation.

**H03 Location search** - Search input, current location, saved/recent
places and Home/Work labels if configured. - Support no-results,
permission-denied, offline and failed-search states. - Distinguish
GPS-derived location from manually entered address.

**H04 Map location picker** - Map, draggable pin, search, recenter
control and address confirmation card. - Validate service area and
resolve ambiguous addresses before continuing.

**H05 Saved places** - Add/edit/delete Home, Work, School or custom
place. - Confirm deletion if a future plan depends on the saved address.

**H06 Notifications** - Filters: All, Trips, Plans, Payments and Offers
only if supported. - Message, timestamp, linked object, read/unread
status and deep link. - Empty/error states. Avoid exposing sensitive
child/payment details on lock-screen previews by default.

**H07 Trips overview** - Active, Upcoming and Past tabs; cards show
date/time, route, service and status. - Open details, track active trip,
manage eligible future trip, view receipt. - Empty, loading and
fetch-failure states.

### C. Ride booking

**R01 Pickup and destination** - Pickup, destination, map preview,
saved/recent places; optional stops only if supported. - Validate
required locations, duplicate route and supported service area.

**R02 Ride options** - Only backend-returned ride classes; fare/ETA
estimates, capacity/features. - Label estimates clearly; never invent
availability or guaranteed arrival times.

**R03 Fare details** - Base fare, distance/time components where
applicable, fees, discounts, total estimate and policy link. - Apply
coupon; recalculate and validate with backend.

**R04 Payment method** - Wallet, card, bank transfer or other methods
only when enabled. - Show available wallet balance and amount due.
Handle insufficient funds and unavailable provider.

**R05 Confirm ride** - Route, ride type, pickup notes, final quoted
amount, payment method and cancellation policy. - Explicitly distinguish
immediate ride from future one-off trip.

**R06 Finding driver** - Searching state and cancel option where policy
allows. - No-driver, retry and cancellation outcomes; do not display
fake driver/ETA.

**R07 Driver assigned** - Approved display name/photo if available,
vehicle/registration details where required, rating if available, pickup
ETA, call/message and safety actions. - Minimise exposed personal data.

**R08 Live tracking** - Map, route, driver card, ETA if available,
last-updated time, support/safety shortcut. - Handle stale GPS,
connection loss, delay and reassignment.

**R09 Driver arrived/pickup** - Arrival status, pickup instructions,
contact and report issue. - Do not infer pickup solely from geofence if
explicit confirmation is required by policy.

**R10 Trip in progress** - Destination, route/ETA where available, share
trip, support and safety options.

**R11 Trip completed** - Final fare, payment status, receipt, rating and
feedback. - Do not imply payment is settled if it is still pending.

**R12 Cancellation** - Reason list, applicable policy and any
backend-confirmed fee before final confirmation. - Confirm or keep trip;
show final status.

**R13 Ride issue/dispute** - Issue category, trip reference, description
and optional attachment if supported. - Show case reference and prevent
duplicate case submissions on retry.

### D. Parcel delivery

**D01 Package details** - Pickup/drop-off, package category, size/weight
where required, description and handling instructions. - Link to
restricted-item policy; validate operational eligibility.

**D02 Sender details** - Sender name/phone, prefilled from profile where
appropriate, edit option.

**D03 Recipient details** - Recipient name/phone, delivery instructions,
save contact only with consent. - Validate required fields and phone
format.

**D04 Delivery option and quote** - Available delivery option, reliable
delivery window if available, price breakdown and restrictions. - Do not
promise insurance or delivery time unless genuinely offered.

**D05 Payment** - Total, method and `Pay and request delivery`. - Handle
processing/success/failure/unknown state. Reconcile uncertain payments
before retrying to prevent duplicate orders.

**D06 Rider assignment** - Awaiting assignment, assigned, delayed, no
rider and cancellation states.

**D07 Pickup confirmation** - Rider arrival and package handover status;
support contact. - Evidence requirements must match operational policy.

**D08 Live tracking** - Map and timeline: assigned, approaching pickup,
picked up, en route, delivered/exception. - Handle stale location,
delay, reassignment and offline connection.

**D09 Proof of delivery** - Timestamp, approved proof type, receipt and
report-problem action. - Restrict access and apply evidence retention
policy.

**D10 Delivery exception** - Recipient unavailable, address issue,
package rejected or rider unable to complete. - Show approved next steps
and contact operations/support. Do not promise redelivery/refund until
eligibility is confirmed.

### E. Scheduled Pickup

Scheduled Pickup supports one-off future trips, recurring plans and
school-run plans. Each leg of a round trip is a separate trip and
entitlement unless approved package terms explicitly state otherwise.

**SP01 Landing** - Explain one-off, recurring and school-run options;
show active plan summary if any. - Actions: book one-off, create plan,
view plans.

**SP02 Choose plan type** - One-off future trip, recurring plan,
school-run plan. - School-run plan requires verified parent/guardian
ownership and passenger profile.

**SP03 Journey details** - Pickup/destination, one-way/round trip,
passenger details and instructions. - Validate route/service area and
school-run requirements.

**SP04 Schedule** - Start/end dates where applicable, weekdays, pickup
time, return time if selected, calendar exceptions if supported. - Never
create return leg implicitly. Show that each leg is separately
priced/entitled unless terms say otherwise.

**SP05 Package and pricing** - Fixed weekly/monthly package with defined
trip entitlement or pay-per-scheduled-trip where enabled. Unlimited
packages are not baseline. - Show period, included trips, exclusions,
expiry, total and published skip/cancel/refund terms. - Never infer
refund formula by dividing package price by trip count.

**SP06 Submit recurring plan request** - Route, schedule, package,
passenger details, quote/terms and policy links. - Submit for operations
review. Submission is not approval or activation.

**SP07 Pending review** - Status, reference, submitted details and SLA
wording only if approved. - Support/withdraw option only if policy
permits. Notify on status change.

**SP08 Approved quote** - Approved details, amount, issue timestamp,
explicit expiry and time remaining. - Payment deadline is 48 hours from
quote issue. Backend controls expiry. - Late payment must revalidate
availability before activation.

**SP09 Payment and activation** - Exact amount, method, quote deadline
and terms. - Plan activates only after approval and verified successful
payment. Handle processing, failure, pending verification and expired
quote idempotently.

**SP10 Plan activated** - Active status, route, schedule, package,
entitlement balance, expiry/renewal and next trip. - Actions: view
schedule, manage plan, calendar export if supported.

**SP11 Subscription details** - Status, route, package, entitlements,
payment history, renewal/expiry, skip cutoff and policies; authorised
contacts for school runs. - Edit eligible fields, pause/resume, manage
contacts, view trips or cancel. - Pricing/policy changes must not
silently alter a paid agreement.

**SP12 Trip schedule** - Upcoming/Past tabs; date/time, route, leg,
driver assignment and entitlement status. - Open details or manage when
eligible; handle no trips and pending assignment.

**SP13 Scheduled trip details** - Date/time, route, leg, status,
assigned driver only when confirmed, entitlement/payment state and
cutoff. - Manage trip or contact operations.

**SP14 Skip trip** - Show trip, cutoff timestamp and exact entitlement
consequence. - Baseline cutoff: 6 hours before pickup. At/before cutoff
preserves entitlement; late skip forfeits it subject to published
exceptions. - Backend validates cutoff; client clock is not
authoritative.

**SP15 Change schedule/address** - Current/proposed values, effective
date and operational impact. - Submit change; show pending, approved or
rejected-with-reason. - Operational/pricing changes may require
approval.

**SP16 Pause/resume** - Show effects on trips, entitlement, expiry and
billing according to package terms. - Never assume pause extends expiry
unless policy says so.

**SP17 Cancel plan** - Reason, effective date, remaining trips and
policy-derived refund/credit explanation. - Use published
pro-rata/contract formula. Approved refunds should be initiated within
1--3 business days after approval; this is an initiation target, not
bank settlement guarantee. Higher-value/exceptional refunds may require
second approval.

**SP18 Driver assignment/service exception** - Awaiting assignment,
driver unavailable/reassigned, delay or service cannot be fulfilled. -
Show time to pickup and support/operations route.
Assignment/offer/escalation windows are configurable. - If Go-Volts
cannot fulfil, apply the correct entitlement restore, wallet credit or
refund according to policy. Preferred driver is not guaranteed.

**SP19 School-run passenger profile** - Child/passenger name, school and
only necessary class/instructions. - Minimise collected data and
restrict role access.

**SP20 Authorised contacts** - Add/edit/remove guardian and authorised
recipients; verify changes. - Only verified parent/guardian can change
contacts. Changes are audited; pending contacts cannot be used.

**SP21 School-run status** - Today's trip, assigned driver and milestone
timeline: assigned, approaching, pickup confirmed, en route, drop-off
pending, drop-off confirmed. - Milestone notifications are baseline;
live GPS tracking is not a baseline requirement. Only backend-confirmed
events advance timeline.

**SP22 Handover verification** - Trip/handover-specific code sent to
authorised contact, expiry and recipient verification instructions. -
Code is time-limited, single-use, stored as verifier/hash where
feasible; never log plaintext. - Code does not replace
authorised-recipient check or school protocol.

**SP23 Failed handover/escalation** - Incident state,
operations/guardian contact and approved fallback instructions. - Driver
cannot self-approve fallback. Operations/safety officer directs and
records alternate verification. Driver must not leave a child unattended
or release to an unauthorised person. Serious incidents escalate
appropriately. Routine child photos are not required; a photo alone does
not prove authorisation.

**SP24 Completion/entitlement update** - Completed trip, receipt/record
and updated entitlement balance. - Deduct entitlement only after
successful completion under policy, not on generation/assignment.
Go-Volts/driver failure must not consume entitlement. Updates must be
idempotent. - Offline events remain pending sync until backend
acknowledgement; offline mode cannot bypass verification.

**SP25 Renewal reminders** - Manual renewal baseline; reminders 7, 3 and
1 day before expiry. - Suppress after renewal/cancellation.

**SP26 One-off future trip** - Date/time, route, one-way/round trip,
quote, payment and confirmation. - **Launch decision unresolved:** exact
payment timing must follow approved ride checkout policy. Confirm
whether immediate full payment or another permitted flow applies; do not
invent a rule.

### F. Wallet, rewards and offers

**W01 Wallet home:** available balance, top-up, transactions, payment
methods and eligible ride-wallet credit. Distinguish
available/pending/reserved balances if shown; loyalty credits are not
unrestricted cash withdrawals by default.

**W02 Top-up:** amount presets/custom amount, payment method, fees if
applicable, confirmation. Post credit only after verified payment;
reconcile callbacks idempotently.

**W03 Transaction details:** reference, type, amount, time, status,
related trip/order/plan and receipt.

**W04 Payment methods:** supported saved methods, add/remove. Use
provider-secure collection; do not store raw card details without an
approved compliant architecture.

**W05 Rewards:** points, earning rules, expiry and eligible redemption
into ride-wallet credit where enabled. Conversion/earning/expiry are
admin-configured; show balances only after server confirmation.

**W06 Referrals:** referral code/link, terms and progress. Explain
eligibility and when reward is earned.

**W07 Coupons:** available/used/expired, terms and expiry. Revalidate
eligibility and price at checkout; explain rejection.

**W08 Receipt/refund:** original payment, refund/credit status and
reference. Distinguish initiated from settled.

### G. Account, safety and support

**A10 Account overview:** profile, saved addresses, payment methods,
authorised contacts where relevant, preferences, support, privacy/legal
and logout.

**A11 Edit profile:** supported fields, verification for sensitive
identifiers, pending-verification state.

**A12 Safety centre:** trip-specific safety support, share trip where
supported, report issue and locally approved guidance. Do not claim
emergency dispatch unless implemented.

**A13 Help and support:** categories for ride, delivery, Scheduled
Pickup, wallet/payment, account and safety. Only show contact channels
that actually exist.

**A14 Support case:** reference, submitted issue, status, responses and
timestamps; avoid duplicate case creation.

**A15 Privacy/preferences:** notification/location settings and only
genuinely supported preferences/data-request controls.

**A16 Logout/session expiry:** confirmation where appropriate; clear
sensitive local state and return expired sessions to login.

## 5. Interactive prototype flows

Use clearly labelled sample data only. These are prototype paths, not
proof of a working backend.

### Flow 1: First-time customer

`A01 Splash → A02 Welcome → A03 Create account → A05 OTP → A06 Profile → A07 Location permission → H01 Home`
Branches: existing user → A04 Login; permission denied → H03 manual
search.

### Flow 2: Ride

`H01 → R01 Locations → R02 Options → R03 Fare → R04 Payment → R05 Confirm → R06 Finding driver → R07 Assigned → R08 Tracking → R09 Pickup → R10 In progress → R11 Completed`
Branches: no driver/retry, payment failure, stale GPS, cancellation R12,
support issue R13.

### Flow 3: Parcel delivery

`H01 → D01 Package → D02 Sender → D03 Recipient → D04 Quote → D05 Payment → D06 Assignment → D07 Pickup → D08 Tracking → D09 Proof`
Branch to D10 for recipient unavailable/address/delivery exception.
Unknown payment must be reconciled before retry.

### Flow 4: One-off future trip

`H01 → SP01 → SP02 One-off → SP03 Journey → SP04 Date/time → SP05 Price/terms → SP26 Review/payment policy → Confirmation → SP12 Trips → SP13 Details`
Prototype must visibly mark payment timing as pending product-owner
confirmation.

### Flow 5: Recurring plan

`H01 → SP01 → SP02 Recurring → SP03 Journey → SP04 Schedule → SP05 Package → SP06 Submit → SP07 Review → SP08 Quote → SP09 Payment → SP10 Active → SP11 Details → SP12 Trips`
Branches: submission failure, rejection with reason, 48-hour quote
expiry, payment failure and late-payment availability revalidation.

### Flow 6: School run

`SP01 → SP02 School run → SP19 Passenger → SP20 Contacts → SP03 Journey → SP04 Schedule → SP05 Package → SP06 Submit → SP07 Review → SP08 Quote → SP09 Payment → SP10 Active → SP21 Status → SP22 Handover → SP24 Completion`
Exception: SP23 failed handover/escalation.

### Flow 7: Skip/change trip

`SP11 → SP12 → SP13 → SP14 Skip OR SP15 Change → Confirmation → Updated status`
Server validates cutoff/eligibility and the UI states entitlement impact
before confirmation.

### Flow 8: Pause/cancel plan

`SP11 → SP16 Pause/resume OR SP17 Cancel → Policy summary → Confirmation → Updated status`
Use package-specific terms and backend-calculated refund.

### Flow 9: Wallet top-up

`Wallet tab → W01 → W02 Top-up → Payment provider → Verified success → Updated balance → W03 details`
Provider timeout means pending reconciliation, not assumed
success/failure.

### Flow 10: Rewards redemption

`W05 Rewards → Select eligible conversion → Review value → Confirm → Server success → Updated points/ride-wallet credit`

### Flow 11: Notification deep link

`Any screen → H06 Notifications → Select item → Linked trip/plan/payment/support case`

### Flow 12: Help

`Account/trip detail → A13 Help → Category → Create case → A14 Case details`

## 6. Global state and error inventory

Critical screens need: - Loading skeleton, empty state and offline
state. - Slow response/timeout and recoverable server error. -
Validation error, permission denied and service-area restriction. -
Authentication expiry, stale information and refresh. - Payment
pending/success/failure/unknown outcome. - Duplicate-submission
protection, cancellation confirmation/result and safe retry. -
Accessibility focus, screen-reader labels and text scaling.

Use clear recovery language. Example: "We haven't confirmed your payment
yet. Check its status before trying again." Avoid generic errors when a
safe, specific explanation is possible.

## 7. Accessibility and interaction standards

-   Use action labels such as "Confirm booking", "Pay now", "Submit for
    review" and "Confirm skip".
-   Sticky CTAs must not cover content or system navigation.
-   Keep totals, dates and policy consequences visible before
    commitment.
-   Use confirmation sheets for consequential actions and show the
    resulting status.
-   Respect screen readers, text scaling, reduced motion, contrast and
    logical focus order.
-   Provide textual alternatives to maps: pickup, destination, route/ETA
    where available.
-   Do not rely on colour alone for status.
-   State when ETA is an estimate; use consistent local date/time
    formatting.
-   Support small screens and intermittent/slow connections.

## 8. Product decisions requiring confirmation before launch

Do not resolve these by visual guesswork: 1. One-off future trip payment
timing. 2. Final fare rules, fees, waiting charges, cancellation charges
and taxes. 3. Enabled payment methods and provider checkout behaviour.
4. Supported ride classes, package categories, service areas and
operating hours. 5. Support channels, emergency escalation and
service-level promises. 6. Refund/credit eligibility and
package-specific calculation formula. 7. Whether pausing a plan affects
expiry/entitlement. 8. Child/passenger data requirements and school
handover protocol per service area. 9. Driver assignment, delay and
escalation thresholds. 10. Loyalty conversion, earning, expiry, referral
and coupon rules. 11. Privacy retention, proof-of-delivery evidence and
notification lock-screen policy. 12. Whether multi-stop rides,
attachments, calendar export and saved recipients are supported.

## 9. Suggested Figma page structure

1.  `00 Cover & Flow Map`
2.  `01 Foundations`
3.  `02 Components`
4.  `03 Auth & Onboarding`
5.  `04 Home & Location`
6.  `05 Ride Booking`
7.  `06 Parcel Delivery`
8.  `07 Scheduled Pickup`
9.  `08 Wallet & Rewards`
10. `09 Account & Support`
11. `10 States & Exceptions`
12. `11 Prototype Routes`

Naming pattern: `AREA / SCREEN / STATE`,
e.g. `RIDE / Payment Method / Insufficient Wallet`,
`SCHEDULED / Quote / Expired`, `SCHOOL RUN / Handover / Exception`. Use
reusable components and variants rather than detached copies.

## 10. Definition of done

-   Every primary navigation destination is specified.
-   Every service has an end-to-end happy path and key exception
    branches.
-   Consequential actions have confirmation and outcome states.
-   Booking/payment retries cannot duplicate operations in prototype
    logic.
-   Scheduled Pickup approval, 48-hour quote expiry, manual renewal,
    six-hour skip cutoff, entitlement rules and school handover are
    represented.
-   Critical screens have loading, empty, offline, validation and error
    states.
-   Labels and policies are consistent; unresolved decisions are
    explicitly tracked.
-   A designer can create linked screens without inventing missing
    transitions.

## 11. Recommended design order

1.  Foundations and reusable components.
2.  Authentication, Home and location.
3.  Ride booking and exceptions.
4.  Parcel delivery and exceptions.
5.  Recurring Scheduled Pickup approval/payment.
6.  School-run safety and handover.
7.  One-off future trip after payment timing is confirmed.
8.  Wallet, rewards, account, notifications and support.
9.  Empty/error/accessibility review.
10. Usability review and developer handoff.
