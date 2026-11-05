// Festival → deity art map for the Hindu theme (Windows frontend).
//
// There is NO festival display surface in the Windows frontend yet, so this
// module is the single data-level source of truth: the hub welcome hero and
// the greeting blessing already show the round-1 art in real surfaces, and
// this map is what a future festival view should read. Do not invent art:
// entries whose portrait has not been made yet resolve to the diya ornament
// fallback. Round 2 (Lakshmi, Saraswati, Krishna, Hanuman) is shipped:
// public-domain paintings sourced from Wikimedia Commons (see
// windows/public/deities/CREDITS.md for provenance).
//
// Reverence rule: deity art is display art — framed, captioned, reverent.
// Nothing in this module is ever wired to a poke, drag or reaction handler,
// and the companion Narayan stays a separate abstract character drawn in code.
//
// Image paths are relative to the built frontend root: the optimized images
// live in windows/public/deities/ and are copied to dist/deities/ by Vite.
// The originals stay OUT of the repo tree (see the theme report).

export interface DeityArtEntry {
  /** English display name of the deity. */
  deity: string;
  /** Built-frontend-relative image path, or null when the portrait is not made yet. */
  image: string | null;
  /** Caption shown under the art. */
  caption: string;
  /** Mantra line, or null when no verified mantra is attached to this entry. */
  mantra: string | null;
  /** Ornament shown when there is no portrait (round-2 entries, unknown keys). */
  fallback: "diya";
}

interface Portrait {
  image: string;
  caption: string;
  mantra: string | null;
}

/** Portraits actually shipped in windows/public/deities/ (rounds 1–2).
 *  Round 1 (shiva, ganesha, durga) is original art made for Bholeynath;
 *  round 2 (lakshmi, saraswati, krishna, hanuman) is public-domain art
 *  from Wikimedia Commons — see windows/public/deities/CREDITS.md. */
export const DEITY_PORTRAITS: Record<string, Portrait> = {
  shiva: { image: "deities/shiva-hero.jpg", caption: "Shiva", mantra: "ॐ नमः शिवाय" },
  ganesha: { image: "deities/ganesha.jpg", caption: "Ganesha", mantra: "श्री गणेशाय नमः" },
  durga: { image: "deities/durga.jpg", caption: "Durga", mantra: null },
  lakshmi: { image: "deities/lakshmi.jpg", caption: "Lakshmi", mantra: "ॐ श्रीं महालक्ष्म्यै नमः" },
  saraswati: { image: "deities/saraswati.jpg", caption: "Saraswati", mantra: "ॐ ऐं सरस्वत्यै नमः" },
  krishna: { image: "deities/krishna.jpg", caption: "Krishna", mantra: "ॐ नमो भगवते वासुदेवाय" },
  hanuman: { image: "deities/hanuman.jpg", caption: "Hanuman", mantra: "ॐ हनुमते नमः" },
};

/** Festival key → deity. Keys follow the Nepali festival names used by the
 *  calendar data (Dashain sequence, Tihar, Shivaratri, …). */
export const FESTIVAL_DEITY: Record<string, string> = {
  // Round 1 — portraits shipped, wired to real art:
  ghatasthapana: "durga",
  phulpati: "durga",
  maha_ashtami: "durga",
  maha_navami: "durga",
  vijaya_dashami: "durga",
  dashain_holiday: "durga",
  maha_shivaratri: "shiva",
  // Round 2 — portraits shipped (public-domain art, see CREDITS.md):
  laxmi_puja: "lakshmi",
  tihar: "lakshmi",
  kag_tihar: "lakshmi",
  kukur_tihar: "lakshmi",
  gai_tihar: "lakshmi",
  govardhan_puja: "lakshmi",
  bhai_tika: "lakshmi",
  basanta_panchami: "saraswati",
  janmashtami: "krishna",
  hanuman_jayanti: "hanuman",
};

/** Display names for deities whose portrait is not made yet.
 *  Empty since round 2: every mapped deity now has a shipped portrait.
 *  Kept so a future round (e.g. Parvati) can add entries without changing
 *  the resolver below. */
const PENDING_NAMES: Record<string, string> = {};

/** Resolve a festival key to its display art (or the diya fallback). */
export function deityArtForFestival(key: string): DeityArtEntry {
  const deity = FESTIVAL_DEITY[key];
  if (deity && DEITY_PORTRAITS[deity]) {
    const p = DEITY_PORTRAITS[deity];
    return { deity, image: p.image, caption: p.caption, mantra: p.mantra, fallback: "diya" };
  }
  if (deity) {
    return { deity, image: null, caption: PENDING_NAMES[deity] ?? deity, mantra: null, fallback: "diya" };
  }
  return { deity: "unknown", image: null, caption: "", mantra: null, fallback: "diya" };
}
