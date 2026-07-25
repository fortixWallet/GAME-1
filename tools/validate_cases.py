#!/usr/bin/env python3
"""Валідатор специфікацій справ. Читає _src/cases/case_NN.md і шукає механічні вади.

Не оцінює якість загадки — тільки форму. Смисл лишається за гейтом правила 13.
Запуск:  python3 tools/validate_cases.py [--json]
Вихід:   0 — чисто · 1 — є ERROR · (WARN не валить збірку)
"""
import re, sys, json, pathlib, collections

ROOT = pathlib.Path(__file__).resolve().parent.parent
CASES = sorted((ROOT / "_src" / "cases").glob("case_*.md"))

# ── лексика висновку: заборонена у ФАКТАХ (крім tag=books) і у ВАРІАНТАХ бланка ──
# факт = спостереження. Довідник = правило. Висновок = робота гравця.
# 1. сполучники висновку — заборонені і у фактах, і у варіантах бланка.
#    Це саме те, що агенти знайшли: «…which means the mark is later than the workshop».
CONNECTIVES = [
    " means ", " meaning ", " therefore", " hence ", " which proves", " proving ",
    " so the ", " and so ", " must be ", " must have ", " cannot be ", " can only be ",
    " older than", " later than", " earlier than", " younger than",
    " which shows", " showing that", " implies", " it follows",
]
# 2. вердиктні ярлики. За власним законом гри (case_06 §7) бланк НІКОЛИ не називає
#    злочин — тому в графах вони теж помилка, а не лише у фактах.
VERDICTS = [
    " forged", " forgery", " fake", " faked", " counterfeit", " genuine", " authentic",
    " stolen", " theft", " thief", " dressed to pass", " made to look", " mislead", " misleading",
    " passed off", " to deceive", " fraud",
]
CONCLUSION = CONNECTIVES + VERDICTS

# порядок важливий: «ПРАВИЛА (зона × інструмент → факт)» містить і «ЗОН», і «ФАКТ»,
# тому спершу шукаємо найспецифічніші слова.
SECTION_KIND = [
    ("ПРАВИЛА", "rules"), ("АТЕСТАТ", "slots"), ("ІНСТРУМЕНТ", "tools"),
    ("ДОВІДНИК", "books"), ("ДОВІДКОВ", "books"), ("НАСЛІДКИ", "outcomes"),
    ("СТРИБОК", "leap"), ("ХИБНИЙ", "redherring"),
    ("ФАКТИ", "facts"), ("ЗОН", "zones"),
]

ID_RE   = re.compile(r"`([a-z]{1,6}\.[A-Za-z0-9_.]+)`")
OPT_ID_RE = re.compile(r"`(o\.[A-Za-z0-9_]+)`")
TRUTH_RE = re.compile(r"(?:[Іі]стина|відповідь)[^*\n]{0,40}\*\*([^*]+)\*\*")
NUM_RE  = re.compile(r"\b\d[\d\s.,]{1,}\b")
# інструменти в правилах пишуть і як `tool.loupe`, і просто як `loupe`
BARE_TOOLS = {
    "eye", "hand", "loupe", "scales", "caliper", "rake", "blade", "saw", "wax",
    "spirit", "schwerter", "hydro", "blowpipe", "cupel", "magnet", "lamp", "candle",
    "screwdriver", "probe", "brush", "weigh", "acid", "uv", "mirror", "tweezers",
    "thermo", "ruler", "compass", "pipette", "cloth", "file", "needle", "seal",
}
TYPE_WORDS = {
    "CHOICE": ("CHOICE", "список"),
    "NUMBER": ("NUMBER", "ЧИСЛО", "число"),
    "FACTS":  ("FACTS", "перетягування"),
}


def sections(text):
    """→ [(kind, title, body)] за ключовим словом у заголовку, не за номером."""
    out, cur = [], None
    for line in text.splitlines():
        if line.startswith("## "):
            title = line[3:].strip()
            kind = next((k for key, k in SECTION_KIND if key in title.upper()), "other")
            cur = [kind, title, []]
            out.append(cur)
        elif cur is not None:
            cur[2].append(line)
    return [(k, t, "\n".join(b)) for k, t, b in out]


def rows(body):
    """Рядки markdown-таблиці як список списків клітинок (без шапки й лінійки)."""
    out = []
    for line in body.splitlines():
        s = line.strip()
        if not s.startswith("|"):
            continue
        # «\|» усередині клітинки — екранована риска (`eye` \| `loupe`), не межа стовпця
        cells = [c.replace("\0", "\\|").strip()
                 for c in s.replace("\\|", "\0").strip("|").split("|")]
        if all(set(c) <= set("-: ") for c in cells):   # лінійка під шапкою
            continue
        out.append(cells)
    return out


