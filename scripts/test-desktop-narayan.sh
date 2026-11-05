#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
TEST_DIR="$(mktemp -d "${TMPDIR:-/tmp}/bholeynath-desktop.XXXXXX")"
trap 'rm -rf "$TEST_DIR"' EXIT
swiftc NotchBuddy/Sources/App/DesktopNarayanLogic.swift \
    tests/DesktopNarayanTests.swift -o "$TEST_DIR/desktop-narayan-tests"
"$TEST_DIR/desktop-narayan-tests"
