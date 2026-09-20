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

# If running via pipe (e.g. curl ... | bash), reconnect stdin to terminal
if [ ! -t 0 ] && [ -e /dev/tty ]; then
    exec < /dev/tty
fi

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
RECONFIGURE=false
for arg in "$@"; do
    case "$arg" in
        --check|-c)
            exec bash "$SETUP_DIR/status.sh"
            ;;
        --yes|-y) NON_INTERACTIVE=true ;;
        --reconfigure) RECONFIGURE=true ;;
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
# 1. OS, Machine & Scenario Detection
# -------------------------------------------------------------
info "Rilevamento macchina, scenario e shell..."

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
        echo "vm"; return
    fi
    echo "linux"
}

MACHINE_ID=$(detect_machine_id)
SCENARIO=$(detect_env_scenario)
OS="$(uname -s)"
case "$OS" in
    Linux)  OS_FAMILY="$SCENARIO" ;;
    Darwin) OS_FAMILY="macos" ;;
    *)      OS_FAMILY="other" ;;
esac

RC_FILE="$USER_HOME/.bashrc"
[ -n "${ZSH_VERSION:-}" ] && RC_FILE="$USER_HOME/.zshrc"
[ "$OS_FAMILY" = "macos" ] && [ -f "$USER_HOME/.zshrc" ] && RC_FILE="$USER_HOME/.zshrc"

# Ensure ~/.local/bin is in PATH in shell rc
if [ -f "$RC_FILE" ] && ! grep -q '\.local/bin' "$RC_FILE"; then
    echo '' >> "$RC_FILE"
    echo '# [pos] User local bin' >> "$RC_FILE"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$RC_FILE"
    ok "Aggiunto ~/.local/bin a PATH in $RC_FILE"
fi

ok "Macchina: $MACHINE_ID | Scenario: $SCENARIO (shell rc: $RC_FILE)"

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
# 4. Git Remote Topology & Privacy Safeguards
# -------------------------------------------------------------
echo ""
info "Verifica topologia Git e salvaguardie privacy..."

CONFIG_FILE="$WORKSPACE_DIR/.pos-config"
PERSONAL_DIR="$WORKSPACE_DIR"
FRESH_INSTANCE=false

# Legacy check (if .pos-config exists and points to personal/...)
if [ -f "$CONFIG_FILE" ]; then
    LEGACY_INSTANCE=$(grep -E '^instance_dir=' "$CONFIG_FILE" | head -1 | cut -d= -f2 || true)
    if [ -n "$LEGACY_INSTANCE" ] && [ -d "$WORKSPACE_DIR/$LEGACY_INSTANCE" ]; then
        PERSONAL_DIR="$WORKSPACE_DIR/$LEGACY_INSTANCE"
        info "Rilevata configurazione legacy a due repository: $LEGACY_INSTANCE"
    fi
fi

# 4a. Enable git pre-push hooks
git -C "$WORKSPACE_DIR" config core.hooksPath .githooks 2>/dev/null || true
ok "Hook pre-push (privacy safeguard): attivo (.githooks)"

# 4b. Verify Git Remotes
CURRENT_ORIGIN=$(git -C "$WORKSPACE_DIR" config --get remote.origin.url 2>/dev/null || echo "")
TEMPLATE_ORIGIN="danielelucarelli1980/personal-workspace"

