# СПРАВА 7 — «СРІБНИЙ ПОРТСИГАР» + СЦЕНА-ПІДПИС
### 45 хв · акт ІІ, кульмінація · **ХВИЛЯ 2** · код сейфа
### ⚠️ ЦЕЙ ФАЙЛ — ЗРАЗОК КАНОНІЧНОЇ СХЕМИ (`ENGINE_SPEC` §1). Решту справ нормалізувати під нього.

---

## 0. ЩО ЦЕ ЗА СПРАВА

Формально: срібний портсигар, треба атестувати. Насправді — **справа про сім тек**.
Портсигар дає **привід** відкрити картотеку; там гравець уперше бачить сім квитанцій однією
рукою, виводить **рік** і виявляє, що **дві з квитанцій — його власні**.

Правило V6: хвиля вписується **рукою гравця**. Тут вона вписує **рік** — і той самий рік
відкриває сейф.

---

## 1. КЛІЄНТ

**Хто.** Пан Дорошенко, 50-х років, комісіонер — торгує чужим за відсоток. Приносить не своє
й цього не приховує.

**Потреба, не пов'язана з річчю:** «Пані, що дала мені його, від'їжджає в четвер. Їй потрібні
гроші на квиток, а мені — папір, щоб узяти річ у заставу.» *(Гравець мусить знати, на що піде
його печатка.)*

**Фізична деталь, яку кадр показує і жоден текст не коментує:** у нього **дві однакові
квитанційні книжки** в кишені, одна майже витрачена. Він робить це часто.

**Репліка на печатку:**
- швидко (< 8 хв): «Швидко у вас. Я так і казав їй — тут не тягнуть.»
- довго (> 25 хв): «Ви довго дивились. Я вже думав, щось не так із річчю.»

---

## 2. ЗОНИ (`ENGINE_SPEC` §1.2)

