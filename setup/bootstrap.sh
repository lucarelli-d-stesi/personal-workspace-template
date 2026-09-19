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
# 4. Deploy or Connect Personal Instance Repo
# -------------------------------------------------------------
echo ""
info "Configurazione repository personale privato..."

CONFIG_FILE="$WORKSPACE_DIR/.pos-config"
PERSONAL_DIR=""
CURRENT_INSTANCE=""
FRESH_INSTANCE=false

if [ -f "$CONFIG_FILE" ]; then
    CURRENT_INSTANCE=$(grep -E '^instance_dir=' "$CONFIG_FILE" | head -1 | cut -d= -f2 || true)
fi

if [ -n "$CURRENT_INSTANCE" ] && [ -d "$WORKSPACE_DIR/$CURRENT_INSTANCE" ] && [ "$RECONFIGURE" = false ]; then
    PERSONAL_DIR="$WORKSPACE_DIR/$CURRENT_INSTANCE"
    ok "Istanza personale già configurata in $CURRENT_INSTANCE"
else
    FRESH_INSTANCE=true
    echo "  Il framework è condiviso e generico. Le tue attività, valori personali,"
    echo "  fonti, appunti e note private risiedono in un tuo repository privato separato."
    echo ""
    
    # 1. Ask for User Name
    DEFAULT_USER_NAME="$(git config --get user.name 2>/dev/null || id -un 2>/dev/null || echo "User")"
    if [ "$NON_INTERACTIVE" = false ]; then
        read -rp "  Come ti chiami? (Nome per l'istanza, default: $DEFAULT_USER_NAME): " USER_NAME_INPUT
        USER_NAME="${USER_NAME_INPUT:-$DEFAULT_USER_NAME}"
    else
        USER_NAME="$DEFAULT_USER_NAME"
    fi

    # Derive slug
    USER_SLUG=$(printf '%s' "$USER_NAME" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9' '-' | sed 's/-\{2,\}/-/g; s/^-//; s/-$//')
    [ -z "$USER_SLUG" ] && USER_SLUG="my"
    DEFAULT_INSTANCE="${USER_SLUG}-pos"

    if [ "$NON_INTERACTIVE" = false ]; then
        read -rp "  Nome della cartella dell'istanza [personal/$DEFAULT_INSTANCE]: " INSTANCE_INPUT
        INSTANCE_INPUT="${INSTANCE_INPUT:-$DEFAULT_INSTANCE}"
    else
        INSTANCE_INPUT="$DEFAULT_INSTANCE"
    fi
    TARGET_DIR="$WORKSPACE_DIR/personal/$INSTANCE_INPUT"
    mkdir -p "$WORKSPACE_DIR/personal"
    
    if [ -d "$TARGET_DIR/.git" ]; then
        ok "Repository già presente in personal/$INSTANCE_INPUT"
    else
        GH_AVAILABLE=false
        if command -v gh &>/dev/null; then
            if gh auth status &>/dev/null 2>&1; then
                GH_AVAILABLE=true
            fi
        fi

        SETUP_CHOICE=""
        if [ "$NON_INTERACTIVE" = true ]; then
            SETUP_CHOICE="3"
        else
            echo ""
            echo "  Scegli come configurare il tuo repository personale:"
            if [ "$GH_AVAILABLE" = true ]; then
                echo "    1) [GitHub CLI] Crea automaticamente un nuovo repo privato su GitHub dal template"
                echo "    2) [Git Clone]  Clona un repository già esistente da GitHub (HTTPS o SSH)"
                echo "    3) [Locale]     Crea un repository privato solo in locale sul tuo computer"
                read -rp "  Scelta [1]: " SETUP_CHOICE
                SETUP_CHOICE="${SETUP_CHOICE:-1}"
            elif command -v gh &>/dev/null; then
                echo "    1) [GitHub CLI] Accedi a GitHub (gh auth login) e crea il repo dal template"
                echo "    2) [Git Clone]  Clona un repository già esistente da GitHub (HTTPS o SSH)"
                echo "    3) [Locale]     Crea un repository privato solo in locale sul tuo computer"
                read -rp "  Scelta [3]: " SETUP_CHOICE
                SETUP_CHOICE="${SETUP_CHOICE:-3}"
            else
                echo "    1) [Git Clone]  Clona un repository già esistente da GitHub (HTTPS o SSH)"
                echo "    2) [Locale]     Crea un repository privato solo in locale sul tuo computer"
                echo "       (Nota: per creare automaticamente su GitHub, installa GitHub CLI 'gh')"
                read -rp "  Scelta [2]: " SETUP_CHOICE
                if [ "$SETUP_CHOICE" = "1" ]; then
                    SETUP_CHOICE="2"
                else
                    SETUP_CHOICE="3"
                fi
            fi
        fi

        if [ "$SETUP_CHOICE" = "1" ]; then
            if ! gh auth status &>/dev/null 2>&1; then
                info "Avvio autenticazione con GitHub CLI..."
                gh auth login || {
                    warn "Autenticazione GitHub CLI fallita o annullata."
                }
            fi
            
            if gh auth status &>/dev/null 2>&1; then
                GH_REPO_NAME="$INSTANCE_INPUT"
                if [ "$NON_INTERACTIVE" = false ]; then
                    read -rp "  Nome del repo GitHub da creare [default: $GH_REPO_NAME]: " GH_REPO_INPUT
                    GH_REPO_NAME="${GH_REPO_INPUT:-$GH_REPO_NAME}"
                fi
                info "Creazione repository privato '$GH_REPO_NAME' su GitHub dal template..."
                if (cd "$WORKSPACE_DIR/personal" && gh repo create "$GH_REPO_NAME" --template danielelucarelli1980/pos-instance-template --private --clone); then
                    ok "Repository GitHub privato '$GH_REPO_NAME' creato e clonato con successo"
                    if [ "$GH_REPO_NAME" != "$INSTANCE_INPUT" ]; then
                        INSTANCE_INPUT="$GH_REPO_NAME"
                        TARGET_DIR="$WORKSPACE_DIR/personal/$INSTANCE_INPUT"
                    fi
                else
                    warn "Creazione via GitHub CLI non riuscita. Inizializzo repository locale..."
                    SETUP_CHOICE="3"
                fi
            else
                warn "Procedo con creazione repository locale."
                SETUP_CHOICE="3"
            fi
        fi

        if [ "$SETUP_CHOICE" = "2" ]; then
            REPO_URL=""
            if [ "$NON_INTERACTIVE" = false ]; then
                echo "  Se hai già creato il repository su GitHub (es. premendo 'Use this template'):"
                read -rp "  Inserisci l'URL del repo (es. https://github.com/username/$INSTANCE_INPUT.git): " REPO_URL
            fi
            if [ -n "$REPO_URL" ]; then
                info "Clonazione repository $REPO_URL in personal/$INSTANCE_INPUT..."
                if git clone "$REPO_URL" "$TARGET_DIR"; then
                    ok "Repository clonato con successo"
                else
                    warn "Clone fallito. Inizializzo repository locale in personal/$INSTANCE_INPUT..."
                    SETUP_CHOICE="3"
                fi
            else
                SETUP_CHOICE="3"
            fi
        fi

        if [ "$SETUP_CHOICE" = "3" ]; then
            info "Inizializzazione repository privato locale in personal/$INSTANCE_INPUT..."
            mkdir -p "$TARGET_DIR"
            (cd "$TARGET_DIR" && git init -b main 2>/dev/null || (cd "$TARGET_DIR" && git init))
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
