#!/usr/bin/env bash
set -e

echo "==> Building PaperEyes for macOS..."
mkdir -p build
swiftc -O Sources/main.swift -o build/PaperEyes

echo "==> Built successfully: build/PaperEyes"
echo "==> Launching..."
killall PaperEyes 2>/dev/null || true
./build/PaperEyes &
echo "==> PaperEyes is now active in your menu bar (⌘⇧P to toggle)."
