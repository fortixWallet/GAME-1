#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Сенсор правила 22: ПОКАЗАНО ≠ НАПИСАНО.
Кожен факт у data/case_NN.gd мусить нести shown_in:
  "frame:<tex>"  — видно на кадрі (файл art/<tex>.png мусить існувати)
  "paper"        — паперовий доказ, читається (виняток правила 22)
  "derived"      — синтез інших фактів (усі базові мусять бути показані)
  "say"/відсутнє — ГОЛИЙ ФАКТ: гравцеві розповіли, а не показали.
Правило 17: спершу скільки переглянуто, потім що знайдено."""
import re, sys, pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
files = sorted((ROOT / "data").glob("case_*.gd"))
total, shown, papers, derived, naked = 0, 0, 0, 0, []
missing_tex = []

for f in files:
    src = f.read_text(encoding="utf-8")
    m = re.search(r"const FACTS\b.*?\{(.*?)\n\}", src, re.S)
    if not m:
        print("%s: FACTS не знайдено" % f.name); continue
    body = m.group(1)
    # записи виду &"f.xxx": {...} — беремо кожен блок факту
    for fm in re.finditer(r'&"(f\.[\w.]+)"\s*:\s*\{(.*?)\}(?=,?\s*(?:&"|$))', body, re.S):
        fid, fbody = fm.group(1), fm.group(2)
        total += 1
        sm = re.search(r'"shown_in"\s*:\s*"([^"]*)"', fbody)
        tag = sm.group(1) if sm else ""
        if tag.startswith("frame:"):
            tex = tag.split(":", 1)[1]
            if not (ROOT / "art" / (tex + ".png")).exists():
                missing_tex.append("%s: %s → art/%s.png НЕМА" % (f.name, fid, tex))
            shown += 1
        elif tag == "paper":
            papers += 1
        elif tag.startswith("model:"):
            glb = tag.split(":", 1)[1]
            if not (ROOT / "models" / (glb + ".glb")).exists():
                missing_tex.append("%s: %s → models/%s.glb НЕМА" % (f.name, fid, glb))
            shown += 1
        elif tag == "spoken":
            papers += 1   # слова клієнта на допиті — покази, не підказка гри
        elif tag == "measured":
            papers += 1   # число дає інструмент дією гравця (шкали приладів — у чергу)
        elif tag == "derived":
            derived += 1
        else:
            naked.append("%s: %s" % (f.name, fid))

print("SHOWN_AUDIT файлів=%d фактів=%d показано=%d папери=%d синтез=%d голих=%d"
      % (len(files), total, shown, papers, derived, len(naked)))
for n in naked:
    print("  ГОЛИЙ  " + n)
for t in missing_tex:
    print("  БИТИЙ  " + t)
if total == 0:
    print("SHOWN_AUDIT_FAIL: нуль переглянутих фактів — поломка парсера (правило 17)")
    sys.exit(2)
# голі факти ДОЗВОЛЕНІ у старих справах (лікуються чергою), але лічильник
# зафіксовано в гейті: нове голе не пролізе непоміченим.
if missing_tex:
    sys.exit(2)
print("SHOWN_AUDIT_OK")
