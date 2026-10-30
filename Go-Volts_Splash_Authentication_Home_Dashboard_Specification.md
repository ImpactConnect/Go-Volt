# Go-Volts Customer App
## Splash Screen, Authentication and Home Dashboard Specification

**Document type:** Product, UI/UX and Engineering Specification  
**Platform:** Flutter mobile app (Android and iOS)  
**Status:** Working specification for design and implementation  
**Version:** 1.0  
**Date:** October 2026

---

## 1. Purpose

This document defines the Go-Volts Customer App entry experience, authentication screens and Home Dashboard down to screen structure, component behaviour, layout dimensions, content hierarchy, API/data requirements, responsive behaviour and acceptance criteria.

It is intended for the product, UI/UX, Flutter, backend and QA teams. It should be used as the working reference when creating Figma screens and implementing the app.

### 1.1 Product principles

1. Make the main customer actions easy to find.
2. Show only services available in the customer's selected service area.
3. Make the current booking or delivery status easy to understand.
4. Keep sign-up and login simple and secure.
5. Use consistent components, spacing, typography and interaction patterns.
6. Never imply that a service is bookable when the backend says it is unavailable.
7. Treat the backend as the source of truth for authentication, service availability, bookings, wallet balances and rewards.

### 1.2 Scope covered

- Splash screen
- Welcome/onboarding entry
- Sign-up
- Email verification using OTP
- Google sign-in
- Login
- Forgot password and password reset
- Home Dashboard
- Home components and interactions
- Home API/data requirements
- Responsive behaviour
- Loading, empty, error and offline states
- Flutter implementation guidance
- Figma frame checklist
- QA and acceptance criteria

---

# PART A: SPLASH AND AUTHENTICATION

## 2. Splash Screen

**Screen ID:** `AUTH-00-SPLASH`  
**Priority:** MVP

### 2.1 Purpose

The splash screen introduces the Go-Volts brand while the app initializes. It should be brief and should not become a marketing screen that delays access to the app.

### 2.2 Layout

| Element | Specification |
|---|---|
| Background | Go-Volts primary dark green or approved brand background |
| Logo | Official Go-Volts logo, centered |
| App name | Optional wordmark below the logo if not already part of the logo |
| Loading indicator | Small, subtle indicator near the lower portion of the screen |
| Safe areas | Respect device status and navigation areas |
| Duration | Display while initialization runs; avoid an artificial long delay |

### 2.3 Visual hierarchy

1. Go-Volts logo
2. Brand name, if required
3. Loading indicator

Do not place sign-up fields, promotional messages or service cards on the splash screen.

### 2.4 Startup behaviour

On launch, the app should:

1. Load local app configuration and theme.
2. Initialize Supabase.
3. Check whether a valid Supabase session exists.
4. Refresh or validate the session where required.
5. Load the minimum customer/profile state needed for routing.
6. Route the customer:
   - Valid session and completed onboarding: Home Dashboard.
   - Valid session but required profile setup is incomplete: profile completion.
   - No session: Welcome screen or Login screen, based on the agreed first-launch behaviour.
   - Session refresh failure: clear invalid local session safely and show Welcome/Login.
7. If startup fails because of network connectivity, show a recoverable error state rather than a blank screen.

### 2.5 Technical notes

- Use the official Supabase Flutter SDK.
- Do not store passwords in local storage.
- Let Supabase manage session tokens through its supported session persistence.
- Do not place Supabase `service_role` credentials in the Flutter app.
- Keep splash initialization work bounded. Defer non-essential calls until after the first screen.
- Add a timeout and retry path for network-dependent startup tasks.

### 2.6 Splash states

| State | Expected behaviour |
|---|---|
| Initializing | Show logo and subtle loader |
| Existing session | Validate session and route |
| No session | Route to Welcome/Login |
| Offline | Show a clear retry state if startup cannot continue |
| Initialization error | Log a safe diagnostic event and show retry option |

---

## 3. Welcome / Entry Screen

**Screen ID:** `AUTH-01-WELCOME`  
**Priority:** MVP

### 3.1 Purpose

Give new and returning customers a clear starting point without making them guess whether to log in or create an account.

### 3.2 Layout

- Go-Volts logo at the top.
- A short headline communicating convenient mobility and delivery services.
- A supporting sentence.
- Primary button: **Create account**.
- Secondary button: **Log in**.
- Google sign-in option may be displayed here if product design chooses a combined entry screen.
- Terms of Service and Privacy Policy links at the bottom.

Suggested copy:

**Headline:** Move, send and manage deliveries with Go-Volts.  
**Supporting text:** Book a ride, send a parcel and keep track of your services in one place.

### 3.3 Interactions

| Control | Action |
|---|---|
| Create account | Open Sign-up |
| Log in | Open Login |
| Continue with Google | Start Supabase Google OAuth |
| Terms of Service | Open approved terms URL |
| Privacy Policy | Open approved privacy URL |

Do not show a Google option unless Google OAuth has been configured and tested for the relevant platform.

---

## 4. Sign-up Screen

**Screen ID:** `AUTH-02-SIGNUP`  
**Priority:** MVP

