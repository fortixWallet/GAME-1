# СПРАВА 3 — «ГОДИННИК ІЗ ДВОХ ГОДИННИКІВ»
### 30 хв · акт I, третя справа · роль: **перші дві живі гіпотези** + постановка наскрізної нитки «Р. Гнат»
### Спец до ENGINE_SPEC §1 (ZONES / RULES / FACTS / SLOTS / OUTCOMES). Усі рядки гри — англійською; коментарі — українською.

**Рік дії:** 1901 (двадцять років від квитанції 1881 — узгоджено з SIUZHET_V6 §4.3).
**Що нове порівняно зі справами 1–2:** вперше два папери **однаково правдиві**; вперше
предмет розбирається (кришка → кювета → механізм); вперше довідник, який гравець уже вміє
читати (таблиця клейм зі справи 1), працює **як навичка, а не як трюк**.

---

## 1. ЗАГОЛОВОК

| | |
|---|---|
| № | 3 |
| Назва (UA) | Годинник із двох годинників |
| Назва (EN, у грі) | **A Watch Made of Two Watches** |
| Хронометраж | 30 хв (зон 7 + 8 паперових, фактів 14, граф 6, звірок із довідником 4) |
| Роль в акті | Дві правдоподібні гіпотези, обидві живі до останньої графи. Вперше гравець мусить сказати «бреше не людина — бреше річ». Тут же тихо ставиться підпис **«R. Hnat»**, який вибухне у справі 7 |
| Предмет | Кишеньковий срібний годинник-савонетка (глуха задня кришка + кювета), Ø 55 мм |
| Екрани | `HANDS` (3D-модель годинника), `DOCS` (папери клієнта + тека бюро), `BOOKS` (4 довідники) |
| Нові інструменти | `tool.opener` — ножик годинникаря (підважити кювету). Решта вже в поясі: `tool.hand`, `tool.loupe`, `tool.rake`, `tool.caliper` |

---

## 2. КЛІЄНТ

**Emil Rausch**, 26, племінник покійного. Приходить сам; удова не приходить **жодного разу** —
її голос у справі це два аркуші паперу.

**Довідка для наратора (у грі не звучить):** дядько — **Anton Rausch**, бухгалтер міської
броварні, помер узимку 1900. Удова — **Marta Rausch**.

**Потреба, не пов'язана з річчю.**
> "My sister is at Sankt Anna. The board is sixty kronen and it is due Friday. I do not need
> the watch, I need a paper that says what the watch is."

**Фізична деталь, яку кадр показує і жоден текст не коментує.**
Свіжа чорнильна пляма на **перетинці правої руки, між великим і вказівним** — так мажеться той,
хто щойно писав правою і зачепив ребром долоні. Він розписується в книзі прийому **правою**,
у кадрі, на початку сцени. Гра про це не каже нічого й ніколи.
*(Це тихо знімає з нього сідловину на дужці — але тільки для того, хто помітить.)*

**Дві репліки на печатку.**
| Умова | Репліка |
|---|---|
| печатка < 8 хв від початку справи | "That was quick. My aunt said you would take a week and side with her." |
| печатка > 20 хв | "You opened it twice. Nobody ever opened it twice." |

**Одна репліка-приманка** (звучить, коли гравець уперше бере лупу):
> "He wound it every Sunday after church. It never once stopped."

---

## 3. ЗОНИ ПРЕДМЕТА

Екран `HANDS`, 3D. Anchor `watch_pivot`, масштаб моделі: **радіус корпусу = 1.0** (55 мм ≈ 2.0
одиниці в поперечнику), товщина корпусу ±0.28. Задня кришка — окремий вузол `lid_back`, який
**повертається** при відкриванні: тому внутрішня поверхня кришки не потребує ані прапорця, ані
окремої зони — її ловить `facing_min` (закрита кришка дивиться нутром усередину корпусу).

