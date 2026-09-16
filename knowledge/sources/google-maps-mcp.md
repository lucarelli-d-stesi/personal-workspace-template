---
id: source-google-maps-mcp
name: Google Maps Grounding Lite MCP
profile: suggested
status: suggested
type: method
url: https://mapstools.googleapis.com/mcp
access: remote-on-demand
tags: [google, maps, geospatial, routing, geocoding, weather, mcp, integration]
triggers:
  - calcolare percorsi, distanze e tempi di percorrenza (driving, walking)
  - cercare punti di interesse, stazioni di ricarica elettrica e attività commerciali
  - verificare meteo attuale e previsioni per località specifiche
  - geocodifica e risoluzione di indirizzi e link brevi di Google Maps
---

# Google Maps Grounding Lite MCP — Integrazione Geospaziale Google (Suggerita)

Server MCP ufficiale e gestito da Google che espone strumenti di grounding geospaziale su protocollo standard Model Context Protocol (MCP) tramite endpoint remoto Streamable HTTP / SSE (`https://mapstools.googleapis.com/mcp`).

---

## 1. Caratteristiche e Tool Disponibili

Il server remoto espone 5 strumenti nativi:
* `search_places`: Ricerca luoghi, stazioni di ricarica, attività e punti di interesse tramite query in linguaggio naturale.
* `compute_routes`: Calcolo percorsi stradali o pedonali con distanze chilometriche e tempi di viaggio stimati.
* `lookup_weather`: Condizioni meteo attuali, previsioni fino a 10 giorni, vento, umidità e probabilità di precipitazioni.
* `resolve_names`: Risoluzione di toponimi o query geografiche informali in entità canoniche Google Maps.
* `resolve_maps_urls`: Decodifica di URL brevi di Google Maps (`maps.app.goo.gl`) in Place ID canonici.

---

## 2. Architettura e Sicurezza

1. **Endpoint Ufficiale Diretto**:
   - Connessione diretta sicura su `https://mapstools.googleapis.com/mcp`.
   - Nessun wrapper o codice di terze parti in locale.
2. **Autenticazione**:
   - Autenticato tramite API Key Google Cloud Platform con header `X-Goog-Api-Key` o parametro URL `?key=`.
   - Chiave salvata in locale in `~/.config/pos/google.env` (permessi 600).
   - Raccomandata restrizione su GCP alla sola API **Maps Grounding Lite API**.