```gdscript
const ZONES := {
    # --- ПОРТСИГАР: 3D у HANDS ---
    &"z.case.lid": {
        "kind": &"mesh", "screen": &"HANDS", "node": &"cigcase",
        "at": Vector3(0.0, 0.045, 0.0), "facing": Vector3.UP, "r": 0.075,
        "label_key": "zone.c7.lid", "tools": [&"tool.loupe", &"tool.rake"],
    },
    &"z.case.inner": {
        "kind": &"mesh", "screen": &"HANDS", "node": &"cigcase",
        "at": Vector3(0.0, 0.010, 0.0), "facing": Vector3.UP, "r": 0.070,
        "label_key": "zone.c7.inner", "tools": [&"tool.loupe", &"tool.eye"],
        "requires_state": {&"z.case.lid": &"open"},
    },
    &"z.case.hinge": {
        "kind": &"mesh", "screen": &"HANDS", "node": &"cigcase",
        "at": Vector3(0.0, 0.030, -0.055), "facing": Vector3.BACK, "r": 0.045,
        "label_key": "zone.c7.hinge", "tools": [&"tool.loupe", &"tool.caliper"],
    },
    &"z.case.underside": {
        "kind": &"mesh", "screen": &"HANDS", "node": &"cigcase",
        "at": Vector3(0.0, -0.020, 0.0), "facing": Vector3.DOWN, "r": 0.080,
        "label_key": "zone.c7.underside", "tools": [&"tool.loupe", &"tool.acid", &"tool.wax"],
    },
    &"z.case.thumbpiece": {   # НАСКРІЗНА НИТКА: рука Продавця
        "kind": &"mesh", "screen": &"HANDS", "node": &"cigcase",
        "at": Vector3(-0.052, 0.032, 0.020), "facing": Vector3.LEFT, "r": 0.040,
        "label_key": "zone.c7.thumb", "tools": [&"tool.loupe", &"tool.rake"],
    },
    # --- КВИТАНЦІЯ КЛІЄНТА: 2D у DOCS ---
    &"z.docs.receipt": {
        "kind": &"img", "screen": &"DOCS", "surface": &"letter_client",
        "u": Vector2(0.500, 0.420), "r": 0.090,
        "label_key": "zone.c7.receipt", "tools": [&"tool.loupe", &"tool.eye"],
    },
    # --- КАРТОТЕКА: сім тек, кожна окрема зона ---
    &"z.cab.folder_1": { "kind": &"img", "screen": &"CABINET", "surface": &"cabinet_face",
        "u": Vector2(0.180, 0.240), "r": 0.055, "label_key": "zone.c7.f1", "tools": [&"tool.hand"] },
    &"z.cab.folder_2": { "kind": &"img", "screen": &"CABINET", "surface": &"cabinet_face",
        "u": Vector2(0.300, 0.240), "r": 0.055, "label_key": "zone.c7.f2", "tools": [&"tool.hand"] },
    &"z.cab.folder_3": { "kind": &"img", "screen": &"CABINET", "surface": &"cabinet_face",
        "u": Vector2(0.420, 0.240), "r": 0.055, "label_key": "zone.c7.f3", "tools": [&"tool.hand"] },
    &"z.cab.folder_4": { "kind": &"img", "screen": &"CABINET", "surface": &"cabinet_face",
        "u": Vector2(0.540, 0.240), "r": 0.055, "label_key": "zone.c7.f4", "tools": [&"tool.hand"] },
    &"z.cab.folder_5": { "kind": &"img", "screen": &"CABINET", "surface": &"cabinet_face",
        "u": Vector2(0.660, 0.240), "r": 0.055, "label_key": "zone.c7.f5", "tools": [&"tool.hand"] },
    &"z.cab.folder_6": { "kind": &"img", "screen": &"CABINET", "surface": &"cabinet_face",
        "u": Vector2(0.780, 0.240), "r": 0.055, "label_key": "zone.c7.f6", "tools": [&"tool.hand"] },
    &"z.cab.folder_7": { "kind": &"img", "screen": &"CABINET", "surface": &"cabinet_face",
        "u": Vector2(0.900, 0.240), "r": 0.055, "label_key": "zone.c7.f7", "tools": [&"tool.hand"] },
    &"z.cab.own_1": {   # УДАР: власні атестати гравця, підшиті автоматично
        "kind": &"img", "screen": &"CABINET", "surface": &"cabinet_face",
        "u": Vector2(0.240, 0.560), "r": 0.055, "label_key": "zone.c7.own1", "tools": [&"tool.hand"] },
    &"z.cab.own_2": { "kind": &"img", "screen": &"CABINET", "surface": &"cabinet_face",
        "u": Vector2(0.360, 0.560), "r": 0.055, "label_key": "zone.c7.own2", "tools": [&"tool.hand"] },
    # --- ГРОСБУХ: джерело РОКУ ---
    &"z.ledger.numbers": { "kind": &"img", "screen": &"LEDGER", "surface": &"ledger_spread",
        "u": Vector2(0.300, 0.480), "r": 0.100, "label_key": "zone.c7.led_num",
        "tools": [&"tool.eye", &"tool.loupe"] },
    &"z.ledger.dated_a": { "kind": &"img", "screen": &"LEDGER", "surface": &"ledger_spread",
        "u": Vector2(0.680, 0.300), "r": 0.070, "label_key": "zone.c7.led_a", "tools": [&"tool.eye"] },
    &"z.ledger.dated_b": { "kind": &"img", "screen": &"LEDGER", "surface": &"ledger_spread",
        "u": Vector2(0.680, 0.700), "r": 0.070, "label_key": "zone.c7.led_b", "tools": [&"tool.eye"] },
    # --- ПІДШИВКА: хибний слід ---
    &"z.news.cholera": { "kind": &"img", "screen": &"NEWS", "surface": &"newspaper_final",
        "u": Vector2(0.760, 0.640), "r": 0.080, "label_key": "zone.c7.cholera", "tools": [&"tool.eye"] },
    # --- СЕЙФ ---
    &"z.safe.dial": { "kind": &"img", "screen": &"SAFE", "surface": &"safe_closed",
        "u": Vector2(0.500, 0.470), "r": 0.120, "label_key": "zone.c7.dial", "tools": [&"tool.hand"] },
}
```

---

## 3. ПРАВИЛА (`ENGINE_SPEC` §1.3)

`say` — рядок, який гравець бачить і який лягає в нотатник. **Жоден `say` не містить висновку.**