| id зони | де саме | вид | координати (локальні, anchor) | r | facing_min | label_key |
|---|---|---|---|---|---|---|
| `z.lid_back_outer` | зовні задньої кришки — сюди тиснуть, щоб відкрити | node3d · `watch_pivot` | p (0.00, 0.00, −0.26) · n (0, 0, −1) | 0.80 | 0.15 | `zone.lid_back` |
| `z.lid_back_inner` | **нутро** задньої кришки: клейма + продряпані дати | node3d · **`lid_back`** | p (0.00, 0.00, +0.03) · n (0, 0, +1) | 0.72 | 0.20 | `zone.lid_inside` |
| `z.cuvette` | кювета (глуха пилозахисна кришка над механізмом) | node3d · `watch_pivot` | p (0.00, 0.00, −0.19) · n (0, 0, −1) | 0.66 | 0.15 | `zone.cuvette` |
| `z.movement_plate` | верхня платина механізму, під кюветою | node3d · `watch_pivot` | p (0.00, +0.10, −0.13) · n (0, 0, −1) | 0.42 | 0.15 | `zone.movement` |
| `z.movement_seat` | стик механізму з посадковим гніздом корпусу, на 6-й годині | node3d · `watch_pivot` | p (0.00, −0.60, −0.13) · n (0, 0, −1) | 0.17 | 0.10 | `zone.seat` |
| `z.band_stem` | ранта на 12-й годині: отвір під заводний вал і сама голівка | node3d · `watch_pivot` | p (0.00, +0.98, 0.00) · n (0, +1, 0) | 0.16 | 0.05 | `zone.stem` |
| `z.bow` | **дужка** (кільце в підвісці, за яке чіпляють ланцюжок) | node3d · `watch_pivot` | p (0.00, +1.30, 0.00) · n (0, +1, 0) | 0.20 | 0.02 | `zone.bow` |

**Стани зон** (початковий у всіх — `default`):
`z.lid_back_outer`: `default → open` · `z.cuvette`: `default → reachable → open` ·
`z.movement_plate`, `z.movement_seat`: `default → exposed` · `z.lid_back_inner`: `default → raked`.

### 3b. Допоміжні зони (папери й довідники, 2D — частки ЗОБРАЖЕННЯ)

| id зони | поверхня (арт) | екран | u (центр) | r | що це |
|---|---|---|---|---|---|
| `z.doc.deed` | `deed_1896` | DOCS | (0.500, 0.420) | 0.150 | дарча дядька, 1896 — папір племінника |
| `z.doc.list` | `fire_list_1899` | DOCS | (0.470, 0.560) | 0.140 | опис майна для страхового товариства, 1899 — папір удови |
| `z.doc.letter` | `letter_1890` | DOCS | (0.520, 0.380) | 0.160 | лист дядька, 1890 — **хибний слід** |
| `z.doc.folder_1881` | `folder_bureau` | DOCS | (0.560, 0.470) | 0.130 | квитанція бюро 20.03.1881, підпис «R. Hnat» |
| `z.book.marks` | `book_hallmarks` | BOOKS | (0.330, 0.520) | 0.170 | таблиця клейм пробірної управи (та сама, що у справі 1) |
| `z.book.serials` | `book_serials` | BOOKS | (0.660, 0.480) | 0.170 | список номерів мануфактури Cuenot Frères |
| `z.book.directory` | `book_directory` | BOOKS | (0.350, 0.600) | 0.160 | адресна книга годинникарень — **сторінка загнута попередником** |
| `z.book.lignes` | `book_lignes` | BOOKS | (0.640, 0.620) | 0.150 | таблиця ліній (ligne → мм). Дає лише `say`, факту не дає — читати мусить гравець |

---

## 4. ПРАВИЛА (зона × інструмент → факт)

`note` = англійський текст **спостереження** (`say_key`), який лунає в момент дії. Висновку в
ньому нема ніде. Порядок у таблиці = порядок у `const RULES`.

