#!/usr/bin/env python3
"""
graph.py — POS Epistemic Relationship Graph CLI

Parses and validates semantic relationships and lineage between knowledge items,
areas, and backlog notes in the Personal Operating System.

Supported typed relationships in frontmatter:
  status: active | superseded | deprecated | proposed

  # Linear / Structural (Causality & Logic)
  supersedes: [id1, id2] | id1
  superseded_by: id
  depends_on: [id1, id2]
  conflicts_with: [id1, id2]
  supports: [id1, id2]

  # Correlative / Plural (Process & Balance)
  resonates_with: [id1, id2]   # Gan-Ying: sympathetic resonance cross-domain
  polar_balance: [id1, id2]    # Yin-Yang: complementary dynamic polarity
  nourishes: [id1, id2]        # Wuxing Sheng: generative & nourishing flow
  moderates: [id1, id2]        # Wuxing Ke: regulative & homeostatic constraint

Usage:
  python3 setup/graph.py check
  python3 setup/graph.py lineage <slug>
  python3 setup/graph.py mermaid [--all]
  python3 setup/graph.py stats
"""

import os
import sys
import glob
import re
import argparse

WORKSPACE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

# Directories scanned for epistemic notes
SCAN_DIRS = ["knowledge", "areas", "backlog/items", "reference/sources"]

# Linear / Structural relationships (Western logic & causality)
LINEAR_REL_TYPES = [
    "supersedes",
    "superseded_by",
    "depends_on",
    "conflicts_with",
    "supports",
]

# Correlative / Plural relationships (Eastern & process philosophy)
PROCESS_REL_TYPES = [
    "resonates_with",
    "polar_balance",
    "nourishes",
    "moderates",
]

ALL_REL_TYPES = LINEAR_REL_TYPES + PROCESS_REL_TYPES


def strip_comment(text):
    """Strips trailing YAML comments while respecting quotes."""
    in_quote = False
    quote_char = None
    res = []
    for char in text:
        if char in ("'", '"'):
            if not in_quote:
                in_quote = True
                quote_char = char
            elif quote_char == char:
                in_quote = False
                quote_char = None
        elif char == '#' and not in_quote:
            break
        res.append(char)
    return "".join(res).strip()


def parse_frontmatter(filepath):
    """Simple parser for YAML frontmatter without external dependencies."""
    fm = {}
    try:
        with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
    except Exception:
        return fm, ""

    lines = content.split("\n")
    body = []
    if lines and lines[0].strip() == "---":
        i = 1
        current_list = None
        while i < len(lines):
            line = lines[i]
            if line.strip() == "---":
                body = lines[i + 1 :]
                break
            if re.match(r"^[a-zA-Z0-9_-]+:", line):
                current_list = None
                k, v = line.split(":", 1)
                k = k.strip()
                v = strip_comment(v)
                if v.startswith("[") and v.endswith("]"):
                    fm[k] = [strip_comment(x).strip("'\"") for x in v[1:-1].split(",") if strip_comment(x).strip("'\"")]
                elif v == "":
                    current_list = k
                    fm[k] = []
                else:
                    fm[k] = v.strip("'\"")
            elif current_list and line.strip().startswith("- "):
                val = strip_comment(line.strip()[2:]).strip("'\"")
                if val:
                    fm[current_list].append(val)
            i += 1
    else:
        body = lines

    title = ""
    for line in body:
        if line.startswith("# "):
            title = line[2:].strip()
            break

    return fm, title


