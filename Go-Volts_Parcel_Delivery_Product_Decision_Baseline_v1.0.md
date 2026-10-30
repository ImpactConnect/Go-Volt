# Go-Volts Send: Parcel Delivery Product Decision Baseline

**Document ID:** GV-CUST-PARCEL-DEC-001  
**Version:** 1.0  
**Date:** October 2026  
**Status:** Recommended baseline for Product, Operations, Finance, Legal/Compliance and Engineering review

## 1. Purpose

This document turns unresolved Go-Volts Send product decisions into a reviewable baseline. It separates requirements already present in the product documentation from recommended decisions that still require approval.

The recommendations below are proposals, not approved Go-Volts policies. Relevant owners should approve them before implementation.

## 2. Recommended launch baseline

| Area | Recommended baseline | Approval needed |
|---|---|---|
| Delivery types | Launch with one on-demand Standard Delivery option. Add Express or Scheduled only when capacity, service-level targets, pricing and support are ready. | Product + Operations |
| Package categories | Start with Documents, Electronics, Clothing, Food, Fragile Items and Other Eligible Items. Keep the catalogue admin-configurable. | Product + Operations |
| Package size and weight | Admin defines allowed bands, dimensions and maximum weight. Reject requests outside configured limits. | Operations |
| Restricted items | Maintain an approved prohibited/restricted-item policy. Display it before submission and require acknowledgement. | Legal/Compliance + Operations |
| Declared value | Collect only when required by policy. Do not imply that declaration automatically creates insurance coverage. | Finance + Legal/Compliance |
| Handling instructions | Show only operationally supported options, such as fragile or keep upright. | Operations |
| Pickup address | Validate address, coordinates and service-area availability before quote generation. | Operations |
| Recipient | Support individual and business recipients. Capture name, phone, delivery address and optional instructions. | Product |
| Payment | Prefer approved prepaid methods. Keep cash, pay-on-delivery and merchant credit hidden until settlement, fraud, safety and reconciliation rules are approved. | Finance + Operations |
| Pricing | Use a server-generated quote with itemized components, currency, quote ID and expiry. Requote after price-affecting changes. | Finance + Product |
| Pickup verification | Record pickup milestone and use a booking reference or configured pickup PIN/OTP where required. | Operations |
| Delivery verification | Use recipient OTP/PIN as the proposed primary method where feasible, with an approved exception path. | Operations + Product |
| Proof of delivery | Record method, result, timestamp and authorized recipient/handover reference. Capture photo evidence only where policy requires it. | Operations + Legal/Compliance |
| Cancellation | Define permitted states and disclose any applicable fee before confirmation. Do not invent a universal fee or cutoff. | Operations + Finance |
| Failed delivery | Record a structured failure reason and provide approved next actions: retry, support review or return process. | Operations |
| Return to sender | Do not expose as a standard option until eligibility, pricing, rider workflow, custody and responsibility are defined. | Operations + Finance |
| Recipient tracking | If enabled, use an expiring, delivery-scoped link with minimal personal information. Recipient should not need the app. | Product + Security |

## 3. Customer journey

1. Pickup details
2. Recipient details
3. Package details
4. Quote and review
5. Payment and booking submission
6. Rider search and assignment
7. Delivery tracking
8. Delivery confirmation
9. Receipt

Recommended backend milestones:

`draft` → `quoted` → `awaiting_payment` (when required) → `confirmed` → `searching_rider` → `rider_assigned` → `approaching_pickup` → `arrived_at_pickup` → `parcel_collected` → `in_transit` → `approaching_destination` → `delivery_verification_pending` → `delivered`

Exception states should be explicit:
- `quote_expired`
- `payment_failed`
- `booking_cancelled`
- `no_rider_available`
- `rider_reassigned`
- `pickup_failed`
- `delivery_attempt_failed`
- `return_in_progress` (only after return operations are approved)
- `delivery_disputed`

Booking state and payment state must remain separate. A client-side payment success screen or redirect is not authoritative proof of payment.

## 4. Key business rules

### Quote validity
- The backend calculates the quote.
- Include quote ID, currency, itemized components, creation time and expiry.
- Changes to pickup, destination, package category, size/weight, declared value or delivery option invalidate the old quote.
- Show the updated amount before confirmation.
- The app must not calculate or invent the payable amount locally.

