# Go-Volts Scheduled Pickup
## Product, UI/UX and Engineering Screen Specification

**Status:** Screen-planning baseline  
**Module:** Scheduled Pickup MVP  
**Design direction:** Go-Volts light mode  
**Source documents:** Developer Concept Note, Section 24 and Appendix C4; Master Technical Specification v1.4, Section 21.

## 1. Purpose

This document turns the approved Scheduled Pickup requirements into a screen-by-screen customer app specification. It defines screen purpose, displayed information, actions, validation, states and backend responsibilities. It is a product/engineering guide, not a final visual design.

## 2. Product model

Scheduled Pickup has three separate concepts:

1. **Trip:** one journey with its own pickup, destination, scheduled time, driver assignment, status and outcome.
2. **Recurring schedule:** dates, weekdays, times, route, direction and calendar exceptions used to generate individual trips.
3. **Subscription/package:** commercial agreement covering a defined number of trips, price, validity, payment, expiry and renewal.

A one-off future trip does not require a recurring plan. An active subscription does not mean a driver has already been assigned to every future trip.

### Supported options
- One-off future journey.
- Recurring weekly or monthly arrangement.
- Trip purpose: school run, work commute or other regular journey.
- One-way or round trip.
- Pay per scheduled trip or fixed weekly/monthly package with a defined number of trip entitlements.

A round trip consists of two separately scheduled and priced legs. Outbound and return locations and times must be configured independently. Each leg has its own assignment, status and outcome and counts as one trip entitlement. Unlimited-trip packages are not part of the approved baseline.

## 3. Entry point

Scheduled Pickup should be a prominent service entry on the customer home screen alongside Ride and Delivery, subject to service-area availability and operational approval.

The landing page should explain one-off and recurring trips and provide shortcuts to create a booking, My Plans and Upcoming Trips. Show an unavailable state when the service is not enabled in the customer's area.

School Run must not appear as an unrestricted service. It can only be offered where the service-area feature gate confirms the required approvals.

## 4. Screen inventory

| ID | Screen | Responsibility |
|---|---|---|
| SP-01 | Scheduled Pickup Landing | Explain service and provide entry points |
| SP-02 | Choose Booking Type | One-off or recurring |
| SP-03 | Select Trip Purpose | School, work or other |
| SP-04 | Pickup and Destination | Addresses, precise points and instructions |
| SP-05 | Journey Direction | One-way or round trip |
| SP-06 | Outbound and Return Details | Configure each leg independently |
| SP-07 | Schedule Calendar | Dates, weekdays, times and exceptions |
| SP-08 | Passenger Details | Passenger/contact information |
| SP-09 | School Run Details | Guardian, school and handover details |
| SP-10 | Preferred Driver | Optional driver preference |
| SP-11 | Payment Model | Pay per trip or fixed package |
| SP-12 | Package and Trip Count | Package selection and entitlement validation |
| SP-13 | Review Plan | Full booking/plan review and terms |
| SP-14 | Submission Confirmation | Request received |
| SP-15 | Plan Review Status | Pending, approved or rejected |
| SP-16 | Approved Quote | Quote, terms and 48-hour deadline |
| SP-17 | Payment | Complete eligible payment |
| SP-18 | Plan Activated | Active plan and entitlement balance |
| SP-19 | My Scheduled Plans | List and filter plans |
| SP-20 | Plan Details | Schedule, package and management actions |
| SP-21 | Upcoming Trips | Individual trip legs |
| SP-22 | Trip Details | Route, milestones, driver and support |
| SP-23 | Skip Trip | Cutoff and entitlement consequence |
| SP-24 | Pause or Resume Plan | Explain affected trips |
| SP-25 | Change Request | Request route/schedule changes |
| SP-26 | Cancel Plan | Cancellation and refund terms |
| SP-27 | Renewal | Manual renewal |
| SP-28 | Driver Assignment | Assignment progress |
| SP-29 | Driver Approaching | Driver and arrival details |
| SP-30 | Pickup Confirmation | Pickup milestone |
| SP-31 | Active Trip | Journey progress |
| SP-32 | Trip Completion | Completion and receipt |
| SP-33 | School Run Status | School pickup and journey milestones |
| SP-34 | Handover Verification | Secure-code/approved verification |
| SP-35 | Handover Complete or Exception | Confirmed handover or incident |
| SP-36 | Payment and Refund Details | Payment, refund and receipt records |

