#!/usr/bin/env bash
# =============================================================
# setup-google-workspace-mcp.sh — Setup Google Workspace MCP
#
# Configures the open-source Google Workspace MCP server
# (workspace-mcp) for Claude Code, Antigravity CLI, and Cursor.
#
# Idempotent: safe to run multiple times. All paths are dynamic.
# =============================================================
set -euo pipefail

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SETUP_DIR="$WORKSPACE_DIR/setup"

USER_HOME=$(getent passwd "$(id -un)" 2>/dev/null | cut -d: -f6 || echo "$HOME")
[ -z "$USER_HOME" ] && USER_HOME="$HOME"

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

echo ""
echo -e "${BOLD}============================================================${NC}"
echo -e "${BOLD}  POS — GOOGLE WORKSPACE MCP SETUP${NC}"
echo -e "${BOLD}============================================================${NC}"
echo "  User: $USER_HOME"
echo ""

# -------------------------------------------------------------
# 1. Check / Install uv & uvx
# -------------------------------------------------------------
PATH="$USER_HOME/.local/bin:$PATH"
export PATH

if command -v uvx &>/dev/null; then
    ok "uvx trovato: $(uvx --version 2>/dev/null || echo 'installato')"
else
    info "uvx non trovato in PATH. Installazione di uv via installer ufficiale..."
    if curl -LsSf https://astral.sh/uv/install.sh | env CARGO_HOME="$USER_HOME/.local" UV_INSTALL_DIR="$USER_HOME/.local/bin" sh; then
        ok "uvx installato con successo in $USER_HOME/.local/bin"
    else
        err "Installazione automatica di uv fallita. Installa manualmente con: curl -LsSf https://astral.sh/uv/install.sh | sh"
        exit 1
    fi
fi

# -------------------------------------------------------------
# 2. Check / Prepare ~/.config/pos/google.env
# -------------------------------------------------------------
ENV_DIR="$USER_HOME/.config/pos"
ENV_FILE="$ENV_DIR/google.env"
mkdir -p "$ENV_DIR"
chmod 700 "$ENV_DIR"

if [ ! -f "$ENV_FILE" ]; then
    info "Creazione file di configurazione credenziali $ENV_FILE da template..."
    cp "$SETUP_DIR/templates/google.env.template" "$ENV_FILE"
    chmod 600 "$ENV_FILE"
    warn "File $ENV_FILE creato. Modificalo con il tuo Client ID e Client Secret di Google Cloud."
fi