### 4.1 Purpose

Allow a new customer to create a Go-Volts account using email and password or Google authentication.

### 4.2 Authentication methods

The app must support:

1. **Email and password** through Supabase Auth.
2. **Google authentication** through Supabase Auth OAuth.

Email verification must use an OTP delivered to the customer's email address. **Do not use SMS OTP or phone-number verification as the account verification method.**

A phone number may be collected later as an optional or operational profile field if the product requires it, but it must not replace email OTP verification.

### 4.3 Recommended screen layout

1. Back navigation.
2. Title: **Create your account**.
3. Supporting text explaining that the customer can register with an email address.
4. Full name field.
5. Email address field.
6. Password field.
7. Confirm password field.
8. Primary button: **Create account**.
9. Divider labelled **or**.
10. **Continue with Google** button.
11. Link: **Already have an account? Log in**.
12. Terms and Privacy consent text.

### 4.4 Field specifications

| Field | Type | Required | Validation |
|---|---|---:|---|
| Full name | Text | Yes | Trim whitespace; enforce reasonable length |
| Email | Email | Yes | Valid email format; normalize consistently |
| Password | Password | Yes | Apply the configured password policy |
| Confirm password | Password | Yes | Must match password |
| Terms acceptance | Checkbox or explicit consent | Yes | Must be accepted before account creation |

Do not invent a password policy in the client that differs from the Supabase project configuration. Agree the minimum length and complexity policy with the backend/security owner and apply it consistently.

### 4.5 Interactions and validation

- Show and hide password controls.
- Keep the Create Account button disabled until required fields are valid and terms are accepted.
- Show field-level errors close to the relevant field.
- Prevent duplicate submissions while a request is in progress.
- Preserve non-sensitive form values if the request fails.
- Never log or analytics-track passwords or OTP values.
- If the email is already registered, show a useful message and offer Login or password recovery.
- On successful account creation, route to Email OTP Verification.

### 4.6 Supabase email/password sign-up

Use Supabase Auth email/password sign-up. The client submits the email and password to Supabase Auth. The backend/database profile creation process should be handled through a trusted database trigger or secured backend workflow.

Conceptual Flutter flow:

```dart
final response = await supabase.auth.signUp(
  email: email.trim(),
  password: password,
  data: {
    'full_name': fullName.trim(),
  },
);
```

Implementation notes:

- Confirm the exact Supabase project settings for email confirmation.
- Configure the email template to deliver the verification code.
- Ensure profile creation is safe to retry and does not create duplicate customer profiles.
- Do not treat a successful sign-up request as proof that the email has been verified.
- Follow the actual Supabase response/session state when deciding the next route.

---

## 5. Email OTP Verification

**Screen ID:** `AUTH-03-EMAIL-OTP`  
**Priority:** MVP

### 5.1 Purpose

Verify that the customer controls the email address supplied during registration.

### 5.2 Non-negotiable channel rule

**OTP must be delivered by email, not SMS.**

- Do not send account verification OTPs through SMS.
- Do not use a phone number as a fallback OTP destination.
- Do not make SMS verification a required step in the sign-up flow.
- Resend must send a new email verification code using the configured Supabase email flow.

### 5.3 Layout

- Title: **Verify your email**.
- Supporting copy: “We sent a verification code to [masked email address].”
- OTP input, preferably six separate visual cells backed by one logical value.
- Primary button: **Verify email**.
- Text action: **Resend code**.
- Countdown or cooldown text while resend is temporarily unavailable.
- Link to change email, if the account has not yet been verified and product rules allow it.

### 5.4 Behaviour

1. Display the email address in masked form.
2. Accept the code sent to that email.
3. Support paste into the OTP control.
4. Move focus between cells as the user types, if separate cells are used.
5. Allow the customer to submit the code.
6. Show an invalid or expired code message without clearing the email address.
7. Apply a resend cooldown and server-side rate limits.
8. On successful verification, route to profile completion if required, otherwise Home.
9. If the customer leaves and returns, allow the verification process to be resumed.

### 5.5 Supabase implementation note

Supabase email confirmation can be configured to use an OTP code in the email template. Use the Supabase-supported email OTP verification flow and the correct verification type for the configured project.

Conceptual Flutter flow:

```dart
await supabase.auth.verifyOTP(
  email: email.trim(),
  token: otp,
  type: OtpType.signup,
);
```

Resend should use the Supabase resend API for the sign-up verification email, with the appropriate `OtpType.signup` setting.

The exact email template and Auth settings must be tested in the target Supabase project. Do not assume that an email link template automatically behaves like a six-digit OTP template.

### 5.6 OTP security

- OTP values must never be stored in application logs.
- Enforce resend and verification rate limits.
- Expired codes must be rejected.
- A code must not be reusable after successful verification.
- Do not reveal whether an unrelated email address has an account in a way that enables account enumeration.
- Provide accessible error text and input labels.

---

## 6. Google Sign-in

**Screen ID:** `AUTH-04-GOOGLE-AUTH`  
**Priority:** MVP

### 6.1 Purpose

Allow customers to create an account or sign in using their Google account.

