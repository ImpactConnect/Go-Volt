# Go-Volts: Product Concept Note and Functional Scope

**Document type:** Product and developer handoff  
**Version:** 1.1  
**Date:** October 2026  
**Purpose:** Define the product vision, user roles, app platforms, screens, user journeys, business rules, visual direction and expected behaviour. This document intentionally excludes implementation technologies, system architecture, database schemas, API design and deployment instructions. Those belong in a separate technical specification.

---

## 1. Product Overview

Go-Volts is a Nigerian mobility and logistics platform for motorcycle-based delivery and, where legally permitted, passenger transportation. It connects customers, riders, stores, online sellers and external commerce platforms through one coordinated delivery and ride service.

Go-Volts is not only the delivery arm of Retail Ai. Retail Ai is one integration partner among several possible sources of delivery demand. Independent merchants can book deliveries through the Go-Volts merchant portal, while external websites and apps can integrate Go-Volts as their courier provider.

The platform has three primary applications:

1. **Customer mobile app:** For booking rides, sending parcels, tracking deliveries, managing payments, referrals, loyalty points, coupons and rewards.
2. **Rider mobile app:** For onboarding, availability, accepting jobs, navigation, pickup and delivery confirmation, passenger trips, earnings and support.
3. **Admin web app:** For operations, rider and merchant management, dispatch, pricing, financial oversight, promotions, referrals, loyalty configuration, coupons, customer support, safety and reporting.

A merchant-facing web portal and external delivery integration capability are also part of the product scope. The merchant portal may be a dedicated area within the web experience, with access controlled by merchant roles. External platforms should be able to create and track delivery requests through an agreed integration programme. The precise technical implementation will be defined separately.

### Product vision

Make rides and deliveries easier to book, safer to track, more transparent to pay for and simpler for businesses to fulfil across supported Nigerian service areas.

### Product goals

- Build a reliable delivery network supported by participating stores and external commerce platforms.
- Offer customers transparent fares, dependable tracking and a trusted service experience.
- Help riders access jobs, understand earnings and receive fair treatment.
- Give merchants a straightforward way to dispatch and monitor deliveries.
- Encourage repeat usage through a transparent referral, loyalty-point, wallet and coupon programme.
- Give administrators control over operating rules, pricing, promotions, service availability and platform performance.
- Expand into public parcel delivery, passenger rides and scheduled services in a controlled, legally compliant way.

---

## 2. Services and Business Channels

### 2.1 Go-Volts Store Delivery

Delivery of store orders placed through Retail Ai or other connected commerce systems. When an order is ready for dispatch, the originating store or platform submits a delivery request to Go-Volts. A suitable rider is assigned or accepts the job. The store and recipient can follow the delivery status, and completion is confirmed with the configured proof-of-delivery process.

### 2.2 Go-Volts Merchant Booking

Independent stores and businesses can register with Go-Volts without using Retail Ai. After approval, they can create delivery requests manually from the merchant portal. The merchant enters pickup details, recipient information, package details and delivery instructions, reviews the price, confirms the booking and follows the rider and delivery progress.

Merchant examples include supermarkets, pharmacies where permitted, restaurants, boutiques, bakeries, electronics shops, market vendors and social-commerce sellers. Each business remains subject to merchant approval, restricted-item rules and applicable operating policies.

### 2.3 External Platform Delivery Integration

Other stores' websites, mobile apps and order-management systems can integrate Go-Volts as a courier provider. Their customers continue to place orders on the originating platform. Go-Volts receives the delivery request, fulfils it and sends status updates back to the originating platform. The originating platform and Go-Volts must be able to identify the same order through agreed references.

The product must support merchant-specific permissions, pricing agreements, service availability, booking limits, cancellation rules and reporting. External integrations must not bypass Go-Volts' rider eligibility, service-zone, package-restriction or safety rules.

### 2.4 Go-Volts Send

A customer can book a rider to move an eligible parcel or item from one address to another. The customer declares the package type, size, approximate value where required, pickup and destination, and any handling instructions. The app shows the price and applicable restrictions before confirmation.

### 2.5 Go-Volts Ride

A customer books a passenger trip by selecting pickup and destination points. The app displays the fare estimate, available ride details and relevant safety information before confirmation. Once a rider accepts, the customer can track arrival, verify the rider and share the trip with a trusted contact.

Passenger rides are enabled only in approved service areas and subject to local regulations, vehicle eligibility and platform policy.

### 2.6 Scheduled Pickup (MVP)

**Scheduled Pickup is an MVP service, not a future feature.** It supports both a one-off future journey and recurring transport arrangements for school runs, work commutes, and other regular journeys. It is available as a prominent service entry on the customer home screen alongside Ride and Delivery, subject to enabled service areas and operational approval.

Scheduled Pickup has three connected but separate concepts:

- **Booking/trip:** one journey with its own pickup, destination, time, assigned driver, status, and outcome.
- **Recurring schedule:** the dates, weekdays, times, route, direction, exceptions, and rules that generate individual trips.
- **Subscription/package:** the commercial agreement covering a defined number of trips, its price, validity period, payment, expiry, and renewal.

A one-off future journey uses the same trip lifecycle but does not require a recurring subscription. A subscription being active does not mean that a driver has already been assigned to every future trip.

School transport is a high-responsibility use case and must not be treated as an ordinary passenger trip. The MVP must include school-specific pickup protocols, approved drivers, verified parent/guardian accounts, authorised recipient management, secure-code handover verification, operations-directed exceptions, milestone notifications, and an auditable handover record. Launch is conditional on applicable legal, insurance, safeguarding, and operational readiness approvals. See the dedicated Scheduled Pickup requirements later in this document.

---

## 3. User Roles

### Customer
Can manage their profile, book eligible services, pay, track bookings, access receipts, submit ratings, use coupons, earn and redeem loyalty points, invite friends and manage the ride wallet.

### Rider
Can apply to join, submit required documents, complete assessments, manage availability, accept eligible jobs, complete pickups and deliveries, handle passenger trips where permitted, view earnings and contact support.

### Merchant owner or manager
Can manage a business profile, branches and authorized staff; create and track deliveries; view delivery costs and reports; and manage payment arrangements allowed by the business agreement.

### Operations agent
Can monitor live jobs, assist customers and riders, manage permitted assignments and handle operational exceptions according to assigned permissions.

### Rider onboarding or safety officer
Can review rider documents, assessments, training, eligibility, incidents and re-verification requirements.

### Finance officer
Can review payment records, refunds, merchant settlements, rider payouts, wallet activity, promotional liabilities and reconciliation reports. Sensitive actions must be recorded.

### Marketing or promotions manager
Can configure approved referral campaigns, loyalty rules, coupons, campaign dates, eligibility and performance reporting, within assigned permissions.

### Administrator / super administrator
Can manage platform-wide settings, roles, service areas, pricing policies, promotions, rewards, operational rules and access. High-impact actions should require suitable authorization and leave an audit record.

---

## 4. App Platforms and Navigation

### 4.1 Customer Mobile App

**Primary navigation:** Home, Activity, Rewards, Wallet, Profile.

The home screen should make the main actions obvious: **Book a Ride**, **Send a Parcel**, **Track Delivery** and, when available, **Schedule a Service**. Contextual banners can show active offers without obstructing core booking actions.

### 4.2 Rider Mobile App

**Primary navigation:** Jobs, Earnings, Activity, Support, Profile.

The primary screen should focus on the rider's current work state: offline, online and waiting, job offer received, assigned job, pickup, in progress or completing a job. Job status and next action must be visually obvious and easy to use while stationary. The interface should not encourage unsafe phone interaction while riding.

### 4.3 Admin Web App

The admin web app should use a left-side navigation menu, a top bar with service area and account controls, and a main content area with tables, filters, charts, detail panels and action menus.

Suggested navigation groups:

- Overview
- Live Operations
- Trips and Deliveries
- Customers
- Riders
- Merchants and Integrations
- Pricing and Service Areas
- Payments and Finance
- Wallets and Loyalty
- Referrals and Coupons
- Support and Incidents
- Reports
- Settings and Access Control

### 4.4 Merchant Portal

The merchant portal should be optimized for desktop and tablet use, with a simple delivery creation workflow. Suggested navigation: Overview, Create Delivery, Deliveries, Branches, Team Members, Billing, Reports, Integration Details and Business Profile. Integration credentials and technical setup documentation should be available only to authorized merchant administrators. Technical API documentation belongs in a separate integration specification.

