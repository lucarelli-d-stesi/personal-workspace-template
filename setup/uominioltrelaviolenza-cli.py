#!/usr/bin/env python3
"""
uominioltrelaviolenza-cli.py — Odoo SaaS CLI for Blog Uomini Oltre la Violenza
Personal Operating System (POS)

Provides command-line and AI-agent access to Odoo SaaS (odoo.com) for managing
blog posts, drafts, and publication on uominioltrelaviolenza.it.
Reads credentials securely from ~/.config/pos/uominioltrelaviolenza.env (mode 600, outside Git).
"""

import argparse
import html
import json
import os
import re
import sys
from typing import Any, Dict, List, Optional
import xmlrpc.client


def get_env_file_path() -> str:
    user_home = os.path.expanduser("~")
    candidates = [
        os.path.join(user_home, ".config", "pos", "uominioltrelaviolenza.env"),
        "/home/daniele/.config/pos/uominioltrelaviolenza.env",
        "/home/daniele/.antigravity-personal/.config/pos/uominioltrelaviolenza.env"
    ]
    for path in candidates:
        if os.path.exists(path):
            return path
    return candidates[0]


def load_config() -> Dict[str, str]:
    env_file = get_env_file_path()
    config = {
        "ODOO_URL": "https://www.uominioltrelaviolenza.it",
        "ODOO_DB": "uominioltrelaviolenza",
        "ODOO_USER": "",
        "ODOO_API_KEY": ""
    }
    if not os.path.exists(env_file):
        return config

    with open(env_file, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, v = line.split("=", 1)
            k = k.strip()
            v = v.strip().strip("\"'")
            if k in config:
                config[k] = v
    return config


class OdooClient:
    def __init__(self, url: str, db: str, user: str, api_key: str):
        self.url = url.rstrip("/")
        self.db = db
        self.user = user
        self.api_key = api_key
        self.uid: Optional[int] = None
        self._common = xmlrpc.client.ServerProxy(f"{self.url}/xmlrpc/2/common")
        self._models = xmlrpc.client.ServerProxy(f"{self.url}/xmlrpc/2/object")

    def authenticate(self) -> int:
        try:
            self.uid = self._common.authenticate(self.db, self.user, self.api_key, {})
            if not self.uid:
                raise RuntimeError("Authentication failed: invalid credentials.")
            return self.uid
        except Exception as e:
            raise RuntimeError(f"Odoo XML-RPC authentication error: {e}")

    def execute(self, model: str, method: str, *args, **kwargs) -> Any:
        if not self.uid:
            self.authenticate()
        return self._models.execute_kw(self.db, self.uid, self.api_key, model, method, list(args), kwargs)

    def get_version(self) -> Dict[str, Any]:
        try:
            return self._common.version()
        except Exception:
            return {}


def strip_html_tags(text: str) -> str:
    clean = re.compile('<.*?>')
    return html.unescape(re.sub(clean, '', text))


def print_status(client: OdooClient, as_json: bool = False):
    uid = client.authenticate()
    user_info = client.execute("res.users", "read", [uid], fields=["name", "login", "email"])
    version_info = client.get_version()
    post_count = client.execute("blog.post", "search_count", [])
    published_count = client.execute("blog.post", "search_count", [["website_published", "=", True]])

    data = {
        "connected": True,
        "url": client.url,
        "db": client.db,
        "server_version": version_info.get("server_version"),
        "user": user_info[0] if user_info else {},
        "total_posts": post_count,
        "published_posts": published_count,
        "draft_posts": post_count - published_count
    }

    if as_json:
        print(json.dumps(data, indent=2, ensure_ascii=False))
        return

    print("\n============================================================")
    print("  ODOO SAAS — UOMINI OLTRE LA VIOLENZA (STATO CONNESSIONE)")
    print("============================================================")
    print(f"URL:              {data['url']}")
    print(f"Database:         {data['db']}")
    print(f"Versione Server:  Odoo {data['server_version']}")
    u = data["user"]
    print(f"Utente collegato: {u.get('name')} <{u.get('login')}> (UID: {u.get('id')})")
    print(f"Articoli totali:  {data['total_posts']} ({data['published_posts']} pubblicati, {data['draft_posts']} bozze)")
    print("")


def print_posts(client: OdooClient, limit: int = 20, drafts_only: bool = False, published_only: bool = False, as_json: bool = False):
    domain = []
    if drafts_only:
        domain.append(["website_published", "=", False])
    elif published_only:
        domain.append(["website_published", "=", True])

    fields = ["id", "name", "subtitle", "published_date", "website_published", "author_name", "visits"]
    posts = client.execute("blog.post", "search_read", domain, fields=fields, limit=limit, order="published_date desc, id desc")

    if as_json:
        print(json.dumps(posts, indent=2, ensure_ascii=False))
        return

    print("\n============================================================")
    print(f"  ARTICOLI BLOG — UOMINI OLTRE LA VIOLENZA (Primi {len(posts)})")
    print("============================================================")
    for p in posts:
        pub = "🟢 [Pubblicato]" if p.get("website_published") else "🟡 [Bozza]"
        dt = (p.get("published_date") or "Nessuna data")[:16]
        author = p.get("author_name") or "Daniele Lucarelli"
        visits = p.get("visits", 0)
        print(f"ID {p['id']}: {pub} {p['name']}")
        if p.get("subtitle"):
            print(f"    Sottotitolo: {p['subtitle']}")
        print(f"    Data: {dt} | Autore: {author} | Visite: {visits}")
    print("")


def print_post_detail(client: OdooClient, post_id: int, as_json: bool = False):
    fields = ["id", "name", "subtitle", "published_date", "website_published", "author_name", "content", "website_url"]
    records = client.execute("blog.post", "read", [post_id], fields=fields)
    if not records:
        print(f"Errore: Nessun articolo trovato con ID {post_id}", file=sys.stderr)
        sys.exit(1)

    post = records[0]
    if as_json:
        print(json.dumps(post, indent=2, ensure_ascii=False))
        return

    print("\n============================================================")
    print(f"  DETTAGLIO ARTICOLO ID {post['id']}")
    print("============================================================")
    print(f"Titolo:       {post['name']}")
    print(f"Sottotitolo:  {post.get('subtitle') or '-'}")
    print(f"Stato:        {'Pubblicato' if post.get('website_published') else 'Bozza'}")
    print(f"Data:         {post.get('published_date') or '-'}")
    print(f"Autore:       {post.get('author_name') or '-'}")
    print(f"URL:          {client.url}{post.get('website_url', '')}")
    print("\n--- CONTENUTO (Testo) ---\n")
    print(strip_html_tags(post.get("content") or "").strip()[:4000])
    print("")


def main():
    parser = argparse.ArgumentParser(description="Odoo SaaS CLI for Uomini Oltre la Violenza")
    subparsers = parser.add_subparsers(dest="command", required=True)

    # Status
    p_status = subparsers.add_parser("status", help="Verifica connessione e dati utente")
    p_status.add_argument("--json", action="store_true", help="Output JSON")

    # Posts
    p_posts = subparsers.add_parser("posts", help="Elenca articoli del blog")
    p_posts.add_argument("--limit", type=int, default=20, help="Limite articoli")
    p_posts.add_argument("--bozze", dest="drafts", action="store_true", help="Solo bozze")
    p_posts.add_argument("--pubblicati", dest="published", action="store_true", help="Solo pubblicati")
    p_posts.add_argument("--json", action="store_true", help="Output JSON")

    # Get
    p_get = subparsers.add_parser("get", help="Visualizza dettaglio e contenuto di un articolo")
    p_get.add_argument("post_id", type=int, help="ID articolo")
    p_get.add_argument("--json", action="store_true", help="Output JSON")

    args = parser.parse_args()

    config = load_config()
    user = config.get("ODOO_USER")
    api_key = config.get("ODOO_API_KEY")
    url = config.get("ODOO_URL")
    db = config.get("ODOO_DB")

    if not user or not api_key:
        print(f"Errore: Credenziali Odoo non configurate in {get_env_file_path()}.", file=sys.stderr)
        sys.exit(1)

    client = OdooClient(url, db, user, api_key)

    if args.command == "status":
        print_status(client, as_json=args.json)
    elif args.command == "posts":
        print_posts(client, limit=args.limit, drafts_only=args.drafts, published_only=args.published, as_json=args.json)
    elif args.command == "get":
        print_post_detail(client, args.post_id, as_json=args.json)


if __name__ == "__main__":
    main()