### 6.2 User flow

1. Customer taps **Continue with Google**.
2. App starts the platform-appropriate Google sign-in/OAuth flow.
3. Customer selects or confirms a Google account.
4. Supabase Auth processes the OAuth callback.
5. App reads the authenticated Supabase session.
6. App checks whether the customer profile exists and is complete.
7. New customer: create/complete the customer profile through the trusted profile workflow.
8. Existing customer: route to Home.
9. If the provider requires additional verification or profile information, route to the appropriate completion screen.

### 6.3 Technical requirements

- Configure Google as an OAuth provider in Supabase.
- Configure the required Google Cloud OAuth client IDs and redirect URLs for Android and iOS.
- Register the correct deep-link/callback scheme in the Flutter application.
- Keep OAuth secrets out of the mobile app.
- Validate callback handling on real Android and iOS devices.
- Handle cancellation, provider errors and missing profile data.
- Use the Supabase session as the authenticated identity source.

### 6.4 Email verification with Google

Google authentication establishes identity through the Google provider. Do not send an additional SMS OTP. Confirm the email verification status supplied by the provider/Supabase and follow the project's account policy. If Supabase reports the Google email as verified, do not unnecessarily send a second sign-up OTP.

---

## 7. Login Screen

**Screen ID:** `AUTH-05-LOGIN`  
**Priority:** MVP

### 7.1 Layout

1. Back navigation.
2. Title: **Welcome back**.
3. Email field.
4. Password field with show/hide control.
5. **Forgot password?** link.
6. Primary button: **Log in**.
7. Divider labelled **or**.
8. **Continue with Google** button.
9. Link to Create account.

### 7.2 Behaviour

- Authenticate email/password using Supabase Auth.
- Authenticate Google users using the same Google OAuth configuration as sign-up.
- Show a generic, useful authentication error.
- Prevent repeated requests while authentication is in progress.
- If email verification is required and incomplete, route to Email OTP Verification or a resend-verification state.
- If login succeeds, load the customer's profile and route to Home or profile completion.
- Do not reveal whether a particular email exists through overly specific error messages.

Conceptual flow:

```dart
final response = await supabase.auth.signInWithPassword(
  email: email.trim(),
  password: password,
);
```

---

## 8. Forgot Password and Reset Password

**Screen IDs:** `AUTH-06-FORGOT-PASSWORD`, `AUTH-07-RESET-PASSWORD`  
**Priority:** MVP

### 8.1 Forgot Password

Layout:
- Title: **Reset your password**.
- Short instruction.
- Email field.
- Primary button: **Send reset code** or the approved equivalent.
- Back to Login link.

Behaviour:
1. Customer enters their email.
2. App requests a password recovery email through Supabase Auth.
3. The email contains the configured recovery OTP or recovery link.
4. App displays a neutral confirmation message.
5. Customer follows the configured recovery flow.

### 8.2 Reset Password

Layout:
- New password field.
- Confirm new password field.
- Primary button: **Update password**.

Behaviour:
- Validate the new password against the configured policy.
- Verify the recovery token/session through Supabase.
- Update the password using the Supabase Auth-supported method.
- Show success and route to Login or the authenticated app, based on the configured recovery flow.

### 8.3 Channel rule

Password recovery codes or links must be sent to the customer's email. Do not introduce SMS OTP into password recovery.

---

## 9. Optional Profile Completion

**Screen ID:** `AUTH-08-PROFILE-COMPLETION`  
**Priority:** MVP if required profile fields are missing

This screen is only shown when required customer profile data is missing after authentication.

Possible fields:
- Full name, if not supplied by the provider.
- Email address, read-only where appropriate.
- Optional phone number, only if needed for service operations.
- Preferred service area or location permission prompt.

A phone number collected here is a profile/contact field. It is not the OTP verification channel.

---

# PART B: HOME DASHBOARD

## 10. Home Dashboard Overview

**Screen ID:** `HOME-01`  
**Priority:** MVP

### 10.1 Purpose

The Home Dashboard is the customer's main control centre. It should answer four questions quickly:

1. Where am I currently receiving Go-Volts services?
2. What can I do from this location?
3. Is there an active ride, delivery or scheduled service I need to manage?
4. Where can I access my rewards and account features?

### 10.2 Primary customer actions

The Home Dashboard should make these actions easy to find:

- **Book a Ride**
- **Send a Parcel**
- **Track Delivery**
- **Schedule a Service**

The app must check service availability for the selected service area. A service that is unavailable must be disabled, hidden or presented as unavailable with a clear explanation. It must not look bookable.

### 10.3 Navigation

The primary bottom navigation has five destinations:

| Destination | Purpose |
|---|---|
| Home | Service discovery and dashboard |
| Activity | Current and past bookings/deliveries |
| Rewards | Points, rewards and referrals |
| Wallet | Payment methods, balance and transactions |
| Profile | Customer details, preferences and support |

Keep these destinations consistent across the authenticated app.

### 10.4 Home screen order

Recommended vertical order:

