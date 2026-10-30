# Go-Volts Customer/Rider App
## Consolidated Screen-Flow Documentation

**Purpose:** Define the customer/rider app's screen groups, navigation sequences, screen actions, and core business rules for design review and implementation.

**Design status:** ImageGen boards are visual concept mockups, not interactive prototypes or verified production screenshots. Confirm final UI copy, pricing, payment rules, and operational policies before implementation.

## 1. App scope and shared navigation

The app supports ride booking, parcel delivery, scheduled pickup and school-run status, wallet and payments, rewards and referrals, trip history, account management, notifications, and support.

The visual direction is Go-Volts green, dark green, white, neutral gray, and restrained lime accents. Reuse typography, spacing, card shapes, buttons, icons, headers, and navigation conventions throughout.

Proposed primary navigation:
- **Home:** services, promotions, recent activity, and booking entry points.
- **Trips:** active and past rides, deliveries, and scheduled trips.
- **Wallet:** balance, transactions, payment methods, and supported wallet actions.
- **Account:** personal details, saved places, preferences, notifications, and support.

Confirm final tab labels and placement against the approved master dashboard.

## 2. Flow A: Ride booking

**Sequence:** Home Dashboard → Location Search and Map Picker → Ride Options → Fare and Payment → Booking Confirmation → Driver Assignment and Live Tracking.

### Screen actions
1. **Home Dashboard:** Choose Ride, view services/promotions, and open recent activity or account features.
2. **Location Search and Map Picker:** Set pickup and destination, adjust map pins, and add an optional stop if supported.
3. **Ride Options:** Compare vehicle categories, estimated arrival, duration, distance, and fare estimate; select a ride.
4. **Fare and Payment:** Review route and fare breakdown, choose an available payment method, and confirm.
5. **Booking Confirmation:** Show booking reference and status after the backend confirms the booking.
6. **Driver Assignment and Live Tracking:** Show assigned driver and vehicle, pickup ETA, trip status, route, and permitted contact/cancellation actions.

### Key rules
- A button tap alone does not confirm a booking; wait for a successful backend response.
- Distinguish fare estimates from final fares where applicable.
- Prevent duplicate bookings from repeated taps or retries.
- Show driver details only after assignment is confirmed.
- Cancellation rules and fees must come from configured policy.
- Map, ETA, and trip status should reflect current service data; indicate unavailable or delayed data.

## 3. Flow B: Parcel delivery

**Sequence:** Home Dashboard → Parcel Details → Sender and Recipient → Review and Pay → Delivery Tracking and Status.

### Screen actions
1. **Home Dashboard:** Select Deliver.
2. **Parcel Details:** Choose package category/size, describe the parcel, add handling instructions, and check package rules.
3. **Sender and Recipient:** Enter contacts and pickup/delivery addresses.
4. **Review and Pay:** Review parcel details, route, delivery option, price, and payment method; submit the booking.
5. **Delivery Tracking and Status:** View delivery reference and verified milestones such as accepted, picked up, in transit, and delivered.

### Key rules
- Do not mark a parcel delivered until the selected proof-of-delivery process confirms it.
- Delivery status must reflect verified operational updates.
- Validate required package, address, and contact fields.
- Explain service-area and package restrictions.
- Protect sender and recipient personal information.

## 4. Flow C: Scheduled pickup and school runs

**Sequence:** Home Dashboard → Choose Plan Type → Plan Details → Plan Review/Submission → Operations Review and Quote → Quote and Payment → Plan Management → Pickup Status and Notifications → School-Run Handover Status where applicable.

### Screen actions
1. **Home Dashboard:** Select Scheduled Pickup.
2. **Choose Plan Type:** Select an available one-off, recurring, or school-run plan.
3. **Plan Details:** Enter locations, dates, times, recurrence, passenger details, and instructions. For school runs, provide parent/guardian and authorised-recipient details.
4. **Plan Review/Submission:** Review route, schedule, passengers, and terms; submit for review if required.
5. **Operations Review and Quote:** Show review status, outcome, and quote; explain next steps if declined or changes are needed.
6. **Quote and Payment:** Review quoted charges and terms, pay, and display the verified payment state.
7. **Plan Management:** View status, upcoming pickups, and supported actions such as requesting a skip or managing renewal.
8. **Pickup Status:** Show upcoming pickup information and verified milestones.
9. **School-Run Handover:** Show pickup/drop-off milestones and handover confirmation to authorised parties.

### Key rules
- Requests requiring operations review must not appear approved before review completes.
- Where a quote has a **48-hour payment window**, show the deadline and expiry behavior.
- A plan activates only after required approval and successful payment verification.
- Renewal is manual unless approved requirements say otherwise.
- Skips must respect the configured **6-hour cutoff** before pickup.
- The configured no-show wait is **10 minutes**; communicate the policy clearly.
- One-way and round-trip legs use separate entitlements.
- Verify the parent/guardian and authorised recipient for school runs and record handover status.
- Baseline school-run experience uses milestone notifications, not continuous GPS tracking.
- Keep an audit trail for requests, reviews, quote changes, payment, skips, no-shows, and handovers.

## 5. Flow D: Wallet and payments

**Sequence:** Home/Wallet Entry → Wallet Overview → Transaction History or Payment Action → Transaction Result.

### Screen actions
- **Wallet Overview:** View available balance, supported actions, and payment methods.
- **Transaction History:** Review credits, debits, refunds, and transaction details.
- **Payment Action:** Enter/select amount, choose a supported method, review charges, and confirm.
- **Transaction Result:** Show success, pending, or failure from the provider/backend, with reference and next steps.

