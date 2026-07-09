#!/usr/bin/env bash
#
# dump.sh — re-export macOS keyboard shortcuts into this repo.
# Run it after changing shortcuts in System Settings → Keyboard → Keyboard
# Shortcuts, then commit the updated symbolichotkeys.plist.

set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"

defaults export com.apple.symbolichotkeys "$DIR/symbolichotkeys.plist"
plutil -convert xml1 "$DIR/symbolichotkeys.plist"   # keep it text/diffable

echo "Exported com.apple.symbolichotkeys -> $DIR/symbolichotkeys.plist"
echo "Review with 'git diff', then commit."