if [[ "$CURRENT_ORIGIN" == *"$TEMPLATE_ORIGIN"* ]]; then
    warn "Il remote 'origin' punta attualmente al template pubblico ($CURRENT_ORIGIN)."
    echo ""
    echo "  Per tutelare la tua privacy, i tuoi dati personali, note e progetti"
    echo "  devono essere salvati in un tuo repository privato su GitHub."
    echo ""

    if [ "$NON_INTERACTIVE" = false ]; then
        if command -v gh &>/dev/null && gh auth status &>/dev/null 2>&1; then
            echo "  GitHub CLI (gh) è disponibile e autenticato."
            DEFAULT_REPO_NAME="personal-pos"
            read -rp "  Vuoi creare un nuovo repository GitHub privato adesso? [S/n]: " CREATE_GH
            CREATE_GH="${CREATE_GH:-S}"
            case "$CREATE_GH" in
                [sSyY]*)
                    read -rp "  Nome del repository privato su GitHub [$DEFAULT_REPO_NAME]: " REPO_NAME_INPUT
                    REPO_NAME="${REPO_NAME_INPUT:-$DEFAULT_REPO_NAME}"
                    info "Creazione del repository privato $REPO_NAME su GitHub..."
                    gh repo create "$REPO_NAME" --private --source="$WORKSPACE_DIR" --remote=origin --push=false 2>/dev/null || true
                    # Disarm template
                    git -C "$WORKSPACE_DIR" remote rename origin template 2>/dev/null || true
                    git -C "$WORKSPACE_DIR" remote set-url --push template "NO_PUSH_UPSTREAM_TEMPLATE" 2>/dev/null || true
                    git -C "$WORKSPACE_DIR" remote add origin "git@github.com:$(gh api user -q .login)/$REPO_NAME.git" 2>/dev/null || true
                    ok "Creato repository privato GitHub e impostato come origin."
                    ;;
                *)
                    read -rp "  Inserisci l'URL del tuo repository Git privato esistente (o invio per saltare): " CUSTOM_URL
                    if [ -n "$CUSTOM_URL" ]; then
                        git -C "$WORKSPACE_DIR" remote rename origin template 2>/dev/null || true
                        git -C "$WORKSPACE_DIR" remote set-url --push template "NO_PUSH_UPSTREAM_TEMPLATE" 2>/dev/null || true
                        git -C "$WORKSPACE_DIR" remote add origin "$CUSTOM_URL"
                        ok "Configurato remote origin: $CUSTOM_URL"
                    else
                        warn "Remote origin lasciato sul template. Il pre-push hook bloccherà qualsiasi invio di dati personali."
                    fi
                    ;;
            esac
        else
            read -rp "  Inserisci l'URL del tuo repository Git privato esistente (o invio per saltare): " CUSTOM_URL
            if [ -n "$CUSTOM_URL" ]; then
                git -C "$WORKSPACE_DIR" remote rename origin template 2>/dev/null || true
                git -C "$WORKSPACE_DIR" remote set-url --push template "NO_PUSH_UPSTREAM_TEMPLATE" 2>/dev/null || true
                git -C "$WORKSPACE_DIR" remote add origin "$CUSTOM_URL"
                ok "Configurato remote origin: $CUSTOM_URL"
            else
                warn "Remote origin lasciato sul template. Il pre-push hook bloccherà qualsiasi invio di dati personali."
            fi
        fi
    fi
else
    ok "Remote 'origin' (Privato): $CURRENT_ORIGIN"
fi

# 4c. Ensure template remote is registered with push disarmed
CURRENT_TEMPLATE=$(git -C "$WORKSPACE_DIR" config --get remote.template.url 2>/dev/null || echo "")
if [ -z "$CURRENT_TEMPLATE" ]; then
    git -C "$WORKSPACE_DIR" remote add template "https://github.com/danielelucarelli1980/personal-workspace.git" 2>/dev/null || true
    git -C "$WORKSPACE_DIR" remote set-url --push template "NO_PUSH_UPSTREAM_TEMPLATE" 2>/dev/null || true
    ok "Remote 'template' aggiunto (upstream in sola lettura, push disarmato)"
else
    git -C "$WORKSPACE_DIR" remote set-url --push template "NO_PUSH_UPSTREAM_TEMPLATE" 2>/dev/null || true
    ok "Remote 'template' verificato (push disarmato)"
fi

# 4d. Ensure structural directories exist
info "Verifica directory del workspace..."
for d in profile areas backlog/items journal inbox projects skills machines reference/sources; do
    mkdir -p "$PERSONAL_DIR/$d"
done
ok "Directory strutturali presenti"

# -------------------------------------------------------------
# 5. Seed Canonical Structure & Templates if Needed
# -------------------------------------------------------------
info "Verifica e seeding della struttura canonica dell'istanza..."

# If the instance repository has no README.md, seed initial structure from template
if [ -d "$SETUP_DIR/templates/personal-instance-TEMPLATE" ] && [ ! -f "$PERSONAL_DIR/README.md" ]; then
    info "Inizializzazione da template personal-instance-TEMPLATE..."
    cp -rn "$SETUP_DIR/templates/personal-instance-TEMPLATE/"* "$PERSONAL_DIR/" 2>/dev/null || true
    [ -f "$PERSONAL_DIR/.gitignore" ] || cp "$SETUP_DIR/templates/personal-instance-TEMPLATE/.gitignore" "$PERSONAL_DIR/" 2>/dev/null || true
    ok "Struttura iniziale dell'istanza copiata dal template"
fi

