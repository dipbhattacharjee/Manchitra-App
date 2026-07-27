# Manchitra — Full App Flow & Architecture Document

### User taps mapped to behind-the-scenes logic across all app modules

---

## 1. App Launch

| User sees/taps | Behind the scenes |
|---|---|
| Splash screen (branded, diya animation) | Firebase initializes; app checks for an existing auth session (`FirebaseAuth.currentUser`); local Panjika JSON asset loads into memory; connectivity check runs via `connectivity_plus` |
| — | If no internet: **No Internet screen** shown, blocks further load until connection resolves |
| — | If session exists: skip to Home. If not: Login screen |

---

## 2. Authentication

| User taps | Behind the scenes |
|---|---|
| "Continue with Google" | Firebase Google Sign-In flow triggers → returns credential → `FirebaseAuth.signInWithCredential()` → on success, checks/creates a matching user row in Supabase (`profiles` table keyed by Firebase UID) |
| "Continue with Phone" | Firebase Phone Auth sends OTP via SMS → user enters code → `FirebaseAuth.signInWithCredential()` with the OTP credential |
| "Continue with Email" | Standard `FirebaseAuth.signInWithEmailAndPassword()` / `createUserWithEmailAndPassword()` |
| — | On any successful auth: FCM device token is generated and stored against the user's profile in Supabase for push notifications; user is subscribed to default notification topics per their (default) preferences |

---

## 3. Home Screen

| User taps | Behind the scenes |
|---|---|
| Location label (e.g. "Kolkata, WB") | Opens **Location Picker screen** → GPS reverse-geocode or manual city search → selected city stored in app state/local storage → Home content re-filters to that city (only Kolkata has real data currently; others show "Coming soon" empty state) |
| A "Popular Routes" card | Fetches that curated route's stop list from `curated_routes` table → pre-fills the Planning page's Optimized Sequence with those stops → navigates to Planning screen |
| Search bar (from Home, if present) | Same debounced Supabase `ilike` query flow as the Map screen's search (see Section 4) |

---

## 4. Map Screen — Browsing

| User taps | Behind the scenes |
|---|---|
| Map screen opens | Query `pandals` table (filtered by selected city) from Supabase → results rendered as clustered markers via `flutter_map_marker_cluster`; each unclustered marker shows the pandal's `image_url` in a circular frame (falls back to icon if null); skeleton/pulsing placeholders shown while the query is in flight |
| Search bar — typing | Debounced (~300ms) `ilike` query against `pandals.name`, `.theme`, `.location` → live dropdown results appear; small spinner shows in the search bar while in flight |
| Mic icon | Requests mic permission if needed → `speech_to_text` starts listening (button shows pulsing "listening" state) → transcribed text fills the search field → triggers the same search query → auto-stops after a pause in speech |
| A cluster bubble (e.g. "8") | Map camera zooms in to that cluster's bounds, splitting it into individual markers |
| An individual pandal marker | Bottom sheet slides up with photo, name, description ("Read more" expands full text inline), crowd badge, distance/ETA from current location |
| "Read more" | Toggles `maxLines` between truncated and full, or opens a full detail page if there's more content (images, timings) than fits in the sheet |
| "Navigate" (single pandal) | `NavigationController.startSingleDestination()` — requests route from current GPS location → chosen pandal via OSRM `/route` (`steps: true`) → polyline + turn-by-turn instruction banner render on the Map screen; GPS position stream starts; on-path/rerouting checks begin |
| Recenter button | Animates map camera back to current GPS position |
| Layers button | Toggles between tile styles (e.g. day/night tint, or base tile provider) |
| Category chip / "Featured 2026" / "List View" | Filters the active `pandals` query by category/tag, or switches the screen to a scrollable list layout instead of the map |
| "Add Photo" (on pandal detail) | `image_picker` opens camera/gallery → selected image compressed client-side → uploaded to Supabase Storage bucket `pandal-photos` → new row inserted into `pandal_user_photos` with `status: 'pending'` → confirmation toast shown; photo won't appear publicly until an admin approves it |
| Crowd report buttons ("How busy is it?") | Inserts a row into `crowd_reports` (pandal_id, user_id, crowd_level, timestamp) → aggregation logic (recent reports within a rolling window) recalculates the pandal's displayed crowd badge |

---

## 5. Live Navigation (Active State)

