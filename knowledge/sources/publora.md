---
id: source-publora
name: Publora Skills & Social MCP
profile: suggested
status: suggested
type: method
url: https://github.com/publora/skills
access: remote-sparse
tags: [social-media, publishing, scheduling, mcp, facebook, instagram, tiktok, telegram, linkedin, youtube, threads, bluesky, x]
triggers:
  - pubblicazione o programmazione post sui social network
  - posting su Pagine Facebook, Instagram Reels o Caroselli, TikTok, Telegram
  - formattazione contenuti e vincoli tecnici per ciascuna piattaforma social
  - campagne di comunicazione social per attivismo, politica, blog o divulgazione
---

# Publora Skills & Social MCP Server (Suggerita)

Framework di skill e blueprint di integrazione per la pubblicazione e programmazione unificata di contenuti su 10 social network attraverso il server **MCP di Publora** (`https://mcp.publora.com`) o le relative API REST.

Il repository open-source [`publora/skills`](https://github.com/publora/skills) contiene 9 skill native (`SKILL.md`) che insegnano agli agenti le regole, le limitazioni tecniche (JPEG vs PNG, formati video verticali, lunghezze massime, formattazione markdown) e i workflow di approvazione per ciascuna piattaforma.

---

## 1. Architettura e Ruolo nel POS

1. **Gateway Unificato Multi-Piattaforma**:
   - Invece di dover sviluppare e manutenere singole integrazioni OAuth e token con Meta (Facebook/Instagram), TikTok, Telegram, Google (YouTube), ecc., Publora funge da middleware hosted.
   - I token e le connessioni ai canali si gestiscono una volta per tutte nella dashboard di Publora.
   - L'agente interagisce con un unico set di tool standardizzati (`create_post`, `list_posts`, `delete_post`, ecc.).

2. **Principio di Proposta e Approvazione (Draft & Approval)**:
   - Coerentemente con il Kernel (*"Proponi, non imporre"*), l'agente può preparare i contenuti in modalità **bozza (`draft`)**.
   - L'utente revisiona e valida i post prima dell'effettiva pubblicazione o programmazione oraria.

3. **Limitazioni e Confini (Da ricordare)**:
   - **Solo in uscita (Outbound)**: Publora gestisce unicamente invio e programmazione. Non supporta l'ascolto di messaggi privati (DM), feed personali o chat chiuse.
   - **Pagine Facebook**: Supporta solo Pagine pubbliche di Facebook, non profili o diari personali (vincolo imposto da Meta).
   - **Piano Gratuito (Starter)**: Copre tutte le piattaforme con limiti d'uso standard (solo X richiede piano a pagamento).

---

## 2. Le 9 Skill Metodologiche Integrate nel Framework (`.agents/skills/`)

Le 9 skill sono state assimilate nel framework del workspace in `.agents/skills/`:

| Skill | Piattaforma | Scopo e Vincoli Principali |
|---|---|---|
| `social-post` | Facebook (Pagine), YouTube, Mastodon | Pagine Facebook (non profili personali), YouTube (video obbligatorio), Mastodon (max 500 car.). |
| `instagram-post` | Instagram | Solo JPEG (no PNG), richiede Business account, post solo con media (immagini/video, no solo testo), Reels e Stories. |
| `tiktok-post` | TikTok | Video verticali (9:16), gestione visibilità e privacy. |
| `telegram-post` | Telegram | Canali e gruppi via Bot, markdown Telegram, limite didascalie a 1.024 car., video max 50 MB. |
| `linkedin-post` | LinkedIn | Post professionali, griglie immagini, documenti PDF multipagina (alternativa ai caroselli). |
| `linkedin-analytics` | LinkedIn | Statistiche di engagement, commenti e reshare. |
| `threads-post` | Threads | Microblogging Meta, caroselli immagini. |
| `bluesky-post` | Bluesky | Post brevi max 300 caratteri, gestione alt-text immagini. |
| `x-post` | X (Twitter) | Tweet singoli e thread (richiede API a pagamento). |

---

## 3. Configurazione dell'MCP Server (Opzionale)

Per attivare i tool MCP in Antigravity o Claude Code:
1. Registrati su [publora.com](https://publora.com/register) e collega i canali social desiderati.
2. Recupera l'API key in [app.publora.com/dashboard/api](https://app.publora.com/dashboard/api).
3. Salva la chiave in `~/.config/pos/publora.env` con permessi `600`.
4. Registra il server MCP HTTP:
   ```bash
   # URL endpoint
   https://mcp.publora.com
   # Header
   Authorization: Bearer sk_YOUR_KEY
   ```
