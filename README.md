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
| Home lists + create / archive / pin | Done |
| List views + status filters (open / maybe later / granted) | Done |
| Add wish (real camera + gallery + quick) | Done |
| Wish detail, edit, soft-delete Bin, maybe later | Done |
| Savings + Reveal Meter + milestones | Done |
| Grant slide + celebration confetti | Done |
| Wish Jar draw | Done |
| Granted Shelf | Done |
| Vision Board drag stickers | Done |
| Share link / privacy / email invite | Done |
| Stardust, streak, Trophy room (+ calm mode) | Done |
| Settings + themes/fonts (persisted) + Help/Privacy | Done |
| Local DemoStore JSON persistence | Done |
| Lottie empty-state sparkle | Done |
| Notifications inbox | Done |
| Me profile | Done |

## Still later (needs backend / heavier assets)

- Drift offline sync + real API (dio client stub exists)
- Production OTP / Google / Apple OAuth SDKs (demo buttons exist)
- Custom Rive Wishicons (folder ready; Lottie used for now)
- Image editor / sticker cut-out
- Full jar physics + FCM push
- Admin console (web, out of this repo)

## Stack

Riverpod · go_router · flutter_animate · google_fonts · sensors_plus · confetti · share_plus · image_picker

Feature-first layout under `lib/features/` per SRD §10.2.
