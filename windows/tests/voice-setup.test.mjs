// Voice defaults and first-run setup (src/hub/shell.ts, src/hub/voice-setup.ts,
// windows/src-tauri/src/flow/store.rs): voice is on by default, but the Rust
// side only starts listening once the model and the Claude key are ready,
// and the hub page guides setup in plain language until then.

import { test } from "node:test";
import assert from "node:assert/strict";
import { registerHooks } from "node:module";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import ts from "typescript";
import { installFakeDom } from "./fakedom.mjs";
import { calls, emit, sent } from "./tauri.mjs";

// Same harness as hub.test.mjs: the shell imports its stylesheets.
registerHooks({
  resolve(specifier, context, nextResolve) {
    if (specifier.endsWith(".css")) {
      return { url: new URL(specifier, context.parentURL).href, shortCircuit: true };
    }
    return nextResolve(specifier, context);
  },
  load(url, context, nextLoad) {
    if (url.endsWith(".css")) return { format: "module", source: "", shortCircuit: true };
    if (url.endsWith("/hub/hero.ts")) {
      const { outputText } = ts.transpileModule(readFileSync(fileURLToPath(url), "utf8"), {
        compilerOptions: { target: ts.ScriptTarget.ES2022, module: ts.ModuleKind.ESNext },
      });
      return { format: "module", source: outputText, shortCircuit: true };
    }
    return nextLoad(url, context);
  },
});

installFakeDom();
document.visibilityState = "hidden";
document.addEventListener = () => {};
document.documentElement = { dataset: {} };
window.addEventListener = () => {};

const { DEFAULT_STATUS } = await import("../src/hub/shell.ts");
const { voiceSetupSteps } = await import("../src/hub/voice-setup.ts");

test("voice is on by default in the hub fallback status", () => {
  assert.equal(DEFAULT_STATUS.prefs.voice, true);
  assert.equal(DEFAULT_STATUS.prefs.voiceLanguage, "auto");
  assert.equal(DEFAULT_STATUS.prefs.voiceOutput, "system");
  assert.equal(DEFAULT_STATUS.models.parakeet.state, "missing");
  assert.equal(DEFAULT_STATUS.models.nepali.state, "missing");
  assert.equal(DEFAULT_STATUS.models.downloadMb, 897);
});

test("the backend default is voice on, gated by the model and key in voice::sync", () => {
  const store = readFileSync(new URL("../src-tauri/src/flow/store.rs", import.meta.url), "utf8");
  const defaults = store.slice(store.indexOf("impl Default for Prefs"), store.indexOf("impl Default for Prefs") + 800);
  assert.match(defaults, /voice: true,/);
  const voice = readFileSync(new URL("../src-tauri/src/voice/mod.rs", import.meta.url), "utf8");
  assert.match(voice, /requirements_met\(\)/);
  assert.match(voice, /wanted && requirements_met\(\)/);
});

test("setup steps name the model, the key and the microphone, in order", () => {
  assert.deepEqual(
    voiceSetupSteps(false, false).map((s) => s.state),
    ["todo", "todo", "info"],
  );
  assert.deepEqual(
    voiceSetupSteps(true, true).map((s) => s.state),
    ["done", "done", "info"],
  );
  assert.match(voiceSetupSteps(false, false)[0].text, /900 MB/);
  assert.match(voiceSetupSteps(false, false)[1].text, /Claude key/);
  assert.match(voiceSetupSteps(false, false)[2].text, /microphone/);
});

test("a ready model with a key leaves nothing to do", () => {
  const steps = voiceSetupSteps(true, true);
  assert.ok(steps.every((s) => s.state !== "todo"));
});