mkdir -p "$PERSONAL_DIR/areas"
mkdir -p "$PERSONAL_DIR/backlog/items"
mkdir -p "$PERSONAL_DIR/profile"
mkdir -p "$PERSONAL_DIR/knowledge"
mkdir -p "$PERSONAL_DIR/reference/sources"
mkdir -p "$PERSONAL_DIR/inbox"
mkdir -p "$PERSONAL_DIR/journal"
mkdir -p "$PERSONAL_DIR/skills"
mkdir -p "$PERSONAL_DIR/projects"
mkdir -p "$PERSONAL_DIR/machines"

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

# Ensure USER_NAME is populated
if [ -z "${USER_NAME:-}" ]; then
    USER_NAME="$(git config --get user.name 2>/dev/null || id -un 2>/dev/null || echo "User")"
fi

# Seed personal CLAUDE.md / AGENTS.md / GEMINI.md if missing
if [ ! -f "$PERSONAL_DIR/CLAUDE.md" ]; then
    if [ -f "$SETUP_DIR/templates/personal-instance-TEMPLATE/CLAUDE.md" ]; then
        cp "$SETUP_DIR/templates/personal-instance-TEMPLATE/CLAUDE.md" "$PERSONAL_DIR/CLAUDE.md"
    elif [ -f "$SETUP_DIR/templates/CLAUDE.template.md" ]; then
        cp "$SETUP_DIR/templates/CLAUDE.template.md" "$PERSONAL_DIR/CLAUDE.md"
    fi
    ok "Creato $PERSONAL_DIR/CLAUDE.md"
fi

# Personalize CLAUDE.md placeholders if present
if [ -f "$PERSONAL_DIR/CLAUDE.md" ]; then
    if grep -q '{{NAME}}' "$PERSONAL_DIR/CLAUDE.md" 2>/dev/null || grep -q '{{LANGUAGE}}' "$PERSONAL_DIR/CLAUDE.md" 2>/dev/null; then
        sed -e "s/{{NAME}}/$USER_NAME/g" -e "s/{{LANGUAGE}}/Italiano/g" "$PERSONAL_DIR/CLAUDE.md" > "$PERSONAL_DIR/CLAUDE.md.tmp" && mv "$PERSONAL_DIR/CLAUDE.md.tmp" "$PERSONAL_DIR/CLAUDE.md"
        ok "Personalizzato CLAUDE.md per $USER_NAME"
    fi
fi
(cd "$PERSONAL_DIR" && ln -sf CLAUDE.md AGENTS.md && ln -sf CLAUDE.md GEMINI.md)

# Pre-push hook and remote configuration if git repo
if [ -d "$PERSONAL_DIR/.git" ]; then
    # Configure template remote for future updates if not present
    if ! git -C "$PERSONAL_DIR" remote get-url template &>/dev/null; then
        git -C "$PERSONAL_DIR" remote add template "https://github.com/danielelucarelli1980/pos-instance-template.git" 2>/dev/null || true
        ok "Configurato remote 'template' per aggiornamenti di sistema"
    fi

    # Ensure .pos-updates-applied exists
    touch "$PERSONAL_DIR/.pos-updates-applied"

    if command -v gitleaks &>/dev/null; then
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
    
    # If this was a fresh instance creation, record initial setup commit if needed
    if [ "$FRESH_INSTANCE" = true ]; then
        if [ -n "$(git -C "$PERSONAL_DIR" status --porcelain 2>/dev/null)" ]; then
            git -C "$PERSONAL_DIR" add -A 2>/dev/null || true
            git -C "$PERSONAL_DIR" commit -m "chore: initial personal instance setup for $USER_NAME" 2>/dev/null || true
            ok "Commit iniziale registrato nel repository privato"
        fi
    fi
fi


# -------------------------------------------------------------
# 5b. Per-Machine Profile Setup (machines/<id>.md)
# -------------------------------------------------------------
info "Verifica profilo macchina locale (machines/${MACHINE_ID}.md)..."
mkdir -p "$PERSONAL_DIR/machines"
if [ ! -f "$PERSONAL_DIR/machines/README.md" ]; then
    cat << 'README_EOF' > "$PERSONAL_DIR/machines/README.md"
# Profili Macchina

Un file per macchina, nome = slug dell'hostname (`detect_machine_id`).

Il repo personale è sincronizzato via git tra le macchine: ognuna scrive **solo
il proprio** file, così i profili non si sovrascrivono a vicenda e da qualunque
macchina si vede il parco completo.

Qui va **solo ciò che non è generalizzabile** (risorse hardware reali, percorsi
locali, tool installati, compiti del nodo, debiti). Se una nota vale per chiunque
sia su quello scenario (wsl / vm / mac / linux), va in `knowledge/reference/local-environment.md`
nel framework, passando da `inbox/` come ogni lesson learned.

