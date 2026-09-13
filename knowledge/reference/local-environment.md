# Local Environment — Reference

> **L'Asse Macchina del POS.** Il POS separa nettamente la base operativa comune
> (il framework) dall'istanza personale. Ma poiché la stessa persona può sincronizzare
> il proprio repository privato su più macchine fisiche o virtuali diverse (es. workstation,
> laptop, VM locale, VPS), lo **scenario macchina** e i tool a disposizione si **rilevano**,
> non si dichiarano a mano.

---

## 1. Indice

- [Cosa vive qui e cosa vive nel profilo macchina](#2-cosa-vive-qui-e-cosa-vive-nel-profilo-macchina)
- [Come rilevare la macchina e lo scenario](#3-come-rilevare-la-macchina-e-lo-scenario)
- [Scenari supportati (VM, WSL2, Linux, macOS, Termux)](#4-scenari-supportati)
- [La cartella `machines/` nel repository personale](#5-la-cartella-machines-nel-repository-personale)
- [Convenzioni sui tool locali e la variabile PATH](#6-convenzioni-sui-tool-locali-e-la-variabile-path)
- [Audit continuo e monitoraggio dello stato di deploy](#7-audit-continuo-e-monitoraggio-dello-stato-di-deploy)

---

## 2. Cosa vive qui e cosa vive nel profilo macchina

Tre file toccano l'ambiente e non devono mai sovrapporsi:

| File | Ambito | Esempio di informazione |
|---|---|---|
| **`knowledge/reference/local-environment.md`** (questo file) | **Regole generali sullo scenario**: OS, PATH, architettura cross-platform | «su WSL2 i workspace vivono nel filesystem Linux e non sotto `/mnt/c/`» |
| **`personal/<instance>/machines/<id>.md`** | **Profilo di UNA specifica macchina**: risorse hardware reali, tool installati, compiti del nodo, debiti locali | «su `stesi-workspace`: 4 vCPU, 7.8 GiB RAM, Docker 29 attivo, Claude Code 2.1.270» |
| **`setup/status.sh`** | **Script di audit dinamico**: verifica istantanea dello stato di salute locale | Esecuzione live di controlli su git, zvec-grep, chiavi e versioni |

> **Regola**: Se un fatto vale per **chiunque** si trovi su quello scenario (es. su Ubuntu o su macOS), va in questo reference. Se vale solo per **quella specifica macchina**, va nel profilo macchina `machines/<id>.md`.

---

## 3. Come rilevare la macchina e lo scenario

Lo scenario non va mai scritto a memoria, perché una configurazione manuale invecchia e causa errori:

```bash
# Esempio di rilevamento (usato da setup/bootstrap.sh e setup/status.sh)
detect_machine_id() {
    # Slug normalizzato dell'hostname (es. "stesi-workspace", "laptop-dell")
    hostname -s 2>/dev/null || hostname 2>/dev/null || echo "unknown"
}

detect_env_scenario() {
    # Risolve: mac | termux | wsl | vm | linux
    case "$(uname -s)" in
        Darwin) echo "mac"; return ;;
    esac
    if [ -n "${TERMUX_VERSION:-}" ] || [[ "${PREFIX:-}" == *com.termux* ]]; then
        echo "termux"; return
    fi
    if [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi microsoft /proc/version 2>/dev/null; then
        echo "wsl"; return
    fi
    local virt
    virt=$(systemd-detect-virt 2>/dev/null || echo none)
    if [ -n "$virt" ] && [ "$virt" != "none" ]; then
        echo "vm ($virt)"; return
    fi
    echo "linux"
}
```

---

## 4. Scenari supportati

### Scenario: VM Linux (KVM / Proxmox / VirtualBox)
- Tipica per ambienti di sviluppo isolati o server di staging (es. `stesi-workspace`).
- Le risorse (CPU/RAM/Swap) sono assegnate dall'hypervisor.
- Docker e i demoni (es. cron, systemd, dockge) girano nativamente come servizi di sistema.

### Scenario: WSL2 (Windows Subsystem for Linux)
- Il workspace DEVE risiedere nel filesystem ext4 Linux (`~/personal-workspace`), **mai** sotto il mount Windows `/mnt/c/...` (altrimenti le performance di Git, node_modules e vector index degradano drasticamente).
- La cifratura a riposo è delegata a BitLocker sul volume host Windows.

### Scenario: macOS (Apple Silicon / Intel)
- Shell di login predefinita: `zsh` (`~/.zshrc`). Attenzione: macOS **non** esegue `~/.bashrc` all'avvio del terminale.
- Package manager principale: Homebrew (`brew`).
- Cifratura disco: FileVault gestito nativamente.

### Scenario: Linux Bare-Metal
- Accesso diretto all'hardware senza layer di virtualizzazione.
- Cifratura a riposo raccomandata via LUKS/dm-crypt su partizioni LVM.

---

## 5. La cartella `machines/` nel repository personale

Poiché il repository personale viene sincronizzato via Git tra più macchine (es. portatile per trasferte, workstation fissa, server domestico o VM di lavoro):
- Non esiste un generico file "la-mia-macchina.md" (entrerebbe in conflitto continuo di merge ad ogni pull/push).
- Ogni macchina scrive **esclusivamente il proprio file**: `machines/<id>.md` (es. `machines/stesi-workspace.md`, `machines/macbook-air.md`).
- In questo modo l'albero `machines/` è **puramente additivo**: non genera mai conflitti Git e offre una panoramica chiara di tutti i nodi operativi a disposizione dell'utente.

---

## 6. Convenzioni sui tool locali e la variabile PATH

1. **Binari utente in `~/.local/bin`**:
   - I tool utente senza privilegi di root (come `zg`, `zvgrep`, `gitleaks`) vengono installati in `$HOME/.local/bin`.
   - `bootstrap.sh` si assicura che `~/.local/bin` sia presente in `PATH` all'interno del file rc della shell (`~/.bashrc` o `~/.zshrc`).
2. **Node.js e NVM**:
   - Molti assistenti e tool invocano sotto-shell non interattive dove le funzioni NVM non sono attive.
   - I wrapper come `zg` risolvono dinamicamente il percorso di Node scansionando le directory NVM presenti, garantendo l'esecuzione anche in contesti headless o daemon.

---

## 7. Audit continuo e monitoraggio dello stato di deploy

Prima di iniziare un lavoro significativo o all'avvio di una sessione in cui si usano tool di sistema:
1. Esegui:
   ```bash
   bash setup/status.sh
   # oppure
   bash setup/bootstrap.sh --check
   ```
2. Lo script effettua un check completo su:
   - Allineamento e pulizia Git di framework e istanza personale.
   - Profilo macchina corrente (`machines/<id>.md`).
   - Risorse hardware (vCPU, RAM disponibile, spazio disco residuo).
   - Tool installati e versioni (Node, Python, Docker, Claude, Antigravity).
   - Stato dell'indice vettoriale semantico (`.zvec-grep/index.zvec`).
   - Hook pre-push di sicurezza.
