---
id: source-google-workspace-mcp
name: Google Workspace MCP
profile: suggested
status: suggested
type: method
url: https://github.com/taylorwilsdon/google_workspace_mcp
access: local-sparse
tags: [google, workspace, gmail, calendar, drive, docs, sheets, mcp, integration]
triggers:
  - consultare o creare eventi su Google Calendar
  - cercare o scaricare file da Google Drive
  - leggere, cercare o comporre email su Gmail
  - leggere o aggiornare fogli Google Sheets o documenti Google Docs
  - integrazione Google Workspace con assistenti AI (Claude Code, Antigravity, Cursor)
---

# Google Workspace MCP — Integrazione Ecosistema Google (Suggerita)

Server MCP open-source basato su specifiche standard [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) che espone oltre 120 strumenti per interagire con l'ecosistema Google Workspace (**Gmail**, **Google Calendar**, **Google Drive**, **Docs**, **Sheets**, **Slides**, **Tasks**, **Contacts**).

È completamente **LLM-agnostico**: funziona in modo identico con **Claude Code**, **Antigravity CLI / IDE**, **Cursor**, **Codex** o qualsiasi client conforme a MCP su protocollo standard `stdio`.

---

## 1. Architettura di Sicurezza & Privacy nel POS

1. **Credenziali Personali Rigorosamente Fuori da Git**:
   - `Client ID` e `Client Secret` sono personali di ciascun utente e risiedono nel file:
     `~/.config/pos/google.env` (con permessi `600`).
   - Il framework POS (`personal-workspace`) non traccia né sincronizza mai token o credenziali.
2. **Connessione Diretta (Zero Proxy Cloud Terzi)**:
   - Il server gira in locale sulla macchina utente (`uvx workspace-mcp`).
   - Tutte le richieste viaggiano direttamente tra il server locale e gli endpoint ufficiali delle Google APIs, autenticate via OAuth 2.0.
3. **Controllo di Confine e Granularità**:
   - **Limitazione strumenti**: puoi esporre solo i servizi desiderati tramite `--tools gmail calendar drive`.
   - **Modalità Read-Only**: puoi impedire scritture o invio email involontario attivando `--read-only`.

---

## 2. Prerequisiti su Google Cloud (Configurazione Una Tantum per l'Utente)

Per generare le tue credenziali OAuth 2.0 personali:

1. **Progetto Google Cloud**:
   - Accedi a [Google Cloud Console](https://console.cloud.google.com/) e crea un progetto (es. `pos-workspace-mcp`).
2. **Abilita le API**:
   - In *API e servizi > Libreria*, abilita:
     - **Google Calendar API**
     - **Gmail API**
     - **Google Drive API**
     - *(Opzionale: Google Docs API, Google Sheets API, Google Tasks API)*.
3. **Schermata di Consenso OAuth (*OAuth consent screen*)**:
   - Seleziona **Esterno** (*External*) per account `@gmail.com` personali, oppure **Interno** (*Internal*) se usi un dominio Google Workspace aziendale.
   - Compila nome applicazione ed email di supporto.
   - Nella scheda **Utenti di test** (*Test users*), **aggiungi il tuo indirizzo email**.
4. **Crea Credenziali OAuth Client ID**:
   - Vai su *API e servizi > Credenziali > Crea credenziali > ID client OAuth*.
   - Tipo di applicazione: **Applicazione desktop** (*Desktop App*).
   - Copia il `Client ID` (termina con `.apps.googleusercontent.com`) e il `Client Secret`.

---

## 3. Configurazione Locale nel POS

### Passo 1: Salva le credenziali
Copia il template ed edita il file con le tue chiavi:
```bash
cp setup/templates/google.env.template ~/.config/pos/google.env
chmod 600 ~/.config/pos/google.env
nano ~/.config/pos/google.env
```

### Passo 2: Esegui lo script di configurazione automatica
Il framework fornisce uno script di setup per configurare i tuoi client AI (Claude Code, Antigravity, Cursor):
```bash
bash setup/setup-google-workspace-mcp.sh
```

### Passo 3: Autenticazione OAuth (Browser / VM)
Puoi completare l'autenticazione OAuth Google in qualsiasi momento con l'helper interattivo:
```bash
python3 setup/auth-google.py
```
Lo script avvia il callback server locale, ti fornisce l'URL di autorizzazione da aprire nel browser e salva automaticamente i token crittografati in `~/.google_workspace_mcp/credentials/`.

---

## 4. Configurazione Manuale nei Client MCP

Se preferisci configurare manualmente i client:

### A. Claude Code (`~/.claude.json`)
Aggiungi all'oggetto `"mcpServers"`:
```json
{
  "mcpServers": {
    "google-workspace": {
      "command": "uvx",
      "args": [
        "workspace-mcp",
        "--tools", "gmail", "calendar", "drive"
      ],
      "env": {
        "GOOGLE_OAUTH_CLIENT_ID": "TUO_CLIENT_ID.apps.googleusercontent.com",
        "GOOGLE_OAUTH_CLIENT_SECRET": "TUO_CLIENT_SECRET"
      }
    }
  }
}
```

### B. Antigravity CLI / Gemini (`~/.gemini/config/mcp_config.json`)
```json
{
  "mcpServers": {
    "google-workspace": {
      "command": "uvx",
      "args": ["workspace-mcp", "--tools", "gmail", "calendar", "drive"],
      "env": {
        "GOOGLE_OAUTH_CLIENT_ID": "TUO_CLIENT_ID.apps.googleusercontent.com",
        "GOOGLE_OAUTH_CLIENT_SECRET": "TUO_CLIENT_SECRET"
      }
    }
  }
}
```

### C. Primo Avvio e Consenso OAuth
Alla prima invocazione da parte di qualsiasi assistente AI, il server apre una scheda nel browser per richiedere l'autorizzazione di accesso al tuo account Google. Una volta autorizzato, i token di refresh vengono salvati in locale e rinnovati automaticamente.

---

## 5. Attivazione nell'Istanza Personale (Thin Overlay)

Ogni utente che desidera adottare Google Workspace nella propria istanza crea una scheda snella in `reference/sources/google-workspace-mcp.md`:

```yaml
---
id: source-google-workspace-mcp
name: Google Workspace MCP
source_ref: knowledge/sources/google-workspace-mcp.md
profile: personal
status: active
areas: [lavoro, organizzazione]
---
```