---

## 5. Customer App: Screens and Functional Requirements

### 5.1 Welcome and Account Access

**Screens:** Welcome, Sign Up, Sign In, Phone Verification, Forgot Access, Permissions Explanation.

**UI elements:** Go-Volts logo, short value statement, phone number field, password or approved access method, verification code input, primary action button, privacy and terms links.

**Behaviour:** Explain why location and notification permissions improve the service. Ask for permissions in context rather than immediately on first launch. A customer should be able to explore basic information before granting optional permissions, while booking requires the information needed to fulfil the booking.

### 5.2 Home

**UI elements:** Greeting, current service area, location selector, service cards, saved addresses, active booking card, promotional banner, rewards summary and bottom navigation.

**Primary actions:** Book a Ride, Send a Parcel, Track Delivery and view eligible scheduled services.

**Behaviour:** Show only services available in the customer's selected area. Do not advertise a service as bookable when it is not available in that area.

### 5.3 Booking a Ride

**Screens:** Pickup and Destination, Map Selection, Fare Estimate, Ride Options if applicable, Booking Confirmation, Searching for Rider, Rider Assigned, Driver Approaching, Active Trip, Trip Completed, Rating and Receipt.

**UI elements:** Map, pickup and destination fields, saved locations, location pin, fare breakdown, payment selector, coupon field, eligible wallet balance, points-redeem option where enabled, booking confirmation button, cancellation policy and safety controls.

**Flow:**

1. Customer selects pickup and destination.
2. App checks service availability and obtains an estimated fare.
3. Customer selects an eligible payment method and optionally applies a coupon or available ride-wallet balance.
4. App shows the final payable amount and relevant terms.
5. Customer confirms the booking.
6. The platform finds an eligible rider.
7. Customer sees rider identity and relevant vehicle details, estimated arrival and trip status.
8. Customer can share the trip and access help or emergency options.
9. Trip completion is recorded and the final receipt is shown.
10. Customer rates the trip and may receive loyalty points if the trip qualifies under the active programme rules.

**Important states:** No riders available, booking expired, rider cancelled, customer cancelled, payment failed, trip interrupted, trip disputed and emergency reported. Each state must offer an understandable next action.

### 5.4 Send a Parcel

**Screens:** Pickup Details, Recipient Details, Package Details, Quote, Payment, Rider Search, Tracking, Delivery Confirmation and Receipt.

**UI elements:** Sender contact, recipient name and contact, pickup and drop-off addresses, package category, size or weight bands, declared value if required, handling notes, restricted-item notice, fare quote, coupon and eligible wallet controls, payment selection and booking button.

**Flow:** Enter pickup and recipient details, describe the package, review restrictions and quote, pay or select an approved payment arrangement, confirm the booking, track the rider and receive delivery confirmation.

The app must explain that prohibited or restricted items may be refused. Declared value must not imply automatic insurance coverage. Applicable coverage, exclusions and claims instructions should be shown clearly.

### 5.5 Delivery Tracking

**UI elements:** Status timeline, map and appropriate rider location, ETA, rider identity, contact options, delivery reference, support action and proof-of-delivery status.

**Behaviour:** Show only information the customer is authorized to see. Recipient tracking links should be secure and limited to the relevant delivery. A recipient should not be forced to install the app just to track a parcel.

### 5.6 Activity and Receipts

**Screens:** Active Bookings, Ride History, Delivery History, Booking Details, Receipt, Cancelled Bookings and Help with a Booking.

**UI elements:** Status filters, date filters, reference number, fare, payment state, receipt action, report-a-problem action and rebook action where appropriate.

### 5.7 Profile and Safety

**Screens:** Personal Details, Saved Addresses, Trusted Contacts, Notification Preferences, Privacy, Terms, Help Centre and Account Settings.

Customers should be able to update their details, manage trusted contacts, review relevant privacy controls and request account support. Emergency actions must be clearly separated from routine support.

---

## 6. Customer Referral Programme

### 6.1 Purpose

The referral programme encourages customers to invite new customers to Go-Volts. Rewards must be transparent, configurable and resistant to abuse.

### 6.2 Customer Screens

**Referral Overview:** Shows the customer's unique referral code or share link, a short explanation of the offer, current campaign terms and a share action.

**Referral Activity:** Shows invited users using privacy-conscious labels, referral status, qualifying event status and rewards earned. Do not expose invitees' sensitive account or trip details.

**Referral Terms:** Explains who qualifies, the qualifying action, reward amounts, reward timing, expiry, limits and conditions for reversing fraudulent or refunded transactions.

### 6.3 Suggested Referral Flow

1. Existing customer opens Rewards or Referrals.
2. Customer shares their referral code or link.
3. New customer joins through the referral path and meets the campaign's new-user eligibility rules.
4. The new customer completes the defined qualifying action, such as a first eligible completed and paid ride.
5. The platform validates eligibility and checks for suspected abuse.
6. The referrer and/or referred customer receives the configured reward according to campaign rules.
7. Both users can view the reward status and applicable terms.

The admin must be able to choose whether a campaign rewards the referrer, the referred customer or both. The campaign must define whether rewards are issued as loyalty points, ride-wallet credit or a coupon. These reward types should not be treated as interchangeable.

### 6.4 Referral Controls

- Campaign start and end dates.
- Eligible service types and customer segments.
- New-user definition and qualifying event.
- Reward type and value for each party.
- Minimum spend or number of qualifying trips where applicable.
- Reward issuance delay and expiry.
- Per-customer and campaign-wide limits.
- Rules for cancelled, refunded or disputed trips.
- Fraud review and manual approval options.
- Referral performance report and export.

The platform should flag patterns such as self-referrals, repeated account creation or suspicious reward activity for review. Automated flags should not automatically accuse a customer of fraud.

---

## 7. Loyalty Points and Ride Wallet

### 7.1 Separate Concepts

The product must clearly distinguish between:

- **Loyalty points:** Promotional reward units earned under configurable programme rules.
- **Ride-wallet balance:** A monetary balance available to pay for eligible Go-Volts services.
- **Payment methods:** External payment options such as supported card or bank methods, subject to the available payment provider.
- **Coupons:** Promotional codes or offers that reduce an eligible booking's price under defined rules.

A customer should never be confused about whether a displayed balance is points, money or a coupon discount.

### 7.2 Loyalty Overview Screen

**UI elements:** Current points balance, points activity, how to earn, redemption value, redeem points action, expiry notices and programme terms.

The screen should explain how points are earned, when they become available, their configured value, whether they expire and which services they can be used for.

### 7.3 Earning Points

The admin can configure qualifying events, such as eligible completed rides, eligible completed deliveries, campaign participation or other approved actions. The system should calculate rewards according to the rule active at the time of the qualifying event and show the customer a clear reward explanation.

Only eligible completed transactions should earn points. Cancelled, refunded or fraudulent transactions should follow the configured reversal or review policy. Points should not be issued more than once for the same qualifying event.

### 7.4 Redeeming Points into Ride-Wallet Credit

Customers must be able to convert eligible loyalty points into a monetary ride-wallet credit, subject to the active redemption rules. Redeemed cash value is intended for payment for eligible Go-Volts ride services and must not be represented as withdrawable cash unless a separate approved policy explicitly permits that.

**Customer flow:**

1. Open Rewards and choose Redeem Points.
2. View available points, conversion rate, minimum redemption and any limits.
3. Enter or select the amount of points to redeem.
4. See the exact ride-wallet credit to be received before confirming.
5. Confirm redemption.
6. Points are deducted once and the corresponding credit appears in the ride wallet.
7. The customer receives a confirmation and can view the entry in both points activity and wallet history.

The conversion must be atomic from the user's perspective: a failed redemption must not leave points deducted without the corresponding wallet credit, or credit the wallet twice. The customer must see the applicable conversion rate before confirming.

### 7.5 Admin-Configurable Point Value

The admin should have a **Loyalty Settings** section where authorized staff can configure:

- Point earning rules by eligible service or campaign.
- Point value or conversion ratio into ride-wallet credit.
- Minimum points required for redemption.
- Maximum points or monetary value redeemable per transaction and within a defined period.
- Eligible services for earning and redemption.
- Reward availability delay, expiry and expiration reminders.
- Campaign-specific multipliers or bonus points, where enabled.
- Whether points are issued immediately after completion or after a review period.
- Effective start date and end date for a rule.
- Programme terms and customer-facing explanation.

