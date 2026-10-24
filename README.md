# Paperman for macOS (Clean-Room Native Clone)

A lightweight, zero-latency screen texture overlay for macOS designed to alleviate digital eye strain by introducing physical paper grain across your displays.

Inspired by [paperman.cc](https://paperman.cc), built natively using AppKit, CoreGraphics, and Carbon.

---

## Features

- **Tactile Paper Tooth:** High-frequency organic micro-grain procedural texture that diffuses harsh screen contrast.
- **Pure Click-Through (`ignoresMouseEvents`):** 100% transparent event passthrough. Clicks, gestures, text selection, and window dragging behave normally with 0ms overhead.
- **Stationary Across Full-Screen Apps & Spaces:** Overlay remains fixed and anchored during Trackpad swipes and Mission Control full-screen transitions (`.stationary`, `.fullScreenAuxiliary`, `.canJoinAllSpaces`).
- **Global Hotkey (`⌘⇧P`):** Toggle the effect anywhere from within any app via Carbon `RegisterEventHotKey` without needing macOS Accessibility or Input Monitoring permissions.
- **Native Menu Bar Interface:** Crisp, retina vector template icon with quick-switch presets:
  - **Light (10%)**
  - **Medium (16%)**
  - **Strong (25%)** *(Default)*
  - **Heavy Parchment (35%)**
- **Ultra-Low Resource Footprint:** Runs with virtually 0% CPU and < 20MB of memory.

---

## Requirements

- macOS 12.0 Monterey or later
- Swift 5.5+ / Xcode Command Line Tools

---

## Quick Start (Compile & Run)

Clone and build directly via Terminal:

```bash
git clone <YOUR_GIT_REMOTE_URL>
cd paperman-macos

# Compile
swiftc -O Sources/main.swift -o Paperman

# Run in background
./Paperman &
```

Or run via the build script:

```bash
chmod +x build.sh
./build.sh
```

---

## Usage & Controls

| Action | Shortcut / Interaction |
| :--- | :--- |
| **Toggle On/Off** | `Cmd + Shift + P` or click Menu Bar icon → Toggle |
| **Change Opacity** | Click the menu bar icon and select a preset |
| **Quit** | Menu bar icon → `Quit (⌘Q)` |

---

## How It Works Under The Hood

1. **`NSWindow` ScreenSaver Level:** Sets window level to `CGWindowLevelForKey(.screenSaverWindow)` so the texture floats gently above all standard apps, full-screen spaces, and system UI.
2. **`NSGraphicsContext.setBlendMode(.multiply)`:** Blends the paper luminance values over the screen's backbuffer, softening specular glare without harsh yellow/orange color temperature shifts.
3. **Template Vector Rendering:** Uses an `NSImage(isTemplate: true)` to ensure dynamic adaptivity to macOS Light Mode and Dark Mode menu bars.

---

## License

MIT License. Designed and reverse-engineered with clean-room principles.
