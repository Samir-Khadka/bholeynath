<div align="center">

# Bholeynath for Windows

**Narayan doesn't get a notch on a PC — so he lives at the top of your screen instead.**

Approve Claude Code permissions, watch your session work, drop a file, chat with Claude, keep an eye on your services — without leaving what you're doing.

![Windows 10/11](https://img.shields.io/badge/Windows-10%2F11-0078D4?logo=windows)
![Tauri 2](https://img.shields.io/badge/Tauri-2-FFC131?logo=tauri&logoColor=black)
![Rust](https://img.shields.io/badge/Rust-backend-000?logo=rust)
![Code: MIT](https://img.shields.io/badge/code-MIT-green)

<img src="public/deities/shiva-hero.jpg" width="320" alt="Shiva in meditation on Mount Kailash">

ॐ नमः शिवाय

</div>

---

## Hindu theme

Bholeynath wears a complete Hindu theme: a manuscript aesthetic — parchment cards, gold rules, temple-arch headers, Om and mandala ornaments, diya motifs — with deity art shown with reverence on the hub welcome hero (Shiva, ॐ नमः शिवाय), the greeting blessing (Ganesha, श्री गणेशाय नमः) and festival art (Durga for the Dashain sequence, Shiva for Maha Shivaratri). Portraits for Lakshmi, Saraswati, Krishna and Hanuman, and a real parchment texture, are planned for round 2; until then those festivals fall back to a diya ornament. The deity art is display art only — Narayan, your assistant, is a separate companion drawn in code, never a depiction of a god. The manuscript texture is CSS/SVG only.

---

## Install

No public release exists yet for this fork. Build it yourself (Node.js, Rust, and the Tauri prerequisites for Windows required):

```powershell
cd windows
npm install
npm run tauri dev     # island on your screen
npm run tauri build   # installer (.msi / NSIS .exe)
```

**Windows will show a warning the first time — that's expected.** The installer isn't code-signed yet, so SmartScreen doesn't know the publisher:

1. A "Windows protected your PC" screen appears, with *Publisher: Unknown publisher*.
2. Click **More info**. This reveals a **Run anyway** button.
3. Click **Run anyway**. The installer starts normally.

## Using it

| What you do | What happens |
|---|---|
| Look at the top-centre of the screen | The closed island: a small black island that stays there while Bholeynath runs. It shows Narayan, or the time, the date, your Claude usage or what's playing (**Settings → General → Closed island shows**). **Hide the island** keeps nothing there: move the pointer to the very top-centre of the screen instead |
| Move the pointer onto the closed island | Narayan peeks out: the compact island |
| Click the small island | It opens. With **Settings → General → Open on hover**, resting the pointer on it is enough, and it folds again shortly after the pointer leaves (click inside to keep it open) |
| The **✕** at the top right of the open island | Folds it back to the compact island now, without waiting for the auto-close |
| Click Narayan | He gets annoyed. Three times in a row and he goes dizzy |
| Rest the pointer on Narayan for two seconds | Hearts |
| Right-click Narayan | The wardrobe: rest the pointer on an outfit to try it on, click to keep it. **Auto** dresses him for the season |
| Drag Narayan out of the island | He moves onto your desktop and hangs out there, in his outfit, watching your cursor. Drop him back on the island to bring him home |
| On the desktop: click / right-click / double-click Narayan | Poke him / the wardrobe / he flies home. Drag him to move him |
| Drag a file onto the island | Narayan turns into a box, swallows it, then offers to answer questions about it |
| Click a file in the session ticker | Its diff opens in the island; ↗ opens the file in VS Code, ‹ or `Esc` goes back |
| `Esc` | Closes the island |
| Put a file named like one of Narayan's sounds (`finish.wav`, `approval.mp3`, `greet.m4a`…) in the sounds folder | It replaces that sound after **Settings → General → Reload sounds**. **Open sounds folder** shows the folder: `%APPDATA%\Bholeynath\sounds` on Windows |
| Tray icon | Open, Weekly recap, Wardrobe…, Settings…, Pause, Quit — and **Update Bholeynath to X…** while a new version is out |
| `Ctrl+Alt+Space` | Opens the chat, from any app |
| `Ctrl+Alt+A` | Jumps to the waiting permission or question |
| `Ctrl+Alt+T` | Brings the session's window forward ("Open terminal") |
| `Ctrl+Alt+→` / `Ctrl+Alt+←` | Next / previous pill |
| `Ctrl+Alt+S` | Mutes or unmutes Narayan |
| `Ctrl+Alt+G` | Opens the wardrobe |
| `Ctrl+Alt+D` | Sends Narayan to the desktop, or brings him home |
| `Ctrl+Alt+N` | Opens and closes the island (off until you turn it on) |
| In the open island: `Ctrl+→` `Ctrl+←`, `Ctrl+1`–`Ctrl+9` | Switch pills |
| In the open island: `Ctrl+↓` `Ctrl+↑`, `Ctrl+O` | Walk the open GitHub list, open the highlighted row |
| In the open island: `Ctrl+E` | Opens the latest edit's diff, or closes the diff |
| In the open island: `Ctrl+Enter`, `Ctrl+K` | Send, start a new chat |
| In the open island: `Ctrl+,`, `Ctrl+P` | Settings, keep the island open |

## How it watches your agents

Bholeynath installs a small relay, `bholeynath-hook`, into your agent's hooks (Claude Code, Cursor, Codex, Gemini CLI and more). The hook forwards session events to the island over a local pipe — and **never blocks**: if the app doesn't answer, the hook exits immediately, so your agent is never left hanging. Tag any hook payload with `bholeynath_agent` to give that agent its own pill.

## Privacy, in one paragraph

No telemetry, no account. Keys live in Windows Credential Manager. The app only talks to the services you plug in (and, once you agree, to GitHub's releases API to tell you about new versions). Nothing is ever approved or emailed without your explicit click.

## What differs from the Mac version

The Mac app (carried over in `NotchBuddy/`) has Flow dictation, the call Notetaker, and voice ("OK Bholeynath") — those are Mac-only in the carried-over code and are **not** in the Windows build yet. Everything else above is the Windows build. The Windows frontend is TypeScript (`src/`, the island, Narayan's engine in `src/narayan/`); the backend is Rust (`src-tauri/`); the hook relay is its own crate (`hook/`, binary `bholeynath-hook`).
