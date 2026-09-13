#!/usr/bin/env python3
"""
classeviva-cli.py — Spaggiari ClasseViva CLI for Personal Operating System (POS)

Provides command-line and AI-agent access to Spaggiari ClasseViva electronic school register:
- Homework / Agenda (compiti)
- Noticeboard / Circulars (bacheca e circolari)
- Today's lessons / topics covered (lezioni)
- Grades (voti)

Supports both Parent accounts (G... with multiple children) and Student accounts (S...).
Reads credentials securely from ~/.config/pos/classeviva.env (mode 600, outside Git).
"""

import argparse
import datetime
import json
import os
import sys
from typing import Any, Dict, List, Optional
import urllib.error
import urllib.parse
import urllib.request


BASE_URL = "https://web.spaggiari.eu/rest"
DEFAULT_HEADERS = {
    "User-Agent": "CVVS/std/4.2.3 Android/12",
    "Z-Dev-ApiKey": "Tg1NWEwNGIgIC0K",
    "Content-Type": "application/json"
}


def get_env_file_path() -> str:
    user_home = os.path.expanduser("~")
    path = os.path.join(user_home, ".config", "pos", "classeviva.env")
    if not os.path.exists(path) and os.path.exists("/home/daniele/.config/pos/classeviva.env"):
        return "/home/daniele/.config/pos/classeviva.env"
    return path


