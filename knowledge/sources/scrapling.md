---
id: source-scrapling
name: Scrapling Web Scraper & Crawler
profile: suggested
status: suggested
category: cli-tool
type: method
url: https://github.com/D4Vinci/Scrapling
access: local-sparse
tags: [scraping, web, anti-bot, cloudflare, stealth, crawlers, open-data, automazione, markdown]
triggers:
  - estrarre dati o testi da pagine web protette da Cloudflare o filtri anti-bot
  - scraping di portali istituzionali, albi pretori, bandi comunali o rassegne stampa
  - acquisizione di contenuti da Single Page Application (SPA) con rendering JavaScript
  - monitoraggio periodico di modifiche a pagine web, elenchi o tariffe
  - aggirare blocchi 403 / captcha durante il download di fonti esterne pubbliche
---

# Scrapling — Framework di Web Scraping Furtivo & Adattivo (Suggerita)

Framework Python open-source ad altissime prestazioni specificamente progettato per il web scraping robusto, l'ingestione di dati web per agenti AI e il superamento delle protezioni anti-bot moderne (**Cloudflare Turnstile**, **DataDome**, **Akamai**, fingerprinting TLS).

A differenza dei crawler tradizionali (es. BeautifulSoup, Scrapy) che vengono bloccati con errori `403 Forbidden` appena incontrano un sistema di protezione, e dei browser headless pesanti (Puppeteer/Selenium puro) che consumano enormi quantità di RAM:
1. **Stealth Nativo a Basso Overhead**: include motori di fetch specializzati in grado di aggirare i challenge anti-bot senza caricare per forza un intero browser per ogni richiesta.
2. **Selettori Intelligenti & Auto-Adattivi**: se la struttura HTML della pagina target subisce piccole variazioni nel tempo, Scrapling si adatta automaticamente riducendo al minimo la manutenzione degli scraper.
3. **Estrazione AI-Ready**: ripulisce il DOM da codice inutile, stili inline, annunci e boilerplate, restituendo testo pulito in Markdown o JSON per l'assistente LLM.
4. **Zero Servizi Terzi a Pagamento**: funziona al 100% in locale, senza richiedere abbonamenti a proxy residenziali o servizi di captcha-solving cloud.

---

## 1. I Tre Motori di Fetching

Scrapling adotta un'architettura modulare a tre livelli in base alla complessità del sito bersaglio:

| Fetcher | Livello di Protezione | Casi d'Uso Tipici |
| :--- | :--- | :--- |
| **`Fetcher`** | Siti statici / API aperte | Velocità pura (fino a 10x rispetto a browser headless), ideale per portali standard senza controlli anti-bot. |
| **`StealthyFetcher`** | Cloudflare / Anti-bot leggeri | Supera le schermate "Verifica che sei un essere umano" e i blocchi TLS fingerprinting senza avviare una GUI. |
| **`DynamicFetcher`** | SPA complesse (React/Vue/Angular) | Basato su Playwright/Camoufox per siti che richiedono esecuzione JavaScript pesante, scroll dinamico o clic. |

---

## 2. Casi d'Uso nel Personal Operating System (POS)

- **🏛️ Monitoraggio Civico, Delibere e Albi Pretori**:
  - Estrazione periodica di avvisi, determine dirigenziali e bandi da siti comunali o regionali che presentano protezioni perimetrali Cloudflare.
- **📰 Ricerca & Rassegna Stampa**:
  - Scraping di articoli di giornale, comunicati o dossier d'attualità da portali informativi, superando blocchi anti-crawler.
- **🔍 Monitoraggio Prezzi & Mercato**:
  - Monitoraggio di annunci, cataloghi o tariffe da portali verticali con protezione anti-scraping.
- **🎓 Ricerca e Materiali di Studio**:
  - Acquisizione automatica di dispense o articoli da portali accademici che bloccano fetch tradizionali.

---

## 3. Installazione & Esempio Rapido

### Installazione Locale
```bash
pip install scrapling
# Se serve anche il motore Playwright per siti con JavaScript pesante:
scrapling install
```

### Esempio Python: Scraping Protetto da Cloudflare
```python
from scrapling import StealthyFetcher

# Inizializza il fetcher furtivo
fetcher = StealthyFetcher()

# Scarica la pagina superando automaticamente la verifica anti-bot
page = fetcher.fetch("https://sito-protetto-da-cloudflare.it/avvisi")

# Estrae il testo pulito dei titoli
titoli = page.css(".titolo-avviso::text").get_all()
for t in titoli:
    print("-", t.strip())
```

---

## 4. Adozione nell'Istanza Personale (Thin Overlay)

Se desideri aggiungere Scrapling al tuo catalogo di strumenti personali:
1. Crea la scheda in `reference/sources/scrapling.md`:
   ```yaml
   ---
   name: Scrapling Web Scraper
   source_ref: knowledge/sources/scrapling.md
   status: active
   areas: [ricerca, lavoro]
   ---
   ```
2. L'assistente AI utilizzerà Scrapling ogni volta che riscontrerà blocchi HTTP `403` o pagine con protezione Cloudflare durante task di ricerca e raccolta dati.
