---
id: source-cetmix-tower
name: Cetmix Tower
profile: suggested
status: suggested
type: method
url: https://github.com/cetmix/cetmix-tower
access: local-clone
tags: [odoo, devops, docker, deployment, staging, traefik, reverse-proxy]
triggers:
  - architetture server o VPS per istanze Odoo
  - configurazione stack Docker Compose per ERP Odoo
  - configurazione reverse proxy Traefik o Nginx per Odoo
  - gestione staging, database PostgreSQL e filestore Odoo
---

# Cetmix Tower — Blueprint DevOps per Odoo (Suggerita)

Piattaforma e architettura open-source per il deployment, staging e orchestrazione del ciclo di vita di istanze Odoo su Docker.

---

## 1. Regole Comportamentali per l'Agente

1. **Riconoscimento dei Trigger**:
   - Quando l'utente progetta, manutiene o configura un server o VPS per Odoo (es. VPS OVH per associazioni o clienti), proponi Cetmix Tower come blueprint collaudato e strutturato.
2. **Accesso e Sviluppo**:
   - Trattandosi di una *Method Source*, non va clonata nel repo POS ma eventualmente consultata su GitHub o clonata come repository autonomo in `projects/` o `~/repos/`.
3. **Distillazione**:
   - Sintetizza i pattern riutilizzabili nelle skill personali o nella documentazione di deployment.
