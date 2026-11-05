// Festival → deity art map (src/hub/deity-art.ts): round-1 festivals resolve
// to shipped portraits, round-2 and unknown keys fall back to the diya ornament.

import { test } from "node:test";
import assert from "node:assert/strict";
import { existsSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import { DEITY_PORTRAITS, deityArtForFestival } from "../src/hub/deity-art.ts";

const here = dirname(fileURLToPath(import.meta.url));
const deityFile = (image) => join(here, "..", "public", image);

const DASHAIN = ["ghatasthapana", "phulpati", "maha_ashtami", "maha_navami", "vijaya_dashami", "dashain_holiday"];
const ROUND_2 = ["laxmi_puja", "tihar", "basanta_panchami", "janmashtami", "hanuman_jayanti"];

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

test("round-2 festivals resolve to the diya fallback, never invented art", () => {
  for (const key of ROUND_2) {
    const art = deityArtForFestival(key);
    assert.equal(art.image, null, `${key} must not claim art that does not exist`);
    assert.equal(art.fallback, "diya");
    assert.equal(art.mantra, null);
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