These are recommended UI states. Related states may share a screen if no required information or control is hidden.

## 5. Detailed screen requirements

### Group 1: Entry and booking type

**SP-01: Scheduled Pickup Landing**
- Show service explanation, Create Scheduled Pickup, My Plans and Upcoming Trips.
- Fetch service-area availability from backend.
- States: available, unavailable, temporarily restricted, loading and error.
- Do not hardcode availability in the app.

**SP-02: Choose Booking Type**
- Options: One-off future trip; Recurring arrangement.
- One-off requires a valid future date/time.
- Recurring requires a valid period and at least one selected recurring date.

**SP-03: Select Trip Purpose**
- Options: School run, Work commute, Other.
- School Run appears only when the service-area feature gate is enabled after required approvals.
- Backend must prevent bypassing the School Run gate by selecting Other.

### Group 2: Route and journey

**SP-04: Pickup and Destination**
- Pickup and destination address.
- Precise map point for each.
- Saved-address selection and address search.
- Pickup/destination notes and safe pickup instructions.
- Validate both points and serviceability before continuing.
- Store address references and immutable location snapshots for accepted trips.

**SP-05: Journey Direction**
- One-way or round trip.
- One-way creates one leg.
- Round trip requires separate outbound and return setup.

**SP-06: Outbound and Return Details**
- Outbound pickup, destination and pickup time.
- Return pickup, destination and pickup time.
- Do not assume the return route is the reverse of the outbound route.
- Do not derive return time automatically.
- Each leg has its own fare, assignment, status, outcome and entitlement.
- Revalidate availability and price when price-affecting details change.

### Group 3: Schedule

**SP-07: Schedule Calendar**
- One-off: future date and pickup time.
- Recurring: start date, end date or package period, weekly/monthly repeat, selected weekdays/dates, time for each leg, excluded dates and applicable school/work calendar exceptions.
- Display selected days, dates, timezone and expected trip count.
- Validate date range and required times.
- Backend calculates authoritative trip demand and generates trips idempotently using service-area timezone and calendar exceptions.
- Show any mismatch between expected trip demand and package entitlements before purchase.

### Group 4: Passenger and driver

**SP-08: Passenger Details**
- Capture passenger details and contact information appropriate to the service.
- Collect only information necessary for the trip.
- Passenger profile and billing customer remain separate concepts where applicable.

**SP-09: School Run Details**
Only available after School Run is enabled in the service area.
- Child/passenger profile.
- Verified parent/guardian.
- School, approved pickup/drop-off points and school protocol/contact.
- Authorised handover contacts and emergency contacts.
- Verified guardian owns the plan and billing relationship.
- Only a verified guardian can add/remove authorised contacts.
- Pending contact changes cannot be used for an imminent handover.
- Restrict child data to the guardian and staff/driver assigned to the relevant trip.
- Routine child photographs are not a default requirement.

**SP-10: Preferred Driver**
- Optional preferred driver request, where eligible choices can be shown.
- State clearly that this is a preference, not a guarantee.
- If unavailable, assign an eligible alternative and notify the customer.
- Alternative must meet vehicle, service-area and rider eligibility requirements, including School Run certification where applicable.

### Group 5: Package and quote

**SP-11: Payment Model**
- Pay per scheduled trip.
- Fixed package/subscription.
- Explain that packages have a defined number of trips and are not unlimited.
- Product owner must confirm one-off future-trip payment timing before launch. Do not invent a new payment rule.

