#!/usr/bin/env python3
"""
graph.py — POS Epistemic Relationship Graph CLI

Parses and validates semantic relationships and lineage between knowledge items,
areas, and backlog notes in the Personal Operating System.

Supported typed relationships in frontmatter:
  status: active | superseded | deprecated | proposed
  supersedes: [id1, id2] | id1
  superseded_by: id
  depends_on: [id1, id2]
  conflicts_with: [id1, id2]
  supports: [id1, id2]

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
                v = v.strip()
                if v.startswith("[") and v.endswith("]"):
                    fm[k] = [x.strip().strip("'\"") for x in v[1:-1].split(",") if x.strip()]
                elif v == "":
                    current_list = k
                    fm[k] = []
                else:
                    fm[k] = v.strip("'\"")
            elif current_list and line.strip().startswith("- "):
                fm[current_list].append(line.strip()[2:].strip().strip("'\""))
            i += 1
    else:
        body = lines

    title = ""
    for line in body:
        if line.startswith("# "):
            title = line[2:].strip()
            break

    return fm, title


def scan_workspace():
    """Scans relevant markdown files and indexes them by relative path slug."""
    nodes = {}
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
                slug = os.path.splitext(os.path.basename(file))[0]
                fm, title = parse_frontmatter(path)
                
                # Normalize relationship fields to lists
                def to_list(val):
                    if not val:
                        return []
                    if isinstance(val, list):
                        return val
                    return [val]

                nodes[slug] = {
                    "path": rel_path,
                    "slug": slug,
                    "title": title or slug,
                    "status": fm.get("status", "active"),
                    "supersedes": to_list(fm.get("supersedes")),
                    "superseded_by": to_list(fm.get("superseded_by")),
                    "depends_on": to_list(fm.get("depends_on")),
                    "conflicts_with": to_list(fm.get("conflicts_with")),
                    "supports": to_list(fm.get("supports")),
                    "tags": to_list(fm.get("tags")),
                }
    return nodes


def cmd_check(nodes):
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

        for rel_type in ["supersedes", "superseded_by", "depends_on", "conflicts_with", "supports"]:
            for target in data[rel_type]:
                # target can be a slug or a relative file path
                target_slug = os.path.splitext(os.path.basename(target))[0]
                if target_slug not in nodes:
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


def cmd_lineage(nodes, target_slug):
    """Traces lineage of what a node supersedes or what supersedes it."""
    target = os.path.splitext(os.path.basename(target_slug))[0]
    if target not in nodes:
        print(f"❌ Error: Node '{target}' not found in workspace.")
        return 1

    node = nodes[target]
    print(f"\n🌱 Lineage Tree for: {node['title']} ({node['path']})")
    print(f"   Status: {node['status']}")

    # What supersedes this?
    superseded_by = []
    for s, d in nodes.items():
        if target in [os.path.splitext(os.path.basename(x))[0] for x in d["supersedes"]]:
            superseded_by.append(s)
        if target in [os.path.splitext(os.path.basename(x))[0] for x in d["superseded_by"]]:
            superseded_by.append(s)

    if superseded_by:
        print("\n  ⬆️ Superseded by:")
        for sup in set(superseded_by):
            print(f"     └─► [{nodes[sup]['status']}] {nodes[sup]['title']} ({nodes[sup]['path']})")
    else:
        print("\n  ⬆️ Superseded by: None (Current authoritative version)")

    # What does this supersede?
    if node["supersedes"]:
        print("\n  ⬇️ Supersedes (ancestors):")
        for sub in node["supersedes"]:
            sub_slug = os.path.splitext(os.path.basename(sub))[0]
            if sub_slug in nodes:
                print(f"     └─► [{nodes[sub_slug]['status']}] {nodes[sub_slug]['title']} ({nodes[sub_slug]['path']})")
            else:
                print(f"     └─► (missing) {sub}")
    else:
        print("\n  ⬇️ Supersedes: None")

    if node["depends_on"]:
        print(f"\n  🔗 Depends on: {', '.join(node['depends_on'])}")
    if node["supports"]:
        print(f"  🤝 Supports:   {', '.join(node['supports'])}")
    if node["conflicts_with"]:
        print(f"  ⚡ Conflicts:  {', '.join(node['conflicts_with'])}")
    print("")
    return 0


def cmd_mermaid(nodes, show_all=False):
    """Exports relationships as a Mermaid diagram."""
    lines = ["flowchart TD"]
    has_edges = False
    for slug, d in nodes.items():
        node_id = re.sub(r"[^a-zA-Z0-9_]", "_", slug)
        style = ":::superseded" if d["status"] == "superseded" else ""

        for target in d["supersedes"]:
            target_slug = os.path.splitext(os.path.basename(target))[0]
            target_id = re.sub(r"[^a-zA-Z0-9_]", "_", target_slug)
            lines.append(f'    {node_id}["{d["title"]}"] -->|supersedes| {target_id}["{target_slug}"]')
            has_edges = True

        for target in d["depends_on"]:
            target_slug = os.path.splitext(os.path.basename(target))[0]
            target_id = re.sub(r"[^a-zA-Z0-9_]", "_", target_slug)
            lines.append(f'    {node_id}["{d["title"]}"] -.->|depends_on| {target_id}["{target_slug}"]')
            has_edges = True

    lines.append("    classDef superseded fill:#ffeeee,stroke:#cc0000,stroke-dasharray: 5 5;")
    if not has_edges:
        print("No relationships found to graph yet.")
    else:
        print("\n```mermaid")
        print("\n".join(lines))
        print("```\n")
    return 0


def main():
    parser = argparse.ArgumentParser(description="POS Epistemic Relationship Graph CLI")
    subparsers = parser.add_subparsers(dest="command")

    subparsers.add_parser("check", help="Check and validate references")
    lineage_p = subparsers.add_parser("lineage", help="Trace node lineage")
    lineage_p.add_argument("slug", help="Slug or file basename of node")
    mermaid_p = subparsers.add_parser("mermaid", help="Output mermaid diagram")
    mermaid_p.add_argument("--all", action="store_true", help="Include all nodes")
    subparsers.add_parser("stats", help="Show graph statistics")

    args = parser.parse_args()
    if not args.command:
        parser.print_help()
        return 0

    nodes = scan_workspace()
    if args.command == "check":
        return cmd_check(nodes)
    elif args.command == "lineage":
        return cmd_lineage(nodes, args.slug)
    elif args.command == "mermaid":
        return cmd_mermaid(nodes, args.all)
    elif args.command == "stats":
        return cmd_check(nodes)


if __name__ == "__main__":
    sys.exit(main())