| # | zone_id | tool | requires (`needs` / `zone_state`) | fact_id | note (EN, спостереження) | sets_state |
|---|---|---|---|---|---|---|
| r.01 | `z.lid_back_outer` | `tool.hand` (on_click) | — | — | "The back springs open on its hinge." | `z.lid_back_outer→open`, `z.cuvette→reachable` |
| r.02 | `z.lid_back_inner` | `tool.eye` (dwell 0.4) | — | — | "The inside of the lid is not smooth. Something is cut into it, too fine to read." | — |
| r.03 | `z.lid_back_inner` | `tool.loupe` (dwell 0.6) | — | **`f.case_marks`** | "Struck inside the back: a lozenge, JW. Beside it the figure 13, the letter A, and the figures 64. Apart from these, deeper and larger: 4198." | — |
| r.04 | `z.lid_back_inner` | `tool.rake` (on_click) | — | — | "Held aslant to the lamp, the lid throws a field of hair-thin lines." | `z.lid_back_inner→raked` |
| r.05 | `z.lid_back_inner` | `tool.loupe` (dwell 1.4) | `zone_state: raked` | **`f.scratch_dates`** | "Six lines scratched inside the back, one under another: 3/74 L·B — 11/79 L·B — 6/83 K✳ — 2/86 K✳ — 9/93 F·M — 4/97 F·M." | — |
| r.06 | `z.cuvette` | `tool.opener` (on_click) | `zone_state: reachable` | — | "The inner cover lifts on the point of the knife." | `z.cuvette→open`, `z.movement_plate→exposed`, `z.movement_seat→exposed` |
| r.07 | `z.cuvette` | `tool.loupe` (dwell 0.6) | `zone_state: open` | **`f.cuvette_number`** | "Engraved on the inner cover, in a running hand: Piguet-Rey, Genève. No 21 607." | — |
| r.08 | `z.cuvette` | `tool.loupe` (dwell 1.2) | `zone_state: open`, `needs: f.cuvette_number` | **`f.cuvette_plugs`** | "Two round holes are cut through the inner cover and stopped with silver plugs. Behind them the plate is blank metal." | — |
| r.09 | `z.movement_plate` | `tool.loupe` (dwell 0.6) | `zone_state: exposed` | **`f.movement_number`** | "On the top plate: Cuenot Frères, Le Locle. No 118 744. Fifteen jewels." | — |
| r.10 | `z.movement_seat` | `tool.loupe` (dwell 0.8) | `zone_state: exposed` | **`f.spacer`** | "A brass ring lies between the movement and the seat of the case. Its turning marks are bright." | — |
| r.11 | `z.movement_seat` | `tool.caliper` (on_click, MEASURE) | `zone_state: exposed` | **`f.spacer`** *(той самий факт, друга дорога)* | "Across the movement: 43.0 mm. Across the seat of the case: 45.1 mm." | — |
| r.12 | `z.band_stem` | `tool.loupe` (dwell 0.8) | — | **`f.band_cut`** | "The opening for the winding stem is cut through the band. The file marks inside it are white; the band around them is grey." | — |
| r.13 | `z.band_stem` | `tool.hand` (on_click) | — | — | "The crown turns and the mainspring answers." | — |
| r.14 | `z.bow` | `tool.loupe` (dwell 0.8) | — | **`f.bow_saddle`** | "Two grooves cross the bow. The one on the left flank is deep and its edges are rounded smooth. The one on the right is shallow and still bright." | — |
| r.15 | `z.bow` | `tool.caliper` (on_click) | `needs: f.bow_saddle` | — | "1.9 mm where the bow is whole. 0.9 mm in the left groove. 1.7 mm in the right." | — |
| r.16 | `z.book.marks` | `*` (on_click) | `needs: f.case_marks` | **`f.tbl_marks`** | "The table: from 1806 to 1866 the mark carries the last two figures of the year. Fineness is given in Loth; 13 Loth is the case standard. A is the Vienna office. From 1867 the Diana head replaces all of it, and the year is gone." | — |
| r.17 | `z.book.serials` | `*` (on_click) | `needs: f.movement_number` | **`f.tbl_serials`** | "Cuenot Frères, list of numbers for repairers: 112 900–117 199 · 1887. 117 200–121 480 · 1888. 121 481–126 010 · 1889." | — |
| r.18 | `z.book.directory` | `*` (on_click) | — | **`f.tbl_workshops`** | "The folded page: L·B — L. Bauer, watch cases, Wien, 1861–1881. K✳ — J. Kraml, 1879–1890. F·M — F. Marek, from 1888. JW — J. Wenzl, case-maker, 1859–1884." | — |
| r.19 | `z.book.lignes` | `*` (on_click) | — | — | "One ligne is 2.2558 mm. Nineteen lignes, 42.86. Twenty lignes, 45.12." | — |
| r.20 | `z.doc.deed` | `*` (on_click) | — | **`f.deed_case_no`** | "Deed of gift, 1896, in the uncle's hand: to my nephew Emil, after me, the silver watch, case number 4198." | — |
| r.21 | `z.doc.list` | `*` (on_click) | — | **`f.list_movement_no`** | "Fire-office list of the household, 1899, made by their valuer: one silver watch, No. 118 744." | — |
| r.22 | `z.doc.letter` | `*` (on_click) | — | **`f.letter_uncle`** | "Letter, 1890: my watch, bought new at Michaelmas, loses two minutes in the week." | — |
| r.23 | `z.doc.folder_1881` | `*` (on_click) | `needs_any: f.case_marks, f.cuvette_number` | **`f.receipt_1881`** | "Bureau folder, 20 March 1881: silver hunting case, JW 4198, twenty lignes; movement Piguet-Rey 21 607; winds by key, key attached; valued 42 fl. Signed in the margin: R. Hnat." | — |