Changes must apply prospectively unless an explicitly approved campaign rule says otherwise. Existing point entries and wallet credits must retain their original recorded value and history. Admins must be able to preview the customer-facing effect before publishing changes.

### 7.6 Ride Wallet Screens

**Wallet Overview:** Available ride-wallet balance, recent transactions, top-up or payment options if enabled, and a clear note describing allowed uses.

**Wallet Activity:** Credits, redemptions, promotional credits, ride payments, reversals and adjustments, each with a reference, date, status and description.

**Wallet Use at Checkout:** Shows the available eligible balance, amount applied, remaining amount to pay and whether another payment method is required.

Wallet funds should have clear source labels, such as customer-funded balance, redeemed points or promotional credit. The product must define which balance types can pay for which services and whether promotional credits expire. Customer-funded money and promotional credit must not be silently merged in a way that obscures restrictions.

Any feature that allows wallet top-ups, cash withdrawals, transfers between customers or redemption outside Go-Volts requires a separate business, risk and compliance decision before being enabled.

---

## 8. Coupons and Promotional Offers

### 8.1 Customer Coupon Screens

**Available Offers:** Lists active offers the customer may use, with discount, eligible service, validity period and key conditions.

**Enter Coupon:** Allows a customer to enter a code during booking or select an eligible saved offer.

**Coupon Details:** Shows the discount type, maximum discount, minimum spend, eligible service, validity, usage limit and exclusions.

**Applied Discount Summary:** Shows the original fare, coupon discount, wallet credit applied, points redemption if applicable and final amount due. Avoid presenting discounts in a way that hides the actual payable amount.

### 8.2 Coupon Types to Support

- Fixed monetary discount.
- Percentage discount with an optional maximum discount.
- First-ride or first-delivery offer.
- Service-specific coupon.
- Customer-segment or campaign-specific coupon.
- Merchant-sponsored offer where an agreement exists.
- Referral-linked coupon.
- Limited-use or single-use coupon.
- Scheduled campaign or time-limited offer.

The first release does not need every coupon type active, but the product design should allow the admin to manage them consistently.

### 8.3 Admin Coupon Management

**Coupon List Screen:** Search, filter and sort coupons by status, code, type, service, date and campaign. Show usage count and current status.

**Create/Edit Coupon Screen:** Fields should include:

- Coupon name and unique code.
- Description and customer-facing terms.
- Discount type and discount value.
- Maximum discount amount where relevant.
- Minimum booking value where relevant.
- Eligible services and service areas.
- Eligible customer segments or specific customers, where allowed.
- Start date, end date and applicable time window.
- Total usage limit and per-customer usage limit.
- New-customer-only setting where relevant.
- Whether it can be combined with wallet credit, loyalty redemption or another coupon.
- Campaign owner or funding source where relevant.
- Status: draft, scheduled, active, paused, expired or archived.

**Coupon Detail Screen:** Shows configuration, usage history, redemptions, failures, attributed discount cost and performance.

### 8.4 Coupon Validation Rules

- Validate a coupon before confirming the booking.
- Explain why a coupon is invalid or unavailable, without exposing internal security rules.
- Recheck eligibility when the booking is confirmed.
- Prevent usage beyond configured limits when multiple customers try to redeem a limited offer at once.
- Record the exact coupon rule and discount applied to each booking.
- Reverse or adjust promotional accounting when a booking is cancelled or refunded according to the published policy.
- Do not stack discounts unless the campaign explicitly permits it.

---

## 9. Checkout, Discounts and Reward Order

The customer must see a clear, itemized checkout summary. The final price calculation should distinguish:

1. Base fare and applicable trip or delivery charges.
2. Any approved additional charges.
3. Coupon discount.
4. Loyalty points redemption converted to ride-wallet credit, if the customer chooses to redeem before checkout.
5. Eligible ride-wallet credit applied to the booking.
6. Remaining amount payable through another accepted payment method.

The product owner must define a single, consistent order of applying offers and wallet credit. The app must show the outcome before the customer confirms payment. A coupon, point redemption or wallet balance must not be applied twice to the same booking.

Rewards and coupons must not alter the rider's agreed earnings unexpectedly. Where a discount is funded by Go-Volts or a merchant, the relevant funding and settlement treatment must be clear to operations and finance teams.

---

## 10. Rider App: Screens and Functional Requirements

### 10.1 Application and Onboarding

**Screens:** Welcome, Rider Application, Personal Information, Identity and Documents, Vehicle Details, Guarantor or Reference Details where required, Assessment, Training, Application Status and Support.

**UI elements:** Progress steps, document upload, capture instructions, expiry dates, application checklist, status messages and contact-support action.

Riders must not be shown as eligible to accept jobs until the required verification and approval steps are complete. Eligibility may differ by service type. A rider approved for parcel delivery is not automatically approved for passenger trips or school-run services.

### 10.2 Rider Home and Availability

**UI elements:** Online/offline toggle, current service zone, job status, connection status, safety reminder, daily summary and support shortcut.

When offline, explain why the rider cannot go online if a required condition is missing, such as an expired document or an unsupported service area.

### 10.3 Job Offer

**UI elements:** Job type, pickup distance, estimated trip distance and duration where available, destination area, package or service information appropriate to the job, expected earnings, acceptance deadline and accept/decline actions.

Do not reveal unnecessary recipient personal data before acceptance. Do not offer jobs that conflict with rider eligibility, vehicle requirements, service restrictions or an existing incompatible assignment.

### 10.4 Pickup and Delivery Workflow

**Screens:** Job Accepted, Navigate to Pickup, Arrived at Pickup, Pickup Verification, In Transit, Arrived at Destination, Delivery Verification, Completed and Exception Report.

**Delivery-specific elements:** Pickup reference, seal identifier if used, pickup photo, package condition, recipient contact options, delivery OTP and proof-of-delivery capture.

**Passenger-trip elements:** Rider and vehicle verification, trip start and end actions, relevant safety controls and an emergency support path.

The app should make the next valid action obvious. If a rider cannot complete a delivery, they must choose a reason and follow the appropriate return, failed-delivery or support procedure rather than simply closing the job.

### 10.5 Earnings

**Screens:** Earnings Summary, Job Earnings, Commission Breakdown, Payout History and Incentives.

Show gross job value where appropriate, rider earnings, platform deductions, adjustments, payout status and references. The displayed earnings must match the platform's recorded financial records. Any incentive programme must show its qualifying rules and status.

### 10.6 Rider Profile and Support

Include personal details, vehicle details, document status, service eligibility, training status, notifications, help centre, incident reporting and account status. Riders should be able to raise a payout dispute or report an unsafe customer or situation.

---

## 11. Admin Web App: Screens and Functional Requirements

### 11.1 Overview Dashboard

**UI elements:** KPI cards, date and service-area filters, trend charts, live activity summary and alerts.

Suggested metrics: bookings created, completed trips, deliveries completed, cancellation rate, average pickup time, delivery time, active riders, merchant activity, gross booking value, platform revenue, contribution margin, coupon cost, loyalty points issued and redeemed, wallet liabilities and referral conversions.

Every metric should have a clear definition and time period. Dashboard totals should reconcile with detailed reports.

### 11.2 Live Operations

A map and work queue showing eligible active riders, unassigned jobs, assigned jobs, overdue pickups, trips in progress and operational exceptions.

Authorized staff can inspect a booking, contact the relevant parties, assign or reassign a rider where policy allows, record a reason for manual intervention and escalate an incident. Manual overrides should be logged.

### 11.3 Booking, Trip and Delivery Management

Search and filter by reference, source, customer, merchant, rider, status, date and service area. The detail view should show the booking timeline, fare snapshot, relevant contact details, delivery evidence, payment status and support history according to staff permissions.

### 11.4 Customer Management

View customer profile, eligible account status, booking history, support cases, referral activity, loyalty balance, wallet activity and coupon usage. Access to sensitive details must be restricted. Staff should not be able to edit financial balances without an authorized adjustment workflow and reason.

### 11.5 Rider Management

Manage applications, document review, assessments, training, vehicle eligibility, service tiers, probation, active status, suspension, incidents and re-verification. Record the reason and staff member for consequential decisions. Riders should have a defined review or appeal route where appropriate.

### 11.6 Merchant and Integration Management

**Merchant list:** Business name, status, service area, branch count, booking volume, settlement status and account owner.

**Merchant profile:** Business details, approved branches and pickup locations, authorized staff, pricing agreement, allowed services, package restrictions, payment terms, booking history, reports and support cases.

