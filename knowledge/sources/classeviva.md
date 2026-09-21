---
id: source-classeviva
name: Spaggiari ClasseViva API
profile: suggested
status: suggested
type: method
url: https://github.com/Lioydiano/Classeviva
access: remote-sparse
tags: [scuola, registro-elettronico, classeviva, spaggiari, compiti, circolari, bacheca, famiglia, studio]
triggers:
  - consultare i compiti assegnati o l'agenda scolastica
  - leggere comunicazioni in bacheca, circolari o avvisi della scuola
  - scaricare allegati e circolari scolastiche in PDF
  - verificare lezioni svolte e argomenti trattati dai docenti
  - monitorare voti, valutazioni e assenze
  - pianificare lo studio pomeridiano o le interrogazioni
---

# Spaggiari ClasseViva API — Integrazione Registro Elettronico (Suggerita)

Specifiche e blueprint di integrazione per il registro elettronico **Spaggiari ClasseViva**, ampiamente adottato dalle scuole primarie e secondarie italiane.

L'integrazione si basa sulle API REST ufficiali usate dall'app mobile ClasseViva (`https://web.spaggiari.eu/rest/v1/...`), referenziate dal wrapper open-source Python [`Lioydiano/Classeviva`](https://github.com/Lioydiano/Classeviva) e dalla documentazione degli endpoint [`Classeviva-Official-Endpoints`](https://github.com/Lioydiano/Classeviva-Official-Endpoints).

---

## 1. Architettura Multi-Ruolo: Genitore vs Studente

Nel Personal Operating System (POS), l'accesso a ClasseViva risponde a due casi d'uso distinti:

### A. Profilo Genitore (`G...`) — Workspace Familiare
- **Identificativo**: inizia convenzionalmente per `G` (es. `G1234567`).
- **Multi-Figlio nativo**: un unico account genitore può avere collegate **più figlie/figli**.
- **Flusso API**:
  1. Login con credenziali genitore: `POST /v1/auth/login`.
  2. Recupero schede studenti collegate: `GET /v1/students/{parentId}/cards`.
  3. Interrogazione puntuale per ciascun figlio: `/v1/students/{studentId}/...`.
- **Ambiti d'uso**:
  - Consultazione compiti e scadenze per coordinare la routine familiare.
  - Lettura di circolari e comunicazioni istituzionali con download allegati PDF.
  - Monitoraggio di valutazioni, assenze e note disciplinari.

### B. Profilo Studente (`S...`) — Workspace Individuale della Figlia/Studente
- **Identificativo**: inizia convenzionalmente per `S` (es. `S7654321`).
- **Mono-Utente nativo**: legato direttamente alla singola studentessa.
- **Ambiti d'uso nel POS dello studente**:
  - **Pianificazione autonoma dello studio**: estrazione automatica dei compiti dell'agenda (`AGHW`) e scomposizione in attività nel backlog o nel journal giornaliero.
  - **Ripasso attivo**: lettura degli argomenti trattati nelle lezioni del giorno (`lezioni_giorno`) per generare schemi di ripasso e flashcard prima di verifiche o interrogazioni.

---

## 2. Specifiche Endpoints Principali

Tutte le richieste all'API Spaggiari richiedono le seguenti intestazioni HTTP:
```http
User-Agent: CVVS/std/4.2.3 Android/12
Z-Dev-ApiKey: Tg1NWEwNGIgIC0K
Content-Type: application/json
```
Dopo il login, le chiamate successive includono l'header di sessione:
```http
Z-Auth-Token: <token_ottenuto_al_login>
```

| Endpoint | Metodo | Descrizione | Oggetto / Filtri |
| :--- | :--- | :--- | :--- |
| `/v1/auth/login` | `POST` | Autenticazione utente | `{"ident": null, "pass": "...", "uid": "G/S..."}` |
| `/v1/students/{id}/cards` | `GET` | Elenco studenti associati | Restituisce array `cards` con `usrId`, nome, scuola |
| `/v1/students/{id}/agenda/all/{da}/{a}` | `GET` | Compiti ed eventi agenda | Codice `AGHW` (compiti) con materia e note |
| `/v1/students/{id}/noticeboard` | `GET` | Bacheca comunicazioni | Titoli, date e categorie (es. `"Circolare"`) |
| `/v1/students/{id}/noticeboard/attach/{code}/{pubId}/101` | `GET` | Download allegato bacheca | Restituisce il file binario (PDF) |
| `/v1/students/{id}/lessons/{giorno}` | `GET` | Lezioni svolte nel giorno | Docenti, materie e argomenti spiegati in classe |
| `/v1/students/{id}/grades` | `GET` | Valutazioni e voti | Elenco voti con data, materia e tipologia |
| `/v1/students/{id}/didactics` | `GET` | Materiale didattico | Cartelle e file condivisi dai docenti |

---

## 3. Architettura di Sicurezza & Privacy nel POS

1. **Zero Credenziali in Git**:
   - Username e password risiedono esclusivamente in `~/.config/pos/classeviva.env` (permessi `600`).
   - Il framework POS non committa né sincronizza credenziali scolastiche.
2. **Connessione Diretta HTTPS**:
   - Tutte le chiamate partono localmente verso i server Spaggiari (`https://web.spaggiari.eu/`).
   - Nessun proxy intermedio o servizio cloud terzo.

---

## 4. Configurazione Locale e Strumenti nel POS

### Passo 1: Configura le credenziali
Copia il template ed edita il file con le credenziali ClasseViva:
```bash
cp setup/templates/classeviva.env.template ~/.config/pos/classeviva.env
chmod 600 ~/.config/pos/classeviva.env
nano ~/.config/pos/classeviva.env
```

### Passo 2: Utilizzo della CLI di Interrogazione
Il framework fornisce lo script [setup/classeviva-cli.py](setup/classeviva-cli.py):
```bash
# Verifica connessione e lista studenti collegati
python3 setup/classeviva-cli.py status

# Mostra i compiti dei prossimi 7 giorni
python3 setup/classeviva-cli.py compiti

# Mostra le circolari e avvisi recenti in bacheca
python3 setup/classeviva-cli.py bacheca

# Mostra le lezioni e gli argomenti spiegati oggi
python3 setup/classeviva-cli.py lezioni
```

---

## 5. Attivazione nell'Istanza Personale (Thin Overlay)

Per attivare la fonte nell'istanza privata dell'utente:
- Profilo Genitore: crea `reference/sources/classeviva.md` collegata alla propria area di supporto familiare.
- Profilo Studente: crea `reference/sources/classeviva.md` collegata all'area `studio` o `scuola`.
