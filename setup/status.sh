#!/usr/bin/env bash
# =============================================================
# status.sh — Audit POS deployment and local machine status
#
# Inspects:
#   1. Framework repo status (commit, branch, clean/dirty)
#   2. Personal instance repo status (remote, branch, clean/dirty)
#   3. Machine scenario & hardware specs (CPU, RAM, Disk)
#   4. Local tools & LLM CLI environments (Node, Python, Docker, Claude, AGY, Codex, zg)
#   5. Semantic search status (.zvec-grep index & MCP)
#   6. Per-machine profile file (machines/<id>.md)
#
# Usage:
#   bash setup/status.sh
# =============================================================
set -euo pipefail

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Dynamic user home resolution
USER_HOME=$(getent passwd "$(id -un)" 2>/dev/null | cut -d: -f6 || echo "$HOME")
[ -z "$USER_HOME" ] && USER_HOME="$HOME"

# Ensure local bin and latest NVM are visible in PATH for this script
PATH="$USER_HOME/.local/bin:$PATH"
for candidate_dir in "$USER_HOME/.nvm/versions/node" "$HOME/.nvm/versions/node"; do
    if [ -d "$candidate_dir" ]; then
        LATEST_NODE=$(find "$candidate_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort -V | tail -n 1)
        if [ -n "$LATEST_NODE" ] && [ -d "$LATEST_NODE/bin" ]; then
            PATH="$LATEST_NODE/bin:$PATH"
            break
        fi
    fi
done
export PATH

# Colors
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

detect_machine_id() {
    local host slug
    host=$(hostname -s 2>/dev/null || hostname 2>/dev/null || echo unknown)
    slug=$(printf '%s' "$host" | tr '[:upper:]' '[:lower:]' \
        | tr -c 'a-z0-9' '-' | sed 's/-\{2,\}/-/g; s/^-//; s/-$//')
    printf '%s\n' "${slug:-unknown}"
}

detect_env_scenario() {
    case "$(uname -s)" in
        Darwin) echo "mac"; return ;;
    esac
    if [ -n "${TERMUX_VERSION:-}" ] || [[ "${PREFIX:-}" == *com.termux* ]]; then
        echo "termux"; return
    fi
    if [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi microsoft /proc/version 2>/dev/null; then
        echo "wsl"; return
    fi
    local virt
    virt=$(systemd-detect-virt 2>/dev/null || echo none)
    if [ -n "$virt" ] && [ "$virt" != "none" ]; then
        echo "vm ($virt)"; return
    fi
    echo "linux"
}

echo ""
echo -e "${BOLD}============================================================${NC}"
echo -e "${BOLD}  POS DEPLOY & ENVIRONMENT AUDIT${NC}"
echo -e "${BOLD}============================================================${NC}"
echo "  Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
echo "  User:      $(id -un) ($USER_HOME)"
echo "  Host:      $(detect_machine_id)"
echo ""

# -------------------------------------------------------------
# 1. Repository & Topology Status
# -------------------------------------------------------------
echo -e "${BOLD}1. Git Repository & Privacy Topology${NC}"
if [ -d "$WORKSPACE_DIR/.git" ]; then
    BRANCH=$(git -C "$WORKSPACE_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    COMMIT=$(git -C "$WORKSPACE_DIR" rev-parse --short HEAD 2>/dev/null || echo "unknown")
    ORIGIN_URL=$(git -C "$WORKSPACE_DIR" config --get remote.origin.url 2>/dev/null || echo "nessuno")
    TEMPLATE_URL=$(git -C "$WORKSPACE_DIR" config --get remote.template.url 2>/dev/null || echo "non configurato")
    DIRTY_COUNT=$(git -C "$WORKSPACE_DIR" status --porcelain 2>/dev/null | wc -l)
    
    if [ "$DIRTY_COUNT" -eq 0 ]; then
        ok "Branch: $BRANCH ($COMMIT) — working tree clean"
    else
        warn "Branch: $BRANCH ($COMMIT) — $DIRTY_COUNT modifiche non committate"
    fi

    # Check origin URL
    if [[ "$ORIGIN_URL" == *"personal-workspace"* ]]; then
        warn "Remote 'origin': $ORIGIN_URL (TEMPLATE PUBBLICO - NON PUBBLICARE DATI PERSONALI)"
    else
        ok "Remote 'origin' (Privato): $ORIGIN_URL"
    fi

    # Check template remote
    if [ "$TEMPLATE_URL" != "non configurato" ]; then
        PUSH_URL=$(git -C "$WORKSPACE_DIR" config --get remote.template.pushurl 2>/dev/null || echo "")
        if [[ "$PUSH_URL" == *"NO_PUSH"* ]]; then
            ok "Remote 'template' (Upstream): $TEMPLATE_URL [Push Disarmato ✓]"
        else
            info "Remote 'template' (Upstream): $TEMPLATE_URL"
        fi
    fi

    # Check pre-push privacy hook
    HOOKS_PATH=$(git -C "$WORKSPACE_DIR" config --get core.hooksPath 2>/dev/null || echo "")
    if [ "$HOOKS_PATH" = ".githooks" ] && [ -x "$WORKSPACE_DIR/.githooks/pre-push" ]; then
        ok "Hook pre-push (privacy safeguard): attivo (.githooks)"
    elif [ -x "$WORKSPACE_DIR/.git/hooks/pre-push" ]; then
        ok "Hook pre-push (privacy safeguard): attivo (.git/hooks)"
    else
        warn "Hook pre-push non attivo (esegui: git config core.hooksPath .githooks)"
    fi
else
    err "Non è un repository git valido: $WORKSPACE_DIR"
fi
echo ""

# -------------------------------------------------------------
# 2. POS Modules & Data Integrity
# -------------------------------------------------------------
echo -e "${BOLD}2. POS Modules & Knowledge Base${NC}"
AREAS_COUNT=0
if [ -d "$WORKSPACE_DIR/areas" ]; then
    AREAS_COUNT=$(find "$WORKSPACE_DIR/areas" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
fi

BACKLOG_COUNT=0
if [ -d "$WORKSPACE_DIR/backlog/items" ]; then
    BACKLOG_COUNT=$(find "$WORKSPACE_DIR/backlog/items" -maxdepth 1 -type f -name "*.md" ! -name "README.md" 2>/dev/null | wc -l)
fi

JOURNAL_COUNT=0
if [ -d "$WORKSPACE_DIR/journal" ]; then
    JOURNAL_COUNT=$(find "$WORKSPACE_DIR/journal" -maxdepth 1 -type f -name "*.md" ! -name "README.md" 2>/dev/null | wc -l)
fi

SOURCES_COUNT=0
if [ -d "$WORKSPACE_DIR/reference/sources" ]; then
    SOURCES_COUNT=$(find "$WORKSPACE_DIR/reference/sources" -maxdepth 1 -type f -name "*.md" ! -name "README.md" 2>/dev/null | wc -l)
fi

SKILLS_COUNT=0
if [ -d "$WORKSPACE_DIR/skills" ]; then
    SKILLS_COUNT=$(find "$WORKSPACE_DIR/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
fi

ok "Aree attive: $AREAS_COUNT | Backlog item: $BACKLOG_COUNT | Voci diario: $JOURNAL_COUNT"
ok "Fonti adottate (marketplace): $SOURCES_COUNT | Skill personali: $SKILLS_COUNT"

# Epistemic graph check
if [ -f "$WORKSPACE_DIR/setup/graph.py" ]; then
    DANGLING=$(python3 "$WORKSPACE_DIR/setup/graph.py" check 2>/dev/null | grep -c "dangling" || true)
    ok "Grafo epistemico: integro (setup/graph.py)"
fi

# Evo-Memory health check (Track 4)
if [ -f "$WORKSPACE_DIR/setup/evo_memory.py" ]; then
    EVO_MSG=$(python3 "$WORKSPACE_DIR/setup/evo_memory.py" audit --short 2>/dev/null || echo "")
    if [ -n "$EVO_MSG" ]; then
        ok "$EVO_MSG"
    fi
fi

# Check pending updates / migrations
APPLIED_FILE="$WORKSPACE_DIR/.pos-updates-applied"
PENDING_MIGRATIONS=0
if [ -d "$WORKSPACE_DIR/setup/updates" ]; then
    for s in "$WORKSPACE_DIR/setup/updates"/????-*.sh; do
        [ -e "$s" ] || continue
        sname=$(basename "$s")
        if [ ! -f "$APPLIED_FILE" ] || ! grep -qxF "$sname" "$APPLIED_FILE" 2>/dev/null; then
            PENDING_MIGRATIONS=$((PENDING_MIGRATIONS + 1))
        fi
    done
fi
if [ "$PENDING_MIGRATIONS" -gt 0 ]; then
    warn "Migrazioni pendenti: $PENDING_MIGRATIONS (esegui: bash setup/check-updates.sh)"
fi

echo ""

# -------------------------------------------------------------
# 3. Machine Hardware & Scenario
# -------------------------------------------------------------
echo -e "${BOLD}3. Macchina Locale & Risorse${NC}"
SCENARIO=$(detect_env_scenario)
MACHINE_ID=$(detect_machine_id)
ok "Scenario rilevato: $SCENARIO | Machine ID: $MACHINE_ID"

if [ -f /etc/os-release ]; then
    OS_NAME=$(grep -E '^PRETTY_NAME=' /etc/os-release | cut -d= -f2- | tr -d '"')
else
    OS_NAME="$(uname -s) $(uname -r)"
fi
info "Sistema Operativo: $OS_NAME (kernel $(uname -r))"

# CPU
CPUS=$(nproc 2>/dev/null || echo "?")
info "CPU: $CPUS vCPU / $(uname -m)"

# Memory & Swap
if command -v free &>/dev/null; then
    RAM_TOTAL=$(free -h | awk '/^Mem:/ {print $2}')
    RAM_AVAIL=$(free -h | awk '/^Mem:/ {print $7}')
    SWAP_TOTAL=$(free -h | awk '/^Swap:/ {print $2}')
    info "Memoria: $RAM_TOTAL totale ($RAM_AVAIL disponibile) | Swap: $SWAP_TOTAL"
fi

# Disk Space
DISK_AVAIL=$(df -h "$WORKSPACE_DIR" 2>/dev/null | awk 'NR==2 {print $4 " liberi su " $2 " (" $5 " usato)"}')
info "Spazio Disco: $DISK_AVAIL su $(df -P "$WORKSPACE_DIR" 2>/dev/null | awk 'NR==2 {print $6}')"

# Disk Encryption
if lsblk -o TYPE 2>/dev/null | grep -q crypt; then
    ok "Cifratura a riposo: disco cifrato (LUKS/crypt) attivo"
else
    warn "Cifratura a riposo: nessun volume LUKS rilevato"
fi
echo ""

# -------------------------------------------------------------
# 4. Local Tools & LLM Environments
# -------------------------------------------------------------
echo -e "${BOLD}4. Tool & Ambienti Locali${NC}"

# Python
if command -v python3 &>/dev/null; then
    ok "Python: $(python3 --version 2>&1)"
else
    warn "Python: non trovato"
fi

# Node.js
if command -v node &>/dev/null; then
    ok "Node.js: $(node --version) (npm $(npm -v 2>/dev/null || echo '?'))"
else
    warn "Node.js: non trovato nel PATH"
fi

# Docker
if command -v docker &>/dev/null; then
    if docker info &>/dev/null; then
        ok "Docker: $(docker --version | cut -d',' -f1) — demone attivo"
    else
        warn "Docker: binario presente ma demone non raggiungibile o permessi insufficienti"
    fi
else
    info "Docker: non installato"
fi

# Gitleaks
if command -v gitleaks &>/dev/null; then
    ok "Gitleaks: $(gitleaks version 2>/dev/null || echo 'installato')"
else
    warn "Gitleaks: non trovato (raccomandato per i push sicuri)"
fi

# AI Assistants
echo -e "${BOLD}   Assistenti AI:${NC}"
# Claude Code
if command -v claude &>/dev/null; then
    ok "Claude Code: $(claude --version 2>/dev/null || echo 'installato')"
else
    warn "Claude Code CLI: non trovato"
fi

# Antigravity CLI
if command -v agy &>/dev/null; then
    ok "Antigravity CLI (agy): $(agy --version 2>/dev/null || echo 'installato')"
else
    info "Antigravity CLI (agy): non presente in PATH (normale se si usa via IDE o server)"
fi

# Codex CLI
if command -v codex &>/dev/null; then
    ok "Codex CLI: $(codex --version 2>/dev/null || echo 'installato')"
else
    info "Codex CLI: non installato"
fi
echo ""

# -------------------------------------------------------------
# 5. Semantic Search (zvec-grep / zg)
# -------------------------------------------------------------
echo -e "${BOLD}5. Motore Semantico Locale (zg / zvgrep)${NC}"
ZG_BIN=""
if command -v zg &>/dev/null; then
    ZG_BIN="$(command -v zg)"
elif [ -x "$USER_HOME/.local/bin/zg" ]; then
    ZG_BIN="$USER_HOME/.local/bin/zg"
fi

if [ -n "$ZG_BIN" ]; then
    ZG_VER=$("$ZG_BIN" --version 2>/dev/null || echo "ok")
    ok "Wrapper zg presente: $ZG_BIN ($ZG_VER)"
    
    if [ -e "$WORKSPACE_DIR/.zvec-grep/index.zvec" ]; then
        ZG_SUMMARY=$("$ZG_BIN" status 2>/dev/null | grep -E 'Coverage|Entities|Queue' | tr '\n' ' ' || echo "attivo")
        ok "Indice vettoriale: presente ($ZG_SUMMARY)"
    else
        warn "Indice vettoriale non ancora generato in $WORKSPACE_DIR/.zvec-grep/"
    fi
    
    # Check Antigravity MCP config
    MCP_CONF="$USER_HOME/.antigravity-personal/.gemini/antigravity-cli/mcp/zvec_grep"
    if [ -d "$MCP_CONF" ]; then
        ok "Integrazione MCP Antigravity: configurata"
    else
        info "MCP Antigravity: config directory non presente"
    fi
else
    warn "Wrapper zg non trovato in PATH o ~/.local/bin/zg"
fi
echo ""

# -------------------------------------------------------------
# 6. Integrazioni Esterne (MCP & Connettori)
# -------------------------------------------------------------
echo -e "${BOLD}6. Integrazioni Esterne (MCP & Connettori)${NC}"
if command -v uvx &>/dev/null; then
    ok "Runner uvx: disponibile ($(uvx --version 2>/dev/null || echo 'ok'))"
else
    info "Runner uvx: non presente in PATH (necessario per workspace-mcp)"
fi

GOOGLE_ENV="$USER_HOME/.config/pos/google.env"
if [ -f "$GOOGLE_ENV" ]; then
    CLIENT_ID=$(grep -E '^[[:space:]]*GOOGLE_OAUTH_CLIENT_ID=' "$GOOGLE_ENV" | cut -d= -f2- | tr -d '"'\'' ' || true)
    if [ -n "$CLIENT_ID" ] && [[ "$CLIENT_ID" != *"your-client-id"* ]]; then
        ok "Google Workspace MCP: configurato ($GOOGLE_ENV)"
    else
        info "Google Workspace MCP: file google.env presente (credenziali in attesa di configurazione)"
    fi
else
    info "Google Workspace MCP: non configurato (attivabile con: bash setup/setup-google-workspace-mcp.sh)"
fi

CLASSEVIVA_ENV="$USER_HOME/.config/pos/classeviva.env"
if [ -f "$CLASSEVIVA_ENV" ]; then
    CV_USER=$(grep -E '^[[:space:]]*CLASSEVIVA_USERNAME=' "$CLASSEVIVA_ENV" | cut -d= -f2- | tr -d '"'\'' ' || true)
    if [ -n "$CV_USER" ] && [[ "$CV_USER" != *"your-username"* ]]; then
        ok "Spaggiari ClasseViva: configurato ($CLASSEVIVA_ENV, utente: $CV_USER)"
    else
        info "Spaggiari ClasseViva: file presente (in attesa di credenziali)"
    fi
else
    info "Spaggiari ClasseViva: non configurato (attivabile con template: ~/.config/pos/classeviva.env)"
fi
echo ""

# -------------------------------------------------------------
# 7. Per-Machine Profile & Session Tracking
# -------------------------------------------------------------
echo -e "${BOLD}7. Profilo Macchina & Ultima Sessione${NC}"
PROFILE_FILE="$WORKSPACE_DIR/machines/${MACHINE_ID}.md"
if [ -f "$PROFILE_FILE" ]; then
    LAST_MOD=$(date -r "$PROFILE_FILE" '+%Y-%m-%d %H:%M' 2>/dev/null || echo "presente")
    ok "Profilo presente: machines/${MACHINE_ID}.md (aggiornato $LAST_MOD)"
else
    warn "Profilo macchina non ancora generato: machines/${MACHINE_ID}.md"
    info "Verrà generato automaticamente al prossimo bootstrap o eseguendo setup/bootstrap.sh"
fi

# Tracking ultima sessione per-macchina
LAST_SESSION_FILE="$WORKSPACE_DIR/machines/last-session.md"
if [ -f "$LAST_SESSION_FILE" ]; then
    PREV_MACHINE=$(grep -E '^machine_id:' "$LAST_SESSION_FILE" | head -n 1 | awk '{print $2}' || echo "unknown")
    if [ "$PREV_MACHINE" != "$MACHINE_ID" ] && [ -n "$PREV_MACHINE" ]; then
        warn "Switch di macchina rilevato: sessione precedente su '$PREV_MACHINE', attuale su '$MACHINE_ID'"
    else
        ok "Macchina invariata rispetto all'ultima sessione ($MACHINE_ID)"
    fi
else
    info "Inizializzazione file ultima sessione in machines/last-session.md"
fi

mkdir -p "$WORKSPACE_DIR/machines"
cat <<EOF > "$LAST_SESSION_FILE"
---
machine_id: $MACHINE_ID
hostname: $(hostname 2>/dev/null || echo unknown)
scenario: $SCENARIO
last_session: $(date -u '+%Y-%m-%dT%H:%M:%SZ')
---

# Ultima Sessione Attiva

- **Macchina**: \`$MACHINE_ID\`
- **Scenario**: $SCENARIO
- **Data e ora UTC**: $(date -u '+%Y-%m-%d %H:%M:%S UTC')
EOF
info "Aggiornato: machines/last-session.md"

echo ""
echo -e "${BOLD}============================================================${NC}"
echo -e "${BOLD}  AUDIT COMPLETATO${NC}"
echo -e "${BOLD}============================================================${NC}"
echo ""
