#!/usr/bin/env bash
# =============================================================
# check-updates.sh — Verifica aggiornamenti del framework e del template POS
#
# Ispeziona:
#   1. Aggiornamenti del framework (git fetch origin su personal-workspace)
#   2. Migrazioni pendenti in setup/updates/ non ancora registrate in .pos-updates-applied
#   3. Differenze/aggiornamenti tra il template canonico e l'istanza personale
#      (es. .gitignore, sezioni in CLAUDE.md/AGENTS.md, nuove directory/file guida)
#   4. Aggiornamenti del remote 'template' nell'istanza personale (se configurato)
#
# Uso:
#   bash setup/check-updates.sh                 # Solo verifica e report
#   bash setup/check-updates.sh --apply-migrations # Esegue le migrazioni pendenti
# =============================================================
set -euo pipefail

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SETUP_DIR="$WORKSPACE_DIR/setup"
CONFIG_FILE="$WORKSPACE_DIR/.pos-config"
TEMPLATE_DIR="$SETUP_DIR/templates/personal-instance-TEMPLATE"

# Colori
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

APPLY_MIGRATIONS=false
SYNC_ALL=false
for arg in "$@"; do
    case "$arg" in
        --apply-migrations) APPLY_MIGRATIONS=true ;;
        --sync|--apply)
            APPLY_MIGRATIONS=true
            SYNC_ALL=true
            ;;
    esac
done


echo ""
echo -e "${BOLD}============================================================${NC}"
echo -e "${BOLD}  VERIFICA AGGIORNAMENTI POS (Framework & Template)${NC}"
echo -e "${BOLD}============================================================${NC}"
echo "  Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
echo "  Framework: $WORKSPACE_DIR"

# 1. Trova l'istanza personale
INSTANCE_NAME=""
if [ -f "$CONFIG_FILE" ]; then
    INSTANCE_NAME=$(grep -E '^[[:space:]]*instance_dir=' "$CONFIG_FILE" | cut -d= -f2- | tr -d ' "[:space:]' || true)
fi

if [ -z "$INSTANCE_NAME" ]; then
    err "File .pos-config non trovato o non configurato."
    exit 1
fi