1. Header and greeting
2. Service-area/location selector
3. Main service action cards
4. Active booking or delivery card, when one exists
5. Campaign/promotional banner, when active
6. Saved locations
7. Rewards summary
8. Fixed bottom navigation

The active booking card may move above the service cards when the customer has an urgent active trip or delivery. This should be a deliberate product rule, not an inconsistent layout change.

---

## 11. Home Dashboard Wireframe

```text
┌─────────────────────────────────────┐
│ Good morning, [First name]      🔔  │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Current location                │ │
│ │ [Selected area/address]      >  │ │
│ └─────────────────────────────────┘ │
│                                     │
│ What would you like to do?          │
│                                     │
│ ┌────────────────┐ ┌──────────────┐ │
│ │ Book a Ride    │ │ Send a Parcel│ │
│ │     icon       │ │     icon     │ │
│ └────────────────┘ └──────────────┘ │
│ ┌────────────────┐ ┌──────────────┐ │
│ │ Track Delivery │ │ Schedule     │ │
│ │     icon       │ │ a Service    │ │
│ └────────────────┘ └──────────────┘ │
│                                     │
│ Your active service                 │
│ ┌─────────────────────────────────┐ │
│ │ Booking / delivery status       │ │
│ │ Reference • Destination         │ │
│ │ [View details]                  │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Campaign banner                 │ │
│ │ Approved campaign content       │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Saved locations                     │
│ [Home] [Work] [Add location]        │
│                                     │
│ Rewards                             │
│ ┌─────────────────────────────────┐ │
│ │ Available points    [View]      │ │
│ └─────────────────────────────────┘ │
│                                     │
├─────────────────────────────────────┤
│ Home   Activity   Rewards   Wallet  │
│                         Profile     │
└─────────────────────────────────────┘
```

This is a structural wireframe, not a final visual design. Final styling, icons and typography should follow the approved Go-Volts design system.

---

## 12. Content Hierarchy

### Level 1: Main actions

The four service actions are the most important Home content. They should be immediately visible without scrolling on common phone sizes where practical.

### Level 2: Current activity

Active bookings and deliveries are time-sensitive. They should be easy to identify and open.

### Level 3: Engagement and convenience

Campaigns, saved locations and rewards support repeat usage but must not compete visually with the main service actions.

### Visual priority

1. Primary service actions
2. Active service status
3. Current service area
4. Saved locations
5. Campaigns and rewards

Do not allow a promotional banner to dominate the screen or push all main service actions below the fold.

---

## 13. Home Component Specifications

### 13.1 Header and Greeting

**Component ID:** `HOME-CMP-01`

**Purpose:** Welcome the customer and provide a familiar starting point.

**Content:**
- Time-aware greeting such as Good morning, Good afternoon or Good evening.
- Customer first name.
- Notification shortcut.

**Dimensions:**
- Header row height: 48-56 dp.
- Greeting block: approximately 64-76 dp.
- Horizontal screen padding: 20 dp.

**Interactions:**
- Notification shortcut opens Notifications.
- Greeting itself is not a button.
- If the name is unavailable, use a neutral greeting.

**Data:**
- `customer.first_name`
- Local device time for greeting.
- `notifications.unread_count`

### 13.2 Notification Shortcut

**Component ID:** `HOME-CMP-02`

**Purpose:** Let customers access service updates and important notices.

**Visuals:**
- Bell icon.
- Small unread indicator or count when unread notifications exist.

**Interactions:**
- Tap opens Notifications.
- Mark notifications as read through the appropriate backend operation.
- Do not show a badge when unread count is zero.

**Data:**
- Unread notification count.
- Notification list is loaded on the Notifications screen, not all on Home.

### 13.3 Service-Area Selector

**Component ID:** `HOME-CMP-03`

**Purpose:** Show the area currently used to determine service availability and pricing.

**Dimensions:**
- Height: 64-76 dp.
- Radius: 14-18 dp.
- Horizontal padding: 14-16 dp.

**Content:**
- Small location icon.
- Label: Current location or Service area.
- Selected area/address.
- Chevron or change-location affordance.

**Interactions:**
- Tap opens Location Search & Map Picker.
- On selection, update the active service area.
- Refresh service availability and any area-dependent content.
- If location permission is denied, allow manual location selection.
- Do not silently change the selected service area based only on GPS movement.

**Data:**
- Selected saved/current location.
- Coordinates where available.
- Resolved service area ID.
- Location permission state.

### 13.4 Main Service Cards

**Component ID:** `HOME-CMP-04`

**Purpose:** Provide direct access to the four primary customer actions.

**Cards:**
1. Book a Ride
2. Send a Parcel
3. Track Delivery
4. Schedule a Service

**Dimensions:**
- Two-column grid on standard phones.
- Card height: 116-132 dp.
- Internal padding: 14-16 dp.
- Corner radius: 14-18 dp.
- Icon size: 26-32 dp.
- Minimum interactive target: 48 x 48 dp.

**Content hierarchy within each card:**
1. Service icon.
2. Service title.
3. Optional short supporting line.
4. Availability state where needed.

**Interactions:**

