#!/bin/bash
# render-outfits.sh — compile and run the Narayan outfit planche renderer
# NOT in CI. Run manually: bash scripts/render-outfits.sh
# Output: /tmp/bholeynath-outfits.png

set -e
cd "$(dirname "$0")/.."

SDK=$(xcrun --sdk macosx --show-sdk-path)

echo "Compiling renderer..."
swiftc \
  -parse-as-library \
  -sdk "$SDK" \
  -target arm64-apple-macosx15.0 \
  NotchBuddy/Sources/BholeynathKit/IslandScreenGeometry.swift \
  NotchBuddy/Sources/BholeynathKit/IslandTypes.swift \
  NotchBuddy/Sources/BholeynathKit/NarayanWardrobe.swift \
  NotchBuddy/Sources/BholeynathKit/BotEngine.swift \
  NotchBuddy/Sources/BholeynathKit/NarayanOutfitDrawing.swift \
  scripts/RenderOutfits.swift \
  -framework AppKit \
  -framework SwiftUI \
  -o /tmp/bholeynath-render-outfits \
  2>&1

echo "Running renderer..."
/tmp/bholeynath-render-outfits
echo "Opening..."
open /tmp/bholeynath-outfits.png