**Niente segreti**: token, password, chiavi private.

Template: `setup/templates/machine-TEMPLATE.md`
Convenzione: `knowledge/reference/local-environment.md`
README_EOF
    ok "Creato machines/README.md nell'istanza"
fi

PROFILE_FILE="$PERSONAL_DIR/machines/${MACHINE_ID}.md"
if [ ! -f "$PROFILE_FILE" ]; then
    info "Creazione profilo macchina locale: machines/${MACHINE_ID}.md..."
    
    # Detect specs
    CPUS=$(nproc 2>/dev/null || echo "?")
    RAM_TOTAL="non rilevata"
    RAM_AVAIL="non rilevata"
    SWAP_TOTAL="non rilevata"
    if command -v free &>/dev/null; then
        RAM_TOTAL=$(free -h | awk '/^Mem:/ {print $2}')
        RAM_AVAIL=$(free -h | awk '/^Mem:/ {print $7}')
        SWAP_TOTAL=$(free -h | awk '/^Swap:/ {print $2}')
    fi
    DISK_INFO=$(df -h "$WORKSPACE_DIR" 2>/dev/null | awk 'NR==2 {print $2 " totali (" $4 " liberi, " $5 " usato)"}')
    if [ -f /etc/os-release ]; then
        OS_PRETTY=$(grep -E '^PRETTY_NAME=' /etc/os-release | cut -d= -f2- | tr -d '"')
    else
        OS_PRETTY="$(uname -s) $(uname -r)"
    fi
    
    # Ensure PATH has ~/.local/bin and NVM for tool detection
    export PATH="$USER_HOME/.local/bin:$PATH"
    for candidate_dir in "$USER_HOME/.nvm/versions/node" "$HOME/.nvm/versions/node"; do
        if [ -d "$candidate_dir" ]; then
            LATEST_NODE=$(find "$candidate_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort -V | tail -n 1)
            if [ -n "$LATEST_NODE" ] && [ -d "$LATEST_NODE/bin" ]; then
                export PATH="$LATEST_NODE/bin:$PATH"
                break
            fi
        fi
    done

    # Detect tools
    NODE_INFO="assente"
    command -v node &>/dev/null && NODE_INFO="$(node -v)"
    PYTHON_INFO="assente"
    command -v python3 &>/dev/null && PYTHON_INFO="$(python3 --version 2>&1)"
    DOCKER_INFO="assente"
    command -v docker &>/dev/null && DOCKER_INFO="$(docker --version | cut -d',' -f1)"
    CLAUDE_INFO="assente"
    command -v claude &>/dev/null && CLAUDE_INFO="$(claude --version 2>/dev/null || echo 'installato')"
    AGY_INFO="assente"
    command -v agy &>/dev/null && AGY_INFO="$(agy --version 2>/dev/null || echo 'installato')"
    CODEX_INFO="assente"
    command -v codex &>/dev/null && CODEX_INFO="$(codex --version 2>/dev/null || echo 'installato')"
    
    TODAY=$(date +%Y-%m-%d)
    
    cat << EOF > "$PROFILE_FILE"
# Macchina: ${MACHINE_ID}

scenario: ${SCENARIO}
os: ${OS_PRETTY} (kernel $(uname -r))
ultimo_aggiornamento: ${TODAY}

## A cosa serve questa macchina

<Descrivi il ruolo di questa macchina: es. ambiente primario di sviluppo / portatile per trasferte / server domestico>

## Risorse Hardware

- **CPU**: ${CPUS} vCPU / $(uname -m)
- **RAM**: ${RAM_TOTAL} totale (${RAM_AVAIL} disponibile) / Swap: ${SWAP_TOTAL}
- **Disco**: ${DISK_INFO}

## Tool e Ambienti Locali

- **Node.js**: ${NODE_INFO}
- **Python**: ${PYTHON_INFO}
- **Docker**: ${DOCKER_INFO}
- **Claude Code**: ${CLAUDE_INFO}
- **Antigravity CLI**: ${AGY_INFO}
- **Codex CLI**: ${CODEX_INFO}
- **zvec-grep (zg)**: attivo (modello local/potion-code-16m-v2)
- **Hook pre-push**: attivo (gitleaks)

## Specificità di questa macchina

<Eventuali porte locali impegnate, percorsi particolari, dischi esterni montati>

## Da sistemare / Debito noto

<Nessun debito noto rilevato al bootstrap>
EOF
    ok "Profilo macchina machines/${MACHINE_ID}.md generato con successo"
else
    ok "Profilo macchina machines/${MACHINE_ID}.md già presente"
fi

# Tracking last session
LAST_SESSION_FILE="$PERSONAL_DIR/machines/last-session.md"
if [ ! -f "$LAST_SESSION_FILE" ]; then
    cat << EOF > "$LAST_SESSION_FILE"
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
    ok "Inizializzato machines/last-session.md"
fi

# -------------------------------------------------------------
# 5c. Functional Projects Directory Setup (projects/)
# -------------------------------------------------------------
info "Verifica directory progetti funzionali (projects/)..."
mkdir -p "$PERSONAL_DIR/projects"
if [ ! -f "$PERSONAL_DIR/projects/README.md" ]; then
    cat << 'PROJECTS_EOF' > "$PERSONAL_DIR/projects/README.md"
# Cartelle di Progetto (Functional Project Folders)

Questa cartella ospita i repository di codice software, tool, estensioni e cloni locali di sviluppo.

## Convenzioni

1. **Ciascuna sottocartella è un repository Git indipendente**:
   - Ha il proprio file `.git/`, la propria storia, i propri branch e i propri remote (es. GitHub).
   - Non viene committata nel repository personale: l'intera cartella `projects/*/` è esclusa dal `.gitignore` dell'istanza.
2. **Separazione tra POS e Codice**:
   - Nel POS (`areas/<area>/` e `backlog/items/`): risiedono requisiti, architettura, decisioni (spec) e avanzamento (worklog).
   - Qui in `projects/<nome>/`: risiede esclusivamente il codice sorgente del software, i test, il Dockerfile e i file di build.
3. **Storage alternativo / Symlink**:
   - Se preferisci mantenere i cloni in una directory esterna (es. `~/repos/mio-tool`), puoi semplicemente creare un symlink:
     `ln -s ~/repos/mio-tool projects/mio-tool`
PROJECTS_EOF
    ok "Creato projects/README.md nell'istanza"
fi

# Ensure projects/*/ is in personal instance .gitignore
if [ -f "$PERSONAL_DIR/.gitignore" ]; then
    if ! grep -q 'projects/' "$PERSONAL_DIR/.gitignore"; then
        echo '' >> "$PERSONAL_DIR/.gitignore"
        echo '# Functional project folders (independent git repos)' >> "$PERSONAL_DIR/.gitignore"
        echo 'projects/*/' >> "$PERSONAL_DIR/.gitignore"
        ok "Aggiunto projects/*/ a .gitignore dell'istanza"
    fi
else
    cat << 'GITIGNORE_EOF' > "$PERSONAL_DIR/.gitignore"
# Functional project folders (independent git repos)
projects/*/
GITIGNORE_EOF
    ok "Creato .gitignore dell'istanza con esclusione projects/*/"
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
            if [ "$PERSONAL_DIR" = "$WORKSPACE_DIR" ]; then
                (cd "$WORKSPACE_DIR/.agents/skills" && ln -sfn "../../skills/$sname" "$sname")
            else
                (cd "$WORKSPACE_DIR/.agents/skills" && ln -sfn "../../personal/$INSTANCE_NAME/skills/$sname" "$sname")
            fi
            linked_skills=$((linked_skills + 1))
        fi
    done
fi

ok "Skill collegate: generic in .agents/skills/ + $linked_skills skill personali montate da skills/"

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
node_modules/
.zvec-grep/
projects/
**/attachments/
IGNORE_EOF

# Configure manifest and reindex
if [ -f "$WORKSPACE_DIR/.zvec-grep/manifest.json" ]; then
    python3 -c "
import json
with open('$WORKSPACE_DIR/.zvec-grep/manifest.json', 'r') as f:
    d = json.load(f)
for root in d.get('rootPaths', []):
    root['noIgnore'] = True
    root['include'] = ['areas/**', 'backlog/**', 'profile/**', 'journal/**', 'inbox/**', 'knowledge/**', 'kernel/**', 'setup/**', 'skills/**', 'reference/**', '*.md']
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
echo "  Profilo macchina:     $PERSONAL_DIR/machines/${MACHINE_ID}.md"
echo ""
echo "  AUDIT & MONITORAGGIO AMBIENTE:"
echo "  Puoi verificare in ogni momento lo stato del deploy e della macchina con:"
echo "    bash setup/bootstrap.sh --check"
echo "    # oppure"
echo "    bash setup/status.sh"
echo "    # oppure verificare aggiornamenti disponibili nel framework/template:"
echo "    bash setup/check-updates.sh"
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
