# Bholeynath — name, character and artwork

Bholeynath is a fork of [Coucou](https://github.com/louis-cfm/coucou) under the
MIT License. The MIT `LICENSE` file and its original copyright notice are kept
intact, as the license requires, and the original author's copyright is not
stripped from code headers.

## What the MIT license covers here

The MIT License covers the **source code** of Bholeynath, including this fork's
changes: the rename itself, the Narayan character code, the icon sources, and
the synthesized sounds.

## What belongs to this fork (Samir Khadka)

- the names **"Bholeynath"** (the app) and **"Narayan"** (the assistant and
  character);
- the **Narayan character** — its design, look, expressions and animations as
  drawn in code (deep indigo body, gold eyes, flame/petal crown, lotus-petal
  almond eyes);
- the **Bholeynath app icon** — `bholeynath-icon.svg` (gold crescent moon +
  abstract trishul on deep indigo) and every raster icon derived from it
  (`windows/src-tauri/icons/`, `NotchBuddy/*.xcassets/`,
  `android/.../mipmap-xxxhdpi/ic_launcher.png`);
- the **sounds** — `NotchBuddy/Resources/sounds/*.wav` (29 files) and
  `android/app/src/main/res/raw/*.wav` (14 files), synthesized for this fork
  (sine/triangle tones, no samples).

## Bholeynath for Android

Bholeynath for Android (`android/`) is part of Bholeynath and uses the name,
Narayan, the icon and the sounds. Its code, and the phone link in
`windows/src-tauri/src/phone_link/`, are © Rhytam Biswas under the MIT License
([`android/LICENSE`](android/LICENSE)); the assets stay under this file. The
app is free, with no ads and no paid features.

## What is NOT this fork's, and is not shipped as its own

The original Coucou/Mochi names, the Mochi character, the Coucou icon, and the
Coucou sounds are **not** included in Bholeynath and remain the property of
their author. No Coucou/Mochi artwork, name, or audio is used by the app, and
no README or UI text references it.

Two carried-over leftovers are honest exceptions, pending deletion — they are
**not** used by the app and **not** claimed as this fork's:

- the old upstream images still present under `docs/media/`, `design/`, and
  `windows/screenshots/` (they depict the previous character; nothing in the
  app or docs references them anymore);
- the `CHANGELOG.md` history, which is the upstream record and still mentions
  the old names.

The `relay/` worker is also carried over unchanged from upstream (see its own
README); its default URL still points at the upstream deployment.

## What you can do

- Build and run Bholeynath from this repository, for yourself, as it is.
- Fork it and contribute back with pull requests.
- Show, review, write or talk about Bholeynath (articles, videos, posts),
  including screenshots of the new art.

## What you can't do without written permission

- Publish or distribute an app, a fork or a derivative work under the name
  "Bholeynath" or "Narayan", or with the Bholeynath icon, the Narayan character
  or the Bholeynath sounds — on the App Store, on GitHub releases, or anywhere
  else.
- Use any of these assets commercially, or in a way that suggests your project
  is Bholeynath or is made or endorsed by its author.

If you fork Bholeynath to ship your own app, that's welcome under the MIT
License: just give it **your own name, icon, character and sounds**.

## Questions

Open an issue on [GitHub](https://github.com/Samir-Khadka/bholeynath/issues).
