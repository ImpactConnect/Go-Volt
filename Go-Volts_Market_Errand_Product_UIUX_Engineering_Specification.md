# Go-Volts Market Errand
## Requirements, Product Flow, UI/UX Logic and Technical Specification

**Document ID:** GV-CUST-ERRAND-001  
**Version:** 1.0  
**Status:** Working specification for product, UI/UX and engineering  
**Platform:** Flutter mobile app for Android and iOS  
**Related system:** Go-Volts Customer App, Rider App, Admin/Operations and shared backend

---

# 1. Purpose

This document defines the Go-Volts **Market Errand** customer experience before final screen designs are produced.

It covers:

- Buy Items From a Shop
- Pick Up a Package
- Other Errand
- Customer request creation
- Dynamic forms
- Pricing, estimates and quotes
- Payment and spending authorization
- Rider/agent assignment
- Tracking
- Purchase and delivery evidence
- Completion
- My Errands and history
- Backend, API and data requirements
- Admin/Operations requirements
- Security, responsive behaviour and acceptance criteria

Where a business policy has not yet been finalized, this document marks it as a decision to be confirmed rather than inventing a production rule.

---

# 2. Product Overview

Market Errand allows a customer to request an eligible Go-Volts rider or errand agent to carry out a task and deliver the resulting goods, package or outcome.

The MVP has three main errand types:

## A. Buy Items From a Shop

The customer asks Go-Volts to:

1. Go to a specified shop or market.
2. Purchase specified items.
3. Follow preferences and budget/substitution rules.
4. Deliver the purchased items.

## B. Pick Up a Package

The customer asks Go-Volts to:

1. Go to a pickup location.
2. Collect an already prepared package.
3. Deliver it to the destination.

## C. Other Errand

The customer describes another supported task.

Some Other Errand requests may require manual review and a quote before execution.

---

# 3. Product Goals

The feature should:

- Make errand creation simple.
- Ask only for information relevant to the selected errand type.
- Clearly distinguish estimates from approved quotes.
- Make payment/authorization status understandable.
- Allow customers to follow fulfilment progress.
- Support transparent purchase reconciliation.
- Record important evidence.
- Provide history and support after completion.

---

# 4. Main Customer Flow

```text
Home Dashboard
    ->
Market Errand
    ->
Market Errand Landing
    ->
Create New Errand
    ->
Choose Errand Type
    ->
+----------------------+----------------------+------------------+
| Buy Items From Shop  | Pick Up a Package   | Other Errand     |
+----------------------+----------------------+------------------+
    ->
Type-Specific Details
    ->
Delivery / Outcome Details
    ->
Review Estimate or Quote
    ->
Confirm
    ->
Payment / Authorization
    ->
Errand Created
    ->
Agent Assignment
    ->
Live Tracking & Updates
    ->
Evidence
    ->
Delivery / Completion
    ->
Receipt / Rating / Support / History
```

An errand must not become eligible for assignment until all required request details and the applicable payment/authorization conditions have been satisfied.

---

# 5. Screen Inventory

| ID | Screen | Responsibility |
|---|---|---|
| ME-01 | Market Errand Landing | Explain service and provide entry points |
| ME-02 | Choose Errand Type | Buy Items, Package Pickup or Other Errand |
| ME-A01 | Select Shop or Market | Select or enter shopping location |
| ME-A02 | Add Items | Create and manage shopping list |
| ME-A03 | Substitution Preferences | Define replacement behaviour |
| ME-A04 | General Instructions | Add notes and optional references |
| ME-A05 | Delivery Details | Set delivery destination and recipient |
| ME-A06 | Review and Estimate | Review shopping request and charges |
| ME-B01 | Pickup Details | Set package collection details |
| ME-B02 | Package Details | Describe package and handling |
| ME-B03 | Delivery Details | Set package destination |
| ME-B04 | Review and Pay | Review package request and proceed |
| ME-C01 | Describe Request | Explain custom errand |
| ME-C02 | Location and Task Details | Dynamic task information |
| ME-C03 | Review Request | Confirm request before submission |
| ME-C04 | Manual Review / Quote | Show review, quote or rejection |
| ME-10 | Payment / Authorization | Verify required financial state |
| ME-11 | Agent Assignment | Show search and assignment |
| ME-12 | Live Tracking | Show fulfilment milestones |
| ME-13 | Purchase Evidence | Show item outcomes and receipt |
| ME-14 | Delivery Confirmation | Confirm delivery outcome |
| ME-15 | My Errands | List and filter requests |
| ME-16 | Errand Details | Show complete history and actions |