```gdscript
const RULES := [
 # ---- ПОРТСИГАР: чесна річ. Це важливо: гравець шукає ваду й не знаходить ----
 {"zone": &"z.case.lid", "tool": &"tool.loupe", "verb": &"observe", "dwell": 0.5,
  "facts": [&"f.c7.lid_mono"],
  "say": "A monogram engraved on the lid: R. H. The cuts are dark at the bottom, worn even at the top."},
 {"zone": &"z.case.lid", "tool": &"tool.hand", "verb": &"apply",
  "sets_state": {&"z.case.lid": &"open"}, "sfx": &"goblet_set",
  "say": "The lid springs open on its own weight."},
 {"zone": &"z.case.inner", "tool": &"tool.loupe", "verb": &"observe", "dwell": 0.5,
  "requires": [], "facts": [&"f.c7.inner_marks"],
  "say": "Inside the lid, four punches in a row: the maker's shield, the Diana head with a 2, the office letter inside the outline, and a zigzag scratch beside them."},
 {"zone": &"z.case.underside", "tool": &"tool.acid", "verb": &"apply",
  "facts": [&"f.c7.acid_red"],
  "say": "A streak on the touchstone. Schwerter's solution runs blood-red on it, like the 900 needle."},
 {"zone": &"z.case.hinge", "tool": &"tool.caliper", "verb": &"apply",
  "facts": [&"f.c7.hinge_ok"],
  "say": "The hinge barrel is of one piece with the body. No solder seam, no filler."},
 # ---- НАСКРІЗНА НИТКА: рука Продавця ----
 {"zone": &"z.case.thumbpiece", "tool": &"tool.rake", "verb": &"observe", "dwell": 0.8,
  "facts": [&"f.c7.thumb_wear"],
  "say": "The thumbpiece is polished away on its left side only, and the polish runs deeper than the engraving."},
 # ---- КВИТАНЦІЯ КЛІЄНТА: вхід у картотеку ----
 {"zone": &"z.docs.receipt", "tool": &"tool.loupe", "verb": &"observe", "dwell": 0.4,
  "facts": [&"f.c7.receipt_gnat"],
  "say": "Receipt of deposit. The owner's hand at the foot: R. Hnat. The H is finished with a loop that comes back on itself."},
 # ---- СІМ ТЕК: кожна дає ПАРУ ДАТ, і більше нічого ----
 {"zone": &"z.cab.folder_1", "tool": &"tool.hand", "verb": &"apply", "facts": [&"f.c7.f1"],
  "say": "Folder 1. Seal set 14 April. Notice of death, 20 April. Six days."},
 {"zone": &"z.cab.folder_2", "tool": &"tool.hand", "verb": &"apply", "facts": [&"f.c7.f2"],
  "say": "Folder 2. Seal set 2 June. Notice of death, 6 June. Four days."},
 {"zone": &"z.cab.folder_3", "tool": &"tool.hand", "verb": &"apply", "facts": [&"f.c7.f3"],
  "say": "Folder 3. Seal set 19 September. Notice of death, 28 September. Nine days."},
 {"zone": &"z.cab.folder_4", "tool": &"tool.hand", "verb": &"apply", "facts": [&"f.c7.f4"],
  "say": "Folder 4. Seal set 11 January. Notice of death, 16 January. Five days."},
 {"zone": &"z.cab.folder_5", "tool": &"tool.hand", "verb": &"apply", "facts": [&"f.c7.f5"],
  "say": "Folder 5. Seal set 3 March. Notice of death, 9 March. Six days."},
 {"zone": &"z.cab.folder_6", "tool": &"tool.hand", "verb": &"apply", "facts": [&"f.c7.f6"],
  "say": "Folder 6. Seal set 27 July. Notice of death, 2 August. Six days."},
 # ТЕКА-ВИНЯТОК: печатки не було, і людина жива
 {"zone": &"z.cab.folder_7", "tool": &"tool.hand", "verb": &"apply", "facts": [&"f.c7.f7_alive"],
  "say": "Folder 7. Returned without a certificate — the line for the seal is empty. The owner wrote again last winter, about a different matter."},
 # ---- УДАР: власні атестати ----
 {"zone": &"z.cab.own_1", "tool": &"tool.hand", "verb": &"apply", "facts": [&"f.c7.own_1"],
  "say": "A card in your own hand. The client's name written by you. Seal set — and the notice of death is already pinned behind it.",
  "sfx": &"page_turn"},
 {"zone": &"z.cab.own_2", "tool": &"tool.hand", "verb": &"apply", "facts": [&"f.c7.own_2"],
  "say": "The second card in your own hand. The same loop on the H at the foot of the deposit receipt.",
  "sfx": &"page_turn", "music": &"stop"},   # музика ОБРИВАЄТЬСЯ на середині такту (REZHYSURA §6Б)
 # ---- ГРОСБУХ: вивід РОКУ (не читання!) ----
 {"zone": &"z.ledger.numbers", "tool": &"tool.eye", "verb": &"apply", "facts": [&"f.c7.led_count"],
  "say": "The seals are numbered without a break. The last is 1 429. Yours are the ones after it."},
 {"zone": &"z.ledger.dated_a", "tool": &"tool.eye", "verb": &"apply", "facts": [&"f.c7.led_a"],
  "say": "A dated spread: seal 402 was set in the spring of 1871."},
 {"zone": &"z.ledger.dated_b", "tool": &"tool.eye", "verb": &"apply", "facts": [&"f.c7.led_b"],
  "say": "Another dated spread: seal 1 106 was set in the autumn of 1889."},
 # ---- ХИБНИЙ СЛІД ----
 {"zone": &"z.news.cholera", "tool": &"tool.eye", "verb": &"apply", "facts": [&"f.c7.cholera"],
  "say": "The file for that spring carries a notice of cholera in the eastern quarters. Two of the seven dates fall inside that fortnight."},
 # ---- СЕЙФ: приймає ЧИСЛО, введене гравцем ----
 {"zone": &"z.safe.dial", "tool": &"tool.hand", "verb": &"apply",
  "input": &"number", "answer": 1862, "tolerance": 1,
  "on_ok": {"sets_state": {&"z.safe.dial": &"open"}, "sfx": &"stamp_seal",
            "say": "The wheels stop. The door comes away from the frame."},
  "on_fail": {"say": "The wheels turn past and settle back."}},
]
```