if [[ "$INSTANCE_NAME" == personal/* ]]; then
    PERSONAL_DIR="$WORKSPACE_DIR/$INSTANCE_NAME"
    INSTANCE_SLUG=$(basename "$INSTANCE_NAME")
else
    PERSONAL_DIR="$WORKSPACE_DIR/personal/$INSTANCE_NAME"
    INSTANCE_SLUG="$INSTANCE_NAME"
fi
echo "  Istanza:   $INSTANCE_SLUG ($PERSONAL_DIR)"
echo ""

# -------------------------------------------------------------
# 1. Controlla aggiornamenti del Framework (personal-workspace)
# -------------------------------------------------------------
echo -e "${BOLD}1. Aggiornamenti Framework (personal-workspace)${NC}"
if [ -d "$WORKSPACE_DIR/.git" ]; then
    git -C "$WORKSPACE_DIR" fetch origin --quiet 2>/dev/null || warn "Impossibile contattare il remote origin del framework (offline?)"
    
    FW_BRANCH=$(git -C "$WORKSPACE_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
    UPSTREAM="origin/$FW_BRANCH"
    
    if git -C "$WORKSPACE_DIR" rev-parse --verify "$UPSTREAM" &>/dev/null; then
        BEHIND=$(git -C "$WORKSPACE_DIR" rev-list --count "HEAD..$UPSTREAM" 2>/dev/null || echo "0")
        AHEAD=$(git -C "$WORKSPACE_DIR" rev-list --count "$UPSTREAM..HEAD" 2>/dev/null || echo "0")
        
        if [ "$BEHIND" -gt 0 ]; then
            warn "Il framework ha $BEHIND commit da scaricare da $UPSTREAM:"
            git -C "$WORKSPACE_DIR" log --oneline "HEAD..$UPSTREAM" | sed 's/^/      /'
            info "Puoi aggiornare eseguendo: git -C $WORKSPACE_DIR pull origin $FW_BRANCH"
        else
            ok "Il framework è aggiornato rispetto a $UPSTREAM."
        fi
        
        if [ "$AHEAD" -gt 0 ]; then
            info "Hai $AHEAD commit locali non ancora inviati a $UPSTREAM."
        fi
    else
        info "Nessun tracking branch remoto trovato per $FW_BRANCH."
    fi
else
    warn "Cartella .git del framework non trovata."
fi
echo ""

# -------------------------------------------------------------
# 2. Migrazioni pendenti in setup/updates/
# -------------------------------------------------------------
echo -e "${BOLD}2. Migrazioni di struttura (setup/updates/)${NC}"
APPLIED_FILE="$PERSONAL_DIR/.pos-updates-applied"
touch "$APPLIED_FILE"

PENDING_SCRIPTS=()
if [ -d "$SETUP_DIR/updates" ]; then
    for script in "$SETUP_DIR/updates"/????-*.sh; do
        [ -e "$script" ] || continue
        script_name=$(basename "$script")
        if ! grep -qxF "$script_name" "$APPLIED_FILE" 2>/dev/null; then
            PENDING_SCRIPTS+=("$script")
        fi
    done
fi

if [ ${#PENDING_SCRIPTS[@]} -eq 0 ]; then
    ok "Nessuna migrazione pendente. Tutte le migrazioni risultano applicate."
else
    warn "Trovate ${#PENDING_SCRIPTS[@]} migrazioni non ancora applicate:"
    for s in "${PENDING_SCRIPTS[@]}"; do
        sname=$(basename "$s")
        # Leggi descrizione se presente nel commento iniziale
        desc=$(grep -E '^# Descrizione:' "$s" | cut -d: -f2- | sed 's/^[[:space:]]*//' || echo "")
        is_dangerous=$(grep -qE '^# DANGEROUS' "$s" && echo " [ATTENZIONE: DANGEROUS]" || echo "")
        echo -e "    - ${YELLOW}$sname${NC}$is_dangerous: ${desc:-Nessuna descrizione}"
    done

    if [ "$APPLY_MIGRATIONS" = true ]; then
        echo ""
        info "Applicazione delle migrazioni in corso..."
        for s in "${PENDING_SCRIPTS[@]}"; do
            sname=$(basename "$s")
            info "Esecuzione $sname..."
            if bash "$s" "$PERSONAL_DIR"; then
                echo "$sname" >> "$APPLIED_FILE"
                ok "$sname applicata con successo."
            else
                err "Errore durante l'esecuzione di $sname. Interruzione."
                exit 1
            fi
        done
        ok "Tutte le migrazioni pendenti sono state applicate."
    else
        info "Per applicarle, esegui: bash setup/check-updates.sh --apply-migrations"
    fi
fi
echo ""

# -------------------------------------------------------------
# 3. Allineamento Template Istanza vs Istanza Personale
# -------------------------------------------------------------
echo -e "${BOLD}3. Allineamento Template -> Istanza Personale${NC}"

# 3a. Verifica .gitignore
if [ -f "$TEMPLATE_DIR/.gitignore" ] && [ -f "$PERSONAL_DIR/.gitignore" ]; then
    MISSING_GITIGNORE=()
    while IFS= read -r line || [ -n "$line" ]; do
        # Salta commenti e righe vuote
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        if ! grep -qF "$line" "$PERSONAL_DIR/.gitignore" 2>/dev/null; then
            MISSING_GITIGNORE+=("$line")
        fi
    done < "$TEMPLATE_DIR/.gitignore"

    if [ ${#MISSING_GITIGNORE[@]} -gt 0 ]; then
        if [ "$SYNC_ALL" = true ]; then
            echo "" >> "$PERSONAL_DIR/.gitignore"
            echo "# Regole sincronizzate dal template ($(date '+%Y-%m-%d'))" >> "$PERSONAL_DIR/.gitignore"
            for rule in "${MISSING_GITIGNORE[@]}"; do
                echo "$rule" >> "$PERSONAL_DIR/.gitignore"
            done
            ok "Aggiornato .gitignore con ${#MISSING_GITIGNORE[@]} nuove regole dal template."
        else
            warn "Regole mancanti nel .gitignore della tua istanza:"
            for rule in "${MISSING_GITIGNORE[@]}"; do
                echo -e "      + $rule"
            done
            info "Suggerimento: puoi sincronizzarle con: bash setup/check-updates.sh --sync"
        fi
    else
        ok ".gitignore dell'istanza è allineato al template."
    fi
fi

# 3b. Verifica file/cartelle mancanti (strutturali)
CHECK_DIRS=("areas" "backlog/items" "profile" "knowledge" "reference/sources" "inbox" "journal" "skills" "projects" "machines")
for dir in "${CHECK_DIRS[@]}"; do
    if [ ! -d "$PERSONAL_DIR/$dir" ]; then
        if [ "$SYNC_ALL" = true ]; then
            mkdir -p "$PERSONAL_DIR/$dir"
            ok "Creata cartella mancante: $dir"
        else
            warn "Cartella strutturale mancante: $dir (creabile con: mkdir -p $PERSONAL_DIR/$dir)"
        fi
    fi
done

# 3c. Verifica file README/guide mancanti
CHECK_READMES=("profile/README.md" "reference/sources/README.md" "machines/README.md" "journal/README.md" "areas/README.md")
for readme in "${CHECK_READMES[@]}"; do
    if [ ! -f "$PERSONAL_DIR/$readme" ] && [ -f "$TEMPLATE_DIR/$readme" ]; then
        if [ "$SYNC_ALL" = true ]; then
            mkdir -p "$(dirname "$PERSONAL_DIR/$readme")"
            cp "$TEMPLATE_DIR/$readme" "$PERSONAL_DIR/$readme"
            ok "Copiata guida/template: $readme"
        else
            info "Nuova guida/documentazione disponibile nel template: $readme"
        fi
    fi
done

# 3d. Verifica remote 'template'
if [ -d "$PERSONAL_DIR/.git" ]; then
    TEMPLATE_REMOTE=$(git -C "$PERSONAL_DIR" config --get remote.template.url 2>/dev/null || echo "")
    if [ -n "$TEMPLATE_REMOTE" ]; then
        ok "Remote 'template' configurato: $TEMPLATE_REMOTE"
        git -C "$PERSONAL_DIR" fetch template --quiet 2>/dev/null || warn "Impossibile contattare il remote 'template' (offline?)"
    else
        if [ "$SYNC_ALL" = true ]; then
            git -C "$PERSONAL_DIR" remote add template "https://github.com/danielelucarelli1980/pos-instance-template.git" 2>/dev/null || true
            ok "Configurato remote 'template' in $PERSONAL_DIR"
        else
            warn "Remote 'template' non configurato nell'istanza."
            info "Puoi aggiungerlo con: git -C $PERSONAL_DIR remote add template https://github.com/danielelucarelli1980/pos-instance-template.git"
        fi
    fi
fi
echo ""

# -------------------------------------------------------------
# 4. Marketplace & Fonti Esterne
# -------------------------------------------------------------
echo -e "${BOLD}4. Marketplace & Fonti Esterne${NC}"
AVAILABLE_COUNT=0
UNADOPTED=()
for src in "$WORKSPACE_DIR/knowledge/sources"/*.md; do
    [ -f "$src" ] || continue
    base=$(basename "$src")
    [ "$base" = "README.md" ] && continue
    [ "$base" = "INDEX.md" ] && continue
    AVAILABLE_COUNT=$((AVAILABLE_COUNT + 1))
    if [ ! -f "$PERSONAL_DIR/reference/sources/$base" ]; then
        UNADOPTED+=("$base")
    fi
done

ADOPTED_COUNT=$((AVAILABLE_COUNT - ${#UNADOPTED[@]}))
if [ ${#UNADOPTED[@]} -gt 0 ]; then
    info "Marketplace POS: $AVAILABLE_COUNT strumenti a catalogo ($ADOPTED_COUNT attivi, ${#UNADOPTED[@]} disponibili per l'adozione)."
    info "Strumenti non ancora adottati: ${UNADOPTED[*]}"
    info "Puoi esplorare la vetrina con: bash setup/marketplace.sh"
else
    ok "Marketplace POS: tutti i $AVAILABLE_COUNT strumenti disponibili a catalogo sono collegati alla tua istanza."
fi

# Controllo Fonti Orfane (Orphan Detection)
ORPHANS=()
if [ -d "$PERSONAL_DIR/reference/sources" ]; then
    for user_src in "$PERSONAL_DIR/reference/sources"/*.md; do
        [ -f "$user_src" ] || continue
        base=$(basename "$user_src")
        [ "$base" = "README.md" ] && continue
        ref_line=$(grep -E '^[[:space:]]*source_ref:' "$user_src" | head -n 1 | cut -d: -f2- | tr -d ' "[:space:]' || true)
        if [ -n "$ref_line" ] && [ ! -f "$WORKSPACE_DIR/$ref_line" ]; then
            ORPHANS+=("$base ($ref_line)")
        fi
    done
fi

if [ ${#ORPHANS[@]} -gt 0 ]; then
    warn "Rilevate ${#ORPHANS[@]} fonti orfane (il file sorgente nel framework è stato rimosso o spostato):"
    for o in "${ORPHANS[@]}"; do
        echo -e "      ${RED}!${NC} $o"
    done
    info "Suggerimento: chiedi all'assistente AI di archiviare la scheda in reference/sources/archive/ o renderla autonoma."
else
    ok "Nessuna fonte orfana rilevata nell'istanza personale."
fi
echo ""

# -------------------------------------------------------------
# Riepilogo
# -------------------------------------------------------------
echo -e "${BOLD}============================================================${NC}"
echo -e "${BOLD}  RIEPILOGO${NC}"
echo -e "${BOLD}============================================================${NC}"
echo -e "  Puoi chiedere all'assistente AI:"
echo -e "  - \"Ci sono novità nel workspace?\" per verificare gli aggiornamenti."
echo -e "  - \"Applica gli aggiornamenti del template\" per applicare le modifiche non distruttive."
echo -e "${BOLD}============================================================${NC}"
echo ""

