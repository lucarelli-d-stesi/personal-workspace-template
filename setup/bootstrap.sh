#!/usr/bin/env bash
# =============================================================
# bootstrap.sh — Setup personal-workspace and personal instance
#
# Idempotent: safe to re-run. Configures the framework operating base,
# deploys or mounts your private personal repo, sets up local semantic
# search (zg/zvgrep), and links individual domain skills.
#
# IMPORTANT:
#   Do NOT run with sudo (bash setup/bootstrap.sh, NOT sudo bash ...).
#   If administrative privileges are needed for a specific action,
#   sudo will prompt for a password on-demand.
#
# Usage:
#   bash ~/personal-workspace/setup/bootstrap.sh
#   bash ~/personal-workspace/setup/bootstrap.sh --yes
# =============================================================
set -euo pipefail

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SETUP_DIR="$WORKSPACE_DIR/setup"

# Dynamic user home resolution (handles sudo/subshell environments reliably)
USER_HOME=$(getent passwd "$(id -un)" 2>/dev/null | cut -d: -f6 || echo "$HOME")
[ -z "$USER_HOME" ] && USER_HOME="$HOME"

# -------------------------------------------------------------
# Color output helpers
# -------------------------------------------------------------
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

confirm_step() {
    local prompt="$1" default="${2:-S}" var_name="${3:-}"
    if [ "$NON_INTERACTIVE" = true ]; then
        return 0
    fi
    local answer
    read -rp "  $prompt [${default}]: " answer
    answer="${answer:-$default}"
    case "$answer" in
        [sSyY]*) return 0 ;;
        *) return 1 ;;
    esac
}

# Run a privileged command with sudo on-demand, never requiring root execution of the script
run_privileged() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    elif command -v sudo &>/dev/null; then
        info "Richiesti privilegi di amministratore per: $*"
        sudo "$@"
    else
        die "Privilegi di root richiesti per: $*, ma sudo non è disponibile."
    fi
}

NON_INTERACTIVE=false
for arg in "$@"; do
    case "$arg" in
        --yes|-y) NON_INTERACTIVE=true ;;
    esac
done

echo ""
echo "============================================================"
echo "  PERSONAL WORKSPACE (POS) BOOTSTRAP"
echo "============================================================"
echo "  Framework: $WORKSPACE_DIR"
echo "  User:      $(id -un) ($USER_HOME)"
echo "============================================================"
echo ""

# -------------------------------------------------------------
# 0. Must NOT run as root
# -------------------------------------------------------------
info "Verifica privilegi utente..."
if [ "$(id -u)" -eq 0 ]; then
    die "Non eseguire questo script con sudo (\$HOME=$HOME). Lancialo come utente normale: bash setup/bootstrap.sh. Sudo verrà richiesto solo se necessario."
fi
ok "Esecuzione con utente non-root ($(id -un))"

# -------------------------------------------------------------
# 1. OS & Shell Detection
# -------------------------------------------------------------
info "Rilevamento OS e shell..."
OS="$(uname -s)"
case "$OS" in
    Linux)
        if grep -qi microsoft /proc/version 2>/dev/null; then
            OS_FAMILY="wsl"
        else
            OS_FAMILY="linux"
        fi
        ;;
    Darwin)
        OS_FAMILY="macos"
        ;;
    *)
        OS_FAMILY="other"
        ;;
esac

RC_FILE="$USER_HOME/.bashrc"
[ -n "${ZSH_VERSION:-}" ] && RC_FILE="$USER_HOME/.zshrc"
[ "$OS_FAMILY" = "macos" ] && [ -f "$USER_HOME/.zshrc" ] && RC_FILE="$USER_HOME/.zshrc"
ok "Ambiente rilevato: $OS_FAMILY (shell rc: $RC_FILE)"

# -------------------------------------------------------------
# 2. Disk Encryption Check (Privacy at Rest)
# -------------------------------------------------------------
info "Verifica diagnostica cifratura disco a riposo..."
case "$OS_FAMILY" in
    linux)
        if lsblk -o TYPE 2>/dev/null | grep -q crypt; then
            ok "Disco cifrato rilevato (LUKS/crypt)"
        else
            warn "Nessun volume cifrato (LUKS) rilevato. Si raccomanda la cifratura del disco per la privacy dei dati personali."
        fi
        ;;
    macos)
        if command -v fdesetup &>/dev/null && fdesetup status 2>/dev/null | grep -qi "FileVault is On"; then
            ok "FileVault attivo"
        else
            warn "FileVault non risulta attivo: abilitalo da Impostazioni di Sistema → Privacy e Sicurezza."
        fi
        ;;
    wsl)
        warn "WSL2: la cifratura a riposo dipende dall'host Windows (BitLocker sul volume host)."
        ;;
    *)
        info "Verifica cifratura saltata su questo OS."
        ;;