**SP-12: Package and Trip Count**
- Show package period, price, included trips, eligible schedule, validity and expiry.
- Show expected trips from the configured schedule.
- Each round-trip leg counts separately.
- Full upfront payment is required for a recurring package.
- Backend is authoritative for price, trip count and entitlement balance.

**SP-13: Review Plan**
Show purpose, booking type, route, each leg, dates/times, passenger details, preferred-driver request, payment model, package count/price/validity and skip/no-show/cancellation/refund terms. Include applicable school protocol summary.
- Allow editing relevant sections.
- Submit request.
- Do not hide critical terms.
- Material changes after approval require revised quote and explicit acceptance.

### Group 6: Submission, review and payment

**SP-14: Submission Confirmation**
- Show request reference, timestamp and pending operational review.
- Explain next step.
- Do not present submission as activation or payment.

**SP-15: Plan Review Status**
- Pending review.
- Approved, awaiting payment.
- Rejected.
- If rejected, show operations reason and applicable payment void/refund treatment.

**SP-16: Approved Quote**
- Show approved route/schedule, trip count, price, terms, quote issue time and expiry.
- Recurring-plan quote is valid for 48 hours from issue timestamp.
- Show exact deadline in service-area timezone.
- After expiry, customer must request re-approval/re-quotation. Availability and price are not guaranteed.

**SP-17: Payment**
- Show approved amount, eligible payment methods and quote deadline.
- Use existing payment flow.
- Verify payment server-side.
- For uncertain network outcomes, check payment/booking status before offering retry.
- Never activate from a client-side success message.

**SP-18: Plan Activated**
- Activate only after operational approval and verified successful payment.
- Show plan reference, dates, package, total/used/remaining entitlements and next trip.
- State that activation does not mean drivers have already been assigned to every future trip.

### Group 7: Plan management

**SP-19: My Scheduled Plans**
- List purpose, status, dates, package summary, remaining entitlements and next trip.
- Filters: active, pending, paused, expired, cancelled and rejected.

**SP-20: Plan Details**
- Show status, schedule, route, package, validity, total/used/remaining/expired entitlements, upcoming trips and history.
- Actions according to plan state: pause, resume, change request, cancel, renew.
- Do not show invalid actions.

**SP-21: Upcoming Trips**
- Each journey leg is a separate item.
- Show date/time, pickup/destination, outbound/return label, trip status, driver status and skip deadline.
- Do not merge round-trip legs into one status or entitlement.

**SP-22: Trip Details**
- Trip reference, route, scheduled pickup, status timeline, confirmed driver details, support and relevant controls.
- Read authoritative backend state. Do not infer completion from a local tap.

**SP-23: Skip Trip**
- Show trip time, six-hour cutoff and whether entitlement is preserved or forfeited.
- Skip accepted by server at least six hours before pickup preserves entitlement.
- Late skip forfeits entitlement under published policy, subject to approved exceptions and applicable law.
- Show consequence before confirmation.
- Use server time and service-area timezone.

**SP-24: Pause or Resume Plan**
- Explain effective time and affected upcoming trips before confirmation.
- Pause prevents future eligible trips from being generated/dispatched after effective point.
- It does not erase history or silently cancel an underway trip.
- Resume affects future schedule generation under approved plan terms.

**SP-25: Change Request**
- Support requests for pickup time/location, destination, schedule dates/weekdays and package changes where supported.
- A request is not an immediate edit.
- Material changes require revised quote and explicit acceptance.
- Preserve original quote and plan history.
- New 48-hour payment deadline applies when additional payment is due.

**SP-26: Cancel Plan**
- Show affected future trips, effective date, used/unused entitlements, refund terms and permitted charges.
- Eligible unused service is refunded under published pro-rata/contract formula.
- Do not assume package price divided by trip count is the refund formula unless package terms explicitly say so.
- Cancellation and refund are separate states.
- Refund initiation target is 1–3 business days after approval, not a bank settlement guarantee.
- Show refund status/reference.