def get_slug_and_aliases(rel_path):
    """Generates unique primary slug and friendly aliases for workspace files."""
    parts = rel_path.split(os.sep)
    filename = parts[-1]
    basename = os.path.splitext(filename)[0]
    aliases = [rel_path, os.path.splitext(rel_path)[0]]

    if rel_path.startswith("areas/"):
        if len(parts) >= 3:
            area = parts[1]
            if filename == "context.md":
                return f"area-{area}", aliases + [area, f"{area}-context", f"area-{area}"]
            elif filename == "STATUS.md":
                return f"status-{area}", aliases + [f"{area}-status", f"status-{area}"]
            elif len(parts) >= 4 and parts[2] == "specs":
                return f"spec-{basename}", aliases + [f"specs/{basename}", f"{area}/{basename}", basename]
            elif len(parts) >= 4 and parts[2] == "worklog":
                return f"worklog-{basename}", aliases + [f"worklog/{basename}", basename]
    elif rel_path.startswith("backlog/items/"):
        return basename, aliases + [f"backlog/{basename}", f"backlog/items/{basename}"]
    elif rel_path.startswith("reference/sources/"):
        return f"source-{basename}", aliases + [basename, f"reference/sources/{basename}"]
    elif rel_path.startswith("knowledge/sources/"):
        return f"catalog-{basename}", aliases + [f"sources/{basename}", f"knowledge/sources/{basename}"]

    return basename, aliases + [basename]


def scan_workspace():
    """Scans relevant markdown files and indexes them by primary slug with alias map."""
    nodes = {}
    alias_map = {}

    for rel_dir in SCAN_DIRS:
        full_dir = os.path.join(WORKSPACE_DIR, rel_dir)
        if not os.path.isdir(full_dir):
            continue
        for root, _, files in os.walk(full_dir):
            for file in files:
                if not file.endswith(".md"):
                    continue
                path = os.path.join(root, file)
                rel_path = os.path.relpath(path, WORKSPACE_DIR)
                primary_slug, aliases = get_slug_and_aliases(rel_path)
                fm, title = parse_frontmatter(path)
                
                # Normalize relationship fields to lists
                def to_list(val):
                    if not val:
                        return []
                    if isinstance(val, list):
                        return val
                    return [val]

                nodes[primary_slug] = {
                    "path": rel_path,
                    "slug": primary_slug,
                    "title": title or primary_slug,
                    "status": fm.get("status", "active"),
                    "supersedes": to_list(fm.get("supersedes")),
                    "superseded_by": to_list(fm.get("superseded_by")),
                    "depends_on": to_list(fm.get("depends_on")),
                    "conflicts_with": to_list(fm.get("conflicts_with")),
                    "supports": to_list(fm.get("supports")),
                    "resonates_with": to_list(fm.get("resonates_with")),
                    "polar_balance": to_list(fm.get("polar_balance")),
                    "nourishes": to_list(fm.get("nourishes")),
                    "moderates": to_list(fm.get("moderates")),
                    "tags": to_list(fm.get("tags")),
                }

                for a in aliases:
                    if a not in alias_map:
                        alias_map[a] = primary_slug

    return nodes, alias_map


def resolve_target(target, nodes, alias_map):
    """Resolves a target reference (slug, alias, or file path) to a primary node slug."""
    if not target:
        return None
    t = str(target).strip()
    if t in nodes:
        return t
    if t in alias_map:
        return alias_map[t]
    base = os.path.splitext(os.path.basename(t))[0]
    if base in nodes:
        return base
    if base in alias_map:
        return alias_map[base]
    if f"area-{base}" in nodes:
        return f"area-{base}"
    if base.startswith("area-") and base[5:] in alias_map:
        return alias_map[base[5:]]
    return None


def cmd_check(nodes, alias_map):
    """Validates references and checks for dangling links or cycles."""
    print("\n🔍 POS Epistemic Graph — Link & Consistency Audit\n")
    dangling = []
    active_count = 0
    superseded_count = 0

    for slug, data in nodes.items():
        if data["status"] == "superseded":
            superseded_count += 1
        else:
            active_count += 1

        for rel_type in ALL_REL_TYPES:
            for target in data[rel_type]:
                resolved = resolve_target(target, nodes, alias_map)
                if not resolved:
                    dangling.append((slug, data["path"], rel_type, target))

    print(f"  • Total scanned nodes:     {len(nodes)}")
    print(f"  • Active nodes:            {active_count}")
    print(f"  • Superseded nodes:        {superseded_count}")
    print(f"  • Dangling references:     {len(dangling)}")

    if dangling:
        print("\n⚠️ Dangling references detected:")
        for source_slug, path, rel_type, target in dangling:
            print(f"    - {path}: {rel_type} -> '{target}' (target not found in workspace)")
        return 1
    else:
        print("\n✅ All epistemic relationships are valid and resolved!\n")
        return 0