esac

# -------------------------------------------------------------
# 3. Required Tools Check
# -------------------------------------------------------------
info "Verifica prerequisiti di sistema..."
command -v git &>/dev/null || die "Git non trovato. Installa git e riprova."
command -v curl &>/dev/null || die "curl non trovato. Installa curl e riprova."
command -v python3 &>/dev/null || die "python3 non trovato. Installa python3 e riprova."
ok "Strumenti base disponibili (git, curl, python3)"

# Ensure ~/.local/bin in PATH
mkdir -p "$USER_HOME/.local/bin"
if [[ ":$PATH:" != *":$USER_HOME/.local/bin:"* ]]; then
    export PATH="$USER_HOME/.local/bin:$PATH"
fi

# -------------------------------------------------------------
# 4. Deploy or Connect Personal Instance Repo
# -------------------------------------------------------------
echo ""
info "Configurazione repository personale privato..."

CONFIG_FILE="$WORKSPACE_DIR/.pos-config"
PERSONAL_DIR=""
CURRENT_INSTANCE=""

if [ -f "$CONFIG_FILE" ]; then
    CURRENT_INSTANCE=$(grep -E '^instance_dir=' "$CONFIG_FILE" | head -1 | cut -d= -f2 || true)
fi

if [ -n "$CURRENT_INSTANCE" ] && [ -d "$WORKSPACE_DIR/$CURRENT_INSTANCE" ]; then
    PERSONAL_DIR="$WORKSPACE_DIR/$CURRENT_INSTANCE"
    ok "Istanza personale già configurata in $CURRENT_INSTANCE"
else
    echo "  Il framework è condiviso e generico. Le tue attività, valori personali,"
    echo "  fonti, appunti e note private risiedono in un tuo repository privato separato."
    echo ""
    
    INSTANCE_INPUT=""
    if [ "$NON_INTERACTIVE" = false ]; then
        read -rp "  Nome della cartella istanza (es. my-life-pos): " INSTANCE_INPUT
    fi
    INSTANCE_INPUT="${INSTANCE_INPUT:-my-pos}"
    TARGET_DIR="$WORKSPACE_DIR/personal/$INSTANCE_INPUT"
    
    if [ -d "$TARGET_DIR/.git" ]; then
        ok "Repository già presente in personal/$INSTANCE_INPUT"
    else
        REPO_URL=""
        if [ "$NON_INTERACTIVE" = false ]; then
            read -rp "  URL/Nome repo GitHub privato (es. git@github.com:user/$INSTANCE_INPUT.git, oppure lascia vuoto per creare locale): " REPO_URL
        fi
        
        if [ -n "$REPO_URL" ]; then
            info "Clonazione repository $REPO_URL in personal/$INSTANCE_INPUT..."
            mkdir -p "$WORKSPACE_DIR/personal"
            if git clone "$REPO_URL" "$TARGET_DIR"; then
                ok "Repository clonato con successo"
            else
                warn "Clone fallito. Inizializzo repository locale in personal/$INSTANCE_INPUT..."
                mkdir -p "$TARGET_DIR"
                (cd "$TARGET_DIR" && git init)
            fi
        else
            info "Inizializzazione repository privato locale in personal/$INSTANCE_INPUT..."
            mkdir -p "$TARGET_DIR"
            (cd "$TARGET_DIR" && git init)
            ok "Repository locale inizializzato in personal/$INSTANCE_INPUT"
        fi
    fi
    
    echo "instance_dir=personal/$INSTANCE_INPUT" > "$CONFIG_FILE"
    PERSONAL_DIR="$TARGET_DIR"
    ok ".pos-config aggiornato (instance_dir=personal/$INSTANCE_INPUT)"
fi

INSTANCE_NAME=$(basename "$PERSONAL_DIR")