**SP-27: Renewal**
- Manual renewal only.
- Show expiry, remaining entitlements, renewal quote, price, validity and terms.
- Send reminders 7, 3 and 1 day before expiry; suppress after renewal/cancellation.
- Explain what happens if customer does not renew.

### Group 8: Trip tracking and completion

**SP-28: Driver Assignment**
- Show trip status and assignment progress.
- Show preferred-driver outcome when applicable.
- Do not show assigned until backend confirms.
- Unassigned trips approaching deadline must alert operations.

**SP-29: Driver Approaching**
- Show confirmed driver and relevant vehicle details, pickup point, reliable ETA and permitted contact/support.
- Delay notifications use configured thresholds; urgent disruptions escalate immediately.

**SP-30: Pickup Confirmation**
- Show arrival milestone, pickup instructions, required verification and support.
- Record pickup as authenticated backend event; a customer tap alone is not proof.

**SP-31: Active Trip**
- Show current status, route/progress, milestones and configured support/safety options.
- School Run uses its separate status/handover flow.

**SP-32: Trip Completion**
- Show completed state only after backend confirmation, trip summary, receipt, rating where supported and issue reporting.
- Consume entitlement only after successful completion under policy.
- Duplicate completion events must not consume twice.

### Group 9: School Run

**SP-33: School Run Status**
Only available in approved/enabled service areas.
- Show driver assigned, approaching, school pickup confirmed under protocol, journey in progress, destination arrival, handover pending, handover confirmed or incident requiring attention.
- Destination arrival is not successful handover.
- Do not expose child details in generic notifications or broad analytics.

**SP-34: Handover Verification**
- Show handover stage, authorised-recipient status and secure-code/approved verification.
- Code is trip-specific, time-limited, single-use and rate-limited.
- Never log plaintext code or expose it to unrelated users.
- Code does not replace school protocol or authorised-recipient check.
- Driver cannot self-approve failed verification.

**SP-35: Handover Complete or Exception**
- Success: confirmed handover and timestamp; complete trip only after required conditions.
- Exception: handover not confirmed, operations escalation and approved customer instructions.
- Driver must not leave child unattended or release to unauthorised person.
- Failed handover is an incident, not normal completion.
- Offline events remain pending until backend acknowledgement; offline mode cannot bypass verification.

### SP-36: Payment and Refund Details
- Show payment reference, amount, status, related plan/trip and receipt.
- Show refund status/reference where applicable.
- Wallet credit, refund and entitlement restoration are separate remedies.
- Do not show an approved refund as settled.
- Financial values come from authoritative backend/ledger records.

## 6. Shared UI behaviour

Use the established Go-Volts light-mode design system.

Recommended reusable components:
- Step progress indicator.
- Address search and map picker.
- Date/time selector and weekday selector.
- Schedule and route summary cards.
- Outbound/return leg cards.
- Package cards and entitlement balance.
- Quote/price breakdown.
- Status badge and event timeline.
- Driver information card.
- Confirmation sheet.
- Loading, empty, offline and error states.
- School-run handover status component.

Preserve entered data when navigating backward. Warn before leaving if unsaved data would be lost. Use a clear primary action and do not hide critical terms in tooltips or secondary menus.

### Required exception states
- Pickup/destination outside service area.
- Invalid dates or return time.
- Package does not cover expected trip count.
- Quote expired.
- Payment failed or unknown outcome.
- Plan rejected.
- No driver assigned by deadline.
- Preferred driver unavailable.
- Driver cancellation.
- Skip before/after cutoff.
- Change requiring re-quote.
- Entitlement discrepancy.
- Refund pending/failed.
- Handover verification failure.
- Network unavailable/offline event pending sync.

## 7. Backend and data responsibilities

Reuse shared quotes, payments, refunds, financial ledger, riders, profiles, addresses, notifications, audit events and dispatch records. Do not create duplicate payment, rider or dispatch systems.

