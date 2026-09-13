---
id: source-italia-corpus
name: Italia Corpus
profile: suggested
status: suggested
type: content
url: https://github.com/ahmeabd/italia-corpus
access: remote-on-demand
raw_base_url: https://raw.githubusercontent.com/ahmeabd/italia-corpus/main/
tags: [normativa, italia, terzo-settore, pubblica-amministrazione, concorsi, legale, leggi, decreti, tuel, cad]
triggers:
  - normative, leggi, decreti legislativi e regolamenti della Repubblica Italiana
  - terzo settore, associazionismo, enti del terzo settore (ETS, APS, ODV)
  - enti locali, comuni, province, regioni e Testo Unico Enti Locali (TUEL)
  - pubblico impiego, contratti pubblici e concorsi nella Pubblica Amministrazione
  - codice amministrazione digitale (CAD) e transizione digitale della PA
  - verifica del testo vigente di una norma o di uno specifico articolo di legge
---

# Italia Corpus — Fonte Normativa Italiana (Suggerita)

Archivio Markdown open-source costantemente aggiornato con la legislazione italiana pubblicata su Normattiva (oltre 280.000 atti normativi indicizzati con cronologia e metadati).

---

## 1. Regole Comportamentali per l'Agente (Proactive Suggestion)

1. **Riconoscimento dei Trigger**:
   - Quando l'utente chiede chiarimenti, avvia un'attività o pianifica un task che coinvolge la legislazione italiana, la burocrazia statale o municipale, il Codice del Terzo Settore o il diritto amministrativo, **proponi proattivamente questa fonte**.
   - Formula suggerita:
     > *«Per questa materia possiamo fare riferimento alla fonte suggerita del framework **Italia Corpus** (repo `ahmeabd/italia-corpus`), che contiene l'archivio normativo aggiornato in formato Markdown. Vuoi che consultiamo puntualmente il testo di legge via URL raw o che la attiviamo tra le tue fonti personali?»*

2. **Accesso On-Demand Puntuale (Zero Bloat)**:
   - **NON clonare né scaricare il repository in blocco**: contiene oltre 280.000 file e saturerebbe l'ambiente locale e l'indice vettoriale.
   - Quando serve un testo o articolo specifico, recuperalo via HTTP raw tramite tool `read_url_content` o `curl` puntando al raw URL:
     `https://raw.githubusercontent.com/ahmeabd/italia-corpus/main/<percorso>`

3. **Harvesting e Distillazione**:
   - Non salvare testi integrali di legge nel repository di note. Registra solo le sintesi pratiche, le scadenze e le implicazioni operative nelle note tematiche di `knowledge/` (es. `knowledge/normativa-ets.md`).

---

## 2. Indice delle Collezioni e Testi Principali

| Materia / Ambito | Atto Normativo | Percorso nel Repository |
|---|---|---|
| **Terzo Settore** | D.Lgs. 117/2017 (Codice del Terzo Settore) | `Testi Unici/D.Lgs. 117-2017 - Codice del Terzo Settore.md` |
| **Enti Locali** | D.Lgs. 267/2000 (TUEL) | `Testi Unici/D.Lgs. 267-2000 - TUEL.md` |
| **Pubblico Impiego** | D.Lgs. 165/2001 (TU Pubblico Impiego) | `Testi Unici/D.Lgs. 165-2001 - Testo Unico del Pubblico Impiego.md` |
| **Digitale & PA** | D.Lgs. 82/2005 (CAD) | `Testi Unici/D.Lgs. 82-2005 - Codice dell'amministrazione digitale.md` |
| **Trasparenza** | D.Lgs. 33/2013 (Accesso civico / FOIA) | `Testi Unici/D.Lgs. 33-2013 - Trasparenza e accesso civico.md` |
| **Appalti Pubblici** | D.Lgs. 36/2023 (Codice dei Contratti Pubblici) | `Testi Unici/D.Lgs. 36-2023 - Codice dei contratti pubblici.md` |
| **Costituzione** | Costituzione della Repubblica Italiana | `Costituzione/Costituzione della Repubblica Italiana.md` |

---

## 3. Promozione a Fonte Personale

Se l'utente accetta o richiede di rendere Italia Corpus una fonte personale attiva:
- Copia/crea la scheda in `<instance_dir>/reference/sources/italia-corpus.md` impostando `profile: personal` e `status: active`.
- L'indice vettoriale locale `zg` indicizzerà la scheda con tutti i trigger per un recupero semantico rapido ad ogni sessione.
