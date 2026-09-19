#!/usr/bin/env python3
"""
marketplace.py — POS Marketplace & Ecosystem Hub CLI

Lists, inspects, and audits available ecosystem tools, MCP servers,
and data sources in the POS framework, comparing them with the
active user instance.
"""

import os
import sys
import glob
import re
import json

WORKSPACE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
SOURCES_DIR = os.path.join(WORKSPACE_DIR, "knowledge", "sources")
CONFIG_FILE = os.path.join(WORKSPACE_DIR, ".pos-config")

# Terminal formatting
GREEN = "\033[0;32m"
BLUE = "\033[0;34m"
YELLOW = "\033[1;33m"
RED = "\033[0;31m"
CYAN = "\033[0;36m"
BOLD = "\033[1m"
DIM = "\033[2m"
NC = "\033[0m"


def parse_frontmatter(filepath):
    """Parses standard YAML frontmatter from a markdown file without external dependencies."""
    fm = {}
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    lines = content.split("\n")
    body_lines = []
    if lines and lines[0].strip() == "---":
        i = 1
        current_list = None
        while i < len(lines):
            line = lines[i]
            if line.strip() == "---":
                body_lines = lines[i + 1 :]
                break
            if re.match(r"^[a-zA-Z0-9_-]+:", line):
                current_list = None
                k, v = line.split(":", 1)
                k = k.strip()
                v = v.strip()
                if v.startswith("[") and v.endswith("]"):
                    fm[k] = [x.strip() for x in v[1:-1].split(",") if x.strip()]
                elif v == "":
                    current_list = k
                    fm[k] = []
                else:
                    fm[k] = v
            elif current_list and line.strip().startswith("- "):
                fm[current_list].append(line.strip()[2:].strip())
            i += 1
    else:
        body_lines = lines

    # Extract first header
    title = ""
    for line in body_lines:
        if line.startswith("# "):
            title = line[2:].strip()
            break

    return fm, title, body_lines


def get_active_instance_dir():
    """Finds the active personal instance directory from .pos-config."""
    if not os.path.isfile(CONFIG_FILE):
        return None
    with open(CONFIG_FILE, "r", encoding="utf-8") as f:
        for line in f:
            if line.startswith("instance_dir="):
                path = line.split("=", 1)[1].strip()
                full_path = os.path.join(WORKSPACE_DIR, path)
                if os.path.isdir(full_path):
                    return full_path
    return None


def get_user_sources(instance_dir):
    """Returns a dict of sources adopted in the user's personal instance."""
    adopted = {}
    if not instance_dir:
        return adopted
    ref_sources_dir = os.path.join(instance_dir, "reference", "sources")
    if not os.path.isdir(ref_sources_dir):
        return adopted

    for filepath in glob.glob(os.path.join(ref_sources_dir, "*.md")):
        fname = os.path.basename(filepath)
        if fname == "README.md":
            continue
        fm, title, _ = parse_frontmatter(filepath)
        source_ref = fm.get("source_ref")
        areas = fm.get("areas", [])
        adopted[fname] = {
            "file": fname,
            "source_ref": source_ref,
            "name": fm.get("name", title or fname),
            "status": fm.get("status", "active"),
            "areas": areas,
        }
    return adopted


