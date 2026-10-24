# PaperEyes for macOS

A lightweight, zero-latency screen texture overlay for macOS designed to alleviate digital eye strain by introducing physical paper grain and ambient lighting across your displays.

Inspired by tactile paper surfaces, built natively using AppKit, CoreGraphics, and Carbon.

---

## What Makes PaperEyes Awesome

### 1. 5 Handcrafted Paper Textures
Switch dynamically between different paper grain profiles:
- **Matte Paper:** Clean, fine-grained tactile tooth. Default high-frequency diffuser.
- **Whisper Weave:** Subtle woven fiber cross-hatch structure.
- **Aged Parchment:** Organic variance with warm fiber pockets.
- **Raw Kraft:** Specks and organic wood fiber variations.
- **E-Ink Reader:** High-contrast micro-pigment bead texture modeled after Kindle displays.

### 2. Desk Lamp Ambience Mode
- Casts a soft, warm radial vignette from the top-right corner of your screen using a soft-light gradient shader.
- Simulates reading under a cozy evening desk lamp.

### 3. Automatic App-Exclusion (Zero Interruption)
- Automatically pauses the texture overlay when you switch to color-critical or media applications (Photoshop, Lightroom, Figma, Final Cut Pro, QuickTime, VLC, Apple Photos).
- Instantly re-engages when you switch back to VS Code, Safari, Obsidian, Slack, or Terminal.

### 4. Pure Click-Through & Full-Screen Swipe Stability
- `ignoresMouseEvents = true`: Clicks, drags, trackpad gestures, and shortcuts pass directly through with 0ms lag.
- Configured with `.stationary`, `.fullScreenAuxiliary`, and `.canJoinAllSpaces`: stays perfectly anchored across desktop and full-screen app swipes without blinking or disappearing.

### 5. Global Hotkey (`⌘⇧P`)
- Toggle anywhere with `Cmd + Shift + P` via native Carbon `RegisterEventHotKey` (no Accessibility permissions required).

---

## Requirements

- macOS 12.0 Monterey or later
- Swift 5.5+ / Xcode Command Line Tools

---

## Quick Start (Compile & Run)

```bash
git clone https://github.com/abhisheksoni27/papereyes.git
cd papereyes

# Build and run
chmod +x build.sh
./build.sh
```

Or manually with the Swift compiler:
```bash
swiftc -O Sources/main.swift -o PaperEyes
./PaperEyes &
```

---

## Menu Bar Controls

- **Toggle Active / Paused:** `⌘⇧P`
- **Texture Finish:** Select Matte, Whisper Weave, Parchment, Kraft, or E-Ink
- **Desk Lamp Ambience:** Toggle cozy evening radial glow
- **Intensity:** Light (10%), Medium (16%), Strong (25% default), Heavy Parchment (35%)
- **Pause for Design/Video Apps:** On/Off (auto-detects Figma, Photoshop, VLC, etc.)

---

## License

MIT License. Clean-room implementation.
