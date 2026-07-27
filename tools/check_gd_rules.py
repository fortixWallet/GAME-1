#!/usr/bin/env python3
"""Звірка РОБОЧИХ даних data/case_*.gd: кожне правило tool=X мусить бути
дозволене зоною (tools[] містить X або порожній). Мертве правило = зона
відфільтрує пік раніше, ніж рушій знайде правило (упіймано 27.07: око на
споді шухляди). Правило 17: друкуємо, скільки переглянуто."""
import re, sys, pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
errors, zones_n, rules_n = [], 0, 0
for gd in sorted((ROOT / "data").glob("case_*.gd")):
    text = gd.read_text(encoding="utf-8")
    # зони: &"z.x": { ... } — беремо блок до закриття та tools усередині
    zone_tools = {}
    for m in re.finditer(r'&"(z\.[A-Za-z0-9_.]+)"\s*:\s*\{(.*?)\n\t\}', text, re.S):
        zid, body = m.group(1), m.group(2)
        tl = re.findall(r'&"(tool\.[a-z_]+)"', body[body.find('"tools"'):]) if '"tools"' in body else []
        zone_tools[zid] = tl
    zones_n += len(zone_tools)
    # правила: {"zone": &"z.x", "tool": &"tool.y" ...}
    for m in re.finditer(r'\{"zone":\s*&"(z\.[A-Za-z0-9_.]+)",\s*"tool":\s*&"([a-z_.*]+)"', text):
        zid, tool = m.group(1), m.group(2)
        rules_n += 1
        zt = zone_tools.get(zid)
        if zt is None:
            errors.append(f"{gd.name}: правило по НЕІСНУЮЧІЙ зоні {zid}")
        elif tool != "*" and zt and tool not in zt:
            errors.append(f"{gd.name}: правило {zid}+{tool} МЕРТВЕ — зона пускає лише {zt}")
print(f"GD_RULES переглянуто: зон={zones_n} правил={rules_n} помилок={len(errors)}")
for e in errors: print("  ERROR:", e)
sys.exit(1 if errors else 0)