**Integration overview:** Connected platform name, integration status, allowed functions, request volume, error summary, last activity and assigned support contact. Sensitive integration credentials should be shown only where strictly necessary and never exposed to unauthorized staff.

### 11.7 Pricing and Service Areas

Admin users with the right permission can configure base fares, distance bands, minimum fares, waiting charges, approved surcharges, service-specific pricing, merchant contracts and service-zone availability. Any surge or dynamic pricing policy must be transparent, bounded and approved before use.

Pricing changes should have effective dates and previews. Existing bookings must retain the fare snapshot shown and accepted at booking time, except for clearly disclosed and authorized adjustments.

### 11.8 Payments and Finance

Screens should cover payment transactions, refunds, rider payouts, merchant settlements, commissions, wallet movements, promotional credits, reconciliation exceptions and financial reports.

Financial actions should show status, amount, currency, reference, related booking, reason and history. Admin users must not directly overwrite a balance without a traceable adjustment entry. Failed and pending transactions should be easy to identify and resolve.

### 11.9 Wallet and Loyalty Administration

**Loyalty Dashboard:** Points issued, points redeemed, points expired, outstanding points liability where tracked, ride-wallet credit created from points, qualifying event counts and campaign performance.

**Loyalty Settings:** Configure earning rules, conversion value, redemption minimums and maximums, eligible services, expiry, issuance timing, campaign multipliers and effective dates.

**Wallet Management:** Search customer wallets, inspect transaction history, review promotional and customer-funded balances, investigate failed movements and perform approved adjustments through a controlled workflow.

**Adjustment controls:** Require a reason, reference and appropriate authorization. Material adjustments should support a second-person approval policy. The admin interface must make it clear that an adjustment changes the financial record and should not be used as an ordinary balance-edit field.

### 11.10 Referral Administration

**Screens:** Campaign List, Create/Edit Campaign, Campaign Detail, Referral Activity, Flagged Activity and Performance Report.

Admin-configurable fields include campaign name, start and end dates, eligible customers and services, referrer reward, referred-customer reward, reward type, qualifying action, minimum spend if applicable, issuance delay, expiry, usage limits, exclusions, funding source and status.

Campaign reporting should include invitations, sign-ups, qualifying conversions, rewards issued, reversals, cost and conversion rate. Staff should be able to review flagged activity and record decisions without exposing unnecessary personal information.

### 11.11 Coupon Administration

Provide the coupon list, create/edit form, detail view, redemption history, usage limits, scheduling, pause/resume controls and performance reports described in Section 8. All changes should be permission-controlled and auditable.

### 11.12 Support and Incident Management

Support queue with category, severity, assigned agent, status, response deadline and linked customer, rider, merchant or booking. Incident records should support evidence, notes, actions taken, escalation and resolution. Sensitive safety cases should have stricter access controls than ordinary support requests.

### 11.13 Roles, Settings and Audit History

Manage staff accounts, role permissions, service availability, cancellation rules, restricted items, customer-facing policy text, notification templates, support contacts and audit history. Destructive or high-impact actions should require confirmation and, where appropriate, additional approval.

---

## 12. Merchant Portal: Screens and Functional Requirements

### 12.1 Business Registration

Capture business name, business category, contact details, operating address, branches, authorized contact and required verification information. Show the approval status and outstanding requirements. An unapproved merchant should not be able to create live bookings unless explicitly allowed by policy.

### 12.2 Merchant Dashboard

Show delivery counts, pending pickups, in-progress deliveries, completed deliveries, failed deliveries, spend and relevant account notices.

### 12.3 Create Delivery

Required fields should include pickup branch or address, pickup contact, recipient details, destination, package category, package size or weight band, declared value where applicable, handling instructions, preferred pickup time if supported and reference from the merchant's own order system.

The portal should show a quote and booking summary before confirmation. Merchants should be able to create one booking at a time and, in a later release, upload a batch of deliveries using a clearly documented template.

### 12.4 Deliveries and Tracking

Provide search, filters, delivery details, status timeline, rider tracking when available, delivery proof, failure reason, cancellation eligibility and return request where supported.

### 12.5 Team, Branches, Billing and Reports

Merchant owners can manage authorized staff and branch access. Billing views should show charges, invoices, payment status, settlement or credit terms, and downloadable delivery reports. Staff access should be limited to assigned branches and permitted actions.

### 12.6 External Platform Integrations

The product must support approved external platforms that want to book and track Go-Volts deliveries from their own websites or apps. Each integration needs an agreed onboarding and testing process, clear ownership of customer communication, duplicate-booking prevention, status mapping, cancellation rules and support escalation. Detailed endpoint definitions and integration examples belong in the separate technical specification.

---

## 13. Core End-to-End Flows

### 13.1 Retail Ai Store Order

1. Customer places an order through Retail Ai.
2. Store prepares and marks the order ready for dispatch.
3. Retail Ai submits the delivery request to Go-Volts.
4. Go-Volts validates the request and returns a delivery reference.
5. Dispatch identifies eligible riders and offers or assigns the job.
6. Rider accepts and proceeds to pickup.
7. Pickup is verified, including package seal or evidence where required.
8. Recipient receives tracking updates.
9. Rider completes delivery using the required confirmation process.
10. Go-Volts sends the final status to Retail Ai and records evidence and financial outcomes.

### 13.2 Independent Merchant Portal Booking

1. Merchant registers and is approved.
2. Merchant selects a branch or enters pickup details.
3. Merchant enters recipient and package information.
4. Go-Volts validates service availability and restrictions.
5. Merchant sees the quote and confirms the booking using the permitted payment arrangement.
6. Dispatch assigns a rider.
7. Merchant and recipient follow status updates.
8. Rider confirms pickup and delivery.
9. Merchant sees the final delivery record, charge and proof of delivery.

### 13.3 External Platform API Delivery

1. An approved external platform creates an order on its own system.
2. It submits a delivery request to Go-Volts using its agreed integration.
3. Go-Volts validates the request and returns a unique delivery reference or a clear error.
4. The external platform stores the reference against its order.
5. Go-Volts dispatches the job and sends status updates as the delivery progresses.
6. The external platform presents suitable status information to its customer.
7. Go-Volts records delivery proof and final financial status.
8. Both parties can reconcile their records using the agreed references.

Repeated requests, delayed responses and status retries must not create duplicate jobs or inconsistent delivery states.

### 13.4 Loyalty Redemption and Ride Payment

1. Customer checks the current points balance and conversion terms.
2. Customer converts an eligible amount of points into ride-wallet credit.
3. The app confirms the point deduction and corresponding credit.
4. Customer books a ride and reviews the fare.
5. Customer chooses to apply eligible ride-wallet credit and any permitted coupon.
6. The app displays the final amount due.
7. Customer confirms payment.
8. The booking and financial records show the wallet amount applied, external payment if any, discount and final outcome.
9. If the booking is cancelled or refunded, the correct reversal or credit policy is applied and recorded.

### 13.5 Coupon Redemption

1. Customer selects a service and enters booking details.
2. Customer selects or enters a coupon.
3. The app checks eligibility and displays the discount and conditions.
4. Customer confirms the booking.
5. The coupon's usage limit is reserved or consumed according to the booking and payment rules.
6. The final booking records the exact discount.
7. If the booking fails or is cancelled, coupon usage is handled according to the published campaign policy.

### 13.6 Rider Incident

1. Rider or customer raises an incident or emergency alert.
2. The platform records the incident and relevant booking reference.
3. The alert reaches the designated response channel.
4. Authorized staff follow the escalation procedure and contact the relevant parties or emergency services as appropriate.
5. Evidence, actions, status and outcome are recorded.
6. Any insurance claim or account action follows the applicable review process.

---

## 14. Visual Design and Brand Theme

The Go-Volts logo uses black and green. The app should feel modern, dependable, clear and energetic, with strong readability and simple task-focused screens.

### 14.1 Suggested Theme Tokens

These are proposed starting values and should be checked against the official logo artwork before final design approval.

- **Primary green:** `#18A957` for primary actions, active states and positive progress.
- **Deep green:** `#107A40` for pressed states, strong accents and selected navigation.
- **Black / near-black:** `#151515` for headings, navigation and high-contrast elements.
- **White:** `#FFFFFF` for main surfaces and text on dark backgrounds where appropriate.
- **Light background:** `#F5F7F5` for page backgrounds and grouped sections.
- **Border / divider:** `#E2E7E2` for subtle boundaries.
- **Secondary text:** `#667067` for supporting labels.
- **Success:** use a green treatment with an icon and text, not color alone.
- **Warning:** amber, such as `#B7791F`, paired with a clear warning label.
- **Error:** red, such as `#C62828`, paired with a clear error label.

