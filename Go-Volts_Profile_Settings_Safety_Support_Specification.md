# Go-Volts Customer App
## Profile, Account, Settings, Safety and Support Specification

**Document ID:** GV-CUST-PROFILE-SETTINGS-001  
**Version:** 1.0  
**Status:** Product, UI/UX and Technical Specification  
**Platform:** Flutter Customer App for Android and iOS  

---

# 1. Purpose

This document defines the user-facing **Profile, Account, Settings, Preferences, Safety and Support** experience for the Go-Volts Customer App.

It covers:

- **Group A: Profile & Account**
- **Group B: Settings & Preferences**
- **Group D: Safety, Help & Support**

The goal is to provide clear requirements for the product team, UI/UX designers and development team before creating the final screen design images.

---

# 2. Design Principles

The experience should follow these principles:

- Keep important account actions easy to find.
- Group related settings together.
- Avoid overwhelming users with too many options on one screen.
- Use progressive disclosure for detailed settings.
- Reuse shared modules such as Saved Places and Payment Methods across the application.
- Clearly distinguish optional preferences from important security or operational settings.
- Use backend-confirmed states for security, verification, payments and support tickets.
- Support loading, empty, error and offline states where applicable.

---

# 3. GROUP A: Profile & Account

## A1. Profile Home

The Profile Home is the customer's main account screen.

### Profile Header

Display:

- Profile photo/avatar
- Customer full name
- Email or masked phone number
- Account status or verification indicator where applicable
- Edit Profile action

### Account Section

- Personal Information
- Saved Places
- Payment Methods

### App & Preferences

- Settings
- Notifications
- Privacy & Security

### Support

- Safety Centre
- Help & Support

### Account Actions

- Terms & Privacy
- Logout
- Delete/Deactivate Account

### Interaction Rules

- Tapping a menu item opens its dedicated screen.
- The profile header or Edit Profile action opens Edit Profile.
- Sensitive account actions should require appropriate confirmation.
- Logout should require confirmation to prevent accidental sign-out.

### Data Requirements

```text
user_id
first_name
last_name
full_name
email
phone_number
profile_photo_url
verification_status
created_at
updated_at
```

---

## A2. Edit Profile

Allows the customer to update permitted account information.

### Editable Fields

- Profile photo
- First name
- Last name
- Email
- Phone number

Some fields may require verification before changes become active.

### Actions

- Change profile photo
- Save changes
- Cancel changes

### UX Rules

- Save Changes should only become active when valid information has changed.
- Invalid input should show clear inline validation.
- The customer should receive clear confirmation when updates are successfully saved.
- Sensitive changes may require re-authentication or verification according to the final security policy.

### API Requirements

```text
GET   /v1/profile
PATCH /v1/profile
```

---

## A3. Personal Information

This screen provides a detailed view of customer account information.

### Information

- Full name
- Email address
- Phone number
- Account information where useful
- Verification status

### Privacy Rule

Sensitive information should not be unnecessarily exposed in full where masking is appropriate.

---

## A4. Account Verification

Account verification should only appear where required by Go-Volts policies or service requirements.

### Possible States

```text
NOT_REQUIRED
PENDING
VERIFIED
ACTION_REQUIRED
REJECTED
```

### UI Requirements

- Clearly show the current status.
- Explain what the customer needs to do.
- Avoid exposing technical backend errors.
- Provide the appropriate next action when customer action is required.

### Technical Rule

Verification status must come from the backend as the authoritative source.

---

# 4. GROUP B: Settings & Preferences

## B1. Settings Home

The Settings Home acts as the customer's preferences control centre.

### Account Preferences

- Notifications
- Saved Places
- Payment Methods

### App Preferences

- Language
- Appearance
- Data usage preferences where applicable

### Privacy & Security

- Change password
- Google authentication status
- Active sessions/devices
- Privacy controls

### Support

- Help Centre
- Safety Centre

### UX Logic

Settings should be grouped into clearly labelled sections rather than displayed as one long unstructured list.

---

## B2. Notification Settings

Notifications should be grouped by service.

### Ride

- Booking updates
- Rider assigned
- Trip updates

