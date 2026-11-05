// Festival → deity art map (src/hub/deity-art.ts): round-1 and round-2
// festivals resolve to shipped portraits; unknown keys fall back to the
// diya ornament.

import { test } from "node:test";
import assert from "node:assert/strict";
import { existsSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import { DEITY_PORTRAITS, deityArtForFestival } from "../src/hub/deity-art.ts";

const here = dirname(fileURLToPath(import.meta.url));
const deityFile = (image) => join(here, "..", "public", image);

const DASHAIN = ["ghatasthapana", "phulpati", "maha_ashtami", "maha_navami", "vijaya_dashami", "dashain_holiday"];

test("Dashain sequence resolves to the shipped Durga portrait", () => {
  for (const key of DASHAIN) {
    const art = deityArtForFestival(key);
    assert.equal(art.deity, "durga");
    assert.equal(art.image, "deities/durga.jpg");
    assert.ok(existsSync(deityFile(art.image)), `missing shipped art for ${key}: ${art.image}`);
  }
});

test("Maha Shivaratri resolves to the shipped Shiva portrait", () => {
  const art = deityArtForFestival("maha_shivaratri");
  assert.equal(art.deity, "shiva");
  assert.equal(art.image, "deities/shiva-hero.jpg");
  assert.equal(art.mantra, "ॐ नमः शिवाय");
  assert.ok(existsSync(deityFile(art.image)));
});

test("round-2 festivals resolve to the shipped public-domain portraits", () => {
  const EXPECTED = {
    laxmi_puja: ["lakshmi", "deities/lakshmi.jpg", "ॐ श्रीं महालक्ष्म्यै नमः"],
    tihar: ["lakshmi", "deities/lakshmi.jpg", "ॐ श्रीं महालक्ष्म्यै नमः"],
    basanta_panchami: ["saraswati", "deities/saraswati.jpg", "ॐ ऐं सरस्वत्यै नमः"],
    janmashtami: ["krishna", "deities/krishna.jpg", "ॐ नमो भगवते वासुदेवाय"],
    hanuman_jayanti: ["hanuman", "deities/hanuman.jpg", "ॐ हनुमते नमः"],
  };
  for (const [key, [deity, image, mantra]] of Object.entries(EXPECTED)) {
    const art = deityArtForFestival(key);
    assert.equal(art.deity, deity);
    assert.equal(art.image, image, `${key} must resolve to its shipped portrait`);
    assert.equal(art.mantra, mantra);
    assert.ok(existsSync(deityFile(art.image)), `missing shipped art for ${key}: ${art.image}`);
  }
});

test("unknown festival keys resolve to the diya fallback", () => {
  const art = deityArtForFestival("not_a_festival");
  assert.equal(art.image, null);
  assert.equal(art.fallback, "diya");
});

test("every shipped portrait file exists in public/deities", () => {
  for (const [name, p] of Object.entries(DEITY_PORTRAITS)) {
    assert.ok(existsSync(deityFile(p.image)), `missing portrait for ${name}: ${p.image}`);
  }
});