| Card | Action |
|---|---|
| Book a Ride | Open Ride Booking |
| Send a Parcel | Open Parcel Booking |
| Track Delivery | Open tracking entry or latest active delivery |
| Schedule a Service | Open Scheduled Pickup/Service flow |

**Availability rules:**
- Use backend service availability for the selected area.
- If unavailable, disable the action and explain why.
- If temporarily unavailable, show a clear unavailable state.
- Do not allow the client to infer availability from a hardcoded city list.
- Recheck availability before creating a booking.

**Design recommendation:**
Use the primary Go-Volts brand colour for the main Ride action if that matches the approved design system. Keep other cards visually consistent and less dominant. This is a design proposal, not a fixed backend requirement.

### 13.5 Active Booking Card

**Component ID:** `HOME-CMP-05`

**Purpose:** Surface the most relevant active ride, parcel or scheduled service.

**Dimensions:**
- Height: 112-150 dp depending on content.
- Padding: 14-16 dp.
- Radius: 14-18 dp.

**Content:**
- Section title: Your active service.
- Service type.
- Booking/reference number, where useful.
- Current status.
- Pickup/destination summary, subject to privacy and available data.
- Primary action: View details.

**Interactions:**
- Tap card or View details opens the relevant booking/tracking screen.
- If multiple active services exist, show the most urgent/recent one and provide a route to Activity for the rest.
- Status must match the backend state machine.
- Do not expose sensitive driver details before assignment or when not authorized.

**Empty state:**
If there is no active booking, either omit the section or show a compact empty state with a useful action. Do not reserve a large blank area.

### 13.6 Campaign Banner

**Component ID:** `HOME-CMP-06`

**Purpose:** Display approved offers, announcements or campaigns.

**Dimensions:**
- Height: 140-180 dp.
- Radius: 16-20 dp.
- Full content width within screen margins.

**Content:**
- Campaign image or artwork.
- Short headline.
- Supporting line, if needed.
- Optional CTA.

**Interactions:**
- Open the linked campaign detail or approved destination.
- Do not make the entire banner clickable unless the whole banner has one clear destination.
- Hide expired or unpublished campaigns.
- If there is no eligible campaign, collapse the component without leaving a blank gap.

**Backend requirements:**
- Campaign ID.
- Title and short description.
- Image URL.
- CTA label and destination type/value.
- Start/end time.
- Publication status.
- Target audience/eligibility.
- Service-area restrictions.
- Priority/sort order.

### 13.7 Saved Locations

**Component ID:** `HOME-CMP-07`

**Purpose:** Help customers reuse common pickup or destination locations.

**Suggested shortcuts:**
- Home
- Work
- Add location

**Dimensions:**
- Card height: 76-92 dp.
- Radius: 12-16 dp.
- Horizontal padding: 12-14 dp.

**Interactions:**
- Tap Home or Work to use that saved location in a relevant booking flow.
- Tap Add location to open location selection.
- Allow customers to edit or remove saved locations in the appropriate management screen.
- Do not assume a saved Home or Work address exists.

**Data:**
- Address ID.
- Label.
- Display address.
- Coordinates.
- Default status.
- Customer ownership.

### 13.8 Rewards Summary

**Component ID:** `HOME-CMP-08`

**Purpose:** Give the customer a quick view of their loyalty points and a path to Rewards.

**Dimensions:**
- Height: 100-124 dp.
- Padding: 14-16 dp.
- Radius: 14-18 dp.

**Content:**
- Available points.
- Short label explaining the points balance.
- View Rewards action.

**Interactions:**
- Tap opens Rewards.
- Display points as an integer.
- Do not calculate or modify points in the client.
- The backend is authoritative for available points and pending points.

---

## 14. Home Navigation and Routes

Suggested route names:

| Action | Suggested route |
|---|---|
| Home | `/home` |
| Notifications | `/notifications` |
| Select location | `/location/select` |
| Ride booking | `/ride/booking` |
| Parcel booking | `/delivery/create` |
| Track delivery | `/delivery/track` |
| Scheduled service | `/scheduled-pickup` |
| Activity | `/activity` |
| Rewards | `/rewards` |
| Wallet | `/wallet` |
| Profile | `/profile` |

These are proposed route names. Align them with the final Flutter route structure before implementation.

---

## 15. Home API and Data Requirements

### 15.1 Recommended data strategy

The Home screen needs several data sources. A single aggregated endpoint is recommended to reduce loading time and keep the screen consistent.

**Proposed endpoint:**

`GET /api/v1/customer/home`

This endpoint is a recommendation for the backend design. It is not confirmed as an existing endpoint in the source specification.

The endpoint should return the minimum data needed to render Home:

- Customer summary
- Selected service area
- Service availability
- Active booking summary
- Campaigns eligible for the customer
- Saved locations
- Rewards summary
- Unread notification count

### 15.2 Candidate underlying endpoints

