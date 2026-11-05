// First-run voice setup for the « OK Bholeynath » page (src/hub/pages/voice.ts),
// as plain data, so the page and the tests share it.
//
// English literals on purpose: the hub pages sit outside the i18n scan's
// checked directories, and a t() key here would need a translation in every
// language before the suite passes.

export interface VoiceSetupStep {
  text: string;
  /** done: ready. todo: still needed. info: guidance, not a check. */
  state: "done" | "todo" | "info";
}

/** The three things voice needs before it can listen. */
export function voiceSetupSteps(modelReady: boolean, hasClaudeKey: boolean): VoiceSetupStep[] {
  return [
    {
      text: "Download the voice model (about 700 MB, once — it stays on this computer)",
      state: modelReady ? "done" : "todo",
    },
    {
      text: "Add your Claude key in Notch → Chat (Bholeynath answers with Claude)",
      state: hasClaudeKey ? "done" : "todo",
    },
    {
      text: "Allow microphone access when your system asks",
      state: "info",
    },
  ];
}
