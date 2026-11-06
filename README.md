# Wishlist (Flutter frontend)

> Wish it. Snap it. Chase it. Grant it.

Flutter client for **Wishlist** from [SRD-WISH-001](./docs/Wishlist_SRD.pdf).  
Frontend-only with **Demo mode** (offline seeded Accra data).

## Run

```powershell
flutter pub get
flutter run -t lib/main_dev.dart
```

After code changes, prefer **hot restart (`R`)** over hot reload — constructor/shell changes break on reload.

Demo splash auto-enters Home as guest with seed lists.

## What’s working (MVP UI)

| Area | Status |
|------|--------|
| Splash → Home shell | Done (IndexedStack tabs) |
| Home lists + create list | Done |
| List views (grid/stack/timeline/board) | Done |
| Add wish (+ sheet, camera/gallery/quick) | Done |
| Wish detail, edit, delete+undo | Done |
| Savings + Reveal Meter + milestones | Done |
| Grant slide + celebration confetti | Done |
| Wish Jar draw | Done |
| Granted Shelf | Done |
| Vision Board drag stickers | Done |
| Share link / privacy | Done |
| Stardust, streak, Trophy room | Done |
| Settings + themes + font packs | Done |
| Notifications inbox | Done |
| Me profile | Done |

## Still later (needs backend / heavier assets)

- Drift offline sync + real API (dio client stub exists)
- Real OTP / Google / Apple auth
- Rive/Lottie Wishicons & sound pack
- Image editor / sticker cut-out
- Full jar physics + FCM push
- Admin console (web, out of this repo)

## Stack

Riverpod · go_router · flutter_animate · google_fonts · sensors_plus · confetti · share_plus · image_picker

Feature-first layout under `lib/features/` per SRD §10.2.
