---
id: <area>-<NNN>       # stable, assigned once, never reused or renamed
title: <short title>
area: <area slug>
parent:                # id of the parent item (thread or sprint); empty = top-level
kind: task             # thread | sprint | task — hint, hierarchy is free
status: todo           # todo | doing | waiting | blocked | done | dropped
created: YYYY-MM-DD
due:
closed:
external_ref:          # filled by a bridge adapter: <adapter>:<model>:<id>
tags: []
---

<!-- One paragraph max. Requirements live in the area's specs/<item>.md;
     the diary lives in worklog/<item>.md. This file is the tracking record. -->