**Арифметика року (це і є загадка, а не читання):**
`(1889 − 1871) років / (1106 − 402) печаток` = 18 / 704 ≈ **0.0256 року на печатку**.
Від печатки 402 назад до печатки 1: `402 × 0.0256 ≈ 10.3 року` → `1871 − 10 = ` **1861–1862**.
Допуск ±1 рік. Запасна дорога (V6, драбина): на першій сторінці гросбуха рік вписаний
рукою попередника, але **залитий чорнилом** — читається лише на просвіт **свічкою**.

---

## 4. ФАКТИ (`ENGINE_SPEC` §1.4)

| fact_id | text (нотатник, EN) | cite (графа «на підставі») | tag | weight |
|---|---|---|---|---|
| `f.c7.lid_mono` | "Monogram R. H. on the lid. Cuts dark at the bottom, worn even at the top." | "the monogram, worn evenly" | `body` | 1 |
| `f.c7.inner_marks` | "Four punches inside the lid: maker's shield, Diana head with a 2, office letter inside the outline, a zigzag scratch beside them." | "four punches, complete" | `marks` | 2 |
| `f.c7.acid_red` | "Schwerter's solution runs blood-red on the streak, like the 900 needle." | "the assay: blood-red, 900" | `metal` | 2 |
| `f.c7.hinge_ok` | "The hinge barrel is of one piece with the body. No solder, no filler." | "the hinge, undisturbed" | `body` | 1 |
| `f.c7.thumb_wear` | "The thumbpiece is polished away on its left side only, deeper than the engraving." | "the wear under a left thumb" | `hand` | **3** |
| `f.c7.receipt_gnat` | "Deposit receipt signed R. Hnat. The H finished with a loop that comes back on itself." | "the signature R. Hnat" | `papers` | 2 |
| `f.c7.f1` … `f.c7.f6` | "Folder N. Seal set DD. Notice of death, DD. N days." | "folder N: seal, then death" | `folders` | 2 each |
| `f.c7.f7_alive` | "Folder 7. Returned without a certificate — the seal line is empty. The owner wrote again last winter." | "folder 7: no seal, and alive" | `folders` | **3** |
| `f.c7.own_1` | "A card in your own hand. The name written by you. Seal set — the notice of death pinned behind it." | "my own certificate, and what followed it" | `self` | **3** |
| `f.c7.own_2` | "The second card in your own hand. The same loop on the H." | "my own hand, twice" | `self` | **3** |
| `f.c7.led_count` | "The seals are numbered without a break. The last is 1 429." | "the ledger runs to 1 429" | `books` | 1 |
| `f.c7.led_a` | "Seal 402 was set in the spring of 1871." | "seal 402, spring 1871" | `books` | 2 |
| `f.c7.led_b` | "Seal 1 106 was set in the autumn of 1889." | "seal 1 106, autumn 1889" | `books` | 2 |
| `f.c7.cholera` | "A notice of cholera that spring. Two of the seven dates fall inside that fortnight." | "the cholera fortnight" | `papers` | 1 |