def load_config() -> Dict[str, str]:
    env_file = get_env_file_path()
    config = {
        "CLASSEVIVA_USERNAME": "",
        "CLASSEVIVA_PASSWORD": "",
        "CLASSEVIVA_DEFAULT_STUDENT": ""
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


class ClasseVivaClient:
    def __init__(self, username: str, password: str):
        self.username = username
        self.password = password
        self.token: Optional[str] = None
        self.user_data: Dict[str, Any] = {}
        self.cards: List[Dict[str, Any]] = []

    def _request(self, method: str, endpoint: str, data: Optional[Dict[str, Any]] = None) -> Any:
        url = f"{BASE_URL}{endpoint}" if endpoint.startswith("/") else endpoint
        headers = dict(DEFAULT_HEADERS)
        if self.token:
            headers["Z-Auth-Token"] = self.token

        body_bytes = None
        if data is not None:
            body_bytes = json.dumps(data).encode("utf-8")

        req = urllib.request.Request(url, data=body_bytes, headers=headers, method=method)
        try:
            with urllib.request.urlopen(req, timeout=15) as resp:
                content_type = resp.headers.get("Content-Type", "")
                res_body = resp.read()
                if "application/json" in content_type:
                    return json.loads(res_body.decode("utf-8"))
                return res_body
        except urllib.error.HTTPError as e:
            err_body = e.read().decode("utf-8", errors="replace")
            try:
                err_json = json.loads(err_body)
                raise RuntimeError(f"HTTP {e.code}: {err_json.get('error', err_body)}")
            except Exception:
                raise RuntimeError(f"HTTP {e.code}: {err_body}")
        except urllib.error.URLError as e:
            raise RuntimeError(f"Network error connecting to ClasseViva: {e.reason}")

    def login(self) -> None:
        payload = {
            "ident": None,
            "pass": self.password,
            "uid": self.username
        }
        res = self._request("POST", "/v1/auth/login", data=payload)
        self.user_data = res
        self.token = res.get("token")
        if not self.token:
            raise RuntimeError("Authentication failed: token not found in response.")

        # Discover cards (children if parent, or student profile)
        clean_id = self.username.lstrip("SGsg")
        try:
            cards_res = self._request("GET", f"/v1/students/{clean_id}/cards")
            self.cards = cards_res.get("cards", [])
        except Exception:
            self.cards = []

        if not self.cards:
            # Fallback card for direct student account
            self.cards = [{
                "ident": self.username,
                "usrId": clean_id,
                "firstName": res.get("firstName", ""),
                "lastName": res.get("lastName", ""),
                "schName": "Scuola"
            }]

    def get_target_students(self, filter_student: Optional[str] = None) -> List[Dict[str, Any]]:
        if not self.cards:
            return []
        if not filter_student:
            return self.cards

        filt = filter_student.lower().strip()
        matched = [
            c for c in self.cards
            if filt in c.get("firstName", "").lower()
            or filt in c.get("lastName", "").lower()
            or filt == str(c.get("usrId", ""))
            or filt in c.get("ident", "").lower()
        ]
        return matched if matched else self.cards

    def get_agenda(self, student_id: str, start_date: str, end_date: str) -> List[Dict[str, Any]]:
        # Dates expected as YYYYMMDD in URL path
        s_clean = start_date.replace("-", "")
        e_clean = end_date.replace("-", "")
        res = self._request("GET", f"/v1/students/{student_id}/agenda/all/{s_clean}/{e_clean}")
        return res.get("agenda", [])

    def get_noticeboard(self, student_id: str) -> List[Dict[str, Any]]:
        res = self._request("GET", f"/v1/students/{student_id}/noticeboard")
        return res.get("items", [])

    def get_lessons(self, student_id: str, day: Optional[str] = None) -> List[Dict[str, Any]]:
        if not day:
            day = datetime.date.today().strftime("%Y%m%d")
        else:
            day = day.replace("-", "")
        res = self._request("GET", f"/v1/students/{student_id}/lessons/{day}")
        return res.get("lessons", [])

    def get_grades(self, student_id: str) -> List[Dict[str, Any]]:
        res = self._request("GET", f"/v1/students/{student_id}/grades")
        return res.get("grades", [])


def print_status(client: ClasseVivaClient, as_json: bool = False):
    info = {
        "authenticated": bool(client.token),
        "username": client.username,
        "name": f"{client.user_data.get('firstName', '')} {client.user_data.get('lastName', '')}".strip(),
        "release": client.user_data.get("release"),
        "expire": client.user_data.get("expire"),
        "students": [
            {
                "name": f"{c.get('firstName', '')} {c.get('lastName', '')}".strip(),
                "student_id": c.get("usrId"),
                "ident": c.get("ident"),
                "school": f"{c.get('schName', '')} {c.get('schDedication', '')}".strip()
            }
            for c in client.cards
        ]
    }
    if as_json:
        print(json.dumps(info, indent=2, ensure_ascii=False))
        return

    print("\n============================================================")
    print("  CLASSEVIVA — STATO CONNESSIONE")
    print("============================================================")
    print(f"Utente:    {info['username']} ({info['name']})")
    print(f"Sessione:  Scadenza {info['expire']}")
    print(f"Studenti associati ({len(info['students'])}):")
    for s in info["students"]:
        print(f"  • {s['name']} (ID: {s['student_id']}) — {s['school']}")
    print("")


def print_compiti(client: ClasseVivaClient, students: List[Dict[str, Any]], days: int = 7, as_json: bool = False):
    today = datetime.date.today()
    end = today + datetime.timedelta(days=days)
    s_date = today.strftime("%Y-%m-%d")
    e_date = end.strftime("%Y-%m-%d")

    all_results = {}
    for st in students:
        s_id = str(st.get("usrId"))
        s_name = f"{st.get('firstName', '')} {st.get('lastName', '')}".strip()
        agenda = client.get_agenda(s_id, s_date, e_date)
        
        # Filter homework entries (AGHW) or keep all
        homework = [
            item for item in agenda
            if item.get("evtCode") == "AGHW" or "compit" in item.get("notes", "").lower()
        ]
        # Sort by begin date
        homework.sort(key=lambda x: x.get("evtDatetimeBegin", ""))
        all_results[s_name] = homework

    if as_json:
        print(json.dumps(all_results, indent=2, ensure_ascii=False))
        return

    print(f"\n============================================================")
    print(f"  CLASSEVIVA — COMPITI IN AGENDA ({s_date} → {e_date})")
    print(f"============================================================")
    for s_name, items in all_results.items():
        print(f"\n🎓 {s_name} ({len(items)} compiti trovati):")
        if not items:
            print("   Nessun compito registrato nel periodo.")
            continue
        for it in items:
            dt = it.get("evtDatetimeBegin", "")[:10]
            subj = it.get("subjectDesc", "Varie")
            teacher = it.get("authorName", "")
            notes = it.get("notes", "").strip()
            print(f"  [{dt}] {subj} (Prof. {teacher})")
            print(f"    📝 {notes}")
    print("")


def print_bacheca(client: ClasseVivaClient, students: List[Dict[str, Any]], limit: int = 10, as_json: bool = False):
    all_results = {}
    for st in students:
        s_id = str(st.get("usrId"))
        s_name = f"{st.get('firstName', '')} {st.get('lastName', '')}".strip()
        items = client.get_noticeboard(s_id)
        items.sort(key=lambda x: x.get("pubDT", ""), reverse=True)
        all_results[s_name] = items[:limit]

    if as_json:
        print(json.dumps(all_results, indent=2, ensure_ascii=False))
        return

    print(f"\n============================================================")
    print(f"  CLASSEVIVA — COMUNICAZIONI IN BACHECA & CIRCOLARI (Ultime {limit})")
    print(f"============================================================")
    for s_name, items in all_results.items():
        print(f"\n📢 {s_name} ({len(items)} comunicazioni):")
        if not items:
            print("   Nessuna comunicazione in bacheca.")
            continue
        for it in items:
            dt = it.get("pubDT", "")[:10]
            cat = it.get("cntCategory", "Avviso")
            title = it.get("cntTitle", "").strip()
            has_attach = it.get("cntHasAttach", False)
            attach_str = " 📎 [Allegato PDF]" if has_attach else ""
            read_str = "✓" if it.get("readStatus") else "● [Nuovo]"
            print(f"  [{dt}] {read_str} ({cat}) {title}{attach_str}")
    print("")


def print_lezioni(client: ClasseVivaClient, students: List[Dict[str, Any]], day: Optional[str] = None, as_json: bool = False):
    target_day = day or datetime.date.today().strftime("%Y-%m-%d")
    all_results = {}
    for st in students:
        s_id = str(st.get("usrId"))
        s_name = f"{st.get('firstName', '')} {st.get('lastName', '')}".strip()
        lessons = client.get_lessons(s_id, target_day)
        all_results[s_name] = lessons

    if as_json:
        print(json.dumps(all_results, indent=2, ensure_ascii=False))
        return

    print(f"\n============================================================")
    print(f"  CLASSEVIVA — LEZIONI ED ARGOMENTI ({target_day})")
    print(f"============================================================")
    for s_name, items in all_results.items():
        print(f"\n📚 {s_name} ({len(items)} lezioni registrate):")
        if not items:
            print("   Nessuna lezione registrata per oggi.")
            continue
        for it in items:
            hour = it.get("hour", "")
            subj = it.get("subjectDesc", "")
            teacher = it.get("authorName", "")
            lesson_arg = it.get("lessonArg", "").strip()
            print(f"  Ora {hour}: {subj} ({teacher})")
            if lesson_arg:
                print(f"    📖 Argomento: {lesson_arg}")
    print("")


def print_voti(client: ClasseVivaClient, students: List[Dict[str, Any]], limit: int = 15, as_json: bool = False):
    all_results = {}
    for st in students:
        s_id = str(st.get("usrId"))
        s_name = f"{st.get('firstName', '')} {st.get('lastName', '')}".strip()
        grades = client.get_grades(s_id)
        grades.sort(key=lambda x: x.get("evtDate", ""), reverse=True)
        all_results[s_name] = grades[:limit]

    if as_json:
        print(json.dumps(all_results, indent=2, ensure_ascii=False))
        return

    print(f"\n============================================================")
    print(f"  CLASSEVIVA — RECENTI VALUTAZIONI (Ultime {limit})")
    print(f"============================================================")
    for s_name, items in all_results.items():
        print(f"\n📊 {s_name} ({len(items)} voti):")
        if not items:
            print("   Nessuna valutazione registrata.")
            continue
        for it in items:
            dt = it.get("evtDate", "")[:10]
            subj = it.get("subjectDesc", "")
            val = it.get("displayValue", "")
            notes = it.get("notesForFamily", "") or it.get("notes", "")
            component = it.get("componentDesc", "")
            print(f"  [{dt}] {subj}: VOTO {val} ({component})")
            if notes:
                print(f"    Nota docente: {notes}")
    print("")


def main():
    parser = argparse.ArgumentParser(description="Spaggiari ClasseViva CLI for Personal Operating System")
    parser.add_argument("command", choices=["status", "compiti", "bacheca", "lezioni", "voti"], help="Comando da eseguire")
    parser.add_argument("--figlia", "--student", dest="student", help="Nome o ID studente su cui filtrare")
    parser.add_argument("--giorni", dest="days", type=int, default=7, help="Numero di giorni per i compiti in agenda (default: 7)")
    parser.add_argument("--giorno", dest="day", help="Data specifica (YYYY-MM-DD) per le lezioni del giorno")
    parser.add_argument("--limite", dest="limit", type=int, default=10, help="Limite di elementi per bacheca/voti")
    parser.add_argument("--json", action="store_true", help="Output in formato JSON per assistenti AI")

    args = parser.parse_args()

    config = load_config()
    username = config.get("CLASSEVIVA_USERNAME")
    password = config.get("CLASSEVIVA_PASSWORD")
    default_student = args.student or config.get("CLASSEVIVA_DEFAULT_STUDENT")

    if not username or not password or "your-" in username or "your-" in password:
        env_file = get_env_file_path()
        print(f"Errore: Credenziali ClasseViva non configurate in {env_file}.", file=sys.stderr)
        print(f"Copia il template da setup/templates/classeviva.env.template e inserisci username e password.", file=sys.stderr)
        sys.exit(1)

    client = ClasseVivaClient(username, password)
    try:
        client.login()
    except Exception as e:
        print(f"Errore autenticazione ClasseViva: {e}", file=sys.stderr)
        sys.exit(1)

    target_students = client.get_target_students(default_student)

    if args.command == "status":
        print_status(client, as_json=args.json)
    elif args.command == "compiti":
        print_compiti(client, target_students, days=args.days, as_json=args.json)
    elif args.command == "bacheca":
        print_bacheca(client, target_students, limit=args.limit, as_json=args.json)
    elif args.command == "lezioni":
        print_lezioni(client, target_students, day=args.day, as_json=args.json)
    elif args.command == "voti":
        print_voti(client, target_students, limit=args.limit, as_json=args.json)


if __name__ == "__main__":
    main()