### Core records
- `scheduled_plans`
- `scheduled_plan_legs`
- `scheduled_trips`
- `scheduled_trip_status_events`
- `trip_entitlement_accounts`
- `trip_entitlement_entries`
- `scheduled_quotes` or immutable quote snapshots
- `scheduled_plan_change_requests` or immutable plan-version snapshots
- `school_passenger_profiles`
- `school_protocols`
- `authorised_contacts`
- `handover_events`
- `school_run_incidents`

### Core invariants
1. One-off trips do not require recurring plans.
2. Each round-trip leg is a separate trip.
3. At most one active driver assignment per trip.
4. Entitlement consumed at most once per trip.
5. Plan, quote, payment, trip and entitlement states remain separate.
6. Plan activates only after operational approval and verified full payment.
7. 48-hour deadline is server-computed.
8. Late payment after quote expiry requires revalidation.
9. Six-hour cutoff uses server time and service-area timezone.
10. Ten-minute no-show wait begins only after correct pickup arrival is recorded.
11. Driver/Go-Volts service failures do not consume customer entitlements.
12. Material changes create a new quote/version and require acceptance.
13. Existing paid plans retain accepted terms unless changed through an approved process.
14. Pending authorised-contact changes cannot be used.
15. Handover codes are secure, time-limited, single-use and rate-limited.
16. Offline handover events remain pending until server acknowledgement.
17. Manual overrides, approvals, refunds, entitlement adjustments and handover exceptions are audited.

Follow existing `/v1` API conventions, authorization, idempotency, pagination and response envelope. Use the existing technical specification's Scheduled Pickup API operations and repository naming conventions.

## 8. Admin and operations dependencies

Operations needs queues for:
- Plans awaiting review.
- Approved plans awaiting payment.
- Unassigned trips and expiring driver offers.
- Approaching assignment deadlines.
- Driver cancellation/unavailability.
- No-show disputes.
- Failed handovers and unresolved incidents.
- Service recovery and refund workflows.

Pricing/policy administrators configure package terms, skip cutoff, no-show wait, assignment deadlines, offer windows and delay thresholds within role permissions and audit.

School Run activation must be blocked until the required service-area approvals are recorded.

## 9. Acceptance criteria

The screens are ready for visual sign-off when:
- One-off and recurring booking are clearly distinguished.
- One-way and round-trip are clear.
- Round-trip legs have independent times, routes, prices, statuses and entitlements.
- Weekly/monthly scheduling and calendar exceptions are supported.
- Expected trip count is visible before package purchase.
- Package limits and terms are clear.
- Review, 48-hour quote deadline and payment states are clear.
- A plan cannot appear active before approval and verified payment.
- Plan and trip states are distinct.
- Skip cutoff and entitlement consequences are shown before confirmation.
- Pause/resume explains affected trips.
- Material changes require revised quote and acceptance.
- Driver assignment appears only after backend confirmation.
- School Run is gated and includes guardian, authorised-recipient and handover safeguards.
- Loading, offline, error and exception states are covered.
- No sample price or unapproved operational promise is treated as production policy.

## 10. Decisions still requiring confirmation

1. Payment timing for one-off future trips.
2. Package catalogue, prices and validity periods.
3. Published refund formula and permitted charges.
4. Treatment of school closures and exceptional calendar changes.
5. Exact School Run operating protocol and verification fallback.
6. School Run service areas and legal, insurance, safeguarding and operational approvals.
7. Payment methods enabled for Scheduled Pickup.
8. Customer-facing cancellation and service-recovery terms.

Do not fill these gaps with assumptions in the UI or backend.

## 11. Recommended design sequence

1. SP-01 landing.
2. SP-02 to SP-07 booking type, purpose, route and schedule.
3. SP-08 to SP-13 passenger, preferred driver, payment model and review.
4. SP-14 to SP-18 submission, review, quote, payment and activation.
5. SP-19 to SP-27 plan management.
6. SP-28 to SP-32 trip tracking and completion.
7. SP-33 to SP-35 School Run states as gated designs.
8. SP-36 payment and refund details.

Generated screen boards are visual references only. The Developer Concept Note and Master Technical Specification remain authoritative.