def cmd_lineage(nodes, alias_map, target_input):
    """Traces lineage, polarities, and ecological relationships of a node."""
    target = resolve_target(target_input, nodes, alias_map)
    if not target or target not in nodes:
        print(f"❌ Error: Node '{target_input}' not found in workspace.")
        return 1

    node = nodes[target]
    print(f"\n🌱 Epistemic Profile for: {node['title']} ({node['path']})")
    print(f"   Slug: {node['slug']} | Status: {node['status']}")

    def format_target(s):
        if s in nodes:
            return f"[{nodes[s]['status']}] {nodes[s]['title']} ({nodes[s]['path']})"
        return f"(missing) {s}"

    # 1. Lineage & Succession
    superseded_by = []
    for s, d in nodes.items():
        if target in [resolve_target(x, nodes, alias_map) for x in d["supersedes"]]:
            superseded_by.append(s)
        if target in [resolve_target(x, nodes, alias_map) for x in d["superseded_by"]]:
            superseded_by.append(s)

    if superseded_by:
        print("\n  ⬆️ Superseded by:")
        for sup in set(superseded_by):
            print(f"     └─► {format_target(sup)}")
    else:
        print("\n  ⬆️ Superseded by: None (Current authoritative version)")

    if node["supersedes"]:
        print("\n  ⬇️ Supersedes (ancestors):")
        for sub in node["supersedes"]:
            sub_slug = resolve_target(sub, nodes, alias_map)
            print(f"     └─► {format_target(sub_slug)}")

    # 2. Linear & Causal Relationships
    if node["depends_on"]:
        resolved_deps = [resolve_target(x, nodes, alias_map) or x for x in node["depends_on"]]
        print(f"\n  🔗 Depends on:   {', '.join(resolved_deps)}")
    
    depended_on_by = [s for s, d in nodes.items() if target in [resolve_target(x, nodes, alias_map) for x in d["depends_on"]]]
    if depended_on_by:
        print(f"  🧲 Prerequisite for: {', '.join(depended_on_by)}")

    if node["supports"]:
        resolved_supps = [resolve_target(x, nodes, alias_map) or x for x in node["supports"]]
        print(f"  🤝 Supports:     {', '.join(resolved_supps)}")

    supported_by = [s for s, d in nodes.items() if target in [resolve_target(x, nodes, alias_map) for x in d["supports"]]]
    if supported_by:
        print(f"  🛡️ Supported by: {', '.join(supported_by)}")

    incoming_conflicts = [s for s, d in nodes.items() if target in [resolve_target(x, nodes, alias_map) for x in d["conflicts_with"]]]
    conflicts = list(set([resolve_target(x, nodes, alias_map) or x for x in node["conflicts_with"]] + incoming_conflicts))
    if conflicts:
        print(f"  ⚡ Conflicts:    {', '.join(conflicts)}")

    # 3. Correlative & Process Relationships
    incoming_polar = [s for s, d in nodes.items() if target in [resolve_target(x, nodes, alias_map) for x in d["polar_balance"]]]
    polar = list(set([resolve_target(x, nodes, alias_map) or x for x in node["polar_balance"]] + incoming_polar))
    if polar:
        print(f"\n  ☯️ Polar Balance (Yin-Yang): {', '.join(polar)}")

    incoming_resonances = [s for s, d in nodes.items() if target in [resolve_target(x, nodes, alias_map) for x in d["resonates_with"]]]
    resonances = list(set([resolve_target(x, nodes, alias_map) or x for x in node["resonates_with"]] + incoming_resonances))
    if resonances:
        print(f"  🔔 Resonates With (Gan-Ying): {', '.join(resonances)}")

    if node["nourishes"]:
        resolved_nourishes = [resolve_target(x, nodes, alias_map) or x for x in node["nourishes"]]
        print(f"  💧 Nourishes (Sheng):         {', '.join(resolved_nourishes)}")
    nourished_by = [s for s, d in nodes.items() if target in [resolve_target(x, nodes, alias_map) for x in d["nourishes"]]]
    if nourished_by:
        print(f"  🌾 Nourished by:              {', '.join(nourished_by)}")

    if node["moderates"]:
        resolved_moderates = [resolve_target(x, nodes, alias_map) or x for x in node["moderates"]]
        print(f"  ⚖️ Moderates (Ke):            {', '.join(resolved_moderates)}")
    moderated_by = [s for s, d in nodes.items() if target in [resolve_target(x, nodes, alias_map) for x in d["moderates"]]]
    if moderated_by:
        print(f"  🛑 Moderated by:              {', '.join(moderated_by)}")

    print("")
    return 0