**Примітки для програміста.**
- r.10 і r.11 дають **один і той самий** `f.spacer` — `add_fact()` з'їсть дубль. Числа з r.11 звучать у `say` і лягають у `note` картки, факт від цього не роздвоюється.
- r.15 — вимірювання **без факту**: чисте число в репліку. Так глибина сідловини не стає окремою карткою, але гравець її чує.
- r.23 гейт: тека бюро відкривається на пошук за номером, і номер треба спершу побачити на речі. Обидві дороги (номер корпусу або номер кювети) ведуть у ту саму квитанцію — це навмисно.
- Жодне правило не має `forbids`. Порядок огляду вільний, окрім фізичного: кришка → кювета → механізм.

---

## 5. ФАКТИ

`weight`: 3 = розводить гіпотези · 2 = твердий доказ · 1 = натяк або приманка.

| fact_id | text (EN, нотатник) | cite (у графі «on the basis of») | tag / group | w |
|---|---|---|---|---|
| `f.case_marks` | "Struck inside the back: JW in a lozenge; 13; A; 64; and, apart from them, 4198." | "the marks inside the back" | `marks` | 2 |
| `f.scratch_dates` | "Scratched inside the back: 3/74 L·B, 11/79 L·B, 6/83 K✳, 2/86 K✳, 9/93 F·M, 4/97 F·M." | "the repair dates inside the back" | `marks` | **3** |
| `f.cuvette_number` | "Engraved on the inner cover: Piguet-Rey, Genève, No 21 607." | "the name on the inner cover" | `marks` | **3** |
| `f.cuvette_plugs` | "Two holes through the inner cover, stopped with silver plugs; blank plate behind them." | "the plugged holes in the inner cover" | `body` | 2 |
| `f.movement_number` | "On the top plate: Cuenot Frères, Le Locle, No 118 744." | "the number on the movement" | `marks` | 2 |
| `f.spacer` | "A brass ring fills the seat between movement and case; its turning marks are bright. Movement 43.0 mm, seat 45.1 mm." | "the brass ring in the seat" | `body` | **3** |
| `f.band_cut` | "The stem opening is cut through the band; white file marks inside it, grey band around." | "the fresh cut in the band" | `body` | 2 |
| `f.bow_saddle` | "Two grooves in the bow: deep and rounded on the left flank, shallow and bright on the right." | "the two grooves in the bow" | `wear` | **3** |
| `f.tbl_marks` | "Table of assay marks: to 1866 the mark carries the year; 13 Loth is the case standard; A is Vienna. From 1867, the Diana head and no year." | "the table of assay marks" | `books` | 2 |
| `f.tbl_serials` | "Cuenot Frères: 117 200–121 480 were entered in 1888." | "the maker's list of numbers" | `books` | 2 |
| `f.tbl_workshops` | "Directory: L. Bauer 1861–1881; J. Kraml 1879–1890; F. Marek from 1888; J. Wenzl, case-maker, 1859–1884." | "the directory of workshops" | `books` | 1 |
| `f.receipt_1881` | "Bureau folder, 1881: case JW 4198 with movement Piguet-Rey 21 607, key-wound. Signed R. Hnat." | "this bureau's own receipt of 1881" | `papers` | **3** |
| `f.deed_case_no` | "Deed of gift, 1896: the silver watch, case number 4198, to the nephew." | "the deed of gift" | `papers` | 2 |
| `f.list_movement_no` | "Fire-office list, 1899: one silver watch, No. 118 744." | "the fire-office list" | `papers` | 2 |
| `f.letter_uncle` | "Letter, 1890: my watch, bought new at Michaelmas, loses two minutes in the week." | "the uncle's letter" | `papers` | **1** ← приманка |