def get_marketplace_sources():
    """Scans knowledge/sources for all available ecosystem items."""
    items = []
    if not os.path.isdir(SOURCES_DIR):
        return items

    for filepath in sorted(glob.glob(os.path.join(SOURCES_DIR, "*.md"))):
        fname = os.path.basename(filepath)
        if fname in ("README.md", "INDEX.md"):
            continue
        fm, title, body_lines = parse_frontmatter(filepath)
        item_id = fm.get("id", fname.replace(".md", ""))
        name = fm.get("name", title or fname)
        stype = fm.get("type", "method")

        # Derive category
        category = fm.get("category", "")
        if not category:
            if stype == "content" or "data" in item_id:
                category = "data-source"
            elif "mcp" in item_id or "mcp" in fname or "mcp" in fm.get("tags", []):
                category = "mcp-server"
            elif "publora" in item_id or "skill" in item_id:
                category = "skill-mcp"
            elif "classeviva" in fname or "cli" in item_id or "cli" in fname or "tool" in item_id or "api" in item_id:
                category = "cli-tool"
            elif "tower" in item_id or "blueprint" in fm.get("tags", []):
                category = "blueprint"
            else:
                category = "tool"

        # Summary / First descriptive paragraph
        desc = ""
        for line in body_lines:
            stripped = line.strip()
            if stripped and not stripped.startswith("#") and not stripped.startswith("---") and not stripped.startswith("|"):
                desc = stripped
                break

        items.append({
            "file": fname,
            "id": item_id,
            "name": name,
            "category": category,
            "type": stype,
            "status": fm.get("status", "ready"),
            "url": fm.get("url", ""),
            "tags": fm.get("tags", []),
            "triggers": fm.get("triggers", []),
            "description": desc,
            "path": filepath,
        })
    return items


def list_marketplace(as_json=False):
    """Prints the marketplace dashboard."""
    instance_dir = get_active_instance_dir()
    instance_name = os.path.basename(instance_dir) if instance_dir else "nessuna"
    user_sources = get_user_sources(instance_dir)
    items = get_marketplace_sources()

    # Match user adoption
    active_count = 0
    for item in items:
        # Check if matched by filename or source_ref
        item_active = False
        active_areas = []
        for uf, uinfo in user_sources.items():
            if uf == item["file"] or (uinfo["source_ref"] and os.path.basename(uinfo["source_ref"]) == item["file"]):
                item_active = True
                active_areas = uinfo["areas"]
                break
        item["is_active"] = item_active
        item["active_areas"] = active_areas
        if item_active:
            active_count += 1

    if as_json:
        print(json.dumps({"instance": instance_name, "total": len(items), "active": active_count, "items": items}, indent=2, ensure_ascii=False))
        return

    print("")
    print(f"{BOLD}============================================================{NC}")
    print(f"{BOLD}       POS MARKETPLACE & ECOSYSTEM HUB                      {NC}")
    print(f"{BOLD}============================================================{NC}")
    print(f"  Istanza personale: {CYAN}{instance_name}{NC}")
    print(f"  Fonti a catalogo:  {BOLD}{len(items)}{NC} ({GREEN}{active_count} attive{NC}, {len(items) - active_count} disponibili)")
    print(f"  Catalogo Markdown: {DIM}knowledge/sources/INDEX.md{NC} (alias: {DIM}marketplace/{NC})")
    print("")

    categories = [
        ("data-source", "🏛️ DATA SOURCES & CORPUS NORMATIVI"),
        ("cli-tool", "🎓 CLI TOOLS & CONNETTORI"),
        ("mcp-server", "🔌 MCP SERVERS (Model Context Protocol)"),
        ("skill-mcp", "📢 SKILLS & AUTOMAZIONI SPECIALISTICHE"),
        ("blueprint", "🏗️ BLUEPRINTS & ARCHITETTURA"),
    ]

    for cat_key, cat_title in categories:
        cat_items = [it for it in items if it["category"] == cat_key]
        if not cat_items:
            continue
        print(f"{BOLD}{cat_title}{NC}")
        for it in cat_items:
            status_tag = f"{GREEN}[✓] ATTIVO{NC}" if it["is_active"] else f"{DIM}[ ] DISPONIBILE{NC}"
            print(f"  {status_tag} {BOLD}{it['name']}{NC} ({CYAN}{it['file']}{NC})")
            if it["description"]:
                print(f"      {DIM}{it['description'][:95]}...{NC}")
            if it["is_active"]:
                areas_str = ", ".join(it["active_areas"]) if it["active_areas"] else "generale"
                print(f"      {GREEN}↳ Aree collegate: {areas_str}{NC}")
            else:
                triggers_str = ", ".join(it["triggers"][:3])
                if triggers_str:
                    print(f"      {DIM}↳ Trigger: {triggers_str}...{NC}")
        print("")

    print(f"{BOLD}------------------------------------------------------------{NC}")
    print(f"  Per adottare una fonte nella tua istanza personale:")
    print(f"    • Chiedi al tuo assistente AI: {CYAN}\"Attiva <nome-fonte> nella mia area <area>\"{NC}")
    print(f"    • Oppure esamina i dettagli con: {CYAN}bash setup/marketplace.sh --info <nome>{NC}")
    print(f"{BOLD}============================================================{NC}")
    print("")


