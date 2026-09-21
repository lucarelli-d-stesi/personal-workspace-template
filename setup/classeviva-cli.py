#!/usr/bin/env python3
"""
classeviva-cli.py — Spaggiari ClasseViva CLI for Personal Operating System (POS)

Provides command-line and AI-agent access to Spaggiari ClasseViva electronic school register:
- Homework / Agenda (compiti)
- Noticeboard / Circulars (bacheca e circolari)
- Today's lessons / topics covered (lezioni)
- Grades (voti)

Supports Parent accounts (email or G... with automatic discovery of multiple children)
and Student accounts (S...).
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
    return os.path.join(user_home, ".config", "pos", "classeviva.env")


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
        self.sessions: Dict[str, Dict[str, Any]] = {}
        self.account_name: str = ""

    def _request(self, method: str, endpoint: str, data: Optional[Dict[str, Any]] = None, token: Optional[str] = None) -> Any:
        url = f"{BASE_URL}{endpoint}" if endpoint.startswith("/") else endpoint
        headers = dict(DEFAULT_HEADERS)
        if token:
            headers["Z-Auth-Token"] = token

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

        # Case 1: Multiple choices (e.g. parent account with multiple daughters)
        if "choices" in res and res.get("choices"):
            for ch in res["choices"]:
                ident = ch.get("ident")
                sub_payload = {
                    "ident": ident,
                    "pass": self.password,
                    "uid": self.username
                }
                sub_res = self._request("POST", "/v1/auth/login", data=sub_payload)
                token = sub_res.get("token")
                num_id = "".join(filter(str.isdigit, ident))

                student_name = f"{sub_res.get('firstName', '')} {sub_res.get('lastName', '')}".strip()
                school_name = ch.get("school", "")
                try:
                    card_res = self._request("GET", f"/v1/students/{num_id}/card", token=token)
                    card = card_res.get("card", {})
                    c_name = f"{card.get('firstName', '')} {card.get('lastName', '')}".strip()
                    if c_name:
                        student_name = c_name
                    c_school = f"{card.get('schName', '')} {card.get('schDedication', '')}".strip()
                    if c_school:
                        school_name = c_school
                except Exception:
                    pass

                self.sessions[ident] = {
                    "ident": ident,
                    "num_id": num_id,
                    "name": student_name,
                    "school": school_name,
                    "token": token,
                    "expire": sub_res.get("expire")
                }
            self.account_name = self.username

        # Case 2: Single direct login
        elif res.get("token"):
            ident = res.get("ident", self.username)
            token = res.get("token")
            num_id = "".join(filter(str.isdigit, ident))
            student_name = f"{res.get('firstName', '')} {res.get('lastName', '')}".strip()
            school_name = ""
            try:
                card_res = self._request("GET", f"/v1/students/{num_id}/card", token=token)
                card = card_res.get("card", {})
                c_name = f"{card.get('firstName', '')} {card.get('lastName', '')}".strip()
                if c_name:
                    student_name = c_name
                school_name = f"{card.get('schName', '')} {card.get('schDedication', '')}".strip()
            except Exception:
                pass

            self.sessions[ident] = {
                "ident": ident,
                "num_id": num_id,
                "name": student_name,
                "school": school_name,
                "token": token,
                "expire": res.get("expire")
            }
            self.account_name = student_name
        else:
            raise RuntimeError("Authentication failed: no token or choices in response.")

    def get_target_students(self, filter_student: Optional[str] = None) -> List[Dict[str, Any]]:
        all_students = list(self.sessions.values())
        if not filter_student:
            return all_students

        filt = filter_student.lower().strip()
        matched = [
            s for s in all_students
            if filt in s["name"].lower()
            or filt in s["ident"].lower()
            or filt == s["num_id"]
        ]
        return matched if matched else all_students

    def get_agenda(self, student: Dict[str, Any], start_date: str, end_date: str) -> List[Dict[str, Any]]:
        s_clean = start_date.replace("-", "")
        e_clean = end_date.replace("-", "")
        num_id = student["num_id"]
        token = student["token"]
        res = self._request("GET", f"/v1/students/{num_id}/agenda/all/{s_clean}/{e_clean}", token=token)
        return res.get("agenda", [])

    def get_noticeboard(self, student: Dict[str, Any]) -> List[Dict[str, Any]]:
        num_id = student["num_id"]
        token = student["token"]
        res = self._request("GET", f"/v1/students/{num_id}/noticeboard", token=token)
        return res.get("items", [])

    def get_lessons(self, student: Dict[str, Any], day: Optional[str] = None) -> List[Dict[str, Any]]:
        if not day:
            day = datetime.date.today().strftime("%Y%m%d")
        else:
            day = day.replace("-", "")
        num_id = student["num_id"]
        token = student["token"]
        res = self._request("GET", f"/v1/students/{num_id}/lessons/{day}", token=token)
        return res.get("lessons", [])

    def get_homeworks(self, student: Dict[str, Any]) -> List[Dict[str, Any]]:
        num_id = student["num_id"]
        token = student["token"]
        try:
            res = self._request("GET", f"/v1/students/{num_id}/homeworks", token=token)
            return res.get("items", [])
        except Exception:
            return []

    def get_grades(self, student: Dict[str, Any]) -> List[Dict[str, Any]]:
        num_id = student["num_id"]
        token = student["token"]
        res = self._request("GET", f"/v1/students/{num_id}/grades", token=token)
        return res.get("grades", [])


def print_status(client: ClasseVivaClient, as_json: bool = False):
    students = list(client.sessions.values())
    info = {
        "authenticated": bool(client.sessions),
        "account": client.username,
        "students": [
            {
                "name": s["name"],
                "student_id": s["num_id"],
                "ident": s["ident"],
                "school": s["school"],
                "session_expires": s.get("expire")
            }
            for s in students
        ]
    }
    if as_json:
        print(json.dumps(info, indent=2, ensure_ascii=False))
        return

    print("\n============================================================")
    print("  CLASSEVIVA — STATO CONNESSIONE")
    print("============================================================")
    print(f"Account:              {info['account']}")
    print(f"Profili collegati:    {len(info['students'])}")
    for s in info["students"]:
        print(f"  • {s['name']} (ID: {s['student_id']} / {s['ident']})")
        print(f"    Scuola:    {s['school']}")
        print(f"    Sessione:  Scadenza {s['session_expires']}")
    print("")


def print_compiti(client: ClasseVivaClient, students: List[Dict[str, Any]], days: int = 7, as_json: bool = False):
    today = datetime.date.today()
    end = today + datetime.timedelta(days=days)
    s_date = today.strftime("%Y-%m-%d")
    e_date = end.strftime("%Y-%m-%d")

    all_results = {}
    for st in students:
        s_name = st["name"]
        agenda = client.get_agenda(st, s_date, e_date)
        agenda.sort(key=lambda x: x.get("evtDatetimeBegin", ""))

        hw_map = {}
        try:
            for hw in client.get_homeworks(st):
                hw_map[hw.get("evtId")] = hw
        except Exception:
            pass

        for it in agenda:
            hw_id = it.get("homeworkId")
            if hw_id and hw_id in hw_map:
                it["didacticsDesc"] = hw_map[hw_id].get("homeworkDesc", "")

        all_results[s_name] = agenda

    if as_json:
        print(json.dumps(all_results, indent=2, ensure_ascii=False))
        return

    print(f"\n============================================================")
    print(f"  CLASSEVIVA — COMPITI ED EVENTI IN AGENDA ({s_date} → {e_date})")
    print(f"============================================================")
    for s_name, items in all_results.items():
        print(f"\n🎓 {s_name} ({len(items)} eventi trovati):")
        if not items:
            print("   Nessun compito registrato nel periodo.")
            continue
        for it in items:
            dt = (it.get("evtDatetimeBegin") or "")[:10]
            subj = it.get("subjectDesc") or "Scuola"
            teacher = it.get("authorName") or ""
            notes = (it.get("notes") or "").strip()
            did_desc = it.get("didacticsDesc")
            teacher_str = f" (Prof. {teacher})" if teacher else ""
            print(f"  [{dt}] {subj}{teacher_str}")
            if notes:
                print(f"    📝 {notes}")
            if did_desc:
                print(f"    📖 Dettaglio Didattica: {did_desc}")
    print("")


def print_bacheca(client: ClasseVivaClient, students: List[Dict[str, Any]], limit: int = 10, as_json: bool = False):
    all_results = {}
    for st in students:
        s_name = st["name"]
        items = client.get_noticeboard(st)
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
            dt = (it.get("pubDT") or "")[:10]
            cat = it.get("cntCategory") or "Avviso"
            title = (it.get("cntTitle") or "").strip()
            has_attach = it.get("cntHasAttach", False)
            attach_str = " 📎 [Allegato PDF]" if has_attach else ""
            read_str = "✓" if it.get("readStatus") else "● [Nuovo]"
            print(f"  [{dt}] {read_str} ({cat}) {title}{attach_str}")
    print("")


def print_lezioni(client: ClasseVivaClient, students: List[Dict[str, Any]], day: Optional[str] = None, as_json: bool = False):
    target_day = day or datetime.date.today().strftime("%Y-%m-%d")
    all_results = {}
    for st in students:
        s_name = st["name"]
        lessons = client.get_lessons(st, target_day)
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
            lesson_arg = (it.get("lessonArg") or "").strip()
            print(f"  Ora {hour}: {subj} ({teacher})")
            if lesson_arg:
                print(f"    📖 Argomento: {lesson_arg}")
    print("")


def print_voti(client: ClasseVivaClient, students: List[Dict[str, Any]], limit: int = 15, as_json: bool = False):
    all_results = {}
    for st in students:
        s_name = st["name"]
        grades = client.get_grades(st)
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
            dt = (it.get("evtDate") or "")[:10]
            subj = it.get("subjectDesc") or ""
            val = it.get("displayValue") or ""
            notes = (it.get("notesForFamily") or it.get("notes") or "").strip()
            component = it.get("componentDesc") or ""
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
