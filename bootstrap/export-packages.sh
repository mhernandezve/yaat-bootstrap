#!/usr/bin/env bash
# Export installed packages for migration

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

REPO="${DOTFILES_REPO:-$HOME/.dotfiles}"
PACKAGES_DIR="$REPO/packages"

log_info "Exporting packages to $PACKAGES_DIR"

mkdir -p "$PACKAGES_DIR"

# Detect package manager
if command -v pacman >/dev/null 2>&1; then
    log_info "Detected pacman (Arch Linux)"
    
    # Export all explicitly installed packages
    pacman -Qqe > "$PACKAGES_DIR/pacman.txt"
    log_info "Exported $(wc -l < "$PACKAGES_DIR/pacman.txt") packages to pacman.txt"
    
    # Export AUR packages separately (if yay/paru available)
    if command -v yay >/dev/null 2>&1 || command -v paru >/dev/null 2>&1; then
        # AUR packages are those not in official repos
        pacman -Qqem > "$PACKAGES_DIR/aur.txt" 2>/dev/null || true
        if [[ -s "$PACKAGES_DIR/aur.txt" ]]; then
            log_info "Exported $(wc -l < "$PACKAGES_DIR/aur.txt") AUR packages to aur.txt"
        else
            rm -f "$PACKAGES_DIR/aur.txt"
        fi
    fi
    
elif command -v apt >/dev/null 2>&1; then
    log_info "Detected apt (Debian/Ubuntu)"
    
    # Export manually installed packages
    apt-mark showmanual > "$PACKAGES_DIR/apt.txt"
    log_info "Exported $(wc -l < "$PACKAGES_DIR/apt.txt") packages to apt.txt"
    
else
    log_warn "No supported package manager detected (pacman/apt)"
    exit 1
fi

log_info "Package export complete"
