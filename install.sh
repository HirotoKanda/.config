#!/usr/bin/env bash
#
# install.sh — bootstrap a fresh Apple Silicon Mac from this dotfiles repo.
#
# Usage:
#   git clone https://github.com/HirotoKanda/.config.git ~/.config
#   ~/.config/install.sh
#
# Idempotent: safe to re-run. Installs Homebrew + packages, symlinks the
# $HOME-targeted configs (Claude Code via stow; zsh files at the repo root),
# and sets up the shell. XDG-native tools (nvim, sheldon, kitty, wezterm,
# ghostty, starship, mise, gh …) are read from ~/.config directly and need
# no linking.

set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.config}"
BREW_PREFIX="/opt/homebrew"

log()  { printf '\n\033[1;34m==>\033[0m \033[1m%s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }

# ---- 0. Sanity: Apple Silicon macOS ---------------------------------------
if [ "$(uname -s)" != "Darwin" ] || [ "$(uname -m)" != "arm64" ]; then
  echo "This script targets Apple Silicon macOS (arm64)." >&2
  exit 1
fi

# ---- 1. Xcode Command Line Tools (git, clang, make) -----------------------
if ! xcode-select -p >/dev/null 2>&1; then
  log "Installing Xcode Command Line Tools…"
  xcode-select --install || true
  echo "Finish the CLT installer dialog, then re-run this script." >&2
  exit 0
fi

# ---- 2. Homebrew (Apple Silicon -> /opt/homebrew) -------------------------
if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew…"
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$("$BREW_PREFIX/bin/brew" shellenv)"

# ---- 3. Packages from the Brewfile ----------------------------------------
if [ -f "$DOTFILES/Brewfile" ]; then
  log "Installing packages (brew bundle)…"
  brew bundle --file="$DOTFILES/Brewfile" || warn "brew bundle reported errors; continuing."
fi

# ---- 4. Symlink $HOME-targeted (non-XDG) configs via stow -----------------
# Tools that ignore XDG and read straight from $HOME each get a package under
# stow/: Claude Code (~/.claude), zsh (~/.zshrc, .zshenv, .zprofile, .zlogin),
# yabai (~/.yabairc). XDG-native tools (nvim, sheldon, git, …) need no linking.
if command -v stow >/dev/null 2>&1 && [ -d "$DOTFILES/stow" ]; then
  log "Linking stow packages into \$HOME…"
  for pkg in "$DOTFILES"/stow/*/; do
    [ -d "$pkg" ] || continue
    name="$(basename "$pkg")"
    echo "  stow: $name"
    stow -d "$DOTFILES/stow" -t "$HOME" --restow "$name" \
      || warn "stow '$name' hit a conflict — resolve, then: stow -d \"$DOTFILES/stow\" -t \"\$HOME\" $name"
  done
fi

# ---- 4c. macOS keyboard shortcuts -----------------------------------------
if [ -f "$DOTFILES/macos/symbolichotkeys.plist" ]; then
  log "Importing macOS keyboard shortcuts…"
  defaults import com.apple.symbolichotkeys "$DOTFILES/macos/symbolichotkeys.plist" || warn "shortcuts import failed"
  # apply without a logout
  /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u 2>/dev/null || true
fi

# ---- 5. Runtimes & shell plugins ------------------------------------------
command -v mise    >/dev/null 2>&1 && { log "mise install…"; mise install -y || warn "mise install skipped"; }
command -v sheldon >/dev/null 2>&1 && { log "sheldon lock…"; sheldon lock    || warn "sheldon lock skipped"; }

# ---- 6. Make Homebrew zsh the login shell ---------------------------------
BREW_ZSH="$BREW_PREFIX/bin/zsh"
if [ -x "$BREW_ZSH" ] && [ "${SHELL:-}" != "$BREW_ZSH" ]; then
  log "Setting Homebrew zsh as the default shell…"
  grep -qxF "$BREW_ZSH" /etc/shells || echo "$BREW_ZSH" | sudo tee -a /etc/shells >/dev/null
  chsh -s "$BREW_ZSH" || warn "chsh failed; set the login shell manually."
fi

# ---- 7. Reminders for secrets that are (intentionally) NOT in git ---------
log "Bootstrap complete."
cat <<'EOF'

These hold secrets, so they are NOT in the repo — set them up manually:
  • GitHub CLI      : gh auth login
  • GitHub Copilot  : re-sign-in from your editor
  • Claude Code     : run `claude` (re-runs OAuth on first launch)
  • SSH keys        : restore ~/.ssh/kanda_key from your backup / keychain

Then finish tool setup:
  • yabai           : yabai --start-service   (scripting addition needs a sudoers entry — see the yabai wiki)

Open a new terminal to load your shell.
EOF