---

# 6. Flow A: Buy Items From a Shop

## ME-A01: Select Shop or Market

### Customer actions

The customer can:

- Search for a shop.
- Search for a market.
- Choose a nearby location.
- Select a saved location.
- Enter a custom shop manually.

### Data

- Shop/market name.
- Address.
- Precise map location.
- Shop contact, where available.
- Additional instructions.

### Validation

- Shopping location must be serviceable.
- A listed shop does not guarantee requested items are available.

---

## ME-A02: Add Items

Each item may support:

- Item name.
- Quantity.
- Unit.
- Brand preference.
- Size/variant.
- Quality/freshness preference.
- Estimated price or spending limit.
- Optional reference image.

### Actions

- Add item.
- Edit item.
- Remove item.
- Reorder items if required.

### Example

```text
Item: Tomatoes
Quantity: 2 kg
Preference: Fresh, medium size
Budget: Up to configured customer limit
```

---

## ME-A03: Substitution Preferences

Recommended options:

### No Substitution

Do not buy another product without customer approval.

### Contact Me

Contact the customer before replacing an unavailable item.

### Similar Alternative

Allow a similar alternative within the approved budget.

The selected rule must be visible to the assigned agent.

---

## ME-A04: General Instructions

Optional notes may include:

- Check expiry date.
- Choose fresh produce.
- Select the best quality.
- Contact me before substitution.
- Do not exceed my approved budget.

Optional reference images may be attached where supported.

---

## ME-A05: Delivery Details

Collect:

- Delivery address.
- Precise map location.
- Recipient name.
- Recipient phone number.
- Delivery instructions.

Only supported delivery options should be shown.

---

## ME-A06: Review and Estimate

Show:

- Selected shop.
- Items and quantities.
- Preferences.
- Substitution rules.
- Delivery address.
- Estimated item cost.
- Errand service fee.
- Delivery fee.
- Other disclosed charges.
- Estimated total.

The customer should be able to edit individual sections without restarting the flow.

---

# 7. Flow B: Pick Up a Package

## ME-B01: Pickup Details

Collect:

- Pickup business/person.
- Pickup address.
- Precise map location.
- Contact person.
- Contact phone number.
- Collection/reference number.
- Pickup instructions.

---

## ME-B02: Package Details

Collect:

- Package description.
- Package category.
- Approximate size.
- Approximate weight or configured band.
- Handling instructions.

Optional:

- Package photo.

Examples of handling:

- Fragile.
- Handle with care.
- Keep upright.

The backend must validate capacity and serviceability.

---

## ME-B03: Delivery Details

Collect:

- Destination.
- Recipient name.
- Recipient phone number.
- Delivery instructions.

Validate:

- Pickup serviceability.
- Destination serviceability.
- Package eligibility and capacity.

---

## ME-B04: Review and Pay

Show:

- Pickup location.
- Delivery destination.
- Package details.
- Service fee.
- Delivery fee.
- Other applicable charges.
- Total amount.

The next state depends on the approved payment model.

---

# 8. Flow C: Other Errand

## ME-C01: Describe Request

Customer enters:

- What they need done.
- Location.
- Relevant contact.
- Special instructions.

The UI must state clearly that some requests require review before acceptance.

---

## ME-C02: Location and Task Details

The form should be dynamic.

Possible fields:

- Task location.
- Destination.
- Contact person.
- Contact phone number.
- Requested date/time.
- Supporting notes.
- Attachments.

Do not force irrelevant fields onto every custom request.

---

## ME-C03: Review Request

Show:

- Description.
- Locations.
- Instructions.
- Contacts.

Then allow the customer to submit the request.

---

## ME-C04: Manual Review / Quote

Possible states:

- Submitted.
- Under Review.
- Quote Available.
- Awaiting Customer Acceptance.
- Awaiting Payment.
- Approved.
- Rejected.

If accepted:

1. Operations creates or confirms the quote.
2. Customer reviews the quote.
3. Customer accepts.
4. Customer pays where required.
5. Backend verifies payment.
6. Errand becomes eligible for assignment.

---

# 9. Pricing and Financial Model

## Buy Items

Potential components:

```text
Estimated Item Cost
+ Errand Service Fee
+ Delivery Fee
+ Approved Additional Charges
= Estimated Total
```

The estimated shopping cost may differ from actual shopping cost.

The system must support a controlled process for:

- Actual cost lower than estimate.
- Actual cost higher than estimate.
- Unavailable item.
- Approved substitution.
- Additional amount approval.
- Final reconciliation.

## Package Pickup