**14 фактів + `f.letter_uncle`** — приманка рахується окремо і має вагу 1 навмисно: атестат,
зіпертий на неї, не добере `basis_weight` найкращої гілки. Гравець цього не бачить.

---

## 6. ДОВІДНИКОВІ ТАБЛИЦІ (історичні значення — справжні)

### 6.1. Клейма пробірної управи, австрійські землі (та сама таблиця, що у справі 1)

| Період | Що в клеймі | Наслідок для датування |
|---|---|---|
| до 1806 | цехове міське + клеймо майстра | року нема |
| 1806/07 | **репунцирування** — усе старе срібло здають на переклеймування | — |
| **1806–1866** | **дві останні цифри року** + проба в **лотах** + літера управи (**A = Wien**) | **рік читається прямо** |
| 1867–1922 | «голова Діани» з цифрою проби (1 = 950, 2 = 900, 3 = 800, 4 = 750) | **року в клеймі нема** |
| з 1872 | код міста перенесено **всередину** пуансона Діани | межа для справи 1 |

**Лоти:** 16 лотів = чисте срібло; **13 лотів = 812.5/1000** — звичайна проба корпусів
кишенькових годинників. Клеймо нашого корпусу: **13 · A · 64 → Відень, 1864**.

### 6.2. Список номерів мануфактури (реальна практика: заводські реєстри для ремонтників)

| Номери | Рік |
|---|---|
| 112 900 – 117 199 | 1887 |
| **117 200 – 121 480** | **1888** |
| 121 481 – 126 010 | 1889 |

Механізм **№ 118 744 → 1888**.

### 6.3. Адресна книга годинникарень (загнута сторінка)

| Знак | Майстерня | Роки |
|---|---|---|
| L·B | L. Bauer, ремонт корпусів, Wien | 1861–1881 |
| K✳ | J. Kraml | 1879–1890 |
| F·M | F. Marek | з 1888 |
| JW (ромб) | **J. Wenzl, корпусник** | 1859–1884 |

### 6.4. Лінії (ligne) — розмір механізму

**1 ligne = 2.2558 мм.** 19 л. = 42.86 мм · 19½ л. = 43.99 · **20 л. = 45.12 мм**.
Механізм 43.0 мм ≈ **19 ліній**; гніздо корпусу 45.1 мм = **20 ліній**.

### 6.5. Заводження (контекст, не доказ)

Ключове заводження (à clef, крізь отвори в кюветі, ключем) панує до 1870-х; безключове
(вал + голівка, патент А. Філіпа 1842/45) поширюється з 1860-х і стає стандартом у 1880-х.
**Обережно:** безключові годинники існували й у 1860-х, тому «корпус 1864 = обов'язково
ключовий» — не доказ. Доказ документальний: квитанція 1881 прямо каже **«winds by key,
key attached»**, а фізичний — дві заглушені дірки в кюветі й свіжий проріз у ранті.

### 6.6. Номер корпусу ≠ номер механізму (реальна практика доби)

Корпуси робили окремі майстри-**корпусники** (boîtiers) і нумерували **своєю** серією;
мануфактура нумерувала механізми своєю. Перекорпусування (recasing) було буденним ремонтом:
розчавлений корпус міняли, механізм лишався. Тому **розбіжність номерів сама по собі —
не злочин і навіть не дивина.** Злочин (чи ні) вирішують дати й папери.