### Key rules
- Balance and transaction history come from authoritative backend records.
- Initiating payment is not proof of successful payment.
- Handle retries idempotently and reconcile provider callbacks.
- Show pending transactions separately from completed ones.
- Refunds and reversals must reflect the actual payment state.
- Confirm the exact wallet operations available to customers before development.

## 6. Flow E: Rewards, referrals, and offers

**Sequence:** Home/Promotions → Rewards Overview → Offer or Referral Details → Apply/Redeem/Share → Result and Activity.

### Screen actions
- View eligible promotions and reward balance.
- Read terms, expiry, and eligibility.
- Share a referral code/link through supported features.
- Apply an eligible coupon during booking.
- Redeem rewards where enabled and view the result.

### Key rules
- Display eligibility, expiry, usage limits, and exclusions before commitment.
- Validate coupons and rewards server-side.
- Prevent redemption beyond configured limits.
- Distinguish earned, pending, expired, and redeemed rewards.
- Do not promise a discount until the backend confirms it applies.

## 7. Flow F: Trip history and trip details

**Sequence:** Trips → History List → Trip Details → Receipt/Payment Details → Help or Report an Issue.

### Screen actions
- View active, upcoming, and past rides, deliveries, and scheduled trips.
- Filter or select a trip.
- Review route, timing, status, driver/delivery details, and receipt.
- Access permitted rating, support, or issue-reporting actions.

### Key rules
- Show only trips belonging to the authenticated customer or authorised profile.
- Trip records and receipts must match backend-confirmed data.
- Do not allow edits to completed trip facts through the customer UI.
- Link support requests to the correct booking/trip reference.
- Retain only information required by privacy and retention policies.

## 8. Flow G: Account, notifications, and support

**Sequence:** Account → Personal Details/Saved Places → Payment Preferences/Notifications → Help and Support → Support Request/Confirmation.

### Screen actions
- Update permitted profile details.
- Manage saved addresses and contact preferences.
- Set notification preferences.
- Browse FAQs and support topics.
- Submit a request linked to a booking or transaction and view its reference/status.

### Key rules
- Protect account changes with appropriate authentication and verification.
- Never expose full payment credentials unnecessarily.
- Explain which notifications are operationally important and which are optional.
- Log support requests with a reference and status.
- Provide clear error and retry paths without losing valid input.

## 9. Shared interaction and screen states

Define applicable states for every flow:
- **Loading:** action is processing.
- **Empty:** no trips, transactions, saved places, or offers exist.
- **Validation error:** required information is missing or invalid.
- **Pending:** backend/provider has not completed the action.
- **Success:** confirmed by the backend.
- **Failure:** action did not complete; provide safe recovery.
- **Offline/connection issue:** preserve entered data where safe and explain whether the action was submitted.
- **Permission denied:** explain the impact and provide a route to settings when appropriate.

### Navigation and accessibility
- Provide a clear back path without unexpectedly discarding input.
- Warn before leaving forms with unsaved changes.
- Prevent duplicate submissions while processing.
- Keep navigation labels and selected states consistent.
- Deep links and notifications must handle unauthenticated users and expired/unavailable records.
- Use readable contrast, scalable text, accessible control labels, comfortable touch targets, and status indicators that do not rely on color alone.

## 10. Security, privacy, and reliability

- Authenticate customers and enforce authorisation server-side.
- Apply least-privilege access to trip, payment, recipient, and school-run data.
- Validate prices, booking states, coupons, entitlements, and payment results server-side.
- Avoid storing payment secrets or unnecessary sensitive data in the app.
- Log critical status changes with timestamps and relevant references.
- Handle retries and provider callbacks safely.
- Use secure transport for backend communication.
- Apply appropriate consent, retention, and deletion policies to personal and location data.

## 11. End-to-end navigation map

```text
Home
├── Ride
│   └── Locations → Ride Options → Fare & Payment
│       → Booking Confirmation → Driver Assignment → Live Tracking
├── Deliver
│   └── Parcel Details → Sender & Recipient → Review & Pay
│       → Tracking → Delivery Confirmation
├── Scheduled Pickup
│   └── Plan Type → Plan Details → Submit for Review
│       → Operations Review/Quote → Payment → Active Plan
│       → Pickup Status/Handover
├── Wallet
│   └── Wallet Overview → Transactions/Payment Action → Result
├── Rewards & Offers
│   └── Rewards → Offer/Referral → Apply or Redeem → Result
├── Trips
│   └── History → Trip Details → Receipt/Support
└── Account
    └── Profile/Saved Places/Notifications/Support
```

## 12. Acceptance checklist

- [ ] One approved Home Dashboard is the visual reference across all flows.
- [ ] Shared components and navigation remain consistent.
- [ ] Every control has a defined action and result state.
- [ ] Booking and payment success rely on verified backend responses.
- [ ] Ride, parcel, scheduled pickup, wallet, rewards, and account flows include pending/error states.
- [ ] Scheduled-plan approval, quote expiry, payment, skip, no-show, and school-run rules are enforced.
- [ ] Trip history, receipts, and support requests use correct backend records.
- [ ] Sensitive data is protected and access-controlled.
- [ ] Sample data in concept images is replaced or clearly labeled before external presentation.
- [ ] Product, design, operations, and engineering review the flows before implementation.

## 13. Items to confirm before development

The visual mockups do not fully establish:
- Final navigation labels and tab arrangement.
- Supported payment methods, wallet operations, refund handling, and transaction limits.
- Fare calculation, cancellation fees, and ride-specific rules.
- Delivery package restrictions and proof-of-delivery method.
- Scheduled-plan quote expiry, approval states, renewal, and skip/no-show enforcement.
- Reward eligibility, referral attribution, coupon stacking, and redemption rules.
- Support response expectations, privacy retention periods, and account deletion behavior.