| User taps/sees | Behind the scenes |
|---|---|
| Top instruction banner ("In 94 m, turn right...") | Continuously updated from `NavigationController`'s current step index, driven by the live GPS stream checking on-path status against the OSRM route geometry |
| Map auto-rotates | `flutter_compass` heading feeds into `MapController.rotate()` so the map stays forward-up during active navigation |
| User deviates from route | `NavigationController` detects the GPS position is outside tolerance of the current polyline → automatically re-requests a new OSRM route from the current position to the same destination → polyline and instructions update seamlessly |
| Close (X) on the bottom ETA card | `NavigationController.endNavigation()` — clears route polyline, current leg index, destination, ETA/distance state to null/initial; **cancels the GPS position stream subscription and any rerouting timers**; UI reactively clears the moment this state resets, leaving a clean map |
| Reaching a stop (multi-stop route) | Within tolerance radius of the current stop (or user taps "Next Stop"), `NavigationController` auto-advances: requests the next leg's route (current stop → next stop) via OSRM, updates header to "Navigating · Stop X of Y" |
| Reaching the final stop | Navigation session ends automatically; completion summary shown (total distance, time, stops visited) |

---

## 6. Routes / Planning Screen

| User taps | Behind the scenes |
|---|---|
| "Add Stop" | Category picker (Pandal / Restaurant / Other) → search/browse UI for that category → selected place appended to the active day's stop list in local state |
| A date on the Puja calendar strip | Selects that date as the active day being planned; stops added afterward are tagged with that `scheduled_date` |
| "Optimize" | Nearest-neighbour algorithm runs: starting from current GPS location, repeatedly picks the nearest unvisited stop (via OSRM distance matrix, or haversine as fast fallback) → reorders the `sequence_order` of stops for that day → recalculates and displays total distance/time/crowd summary |
| "Clear" | Resets the day's stop sequence (with a confirmation dialog since it's destructive) |
| Reorder arrows (↑↓) on a stop card | Manually swaps `sequence_order` between adjacent stops, overriding the optimizer's suggestion |
| "Save This Hop" | Inserts/updates rows in `schedules` and `schedule_stops` in Supabase, scoped to the current user |
| "Start Multi-Stop Navigation" | Full ordered waypoint list (current location + all stops for the active day, in sequence) is handed to `NavigationController.startMultiStop()` → app navigates to the Map screen with navigation already active on Stop 1, header showing "Navigating · Stop 1 of N" |
| "Add to Calendar" (on a stop or Puja day) | Constructs a local `Event` object → `Add2Calendar.addEvent2Cal()` opens the device's native calendar app pre-filled — no network call involved |

---

## 7. Notifications

| User taps/sees | Behind the scenes |
|---|---|
| Notification arrives (push) | Triggered server-side: an Edge Function fires when a new row lands in `notifications` (e.g. a crowd-level trigger, an admin-authored festival update, or an auto-generated system notification) → publishes to the relevant FCM topic → device receives it via `firebase_messaging`; if app is foregrounded, `flutter_local_notifications` displays it manually |
| Notifications screen opens | Queries `user_notifications` joined with `notifications`, ordered by `delivered_at` descending, filtered by the active tab (All/Festival Updates/Crowd Alerts) |
| Tapping a notification card | Marks `is_read = true` on that `user_notifications` row → navigates via the notification's `deep_link` field (e.g. straight to a pandal detail page or a saved route) |
| Settings gear icon | Opens **Notification Settings screen** → toggling a category writes to `user_notification_preferences` and immediately subscribes/unsubscribes the device's FCM topic accordingly; quiet hours settings suppress push delivery timing |

---

## 8. Cross-Cutting States (appear anywhere, as needed)

| Trigger | What shows |
|---|---|
| No connectivity | Full-screen **No Internet** state, auto-dismisses when connection returns (`connectivity_plus` listener) |
| Requests unusually slow/timing out | **Slow Network** state — softer messaging than no-internet, with retry |
| Unhandled API/app error | Generic **Error screen** — "Something went wrong" + Try Again |
| Location permission denied | Dedicated screen explaining why GPS is needed + button to open device settings |
| Empty lists (no saved routes, no search results, etc.) | Shared **Empty State** widget with contextual message + action button |
| Any list/detail screen mid-load | Skeleton loaders (shimmer) matching the real content's layout, not blank screens or bare spinners |

---

## High-Level Architecture Summary

```
Flutter App (UI + local state)
  │
  ├── Firebase Auth ── login/session, FCM token registration
  ├── Firebase Cloud Messaging ── push notification delivery
  ├── Supabase (Postgres + Storage + Edge Functions)
  │     ├── pandals, restaurants/other places
  │     ├── crowd_reports → aggregated crowd levels
  │     ├── schedules, schedule_stops → multi-day planning
  │     ├── notifications, user_notifications, user_notification_preferences
  │     ├── pandal_user_photos (moderated) + Storage bucket
  │     └── curated_routes → admin-authored Popular Routes
  ├── OSRM (routing engine) ── /route, /nearest, /match, distance matrix
  ├── flutter_map + OpenStreetMap tiles ── map rendering
  └── Device-native: GPS (geolocator), compass (flutter_compass),
        speech-to-text, device calendar (add_2_calendar), camera/gallery (image_picker)
```