### 6.7. Знос дужки — нотатка бюро, а не друкований довідник

Ланцюжок (single albert) іде з кишені жилета вгору до петлі: годинник у **лівій** кишені →
карабін тягне на **правий** фланг дужки, витягують **правою**. Годинник у **правій** кишені →
сідловина на **лівому** фланзі, витягують **лівою**.
Глибина = роки: 1.0 мм зносу на дужці 1.9 мм — це десятиліття щоденного носіння, не сезон.
**Чесно:** друкованої таблиці такого зносу 1900-й рік не мав. У грі це **власна нотатка
попередника** з намальованою схемою і дописом його рукою — і саме тому вона не «істина з
підручника», а річ, яку гравець може прийняти або ні.

---

## 7. АТЕСТАТ (6 граф, 2 числові)

| # | slot_id | префікс (EN, друком на бланку) | тип | гейт (`needs` / `needs_slot`) | варіанти |
|---|---|---|---|---|---|
| 1 | `s.origin` | "The case was struck at ____" | CHOICE | `needs: f.case_marks, f.tbl_marks` | `o.wien_wenzl` "Vienna, J. Wenzl" · `o.geneve_piguet` "Geneva, Piguet-Rey" · `o.locle_cuenot` "Le Locle, Cuenot Frères" · `o.unknown_house` "no house can be read" |
| 2 | `s.bureau_year` | "This case last passed this bureau in the year ____" | **NUMBER** (4 цифри, 1840–1901, без валідації) | `needs: f.receipt_1881` | — → **1881** |
| 3 | `s.assembled` | "In its present state this watch cannot have been put together before the year ____" | **NUMBER** (4 цифри, 1700–1901, без валідації) | `needs_any: f.tbl_serials, f.scratch_dates` | — → **1888** |
| 4 | `s.composition` | "As it now stands, the watch is ____" | CHOICE | `needs_any: f.scratch_dates, f.spacer, f.bow_saddle` + `needs: f.movement_number, f.case_marks` | `o.one_original` "one watch, as it left its maker" · `o.one_repaired` "one watch, repaired but its own" · `o.two_bodies` "two watches: a movement in another watch's case" · `o.dial_swapped` "one watch with a later dial" |
| 5 | `s.claims` | "This certificate answers ____" | CHOICE | `needs: f.deed_case_no, f.list_movement_no` | `o.nephew` "the deed of gift: the thing is the nephew's" · `o.widow` "the household list: the thing is the widow's" · `o.both_parts` "both papers — each names a different part of the same object" · `o.neither` "neither paper can be told from the other" |
| 6 | `s.basis` | "On the basis of ____" | FACTS (min 2, max 4) | `needs_slot: s.composition, s.claims`; `clears_on: [s.composition, s.claims]` | джерело — `state.fact_order` |

**Правильні значення** (рушій їх не знає; знають лише OUTCOMES):
`s.origin = o.wien_wenzl` · `s.bureau_year = 1881` · `s.assembled = 1888` ·
`s.composition = o.two_bodies` · `s.claims = o.both_parts`.

**Чому 1888, а не 1864:** дата збірки — це **пізніша** з двох дат, і її ніде не написано.
Це і є числова графа, яку не можна прочитати — тільки вивести. Ані реєстр, ані клеймо, ані
квитанція не містять числа 1888 у контексті «збірка»: 1888 стоїть у списку номерів як рік
випуску **механізму**, і гравець мусить сам зрозуміти, що ціле не може бути старшим за свою
наймолодшу частину. Продряпане «9/93» дає другий, слабший шлях: не раніше 1893 — і це
**прийнятна, але гірша** відповідь (див. гілку `out.dated_late`).

---

## 8. НАСЛІДКИ (ранок наступного дня)

Матчер бере **перший** запис, чиї умови збіглися. `out.default` — останній завжди.

