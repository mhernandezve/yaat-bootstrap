#!/usr/bin/env bash
# Reload Hyprland configuration

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"

if is_hypr_session; then
    log_info "Reloading Hyprland..."
    run hyprctl reload
else
    log_info "Not in Hyprland session, skipping"
fi
