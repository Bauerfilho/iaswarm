#!/usr/bin/env python3
"""Gate textual do painel neon: sha256 gêmeo, guarda anti-repaint, teto 8 KB.

Saída: N ✔  M ✗   (exit 1 se M>0)
"""
from __future__ import annotations

import hashlib
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[1]
PROD = Path.home() / ".claude/scripts/iaswarm/painel.html"
REPO = RAIZ / "painel" / "painel.html"
TETO = 8192

ok = 0
fail = 0


def sha256(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def tick_src(html: str) -> str:
    i = html.find("async function tick(")
    if i < 0:
        return ""
    j = html.find("tick();", i)
    return html[i:j] if j > i else html[i:]


def marca(passou: bool, letra: str, msg: str) -> None:
    global ok, fail
    if passou:
        ok += 1
        print(f"✔ {letra}  {msg}")
    else:
        fail += 1
        print(f"✗ {letra}  {msg}")


def main() -> int:
    if not PROD.is_file():
        marca(False, "a", f"produção ausente: {PROD}")
        marca(False, "b", "sem produção, não conferi o tick()")
        marca(False, "c", "sem produção, não conferi o tamanho")
        print(f"{ok} ✔  {fail} ✗")
        return 1
    if not REPO.is_file():
        marca(False, "a", f"repo ausente: {REPO}")
    else:
        h1, h2 = sha256(PROD), sha256(REPO)
        marca(h1 == h2, "a", f"sha256 produção == repo  {h1}")

    html = PROD.read_text(encoding="utf-8")
    tick = tick_src(html)
    dest = re.search(r"""\.innerHTML\s*=\s*(['"`]\s*['"`])""", tick)
    tem_json = "JSON.stringify" in tick
    tem_return = bool(re.search(r"if\s*\(\s*sig\s*===\s*lastSig\s*\)\s*return", tick))
    if not tick:
        marca(False, "b", "async function tick() ausente")
    elif not tem_json or not tem_return:
        marca(False, "b", "tick() sem guarda JSON.stringify + if(sig===lastSig) return")
    elif dest is None:
        marca(True, "b", "tick() sem innerHTML=\"\" e com guarda de assinatura antes do grid")
    else:
        antes = tick[: dest.start()]
        guarda_antes = ("JSON.stringify" in antes) and ("return" in antes)
        marca(
            guarda_antes,
            "b",
            "innerHTML=\"\" só depois da comparação de assinatura"
            if guarda_antes
            else "innerHTML=\"\" alcançável ANTES da guarda de assinatura",
        )

    n = PROD.stat().st_size
    marca(n < TETO, "c", f"{n} bytes {'<' if n < TETO else '>='} {TETO}")

    print(f"{ok} ✔  {fail} ✗")
    return 1 if fail else 0


if __name__ == "__main__":
    sys.exit(main())
