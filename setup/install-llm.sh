#!/usr/bin/env bash
# =============================================================
# install-llm.sh — Install and configure AI assistant(s) for POS
#
# Supports:
#   - Claude Code (Anthropic)
#   - Antigravity CLI (Google DeepMind)
#   - Codex / ChatGPT CLI (OpenAI)
#
# Idempotent: safe to run multiple times. All paths are dynamic.
# =============================================================
set -euo pipefail

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SETUP_DIR="$WORKSPACE_DIR/setup"

# Dynamic user home resolution
USER_HOME=$(getent passwd "$(id -un)" 2>/dev/null | cut -d: -f6 || echo "$HOME")
[ -z "$USER_HOME" ] && USER_HOME="$HOME"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ok()   { echo -e "  [${GREEN}ok${NC}] $*"; }
info() { echo -e "  [${BLUE}..${NC}] $*"; }
warn() { echo -e "  [${YELLOW}warn${NC}] $*"; }
err()  { echo -e "  [${RED}err${NC}] $*"; }
skip() { echo -e "  [skip] $*"; }
die()  { err "$*"; exit 1; }

# Must NOT run as root
if [ "$(id -u)" -eq 0 ]; then
    die "Non eseguire questo script come root. Eseguilo come utente normale."
fi

echo ""
echo "============================================================"
echo "  POS — LLM ASSISTANT SETUP"
echo "============================================================"
echo "  Workspace: $WORKSPACE_DIR"
echo "  User:      $(id -un) ($USER_HOME)"
echo "============================================================"
echo ""

# -------------------------------------------------------------
# 1. Resolve Personal Instance
# -------------------------------------------------------------
CONFIG_FILE="$WORKSPACE_DIR/.pos-config"
if [ ! -f "$CONFIG_FILE" ]; then
    warn "File .pos-config non trovato. Esegui prima bash setup/bootstrap.sh"
    exit 1
fi

INSTANCE_REL=$(grep -E '^instance_dir=' "$CONFIG_FILE" | head -1 | cut -d= -f2 || true)
if [ -z "$INSTANCE_REL" ] || [ ! -d "$WORKSPACE_DIR/$INSTANCE_REL" ]; then
    warn "Istanza personale non trovata ($INSTANCE_REL). Esegui prima bash setup/bootstrap.sh"
    exit 1
fi
PERSONAL_DIR="$WORKSPACE_DIR/$INSTANCE_REL"
ok "Istanza personale individuata: $INSTANCE_REL"

# -------------------------------------------------------------
# 2. Select Assistant(s)
# -------------------------------------------------------------
NON_INTERACTIVE=false
for arg in "$@"; do
    case "$arg" in
        --yes|-y) NON_INTERACTIVE=true ;;
    esac
done

if [ "$NON_INTERACTIVE" = true ]; then
    LLM_CHOICE="1 2"
else
    echo ""
    echo "  Quale assistente AI vuoi installare/configurare? (puoi inserire più numeri separati da spazio)"
    echo "  [1] Claude Code"
    echo "  [2] Antigravity CLI (Gemini)"
    echo "  [3] Codex CLI (OpenAI)"
    echo "  [4] Tutti"
    read -rp "  Scelta [1 2]: " LLM_CHOICE
    LLM_CHOICE="${LLM_CHOICE:-1 2}"
    [[ "$LLM_CHOICE" == "4" ]] && LLM_CHOICE="1 2 3"
fi

want() { [[ " $LLM_CHOICE " == *" $1 "* ]]; }

# Ensure ~/.local/bin in PATH
mkdir -p "$USER_HOME/.local/bin"
if [[ ":$PATH:" != *":$USER_HOME/.local/bin:"* ]]; then
    export PATH="$USER_HOME/.local/bin:$PATH"
fi

# -------------------------------------------------------------
# 3. Installation
# -------------------------------------------------------------

# Claude Code
if want 1; then
    echo ""
    info "Configurazione Claude Code..."
    if command -v claude &>/dev/null; then
        ok "Claude Code già installato ($(claude --version 2>/dev/null || echo 'versione rilevata'))"
    else
        info "Installazione Claude Code tramite script ufficiale Anthropic..."
        if curl -fsSL https://claude.ai/install.sh | bash; then
            ok "Claude Code installato con successo"
        else
            warn "Installazione automatica Claude Code non riuscita. Installa manualmente con:"
            warn "  curl -fsSL https://claude.ai/install.sh | bash"
        fi
    fi
fi

# Antigravity CLI
if want 2; then
    echo ""
    info "Configurazione Antigravity CLI..."
    if command -v agy &>/dev/null || command -v antigravity &>/dev/null; then
        ok "Antigravity CLI già installato"
    else
        info "Installazione Antigravity CLI..."
        if curl -fsSL https://antigravity.google/cli/install.sh | bash; then
            ok "Antigravity CLI installato con successo"
        else
            warn "Installazione automatica Antigravity non riuscita. Installa manualmente con:"
            warn "  curl -fsSL https://antigravity.google/cli/install.sh | bash"
        fi
    fi

    # Configure local MCP server for Antigravity
    MCP_CONFIG_DIR="$USER_HOME/.gemini/config"
    mkdir -p "$MCP_CONFIG_DIR"
    python3 - << PYEOF
import json
import os

config_path = os.path.expanduser("$MCP_CONFIG_DIR/mcp_config.json")
data = {}
if os.path.exists(config_path) and os.path.getsize(config_path) > 0:
    try:
        with open(config_path, "r", encoding="utf-8") as f:
            data = json.load(f)
    except Exception:
        data = {}

servers = data.setdefault("mcpServers", {})
servers["zvec_grep"] = {
    "serverUrl": "http://127.0.0.1:7999/mcp"
}

with open(config_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)
PYEOF
    ok "Endpoint MCP zvec_grep configurato in $MCP_CONFIG_DIR/mcp_config.json"
fi

# Codex CLI
if want 3; then
    echo ""
    info "Configurazione Codex CLI..."
    if command -v codex &>/dev/null; then
        ok "Codex CLI già installato"
    elif command -v npm &>/dev/null; then
        npm install -g @openai/codex
        ok "Codex CLI installato tramite npm"
    else
        warn "npm non trovato: impossibile installare @openai/codex automaticamente."
    fi
fi

# -------------------------------------------------------------
# 4. Generate & Link Instance Configurations
# -------------------------------------------------------------
echo ""
info "Generazione e verifica file di configurazione istanza..."

if [ ! -f "$PERSONAL_DIR/CLAUDE.md" ]; then
    USER_NAME="$(git config --get user.name || id -un)"
    sed -e "s/{{NAME}}/$USER_NAME/g" -e "s/{{LANGUAGE}}/Italiano/g" \
        "$SETUP_DIR/templates/CLAUDE.template.md" > "$PERSONAL_DIR/CLAUDE.md"
    ok "Creato $PERSONAL_DIR/CLAUDE.md"
fi

# Symlinks inside personal instance
(cd "$PERSONAL_DIR" && ln -sf CLAUDE.md AGENTS.md && ln -sf CLAUDE.md GEMINI.md)
ok "Symlinks AGENTS.md e GEMINI.md aggiornati in $PERSONAL_DIR"

echo ""
echo "============================================================"
echo -e "  ${GREEN}LLM SETUP COMPLETATO${NC}"
echo "============================================================"
echo "  Per iniziare ad usare il tuo assistente:"
echo "  - Claude Code:      cd $WORKSPACE_DIR && claude"
echo "  - Antigravity CLI:  cd $WORKSPACE_DIR && agy"
echo "============================================================"
echo ""