---

## 5. АТЕСТАТ (`ENGINE_SPEC` §1.5) — 6 граф, **дві числові**

| # | Префікс (EN) | Тип | Гейт | Варіанти / відповідь |
|---|---|---|---|---|
| 1 | "The case was made in" | список | `f.c7.inner_marks` | Vienna 900 · Pest 800 · Warsaw 875 |
| 2 | "The metal is" | перетягування факту | `f.c7.acid_red` | будь-який факт `metal` |
| 3 | "The piece has passed through this bureau" | **ЧИСЛО** | ≥3 факти `folders` | **7** (і восьмий — твій) |
| 4 | "The earliest seal in this ledger was set in the year" | **ЧИСЛО** | `f.c7.led_a` + `f.c7.led_b` | **1862** (±1) |
| 5 | "The hand that brought them is" | список | `f.c7.thumb_wear` | one hand · many hands · cannot be told |
| 6 | "On this I set my name — I rely upon" | перетягування ≥2 фактів | графа 5 заповнена | тільки зібрані факти |

**Графа 4 і є код сейфа.** Гравець вписує рік в атестат — і **той самий рік** набирає на диску.
Гра не каже, що це одне й те саме. Зв'язок робить гравець.

---

## 6. НАСЛІДКИ (`ENGINE_SPEC` §1.6)

```gdscript
const OUTCOMES := [
 # правильно + власні атестати впізнані
 {"when": {"5": &"opt.hand.one", "cite_has": [&"f.c7.own_1", &"f.c7.own_2"]},
  "text_key": "out.c7.recognised"},
 # правильно, але власних карток не торкнувся
 {"when": {"5": &"opt.hand.one"}, "text_key": "out.c7.pattern_only"},
 # повірив холері
 {"when": {"5": &"opt.hand.many"}, "text_key": "out.c7.cholera"},
 {"text_key": "out.c7.declined"},
]
```

- **`out.c7.recognised`** — "Doroshenko collects his paper and is gone before noon. In the evening you take the two cards out of the cabinet again and hold them side by side, and there is nothing wrong with either of them. That is the part you cannot put down."
- **`out.c7.pattern_only`** — "You wrote *one hand*, and you were right, and you could not have said whose. The cabinet keeps its own account of it."
- **`out.c7.cholera`** — "You wrote *many hands*. The eastern quarters did have cholera that spring; two of the seven died of it. The other five did not die of anything the papers named."
- **`out.c7.declined`** — "You declined to say. Doroshenko takes the case to a bureau on the other side of the river, and it is certified there within the week."

---

## 7. ХИБНИЙ СЛІД

**Холерний тиждень.** Дві з семи дат припадають на реальний спалах у східних кварталах
(є в підшивці). Патерн читається як **збіг епідемії** — і це чесна, правдоподібна гіпотеза,
бо холера справді забирала за 4–9 днів.

**Чим спростовується:** решта п'ять дат розкидані по чотирьох різних роках і чотирьох різних
кварталах міста. Плюс **тека 7**: там печатки **не було** — і людина жива. Епідемія не
розрізняє, хто мав папір.

**Чому це не декорація:** гравець, який купився, напише «many hands», отримає правильну
частину (двоє справді від холери) і **ніколи не дізнається** про решту п'ять. Наслідок
`out.c7.cholera` не називає це помилкою.

---

## 8. ДВІ ГІПОТЕЗИ І РОЗВОДЖУВАЛЬНИЙ ФАКТ