Pricing may depend on:

- Pickup distance.
- Delivery distance.
- Package size.
- Weight band.
- Handling requirements.
- Vehicle type.
- Service area.

## Other Errand

Pricing may be:

- Automatically estimated where supported.
- Manually quoted by operations.

The UI must clearly distinguish:

- Estimate.
- Approved quote.
- Actual reconciled amount.

---

# 10. Payment and Authorization Flow

Recommended state flow:

```text
Draft
->
Estimate Available
->
Customer Confirms
->
Payment / Spending Authorization
->
Backend Verification
->
Errand Eligible
->
Assignment
```

For manually reviewed errands:

```text
Submitted
->
Operations Review
->
Quote Available
->
Customer Accepts
->
Payment
->
Payment Verified
->
Assignment
```

Payment verification must happen server-side.

The app must not treat a local payment success response as the final source of truth.

---

# 11. Agent/Rider Assignment

After the errand becomes eligible:

```text
Errand Eligible
->
Searching for Agent
->
Agent Offered
->
Agent Assigned
->
Agent Accepted
->
In Progress
```

The system checks:

- Service area.
- Agent availability.
- Vehicle/capacity suitability.
- Job-type eligibility.
- Conflicting active assignments.

There must be at most one active assignment per errand.

---

# 12. Live Tracking and Status Updates

## Buy Items

```text
Searching for Agent
Agent Assigned
On the Way to Shop
Arrived at Shop
Shopping in Progress
Items Purchased
On the Way to You
Delivered
Completed
```

## Package Pickup

```text
Searching for Agent
Agent Assigned
On the Way to Pickup
Arrived at Pickup
Package Collected
On the Way to Destination
Delivered
Completed
```

## Other Errand

```text
Under Review
Quote Available
Awaiting Payment
Searching for Agent
Agent Assigned
Task in Progress
On the Way to Destination
Completed
```

Statuses displayed to the customer must come from authoritative backend events.

---

# 13. Purchase Evidence

For Buy Items, support:

- Item-level purchase outcome.
- Purchased items.
- Unavailable items.
- Substituted items.
- Actual shopping cost.
- Receipt.

This gives the customer visibility into:

```text
Estimated Cost vs Actual Cost
```

---

# 14. Delivery Evidence

Delivery may record:

- Delivery timestamp.
- Recipient confirmation.
- Configured proof of delivery.
- Delivery issue/exception.

The errand must not be marked completed until the required backend completion conditions are satisfied.

---

# 15. My Errands

Recommended filters:

- Active.
- Pending.
- Under Review.
- Completed.
- Cancelled.

Each card should show:

- Errand reference.
- Errand type.
- Current status.
- Date.
- Primary pickup/shop.
- Destination.

---

# 16. Errand Details

The detail screen should contain:

## Request

- Errand type.
- Original instructions.
- Pickup/shop.
- Delivery destination.

## Status

- Current status.
- Timeline.

## Agent

- Assigned agent when confirmed.

## Financial

- Estimate.
- Approved quote.
- Actual cost where applicable.
- Service fees.
- Payment status.
- Refund status where applicable.

## Evidence

- Receipt.
- Purchase evidence.
- Delivery confirmation.

## Actions

Depending on state:

- Contact support.
- View receipt.
- Track agent.
- Cancel.
- Report an issue.
- Rate service.

---

# 17. UI/UX Logic

## Progressive Disclosure

Do not show every field at once.

```text
Type
->
Relevant Details
->
Items / Package / Task
->
Delivery
->
Review
```

## Visible Progress

Example:

```text
1 Type -> 2 Details -> 3 Delivery -> 4 Review
```

Shopping may use:

```text
1 Type -> 2 Shop -> 3 Items -> 4 Delivery -> 5 Review
```

## Preserve Form State

When navigating backward:

- Preserve valid entered data.
- Do not force a restart.
- Support drafts where enabled.

## Shared States

Every major flow should support:

- Loading.
- Empty.
- Retryable error.
- Offline.
- Pending server confirmation.

---

# 18. Backend Architecture

Market Errand should use a dedicated domain module while reusing shared platform services.

## Core entities

```text
Errand
Errand Item
Errand Quote
Errand Assignment
Errand Status Event
Errand Evidence
Errand Delivery Confirmation
Errand Issue
Errand Refund
Shopping Reconciliation
Item Outcome
```

## Core invariants