def norm(s):
    """Шапки пишуть і `slot_id`, і `slot id`, і `id графи` — зводимо до одного."""
    return re.sub(r"[\s_*`]+", "", s).lower()


def table_after_header(body, *keys):
    """Таблиця, чия шапка містить будь-який із keys. → (шапка, рядки)"""
    rs = rows(body)
    for i, r in enumerate(rs):
        joined = norm(" ".join(r))
        if any(norm(k) in joined for k in keys):
            return r, rs[i + 1:]
    return None, []


def options(s):
    """Варіанти бланка в усіх чотирьох діалектах → [(id, текст)].

    Зустрічаються: `o.id` "текст" · `o.id` «текст» · `o.id` ("текст") · `o.id` (текст)
    · `o.id` — "текст" · рядок списку «- `o.id` — "текст"». Тому не мучимо регекс:
    беремо текст від id до наступного id (або до кінця клітинки) і чистимо облямівку.
    """
    out, ms = [], list(OPT_ID_RE.finditer(s))
    for i, m in enumerate(ms):
        end = ms[i + 1].start() if i + 1 < len(ms) else len(s)
        seg = s[m.end():end]
        seg = re.split(r"[|·\n]", seg)[0]                  # до розділювача варіантів
        seg = re.sub(r"^[\s—–:\-]*", "", seg)              # ведуче тире/двокрапка
        seg = seg.strip().strip("()").strip()              # дужки
        seg = seg.strip("«»\"'").strip()                   # лапки
        if seg:
            out.append((m.group(1), seg))
    return out


def strip_md(s):
    s = re.sub(r"`[^`]*`", " ", s)          # прибрати id у backticks
    s = re.sub(r"[*_>]", "", s)
    return re.sub(r"\s+", " ", s).strip()


