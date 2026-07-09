#!/usr/bin/env bash
# Trackpad keys in the shared NSGlobalDomain. Regenerate with dump.sh.
set -euo pipefail
defaults write -g com.apple.swipescrolldirection -bool false
defaults write -g com.apple.trackpad.scaling -float 1
defaults write -g com.apple.trackpad.forceClick -bool true
defaults write -g AppleEnableSwipeNavigateWithScrolls -bool true
