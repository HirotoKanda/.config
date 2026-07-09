#!/usr/bin/env bash
#
# dump.sh — re-export macOS input settings into this repo. Run after changing
# keyboard shortcuts or trackpad settings in System Settings, then commit the
# updated files.

set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"

# Whole domains that are trackpad/input-dedicated and safe to export/import.
DOMAINS=(
  com.apple.symbolichotkeys                            # keyboard shortcuts
  com.apple.AppleMultitouchTrackpad                    # built-in trackpad
  com.apple.driver.AppleBluetoothMultitouch.trackpad   # Magic Trackpad
)
for d in "${DOMAINS[@]}"; do
  defaults export "$d" "$DIR/$d.plist"
  plutil -convert xml1 "$DIR/$d.plist"                 # keep it text/diffable
  echo "  exported $d"
done

# Trackpad keys that live in the shared NSGlobalDomain cannot be exported as a
# whole domain (it holds machine UUIDs, locale, etc.), so regenerate a small
# `defaults write` script from their current values.
GLOBAL_KEYS=(
  com.apple.swipescrolldirection
  com.apple.trackpad.scaling
  com.apple.trackpad.forceClick
  AppleEnableSwipeNavigateWithScrolls
)
snippet="$DIR/globaldomain-trackpad.sh"
{
  echo "#!/usr/bin/env bash"
  echo "# Trackpad keys in the shared NSGlobalDomain. Regenerate with dump.sh."
  echo "set -euo pipefail"
  for k in "${GLOBAL_KEYS[@]}"; do
    type=$(defaults read-type -g "$k" 2>/dev/null | awk '{print $NF}') || true
    val=$(defaults read -g "$k" 2>/dev/null) || true
    [ -z "${type:-}" ] && continue
    case "$type" in
      boolean) [ "$val" = 1 ] && val=true || val=false; echo "defaults write -g $k -bool $val" ;;
      integer) echo "defaults write -g $k -int $val" ;;
      float)   echo "defaults write -g $k -float $val" ;;
      *)       echo "defaults write -g $k -string \"$val\"" ;;
    esac
  done
} > "$snippet"
chmod +x "$snippet"
echo "  regenerated $(basename "$snippet")"

echo "Done. Review with 'git -C \"$DIR/..\" diff', then commit."
