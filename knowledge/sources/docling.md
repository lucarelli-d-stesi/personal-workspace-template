---
id: source-docling
name: Docling Document Parser (IBM Research)
profile: suggested
status: suggested
category: cli-tool
type: method
url: https://github.com/DS4SD/docling
access: local-sparse
tags: [pdf, docx, documenti, parsing, ocr, tabelle, markdown, ibm, genai, rag, scansioni]
triggers:
  - convertire o analizzare documenti PDF complessi con tabelle o layout articolati
  - estrarre dati e tabelle strutturate da file PDF, bilanci, bandi o circolari
  - digitalizzazione e OCR di scansioni, immagini o documenti cartacei digitalizzati
  - convertire file Word (.docx), PowerPoint (.pptx) o Excel (.xlsx) in formato Markdown
  - preparare documenti per analisi semantica o interrogazione approfondita da parte dell'LLM
---

# Docling — Parser Documentale Avanzato per GenAI (Suggerita)

Progetto open-source d'avanguardia sviluppato da **IBM Research** specializzato nella conversione e comprensione di documenti ricchi e complessi (**PDF multipagina**, **DOCX**, **PPTX**, **XLSX**, **HTML**, **immagini**) in formati nativamente strutturati per i modelli di linguaggio (**Markdown**, **JSON** e chunk semantici).

A differenza dei tradizionali estrattori di testo (es. `pdftotext`, `pypdf`, `pdfminer`) che producono un flusso continuo e disordinato di caratteri perdendo completamente il contesto visivo, Docling esegue:
1. **Riconoscimento del Layout Visivo**: individua titoli, paragrafi, intestazioni, note a piè di pagina e ordine di lettura logico su documenti multi-colonna.
2. **Estrazione e Ricostruzione di Tabelle Complesse**: riconosce le celle unite, l'allineamento e la struttura tabellare, convertendole in perfette tabelle Markdown o dataframe esportabili.
3. **Motore OCR Integrato**: elabora automaticamente documenti scansionati o PDF ibridi tramite motori OCR locali (EasyOCR, RapidOCR, Tesseract) senza inviare dati al cloud.
4. **Formule Matematiche e Codice**: riconosce blocchi di codice e formule matematiche preservandone la sintassi LaTeX.

---

## 1. Ambiti d'Uso nel Personal Operating System (POS)

Nel contesto operativo del POS, Docling risolve una delle maggiori sfide di ingestione documentale:

- **🏛️ Atti Pubblici, Delibere e Bandi di Concorso**:
  - Bandi comunali, decreti ministeriali e formulari amministrativi con allegati e tabelle di punteggio complesse.
- **🎓 Scuola & Università (ClasseViva / Tesine)**:
  - Circolari d'istituto in formato PDF con prospetti orari, tabelle quote gite e regolamenti interni.
  - Articoli scientifici, saggi e dispense universitarie in PDF da sintetizzare o convertire in dispense di studio.
- **💼 Finanze, Contratti e Bollette**:
  - Estratti conto, bollette energetiche con grafici e tabelle di consumo, contratti di locazione o polizze assicurative.
- **🏗️ Progetti Tecnici e Specifiche**:
  - Capitolati tecnici, documentazione Odoo o diagrammi di processo scansionati.

---

## 2. Architettura & Requisiti Locali

Docling gira **completamente in locale** sul computer dell'utente (CPU o accelerazione GPU/MPS se disponibile):
- **Runtime**: Python 3.10+
- **Pacchetto**: `pip install docling` (oppure eseguibile tramite `uvx docling`)
- **Zero Cloud**: Nessun documento viene mai trasmesso all'esterno o ad API di terze parti (privacy by design).

---

## 3. Modalità d'Uso Operativa

### A. Esecuzione Rapida da Riga di Comando (CLI)
Per convertire istantaneamente un file locale in Markdown pronto per essere letto dall'agente o incluso nel workspace:

```bash
# Converte un PDF locale e genera il file .md corrispondente
docling documento.pdf

# Oppure senza installazione globale tramite uvx:
uvx docling documento.pdf --output output_dir/
```

### B. Uso in Script Python
```python
from docling.document_converter import DocumentConverter

converter = DocumentConverter()
result = converter.convert("circolare_scolastica.pdf")

# Esporta in Markdown strutturato
markdown_text = result.document.export_to_markdown()

# Salva nella cartella d'area o in knowledge/
with open("circolare_analizzata.md", "w") as f:
    f.write(markdown_text)
```

---

## 4. Adozione nell'Istanza Personale (Thin Overlay)

Se desideri adottare formalmente Docling nella tua istanza personale:
1. Crea la scheda in `reference/sources/docling.md`:
   ```yaml
   ---
   name: Docling Document Parser
   source_ref: knowledge/sources/docling.md
   status: active
   areas: [ricerca, lavoro, documenti]
   ---
   ```
2. Installa la dipendenza locale nell'ambiente Python:
   ```bash
   pip install docling
   ```
3. L'assistente AI proporrà automaticamente Docling quando gli chiederai di analizzare o comprendere documenti PDF o scansioni complesse.