The black and green brand should dominate, but not every component needs to be green. Reserve green for meaningful actions and active states. Use neutral surfaces for long forms and data-heavy admin screens. Ensure text and controls have accessible contrast.

### 14.2 Components

- Primary button: green fill, high-contrast text, clear action label.
- Secondary button: white or neutral fill with a defined border.
- Destructive button: red treatment and confirmation where appropriate.
- Input fields: clear labels, helpful examples, visible error messages and sufficient touch size.
- Status chips: text plus icon or shape; do not rely on color alone.
- Cards: restrained borders and spacing, with clear information hierarchy.
- Maps: use distinct markers for pickup, destination and rider; include a list or status alternative for users who cannot interpret the map.
- Bottom navigation: simple icons with labels on customer and rider mobile apps.
- Admin tables: readable rows, visible status, filters, pagination and responsive detail panels.
- Loading states: skeletons or progress indicators with a clear explanation when a task takes time.
- Empty states: explain what is missing and provide a useful next action.
- Error states: explain what happened, whether anything was charged and how to retry or get help.

### 14.3 Writing and Tone

Use plain, friendly English that is easy to understand. Keep fare, coupon, reward and wallet language precise. Use local place names and address details when provided by the user, but do not assume an address is accurate without confirmation. Avoid promising guaranteed arrival times or insurance coverage when those depend on external conditions or policy terms.

### 14.4 Responsive Behaviour

Customer and rider apps are mobile-first. The admin web app should work on common laptop and tablet sizes. The merchant portal should be comfortable on desktop and tablet and usable on mobile for basic tracking and urgent updates.

---

## 15. Notifications and Communication

Notifications should be event-based, useful and non-duplicative.

### Customer notifications

- Booking confirmed.
- Rider assigned and approaching.
- Pickup completed and delivery in progress.
- Delivery completed or failed.
- Payment success, failure, refund or adjustment.
- Coupon expiry or relevant promotion, where consent and settings permit.
- Loyalty points earned, redeemed, expiring or reversed.
- Referral reward pending, approved or reversed.
- Wallet credit or debit.
- Safety incident or support update.

### Rider notifications

- Eligible job offer.
- Assignment or reassignment.
- Pickup or delivery instruction changes.
- Document expiry and onboarding reminders.
- Payout status.
- Incident or support updates.

### Merchant notifications

- Booking accepted.
- Rider assigned.
- Pickup completed.
- Delivery completed, failed or returned.
- Billing and reconciliation updates.
- Integration issues that require merchant action.

Users should be able to manage non-essential marketing notifications. Critical transaction and safety notices should follow clearly explained service settings and applicable requirements.

---

## 16. Product Rules and Edge Cases

The product should explicitly handle:

- No eligible rider available.
- Rider accepts and then cancels.
- Customer or merchant cancels after dispatch.
- Pickup address is wrong or inaccessible.
- Recipient is unavailable.
- Delivery OTP does not match.
- Package is damaged, opened or does not match the declaration.
- Restricted item is discovered.
- Rider loses network connectivity during a job.
- Location updates are delayed or inaccurate.
- Payment is pending, failed, repeated or reversed.
- Merchant integration sends a duplicate request.
- Coupon expires or reaches its limit while a customer is checking out.
- Two requests try to use the final available coupon allocation at the same time.
- Loyalty points are earned twice due to a repeated event.
- Redemption is interrupted after points are deducted but before wallet credit appears.
- A trip earning points is later refunded or disputed.
- Wallet balance is insufficient or only part of it is eligible for the selected service.
- Referral eligibility is disputed or suspicious activity is flagged.
- Admin changes a reward or pricing rule while a customer is booking.
- A merchant has multiple branches and users with different permissions.
- An account is suspended while it has active bookings or unresolved financial entries.

For each case, define the customer-facing message, allowed next action, financial effect, staff escalation and audit requirement. Never leave the customer uncertain about whether a booking exists or whether money was taken.

---

## 17. Security, Privacy and Trust Requirements

This section describes product behaviour, not implementation technology.

- Collect only information required for service delivery, safety, legal obligations and support.
- Explain why identity, location, contact and document information is needed.
- Limit visibility of customer, rider and recipient information to authorized roles and relevant stages of a job.
- Protect tracking links and avoid exposing a customer's full booking history through a shared link.
- Maintain a history of important account, payment, reward, pricing and administrative actions.
- Provide clear procedures for account suspension, appeal, incident review and data-related requests.
- Restrict access to identity documents, incident evidence, financial records and child-related information.
- Define retention periods for location data, documents, delivery evidence and support records.
- Explain restricted items, package declarations, insurance limitations, cancellation policies and refund conditions before relevant confirmation steps.
- Use an explicit permission and approval process for staff actions that affect money, customer safety or rider eligibility.

---

## 18. Reporting and Success Measures

### Operations

- Booking-to-assignment time.
- Average rider arrival time.
- Delivery completion time.
- Completion and cancellation rates.
- Failed delivery and return rates.
- Rider availability and utilization by service area.
- Incidents per defined number of trips.

### Customer experience

- Customer rating and complaint rate.
- Repeat booking rate.
- Booking abandonment rate.
- Customer support response and resolution time.
- Coupon usage and repeat use after promotions.

### Merchants and integrations

- Active merchants and branches.
- Delivery volume per merchant.
- Merchant repeat usage and retention.
- API booking success and failure rates.
- Delivery status update reliability.
- Merchant settlement and reconciliation exceptions.

### Financial performance

- Gross booking value.
- Platform revenue and contribution margin per service.
- Rider payout timeliness.
- Refunds and payment failures.
- Promotional discount cost.
- Referral campaign acquisition cost.
- Loyalty points issued, redeemed and expired.
- Ride-wallet credit issued and used.
- Outstanding wallet and promotional-credit liabilities where applicable.

### Rider welfare

- Rider retention.
- Earnings per active hour and per completed job.
- Payout delays and disputes.
- Training completion and document compliance.
- Rider-reported safety concerns.

All metrics need agreed definitions and should be filterable by date, service, location and relevant business source.

---

## 19. Suggested Delivery Phases

### Phase 1: Core delivery MVP

- Customer and rider mobile apps.
- Admin web app with rider approval and operational monitoring.
- Retail Ai delivery integration.
- Independent merchant registration and manual delivery booking.
- Delivery assignment, tracking, pickup and proof of delivery.
- Core payment records, receipts, support and reporting.
- Basic referral and coupon foundations should be planned in the product structure even if campaigns are activated after core delivery is stable.

### Phase 2: Merchant expansion and customer engagement

- External platform delivery integration capability.
- Merchant reporting, branches and business payment arrangements.
- Customer referral campaigns.
- Configurable coupons and promotion reporting.
- Loyalty earning, points history and admin-configurable conversion to ride-wallet credit.
- Wallet use at eligible ride checkout with full transaction history.

### Phase 3: Public mobility and business services

- Public passenger rides in approved areas.
- Customer scheduled bookings where operationally supported.
- Business accounts, bulk delivery workflows and enhanced reports.
- Additional payment methods and service-specific pricing as approved.

### Phase 4: Advanced services

- School-run service only after dedicated safety, legal and operational approval.
- Errands and additional merchant services.
- Commuter subscriptions, advanced dispatch optimization and rider welfare partnerships.
- Further automation and analytics based on real operating data.

The order of phases can change based on client priorities, but safety, financial correctness and legal eligibility are release gates, not optional enhancements.

---

## 20. Acceptance Criteria for the First Release

The first release should not be considered ready until the team can demonstrate that:

1. A customer can create and track an eligible delivery.
2. An approved rider can accept, collect and complete that delivery.
3. Pickup and delivery evidence is captured according to the service rules.
4. Admin staff can monitor the job and resolve a documented exception.
5. Retail Ai can submit a delivery request and receive status updates without creating duplicate jobs on retries.
6. An approved independent merchant can create a delivery through the portal.
7. The system records the agreed fare, payment outcome and rider earnings for each completed job.
8. Customers receive understandable notifications and receipts.
9. Role restrictions prevent unauthorized access to sensitive customer, rider, merchant and financial information.
10. Failed payment, cancellation, no-rider and failed-delivery cases have defined outcomes.
11. The brand theme is consistent and the main customer and rider tasks are usable on supported mobile devices.
12. Operational staff have a documented incident response process before live customer use.