def cmd_mermaid(nodes, alias_map, show_all=False):
    """Exports relationships as a Mermaid diagram."""
    lines = ["flowchart TD"]
    has_edges = False
    drawn_pairs = set()

    for slug, d in nodes.items():
        node_id = re.sub(r"[^a-zA-Z0-9_]", "_", slug)

        # 1. Linear
        for target in d["supersedes"]:
            target_slug = resolve_target(target, nodes, alias_map)
            if not target_slug:
                continue
            target_id = re.sub(r"[^a-zA-Z0-9_]", "_", target_slug)
            lines.append(f'    {node_id}["{d["title"]}"] -->|supersedes| {target_id}["{nodes[target_slug]["title"]}"]')
            has_edges = True

        for target in d["depends_on"]:
            target_slug = resolve_target(target, nodes, alias_map)
            if not target_slug:
                continue
            target_id = re.sub(r"[^a-zA-Z0-9_]", "_", target_slug)
            lines.append(f'    {node_id}["{d["title"]}"] -.->|depends_on| {target_id}["{nodes[target_slug]["title"]}"]')
            has_edges = True

        for target in d["supports"]:
            target_slug = resolve_target(target, nodes, alias_map)
            if not target_slug:
                continue
            target_id = re.sub(r"[^a-zA-Z0-9_]", "_", target_slug)
            lines.append(f'    {node_id}["{d["title"]}"] -->|supports| {target_id}["{nodes[target_slug]["title"]}"]')
            has_edges = True

        for target in d["conflicts_with"]:
            target_slug = resolve_target(target, nodes, alias_map)
            if not target_slug:
                continue
            target_id = re.sub(r"[^a-zA-Z0-9_]", "_", target_slug)
            pair = tuple(sorted([node_id, target_id]))
            if ("conflicts", pair) not in drawn_pairs:
                drawn_pairs.add(("conflicts", pair))
                lines.append(f'    {node_id}["{d["title"]}"] x--x|conflicts| {target_id}["{nodes[target_slug]["title"]}"]')
                has_edges = True

        # 2. Process & Correlative
        for target in d["polar_balance"]:
            target_slug = resolve_target(target, nodes, alias_map)
            if not target_slug:
                continue
            target_id = re.sub(r"[^a-zA-Z0-9_]", "_", target_slug)
            pair = tuple(sorted([node_id, target_id]))
            if ("polar", pair) not in drawn_pairs:
                drawn_pairs.add(("polar", pair))
                lines.append(f'    {node_id}["{d["title"]}"] <==>|polar| {target_id}["{nodes[target_slug]["title"]}"]')
                has_edges = True

        for target in d["resonates_with"]:
            target_slug = resolve_target(target, nodes, alias_map)
            if not target_slug:
                continue
            target_id = re.sub(r"[^a-zA-Z0-9_]", "_", target_slug)
            pair = tuple(sorted([node_id, target_id]))
            if ("resonates", pair) not in drawn_pairs:
                drawn_pairs.add(("resonates", pair))
                lines.append(f'    {node_id}["{d["title"]}"] <-.->|resonates| {target_id}["{nodes[target_slug]["title"]}"]')
                has_edges = True

        for target in d["nourishes"]:
            target_slug = resolve_target(target, nodes, alias_map)
            if not target_slug:
                continue
            target_id = re.sub(r"[^a-zA-Z0-9_]", "_", target_slug)
            lines.append(f'    {node_id}["{d["title"]}"] ==>|nourishes| {target_id}["{nodes[target_slug]["title"]}"]')
            has_edges = True

        for target in d["moderates"]:
            target_slug = resolve_target(target, nodes, alias_map)
            if not target_slug:
                continue
            target_id = re.sub(r"[^a-zA-Z0-9_]", "_", target_slug)
            lines.append(f'    {node_id}["{d["title"]}"] -.->|moderates| {target_id}["{nodes[target_slug]["title"]}"]')
            has_edges = True

    lines.append("    classDef superseded fill:#ffeeee,stroke:#cc0000,stroke-dasharray: 5 5;")
    if not has_edges:
        print("No relationships found to graph yet.")
    else:
        print("\n```mermaid")
        print("\n".join(lines))
        print("```\n")
    return 0


