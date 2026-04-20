#!/usr/bin/env bash
# Install packages from exported lists

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

REPO="${DOTFILES_REPO:-$HOME/.dotfiles}"
PACKAGES_DIR="$REPO/packages"
DRY_RUN=0
ONLY_MISSING=0
SKIP_LIST=""

usage() {
    cat <<'EOF'
Usage: install-packages.sh [OPTIONS]

Options:
  --dry-run         Preview what would be installed
  --only-missing    Only install packages not already installed
  --skip list       Comma-separated list of packages to skip
  --help            Show this help

Examples:
  install-packages.sh                    # Install all packages
  install-packages.sh --dry-run          # Preview only
  install-packages.sh --only-missing     # Skip already installed
  install-packages.sh --skip pkg1,pkg2   # Skip specific packages
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        --only-missing)
            ONLY_MISSING=1
            shift
            ;;
        --skip)
            SKIP_LIST="${2:-}"
            [[ -n "$SKIP_LIST" ]] || { log_error "--skip requires value"; exit 2; }
            shift 2
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            log_error "Unknown argument: $1"
            usage >&2
            exit 2
            ;;
    esac
done

# Check packages directory exists
[[ -d "$PACKAGES_DIR" ]] || { log_error "Packages directory not found: $PACKAGES_DIR"; exit 1; }

# Detect package manager and install
if command -v pacman >/dev/null 2>&1; then
    log_info "Using pacman (Arch Linux)"
    
    INSTALL_CMD="pacman -S --needed"
    if command -v yay >/dev/null 2>&1; then
        INSTALL_CMD="yay -S --needed"
        log_info "Using yay for AUR support"
    elif command -v paru >/dev/null 2>&1; then
        INSTALL_CMD="paru -S --needed"
        log_info "Using paru for AUR support"
    fi
    
    # Read package list
    if [[ -f "$PACKAGES_DIR/pacman.txt" ]]; then
        mapfile -t packages < "$PACKAGES_DIR/pacman.txt"
        
        # Filter already installed if --only-missing
        if [[ "$ONLY_MISSING" -eq 1 ]]; then
            missing_packages=()
            for pkg in "${packages[@]}"; do
                if ! pacman -Q "$pkg" >/dev/null 2>&1; then
                    missing_packages+=("$pkg")
                fi
            done
            packages=("${missing_packages[@]}")
            log_info "Found ${#packages[@]} missing packages"
        fi
        
        # Filter skipped packages
        if [[ -n "$SKIP_LIST" ]]; then
            IFS=',' read -ra skip_array <<< "$SKIP_LIST"
            filtered_packages=()
            for pkg in "${packages[@]}"; do
                skip=0
                for skip_pkg in "${skip_array[@]}"; do
                    if [[ "$pkg" == "$skip_pkg" ]]; then
                        skip=1
                        break
                    fi
                done
                [[ "$skip" -eq 0 ]] && filtered_packages+=("$pkg")
            done
            packages=("${filtered_packages[@]}")
        fi
        
        if [[ ${#packages[@]} -eq 0 ]]; then
            log_info "No packages to install"
            exit 0
        fi
        
        if [[ "$DRY_RUN" -eq 1 ]]; then
            log_info "[DRY-RUN] Would install ${#packages[@]} packages:"
            printf '  %s\n' "${packages[@]}"
        else
            log_info "Installing ${#packages[@]} packages..."
            # Install in batches to avoid command line length limits
            batch_size=50
            for ((i=0; i<${#packages[@]}; i+=batch_size)); do
                batch=("${packages[@]:i:batch_size}")
                run $INSTALL_CMD "${batch[@]}"
            done
        fi
    else
        log_warn "No pacman.txt found in $PACKAGES_DIR"
    fi
    
elif command -v apt >/dev/null 2>&1; then
    log_info "Using apt (Debian/Ubuntu)"
    
    if [[ -f "$PACKAGES_DIR/apt.txt" ]]; then
        mapfile -t packages < "$PACKAGES_DIR/apt.txt"
        
        # Filter already installed if --only-missing
        if [[ "$ONLY_MISSING" -eq 1 ]]; then
            missing_packages=()
            for pkg in "${packages[@]}"; do
                if ! dpkg -l "$pkg" >/dev/null 2>&1; then
                    missing_packages+=("$pkg")
                fi
            done
            packages=("${missing_packages[@]}")
        fi
        
        if [[ ${#packages[@]} -eq 0 ]]; then
            log_info "No packages to install"
            exit 0
        fi
        
        if [[ "$DRY_RUN" -eq 1 ]]; then
            log_info "[DRY-RUN] Would install ${#packages[@]} packages:"
            printf '  %s\n' "${packages[@]}"
        else
            log_info "Installing ${#packages[@]} packages..."
            run apt install -y "${packages[@]}"
        fi
    else
        log_warn "No apt.txt found in $PACKAGES_DIR"
    fi
    
else
    log_error "No supported package manager found (pacman/apt)"
    exit 1
fi

log_info "Package installation complete"