# Load variables if set
CLIENT_ID=$(grep -E '^[[:space:]]*GOOGLE_OAUTH_CLIENT_ID=' "$ENV_FILE" | cut -d= -f2- | tr -d '"'\'' ' || true)
CLIENT_SECRET=$(grep -E '^[[:space:]]*GOOGLE_OAUTH_CLIENT_SECRET=' "$ENV_FILE" | cut -d= -f2- | tr -d '"'\'' ' || true)
USER_EMAIL=$(grep -E '^[[:space:]]*USER_GOOGLE_EMAIL=' "$ENV_FILE" | cut -d= -f2- | tr -d '"'\'' ' || true)
SINGLE_USER=$(grep -E '^[[:space:]]*MCP_SINGLE_USER_MODE=' "$ENV_FILE" | cut -d= -f2- | tr -d '"'\'' ' || true)
TOOLS=$(grep -E '^[[:space:]]*WORKSPACE_MCP_TOOLS=' "$ENV_FILE" | cut -d= -f2- | tr -d '"'\'' ' || echo "gmail,calendar,drive")
READ_ONLY=$(grep -E '^[[:space:]]*WORKSPACE_MCP_READ_ONLY=' "$ENV_FILE" | cut -d= -f2- | tr -d '"'\'' ' || echo "false")

[ -z "$TOOLS" ] && TOOLS="gmail,calendar,drive"

# Convert comma-separated tools to bash array/args
IFS=',' read -ra TOOL_LIST <<< "$TOOLS"
TOOL_ARGS=()
for t in "${TOOL_LIST[@]}"; do
    [ -n "$t" ] && TOOL_ARGS+=("$t")
done

if [ -z "$CLIENT_ID" ] || [[ "$CLIENT_ID" == *"your-client-id"* ]] || [ -z "$CLIENT_SECRET" ] || [[ "$CLIENT_SECRET" == *"your-client-secret"* ]]; then
    warn "Credenziali Google OAuth non ancora configurate in $ENV_FILE."
    echo ""
    info "Per ottenere le credenziali:"
    info "1. Accedi a https://console.cloud.google.com/"
    info "2. Abilita le API: Google Calendar, Gmail, Google Drive"
    info "3. Configura la Schermata di consenso OAuth (Utenti di test: inserisci la tua email)"
    info "4. Crea credenziali OAuth Client ID (Tipo: Applicazione desktop)"
    info "5. Inserisci Client ID e Secret in: nano $ENV_FILE"
    echo ""
    info "La configurazione dei client AI verrà completata non appena le credenziali saranno presenti."
    exit 0
fi

ok "Credenziali OAuth rilevate in $ENV_FILE (Client ID: ${CLIENT_ID:0:15}...)"

# -------------------------------------------------------------
# 3. Configure AI Clients (Claude Code, Antigravity)
# -------------------------------------------------------------
echo ""
info "Aggiornamento configurazioni client MCP..."

python3 - << PYEOF
import json, os

client_id = "$CLIENT_ID"
client_secret = "$CLIENT_SECRET"
user_email = "$USER_EMAIL"
single_user = "$SINGLE_USER"
tools = "$TOOLS".split(",")
tools = [t.strip() for t in tools if t.strip()]
read_only = "$READ_ONLY".lower() == "true"

args = ["workspace-mcp"]
if tools:
    args.extend(["--tools"] + tools)
if read_only:
    args.append("--read-only")

env = {
    "GOOGLE_OAUTH_CLIENT_ID": client_id,
    "GOOGLE_OAUTH_CLIENT_SECRET": client_secret
}
if user_email:
    env["USER_GOOGLE_EMAIL"] = user_email
if single_user.lower() in ("true", "1", "yes") or (user_email and single_user == ""):
    env["MCP_SINGLE_USER_MODE"] = "true"

server_def = {
    "command": "uvx",
    "args": args,
    "env": env
}

# 1. Claude Code (~/.claude.json)
claude_path = os.path.expanduser("$USER_HOME/.claude.json")
if os.path.exists(claude_path):
    try:
        with open(claude_path, "r", encoding="utf-8") as f:
            cdata = json.load(f)
        cservers = cdata.setdefault("mcpServers", {})
        cservers["google-workspace"] = server_def
        with open(claude_path, "w", encoding="utf-8") as f:
            json.dump(cdata, f, indent=2)
        print("  [\033[0;32m✓\033[0m] Server google-workspace configurato in ~/.claude.json")
    except Exception as e:
        print(f"  [\033[1;33m!\033[0m] Errore aggiornamento ~/.claude.json: {e}")

# 2. Antigravity / Gemini (~/.gemini/config/mcp_config.json)
gemini_paths = set()
for h in ["$USER_HOME", "$HOME"]:
    if h and os.path.exists(h):
        gemini_paths.add(os.path.join(os.path.expanduser(h), ".gemini", "config", "mcp_config.json"))

for gemini_path in gemini_paths:
    os.makedirs(os.path.dirname(gemini_path), exist_ok=True)
    gdata = {}
    if os.path.exists(gemini_path) and os.path.getsize(gemini_path) > 0:
        try:
            with open(gemini_path, "r", encoding="utf-8") as f:
                gdata = json.load(f)
        except Exception:
            gdata = {}

    gservers = gdata.setdefault("mcpServers", {})
    # Rimuovi eventuale vecchio test workspace-universal se presente
    gservers.pop("workspace-universal", None)
    gservers["google-workspace"] = server_def
    with open(gemini_path, "w", encoding="utf-8") as f:
        json.dump(gdata, f, indent=2)
    print(f"  [\033[0;32m✓\033[0m] Server google-workspace configurato in {gemini_path}")
PYEOF

echo ""
ok "Configurazione completata con successo."
info "Al primo utilizzo da parte di Claude o Antigravity, si aprirà il browser per completare il login OAuth Google."
echo ""
