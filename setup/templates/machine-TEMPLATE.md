# Macchina: <id>

<!-- Profilo di UNA macchina. Un file per macchina, nome = detect_machine_id()
     (slug dell'hostname). Il repo personale è sincronizzato via git tra le
     macchine: ognuna scrive SOLO il proprio file, così non si sovrascrivono.
     Convenzione completa: knowledge/reference/local-environment.md -->

scenario: <wsl | vm | mac | termux | linux>
os: <es. Ubuntu 24.04.4 LTS / macOS 15.2>
ultimo_aggiornamento: <AAAA-MM-GG>

## A cosa serve questa macchina

<1–3 righe: è la macchina principale? portatile per trasferte? server/VPS?
Serve all'assistente per capire il ruolo di questo nodo nel parco macchine.>

## Risorse Hardware

- **CPU**: <es. 4 vCPU / x86_64>
- **RAM**: <es. 7.8 GiB / Swap: 4.0 GiB>
- **Disco**: <es. 124 GB (53 GB disponibili)>

## Tool e Ambienti Locali

- **Node.js**: <versione o assente>
- **Python**: <versione o assente>
- **Docker**: <versione o assente>
- **Assistenti AI**: <Claude Code / Antigravity CLI / Codex CLI>
- **zvec-grep (zg)**: <versione o assente, stato indice locale>
- **Hook pre-push**: <attivo (gitleaks) | assente>

## Specificità di questa macchina

<Solo ciò che NON è generalizzabile. Se vale per chiunque su questo scenario,
va in knowledge/reference/local-environment.md.
Esempi:
- porte di rete locali utilizzate
- percorsi non standard o mount esterni
- configurazioni speciali per editor o terminali>

## Da sistemare / Debito noto

<Debito noto su questa macchina: tool mancanti, versioni disallineate,
configurazioni temporanee da ripulire.>

<!-- NIENTE SEGRETI: token, password, chiavi private, stringhe di connessione.
     Il repo è su GitHub; lo scan gitleaks è una rete di sicurezza, non il
     motivo per cui non si scrivono. -->