If an aggregate endpoint is not implemented, Home may compose data from endpoints such as:

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/api/v1/customer/profile` | Customer display information |
| GET | `/api/v1/customer/notifications` | Notification data/count |
| GET | `/api/v1/service-areas` | Service area information |
| POST | `/api/v1/services/availability` | Check service availability |
| GET | `/api/v1/customer/addresses` | Saved locations |
| GET | `/api/v1/customer/bookings?status=active` | Active bookings |
| GET | `/api/v1/customer/loyalty` | Points/rewards summary |

These are candidate API contracts and should be reconciled with the final backend API specification.

### 15.3 Example Home response

Illustrative response only. Final field names and types must be agreed with the backend team.

```json
{
  "customer": {
    "id": "customer_id",
    "first_name": "Customer"
  },
  "service_area": {
    "id": "area_id",
    "name": "Selected service area"
  },
  "service_availability": {
    "ride": {
      "available": true,
      "reason": null
    },
    "parcel": {
      "available": true,
      "reason": null
    },
    "tracking": {
      "available": true,
      "reason": null
    },
    "scheduled_service": {
      "available": false,
      "reason": "Not available in this area"
    }
  },
  "active_booking": {
    "id": "booking_id",
    "type": "ride",
    "reference": "GV-000001",
    "status": "driver_assigned",
    "pickup_label": "Pickup location",
    "destination_label": "Destination"
  },
  "campaigns": [],
  "saved_locations": [],
  "rewards": {
    "available_points": 0
  },
  "notifications": {
    "unread_count": 0
  }
}
```

### 15.4 API and security rules

- Require a valid authenticated customer session.
- Derive customer identity from the verified Supabase JWT/session. Do not trust a customer ID supplied by the client as authorization.
- Return only records belonging to the authenticated customer.
- Enforce Row Level Security where appropriate.
- Never expose Supabase `service_role` credentials in Flutter.
- Do not allow direct client writes to financial ledger tables.
- Recheck service availability before booking creation.
- Use idempotency keys for operations that create bookings, payments or redemptions.
- Store monetary values as integer minor units (kobo), not floating-point values.
- Keep rewards/points calculations authoritative on the backend.
- Return stable status codes and machine-readable error codes.

### 15.5 Loading and refresh strategy

- Show a lightweight skeleton while Home data loads.
- Load critical content first: customer greeting, selected area, service availability and active booking.
- Load campaigns and secondary engagement content without blocking the main actions.
- Support pull-to-refresh.
- Refresh availability when the customer changes service area.
- Refresh or invalidate Home data after booking creation/cancellation or a relevant profile/location update.
- Use Realtime or push notifications selectively for active service status changes.
- Do not rely on cached availability when creating a booking.

---

## 16. Responsive Behaviour

### 16.1 Breakpoints

Suggested Flutter layout breakpoints:

| Width | Layout |
|---|---|
| Below 360 dp | Compact phone |
| 360-599 dp | Standard phone |
| 600-839 dp | Expanded/tablet |
| 840 dp and above | Wide tablet |

These are implementation starting points. Validate them against the supported device range.

### 16.2 Compact phones

- Keep 20 dp horizontal margins where practical; reduce carefully if required.
- Use a two-column service grid only if card titles and touch targets remain comfortable.
- Allow vertical scrolling.
- Keep bottom navigation fixed.
- Avoid clipping long addresses and customer names.

### 16.3 Standard phones

- Two-column service-card grid.
- Full-width location selector.
- Full-width active booking card and campaign banner.
- Saved locations can use a horizontal list.
- Keep main actions visible as high as practical.

### 16.4 Tablets

- Centre the main content with a sensible maximum width.
- Do not stretch cards across the entire screen.
- Consider a two-column content layout for larger tablets:
  - Main service actions and active booking in the primary column.
  - Campaign, saved locations and rewards in the secondary column.
- Keep bottom navigation or use an approved tablet navigation pattern consistently.

### 16.5 General responsive rules

- Use `LayoutBuilder` or shared responsive utilities.
- Prefer flexible constraints over device-model checks.
- Use scroll views for variable-height content.
- Respect safe areas and system insets.
- Support text scaling and avoid fixed-height text containers that clip content.
- Maintain minimum touch targets of approximately 48 x 48 dp.
- Test long names, long addresses, large text and narrow widths.

---

## 17. Home UI States

| State | Expected behaviour |
|---|---|
| Loading | Show skeletons/placeholders; avoid a blank screen |
| Loaded | Show available services and customer content |
| No active booking | Hide active card or show a compact empty state |
| No saved locations | Show a simple Add location prompt |
| No campaigns | Hide campaign area without blank space |
| No rewards balance | Show zero or an approved introductory state |
| Service unavailable | Disable or clearly label the service |
| Unsupported area | Explain that services are not yet available in the selected area |
| Offline | Show cached non-sensitive information where safe and an offline notice |
| API error | Provide retry without losing the navigation shell |
| Session expired | Re-authenticate through the approved auth flow |

### 17.1 Empty and error copy examples

- No active service: “You don't have an active booking right now.”
- No saved locations: “Save a location to make future bookings quicker.”
- Service unavailable: “This service isn't available in your selected area yet.”
- Offline: “You're offline. Check your connection and try again.”
- General load failure: “We couldn't load your Home dashboard. Try again.”

Copy should be reviewed by Product and Customer Support before release.

---

# PART C: FLUTTER IMPLEMENTATION

## 18. Suggested Flutter Structure

A feature-first structure is recommended:

```text
lib/
├── app/
│   ├── app.dart
│   ├── router.dart
│   ├── bootstrap.dart
│   └── theme/
│       ├── app_colors.dart
│       ├── app_spacing.dart
│       ├── app_typography.dart
│       └── app_theme.dart
│
├── core/
│   ├── network/
│   ├── errors/
│   ├── utils/
│   ├── widgets/
│   └── responsive/
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── splash/
│   │       ├── welcome/
│   │       ├── signup/
│   │       ├── email_otp/
│   │       ├── login/
│   │       ├── forgot_password/
│   │       └── profile_completion/
│   │
│   ├── home/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── screens/
│   │       ├── providers/
│   │       └── widgets/
│   │
│   ├── ride/
│   ├── delivery/
│   ├── scheduled_pickup/
│   ├── activity/
│   ├── rewards/
│   ├── wallet/
│   ├── profile/
│   └── notifications/
│
└── main.dart
```

## 19. State Management

Use Riverpod for authentication and Home state.

Suggested Home state:

```dart
class HomeState {
  final bool isLoading;
  final String? error;
  final CustomerSummary? customer;
  final ServiceArea? serviceArea;
  final ServiceAvailability? availability;
  final ActiveBooking? activeBooking;
  final List<Campaign> campaigns;
  final List<SavedLocation> savedLocations;
  final RewardsSummary? rewards;
  final int unreadNotificationCount;