Before enabling referrals, coupons, points redemption and wallet credit in production, additionally verify:

13. Admins can create, preview, schedule, pause and audit promotional campaigns.
14. A coupon cannot exceed its usage limits or be applied contrary to its eligibility rules.
15. A qualifying referral event cannot issue duplicate rewards.
16. Loyalty points are earned only for eligible events and can be traced to their source.
17. Admins can change the point conversion rule with an effective date, and previous entries retain their recorded value.
18. A points redemption cannot deduct points without issuing the matching ride-wallet credit.
19. Wallet credit is applied only to eligible services and the checkout shows the final amount clearly.
20. Reversals for refunds, cancellations or fraudulent activity follow published rules and remain visible in the history.
21. Customers can see their points, wallet transactions, coupon status and reward terms.
22. Finance staff can reconcile rewards, wallet credits, coupon discounts and actual booking payments.

---

## 21. Decisions Required from the Product Owner

The following business decisions should be confirmed before the technical specification is finalized:

- First launch city and legally permitted service zones.
- Which services are available at launch and which remain disabled.
- Whether customer wallet top-ups are supported at launch or wallet credit comes only from approved rewards and adjustments.
- Whether redeemed loyalty value is usable only for passenger rides or also for other Go-Volts services. The current product requirement is that redeemed value can pay for ride services.
- Exact point conversion value, earning rules, minimum redemption and expiry policy. Admins must be able to configure these values.
- Whether points have monetary value only when redeemed or are also used for status tiers.
- Referral qualifying event, reward recipient, reward type, issuance delay and limits.
- Whether coupons can be combined with wallet credit or points redemption.
- Who funds each coupon or reward: Go-Volts, merchant or another approved partner.
- Refund and cancellation rules for customer-funded balances, promotional wallet credits, coupons and redeemed points.
- Merchant approval requirements, billing model and payment terms.
- Merchant delivery price model and whether merchants can have contract-specific rates.
- Rules for declared package value, prohibited items and insurance coverage.
- Rider acceptance, reassignment, cancellation and waiting-time policies.
- Customer support hours and emergency response responsibilities.
- School-run safeguarding, transport legality and operational requirements before that service is offered.
- Data retention and privacy policy for location history, identity documents, delivery photos and incident records.

Where a decision is not yet confirmed, the design should label it as configurable or pending approval rather than inventing a fixed business rule.

---

## 22. Scope Boundary: Separate Technical Specification

This concept note intentionally does not prescribe:

- Programming languages, frameworks or libraries.
- Hosting, cloud services or deployment environments.
- Database schema or detailed entity relationships.
- API endpoint definitions, request and response formats or webhook payloads.
- Authentication implementation or secret management.
- GPS sampling intervals, real-time transport mechanisms or dispatch algorithms.
- Payment provider integration details or settlement implementation.
- Queue, caching, background-job or monitoring infrastructure.
- CI/CD, test automation implementation or infrastructure configuration.

The separate technical specification should translate this product scope into architecture, data models, API contracts, state machines, security controls, integration contracts, testing strategy and deployment plan.

---

## 23. Summary for Developers and AI Coding Agents

Build Go-Volts as a multi-channel Nigerian mobility and logistics product, not a Retail Ai-only delivery feature. It must support customer and rider mobile apps, an admin web app, an independent merchant portal and external commerce platforms that integrate Go-Volts as their courier provider.

Keep the customer, rider, merchant and admin experiences distinct, with clear roles and permissions. Use a consistent black-and-green brand theme, accessible controls, clear empty/error/loading states and plain language. The customer experience must include ride and parcel booking, tracking, receipts, support, referrals, coupons, loyalty points and a ride wallet. Admins must control referral campaigns, coupon rules, point earning and point-to-wallet conversion values through auditable settings. Loyalty redemption creates eligible ride-wallet credit; it must not be presented as unrestricted cash or a cash withdrawal feature.

Prioritize correct booking states, reliable delivery proof, financial reconciliation, transparent pricing, rider safety, privacy and operational exception handling. Treat school transport and other high-responsibility services as separately gated features. Do not invent unresolved business rules. Record assumptions and ask for product-owner decisions where required.

**This document defines what the product should do and how users should experience it. The companion technical specification will define how the software is built.**


---

## 24. Scheduled Pickup: Complete MVP Requirements

This section records the product-owner-approved requirements for Scheduled Pickup. It supersedes any earlier wording that describes scheduled rides or school runs as future-only capabilities. Technical implementation details belong in the companion technical specification.

### 24.1 MVP scope and use cases

The customer can:

- Book a one-off trip for a future date and time.
- Create a recurring weekly or monthly arrangement for school, work, or another regular destination.
- Configure one-way journeys or round trips. A round trip is represented as two separately scheduled and priced journey legs, each with its own time, pickup, destination, assignment, status, and outcome.
- Use a fixed subscription/package with a defined number of trips or pay for scheduled trips individually.
- Request a preferred driver. The request is a preference, not a guarantee; an eligible alternative driver is assigned automatically if the preferred driver is unavailable, and the customer is notified.
- Review, skip an eligible trip, pause/resume a recurring plan, request changes, cancel a plan, see trip history and entitlement balance, and manually renew a package.

Initial use cases include school runs, work commutes, and other recurring trips. School-run features are part of the MVP but may only be enabled where Go-Volts has approved the legal, safeguarding, insurance, service-area, and operating arrangements.

### 24.2 Customer setup flow

The guided setup should collect and validate:

1. Trip purpose: school run, work commute, or other.
2. Booking type: one-off future journey or recurring arrangement.
3. Pickup address and precise pickup point, destination address and destination point, address notes and safe pickup instructions.
4. Direction: one-way or round trip. For round trips, collect outbound and return times and locations independently. Each leg is a separate trip entitlement and fare unless a future explicitly approved bundle rule says otherwise.
5. Schedule: start date, end date or package period, selected weekdays, pickup times per leg, local timezone, school/work calendar exceptions, holidays and excluded dates.
6. Passenger details and contact information appropriate to the service. For a school run, record the child/passenger profile, verified parent or guardian, school, school contact/protocol, authorised handover contacts, and required emergency contacts.
7. Preferred driver, if requested, with an explicit statement that availability is not guaranteed.
8. Price and payment model: individual trip pricing or fixed subscription with a defined number of trips; full price, number of included trips, period, expiry, skip/no-show/cancellation terms, refund rules, and manual renewal terms.
9. Review and submit for Go-Volts operational review.

Use a multi-step flow with a progress indicator, saved addresses, clear validation, and a final review. Do not hide critical terms in secondary screens.

### 24.3 Pricing, subscriptions and payment

Approved commercial rules:

- Supported pricing models: pay-per-scheduled-trip and fixed weekly/monthly subscription/package with a defined number of trip entitlements. Unlimited-trip packages are not part of the agreed baseline.
- Subscription entitlements are defined trip units. Each leg of a round trip counts as a separate trip. Package details must state the number of trips, eligible schedule, price, validity period, and expiry date.
- The system should calculate expected trip demand from the selected schedule and dates, show the included count, and identify any mismatch between the requested schedule and package entitlement before purchase.
- Full upfront payment is required for a subscription/package. A one-off future trip follows the existing approved ride checkout and payment policy. The product owner must explicitly confirm before Scheduled Pickup launch whether one-off future trips use immediate full payment or another existing permitted payment flow; developers must not invent a new payment rule.
- Go-Volts reviews a recurring plan before payment. After approval, the customer has 48 hours from the quote's issue timestamp to pay. Quote expiry is timestamped in the service area's timezone. If payment is not verified before expiry, the quote expires and the customer must request re-approval/re-quotation; availability and price are not guaranteed after expiry.
- A plan becomes active only after approval and successful server-side payment verification. Payment success alone must not activate an unapproved plan; plan approval alone must not activate an unpaid plan.
- Renewal is manual. Send reminders 7 days, 3 days, and 1 day before expiry. Suppress reminders once the customer renews, cancels, or otherwise no longer needs them. Show renewal price/quote, expiry, remaining entitlements, and what happens if the customer does not renew.
- Fixed subscriptions are not unlimited. Show used, remaining, and expired entitlements and the associated trip history.
- Material changes to route, schedule, service dates, included trip count, or price require a revised quote and explicit customer acceptance before the change takes effect. A revised quote has a new 48-hour payment deadline when additional payment is due. Preserve the original quote and approval history.
- Mid-period customer cancellation permits a refund of eligible unused service on a published pro-rata/contract formula. The formula must define the valuation of completed trips, forfeited late cancellations/no-shows, disclosed permitted charges, service-failure credits, and prior adjustments. Do not assume that package price divided by trip count is always the refund formula unless the package terms explicitly use that method.
- Approved refunds should be initiated within 1 to 3 business days. This is an initiation target, not a guarantee of bank settlement. Communicate provider/bank processing delays and expose refund status/reference.
- Refunds, wallet credits, and restored trip entitlements are different remedies. Apply the published policy and record each separately. Wallet credit is not automatically cash-withdrawable.

