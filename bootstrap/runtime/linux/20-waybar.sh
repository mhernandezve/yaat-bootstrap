#!/usr/bin/env bash
# Restart Waybar

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"

if command -v waybar >/dev/null 2>&1; then
    log_info "Restarting waybar..."
    run pkill waybar 2>/dev/null || true
    run sleep 0.5
    if [[ "$DRY_RUN" -eq 1 ]]; then
        run waybar
    else
        waybar >/dev/null 2>&1 &
    fi
else
    log_info "waybar not found, skipping"
fi