# -------------------------------------------------------------
# 5. Seed Canonical Structure & Templates if Needed
# -------------------------------------------------------------
info "Verifica e seeding della struttura canonica dell'istanza..."
mkdir -p "$PERSONAL_DIR/areas"
mkdir -p "$PERSONAL_DIR/backlog/items"
mkdir -p "$PERSONAL_DIR/profile"
mkdir -p "$PERSONAL_DIR/knowledge"
mkdir -p "$PERSONAL_DIR/reference/sources"
mkdir -p "$PERSONAL_DIR/inbox"
mkdir -p "$PERSONAL_DIR/journal"
mkdir -p "$PERSONAL_DIR/skills"

# Seed profile templates if missing
for tpl in "$SETUP_DIR/templates/profile"/*-TEMPLATE.md; do
    [ -e "$tpl" ] || continue
    base=$(basename "$tpl" -TEMPLATE.md).md
    dest="$PERSONAL_DIR/profile/$base"
    if [ ! -f "$dest" ]; then
        cp "$tpl" "$dest"
        ok "Inizializzato profilo personale: profile/$base"
    fi
done

# Seed personal CLAUDE.md / AGENTS.md if missing
if [ ! -f "$PERSONAL_DIR/CLAUDE.md" ]; then
    USER_NAME="$(git config --get user.name || id -un)"
    sed -e "s/{{NAME}}/$USER_NAME/g" -e "s/{{LANGUAGE}}/Italiano/g" \
        "$SETUP_DIR/templates/CLAUDE.template.md" > "$PERSONAL_DIR/CLAUDE.md"
    ok "Creato $PERSONAL_DIR/CLAUDE.md"
fi
(cd "$PERSONAL_DIR" && ln -sf CLAUDE.md AGENTS.md && ln -sf CLAUDE.md GEMINI.md)

# Pre-push hook for secret protection if git repo
if [ -d "$PERSONAL_DIR/.git" ] && command -v gitleaks &>/dev/null; then
    HOOK_FILE="$PERSONAL_DIR/.git/hooks/pre-push"
    cat << 'HOOK_EOF' > "$HOOK_FILE"
#!/bin/bash
if command -v gitleaks >/dev/null 2>&1; then
    gitleaks protect --staged --verbose || {
        echo "[personal-repo] Push bloccato: rilevati possibili segreti con gitleaks."
        exit 1
    }
fi
exit 0
HOOK_EOF
    chmod +x "$HOOK_FILE"
    ok "Hook pre-push di scansione segreti (gitleaks) installato nell'istanza"
fi

# -------------------------------------------------------------
# 6. Skill Partitioning & Dynamic Linking
# -------------------------------------------------------------
info "Configurazione e collegamento delle skill..."

# Ensure internal instance symlinks
mkdir -p "$PERSONAL_DIR/.agents" "$PERSONAL_DIR/.claude"
(cd "$PERSONAL_DIR" && ln -sfn ../skills .agents/skills && ln -sfn ../skills .claude/skills)

# Dynamic link from personal instance skills into framework .agents/skills
mkdir -p "$WORKSPACE_DIR/.agents/skills"
mkdir -p "$WORKSPACE_DIR/.claude"
[ -L "$WORKSPACE_DIR/.claude/skills" ] || ln -sfn ../.agents/skills "$WORKSPACE_DIR/.claude/skills"

linked_skills=0
if [ -d "$PERSONAL_DIR/skills" ]; then
    for skill_path in "$PERSONAL_DIR/skills"/*; do
        [ -d "$skill_path" ] || continue
        if [ -f "$skill_path/SKILL.md" ]; then
            sname=$(basename "$skill_path")
            # Pure relative symlink: ../../personal/<instance>/skills/<name>
            (cd "$WORKSPACE_DIR/.agents/skills" && ln -sfn "../../personal/$INSTANCE_NAME/skills/$sname" "$sname")
            linked_skills=$((linked_skills + 1))
        fi
    done
fi

ok "Skill collegate: generic in .agents/skills/ + $linked_skills skill personali montate da personal/$INSTANCE_NAME/skills/"

# -------------------------------------------------------------
# 7. zvec-grep (zg) Local Semantic Index Setup
# -------------------------------------------------------------
info "Verifica motore semantico locale (zvec-grep / zg)..."

# Ensure dynamic zg wrapper in ~/.local/bin/zg (fully agnostic of home path or node version)
cat << 'ZG_EOF' > "$USER_HOME/.local/bin/zg"
#!/usr/bin/env bash
USER_HOME=$(getent passwd "$(id -un)" 2>/dev/null | cut -d: -f6 || echo "$HOME")
[ -z "$USER_HOME" ] && USER_HOME="$HOME"

if ! command -v node >/dev/null 2>&1; then
    for candidate_dir in "$USER_HOME/.nvm/versions/node" "$HOME/.nvm/versions/node"; do
        if [ -d "$candidate_dir" ]; then
            LATEST_NODE=$(find "$candidate_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort -V | tail -n 1)
            if [ -n "$LATEST_NODE" ] && [ -d "$LATEST_NODE/bin" ]; then
                export PATH="$LATEST_NODE/bin:$PATH"
                break
            fi
        fi
    done
fi

if command -v zg >/dev/null 2>&1 && [ "$(command -v zg)" != "$HOME/.local/bin/zg" ] && [ "$(command -v zg)" != "$USER_HOME/.local/bin/zg" ]; then
    exec zg "$@"
else
    for node_dir in "$USER_HOME/.nvm/versions/node"/* "$HOME/.nvm/versions/node"/*; do
        if [ -x "$node_dir/bin/zg" ]; then
            export PATH="$node_dir/bin:$PATH"
            exec "$node_dir/bin/zg" "$@"
        fi
    done
fi

echo "Error: 'zg' binary not found. Please install @zvec/zvec-grep via npm." >&2
exit 1
ZG_EOF
chmod +x "$USER_HOME/.local/bin/zg"
ln -sf "$USER_HOME/.local/bin/zg" "$USER_HOME/.local/bin/zvgrep"

# Ensure .zgignore
cat << 'IGNORE_EOF' > "$WORKSPACE_DIR/.zgignore"
.git/
reference/
knowledge/stesi-odoo-reference
node_modules/
.zvec-grep/
IGNORE_EOF

# Configure manifest and reindex
if [ -f "$WORKSPACE_DIR/.zvec-grep/manifest.json" ]; then
    python3 -c "
import json
with open('$WORKSPACE_DIR/.zvec-grep/manifest.json', 'r') as f:
    d = json.load(f)
for root in d.get('rootPaths', []):
    root['noIgnore'] = True
    root['include'] = ['personal/**', 'knowledge/**', 'kernel/**', 'setup/**', '*.md']
with open('$WORKSPACE_DIR/.zvec-grep/manifest.json', 'w') as f:
    json.dump(d, f, indent=2)
"
fi

if command -v "$USER_HOME/.local/bin/zg" &>/dev/null; then
    info "Rigenerazione indice semantico del workspace..."
    (cd "$WORKSPACE_DIR" && "$USER_HOME/.local/bin/zg" index "$WORKSPACE_DIR" >/dev/null 2>&1 || true)
    ok "Indice semantico locale zvec-grep aggiornato"
fi

# -------------------------------------------------------------
# 8. Chained LLM Assistant Setup
# -------------------------------------------------------------
echo ""
if confirm_step "Vuoi verificare/installare gli assistenti AI adesso (Claude Code / Antigravity / Codex)?" "S"; then
    bash "$SETUP_DIR/install-llm.sh" ${NON_INTERACTIVE:+--yes}
else
    skip "Setup LLM saltato. Potrai eseguirlo in seguito con: bash setup/install-llm.sh"
fi

# -------------------------------------------------------------
# 9. Completion (Organic Discovery)
# -------------------------------------------------------------
echo ""
echo "============================================================"
echo -e "  ${GREEN}BOOTSTRAP COMPLETATO CON SUCCESSO${NC}"
echo "============================================================"
echo "  Framework base:       $WORKSPACE_DIR"
echo "  Istanza personale:    $PERSONAL_DIR"
echo "  Skill generiche:      $WORKSPACE_DIR/.agents/skills (project-management, text-drafting)"
echo "  Skill personali:      $PERSONAL_DIR/skills"
echo ""
echo "  NOTA SUL DISCOVERY (Nessuna intervista iniziale):"
echo "  Non è prevista alcuna intervista a freddo. Il discovery avviene in"
echo "  modo completamente organico durante le normali sessioni operative."
echo "  Puoi iniziare direttamente chiedendo all'agente di aiutarti su un'attività"
echo "  reale (es. 'organizziamo il tagliando dell'auto', 'aiutami a scrivere un saggio')."
echo "  L'agente mapperà progressivamente aree, attività e bagaglio esperienziale"
echo "  all'interno del tuo repository personale."
echo "============================================================"
echo ""