def show_info(item_query):
    """Shows full details of a specific marketplace source."""
    items = get_marketplace_sources()
    matched = None
    for it in items:
        if (
            it["file"].lower() == item_query.lower()
            or it["file"].replace(".md", "").lower() == item_query.lower()
            or it["id"].lower() == item_query.lower()
            or item_query.lower() in it["name"].lower()
        ):
            matched = it
            break

    if not matched:
        print(f"{RED}Errore: Nessun elemento trovato nel marketplace corrispondente a '{item_query}'{NC}")
        sys.exit(1)

    instance_dir = get_active_instance_dir()
    user_sources = get_user_sources(instance_dir)
    is_active = False
    areas = []
    for uf, uinfo in user_sources.items():
        if uf == matched["file"] or (uinfo["source_ref"] and os.path.basename(uinfo["source_ref"]) == matched["file"]):
            is_active = True
            areas = uinfo["areas"]
            break

    print("")
    print(f"{BOLD}============================================================{NC}")
    print(f"  SCHEDA MARKETPLACE: {BOLD}{matched['name']}{NC}")
    print(f"{BOLD}============================================================{NC}")
    print(f"  ID:          {CYAN}{matched['id']}{NC}")
    print(f"  File:        knowledge/sources/{matched['file']}")
    print(f"  Categoria:   {matched['category']} (type: {matched['type']})")
    print(f"  Stato:       {matched['status']}")
    print(f"  Adozione:    {GREEN}ATTIVO{NC} (aree: {', '.join(areas)})" if is_active else f"  Adozione:    {YELLOW}NON ANCORA ADOTTATO{NC}")
    if matched["url"]:
        print(f"  URL Riferim: {matched['url']}")
    if matched["tags"]:
        print(f"  Tag:         {', '.join(matched['tags'])}")

    if matched["triggers"]:
        print(f"\n{BOLD}Trigger Semantici di Attivazione:{NC}")
        for t in matched["triggers"]:
            print(f"    • {t}")

    print(f"\n{BOLD}Descrizione & Ruolo:{NC}")
    print(f"  {matched['description']}")

    print(f"\n{BOLD}Come Adottarlo nella tua Istanza:{NC}")
    print(f"  1. Chiedi al tuo assistente AI: {CYAN}\"Attiva {matched['file'].replace('.md', '')} nella mia area <area>\"{NC}")
    print(f"  2. Oppure crea il Thin Overlay in: {DIM}personal/<tua-istanza>/reference/sources/{matched['file']}{NC}")
    print(f"     contenente:")
    print(f"       ---")
    print(f"       name: {matched['name']}")
    print(f"       source_ref: knowledge/sources/{matched['file']}")
    print(f"       status: active")
    print(f"       areas: [<tue-aree>]")
    print(f"       ---")
    print(f"{BOLD}============================================================{NC}\n")


if __name__ == "__main__":
    if len(sys.argv) > 1:
        arg = sys.argv[1]
        if arg in ("--json", "-j"):
            list_marketplace(as_json=True)
        elif arg in ("--info", "-i") and len(sys.argv) > 2:
            show_info(sys.argv[2])
        elif arg.startswith("--info="):
            show_info(arg.split("=", 1)[1])
        elif arg in ("--help", "-h"):
            print("Uso: python3 setup/marketplace.py [--json | --info <id-o-nome>]")
        else:
            show_info(arg)
    else:
        list_marketplace(as_json=False)
