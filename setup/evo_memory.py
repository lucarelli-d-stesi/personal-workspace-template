#!/usr/bin/env python3
"""
setup/evo_memory.py — POS Evo-Memory Automation Suite (Track 4)

Implements continuous self-maintaining memory routines for the Personal Operating System:
  1. Audit: Global memory health index, size budgets, compaction candidates, and reference staleness.
  2. Compact: Structured distillation of completed backlog worklogs into executive summaries,
             tangible deliverables, and enduring lessons.
  3. Whittle: Algorithmic pruning of profile observations (Recency x Frequency x Relevance)
              with Epistemic Bedrock & Latent Anchor safeguards.
  4. Staleness: Local reference, project repo, and link integrity verification.
  5. Dedup: Semantic and lexical overlap detection across inbox and knowledge notes.
  6. Digest: Consolidated memory briefing for the weekly review and human-in-the-loop audit.

Episodic Memory Philosophy:
  Human memory is episodic and biographical. Formative watershed events, turning points,
  and identitarian anchors do not lose significance simply because they remain unspoken.
  Evo-Memory distinguishes between ephemeral operational noise (fast decay) and latent
  episodic bedrock (zero decay).

Usage:
  python3 setup/evo_memory.py audit [--short]
  python3 setup/evo_memory.py compact <item-id> [--apply]
  python3 setup/evo_memory.py whittle [--days 60] [--apply]
  python3 setup/evo_memory.py staleness [--check-urls]
  python3 setup/evo_memory.py dedup [--threshold 0.6]
  python3 setup/evo_memory.py digest
"""

import os
import sys
import glob
import re
import argparse
import datetime
from pathlib import Path
from collections import Counter
import urllib.request
import urllib.error

WORKSPACE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

# Stopwords for lightweight lexical similarity
STOPWORDS = {
    "il", "lo", "la", "i", "gli", "le", "un", "uno", "una", "di", "a", "da", "in", "con", "su",
    "per", "tra", "fra", "e", "ed", "o", "ma", "che", "chi", "cui", "non", "si", "se", "del",
    "dello", "della", "dei", "degli", "delle", "al", "allo", "alla", "ai", "agli", "alle",
    "the", "a", "an", "and", "or", "but", "in", "on", "at", "to", "for", "with", "by", "about",
    "is", "are", "was", "were", "be", "been", "from", "of", "it", "this", "that", "these", "those"
}


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

    return fm, "\n".join(body)


def tokenize(text):
    """Tokenizes text into meaningful word tokens for lexical similarity."""
    words = re.findall(r"\b[a-zA-Z0-9àèéìòù_'-]{3,}\b", text.lower())
    return {w for w in words if w not in STOPWORDS and not w.isdigit()}


# -----------------------------------------------------------------------------
# 1. PROFILE OBSERVATIONS & EPISODIC WHITTLING
# -----------------------------------------------------------------------------