class Case:
    def __init__(self, path):
        self.path = path
        self.name = path.stem
        self.n = int(re.search(r"\d+", path.stem).group())
        self.text = path.read_text(encoding="utf-8")
        self.lines = self.text.splitlines()
        self.sec = {}
        for kind, title, body in sections(self.text):
            self.sec.setdefault(kind, []).append((title, body))
        self.facts = self._facts()
        self.slots = self._slots()
        self.zones = self._zones()
        self.rules = self._rules()

    def lineno(self, needle):
        for i, l in enumerate(self.lines, 1):
            if needle in l:
                return i
        return 0

    def _body(self, kind):
        return "\n\n".join(b for _, b in self.sec.get(kind, []))

    def _facts(self):
        """→ {fact_id: {'text','cite','tag','raw'}}"""
        out = {}
        hdr, rs = table_after_header(self._body("facts"), "fact_id", "id факту")
        if hdr is None:
            return out
        low = [h.lower() for h in hdr]
        def col(*keys, default=None):
            for i, h in enumerate(low):
                if any(k in h for k in keys):
                    return i
            return default
        c_id, c_tx = col("fact_id", "id факту", default=0), col("text", "текст", default=1)
        c_ct, c_tg = col("cite"), col("tag", "груп")
        for r in rs:
            m = ID_RE.search(r[c_id]) if c_id < len(r) else None
            if not m:
                continue
            fid = m.group(1)
            g = lambda i: strip_md(r[i]) if i is not None and i < len(r) else ""
            # тег пишуть у backticks (`books`), а strip_md їх викидає — беремо клітинку сиру
            raw_tag = r[c_tg] if c_tg is not None and c_tg < len(r) else ""
            out[fid] = {"text": g(c_tx), "cite": g(c_ct),
                        "tag": re.sub(r"[`*\s]+", "", raw_tag).lower(),
                        "raw": " | ".join(r)}
        return out

    def _slots(self):
        """→ [{'id','kind','opts':[(id,text)],'truth','gate','raw'}], self.dialect

        Бланк написано ЧОТИРМА діалектами. Читаємо всі, але дiалект фіксуємо —
        відхід від канону сам стає помилкою (перевірка I-canon).
        """
        body = self._body("slots")
        out = []
        self.dialect = "?"

        def kind_of(s):
            for k, words in TYPE_WORDS.items():
                if any(w in s for w in words):
                    return k
            return "?"

        def mk(sid, joined, num):
            tm = TRUTH_RE.search(joined)
            return {"id": sid or f"s.#{num}", "kind": kind_of(joined),
                    "opts": options(joined),
                    "truth": tm.group(1).strip() if tm else None,
                    "gate": " ".join(re.findall(r"needs[a-z_]*\s*:?\s*\[[^\]]*\]", joined)),
                    "has_id": bool(sid), "raw": joined}

        # діалект 1/2/3 — таблиця (з slot_id, зі «slot id», або зовсім без id)
        hdr, rs = table_after_header(body, "slot_id", "id графи", "префікс")
        if hdr is not None:
            self.dialect = "table+id" if any(norm(k) in norm(" ".join(hdr))
                                             for k in ("slot_id", "slotid", "id графи")) \
                           else "table-noid"
            for i, r in enumerate(rs, 1):
                joined = " | ".join(r)
                if not re.search(r"[«\"'`]|ЧИСЛО|CHOICE|NUMBER|FACTS|список", joined):
                    continue
                m = re.search(r"`(s\.[A-Za-z0-9_]+)`", joined)
                out.append(mk(m.group(1) if m else None, joined, i))
            if out:
                return out

        # діалект 4 — проза: «### Графа N — `s.id`» + список варіантів
        blocks = re.split(r"^###\s+", body, flags=re.M)[1:]
        if blocks:
            self.dialect = "prose"
            for i, b in enumerate(blocks, 1):
                m = re.search(r"`(s\.[A-Za-z0-9_]+)`", b)
                out.append(mk(m.group(1) if m else None, b, i))
        return out

    def _zones(self):
        ids = set()
        for _, b in self.sec.get("zones", []):
            ids |= {i for i in ID_RE.findall(b) if i.startswith("z.")}
            # case_07 пише зони GDScript-словником, а не таблицею: &"z.case.lid": {
            ids |= set(re.findall(r'&"(z\.[A-Za-z0-9_.]+)"\s*:\s*\{', b))
        return ids

    def _rules(self):
        """→ [(zones, tools, facts)]. Інструмент пишуть і `tool.loupe`, і просто `loupe`."""
        out = []
        self.bare_tool_rows = 0
        for _, b in self.sec.get("rules", []):
            for r in rows(b):
                joined = " | ".join(r)
                ids = ID_RE.findall(joined)
                zs = [i for i in ids if i.startswith("z.")]
                fs = [i for i in ids if i.startswith("f.")]
                ts = [i for i in ids if i.startswith("tool.")]
                bare = [f"tool.{t}" for t in re.findall(r"`([a-z_]+)`", joined)
                        if t in BARE_TOOLS]
                if bare and not ts:
                    self.bare_tool_rows += 1
                ts = ts or bare
                if zs or ts or fs:
                    out.append((zs, ts, fs))
            # друга форма (case_07): правила як GDScript-словники в блоці коду.
            # Без цього файл проходив би валідатор, бо в ньому просто нема таблиць.
            for m in re.finditer(r'\{"zone":\s*&"(z\.[A-Za-z0-9_.]+)".*?(?=\n\s*\{"zone"|\n\]|\Z)',
                                 b, re.S):
                seg = m.group(0)
                out.append(([m.group(1)],
                            re.findall(r'&"(tool\.[A-Za-z0-9_]+)"', seg),
                            re.findall(r'&"(f\.[A-Za-z0-9_.]+)"', seg)))
        return out

    def produced_facts(self):
        s = set()
        for _, _, fs in self.rules:
            s |= set(fs)
        return s

    def tools(self):
        s = set()
        for _, _, in_ in []:
            pass
        for zs, ts, fs in self.rules:
            s |= set(ts)
        for _, b in self.sec.get("tools", []):
            s |= {i for i in ID_RE.findall(b) if i.startswith("tool.")}
        return s

    def referenced_facts(self):
        """усі f.* згадані будь-де у файлі (гейти, наслідки, правила)"""
        return {i for i in ID_RE.findall(self.text) if i.startswith("f.")}


def sig_numbers(s):
    """Значущі числа рядка (≥3 цифр).

    Кома — РОЗДІЛЮВАЧ, не частина числа: у «1 = 950, 2 = 900» немає числа 9502.
    Пробіл склеюємо лише як розряд тисяч, тобто коли далі рівно три цифри: «1 429».
    """
    out = set()
    for m in re.finditer(r"\d+(?: \d{3})*(?:\.\d+)?", s):
        t = m.group(0).replace(" ", "")
        if len(t.replace(".", "")) >= 3:
            out.add(t)
    return out


