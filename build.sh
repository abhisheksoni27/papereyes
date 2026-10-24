#!/usr/bin/env bash
set -e

echo "==> Building Paperman for macOS..."
mkdir -p build
swiftc -O Sources/main.swift -o build/Paperman

echo "==> Built successfully: build/Paperman"
echo "==> Launching..."
killall Paperman 2>/dev/null || true
./build/Paperman &
echo "==> Paperman is now active in your menu bar (⌘⇧P to toggle)."