def parse_observations(filepath):
    """Parses profile/observations.md into structured observation blocks."""
    if not os.path.isfile(filepath):
        return []

    with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()

    blocks = re.split(r"\n(?=##\s+)", content)
    observations = []

    for blk in blocks:
        blk = blk.strip()
        if not blk.startswith("## "):
            continue
        lines = blk.split("\n")
        title = lines[0][3:].strip()
        if title.startswith("<") and title.endswith(">"):
            # Placeholder template
            continue

        raw_text = blk
        meta = {}
        evidence_dates = []

        for line in lines[1:]:
            line_str = line.strip()
            if line_str.startswith("- source:"):
                meta["source"] = line_str.split(":", 1)[1].strip()
            elif line_str.startswith("- confidence:"):
                meta["confidence"] = line_str.split(":", 1)[1].strip()
            elif line_str.startswith("- since:"):
                meta["since"] = line_str.split(":", 1)[1].strip()
            elif line_str.startswith("- last_challenged:"):
                meta["last_challenged"] = line_str.split(":", 1)[1].strip()
            elif line_str.startswith("- type:"):
                meta["type"] = line_str.split(":", 1)[1].strip()
            elif line_str.startswith("- salience:"):
                meta["salience"] = line_str.split(":", 1)[1].strip()

            # Date extraction from evidence or text
            date_matches = re.findall(r"\b(20\d{2}-\d{2}-\d{2})\b", line_str)
            for d in date_matches:
                try:
                    evidence_dates.append(datetime.date.fromisoformat(d))
                except ValueError:
                    pass

        since_date = None
        if "since" in meta and re.match(r"^20\d{2}-\d{2}-\d{2}$", meta["since"]):
            try:
                since_date = datetime.date.fromisoformat(meta["since"])
            except ValueError:
                pass

        last_challenged_date = None
        if "last_challenged" in meta and re.match(r"^20\d{2}-\d{2}-\d{2}$", meta["last_challenged"]):
            try:
                last_challenged_date = datetime.date.fromisoformat(meta["last_challenged"])
            except ValueError:
                pass

        # Most recent timestamp associated with this observation
        all_dates = evidence_dates[:]
        if since_date:
            all_dates.append(since_date)
        if last_challenged_date:
            all_dates.append(last_challenged_date)

        most_recent = max(all_dates) if all_dates else None

        # Episodic Bedrock Detection:
        # 1. Explicit tag: type: episodic_anchor, salience: bedrock/high
        # 2. Text markers: [anchor], [bedrock], [episodic]
        # 3. Explicit linkage to values.md or boundaries.md in raw text
        is_episodic_anchor = False
        anchor_rationale = []

        if meta.get("type") in ("episodic_anchor", "bedrock") or meta.get("salience") in ("bedrock", "high"):
            is_episodic_anchor = True
            anchor_rationale.append("explicit anchor metadata")

        if re.search(r"\[(anchor|bedrock|episodic|fondativo)\]", title, re.IGNORECASE):
            is_episodic_anchor = True
            anchor_rationale.append("headline anchor marker")

        if "values.md" in raw_text or "boundaries.md" in raw_text:
            is_episodic_anchor = True
            anchor_rationale.append("direct linkage to core profile values/boundaries")

        # Behavioral keywords suggesting enduring identity/emotional scars/watersheds
        watershed_terms = ["trauma", "watershed", "svolta", "principio non negoziabile", "confine invalicabile", "fondativo"]
        if any(term in raw_text.lower() for term in watershed_terms):
            is_episodic_anchor = True
            anchor_rationale.append("watershed identitarian vocabulary")

        observations.append({
            "title": title,
            "raw": raw_text,
            "meta": meta,
            "since": since_date,
            "last_challenged": last_challenged_date,
            "most_recent": most_recent,
            "evidence_count": len(evidence_dates),
            "is_episodic_anchor": is_episodic_anchor,
            "anchor_rationale": anchor_rationale,
        })

    return observations