### Package eligibility
- Active categories and limits come from admin configuration.
- The backend validates category, size, weight, declared value and handling options.
- Prohibited items are rejected.
- Restricted items require configured conditions and acknowledgement.
- Avoid unnecessary sensitive details in free-text package descriptions.

### Payment and booking
- Create payment attempts through the backend.
- Verify payment using authoritative backend/provider confirmation.
- Use idempotency keys to prevent duplicate bookings and payment attempts.
- On timeout, check existing payment and booking state before offering a retry.
- Do not dispatch until required payment or an approved merchant-credit condition is satisfied.

### Pickup and delivery evidence
- Record each milestone with actor, timestamp and booking reference.
- Capture location evidence only where justified and permitted.
- Delivery completion requires the configured proof-of-delivery method.
- Restrict access to photos, OTP results, contact details and tracking data.
- Define retention and deletion periods before production.

### Failed delivery and returns
- The rider selects a structured failure reason.
- The customer receives a clear status and next step.
- A retry follows configured eligibility, time window and pricing rules.
- Return-to-sender requires a separate approved workflow and charge rules.
- Never mark an unsuccessful delivery as completed.

## 5. Admin Panel requirements

Add an explicit **Parcel Delivery Configuration** module. Authorized administrators should manage:

1. Delivery options and availability by service area.
2. Package categories and descriptions.
3. Size, weight and dimension bands.
4. Prohibited/restricted-item policy notices and versions.
5. Declared-value rules and limits, if used.
6. Supported handling instructions.
7. Pricing rules and quote validity.
8. Pickup and delivery verification requirements.
9. Proof-of-delivery methods.
10. Cancellation, retry and failed-delivery rules.
11. Return-to-sender availability and pricing, when approved.
12. Payment methods and eligibility.

Configuration changes should be permission-controlled, audited and versioned. A booking retains the policy/configuration version that applied when it was created. Sensitive changes, especially pricing and restrictions, should support approval and publishing.

## 6. Targeted UI changes

Keep the existing 17-panel storyboard as the visual reference. Do not redesign the whole journey.

- Delivery Type: show only active options for the customer's area.
- Package Details: load categories, limits and handling options from configuration.
- Review and Quote: show itemized charges, quote expiry and restriction acknowledgement.
- Payment: show eligible methods and clear pending, failed and retry states.
- Pickup and Tracking: show the correct verification milestones.
- Delivery Confirmation: show verification method and evidence status without unnecessarily exposing private evidence.
- Add exception-state designs for no rider available, payment failure, cancellation, failed delivery and approved return flow.

## 7. Decisions requiring approval

The following values are not defined here and must not be invented:

- Exact delivery types and service-level promises.
- Launch package categories.
- Maximum weight, dimensions and size bands.
- Prohibited/restricted-item list.
- Declared-value requirement and limits.
- Insurance/coverage product, exclusions and claims process, if any.
- Enabled payment methods.
- Pricing components and quote expiry duration.
- Pickup verification requirements.
- Delivery OTP/PIN and fallback process.
- Photo evidence requirements and retention period.
- Cancellation windows and fees.
- Rider search timeout and reassignment policy.
- Failed-delivery retry policy.
- Return-to-sender availability, charges and custody process.
- Recipient tracking-link expiry and privacy rules.

## 8. Approval checklist

| Owner | Approval area | Status |
|---|---|---|
| Product | Customer journey, delivery types and required fields | Pending |
| Operations | Package handling, rider workflow, verification, failed delivery and returns | Pending |
| Finance | Pricing, payment methods, cancellations, refunds and returns | Pending |
| Legal/Compliance | Restricted items, declared value, coverage language, privacy and evidence retention | Pending |
| Engineering/Security | State transitions, APIs, idempotency, access control and audit trail | Pending |
| QA | Normal, failure, retry, dispute and regression test coverage | Pending |

## 9. Source alignment

The Go-Volts product concept requires sender and recipient details, pickup/drop-off addresses, package category, size/weight band, declared value where required, handling notes, restricted-item notice, quote, payment, tracking and delivery confirmation. It also states that declared value must not be presented as automatic insurance coverage.

The companion parcel specification defines the nine-stage customer journey, server-generated quotes, separate booking/payment states, idempotent booking/payment operations and configurable proof of delivery.

This document adds recommended launch defaults and an approval register. These recommendations must not be treated as approved business policy until the relevant owners sign off.

---

**End of document.**
