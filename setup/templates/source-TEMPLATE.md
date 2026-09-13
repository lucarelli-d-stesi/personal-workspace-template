---
id: source-{{ID}}
name: {{NAME}}
type: content # content | method | mixed
url: https://github.com/{{ORG}}/{{REPO}}
access: remote-on-demand # remote-on-demand | local-sparse | local-clone
raw_base_url: # optional: for remote-on-demand markdown/raw fetching
local_path: # optional: e.g. ~/repos/{{REPO}} if cloned locally outside workspace
tags: [tag1, tag2]
derived_skills: [] # optional: links to local skills informed by this source
---

# {{NAME}} — External Source Reference

Brief description of what this repository contains and why it is mapped as a source in your personal system.

## Purpose & Scope
- Where and when this source should be consulted.
- Key subdirectories, documents, or collections of interest.

## Access & Distillation Rules for the Agent
- **Access mode**: (e.g. read on-demand via raw URL, or check local clone in `local_path`).
- **Never mirror blindly**: extract only actionable conclusions, patterns, or facts into `knowledge/` or `skills/`.
- Let the local semantic search (`zg`) index the distilled knowledge rather than the raw external repository.
