#!/usr/bin/env bash
# =============================================================
# install.sh — One-line installer for Personal Operating System (POS)
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/lucarelli-d-stesi/personal-workspace-template/main/setup/install.sh | bash
#
# This script:
#   1. Checks and installs base prerequisites (git, curl)
#   2. Clones or updates the personal-workspace framework
#   3. Launches the interactive bootstrap wizard
# =============================================================
set -euo pipefail

# If running via pipe (e.g. curl ... | bash), reconnect stdin to terminal
if [ ! -t 0 ] && [ -e /dev/tty ]; then
    exec < /dev/tty
fi

# Terminal colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

ok()   { echo -e "  [${GREEN}✓${NC}] $*"; }
info() { echo -e "  [${BLUE}i${NC}] $*"; }
warn() { echo -e "  [${YELLOW}!${NC}] $*"; }
err()  { echo -e "  [${RED}✗${NC}] $*"; }
die()  { err "$*"; exit 1; }

echo ""
echo -e "${BOLD}============================================================${NC}"
echo -e "${BOLD}     Benvenuto nel Personal Operating System (POS)          ${NC}"
echo -e "${BOLD}============================================================${NC}"
echo "  Questo installer configurerà la base operativa sul tuo computer."
echo ""

# -------------------------------------------------------------
# 1. Prerequisiti minimi (git, curl)
# -------------------------------------------------------------
info "Controllo prerequisiti..."

install_pkg() {
    local pkg="$1"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &>/dev/null; then
            brew install "$pkg"
        else
            die "Homebrew non trovato. Installa $pkg o Homebrew: https://brew.sh"
        fi
    elif [ -f /etc/debian_version ]; then
        sudo apt-get update && sudo apt-get install -y "$pkg"
    elif [ -f /etc/fedora-release ]; then
        sudo dnf install -y "$pkg"
    elif [ -f /etc/arch-release ]; then
        sudo pacman -S --noconfirm "$pkg"
    else
        die "Impossibile installare automaticamente $pkg su questo sistema. Installalo manualmente e rilancia."
    fi
}

if ! command -v curl &>/dev/null; then
    warn "curl non trovato. Tentativo di installazione..."
    install_pkg curl
fi

if ! command -v git &>/dev/null; then
    warn "git non trovato. Tentativo di installazione..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Installazione Command Line Tools di macOS..."
        xcode-select --install || true
        die "Completa l'installazione dei Command Line Tools e rilancia lo script."
    else
        install_pkg git
    fi
fi

if ! command -v python3 &>/dev/null; then
    warn "python3 non trovato. Tentativo di installazione..."
    install_pkg python3
fi
ok "Prerequisiti verificati (git, curl, python3 presenti)."

# -------------------------------------------------------------
# 2. Posizione del workspace
# -------------------------------------------------------------
USER_HOME=$(getent passwd "$(id -un)" 2>/dev/null | cut -d: -f6 || echo "$HOME")
[ -z "$USER_HOME" ] && USER_HOME="$HOME"

DEFAULT_DIR="$USER_HOME/personal-workspace"
FRAMEWORK_REPO="https://github.com/lucarelli-d-stesi/personal-workspace-template.git"

TARGET_DIR="${POS_DIR:-$DEFAULT_DIR}"

if [ -d "$TARGET_DIR/.git" ]; then
    info "Cartella già presente in $TARGET_DIR. Aggiornamento in corso..."
    git -C "$TARGET_DIR" pull --rebase origin main || warn "Aggiornamento git pull non riuscito, continuo con i file locali..."
    ok "Framework aggiornato."
elif [ -d "$TARGET_DIR" ]; then
    warn "La directory $TARGET_DIR esiste già ma non è un repository Git."
else
    info "Clonazione del framework in $TARGET_DIR..."
    git clone "$FRAMEWORK_REPO" "$TARGET_DIR"
    ok "Framework clonato con successo."
fi

# -------------------------------------------------------------
# 3. Lancio del bootstrap interattivo
# -------------------------------------------------------------
echo ""
info "Avvio del processo di configurazione guidata (bootstrap)..."
echo ""

cd "$TARGET_DIR"
exec bash "$TARGET_DIR/setup/bootstrap.sh" "$@"