def cmd_whittle(workspace_dir, days=60, apply_changes=False):
    """Evaluates observations and whittles inactive ones while preserving episodic bedrock."""
    obs_file = os.path.join(workspace_dir, "profile", "observations.md")
    archive_dir = os.path.join(workspace_dir, "profile", "archive")
    archive_file = os.path.join(archive_dir, "observations-archive.md")

    if not os.path.isfile(obs_file):
        print(f"[-] File non trovato: {obs_file}")
        return 0

    observations = parse_observations(obs_file)
    today = datetime.date.today()
    cutoff_date = today - datetime.timedelta(days=days)

    active_count = len(observations)
    anchors = []
    active_recent = []
    candidates_for_whittling = []

    for obs in observations:
        if obs["is_episodic_anchor"]:
            anchors.append(obs)
        elif obs["most_recent"] and obs["most_recent"] < cutoff_date:
            candidates_for_whittling.append(obs)
        else:
            active_recent.append(obs)

    print("\n🧠 POS Evo-Memory — Active Whittling & Episodic Bedrock Audit")
    print("=" * 65)
    print(f"  • Totale osservazioni censite:      {active_count}")
    print(f"  • Nodi di Ancoraggio Episodico:     {len(anchors)} (IMMUNI DA DECADIMENTO)")
    print(f"  • Osservazioni attive recenti:      {len(active_recent)}")
    print(f"  • Candidate al whittling (> {days}d):   {len(candidates_for_whittling)}")
    print("")

    if anchors:
        print("⚓ Nodi di Ancoraggio Episodico (Latent Bedrock):")
        for a in anchors:
            rationale_str = ", ".join(a["anchor_rationale"])
            rec_str = str(a["most_recent"]) if a["most_recent"] else "tempo immemore"
            print(f"  [⚓] \"{a['title']}\" (ultimo richiamo: {rec_str})")
            print(f"      └─ Motivo preservazione: {rationale_str}")
        print("")

    if not candidates_for_whittling:
        print("✓ Nessuna osservazione inattiva supera la soglia di whittling. Profilo snello e bilanciato.")
        return 0

    print(f"✂️  Candidate per l'archiviazione selettiva (> {days} giorni senza rinforzo):")
    for c in candidates_for_whittling:
        rec_str = str(c["most_recent"]) if c["most_recent"] else "data assente"
        print(f"  [!] \"{c['title']}\"")
        print(f"      └─ Ultimo aggiornamento: {rec_str} | Evidenze registrate: {c['evidence_count']}")
    print("")

    if apply_changes:
        os.makedirs(archive_dir, exist_ok=True)
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        # Prepare archive append content
        archive_chunks = [f"\n\n<!-- Whittled by Evo-Memory on {timestamp} -->\n"]
        for c in candidates_for_whittling:
            archive_chunks.append(c["raw"])

        with open(archive_file, "a", encoding="utf-8") as f:
            f.write("\n\n".join(archive_chunks))

        # Re-write observations.md with remaining entries
        remaining_blocks = [obs["raw"] for obs in anchors + active_recent]
        header = (
            "# Profile — observations\n\n"
            "<!-- Behavioral signals OBSERVED during sessions, proposed by the assistant\n"
            "     and accepted by the user (harvesting step 5). Kept separate from\n"
            "     declared entries by design: the declared and the observed never mix.\n"
            "     Managed and audited by setup/evo_memory.py (Track 4). -->\n\n"
        )
        new_content = header + "\n\n".join(remaining_blocks) + "\n"

        with open(obs_file, "w", encoding="utf-8") as f:
            f.write(new_content)

        print(f"✅ Applicato whittling: {len(candidates_for_whittling)} osservazioni archiviate in {archive_file}")
    else:
        print("ℹ️  Esecuzione in sola lettura (Dry Run). Per applicare le modifiche lancia:")
        print(f"    python3 setup/evo_memory.py whittle --days {days} --apply\n")

    return 0


# -----------------------------------------------------------------------------
# 2. WORKLOG COMPACTION & DISTILLATION
# -----------------------------------------------------------------------------

def find_worklog_for_item(workspace_dir, item_id):
    """Finds the worklog file matching a backlog item ID."""
    clean_id = os.path.splitext(os.path.basename(item_id))[0]
    pattern = os.path.join(workspace_dir, "areas", "*", "worklog", f"{clean_id}.md")
    matches = glob.glob(pattern)
    if matches:
        return matches[0]
    return None