  const HomeState({
    this.isLoading = false,
    this.error,
    this.customer,
    this.serviceArea,
    this.availability,
    this.activeBooking,
    this.campaigns = const [],
    this.savedLocations = const [],
    this.rewards,
    this.unreadNotificationCount = 0,
  });
}
```

Use immutable state models. Avoid placing API calls directly inside widget build methods.

## 20. Reusable Components

Suggested component inventory:

```text
AppScaffold
AppPrimaryButton
AppSecondaryButton
AppTextField
AppPasswordField
EmailOtpInput
GoogleAuthButton
AppLoadingIndicator
AppErrorView
AppEmptyState
AppBottomNavigation
NotificationIconButton
CustomerGreeting
ServiceAreaSelector
ServiceActionCard
ActiveBookingCard
CampaignBanner
SavedLocationCard
RewardsSummaryCard
```

Components should support consistent spacing, typography, disabled/loading states, accessibility labels and responsive constraints.

---

# PART D: FIGMA AND DESIGN HANDOFF

## 21. Required Figma Frames

Create frames for the following screens and states.

### Authentication

1. `AUTH-00-SPLASH`
2. `AUTH-01-WELCOME`
3. `AUTH-02-SIGNUP-DEFAULT`
4. `AUTH-02-SIGNUP-VALIDATION`
5. `AUTH-03-EMAIL-OTP`
6. `AUTH-03-EMAIL-OTP-ERROR`
7. `AUTH-03-EMAIL-OTP-RESEND`
8. `AUTH-04-GOOGLE-AUTH-LOADING`
9. `AUTH-05-LOGIN`
10. `AUTH-05-LOGIN-ERROR`
11. `AUTH-06-FORGOT-PASSWORD`
12. `AUTH-07-RESET-PASSWORD`
13. `AUTH-08-PROFILE-COMPLETION`, if required

### Home

1. `HOME-01-DEFAULT`
2. `HOME-02-NO-ACTIVE-BOOKING`
3. `HOME-03-ACTIVE-RIDE`
4. `HOME-04-ACTIVE-DELIVERY`
5. `HOME-05-SERVICE-UNAVAILABLE`
6. `HOME-06-LOCATION-SELECTOR`
7. `HOME-07-NOTIFICATIONS`
8. `HOME-08-LOADING`
9. `HOME-09-OFFLINE`
10. `HOME-10-UNSUPPORTED-AREA`

### 21.1 Component variants

Create reusable Figma components and variants for:

- Primary and secondary buttons
- Text fields: default, focused, error, disabled
- Password field: hidden and visible
- OTP input: empty, partial, complete, error
- Google sign-in button: default, loading, disabled
- Service card: available, unavailable, loading
- Active booking card: ride, parcel, scheduled service
- Notification icon: read state and unread state
- Campaign banner
- Saved location card
- Rewards summary
- Bottom navigation: active and inactive destinations
- Loading skeletons
- Empty and error states

### 21.2 Design handoff notes

- Use Auto Layout for cards, form groups and screen sections.
- Use shared colour, typography, spacing and radius tokens.
- Define component properties and variants rather than detaching instances.
- Include interaction annotations for every tappable element.
- Document loading, validation, disabled, error and offline states.
- Keep text content realistic enough to test long names, addresses and messages.
- Make the email-only OTP channel explicit in the design and prototype.
- Do not include an SMS OTP screen or SMS verification option.

---

# PART E: QA AND ACCEPTANCE

## 22. Authentication Test Checklist

### Splash and routing

- [ ] App initializes Supabase correctly.
- [ ] Existing valid session routes to the correct authenticated screen.
- [ ] No session routes to Welcome/Login.
- [ ] Invalid/expired session is handled safely.
- [ ] Startup failure shows a recoverable state.

### Sign-up

- [ ] Email/password sign-up works.
- [ ] Required fields are validated.
- [ ] Password and confirmation must match.
- [ ] Terms acceptance is required.
- [ ] Duplicate/registered email receives a safe message.
- [ ] Account verification email is sent to the supplied email address.
- [ ] No SMS OTP is sent or requested.

### Email OTP

- [ ] OTP email is delivered.
- [ ] Correct OTP verifies the account.
- [ ] Incorrect OTP shows an error.
- [ ] Expired OTP is rejected.
- [ ] Resend works and respects cooldown/rate limits.
- [ ] OTP cannot be reused after successful verification.
- [ ] Paste and keyboard behaviour work on supported devices.

### Google authentication

- [ ] Google sign-in works on Android.
- [ ] Google sign-in works on iOS.
- [ ] OAuth callback returns to the app.
- [ ] Cancelled sign-in is handled.
- [ ] New Google user profile is created/completed correctly.
- [ ] Existing Google user can sign in.
- [ ] No unnecessary SMS OTP is triggered.

### Login and recovery

- [ ] Email/password login works.
- [ ] Google login works.
- [ ] Unverified account is routed correctly.
- [ ] Forgot-password email is delivered.
- [ ] Password reset succeeds.
- [ ] No SMS OTP is used for recovery.

## 23. Home Dashboard Test Checklist

- [ ] Customer greeting displays correctly.
- [ ] Notification unread count is correct.
- [ ] Service-area selector shows the selected area.
- [ ] Changing area refreshes service availability.
- [ ] Only available services appear bookable.
- [ ] Ride card opens Ride Booking.
- [ ] Parcel card opens Parcel Booking.
- [ ] Track Delivery opens the correct tracking entry.
- [ ] Schedule a Service opens the scheduled-service flow.
- [ ] Active booking card reflects backend status.
- [ ] Empty active-booking state is handled.
- [ ] Campaigns respect publication dates and eligibility.
- [ ] Saved locations are customer-specific.
- [ ] Rewards balance is backend-authoritative.
- [ ] Bottom navigation routes correctly.
- [ ] Loading, error, offline and unsupported-area states work.
- [ ] Layout works on compact phones, standard phones and tablets.
- [ ] Large text and long addresses do not cause clipping.
- [ ] Touch targets are accessible.

## 24. Definition of Done

The Splash, Authentication and Home Dashboard work is ready for handoff when:

1. All required Figma frames and component states are present.
2. Email/password authentication works through Supabase.
3. Google authentication works through Supabase OAuth.
4. Email verification uses OTP delivered by email.
5. SMS OTP is not part of sign-up, login or password recovery.
6. Authenticated routing handles new, returning and incomplete-profile customers.
7. Home renders from backend data rather than hardcoded service availability.
8. All four primary Home actions route to the correct flows.
9. Active booking, campaigns, saved locations, rewards and notification count display correctly.
10. Loading, empty, error, offline and unavailable states are tested.
11. API contracts and security responsibilities are agreed with backend engineering.
12. QA acceptance checks pass on supported Android and iOS devices.

---

# PART F: DECISIONS AND OPEN ITEMS

## 25. Confirmed requirements in this note

- Flutter/Dart is the customer mobile app technology.
- Supabase Auth is used for customer authentication.
- Email/password sign-up and login are supported.
- Google authentication is supported through Supabase OAuth.
- Email OTP is used for email verification.
- SMS OTP is not used for account verification or password recovery.
- Home has five primary navigation destinations: Home, Activity, Rewards, Wallet and Profile.
- Home highlights Ride, Parcel, Track Delivery and Scheduled Service actions.
- Service availability is determined by the selected service area and backend availability data.

## 26. Proposed design and engineering decisions

The following are recommendations that should be confirmed by Product and Engineering:

- Exact splash background and logo treatment.
- Whether first launch opens Welcome or Login.
- Exact password policy.
- Exact OTP length, expiry and resend cooldown based on Supabase configuration.
- Whether Google sign-in is shown on Welcome, Sign-up and Login.
- Home card colours and exact typography.
- Exact breakpoints and maximum tablet content width.
- Whether active booking moves above service cards for urgent states.
- Whether Home uses one aggregated API endpoint or multiple endpoints.
- Final endpoint names, request/response schemas and error codes.
- Whether profile completion requires a phone number for operational contact.
- Final terms and privacy URLs.
- Exact campaign eligibility and display rules.

## 27. Important product and engineering reminders

1. Do not add an SMS OTP step to the authentication experience.
2. Do not assume a Google-authenticated customer needs a second email OTP if the provider email is already verified and Supabase reports it as verified.
3. Do not trust client-side service availability when creating a booking.
4. Do not store sensitive credentials or Supabase service-role keys in the mobile app.
5. Do not calculate wallet balances or rewards points in the client.
6. Keep auth errors helpful without exposing account-enumeration information.
7. Treat this document as the working specification. Final API contracts, security policies, copy and design tokens must be confirmed before production release.