**(А)** Сім речей — від різних людей, збіг дат випадковий (холера, вік, місто без каналізації).
**(Б)** Сім речей приносила **одна рука**, і смерть настає після **печатки**, не після продажу.

Один факт їх не розводить: підпис «Р. Гнат» доводить лише спільність **двох** квитанцій;
холера пояснює **дві** смерті; потертість під лівий великий палець сама по собі — просто знос.

**Розводить тека 7:** там **та сама рука**, той самий портсигарний тип речі — але **печатки не
було**, і власник **живий**. Одна відсутність вирішує все: змінна — не рука і не хвороба,
а **папір**.

---

## 9. СТРИБОК ДУМКИ

> Смерть настає не після продажу, а після **печатки** — і виняток це доводить, бо саме там
> печатки не було. А два останні документи в цьому ряду **виписав я сам**.

---

## 10. ВХІД (діегетично, без підказок UI)

1. **У картотеку:** підпис на квитанції клієнта («Р. Гнат») **уже стояв** у теці справи 3
   (годинник). Нотатник тримає обидва рядки — гравець сам зіставляє почерк.
2. **До семи тек:** нижня шухляда картотеки відмикається ключиком зі справи 4 (олійниця).
   Попередник лишив **сім тек висунутими на палець** — рука сама тягнеться.
3. **До гросбуха за роком:** графа 4 атестата питає рік прямо. Гросбух лежить на столі
   щовечора з першого дня — гравець уже знає, що там нумерація.
4. **Запасна дорога:** рік на першій сторінці гросбуха, залитий чорнилом → **свічка на просвіт**.
5. **До сейфа:** сейф уже відкритий за портретом (справа 5, шпилька). Він **порожній до цієї
   миті** — диск не приймав нічого, бо гравець не мав числа.

---

## 11. РЕЖИСУРА (`REZHYSURA` §6Б — розкадровано)

Порожній стіл 1.4 с → **сім тек по 0.55 с рівними інтервалами, як метроном** (жодного
акценту) → загальний 2.0 с → чотири вставки дат по 0.4 с → тека-виняток 1.2 с, наїзд 8% →
*гравець тягне восьму — свою* → **музика обривається на середині такту** → власний почерк
1.6 с у тиші → **від'їзд ширше за майстер-шот, з'являється стеля** 1.0 с →
**тримати найширший 4.0 с**, на третій секунді один удар годинника → стик на **порожнє
гніздо для штампа** 1.0 с.

---

## 12. АРТ, ЯКОГО ПОТРЕБУЄ СПРАВА

| Асет | Що саме | Нотатка |
|---|---|---|
| `cigcase.glb` | портсигар, 2 частини (корпус + кришка на завісі) | Meshy; `--compress false` |
| `cabinet_face` | фронт картотеки з висунутими сімома теками | правка кадру хаба |
| `cabinet_face` стан `own_cards` | ті самі шухляди + дві картки твоєю рукою | правка попереднього |
| `ledger_spread` | розворот гросбуха з нумерацією і двома датованими сторінками | гравюра + текст шрифтом |
| `safe_closed` / `safe_open` | сейф за портретом | правка кадру хаба |
| `folder_case` ×7 | обкладинки тек, `rest` / `dragged` / `aligned` | один арт + стани |

---

## 13. ДЕ Я САМ СУМНІВАЮСЯ

1. **Арифметика року може виявитись задовгою для казуала.** 18/704 у голові не порахуєш —
   потрібен олівець. Запасна дорога (свічка) обов'язкова, і її треба **перевірити агентом-казуалом
   першою**, а не останньою.
2. **Сім тек по 0.55 с = 3.85 с чистої анімації.** Режисер вимагає рівних інтервалів без
   акценту. Є ризик, що гравець почне клікати наскрізь. Пропоную: **анімація не скіпається,
   але теки можна відкривати в будь-якому порядку** — тоді це його ритм, не наш.
3. **Чи не завчасно давати «власні атестати» у справі 7 із 11?** За V6 це ХВИЛЯ 2 і пік акту ІІ.
   Але після цього лишається чотири справи, і всі — на спуску напруги. Наративник це вже
   ловив. Можливо, `own_2` варто відкривати лише у справі 8.