def main():
    cases = [Case(p) for p in CASES]
    problems = []          # (level, case, code, msg, line)

    def add(level, c, code, msg, line=0):
        problems.append((level, c.name if c else "-", code, msg, line))

    # ── A. лексика висновку у варіантах бланка ──────────────────────────────
    for c in cases:
        for s in c.slots:
            for oid, otext in s["opts"]:
                low = " " + otext.lower() + " "
                hits = [p.strip() for p in CONCLUSION if p in low]
                if hits:
                    add("ERROR", c, "A-opt",
                        f"{s['id']} · варіант {oid} друкує висновок ({', '.join(hits)}): «{otext}»",
                        c.lineno(oid))

    # ── B. лексика висновку у фактах (крім довідникових) ───────────────────
    for c in cases:
        for fid, f in c.facts.items():
            if "book" in f["tag"] or "довід" in f["tag"]:
                continue
            for field in ("text", "cite"):
                low = " " + f[field].lower() + " "
                hits = [p.strip() for p in CONCLUSION if p in low]
                if hits:
                    add("ERROR", c, "B-fact",
                        f"{fid}.{field} робить висновок ({', '.join(hits)}) — мусить бути спостереження",
                        c.lineno(fid))

    # ── C. число NUMBER-графи дослівно лежить у факті ──────────────────────
    for c in cases:
        for s in c.slots:
            if s["kind"] != "NUMBER" or not s["truth"]:
                continue
            t = s["truth"].replace("**", "").strip()
            digits = re.sub(r"[^\d.]", "", t)
            # однозначні числа зустрічаються всюди — на них перевірка безсила
            if len(digits.replace(".", "")) < 2:
                continue
            hits = []
            for fid, f in c.facts.items():
                hay = f["text"] + " " + f["cite"]
                if re.search(r"(?<![\d.])" + re.escape(digits) + r"(?![\d])", hay):
                    hits.append((fid, "book" in f["tag"] or "довід" in f["tag"]))
            if not hits:
                continue
            # число в довідниковому факті — це чесний пошук по таблиці.
            # число у факті, здобутому з ПРЕДМЕТА, — це переписування.
            from_item = [fid for fid, is_book in hits if not is_book]
            if from_item:
                add("ERROR", c, "C-copy",
                    f"{s['id']} = {digits} дослівно є у факті {from_item[0]} (здобутий із предмета) — "
                    f"графа переписується, а не рахується", c.lineno(s["id"]))
            else:
                add("WARN", c, "C-lookup",
                    f"{s['id']} = {digits} читається з довідника {hits[0][0]} — це пошук по таблиці, "
                    f"не обчислення; допустимо, але графа думки не вимагає", c.lineno(s["id"]))

    # ── D. висячі посилання на факти (схемний дрейф) ───────────────────────
    for c in cases:
        for fid in sorted(c.referenced_facts() - set(c.facts)):
            add("ERROR", c, "D-dangling",
                f"{fid} згадується, але його НЕ ОГОЛОШЕНО в таблиці фактів", c.lineno(fid))

    # ── E. факт оголошено, але жодне правило його не видає ─────────────────
    for c in cases:
        produced = c.produced_facts()
        if not produced:
            add("WARN", c, "E-norules", "таблиця правил не розпарсилась — перевірити формат", 0)
            continue
        for fid in sorted(set(c.facts) - produced):
            add("WARN", c, "E-orphan",
                f"{fid} оголошено, але жодне правило його не видає (недосяжний або перенесений)",
                c.lineno(fid))

    # ── F. мертві інструменти: працюють лише в одній справі ────────────────
    usage = collections.defaultdict(set)
    for c in cases:
        for zs, ts, fs in c.rules:
            for t in ts:
                usage[t].add(c.n)
    for t, ns in sorted(usage.items()):
        if len(ns) == 1:
            add("WARN", None, "F-onehit",
                f"{t} має правила лише у справі {sorted(ns)[0]} — чехівська рушниця не стріляє")

    # ── G. колізії значущих чисел МІЖ справами ─────────────────────────────
    numbers = collections.defaultdict(set)
    for c in cases:
        for fid, f in c.facts.items():
            # довідникові факти навмисно однакові в різних справах (той самий розворот) —
            # спільне число в них не колізія, а той самий довідник
            if "book" in f["tag"] or "довід" in f["tag"]:
                continue
            for v in sig_numbers(f["text"]):
                numbers[v].add(c.n)
    for v, ns in sorted(numbers.items(), key=lambda kv: -len(kv[1])):
        try:
            fv = float(v.replace(",", ""))
        except ValueError:
            continue
        # роки 1700–1900 не колізія: світ у гри один, історія в ньому спільна
        if 1700 <= fv <= 1900 and "." not in v:
            continue
        if len(ns) > 1 and fv >= 100:
            add("WARN", None, "G-collision",
                f"число {v} зустрічається у справах {sorted(ns)} — гравець зчитає зв'язок, якого нема")

    # ── H. схема id: префікс фактів мусить бути єдиний ─────────────────────
    for c in cases:
        pref = collections.Counter(fid.split(".")[1] if fid.count(".") > 1 else "-"
                                   for fid in c.facts)
        deep = [fid for fid in c.facts if fid.count(".") > 1]
        if deep:
            add("ERROR", c, "H-schema",
                f"{len(deep)} факт(ів) у власній схемі (напр. {deep[0]}) — канон: f.<name>, без підпростору",
                c.lineno(deep[0]))

    # ── I. канон форми: один діалект бланка, один спосіб писати інструмент ──
    # Канон = case_08: таблиця з колонкою slot_id, тип словами CHOICE/NUMBER/FACTS,
    # варіанти як `o.id` "текст", інструменти як `tool.<name>`.
    for c in cases:
        if not c.slots:
            add("ERROR", c, "I-canon", "бланк не розпарсився зовсім — формат поза каноном", 0)
            continue
        if c.dialect != "table+id":
            add("ERROR", c, "I-canon",
                f"бланк у діалекті «{c.dialect}», канон — «table+id» (як case_08)",
                c.lineno("АТЕСТАТ"))
        noid = [s for s in c.slots if not s["has_id"]]
        if noid:
            add("ERROR", c, "I-canon",
                f"{len(noid)} граф(и) без slot_id — рушій не має чим їх адресувати",
                c.lineno("АТЕСТАТ"))
        unk = [s["id"] for s in c.slots if s["kind"] == "?"]
        if unk:
            add("ERROR", c, "I-canon",
                f"тип графи не розпізнано: {', '.join(unk)} — писати CHOICE/NUMBER/FACTS",
                c.lineno("АТЕСТАТ"))
        if getattr(c, "bare_tool_rows", 0):
            add("WARN", c, "I-canon",
                f"{c.bare_tool_rows} правил(о) пише інструмент без префікса — канон `tool.<name>`",
                c.lineno("ПРАВИЛА"))
        nch = sum(1 for s in c.slots if s["kind"] == "CHOICE")
        if len(c.slots) != 6:
            add("WARN", c, "I-canon", f"граф {len(c.slots)}, а домовлено 6", 0)
        # CHOICE-графа без жодного розпарсеного варіанта = варіанти написані прозою
        for s in c.slots:
            if s["kind"] == "CHOICE" and not s["opts"]:
                add("ERROR", c, "I-canon",
                    f"{s['id']}: CHOICE без жодного `o.*` варіанта — варіанти не адресовні",
                    c.lineno(s["id"]) or c.lineno("АТЕСТАТ"))

    # ── звіт ───────────────────────────────────────────────────────────────
    if "--json" in sys.argv:
        print(json.dumps([{"level": l, "case": c, "code": k, "msg": m, "line": ln}
                          for l, c, k, m, ln in problems], ensure_ascii=False, indent=1))
    else:
        by = collections.Counter((l, k) for l, _, k, _, _ in problems)
        print("=" * 78)
        for c in cases:
            print(f"{c.name}: {len(c.facts):2} фактів · {len(c.slots)} граф · "
                  f"{len(c.zones):2} зон · {len(c.rules):2} правил")
        print("=" * 78)
        cur = None
        for l, cn, k, m, ln in sorted(problems, key=lambda p: (p[2], p[1])):
            if k != cur:
                print(f"\n── {k} " + "─" * (72 - len(k)))
                cur = k
            loc = f"{cn}:{ln}" if ln else cn
            print(f"  {l:5} {loc:14} {m}")
        print("\n" + "=" * 78)
        for (l, k), n in sorted(by.items()):
            print(f"  {l:5} {k:12} {n}")
        errs = sum(n for (l, _), n in by.items() if l == "ERROR")
        print(f"\n  ERROR: {errs} · WARN: {len(problems) - errs}")
    return 1 if any(l == "ERROR" for l, *_ in problems) else 0


if __name__ == "__main__":
    sys.exit(main())
