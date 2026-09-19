#!/usr/bin/env bash
# =============================================================
# marketplace.sh — POS Marketplace & Ecosystem Hub
#
# Inspects available ecosystem tools, MCP servers, and data sources
# in the POS framework, comparing them with your active instance.
#
# Usage:
#   bash setup/marketplace.sh             # Mostra la vetrina completa
#   bash setup/marketplace.sh --info <id> # Dettagli su uno strumento
#   bash setup/marketplace.sh --json      # Output strutturato JSON
# =============================================================
set -euo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$SETUP_DIR/marketplace.py" "$@"