### 24.4 Schedule management and exceptions

- A recurring plan has its own lifecycle independent of its individual trips. Supported plan statuses: draft, pending_review, approved_awaiting_payment, active, paused, rejected, expired, cancellation_pending where applicable, and cancelled.
- Each generated trip has its own lifecycle and status history. Minimum trip statuses include scheduled, awaiting_assignment, driver_offer_pending, driver_assigned, driver_approaching, pickup_confirmed, in_progress, arrived_at_destination, handover_pending where applicable, completed, skipped, cancelled, no_show_pending_review, no_show_confirmed, failed, and service_recovery_pending. Implement only valid transitions; the exact enum names may be adapted in the technical implementation while preserving these semantics.
- Recurring schedules generate individual trips only for eligible dates. A generated trip is not a completed trip and does not consume an entitlement merely because it was created or assigned.
- Customer skip cut-off is 6 hours before the scheduled pickup time. A skip submitted at least 6 hours before pickup preserves the entitlement. A customer late skip after the cut-off forfeits the trip entitlement under the published policy, subject to approved exceptions and applicable law. Show the deadline and consequence before confirming the skip.
- Customers can pause/resume a plan and skip individual trips. Pause/resume effects on already generated trips must be explicit: pausing prevents future eligible trips from being generated/dispatching after the effective point; it does not erase completed history or silently cancel a trip already underway. The app must show affected upcoming trips and any terms/charges before confirmation.
- Changes to pickup time, route, destination, or dates are requests, not silent edits. Material changes require revised quote and acceptance. Rules must prevent repeated time changes from being used to evade the six-hour late-skip policy.
- Admin-configurable calendar exceptions support school holidays, school closures, public holidays, selected dates, term start/end dates, and temporary schedule changes. Whether a closure is billable depends on the disclosed package terms. A customer-requested skip and a school closure are distinct reasons.
- On expiry, remaining entitlements expire under the disclosed policy except eligible service-failure/approved exceptions. Service failures must not be misclassified as customer-caused unused trips.

### 24.5 Entitlement and no-show policy

A trip entitlement, scheduled trip, and completed trip are distinct concepts. Entitlements must be recorded in an auditable append-only transaction history.

- Deduct an entitlement after successful trip completion under the relevant trip type and policy.
- Do not deduct merely on trip generation, offer, or driver assignment.
- A skip at least 6 hours before pickup preserves the entitlement.
- A customer skip after the cut-off forfeits the entitlement, subject to policy exceptions.
- Passenger no-show: driver must arrive at the correct pickup point, record arrival, wait 10 minutes, attempt the required contact procedure, and record evidence before a no-show can be confirmed. Operations review is required where the record is disputed, location is uncertain, contact failed due to platform error, or other exception criteria apply.
- A driver failure, Go-Volts cancellation, or other Go-Volts service failure must not consume the customer's entitlement. Restore the entitlement or apply eligible credit/refund under the published policy.
- A school closure or other exceptional event follows its separately disclosed policy; do not automatically treat it as a customer skip.
- Duplicate completion events must not deduct the same entitlement more than once. Corrections use compensating ledger entries, not deletion or mutation of prior history.

### 24.6 Review, activation and quote changes

Default MVP activation flow for a recurring plan:

1. Customer submits a complete plan request.
2. System validates fields, supported service area, schedule feasibility, trip count, passenger/school details where applicable, and price inputs.
3. Operations reviews service feasibility, route, schedule, capacity, eligibility, school protocol readiness, and any special requirements.
4. Go-Volts approves with a quote or rejects with a reason. A rejected request must clearly state whether any payment exists and the applicable refund/void treatment.
5. Approved quote is valid for 48 hours.
6. Customer pays the full amount.
7. Backend verifies payment through trusted server-side provider confirmation and idempotent webhook/reconciliation logic.
8. Plan becomes active; eligible trips are generated and enter the assignment schedule.

One-off future trips use the same availability, quote, payment, and trip-state principles but need not create a subscription. The product owner may later approve automatic approval for a defined class of low-risk plans; this is not the default MVP behaviour.

### 24.7 Driver assignment and operational handling

- Driver assignment timing is configurable by service type, trip urgency, pickup time, and operating needs. Admin configuration must include assignment deadline and escalation threshold.
- If a trip remains unassigned as its deadline approaches or passes, alert operations and escalate based on urgency. Do not silently leave the trip pending. School runs approaching pickup require elevated priority.
- Driver offer acceptance windows are configurable. An offer expires automatically at the deadline; a late response cannot create a duplicate assignment.
- Driver cancellation/unavailability is handled manually by operations in the MVP. The system must immediately flag the trip, alert the appropriate operations queue, show time-to-pickup and service type, record resolution deadline, and track the outcome. Manual handling does not mean no alert or no deadline.
- When a preferred driver is unavailable, automatically assign an eligible alternative and notify the customer. The preferred driver is a request, not a guarantee. The alternative must satisfy all applicable vehicle, service-area, rider eligibility and school-run safeguarding requirements. Customer support must be available for concerns; cancellation rights follow the published policy.
- Delay notifications use configurable predicted-delay thresholds. Notify when the threshold is exceeded; urgent disruptions and safety incidents are escalated immediately. Send updated ETA only when sufficiently reliable.
- If Go-Volts cannot fulfil an accepted trip, notify the customer and apply the appropriate remedy: restore entitlement, wallet credit, or eligible monetary refund. Replacement can be attempted only when safe and feasible; the approved baseline does not promise automatic replacement. Record reason and remedy.
- Dispatch assignment must be atomic: at most one active assigned driver per trip. Offer expiry, late accept, reassignment, and concurrent actions must not create duplicate assignments.

### 24.8 School-run passenger, pickup and handover safeguards

School-run functionality is included in MVP scope but may only be activated in a service area after legal, insurance, safeguarding, rider eligibility, school protocol, and operational readiness approvals.

**Guardian and passenger setup**

- A verified parent/guardian owns the plan and billing relationship. A child is a passenger profile, not the billing account by default.
- Record only the necessary passenger information, school, approved pickup/drop-off points, school contact/protocol, emergency contacts, and authorised recipients.
- Only a verified parent/guardian can add or remove authorised contacts. Changes become effective only after verification and confirmation to the parent. Preserve the prior authorisation history. Last-minute changes must trigger the configured additional review/safeguard and must not silently apply to an imminent trip while pending.
- Access to child data is least-privilege: only the parent/guardian and staff/driver assigned to the relevant trip can access necessary details. Do not expose data to unrelated customers or drivers.

**Pickup at school**

- Follow the registered school's approved collection/release protocol, pickup point, operating window, and contact procedure. The driver arriving at the address is not proof of pickup.
- The school protocol must identify required authorisation checks and the escalation contact. The system must not bypass school rules merely because a parent has booked a trip.

**Drop-off**

- The child must be handed to the parent/guardian or a currently authorised recipient under the registered handover rules. The driver must not substitute an unapproved person.
- Reaching the destination is not successful handover. Trip status must remain handover_pending or equivalent until the approved handover outcome is recorded.

**Secure code**

- Use a trip/handover-specific, time-limited, single-use code delivered through the approved channel to the authorised recipient/guardian.
- Do not expose the code to unrelated users or in overly revealing lock-screen notifications. Store only a verifier/hash where feasible; never log plaintext codes.
- A code verifies the configured handover step but does not replace the school's release protocol or recipient authorisation check.
- If the code cannot be used, the driver contacts operations. An authorised operations staff member uses an approved alternative verification procedure and records the decision. Driver self-override is prohibited.

**Evidence and privacy**