1. Only relevant data is collected for the selected errand type.
2. At most one active agent assignment exists.
3. Payment state is separate from errand state.
4. Assignment state is separate from fulfilment state.
5. Actual shopping cost does not overwrite the original estimate.
6. Completion occurs only after required backend conditions.
7. Duplicate callbacks must not duplicate financial or fulfilment effects.
8. Material overrides are audited.

---

# 19. Conceptual API Requirements

Follow existing Go-Volts `/v1` conventions.

```text
POST   /v1/errands/drafts
POST   /v1/errands
GET    /v1/errands
GET    /v1/errands/{id}
PATCH  /v1/errands/{id}
POST   /v1/errands/{id}/cancel
```

Shopping:

```text
POST   /v1/errands/{id}/items
PATCH  /v1/errands/{id}/items/{itemId}
DELETE /v1/errands/{id}/items/{itemId}
```

Quote/estimate:

```text
GET    /v1/errands/{id}/estimate
GET    /v1/errands/{id}/quote
POST   /v1/errands/{id}/quote/accept
```

Tracking/evidence:

```text
GET /v1/errands/{id}/tracking
GET /v1/errands/{id}/events
GET /v1/errands/{id}/evidence
GET /v1/errands/{id}/receipt
```

Exact endpoint names may be aligned later with the final backend module conventions.

---

# 20. Admin and Operations Requirements

## Service Configuration

Admin/Operations should manage:

- Enabled service areas.
- Supported errand types.
- Allowed task categories.
- Capacity restrictions.
- Pricing rules.
- Manual review requirements.

## Manual Review

Operations should be able to:

- Review custom requests.
- Request clarification.
- Approve or reject.
- Create/revise quotes.

## Live Operations

Operations should monitor:

- Active errands.
- Unassigned errands.
- Failed assignment.
- Agent reassignment.
- Failed pickup.
- Failed delivery.
- Customer issues.

## Financial Operations

Authorized users should manage:

- Estimate review.
- Actual purchase reconciliation.
- Approved additional charges.
- Refunds.
- Audited adjustments.

---

# 21. Security and Privacy

The module must enforce:

- Customer ownership checks.
- Agent authorization.
- Service-area validation.
- Server-side payment verification.
- Idempotent state-changing operations.
- No duplicate active assignment.
- No duplicate completion.
- Immutable or append-only audit records for material actions.
- Access-controlled receipts and attachments.
- Least-privilege access to customer and recipient information.

---

# 22. Responsive Behaviour

The Flutter app must work on Android and iOS phone sizes.

## Narrow devices

- Keep primary actions reachable.
- Stack review content vertically.
- Avoid cramped side-by-side address fields.
- Keep item details readable.

## Larger phones

- Wider cards may be used.
- Preserve the same hierarchy and action order.

Respect safe areas and system navigation areas.

---

# 23. Acceptance Criteria

The module is ready for visual design and implementation when:

- The three errand types have clear entry points.
- Each type displays only relevant fields.
- Shopping items support quantity, preferences and substitution rules.
- Shop listing does not imply availability.
- Package requests validate serviceability and capacity.
- Estimates and quotes are clearly different.
- Required payment/authorization is verified before assignment.
- Actual shopping cost can be reconciled.
- Item substitutions and approvals are auditable.
- At most one active agent is assigned.
- Tracking uses authoritative backend events.
- Completion is backend-confirmed.
- Evidence and receipts are access-controlled.
- Cancellation, refund and issue states are separated from normal completion.
- Duplicate callbacks do not create duplicate financial or fulfilment effects.

---

# 24. Business Decisions to Finalize Later

These rules still need explicit Product/Operations decisions:

1. Who provides money for shopping purchases?
2. Exact spending authorization model.
3. Maximum shopping amount.
4. Rules when actual cost exceeds estimate.
5. Customer approval rules for substitutions.
6. Cancellation rules.
7. Refund rules.
8. Package size/weight/capacity limits.
9. Prohibited errand categories.
10. Delivery confirmation method.
11. Rider cash-handling policy.
12. Maximum item count.
13. Maximum distance.
14. Agent waiting-time rules.
15. Failed pickup rules.
16. Failed delivery rules.
17. Customer-agent communication rules.
18. Automatic pricing vs mandatory manual review for Other Errand.

These should be finalized in a dedicated **Market Errand Business Rules & Policy Matrix** before production launch.

---

# 25. Recommended Next Step

The next design stage should be:

1. Refine **Flow A: Buy Items From a Shop** down to individual screens and interactions.
2. Refine **Flow B: Pick Up a Package**.
3. Refine **Flow C: Other Errand**.
4. Create full-screen design images in grouped parts.
5. Reconcile the final business rules with the Master Technical Specification.