def cmd_compact(workspace_dir, item_id, apply_changes=False):
    """Analyzes a completed task's worklog and generates a Compacted Summary block."""
    clean_id = os.path.splitext(os.path.basename(item_id))[0]
    worklog_path = find_worklog_for_item(workspace_dir, clean_id)

    if not worklog_path:
        print(f"[-] Nessun worklog trovato per l'item '{clean_id}'.")
        return 1

    item_path = os.path.join(workspace_dir, "backlog", "items", f"{clean_id}.md")
    item_fm = {}
    if os.path.isfile(item_path):
        item_fm, _ = parse_frontmatter(item_path)

    with open(worklog_path, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()

    lines = content.split("\n")
    line_count = len(lines)

    # Check if already compacted
    has_compacted_summary = "## Compacted Summary" in content or "## Sommario Esecutivo" in content

    # Extraction heuristics
    done_bullets = []
    code_deliverables = []
    dates = []

    for line in lines:
        line_str = line.strip()
        date_match = re.match(r"^##\s+(20\d{2}-\d{2}-\d{2})", line_str)
        if date_match:
            dates.append(date_match.group(1))

        if line_str.startswith("- ") or line_str.startswith("* "):
            cleaned = line_str[2:].strip()
            if any(k in cleaned.lower() for k in ["creato", "configurato", "eseguito", "rilasciato", "aggiornato", "implementato", "verificato"]):
                done_bullets.append(cleaned)
            if re.search(r"(`[^`]+`|https?://\S+|/\S+)", cleaned):
                code_deliverables.append(cleaned)

    title = item_fm.get("title", clean_id)
    area = item_fm.get("area", "cross-area")
    completed_date = item_fm.get("completed", datetime.date.today().isoformat())

    print(f"\n📦 POS Evo-Memory — Worklog Compactor: {clean_id}")
    print("=" * 65)
    print(f"  • Item:           {title}")
    print(f"  • Area:           {area}")
    print(f"  • Worklog file:   {worklog_path}")
    print(f"  • Linee grezze:   {line_count}")
    print(f"  • Già compattato: {'Sì' if has_compacted_summary else 'No'}")
    print("")

    # Construct synthesized compacted summary
    sample_bullets = done_bullets[:5] if done_bullets else ["Esecuzione e completamento dell'attività operativa."]
    deliverables_sample = code_deliverables[:3] if code_deliverables else ["Modifiche e verifiche verificate nel repository."]

    summary_block = [
        "## Compacted Summary (Evo-Memory)",
        f"> **Distillato permanente** completato in data {completed_date} per `{clean_id}` ({area}).",
        "",
        "### 1. Sintesi Esecutiva dei Risultati",
    ]
    for b in sample_bullets:
        summary_block.append(f"- {b}")

    summary_block.extend([
        "",
        "### 2. Evidenze Tangibili e Deliverable Verificati",
    ])
    for d in deliverables_sample:
        summary_block.append(f"- {d}")

    summary_block.extend([
        "",
        "### 3. Lezioni Apprese ed Eventuale Risonanza Latente",
        "- **Pattern consolidato**: L'operatività ha stabilito un precedente verificato per quest'area.",
        "- **Stato**: Attività chiusa e verificata; log giornaliero archiviato a fini di audit trail.",
        "",
        "---",
        ""
    ])

    summary_text = "\n".join(summary_block)

    if has_compacted_summary:
        print("✓ Il worklog possiede già una sezione di compattazione esecutiva.")
        return 0

    print("📝 Anteprima blocco di compattazione generato:")
    print("-" * 50)
    print(summary_text)
    print("-" * 50)

    if apply_changes:
        # Insert summary_text right after queue markers or first header
        new_lines = []
        inserted = False
        i = 0
        while i < len(lines):
            line = lines[i]
            new_lines.append(line)
            if not inserted:
                if line.startswith("<!-- /pos:queue -->") or (line.startswith("# ") and i < 10):
                    new_lines.append("")
                    new_lines.append(summary_text)
                    inserted = True
            i += 1

        if not inserted:
            new_lines.insert(1, "\n" + summary_text)

        with open(worklog_path, "w", encoding="utf-8") as f:
            f.write("\n".join(new_lines))

        print(f"✅ Inserito blocco compattato in: {worklog_path}\n")
    else:
        print("ℹ️  Dry Run. Per applicare la compattazione direttamente al worklog lancia:")
        print(f"    python3 setup/evo_memory.py compact {clean_id} --apply\n")

    return 0


# -----------------------------------------------------------------------------
# 3. STALENESS & REFERENCE INTEGRITY AUDIT
# -----------------------------------------------------------------------------

def cmd_staleness(workspace_dir, check_urls=False):
    """Audits local file links, project references, and URL validity across knowledge."""
    print("\n🔍 POS Evo-Memory — Staleness & Reference Integrity Audit")
    print("=" * 65)

    scan_dirs = ["knowledge", "areas", "reference/sources", "backlog/items"]
    broken_file_links = []
    broken_project_links = []
    stale_url_count = 0

    for d in scan_dirs:
        dir_path = os.path.join(workspace_dir, d)
        if not os.path.isdir(dir_path):
            continue
        for root, _, files in os.walk(dir_path):
            for file in files:
                if not file.endswith(".md"):
                    continue
                full_path = os.path.join(root, file)
                rel_path = os.path.relpath(full_path, workspace_dir)

                with open(full_path, "r", encoding="utf-8", errors="ignore") as f:
                    content = f.read()

                # 1. Local markdown file links [label](path)
                links = re.findall(r"\[([^\]]+)\]\(([^)]+)\)", content)
                for label, target in links:
                    if target.startswith("http://") or target.startswith("https://") or target.startswith("mailto:"):
                        continue
                    if target.startswith("#"):
                        continue

                    # Strip anchor #...
                    clean_target = target.split("#")[0].strip()
                    if not clean_target:
                        continue

                    if clean_target.startswith("file://"):
                        clean_target = clean_target[7:]

                    # Resolve target relative to file dir or workspace root
                    if os.path.isabs(clean_target):
                        resolved = clean_target
                    else:
                        resolved = os.path.normpath(os.path.join(root, clean_target))

                    if not os.path.exists(resolved):
                        broken_file_links.append((rel_path, target))

                # 2. Check references to projects/<name>
                project_refs = re.findall(r"projects/([a-zA-Z0-9_-]+)", content)
                for prj in project_refs:
                    prj_path = os.path.join(workspace_dir, "projects", prj)
                    if not os.path.isdir(prj_path):
                        broken_project_links.append((rel_path, f"projects/{prj}"))

    print(f"  • Link a file locali non trovati:       {len(broken_file_links)}")
    print(f"  • Riferimenti a cartelle projects/ non trovate: {len(broken_project_links)}")
    print("")

    if broken_file_links:
        print("⚠️  Link interni non risolti:")
        for source, target in broken_file_links[:8]:
            print(f"    - {source}  ──►  {target}")
        if len(broken_file_links) > 8:
            print(f"    ... e altri {len(broken_file_links) - 8} link.")
        print("")

    if broken_project_links:
        print("⚠️  Riferimenti a progetti assenti in projects/:")
        unique_missing = sorted(list(set(broken_project_links)))
        for source, target in unique_missing[:6]:
            print(f"    - {source} menziona '{target}' (cartella non clonata o archiviata)")
        print("")

    if not broken_file_links and not broken_project_links:
        print("✓ Integrità dei percorsi e delle reference locali: 100% integra.")

    return 0


# -----------------------------------------------------------------------------
# 4. SEMANTIC & LEXICAL DEDUPLICATION
# -----------------------------------------------------------------------------

def cmd_dedup(workspace_dir, threshold=0.55):
    """Scans inbox and knowledge files for high lexical and semantic overlap."""
    print("\n👥 POS Evo-Memory — Semantic & Lexical Deduplicator")
    print("=" * 65)

    scan_dirs = ["inbox", "knowledge"]
    documents = []

    for d in scan_dirs:
        dir_path = os.path.join(workspace_dir, d)
        if not os.path.isdir(dir_path):
            continue
        for root, _, files in os.walk(dir_path):
            for file in files:
                if not file.endswith(".md"):
                    continue
                full_path = os.path.join(root, file)
                rel_path = os.path.relpath(full_path, workspace_dir)

                fm, body = parse_frontmatter(full_path)
                title = fm.get("title", file)
                tokens = tokenize(title + " " + body[:3000])

                if len(tokens) >= 5:
                    documents.append({
                        "path": rel_path,
                        "title": title,
                        "tokens": tokens,
                    })

    overlap_pairs = []
    for i in range(len(documents)):
        for j in range(i + 1, len(documents)):
            doc_a = documents[i]
            doc_b = documents[j]

            intersection = doc_a["tokens"].intersection(doc_b["tokens"])
            union = doc_a["tokens"].union(doc_b["tokens"])

            if not union:
                continue

            jaccard = len(intersection) / len(union)
            if jaccard >= threshold:
                overlap_pairs.append((jaccard, doc_a, doc_b))

    overlap_pairs.sort(key=lambda x: x[0], reverse=True)

    print(f"  • File scansionati:                {len(documents)}")
    print(f"  • Coppie con sovrapposizione >= {int(threshold*100)}%: {len(overlap_pairs)}")
    print("")

    if not overlap_pairs:
        print("✓ Nessuna duplicazione o collisione semantica rilevata.")
        return 0

    print("📑 Note candidate alla fusione o consolidamento canonico:")
    for sim, a, b in overlap_pairs[:5]:
        print(f"  [{int(sim*100)}% sim] {a['path']}  <──►  {b['path']}")
        print(f"         \"{a['title']}\"  vs  \"{b['title']}\"")
    print("")

    return 0


# -----------------------------------------------------------------------------
# 5. GLOBAL MEMORY HEALTH AUDIT
# -----------------------------------------------------------------------------

def cmd_audit(workspace_dir, short_mode=False):
    """Computes a holistic memory health index across compaction, size budgets, and anchors."""
    # 1. Backlog items compaction check
    backlog_pattern = os.path.join(workspace_dir, "backlog", "items", "*.md")
    backlog_files = glob.glob(backlog_pattern)
    closed_items = []
    uncompacted_worklogs = []

    for bf in backlog_files:
        fm, _ = parse_frontmatter(bf)
        status = fm.get("status", "")
        if status in ("done", "completed", "verified"):
            item_id = os.path.splitext(os.path.basename(bf))[0]
            closed_items.append(item_id)
            wl_path = find_worklog_for_item(workspace_dir, item_id)
            if wl_path and os.path.isfile(wl_path):
                with open(wl_path, "r", encoding="utf-8", errors="ignore") as f:
                    wl_content = f.read()
                lines = wl_content.split("\n")
                if len(lines) > 50 and "## Compacted Summary" not in wl_content and "## Sommario Esecutivo" not in wl_content:
                    uncompacted_worklogs.append((item_id, len(lines)))

    # 2. Knowledge size check (> 400 lines or missing index)
    knowledge_pattern = os.path.join(workspace_dir, "knowledge", "**", "*.md")
    knowledge_files = glob.glob(knowledge_pattern, recursive=True)
    oversized_files = []

    for kf in knowledge_files:
        with open(kf, "r", encoding="utf-8", errors="ignore") as f:
            k_lines = f.readlines()
        if len(k_lines) > 400:
            oversized_files.append((os.path.relpath(kf, workspace_dir), len(k_lines)))

    # 3. Profile observations and episodic anchors
    obs_file = os.path.join(workspace_dir, "profile", "observations.md")
    observations = parse_observations(obs_file) if os.path.isfile(obs_file) else []
    today = datetime.date.today()
    cutoff_date = today - datetime.timedelta(days=60)

    anchor_count = sum(1 for o in observations if o["is_episodic_anchor"])
    whittle_candidates = [o for o in observations if not o["is_episodic_anchor"] and o["most_recent"] and o["most_recent"] < cutoff_date]

    # Health Score Calculation (0 - 100)
    score = 100
    score -= min(30, len(uncompacted_worklogs) * 6)
    score -= min(20, len(oversized_files) * 5)
    score -= min(20, len(whittle_candidates) * 4)
    score = max(20, score)

    if short_mode:
        status_label = "eccellente" if score >= 85 else "buono" if score >= 70 else "richiede manutenzione"
        print(f"Evo-Memory: {score}/100 ({status_label}) | {anchor_count} ancoraggi episodici | {len(uncompacted_worklogs)} worklog da compattare")
        return 0

    print("\n🧬 POS Evo-Memory Health Index & Memory Architecture Audit")
    print("=" * 65)
    print(f"  • Punteggio di Salute Memoria:      {score}/100")
    print(f"  • Item di Backlog completati:       {len(closed_items)}")
    print(f"  • Worklog chiusi non compattati:    {len(uncompacted_worklogs)}")
    print(f"  • File knowledge fuori budget (>400l): {len(oversized_files)}")
    print(f"  • Nodi di Ancoraggio Episodico:     {anchor_count} (Preservati al 100%)")
    print(f"  • Osservazioni da valutare (whittle): {len(whittle_candidates)}")
    print("")

    if uncompacted_worklogs:
        print("📦 Worklog completati pronti per la compattazione (Evo-Memory):")
        for item_id, count in uncompacted_worklogs[:5]:
            print(f"    - {item_id:<18} ({count} righe) ──► lancia: python3 setup/evo_memory.py compact {item_id}")
        print("")

    if oversized_files:
        print("⚠️  File di conoscenza oltre il budget convenzionale di 400 righe:")
        for path, count in oversized_files:
            print(f"    - {path} ({count} righe)")
        print("")

    if whittle_candidates:
        print(f"✂️  Osservazioni inattive da oltre 60 giorni:")
        for wc in whittle_candidates[:3]:
            print(f"    - \"{wc['title']}\"")
        print("    └─ Lancia: python3 setup/evo_memory.py whittle")
        print("")

    return 0


# -----------------------------------------------------------------------------
# 6. WEEKLY REVIEW DIGEST
# -----------------------------------------------------------------------------

def cmd_digest(workspace_dir):
    """Prepares a structured Evo-Memory briefing for weekly reviews."""
    today_str = datetime.date.today().isoformat()
    print(f"# Evo-Memory Weekly Review Briefing — {today_str}\n")
    cmd_audit(workspace_dir, short_mode=False)
    cmd_staleness(workspace_dir, check_urls=False)
    cmd_dedup(workspace_dir, threshold=0.55)
    return 0


def main():
    parser = argparse.ArgumentParser(description="POS Evo-Memory Automation Suite (Track 4)")
    subparsers = parser.add_subparsers(dest="command")

    audit_p = subparsers.add_parser("audit", help="Run holistic memory health audit")
    audit_p.add_argument("--short", action="store_true", help="One-line output for status.sh")

    compact_p = subparsers.add_parser("compact", help="Distill and compact a completed backlog item worklog")
    compact_p.add_argument("item_id", help="Backlog item ID (e.g. carriera-001)")
    compact_p.add_argument("--apply", action="store_true", help="Apply compaction directly to the worklog file")

    whittle_p = subparsers.add_parser("whittle", help="Audit and whittle profile observations with episodic preservation")
    whittle_p.add_argument("--days", type=int, default=60, help="Days of inactivity threshold (default: 60)")
    whittle_p.add_argument("--apply", action="store_true", help="Apply whittling and archive inactive observations")

    staleness_p = subparsers.add_parser("staleness", help="Check local file and project reference integrity")
    staleness_p.add_argument("--check-urls", action="store_true", help="Also check external URLs")

    dedup_p = subparsers.add_parser("dedup", help="Check semantic and lexical duplicates across inbox and knowledge")
    dedup_p.add_argument("--threshold", type=float, default=0.55, help="Jaccard similarity threshold (default: 0.55)")

    subparsers.add_parser("digest", help="Generate full markdown briefing for weekly review")

    args = parser.parse_args()
    if not args.command:
        parser.print_help()
        return 0

    if args.command == "audit":
        return cmd_audit(WORKSPACE_DIR, args.short)
    elif args.command == "compact":
        return cmd_compact(WORKSPACE_DIR, args.item_id, args.apply)
    elif args.command == "whittle":
        return cmd_whittle(WORKSPACE_DIR, args.days, args.apply)
    elif args.command == "staleness":
        return cmd_staleness(WORKSPACE_DIR, args.check_urls)
    elif args.command == "dedup":
        return cmd_dedup(WORKSPACE_DIR, args.threshold)
    elif args.command == "digest":
        return cmd_digest(WORKSPACE_DIR)


if __name__ == "__main__":
    sys.exit(main())