### Parcel

- Delivery updates
- Rider assignment
- Delivery completion

### Market Errand

- Agent updates
- Shopping updates
- Payment/reconciliation updates

### General

- Rewards
- Promotions
- Important account/security notifications

### Business and UX Rules

- Optional marketing notifications should be separate from important operational notifications.
- Security notifications may have different handling from promotional preferences.
- Notification preferences should synchronize with the backend.

### API Requirements

```text
GET   /v1/notification-preferences
PATCH /v1/notification-preferences
```

---

## B3. Saved Places

Saved Places is a shared location module that can be reused across:

- Ride booking
- Parcel delivery
- Scheduled Pickup
- Market Errand

### Default Places

- Home
- Work

### Customer Actions

- Add a place
- Search for an address
- Select a location on the map
- Add location instructions
- Edit a saved place
- Delete a saved place

### Suggested Data Model

```text
Place ID
User ID
Label
Address
Latitude
Longitude
Additional Instructions
Created At
Updated At
```

### Business Rules

- A saved place belongs to one customer.
- Customers can only access and edit their own places.
- Coordinates should be stored separately from the formatted address.
- Deleting a saved place must not modify historical ride or delivery records.
- Address validation should use the approved location/map service.

### API Requirements

```text
GET    /v1/saved-places
POST   /v1/saved-places
PATCH  /v1/saved-places/{id}
DELETE /v1/saved-places/{id}
```

---

## B4. Payment Methods

This screen manages customer payment options supported by Go-Volts.

### Screen Sections

#### Go-Volts Wallet

- Current balance where applicable
- Open Wallet action

#### Saved Payment Methods

Display supported saved payment methods.

### Actions

- Add payment method
- Set default payment method
- Remove payment method

### Security Rule

Sensitive card details must not be directly stored by the Go-Volts application unless explicitly supported by the approved payment architecture.

The payment provider should remain the authoritative system for sensitive payment credentials.

---

## B5. Privacy & Security

### Security

- Change password
- Password reset
- Google authentication status
- Active sessions/devices

### Privacy

- Personal data controls
- Location permissions
- Data sharing preferences where applicable

### Recommended Security Behaviour

When a password is changed or an important security action occurs:

- The backend should record the event.
- Appropriate session management should occur according to policy.
- Security notifications should be triggered where required.

### Important Rule

The client application must not be the sole authority for security-sensitive state.

---

# 5. GROUP D: Safety, Help & Support

## D1. Safety Centre

The Safety Centre should be easy to find from:

- Profile
- Help & Support
- Relevant active service experiences

### Features

- Emergency assistance information
- Share trip or delivery where supported
- Trusted contacts
- Report a safety issue
- Safety guidance

### Important Product Rule

The exact emergency workflow must be aligned with actual Go-Volts operational capabilities before launch.

The application must never imply that an emergency service or support team has been contacted unless that action has actually been confirmed.

---

## D2. Trusted Contacts

Customers can manage selected trusted contacts.

### Actions

- Add contact
- Edit contact
- Remove contact
- Select contacts for sharing where supported

### Suggested Data Model

```text
Contact ID
User ID
Name
Phone Number
Relationship/Label (Optional)
Created At
Updated At
```

### Business Rules

- Contacts belong to the customer account.
- Customers can only manage their own contacts.
- Sharing behaviour must follow the approved privacy policy.
- Sensitive contact information must be protected.

---

## D3. Help Centre

### Categories

- Ride Help
- Parcel Help
- Market Errand Help
- Scheduled Pickup Help
- Payment & Wallet
- Account & Login
- Safety

Each category may contain:

- Frequently asked questions
- Help articles
- Contact Support actions

### UX Logic

The Help Centre should prioritize self-service answers while keeping the Contact Support action easy to access.

---

## D4. Create Support Request

### Flow

```text
Help Centre
    ↓
Select Service
    ↓
Select Issue Category
    ↓
Describe Problem
    ↓
Attach Evidence (Optional)
    ↓
Submit Request
```

### Fields

- Related service
- Related booking, order or transaction where applicable
- Issue category
- Description
- Optional attachment

