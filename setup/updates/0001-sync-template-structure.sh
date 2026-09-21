#!/usr/bin/env bash
# =============================================================
# 0001-sync-template-structure.sh
# Descrizione: Configura il remote 'template', aggiorna .gitignore e copia le nuove guide di documentazione
# =============================================================
set -euo pipefail

TARGET_DIR="${1:-}"

if [ -z "$TARGET_DIR" ] || [ ! -d "$TARGET_DIR" ]; then
    echo "Errore: Directory dell'istanza non specificata o inesistente: '$TARGET_DIR'" >&2
    exit 1
fi

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEMPLATE_DIR="$WORKSPACE_DIR/setup/templates/personal-instance-TEMPLATE"

echo "  -> Sincronizzazione struttura per $TARGET_DIR..."

# 1. Configura remote 'template' se git repo
if [ -d "$TARGET_DIR/.git" ]; then
    if ! git -C "$TARGET_DIR" remote get-url template &>/dev/null; then
        git -C "$TARGET_DIR" remote add template "https://github.com/lucarelli-d-stesi/personal-workspace-template.git" 2>/dev/null || true
        echo "     + Remote 'template' configurato"
    fi
fi

# 2. Allinea regole .gitignore
if [ -f "$TEMPLATE_DIR/.gitignore" ] && [ -f "$TARGET_DIR/.gitignore" ]; then
    ADDED_RULES=0
    while IFS= read -r line || [ -n "$line" ]; do
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        if ! grep -qF "$line" "$TARGET_DIR/.gitignore" 2>/dev/null; then
            if [ "$ADDED_RULES" -eq 0 ]; then
                echo "" >> "$TARGET_DIR/.gitignore"
                echo "# Regole sincronizzate dal template (0001)" >> "$TARGET_DIR/.gitignore"
            fi
            echo "$line" >> "$TARGET_DIR/.gitignore"
            ADDED_RULES=$((ADDED_RULES + 1))
        fi
    done < "$TEMPLATE_DIR/.gitignore"
    if [ "$ADDED_RULES" -gt 0 ]; then
        echo "     + $ADDED_RULES nuove regole aggiunte a .gitignore"
    fi
fi

# 3. Copia guide/README mancanti (senza mai sovrascrivere file dati personali)
READMES=("profile/README.md" "reference/sources/README.md" "machines/README.md" "journal/README.md" "areas/README.md" "projects/README.md")
for r in "${READMES[@]}"; do
    if [ ! -f "$TARGET_DIR/$r" ] && [ -f "$TEMPLATE_DIR/$r" ]; then
        mkdir -p "$(dirname "$TARGET_DIR/$r")"
        cp "$TEMPLATE_DIR/$r" "$TARGET_DIR/$r"
        echo "     + Creata guida mancante: $r"
    fi
done

exit 0