def cmd_stats(nodes, alias_map):
    """Shows comprehensive graph topology and relationship counts."""
    print("\n📊 POS Epistemic Graph — Statistics & Topology\n")
    
    status_counts = {}
    rel_counts = {r: 0 for r in ALL_REL_TYPES}
    node_degree = {s: 0 for s in nodes}

    for s, d in nodes.items():
        st = d["status"]
        status_counts[st] = status_counts.get(st, 0) + 1
        for r in ALL_REL_TYPES:
            c = len(d[r])
            rel_counts[r] += c
            node_degree[s] += c

    print(f"  • Total Scanned Nodes:     {len(nodes)}")
    for st, cnt in sorted(status_counts.items()):
        print(f"    - Status '{st}': {cnt}")

    print("\n  • Linear & Causal Relationships (Western Logic):")
    for r in LINEAR_REL_TYPES:
        print(f"    - {r:<15}: {rel_counts[r]}")

    print("\n  • Correlative & Process Relationships (Plural / Eastern):")
    for r in PROCESS_REL_TYPES:
        print(f"    - {r:<15}: {rel_counts[r]}")

    top_nodes = sorted(node_degree.items(), key=lambda x: x[1], reverse=True)[:5]
    if top_nodes and top_nodes[0][1] > 0:
        print("\n  • Most Connected Nodes (Epistemic Hubs):")
        for slug, deg in top_nodes:
            if deg > 0:
                print(f"    - {slug} ({deg} connections)")
    print("")
    return 0


def main():
    parser = argparse.ArgumentParser(description="POS Epistemic Relationship Graph CLI")
    subparsers = parser.add_subparsers(dest="command")

    subparsers.add_parser("check", help="Check and validate references")
    lineage_p = subparsers.add_parser("lineage", help="Trace node lineage and relationships")
    lineage_p.add_argument("slug", help="Slug, alias, or file path of node")
    mermaid_p = subparsers.add_parser("mermaid", help="Output mermaid diagram")
    mermaid_p.add_argument("--all", action="store_true", help="Include all nodes")
    subparsers.add_parser("stats", help="Show graph statistics and topology")

    args = parser.parse_args()
    if not args.command:
        parser.print_help()
        return 0

    nodes, alias_map = scan_workspace()
    if args.command == "check":
        return cmd_check(nodes, alias_map)
    elif args.command == "lineage":
        return cmd_lineage(nodes, alias_map, args.slug)
    elif args.command == "mermaid":
        return cmd_mermaid(nodes, alias_map, args.all)
    elif args.command == "stats":
        return cmd_stats(nodes, alias_map)


if __name__ == "__main__":
    sys.exit(main())
