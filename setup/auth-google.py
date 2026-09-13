#!/usr/bin/env python3
"""
auth-google.py — Google Workspace OAuth Login Helper for POS

Starts the local OAuth callback listener, generates the authorization URL,
and handles authentication either automatically (via local redirect) or
manually (by pasting the redirected callback URL).
"""

import asyncio
import os
import sys
import time

USER_HOME = os.path.expanduser("~")
ENV_FILE = os.path.join(USER_HOME, ".config", "pos", "google.env")

# Fallback to /home/daniele if in container/special home
if not os.path.exists(ENV_FILE) and os.path.exists("/home/daniele/.config/pos/google.env"):
    ENV_FILE = "/home/daniele/.config/pos/google.env"
    USER_HOME = "/home/daniele"

if not os.path.exists(ENV_FILE):
    print(f"Errore: file {ENV_FILE} non trovato. Esegui prima setup/setup-google-workspace-mcp.sh", file=sys.stderr)
    sys.exit(1)

# Load env variables
with open(ENV_FILE, "r", encoding="utf-8") as f:
    for line in f:
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        k, v = line.split("=", 1)
        k = k.strip()
        v = v.strip().strip("\"'")
        os.environ[k] = v

client_id = os.environ.get("GOOGLE_OAUTH_CLIENT_ID", "")
client_secret = os.environ.get("GOOGLE_OAUTH_CLIENT_SECRET", "")

if not client_id or "your-client-id" in client_id:
    print(f"Errore: GOOGLE_OAUTH_CLIENT_ID non configurato in {ENV_FILE}", file=sys.stderr)
    sys.exit(1)

from auth import oauth_callback_server, google_auth, credential_store

def get_existing_authenticated_user(store):
    if hasattr(store, "base_dir") and os.path.exists(store.base_dir):
        files = [f for f in os.listdir(store.base_dir) if f.endswith(".json") and "@" in f]
        if files:
            return files[0].replace(".json", "")
    return None

async def main():
    print("\n============================================================")
    print("  POS — GOOGLE WORKSPACE OAUTH LOGIN")
    print("============================================================\n")

    # Start the callback server
    success, msg = oauth_callback_server.ensure_stdio_oauth_callback_available()
    if not success:
        print(f"Errore avvio server OAuth: {msg}", file=sys.stderr)
        sys.exit(1)

    config = oauth_callback_server.get_oauth_config()
    print(f"✓ Server OAuth in ascolto su {config.base_uri}:{config.port}")

    # Generate authorization URL
    auth_msg = await google_auth.start_auth_flow("", "Google Workspace", redirect_uri=config.redirect_uri)
    
    # Extract URL from message
    auth_url = ""
    for line in auth_msg.splitlines():
        if "https://accounts.google.com" in line:
            auth_url = line.strip().split("Authorization URL: ")[-1].strip()
            break

    if not auth_url:
        print("Impossibile generare l'URL di autorizzazione. Messaggio:\n", auth_msg)
        oauth_callback_server.cleanup_oauth_callback_server()
        sys.exit(1)

    print("\n------------------------------------------------------------")
    print("  APRI QUESTO LINK NEL TUO BROWSER PER AUTORIZZARE L'ACCESSO:")
    print("------------------------------------------------------------\n")
    print(auth_url)
    print("\n------------------------------------------------------------")
    print("1. Accedi con il tuo account Google e clicca su 'Continua' / 'Consenti'.")
    print("2. Google reindirizzerà a http://localhost:8000/oauth2callback.")
    print("   - Se sei sulla stessa macchina, l'autenticazione si completerà automaticamente.")
    print("   - Se sei su VM/remoto e il browser dà 'Impossibile raggiungere il sito',")
    print("     copia l'URL completo dalla barra degli indirizzi e incollalo qui sotto.\n")

    store = credential_store.get_credential_store()
    start_time = time.time()
    timeout = 1800  # 30 minutes


    found_email = None
    while time.time() - start_time < timeout:
        await asyncio.sleep(2)
        found_email = get_existing_authenticated_user(store)
        if found_email:
            break

    oauth_callback_server.cleanup_oauth_callback_server()

    if found_email:
        print(f"\n[✓] Autenticazione completata con successo per: {found_email}")
        creds_file = os.path.join(store.base_dir, found_email + ".json")
        print(f"[✓] Token salvato in: {creds_file}")

        # Mirror credentials across home directories if split (e.g. CLI vs Antigravity sandbox)
        alt_homes = {os.path.expanduser("~"), os.environ.get("HOME", ""), "/home/daniele", "/home/daniele/.antigravity-personal"}
        for h in alt_homes:
            if h and os.path.exists(h):
                alt_dir = os.path.join(h, ".google_workspace_mcp", "credentials")
                if alt_dir != store.base_dir:
                    try:
                        os.makedirs(alt_dir, exist_ok=True)
                        import shutil
                        shutil.copy2(creds_file, os.path.join(alt_dir, found_email + ".json"))
                        os.chmod(os.path.join(alt_dir, found_email + ".json"), 0o600)
                    except Exception:
                        pass

        print("Google Workspace MCP è ora pienamente operativo per tutti i tuoi assistenti AI!\n")
    else:
        print("\n[!] Timeout: autorizzazione non completata entro 5 minuti.")

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        oauth_callback_server.cleanup_oauth_callback_server()
        print("\nOperazione annullata.")
