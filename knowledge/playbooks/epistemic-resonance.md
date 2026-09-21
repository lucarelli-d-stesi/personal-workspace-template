# Playbook — epistemic resonance and pluralism

The Personal Operating System models knowledge to augment human thinking. By default,
digital knowledge systems inherit the dominant patterns of Western thought: Aristotelian
binary logic (true vs false, excluded middle), Cartesian substance ontology (discrete
objects with fixed properties), and linear teleological time (cause-and-effect chains,
forward progress, replacing the old with the new).

While effective for short-term technical execution, this creates a **cultural echo chamber**
and cognitive blind spots. Grounded in **Kernel Principle 7 (Anti-echo-chamber)**, this
playbook establishes a pluralistic, non-linear epistemology inspired by classical Eastern
thought (Daoism, *Gan-Ying*, *Wuxing*, Buddhism, Jainism).

---

## 1. The Two Epistemic Modes

Knowledge notes, area contexts, and backlog items operate across two complementary modes:

```
┌──────────────────────────────────────┐     ┌──────────────────────────────────────┐
│       MODE A: LINEAR & CAUSAL        │     │     MODE B: CORRELATIVE & PROCESS    │
│            (Yang / Action)           │     │          (Yin / Ecology)             │
├──────────────────────────────────────┤     ├──────────────────────────────────────┤
│ • Substance & discrete categories    │     │ • Flow, transition & transformation  │
│ • Sequential time (past → future)    │     │ • Cyclical rhythm & seasonal phases  │
│ • Teleological goal execution        │     │ • Situational propensity (Shi / 勢)  │
│ • Binary exclusion (true vs false)   │     │ • Complementary polarity (Yin-Yang)  │
│ • Deterministic causality (A → B)    │     │ • Sympathetic resonance (Gan-Ying)   │
└──────────────────────────────────────┘     └──────────────────────────────────────┘
```

Both modes are necessary. Mode A builds software, manages sprints, and fixes bugs.
Mode B nurtures judgment, prevents burnout, preserves paradoxes, and discovers deep cross-domain insight.

---

## 2. Typed Relationships in Frontmatter

Every note in `knowledge/`, `areas/`, and `backlog/items/` can declare both linear and
correlative relations in its YAML frontmatter:

```yaml
---
title: "Radicamento e Struttura Dinamica"
status: active

# Mode A — Linear & Causal (Western Logic)
depends_on: []
supersedes: []
supports: [resilienza-sistemi]
conflicts_with: []

# Mode B — Correlative & Process (Eastern Epistemology)
resonates_with: [architettura-disaccoppiamento, negoziazione-non-resistenza]
polar_balance: [adattabilita-fluida]
nourishes: [chiarezza-decisionale, presenza-mentale]
moderates: [iper-reattivita-emotiva]
---
```

### Relational Semantics:

### 1. `resonates_with: [slug1, slug2]` (*Gan-Ying* 感應 — Sympathetic Resonance)
* **Principle:** Like strings on two tuned zithers, concepts in disparate domains vibrate together when they share an underlying archetype or structural dynamic.
* **When to use:** Connecting ideas across completely separated areas (e.g. martial arts body mechanics $\leftrightarrow$ software resilience $\leftrightarrow$ economic diplomacy) where no causal dependency exists, but the same deep pattern applies.
* **Mermaid representation:** `A <-.->|resonates| B`

### 2. `polar_balance: [slug1, slug2]` (*Yin-Yang* 陰陽 — Dynamic Polar Balance)
* **Principle:** Opposites do not cancel or destroy each other; they co-originate and define each other. A tension is not an error (`conflicts_with`) to be resolved, but a living polarity to be kept in balance.
* **When to use:** Pairs such as *rigor* vs *flexibility*, *automation* vs *craftsmanship*, *action* vs *rest*, *specialization* vs *generalism*.
* **Mermaid representation:** `A <==>|polar| B`

### 3. `nourishes: [slug1, slug2]` (*Wuxing Sheng* 五行生 — Generative Nutrition)
* **Principle:** In the five-phase cycle, each phase gives birth to and feeds the next (Wood feeds Fire, Water feeds Wood). In knowledge and life, certain practices or mental models provide continuous vitality to others.
* **When to use:** Identifying what sustains an activity or capability over time (e.g. physical discipline `nourishes` mental stamina; foundational study `nourishes` architectural elegance). Distinct from `depends_on`: absence does not cause an immediate syntax failure, but slow starvation.
* **Mermaid representation:** `A ==>|nourishes| B`

### 4. `moderates: [slug1, slug2]` (*Wuxing Ke* 五行剋 — Homeostatic Restraint)
* **Principle:** The overcoming/controlling cycle prevents any element from hyper-expanding into self-destruction (Metal prunes Wood; Water quenches excess Fire).
* **When to use:** Defining checks, balances, and counterweights (e.g. simplicity `moderates` over-engineering; rest `moderates` drive; critical audit `moderates` ungrounded enthusiasm).
* **Mermaid representation:** `A -.->|moderates| B`

---

## 3. Synergy with Associative Latent Search (`zg`)

The workspace combines **unsupervised latent association** with **deliberate epistemic declaration**:

1. **`zg` / `zvec_grep` (The Latent Void / Yin):**
   * High-dimensional vector space captures semantic proximity, tone, and unstated affinities across thousands of lines of text.
   * Discovers connections the rational mind has not yet consciously labeled.
2. **YAML Frontmatter & `setup/graph.py` (The Manifest Form / Yang):**
   * Encodes deliberate human intention, ontological commitment, and structural relationships.
   * Embeddings cannot tell if two polar opposites are in toxic conflict or fruitful equilibrium; the YAML frontmatter explicitly declares it.

**The Workflow Loop:**
* Run `zg query "<theme>"` to discover unlinked notes that share vocabulary or semantic fields.
* Reflect on the results: is this a mere coincidence, a causal link, or a deep resonance (*Gan-Ying*)?
* Declare the appropriate relationship (`resonates_with` or `polar_balance`) in the note's frontmatter.

---

## 4. Graph Diagnostics and CLI

Inspect and audit the epistemic fabric using `setup/graph.py`:

```bash
# 1. Audit consistency (detect dangling links or missing files)
python3 setup/graph.py check

# 2. Inspect a node's full relational constellation
python3 setup/graph.py lineage <slug>

# 3. Export a Mermaid visualization showing linear, polar, and resonant edges
python3 setup/graph.py mermaid

# 4. View statistics on the balance between linear and correlative relations
python3 setup/graph.py stats
```

---

## 5. Summary Matrix

| Need / Query | Traditional Western Trap | Plural Epistemic Tool | Frontmatter Field |
| :--- | :--- | :--- | :--- |
| Two ideas seem contradictory | Force one to `supersedes` or delete the other | Recognize complementary polarity | `polar_balance` |
| Same principle appears in 2 different domains | Create artificial shared abstraction / hierarchy | Acknowledge horizontal resonance | `resonates_with` |
| An area is running out of energy / feeling dry | Add more task deadlines (`depends_on`) | Inspect what feeds and vitalizes it | `nourishes` |
| An initiative is growing bloated and obsessive | Wait for failure or burnout | Apply deliberate counterweight/pruning | `moderates` |
| What is the next step in a project? | Force execution regardless of context | Evaluate situational ripeness (*Shi*) | Contextual alignment |