| id | when | basis | текст ранку (EN) |
|---|---|---|---|
| `out.split` | `s.composition = o.two_bodies` · `s.claims = o.both_parts` · `s.assembled = 1888` · `s.bureau_year = 1881` | `basis_needs: f.receipt_1881` · `basis_any: [f.scratch_dates, f.bow_saddle, f.cuvette_number]` · `basis_weight ≥ 5` | "The notary's clerk came at nine to copy the certificate, and stayed to copy the second page as well. They have agreed between themselves: the widow keeps the movement, the nephew keeps the case, and a watchmaker in Salt Street will do the parting on Thursday for eleven kronen. The clerk asked, on his way out, whether the bureau still holds its folders from 1881, and whether a man might see one. He did not say which. **The nephew left a note: he will come again in the spring, he says, with his mother's snuffbox.**" |
| `out.forger_named` | `s.claims = o.widow` · `s.composition ∈ {o.one_original, o.one_repaired}` | `basis_forbids: f.scratch_dates` | "The widow's solicitor laid the certificate before the magistrate at eight. A deed that names a number the watch does not carry is a forged deed, and the magistrate has issued a summons in the nephew's name. The paper of the deed has been tested and is of 1896; the ink is of 1896; the hand is the uncle's. None of that is in question, because nobody has asked it. **Sankt Anna returns a letter unopened: the board for the sister was not paid on Friday.**" |
| `out.to_nephew` | `s.claims = o.nephew` | — | "He sold it whole to a dealer in the Graben before noon and paid Sankt Anna the same afternoon. The dealer's own watchmaker opened it in the evening and wrote to us, politely, that the case is a Wenzl of the sixties and the movement is not, and that he assumes the bureau knew this and had its reasons. The widow's letter is one line long and asks nothing. **The nephew will come again in the spring, he says, with his mother's snuffbox.**" |
| `out.dated_late` | `s.composition = o.two_bodies` · `s.assembled ∈ {min 1889, max 1901}` | — | "Nobody disputes the certificate; a watchmaker corrects it. He writes that the movement's number stands in the maker's list for 1888, and that a thing may be put together the day after its youngest part is made or thirty years after, but not before. He asks whether the bureau would like the letter kept out of the folder. **The folder already holds a letter of that kind, in another hand, from a year the bureau does not admit to.**" |
| `out.default` | — | — | "Both papers were returned across the counter and the watch went back into its cloth. The day-book has it as undetermined, with the number of the case and the number of the movement written one under the other, which is how the previous keeper wrote them in 1881, on a page nobody has asked for." |

**Про повернення персонажів (SIUZHET_V6 §5):** нитка «племінник приходить навесні з наступною
річчю родини» вішається на `out.split` **і** `out.to_nephew` — тобто на обидві гілки, де гравець
не зробив із нього злодія. `out.forger_named` цю нитку вбиває, і замість неї у справі 6 приходить
поштою рахунок із Sankt Anna, адресований у бюро.

---

## 9. ХИБНИЙ СЛІД

**Що спокушає.** Лист дядька, 1890: *«my watch, bought new at Michaelmas»*. Він **справжній** —
папір, чорнило, рука. І він **сходиться з двома незалежними джерелами**: список номерів
мануфактури дає механізму 1888 (куплений новим 1889/90 — ідеально), а опис майна удови 1899 року
називає **той самий** номер 118 744. Три джерела в один голос кажуть: це один годинник, куплений
новим, і він дядьків. Тоді дарча племінника з номером 4198 називає номер, якого на цьому годиннику
«нема» — отже, дарча про **іншу річ**, отже — підробка.

**Куди веде.** До атестата `s.composition = o.one_original`, `s.claims = o.widow` і гілки
`out.forger_named`: справжній папір оголошено фальшивим, живу людину — фальшивником, а гроші за
пансіон сестри не сплачено. Слід не декоративний: він **дає повністю несуперечливу картину**,
поки гравець не відкрив задню кришку **вдруге**, під косим світлом.

**Чим спростовується.** Трьома незалежними речами, і кожної з них досить:
1. **Продряпані дати 3/74, 11/79, 6/83, 2/86** — ремонти корпусу, зроблені **до** того, як
   механізм 1888 року взагалі існував. Жодна брехня людини такого не породжує.
