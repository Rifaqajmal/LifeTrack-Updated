# Play Console — Data Safety Form Reference

Use these answers when filling out the Data Safety section in Play
Console (Play Console → App content → Data safety). This isn't a legal
document — it's a working reference for what LifeTrack actually does,
based on the app's real code, so the form is filled out accurately.

## Does your app collect or share any required user data types?
**Yes.**

## Data types collected

| Category | Data type | Collected? | Shared with third parties? | Purpose |
|---|---|---|---|---|
| Personal info | Email address | Yes | No¹ | Account creation/login (Firebase Auth) |
| Personal info | Name | Yes | No¹ | Birthdays you add are stored with a name |
| Personal info | Other (date of birth) | Yes | No¹ | Core app feature — birthday tracking |

¹ Firebase (Google) processes this data as our backend infrastructure
provider, not as an independent third party for their own purposes. See
Google's disclosure at https://firebase.google.com/support/privacy — you
may still need to declare Firebase as a "service provider" depending on
current Play Console categories at the time you submit.

## Data NOT collected
- Location, contacts, photos/videos, audio, calendar events
- Financial info, health info, messages
- App activity / analytics data (no analytics SDK is integrated)
- Advertising ID (no ads SDK is integrated)
- Device or other identifiers

## Is data encrypted in transit?
**Yes** — Firebase Auth and Realtime Database traffic is encrypted via
HTTPS/TLS by default.

## Can users request data deletion?
**Yes** — users can delete individual birthdays in-app. For full account
deletion, direct users to contact you (add your contact method to the
Play Store listing and to `docs/PRIVACY_POLICY.md`).

## Biometric data note
The optional biometric app-lock uses the device OS's own biometric APIs
(Android BiometricPrompt / iOS Face ID/Touch ID). LifeTrack never
receives, stores, or transmits biometric data — the OS returns only a
pass/fail result. This typically does NOT count as "collected" biometric
data under Play Console's definitions, but confirm current guidance at
submission time since Play Console's categories are periodically updated.

## Before submitting
- [ ] Re-check this against the live Data Safety form fields at
      submission time — Play Console's exact categories/wording change
      periodically, and this doc reflects the app's actual behavior, not
      necessarily the current form's exact labels
- [ ] Confirm your Firebase project's data processing terms if asked
- [ ] Fill in a real contact email in `PRIVACY_POLICY.md` before publishing it