- Every handover records timestamp, trip ID, verification outcome/method, responsible driver/staff, and any exception decision in an append-only audit trail.
- A signature or other acknowledgement may be collected where appropriate under the protocol. Routine photographs of children are not required. Photos are allowed only for a justified operational purpose, lawful basis, explicit policy, access control, and retention rule; a photo alone never proves authorisation.
- Define evidence retention and deletion schedules, role-based access, encryption, access logging, and handling of parent/guardian requests in line with applicable data-protection requirements.

**Failed handover and incidents**

- If the recipient is unavailable or verification fails, driver immediately contacts operations. Operations contacts the parent and authorised backups, follows the documented safe escalation procedure, and records decisions. Serious or unresolved safety incidents escalate to the designated safety lead and, when appropriate, emergency services.
- The driver must not leave a child unattended or release the child to an unapproved person. The procedure must state what the driver should do while waiting and how the school/guardian is involved.
- School pickup and destination handover failures are incidents, not normal trip completion. A trip cannot be closed as completed solely because the vehicle arrived.

**Offline operation**

- The rider app may securely retain minimum necessary trip details for an assigned trip, but offline mode must not bypass required identity or handover checks.
- If required verification cannot be completed, invoke the operations-directed fallback. Local/offline event capture must be labelled pending sync until acknowledged by the backend. Do not display an offline event as server-confirmed.
- Any offline secure-code fallback must be specifically designed and approved; it is not implied by this baseline.

### 24.9 Customer notifications and screens

Customer app must provide a prominent Scheduled Pickup entry alongside Ride and Delivery. Required customer areas:

- **Create Scheduled Pickup:** guided setup for one-off future trips or recurring plans.
- **Review and Quote:** route, dates, legs, trip count, price, package terms, payment deadline, expiry, skip/no-show/refund terms.
- **My Plans:** plan status, schedule, package price, trip entitlement balance, pause/resume, cancellation, renewal, and history.
- **Upcoming Trips:** separate rows/cards for each leg, pickup time, destination, driver status, skip deadline, change request, and trip status.
- **Trip Detail:** route, milestones, assigned driver when confirmed, support, notifications, and relevant cancellation controls.
- **School-Run Status:** driver assigned, approaching, pickup confirmed, in progress where appropriate, and drop-off/handover confirmed. Display unresolved incidents as requiring attention, not completed.
- **Payment and Refund Details:** payment status, receipt, refund request/status/reference, wallet credit if used, and entitlement adjustments.

Required notifications include quote approval/rejection, quote expiry warning where configured, payment confirmation/failure, plan activation, driver assignment/replacement, approaching pickup, pickup confirmation, significant delay, drop-off/handover confirmation, incident requiring parent action, pause/resume/cancellation, and renewal reminders at 7/3/1 days. Suppress reminders that are no longer relevant.

Milestone notifications are the baseline for school-run parents. Live GPS tracking is not required by this decision set for school runs; do not imply it is available unless separately approved and implemented. General ride tracking remains governed by the normal ride product.

### 24.10 Admin and operations dashboard

Add Scheduled Pickup to the admin web app with:

- Plans awaiting review, approved-awaiting-payment, active, paused, expired, rejected and cancelled.
- Quote amount, 48-hour payment deadline, payment status, schedule, route, trip count, and reason for rejection.
- Upcoming trips with pickup time, time remaining, driver assignment/offer status, preferred-driver request, service type and urgency.
- Unassigned trips approaching/past assignment deadline; pending driver offers; driver cancellations; delays beyond threshold; school handover incidents; customer disputes; failed payment/refund exceptions.
- Subscription trip balance, upcoming schedule, skips, pause/resume, expiry and renewal reminders.
- Actions limited by role, with confirmation and reason for high-impact changes.

### 24.11 Roles and permissions

- **Super admin:** system-wide settings, role management, high-impact exceptional approvals; all actions audited.
- **Operations manager:** review/approve/reject plans, monitor dispatch, resolve trip exceptions and service recovery within policy.
- **Dispatcher:** assignment monitoring, driver offers, permitted reassignments, delay coordination; no unrestricted financial access.
- **Safety officer:** school-run protocol oversight, handover exceptions, incident review and safeguarding escalations.
- **Finance officer:** payment reconciliation, refunds, wallet credits and financial reports.
- **Pricing/policy administrator:** fare rules, subscription terms, skip/no-show parameters and policy configuration.
- **Customer support:** enquiries, skip/cancellation assistance, refund requests and status communication, without unrestricted financial approval.
- **Driver:** assigned-trip information, arrival/pickup/drop-off events, secure-code verification, incident reporting; cannot independently bypass a handover check.

A person may hold multiple roles in a small team, but permissions remain separate. Configure financial approval thresholds. Higher-value or exceptional refunds require a second authorised approver. Pricing/policy changes apply prospectively by default and do not silently modify existing paid agreements. All sensitive actions must record actor, timestamp, reason, before/after values and related plan/trip/payment IDs.

### 24.12 Admin-controlled policy parameters

The admin configuration should support, with validation and effective dates:

- Supported service areas and service-type eligibility.
- Driver assignment timing and assignment deadlines by service type.
- Driver acceptance window by urgency/service type.
- Delay notification threshold.
- Six-hour customer skip cut-off (configurable only through an authorised policy change; the agreed launch value is 6 hours).
- Ten-minute passenger no-show waiting period (agreed launch value: 10 minutes), plus required contact attempts and exception criteria.
- Quote validity/payment deadline (agreed launch value: 48 hours).
- Renewal reminder offsets (7, 3, and 1 day).
- Package period, entitlement count, expiry and calendar exceptions.
- Refund/credit/entitlement-restoration rules, approval limits and refund initiation target (1–3 business days after approval).
- School protocols, handover verification rules, contact-change safeguards, escalation contacts, evidence retention and role permissions.

Every change is versioned and audited. Do not permit arbitrary configuration that disables mandatory safety invariants such as authorisation checks, audit history, single active assignment, or financial idempotency.

### 24.13 Analytics and service quality

Track at minimum: plan approval time, quote-to-payment conversion, expired unpaid quotes, renewal rate, trips included/used/remaining/expired, skip rate by notice window, no-show rate, driver assignment lead time, unassigned trips at deadline, driver offer acceptance, driver cancellation, late pickup, service failure, entitlement restoration, refund amount/time, school handover exceptions, contact-verification failures, and incident resolution time. Reports must respect role-based access and avoid unnecessary exposure of child data.

### 24.14 MVP acceptance criteria

The feature is not complete until tests demonstrate that:

1. Customer can create one-off future and recurring bookings.
2. One-way and round-trip configurations create the correct individual trip legs and prices.
3. Fixed packages have a defined trip allowance and pay-per-trip bookings work independently.
4. Plan review, rejection reason, 48-hour quote expiry, full payment, server-side verification and activation conditions work correctly.
5. Manual renewal reminders send at 7/3/1 days and stop after renewal/cancellation.
6. Skip at least 6 hours before pickup preserves entitlement; a late skip follows the published forfeiture policy and any approved exception.
7. Pausing/resuming does not delete history or silently alter in-progress trips.
8. Entitlement deduction is idempotent and only occurs after the defined successful completion outcome; driver/Go-Volts failures restore entitlement or invoke the correct remedy.
9. Ten-minute no-show flow records correct pickup location, arrival time, contact attempts and review outcome.
10. Driver assignment deadlines and acceptance windows are configurable; expired offers and concurrent accepts cannot create two active drivers.
11. Unassigned and driver-cancelled trips alert and escalate to operations with urgency.
12. Preferred-driver unavailability leads to an eligible alternative and customer notification.
13. Delay notifications follow configured thresholds and urgent safety cases escalate immediately.
14. Refunds are itemised, linked to original payments, initiated within the target after approval, and reconciled without mutating the original payment.
15. School pickup follows the registered school protocol; drop-off requires an authorised contact and secure code or an operations-approved fallback.
16. Handover records contain timestamp, verification method/result, actor, and exception history; photos are not mandatory by default.
17. Contact changes require verified parent/guardian approval and cannot be used while pending.
18. Failed handovers trigger operations escalation; trip is not marked completed solely because the vehicle arrived.
19. Offline events are clearly pending synchronisation and cannot bypass required verification.
20. RBAC prevents drivers, dispatchers, support, and finance from exceeding their permissions; all sensitive changes are audited.
21. Customer screens display quote, schedule, entitlement balance, skip deadline, renewal, trip status, and refund status accurately.
22. School-run service cannot be enabled for a service area until the required legal, insurance, safeguarding, rider eligibility and operations approvals are recorded.

---

**End of concept note, version 1.1.**