2. **Квитанція бюро 1881** — цей самий корпус 4198 уже приходив сюди, з **іншим** механізмом
   (Piguet-Rey 21 607), і той номер досі викарбувано на кюветі.
3. **Латунне кільце в гнізді**: механізм 19 ліній у корпусі, зробленому під 20.

**Чому лист усе одно правдивий** (і це важливо сказати гравцеві мовчки): дядько справді купив
годинник новим 1889-го. Просто у 1893-му старий корпус загинув (продряпаний рядок **9/93 F·M** —
це і є перекорпусування), і майстер поставив механізм у той корпус, що лежав у нього в шухляді.

---

## 10. ДВІ ГІПОТЕЗИ І РОЗВОДЖУВАЛЬНИЙ ФАКТ

**(А) Бреше людина.** Два папери називають два різні номери — отже, один із них про інший
годинник: або племінник підробив дарчу, або удова підмінила річ після похорону. Гіпотеза
тримається на всьому, що бачить око: номер на механізмі збігається зі списком удови, лист дядька
її підтверджує, а розбіжність номерів звучить як улика.
**(Б) Бреше річ.** Обидва папери правдиві, бо описують **різні частини одного предмета**:
дарчу писали, відкривши задню кришку (там номер **корпусу** 4198), а страховий оцінювач знімав
кювету (там номер **механізму** 118 744). Ніхто не збрехав — просто кожен подивився в своє.
**Розводить одне: шість продряпаних дат усередині кришки.** Чотири з них (1874, 1879, 1883,
1886) старші за рік випуску механізму. Під гіпотезою (А) — за будь-якого набору людських
брехень — корпус і механізм є одним предметом, і предмет не може ремонтуватися за чотирнадцять
років до того, як його зробили. Під (Б) це просто біографія корпусу до 1893 року.
Квитанція 1881 і латунне кільце добивають, але вже не розводять.

---

## 11. СТРИБОК ДУМКИ

**Гравець сам розуміє, що суперечність між двома правдивими паперами зникає, щойно перестати
питати «хто з них бреше» і почати питати «чи це одна річ» — бо ціле не може бути старшим за свою
наймолодшу частину, а корпус лагодили за чотирнадцять років до того, як механізм народився.**

---

## 12. ВХІД (діегетично, без підказок)

Чотири незалежні двері; жодна не називає проблеми.

1. **Репліка клієнта на початку:** *"He wound it every Sunday after church."* — а годинник
   з квитанції 1881 заводиться **ключем**, і ключ у квитанції вписано. Спрацює лише заднім числом.
2. **Голе око по нутру кришки** (r.02): *"The inside of the lid is not smooth."* Це весь поштовх
   до косого світла — далі гравець сам.
3. **Загнута попередником сторінка** в адресній книзі годинникарень: розворот на літері W,
   рядок **J. Wenzl, корпусник, 1859–1884** підкреслено нігтем. Загин старий, засмальцьований —
   попередник тримав цю сторінку відкритою не раз. *(Це його слід у справі 3; у справі 7
   з'ясується, навіщо.)*
4. **Тека бюро** відкривається пошуком за номером: вписав 4198 або 21 607 — знайшов 1881-й.
   Пошук за 118 744 не дає нічого, і **це теж інформація**.

**Куди дивиться камера в перші 20 секунд:** годинник лежить у кишеньці з сукна циферблатом
догори, і **дужка звисає за край столу** — єдиний елемент предмета, який видно у профіль ще до
того, як гравець узяв щось у руки.

---

## 13. ЧЕК-ЛИСТ ПРИЙМАННЯ (гейт якості, PUZZLES_V4 §8)

Свіжий агент-казуал після справи мусить сказати **своїми словами**:
> «Це не один годинник. Корпус лагодили в 74-му, а механізм зробили аж у 88-му — значить,
> механізм сюди вставили пізніше. І обидва папери правдиві, просто один читав номер із кришки,
> а другий — із механізму.»

Не сформулював — справа переробляється. Час до першого стрибка ≤ 12 хв від початку справи;
загальний час 27–33 хв; доріг до `f.receipt_1881` дві (номер корпусу або номер кювети).