### Validation

- Required fields must be completed before submission.
- Attachments should be validated according to file type and size limits.
- The backend must verify that the referenced service belongs to the customer where applicable.

---

## D5. Support Ticket

### Suggested Status Flow

```text
SUBMITTED
    ↓
UNDER_REVIEW
    ↓
IN_PROGRESS
    ↓
RESOLVED
    ↓
CLOSED
```

### Screen Content

- Ticket reference
- Current status
- Related service
- Date submitted
- Updates or messages where supported
- Resolution information

### Technical Rule

Support ticket status must come from the backend.

The application must not display a ticket as resolved until the authoritative backend status confirms it.

---

# 6. Consolidated Navigation Structure

```text
PROFILE

├── Profile & Account
│   ├── Edit Profile
│   ├── Personal Information
│   └── Verification Status
│
├── Preferences
│   ├── Notification Settings
│   ├── Saved Places
│   └── Payment Methods
│
├── Privacy & Security
│   ├── Password
│   ├── Authentication
│   ├── Sessions/Devices
│   └── Privacy Controls
│
├── Safety
│   ├── Safety Centre
│   ├── Trusted Contacts
│   └── Report Safety Issue
│
├── Help & Support
│   ├── Help Centre
│   ├── Create Support Request
│   └── Support Tickets
│
└── Legal & Account Actions
    ├── Terms
    ├── Privacy Policy
    ├── Logout
    └── Account Deactivation/Deletion
```

---

# 7. Shared Technical Requirements

## Authentication

All Profile, Settings and Support operations must use the authenticated customer identity.

Supabase authentication remains responsible for the approved authentication flow.

Sensitive operations may require additional verification according to the final security policy.

## Authorization

The backend must enforce ownership rules.

Examples:

- A customer can only edit their own profile.
- A customer can only access their own saved places.
- A customer can only access their own trusted contacts.
- A customer can only access their own support tickets.
- A customer can only manage their own payment method references.

## State Management

The Flutter application should clearly handle:

```text
Loading
Empty
Success
Retryable Error
Offline
Pending Server Confirmation
```

## Responsive Behaviour

The customer app must support:

- Android devices
- iOS devices
- Safe areas
- Different phone widths

On narrow screens:

- Stack content vertically.
- Keep primary actions easy to reach.
- Avoid crowded side-by-side layouts.

On larger phones:

- Use additional space without changing the core information hierarchy.

---

# 8. Recommended Screen Design Groups

## FLOW A: Profile & Account

```text
Profile Home
    ↓
Edit Profile
    ↓
Personal Information
    ↓
Verification Status
```

## FLOW B: Settings & Preferences

```text
Settings Home
    ↓
Notification Settings
    ↓
Saved Places
    ↓
Payment Methods
    ↓
Privacy & Security
```

## FLOW D: Safety, Help & Support

```text
Safety Centre
    ↓
Trusted Contacts
    ↓
Help Centre
    ↓
Create Support Request
    ↓
Support Ticket
```

---

# 9. Acceptance Criteria

This section is ready for implementation and visual design when:

- Profile information is retrieved from the authenticated customer account.
- Profile changes are validated and saved through the backend.
- Verification status comes from an authoritative backend source.
- Notification preferences are grouped by service.
- Saved Places can be reused by supported Go-Volts services.
- Historical bookings are not broken when saved places are deleted.
- Payment credentials are handled through the approved payment architecture.
- Security-sensitive state is not controlled solely by the mobile client.
- Trusted contacts are protected by ownership and privacy rules.
- Support requests can be linked to relevant customer services.
- Support ticket statuses are backend-authoritative.
- Safety features accurately reflect real operational capabilities.
- All screens support loading and error states.
- The UI remains usable across common Android and iOS phone sizes.

---

# 10. Next Step

The next stage is to create the visual screen designs as three separate image flows:

1. **Flow A: Profile & Account**
2. **Flow B: Settings & Preferences**
3. **Flow D: Safety, Help & Support**

Each flow should be designed as its own full-screen mobile storyboard image, following the established Go-Volts visual design system.