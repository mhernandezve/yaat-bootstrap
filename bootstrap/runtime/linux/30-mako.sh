#!/usr/bin/env bash
# Restart Mako notification daemon

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"

if command -v mako >/dev/null 2>&1; then
    log_info "Restarting mako..."
    run pkill -x mako 2>/dev/null || true

    if [[ "$DRY_RUN" -ne 1 ]]; then
        for _ in {1..20}; do
            if ! pgrep -x mako >/dev/null 2>&1; then
                break
            fi
            sleep 0.1
        done
    else
        run sleep 0.5
    fi

    if [[ "$DRY_RUN" -eq 1 ]]; then
        run mako
    else
        if pgrep -x mako >/dev/null 2>&1; then
            log_warn "mako is still running after pkill; skipping restart"
        else
            mako >/dev/null 2>&1 &
        fi
    fi
else
    log_info "mako not found, skipping"
fi
