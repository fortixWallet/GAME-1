# СПРАВА 11 — «ФІНАЛ»

**Хронометраж:** 20 хв · **Акт III, остання справа** · **ХВИЛЯ 4**
**Роль:** єдина справа гри, де предмет атестації — **людина**, і остання, де гравець ставить
печатку. Нових інструментів **нема**, нових довідників **нема**, нового арту предмета —
мінімум (годинник клієнта — варіант моделі зі справи 3, решта зон уже намальована для
кімнати). Уся вага справи лежить на речах, які гравець тримав у руках десять справ поспіль:
бланк під бюваром, штамп, гросбух, гніздо в шухляді, власна рука.

**Головний закон цієї справи:** гра не називає розв'язку **жодним рядком** — ні в нотатнику,
ні в наслідку, ні в кадрі. Розв'язку промовляє гравець, коли вписує чотири цифри в графу
«Not before». Якщо він їх не впише — гра не заперечить і не підсвітить.

**Порядок беатів (жорстко):**
1. клієнт · квитанція · годинник (5–7 хв, з них ≈5 — хибний слід);
2. бланк з-під бювара, розгорнутий (5–6 хв) — **ХВИЛЯ 4 стається тут, до печатки**;
3. заповнення шести граф (4–5 хв);
4. печатка **або** «повернути без атестата» — кнопка жива;
5. **жест**: шухляда · гніздо · релікварій. Керує гравець, не катсцена.

**Дати справи (звірено з календарем):**

| подія | дата | день тижня |
|---|---|---|
| бюро відчинено (щоденник, стор. 1) | **11 березня 1859** | п'ятниця |
| перша печатка (гросбух, рядок 1) | 28 квітня 1859 | четвер |
| гросбух куплено (форзац) | 1859, «у двадцять четвертий рік його віку» | — |
| годинник клієнта проданий новим (реєстр) | 1871 | — |
| **сьогодні** | **6 травня 1899** | **субота** |
| клієнт стає на нове місце | понеділок, 8 травня 1899 | — |

1899 − 1859 = **40**. 23 + 40 = **63** — вік, що стоїть в описі бланка.
1899 − 63 = **1836** — рік народження, і це **пастка числової графи** (див. §7).

---

## 1. КЛІЄНТ

**Антон Рехбергер**, тридцять один рік, конторник. Прийшов не з річчю, а з проханням:
на новому місці від нього хочуть **«характер»** — письмове свідчення від установи
(§6.1: реальна практика, австрійський *Dienstbuch* / *Zeugnis*). Годинник він виклав на стіл
сам, як застава серйозності розмови: «You'll want something to look at, sir.»

- **Названа потреба, не пов'язана з річчю:** «The room they've found me wants a month
  in advance, and I begin on Monday. I don't need much for it. I only want to know what
  the watch is worth, and I want it in writing that I'm not a thief.»
- **Фізична деталь, яку кадр показує і жоден текст не коментує:** **латунний ключ на
  черевичному шнурку на шиї**; коли він нахиляється над столом, ключ вивалюється з-під
  коміра й лягає на сукно. Борідка — того самого профілю, що ключ, яким гравець відчинив
  двері о 0:00. Ніхто не каже про це нічого. Ні він, ні гра, ні гравець.
  *(Друга, тихіша деталь, теж без коментаря: на його руках **нема** білого шва через
  середній суглоб третього пальця лівої. Руки лежать на столі всю сцену. Це не декор —
  це розводжувальний доказ, і він мусить бути видимий у 4K, див. §10.)*
- **Дві репліки на печатку:**
  - **швидко** (печатка < 6 хв від розгортання бланка): «That was quick, sir. They told
    me this place takes its time about everything.»
  - **довго** (> 14 хв): «You've been very thorough.» …пауза… «I hope I haven't kept you
    from anything.» …пауза… «It's only a watch.»
- **Ім'я вписує гравець** — Рехбергер диктує його по літерах, як людина, чиє прізвище
  завжди пишуть неправильно. Квитанція з цим ім'ям лишається на столі й **стає доказом**
  (`f.own_receipt`): це єдиний свіжий зразок власного почерку гравця в кімнаті.

**Функція клієнта в механіці — три, і всі три тихі:**
1. він приносить **сідловину на дужці** (гак: гравець одразу згадує справу 3 і йде хибним слідом);
2. він змушує **написати квитанцію** (зразок почерку, без якого §4 не працює);
3. він **не має шва на пальці** (розводить дві гіпотези).

---

## 2. ЗОНИ ПРЕДМЕТА

Одиниця 3D годинника — та сама, що у справі 3: **радіус корпусу = 1.0** (55 мм),
anchor `watch_pivot`. Годинник гравця — окрема сцена з тим самим ригом,
anchor `own_watch_pivot`, масштаб 0.92 (менший корпус, 50 мм).
2D-зони — у частках **ЗОБРАЖЕННЯ**, радіус у частках ширини зображення (ENGINE_SPEC §1.2).

| zone_id | де саме | kind | екран / surface | координати | r / half | стани |
|---|---|---|---|---|---|---|
| `z.watch.bow` | дужка годинника клієнта | `node3d` | HANDS / `watch_pivot` | p (0.00, +1.30, 0.00) · n (0, +1, 0) | r 0.20 · facing_min 0.02 | — |
| `z.watch.lid_inner` | нутро задньої кришки: клейма + продряпані дати | `node3d` | HANDS / `lid_back` | p (0.00, 0.00, +0.03) · n (0, 0, +1) | r 0.72 · facing_min 0.20 | `default` → `open` |
| `z.watch.cuvette` | кювета над механізмом; у стані `open` — платина з номером | `node3d` | HANDS / `watch_pivot` | p (0.00, 0.00, −0.19) · n (0, 0, −1) | r 0.66 · facing_min 0.15 | `default` → `reachable` → `open` |
| `z.own.watch_bow` | дужка **власного** годинника гравця, викладеного на бювар | `node3d` | HANDS / `own_watch_pivot` | p (0.00, +1.30, 0.00) · n (0, +1, 0) | r 0.20 · facing_min 0.02 | `reveal_needs: f.client_bow_saddle` |
| `z.own.hand` | **власна ліва рука** гравця, що лежить на бюварі коло каламарки | `img` | DESK / `desk_main` | u (0.196, 0.742) · `shape: rect` | half (0.104, 0.058) | `reveal_needs: f.cert_marks` |
| `z.cert.subject` | верхня половина розгорнутого бланка: шапка + графа OBJECT, заповнена чужою рукою | `img` | DOCS / `master_cert_spread` | u (0.500, 0.286) · `shape: rect` | half (0.310, 0.108) | `folded` → `unfolded` |
| `z.cert.fields` | середні дві сторінки бланка: шість розлінованих граф, порожніх | `img` | DOCS / `master_cert_spread` | u (0.500, 0.612) · `shape: rect` | half (0.330, 0.150) | `reveal_needs: zone_state z.cert.subject = unfolded` |
| `z.stamp.face` | **робоче лице штампа** — латунна матриця з кільцем літер | `node3d` | HANDS / `stamp_pivot` | p (0.00, −0.62, 0.00) · n (0, −1, 0) | r 0.55 · facing_min 0.25 | — |

**Вісім зон предмета.** Половина з них — не предмет клієнта, а власність бюро,
і саме в цьому вся справа.

### 2b. Зони обстановки й довідників (окремого арту предмета не мають, у бюджет 6–8 не входять)

| zone_id | де | kind | екран / surface | u / p | r / half |
|---|---|---|---|---|---|
| `z.cert.seal_field` | четверта сторінка бланка: порожнє кільце під сургуч + друкована рубрика | `img` | DOCS / `master_cert_spread` | (0.842, 0.836) | r 0.086 |
| `z.papers.receipt_today` | квитанція, яку гравець щойно виписав на ім'я клієнта | `img` | DESK / `desk_main` | (0.628, 0.690) · `rect` | half (0.118, 0.046) |
| `z.book.ledger_fly` | форзац гросбуха (перед першою сторінкою) | `img` | BOOKS / `ledger_flyleaf` | (0.480, 0.404) · `rect` | half (0.240, 0.070) |
| `z.book.ledger_line1` | гросбух, друкований рядок 1 (той самий, що у справі 4) | `img` | BOOKS / `ledger_spread_1859` | (0.310, 0.284) · `rect` | half (0.230, 0.026) |
| `z.book.diary_p1` | щоденник попередника, перша сторінка (прийшла поштою в акті I) | `img` | BOOKS / `diary_p1` | (0.500, 0.372) · `rect` | half (0.260, 0.120) |
| `z.drawer.nest` | оксамитове гніздо у формі печатки, у верхній шухляді | `img` | DESK / `drawer_open` | (0.404, 0.560) | r 0.092 |
| `z.reliquary.nest` | гніздо всередині релікварія (річ №6, стоїть у кімнаті зі справи 10) | `img` | ROOM / `reliquary_open` | (0.500, 0.520) | r 0.092 |

**`z.reliquary.nest` неактивна до фази 5** (`reveal_needs: phase = gesture`). До того релікварій
у кадрі стоїть **зачинений**, як стояв усі дні після справи 10.

**Заборон нема.** Увесь пояс інструментів доступний: `tool.eye`, `tool.hand`, `tool.loupe`,
`tool.rake`, `tool.candle`, `tool.opener`, `tool.caliper`, `tool.scales`, `tool.schwerter`,
`tool.screwdriver`. **Половина з них у фіналі не дає нічого** — і це навмисно: остання справа
не звужує вибір, вона перевіряє, чи гравець навчився не хапатися за інструмент.

---

## 3. ПРАВИЛА (зона × інструмент → факт)

`note` — англійський текст **спостереження**, що лунає в момент дії й лягає в нотатник.
Висновку в ньому нема ніде. Порядок у таблиці = порядок у `const RULES`.

| rule_id | zone_id | tool | requires | fact_id | note (EN, спостереження — БЕЗ висновку) | sets_state |
|---|---|---|---|---|---|---|
| `r.bow` | `z.watch.bow` | `tool.loupe` (dwell 0.8) | — | `f.client_bow_saddle` | "Two grooves cross the bow. The one on the left flank is deep and its edges are rounded smooth. The one on the right is shallow and still bright." | реве́ал `z.own.watch_bow` |
| `r.bow_measure` | `z.watch.bow` | `tool.caliper` (on_click) | `f.client_bow_saddle` | — | *(say-only)* "1.8 mm where the bow is whole. 0.9 mm in the left groove." | — |
| `r.lid_open` | `z.watch.lid_inner` | `tool.hand` (on_click) | — | — | *(say-only)* "The back springs open on its hinge." | `z.watch.lid_inner` → `open`, `z.watch.cuvette` → `reachable` |
| `r.lid_read` | `z.watch.lid_inner` (state `open`) | `tool.loupe` (dwell 0.6) | — | — | *(say-only)* "Struck inside the back: a lozenge, A·K, the figures 800, and 22 610. Scratched below in three different hands: 5/78 · 9/85 · 3/94." | — |
| `r.cuvette_open` | `z.watch.cuvette` (state `reachable`) | `tool.opener` (on_click) | — | — | *(say-only)* "The inner cover lifts on the point of the knife." | `z.watch.cuvette` → `open` |
| `r.watch_clean` | `z.watch.cuvette` (state `open`) | `tool.loupe` (dwell 0.7) | — | `f.client_watch_agrees` | "The number on the movement plate is 22 610. It is the number inside the back, figure for figure. The three scratched dates run in order, earliest at the top." | — |
| `r.own_bow` | `z.own.watch_bow` | `tool.loupe` (dwell 0.8) | `f.client_bow_saddle` | `f.own_bow_saddle` | "The bow of the watch out of my own waistcoat carries two grooves. The one on the left flank is deep and its edges are rounded smooth. The one on the right is shallow." | — |
| `r.receipt` | `z.papers.receipt_today` | `tool.loupe` (dwell 0.5) | — | `f.own_receipt` | "The receipt I wrote out this morning: every 'g' is broken at the shoulder, with a burr standing to the left of the break. The nib in the standish throws that burr and has thrown it since I sat down here." | — |
| `r.unfold` | `z.cert.subject` (state `folded`) | `tool.hand` (on_click) | — | — | *(say-only)* "The sheet is a folded one. The two pages inside have not been opened; the paper in the fold is the colour paper is when it has never seen the lamp." | `z.cert.subject` → `unfolded`, реве́ал `z.cert.fields` |
| `r.subject_read` | `z.cert.subject` (state `unfolded`) | `tool.eye` (on_click) | — | `f.cert_is_a_person` | "Where the printed word is OBJECT, the line is filled in the old hand, and it reads: one man, sixty-three years." | — |
| `r.subject_marks` | `z.cert.subject` (state `unfolded`) | `tool.loupe` (dwell 0.9) | `f.cert_is_a_person` | `f.cert_marks` | "Under the marks column: height five feet nine · hair grey, was black · third finger of the left hand seamed white across the middle joint, an old cut, badly healed · carries a watch of no account, the bow worn to a saddle on the left flank · right cuff inked · answers to his own name once in three times." | реве́ал `z.own.hand` |
| `r.subject_hand` | `z.cert.subject` (state `unfolded`) | `tool.loupe` (dwell 1.4) | `f.own_receipt`, `f.cert_marks` | `f.hand_same` | "The letters of the description lean back, not forward. Every 'g' is broken at the shoulder, and the burr stands to the left of the break. Where a word was struck out, the correction was made without lifting the nib." | — |
| `r.subject_ink` | `z.cert.subject` (state `unfolded`) | `tool.candle` (dwell 1.0) | `f.hand_same` | `f.ink_browned` | "Held against the flame, the description shows through the sheet as a brown stain in the fibre, the colour of the first page of the ledger. The receipt beside it shows nothing through at all; that ink is still standing on the surface." | — |
| `r.fields_read` | `z.cert.fields` | `tool.eye` (on_click) | — | — | *(say-only)* "Six lines, ruled and printed, and nothing written on any of them. The last of them is the one I have filled ten times." | — |
| `r.seal_rubric` | `z.cert.seal_field` | `tool.eye` (on_click) | — | `f.seal_rubric` | "Printed small under the ring, where the wax goes: *to be struck in the presence of the subject.*" | — |
| `r.own_hand` | `z.own.hand` | `tool.loupe` (dwell 1.2) | `f.cert_marks` | `f.own_scar` | "Across the middle joint of the third finger of my left hand there is a white seam. It is old. I do not remember getting it." | — |
| `r.die_ring` | `z.stamp.face` | `tool.loupe` (dwell 0.7) | — | `f.bureau_1859` | "The ring of the die reads in reverse, cut to be read in the wax: BUREAU OF ATTRIBUTION · VIENNA · MDCCCLIX." | — |
| `r.die_wear` | `z.stamp.face` | `tool.rake` (dwell 0.6) | `f.bureau_1859` | — | *(say-only)* "The lettering stands sharp all round the ring but at one point, where it is worn down to a shine. The shine is the width of a thumb." | — |
| `r.ledger_fly` | `z.book.ledger_fly` | `*` (on_click) | — | `f.ledger_flyleaf` | "Flyleaf of the ledger, in the hand that wrote its first line: *Bought against the opening of the door, in his twenty-fourth year.* Under it, 1859." | — |
| `r.ledger_1` | `z.book.ledger_line1` | `*` (on_click) | — | `f.bureau_1859` | "Ledger, printed line 1: No. 1 · 28 April 1859 · one brass inkstand · Reindl, T." | — |
| `r.diary_1` | `z.book.diary_p1` | `*` (on_click) | — | `f.bureau_1859` | "Diary, first page, 1859: *the eleventh of March. Opened the door. Swept it twice. No one came.*" | — |
| `r.nest` | `z.drawer.nest` | `tool.loupe` (dwell 0.6) | — | `f.nest_worn` | "The velvet inside the nest is worn through to the backing, and the backing is shiny. Everywhere else in the drawer the pile stands up." | — |
| `r.nest_hand` | `z.drawer.nest` | `tool.hand` (on_click) | — | — | *(say-only, доступне будь-коли)* "The nest is empty. The die is in my hand." | — |

**Примітки для програміста:**
- **`f.bureau_1859` має три дороги** (`r.die_ring`, `r.ledger_1`, `r.diary_1`) і **один id**.
  Нотатник показує канонічний `FACTS[f].text` (§5), а `note` правила лунає лише в момент дії.
- `r.bow_measure`, `r.lid_read`, `r.die_wear` — **say-only**, факту не дають навмисно:
  вони віддають число/деталь у вухо, не роблячи з неї картку. Так хибний слід не набирає ваги
  в графі «на підставі».
- **Жодне правило не є `DESTRUCTIVE`.** У фіналі нічого не пиляють, не труять кислотою і не
  розбирають. Пропил на речі клієнта, який нічого не приховує, — це те, чого гра не пробачає
  ані гравцеві, ані собі.
- `r.own_hand` — **єдиний клік у грі, спрямований на самого гравця**. Зона не підсвічується
  ніколи, поки не здобуто `f.cert_marks`; після цього курсор над нею змінюється так само, як
  над будь-якою іншою. Гра не запрошує. Запрошує бланк.
- `tool.scales`, `tool.schwerter`, `tool.screwdriver` не мають у цій справі жодного правила.
  Наведення дає стандартний `sfx_nothing` і мовчання. Це третій і останній «прилад мовчить».

---

## 4. ФАКТИ

| fact_id | text (EN, спостереження) | cite («на підставі») | tag / group | weight |
|---|---|---|---|---|
| `f.client_bow_saddle` | "Two grooves in the bow of his watch: deep and rounded on the left flank, shallow on the right." | *the grooves in his watch-bow* | `object` | 1 |
| `f.client_watch_agrees` | "Case number and movement number are the same, 22 610, and the three scratched service dates run in order." | *the numbers in his watch* | `object` | 1 |
| `f.own_bow_saddle` | "The bow of my own watch carries the same two grooves, in the same places." | *the grooves in my own watch-bow* | `object` | 2 |
| `f.own_receipt` | "The receipt I wrote this morning: every 'g' broken at the shoulder, a burr to the left of the break." | *the receipt in my own hand* | `papers` | 1 |
| `f.cert_is_a_person` | "The standing form under the blotter is filled in the old hand, and where it says OBJECT it reads: one man, sixty-three years." | *the object named on the form* | `papers` | 1 |
| `f.cert_marks` | "The marks column lists: grey hair that was black; a white seam across the third finger of the left hand; a watch-bow saddled on the left flank; an inked right cuff." | *the marks listed on the form* | `papers` | 2 |
| `f.hand_same` | "The description is written with the same broken shoulder and the same left-standing burr as the receipt I wrote this morning." | *the broken shoulder in both hands* | `papers` | 3 |
| `f.ink_browned` | "The ink of the description has browned and gone through into the fibre, the colour of the ledger's first page. This morning's ink still stands on the surface." | *the browning of the ink* | `papers` | 3 |
| `f.seal_rubric` | "Printed under the seal ring: to be struck in the presence of the subject." | *the rubric under the seal ring* | `papers` | 1 |
| `f.bureau_1859` | "The Bureau opened its door on the eleventh of March 1859; its first seal was struck on the 28th of April that year; the die carries MDCCCLIX." | *the year the door was opened* | `books` | 3 |
| `f.ledger_flyleaf` | "Flyleaf of the ledger, same hand as line 1: bought against the opening of the door, in his twenty-fourth year." | *the flyleaf of the ledger* | `books` | 2 |
| `f.nest_worn` | "The velvet of the nest is worn through to the backing; the pile stands up everywhere else in the drawer." | *the worn velvet in the nest* | `room` | 1 |
| `f.own_scar` | "A white seam across the middle joint of the third finger of my left hand. It is old." | *the seam on my own finger* | `self` | 3 |

**13 фактів, 8 зон предмета + 7 зон обстановки.** Розкладка на 20 хв:
годинник клієнта ≈ 5 хв (**хибний слід**) · власний годинник ≈ 1 хв · бланк ≈ 6 хв ·
книжки ≈ 2 хв · штамп і гніздо ≈ 1 хв · шість граф ≈ 4 хв · жест ≈ 1 хв.

**Група `self` — нова і єдина в грі.** У нотатнику картка `f.own_scar` стоїть без вирізки арту
предмета: замість вирізки — той самий кадр руки, що на столі. Ця картка **перетягується в
графу «на підставі»** нарівні з рештою. Нічого не коментується.

---

## 5. ЩО ГРА НЕ КАЖЕ (перелік для рев'ю)

Формальний чек-ліст, бо в цій справі спокуса дописати за гравця найбільша:

| гра **не** каже | гравець мусить сказати сам |
|---|---|
| що опис у бланку — про нього | збіг шва, дужки, манжети, віку |
| що почерк у бланку його | «той самий злам плеча» — і все |
| що чорнилу сорок років | «брунатне, пройшло в товщу» — і все |
| що 1859 — «його» рік | він сам вписує чотири цифри |
| що гніздо в шухляді більше не тримає штамп | штамп двічі випадає; звук той самий |
| що річ у релікварії — він | він кладе туди штамп власною рукою |

---

## 6. ДОВІДКОВІ ТАБЛИЦІ

### 6.1. «Характер» (свідчення від установи), Австро-Угорщина, кінець XIX ст.
*Історично правда. Для челяді від 1810-х був обов'язковий **Dienstbotenbuch** (службова
книжка) із записами роботодавців; для конторників і прикажчиків — **Zeugnis**, вільної
форми, але зі сталим набором пунктів. Без нього на місце не брали.*

| пункт свідчення | що пишуть |
|---|---|
| ім'я, вік, місце народження | з метричної виписки або зі службової книжки |
| строк служби | від і до, числами |
| рід занять | «конторник», «прикажчик», «доглядач» |
| **чесність** | окремим рядком; це головне, по що приходять |
| тверезість і охайність | стандартна формула |
| підпис і **печатка установи** | без печатки папір не має ваги |

→ Рехбергер прийшов саме по це. Бюро атрибуції не видає «характерів» — і це перше,
чого гравець **не помічає**: він бере не той бланк, бо іншого в коробці нема.

### 6.2. Сталий бланк бюро (той самий, що в усіх десяти справах)

| частина бланка | сторінка складеного аркуша | стан у фіналі |
|---|---|---|
| шапка й **OBJECT** (опис і колонка прикмет) | 1 (зовнішня) | **заповнена чужою рукою, брунатним чорнилом** |
| шість граф атрибуції | 2 і 3 (внутрішні) | **порожні, аркуш не розгортали** |
| кільце під сургуч + рубрика | 4 (зовнішня) | порожнє |

**Ось чому десять справ здавалося, що бланк «заповнений до графи печатки»:** зовні
складеного аркуша видно рівно дві сторінки — заповнену першу й порожнє кільце четвертої.
Це не трюк сценариста, це фізика бифолія. Гравець ніколи не мав причини його розгортати.

### 6.3. Старіння залізо-галового чорнила (реальні орієнтири)

| вік запису | колір | поведінка в товщі паперу | на просвіт |
|---|---|---|---|
| дні–місяці | синьо-чорний | стоїть на поверхні, ворс не пробитий | не читається |
| 5–10 років | чорно-бурий | починає пробиватись у волокно | ледве |
| **20–50 років** | **брунатний** | **ореол по волокну навколо штриха** | **читається наскрізь** |
| 100+ | рудо-брунатний, місцями випад | часто наскрізна корозія, папір крихкий по штриху | дірки |

⚠️ **Чесно:** колір і ореол дають **десятиліття, а не рік**. Гра цим і користується — жоден
рядок не називає числа «сорок». Число приносить гросбух, а не хімія. (Див. §13.)

### 6.4. Гросбух печаток — початок і кінець

| № | дата | річ | вкладник |
|---|---|---|---|
| **1** | 28 квітня 1859 | one brass inkstand | Reindl, T. |
| 2 | 9 травня 1859 | a pair of steel snuffers | Wieser, A. |
| … | … | … | … |
| **1 429** | 12 лютого 1899 | *(рукою попередника на полі: підсумок)* | — |
| 1 430 … | березень–травень 1899 | **печатки гравця**, скільки їх було | вписані власноруч |

Сьогоднішній рядок = `1429 + st.seals_placed + 1`. Число обчислюється, не зашивається:
гравець міг повернути частину речей без печатки, і тоді сьогоднішній номер менший.
**Гра його не коментує в жодній гілці.**

### 6.5. Римські цифри на матрицях (для читання кільця)

| запис | рік |
|---|---|
| MDCCCXLVIII | 1848 |
| **MDCCCLIX** | **1859** |
| MDCCCLXXII | 1872 |
| MDCCCXCIX | 1899 |

### 6.6. Номер корпусу й номер механізму (стисло; повна таблиця — справа 3)
Практика доби: корпус і механізм нумерувалися **окремо** і збігалися лише тоді, коли
годинник ішов до покупця цілим від одного постачальника. **Збіг номерів — доказ цілості
речі**, розбіжність — доказ складання з двох. У Рехбергера вони **збігаються**.

### 6.7. Календар, травень 1899 (звірено)

| | Пн | Вт | Ср | Чт | Пт | Сб | Нд |
|---|---|---|---|---|---|---|---|
| травень | 1 | 2 | 3 | 4 | 5 | **6** | 7 |
| травень | **8** | 9 | 10 | 11 | 12 | 13 | 14 |

1 травня 1899 — понеділок; **6 травня — субота** (сьогодні); нове місце — **понеділок 8-го**.
11 березня 1859 — п'ятниця; 28 квітня 1859 — четвер (звірено зі справою 4).

---

## 7. АТЕСТАТ (6 граф, одна числова)

Той самий бланк, що в усіх справах, ті самі друковані префікси. **Змінилось тільки те,
про що йдеться.** Жодна графа не має варіанта, який би називав людину людиною: бюро
не має такого слова, і в цьому вся жорстокість форми.

| # | slot_id | префікс (EN) | kind | гейт | варіанти |
|---|---|---|---|---|---|
| 1 | `s.origin` | **Made at ____** | CHOICE | `needs: [f.cert_is_a_person]` · `needs_any: [f.bureau_1859, f.ledger_flyleaf]` | `o.this_bureau` «this bureau, and no other place» · `o.country_district` «a country district; workshop not named» · `o.not_identified` «not identified» |
| 2 | `s.not_before` | **Not before ____** | **NUMBER** | `needs: [f.cert_is_a_person]` · `digits: 4, min: 1700, max: 1899` | **списку нема, валідації нема, підказки нема.** Істина = **1859** |
| 3 | `s.condition` | **The piece itself is ____** | CHOICE | `needs_any: [f.cert_marks, f.own_scar, f.client_watch_agrees]` | `o.as_made` «as it left the maker» · `o.repaired` «repaired, and not always by the same hand» · `o.made_up` «made up from the parts of more than one piece» · `o.altered_over` «altered after the fact, and the alteration polished over» |
| 4 | `s.provenance` | **How it came here ____** | CHOICE | `needs_slot: [s.origin]` | `o.walked_in` «came in at the door and stayed» · `o.inherited` «came with the room, by inheritance» · `o.deposited` «was deposited, and never called for» · `o.made_here` «was made here, out of what was here» |
| 5 | `s.disposition` | **Disposition ____** | CHOICE | `needs_slot: [s.provenance]` | `o.seal_and_file` «to be sealed, and filed with the rest» · `o.returned_unsealed` «to be returned without a certificate» · `o.remain_unsealed` «to remain in the bureau, unsealed» |
| 6 | `s.basis` | **On the basis of ____** | FACTS | `needs_slot: [s.disposition]` · `min_count: 2, max_count: 4` · `clears_on: [s.condition]` | джерело — `state.fact_order` (група `strat` тут не використовується) |

**Пастка графи 2 — головна пастка гри, і вона арифметична.**
Гейт відкривається вже з `f.cert_is_a_person`, тобто **до** будь-якої книжки. Опис дає вік:
**63**. Сьогодні **1899**. Найприродніше в світі число — **1836**, рік народження предмета.
Воно правдиве й неправильне: друкований підрядник графи, який гравець читав десять разів,
питає інше — *the earliest year at which the piece could have taken its present form*.
Річ, описану в цьому бланку, зробило не народження, а **відчинені двері**.
Інші живі хибні числа: **1871** (рік годинника Рехбергера), **1899**, **1872** (рефлекс
із першої справи). Гра не заперечує жодному.

**Кнопка «повернути без атестата» жива й натискна в самій сцені** — не в меню, не в
підтвердженні. Вона лежить на столі як третій варіант графи 5 **і** як фізичний жест:
скласти аркуш назад і посунути під бювар. Обидві дороги ведуть у `out.returned_unsealed`.

---

## 8. НАСЛІДКИ

**Порядок збігу — зверху вниз, перший збіг виграє.**
Дві верхні гілки — **термінальні**: після них ранку нема, є фаза 5 (жест). Дві нижні —
звичайні ранки, і гра після них тихо закінчується титрами того ж дня.

| # | id | умова | текст (EN) |
|---|---|---|---|
| 1 | `out.sealed_true` | `s.not_before = 1859` · `s.origin = o.this_bureau` · `s.disposition = o.seal_and_file` · `basis_any: [f.hand_same, f.ink_browned, f.own_scar]` · `basis_weight ≥ 6` | *(термінальна — переходить у фазу 5)* "The wax goes down. Rehberger says his line about the watch, and takes it, and does not go; he sits with his hat on his knees like a man waiting for a train he knows is late. The room does what it has done ten evenings running. The drawer comes out. The nest is there. The lamp holds still." |
| 2 | `out.sealed_wrong_year` | `s.disposition = o.seal_and_file` · `s.not_before ≠ 1859` | *(термінальна — переходить у фазу 5)* "The wax goes down. In the morning the ledger lies open at today's line, and the year in the second column has been gone over: the figure struck through once, and the right one written above it, small, in the space between the rules. It is in my hand. I do not remember making the correction, and there has been no one else in the building." |
| 3 | `out.character_for_the_clerk` | `s.origin = o.country_district` **або** (`s.provenance = o.walked_in` · `basis` не містить жодного з `[f.hand_same, f.ink_browned, f.own_scar]`) | "He is gone by nine with the sheet folded in his breast, and he touches his hat at the door with the hand that has no seam in it. On Friday a letter comes from the house that took him, thanking the Bureau for its character of the young man, who is quick with a pen and is to have the keeping of their books. The letter is franked from a street four doors from this one. On Saturday there is a line in the ledger that I did not write, and the figures lean forward." |
| 4 | `out.returned_unsealed` | `s.disposition = o.returned_unsealed` **або** натиснуто кнопку в сцені | "Nothing is sealed. The sheet goes back into the fold it has held for forty years, and back under the blotter, and the corner of it shows, as it has shown every day. Rehberger takes his watch and a shilling's worth of opinion and no paper, and takes it better than most men would. At the usual hour the drawer is opened for the die, and the die is not in the room. It is not in the room in the morning either. The velvet is worn through to the backing, and the pile stands up all round it, and the shape in the middle is the shape of a thing that lay there a long while and was taken away." |
| 5 | `out.default` | — (обов'язкова остання) | "The morning post brings one thing: a bill from the stationer for a ream of the standing form, ordered in March, delivered in April, unpaid. At the foot, in a clerk's hand: *this being the last of them, we have discontinued the line; there is no further call.*" |

### 8b. ФАЗА 5 — ЖЕСТ (керує гравець; це не катсцена)

Грає після гілок 1 і 2. Жодного тексту, жодного натяку, жодної підказки.

1. Шухляда виїжджає сама, як щовечора. Курсор тримає штамп. `z.drawer.nest` активна.
2. **Штамп у шухляді більше не лежить.** Оксамит протертий до основи (`f.nest_worn`),
   матриця гойдається й **вивалюється на дерево**. Той самий звук, що десять вечорів,
   але **на такт довший**. Дозволено рівно **дві спроби**; на другій штамп випадає так само.
3. Після другої спроби (або одразу, якщо гравець туди не тиснув) **релікварій у кутку
   стоїть відчинений**. Ніхто його не відчиняв у кадрі. `z.reliquary.nest` активна:
   гніздо тієї самої форми, оксамит **новий, ворс не збитий**.
4. Клік → **та сама анімація, той самий звук, у неправильному місці.**
5. Кришка сходить. **Обов'язковий один кадр** (V6 §1): на релікварії печатка — **його
   власна, стара, сургуч потрісканий по всьому обводу, відбиток стертий в одному місці на
   ширину великого пальця** (`r.die_wear`, який гравець, можливо, зробив десять хвилин тому).
   Вона була там завжди.
6. Останній кадр: Рехбергер бере перо зі стакана, повертає гросбух до себе й питає,
   як тут нумерують рядки. Екран гасне на його руці, не на обличчі.

**Якщо гравець за 90 секунд не поклав штамп нікуди** — нічого не стається. Лампа не гасне,
музики нема, підказки нема. Кімната чекає стільки, скільки треба. Це остання перевірка
того самого правила: гра ніколи не квапить руку.

---

## 9. ХИБНИЙ СЛІД

**Що спокушає.** Годинник Рехбергера має **сідловину на дужці** — точнісінько ту, якою
справа 3 доводила, що річ зібрана з двох. Десять справ гравця вчили: сідловина → шукай шов.
Він відкриє кришку, підважить кювету, звірить номер корпусу з номером механізму, прочитає
продряпані дати ремонтів, полізе в реєстр майстерень. Це п'ять–сім хвилин із двадцяти,
чесної, добре знайомої, приємної роботи.

**Куди веде.** У нікуди, і дуже переконливо. Номери **збігаються** (22 610 і 22 610),
дати ремонтів ідуть **у зростанні** й трьома різними руками (три майстри за двадцять років —
норма), проба 800 стоїть там, де їй належить, реєстр підтверджує продаж новим у 1871-му.
Річ бездоганна. Сідловина означає рівно одне: чоловік тридцять років носив годинник у
лівій кишені жилета й витягав його лівою рукою.

**Чим спростовується — і це найтихіше спростування в грі:** гравець наводить лупу на
**власну дужку** (`f.own_bow_saddle`) і бачить ті самі дві борозни в тих самих місцях.
Прикмета, яка в справі 3 щось доводила, тут не доводить нічого — бо вона є в обох.
Інструмент справний, зона справна, факт справжній, ціна факту — **нуль**.
Це третій і останній раз, коли прилад мовчить, і єдиний, коли він мовчить не про річ,
а про людину.

**Другий, коротший хибний слід (на папері).** Побачивши свій зламаний «g» у чужому написі,
гравець природно вирішить, що бланк заповнили **нещодавно, підробивши його руку** —
версія жива, зловісна й доросла. Її вбиває `f.ink_browned`: чорнило пройшло крізь волокно
й побуріло до кольору першої сторінки гросбуха, тоді як його ранкова квитанція лежить
на поверхні. Підробити можна почерк. Сорок років у товщі паперу — ні.

**Чого хибний слід НЕ робить:** він не карає. Час, витрачений на годинник, потрібен —
без нього другий беат не має ваги, а `f.client_watch_agrees` лишається законною карткою
для графи «на підставі». Гравець нічого не втрачає, крім упевненості.

---

## 10. ДВІ ГІПОТЕЗИ І РОЗВОДЖУВАЛЬНИЙ ФАКТ

**(А) Бланк — на попередника.** Старий, що сидів за цим столом сорок років, склав атестат
на самого себе й не встиг його запечатати; останній обов'язок спадкоємця — закрити теку
покійного. Гіпотеза пояснює **все**: вік шістдесят три, сивину, що була чорною, брунатне
чорнило, стару руку, сорокарічну печатку на релікварії, навіть рубрику «у присутності
предмета» (він же сидів тут сам). Вона гідна, охайна й **майже правильна** — саме тому
вона найнебезпечніша.
**(Б) Бланк — на клієнта.** Він прийшов по «характер», у бюро лишився один бланк, він
чоловік із годинником, у якого сідловина на дужці, і графа «Disposition» просто чекає
слова. Гіпотеза приваблива тим, що робить гравця добрим.
**Розводить не один факт, а зіткнення двох, і жоден із них гра не коментує.**
Б умирає від `f.ink_browned`: опис написаний за сорок років до того, як Рехбергер
народився, — а прикмети в ньому теперішні, не пророчі («hair grey, **was black**»).
А умирає від `f.hand_same` + `f.own_scar`: рука, що заповнила бланк, — та сама, що виписала
сьогоднішню квитанцію, зі зламаним плечем «g» і задиркою ліворуч; а білий шов через
середній суглоб третього пальця лівої руки, який стоїть у колонці прикмет, є на **його
власній** руці й **нема** на руках клієнта, що лежать на столі всю сцену.
Обидві гіпотези помирають від фактів, здобутих різними інструментами (свічка й лупа) на
різних об'єктах (папір і власна рука) — як і належить у цій грі.
**Третьої гіпотези гра не пропонує. Її пропонує гравець.**

---

## 11. СТРИБОК ДУМКИ

Гравець виводить сам: **предмет, описаний у бланку, — це людина, яка тримає перо, а
найраніший рік, коли ця річ могла набути теперішнього вигляду, — не рік її народження,
а рік, коли відчинилися двері бюро.**

---

## 12. ВХІД

Чотири речі сходяться в одному ранку, і жодна з них — не кнопка й не репліка гри.

1. **Прохання, на яке в бюро нема бланка.** Рехбергер просить «характер». Гравець іде до
   пласкої шухляди, де сорок років лежать друковані бланки, і **бере останній**. Коробка
   порожня — це видно в кадрі, і це не коментується. Інший бланк узяти нема звідки.
2. **Останній бланк — той самий.** Він лежить не в коробці, а **під бюваром**, де лежав
   з першого ранку гри: заповнений чужою рукою, з порожнім кільцем під сургуч. Гравець
   бачив його десять разів і десять разів клав зверху інший.
3. **Складений аркуш.** Щоб покласти бланк перед собою, його треба взяти — і рука
   відчуває **згин**. Аркуш **складений**, і сторінки всередині не розгорталися ніколи.
   Це і є вхід: одна дія рукою, яку не можна не зробити, бо писати треба на внутрішніх
   сторінках. (`r.unfold`)
4. **Сьома річ.** Між справою 10 і фіналом гравець вписав у інвентарну книгу «№6» і побачив
   у наступному порожньому рядку чуже **7** (V6 §3). У кімнаті сьомої речі нема. У кімнаті
   є релікварій, стіл, штамп — і чоловік у кріслі.

Перше речення дня, і єдине, яке гра дозволяє собі сказати вголос — його каже клієнт:
> *"They want it in writing, sir. They won't take a man's word for what he is."*

---

## 13. ЧЕСНІСТЬ МЕТОДУ ТА IP-ЧЕК

**Перевірено і правда:**
- **«Характер» / службова книжка.** Австрійський *Dienstbotenbuch* для челяді (обов'язковий
  з початку XIX ст. за Gesindeordnung) і вільне *Zeugnis* для конторників — реальні
  документи; без письмового свідчення про чесність на місце не брали. Пункти в §6.1 —
  сталий набір таких паперів.
- **Залізо-галове чорнило** з роками окислюється, буріє і мігрує у волокно (ореол,
  у важких випадках — наскрізна корозія паперу). Старий запис читається на просвіт,
  свіжий — ні. Це метод доби: свічка на просвіт уже введена справою 5.
- **Порівняння почерків у 1899 році існувало як фахова практика** (Фрейзер, «Bibliotics»,
  1894; експертизи в справі Дрейфуса, 1894–99). Формально це **думка експерта, а не доказ**,
  і гра тримається межі: нотатник фіксує лише **зламане плече «g» і задирку ліворуч** —
  дефект **пера**, не «та сама людина». Висновок робить гравець.
- **Номер корпусу ≠ номер механізму** — засвідчена практика доби (детально в справі 3).
  Збіг номерів як доказ цілості речі — коректний хід.
- **Продряпані дати ремонту всередині кришки** — засвідчена практика годинникарів.
- **Знос дужки сідловиною** від тридцятирічного носіння в кишені жилета — фізично
  правильно (тертя ланцюжка й нігтя об одну щоку кільця); саме тому в справі 3 він доводив
  ліворукість, а не датування.
- **Сургуч** (шелак + каніфоль + кіновар) за десятиліття темнішає і береться тріщинами по
  обводу — так і виглядає печатка на релікварії.
- **Римські цифри в кільці матриці** й дзеркальне різьблення робочого лиця — норма для
  будь-якого штемпеля.
- **Календар:** 6 травня 1899 — субота; 8 травня — понеділок; 11 березня 1859 — п'ятниця;
  28 квітня 1859 — четвер (сходиться зі справою 4).

**Прямо кажу, де метод був би сумнівним, і що зроблено натомість:**
- **Колір чорнила не дає року.** Побуріння й ореол дають **десятиліття**, не «сорок років».
  Тому число **1859 не виводиться з паперу взагалі**: його дають гросбух, щоденник і
  кільце матриці. Хімія тут лише вбиває гіпотезу Б («написано щойно»), і більше нічого.
- **«Та сама рука» через дефект пера — не тотожність.** Одне перо може обслуговувати
  контору, і гра цього не приховує: `f.hand_same` сформульований як спостереження про
  **нахил, злам і задирку**, а не про особу. Він працює тільки в парі з `f.own_scar`.
- **Дата заснування в кільці штемпеля** — правдоподібна, але не універсальна практика
  (приватні «привілейовані» контори справді били рік заснування; казенні — ні).
  Тому це **одна з трьох доріг** до `f.bureau_1859`, а не єдина.
- **Мова на матриці.** У світі гри кільце німецьке; гра рендерить англійську базу
  (правило 10). Локалізація UA дає той самий відбиток українською — **арт матриці
  малюється без тексту, кільце набирається шрифтом** (правило 1).

**IP-чек.** Усі імена вигадані й перевірені на відсутність відомого носія в ремеслі:
*Anton Rehberger* (конторник), *A·K* (клеймо корпусу), *Reindl* (успадковано зі справи 4).
Обличчя Рехбергера — новий портрет, без прототипу; вимога до арту: **звичайне обличчя,
яке не запам'ятовується**, і **руки без жодного шраму**, добре видимі при столі.
Формула фіналу (жест у неправильному місці) — наша; звірено з *Strange Antiquities*,
*Return of the Obra Dinn*, *Case of the Golden Idol*: збігів механіки чи образу нема.

---

## 14. ЗАЛЕЖНОСТІ Й БОРГИ ПЕРЕД ІНШИМИ СПРАВАМИ

| що | звідки/куди | навіщо |
|---|---|---|
| **гніздо в шухляді, штамп щовечора** | справи 1–10, **кожен** вечір | без десяти повторів фаза 5 — режисура, а не м'язова пам'ять |
| **бланк під бюваром, заповнений до кільця** | з 0:01, у кадрі кожного дня | §12.2; коштує один шар у композиції столу |
| **аркуш складений (бифолій)** | арт бланка в усіх справах | §6.2; інакше «розгортання» у фіналі — читерство |
| **власна ліва рука в кадрі стола** | справи 1–10, шар `desk_main` | `z.own.hand` не має бути новим об'єктом у фіналі |
| **власний годинник гравця на бюварі** | справи 1–10, той самий шар | те саме: у фіналі він не з'являється, він уже там |
| **сідловина на дужці** | справа 3 → сюди | хибний слід працює лише на завченому прийомі |
| **рік 1859** | справа 4 (рядок 1 гросбуха) → сюди | гравець тримав це число в руках за шість справ до фіналу |
| **1 429 печаток** | після справи 4 → §6.4 | сьогоднішній номер рядка обчислюється, не зашивається |
| **щоденник, стор. 1** | пошта акту I → `z.book.diary_p1` | третя дорога до `f.bureau_1859` |
| **релікварій у кімнаті** | справа 10 → фаза 5 | стоїть зачинений усі дні між 10 і 11 |
| **число 7 в інвентарній книзі** | між 10 і 11 (V6 §3) → §12.4 | вхід |
| **свічка на просвіт** | справа 5 → `r.subject_ink` | інструмент вживається востаннє, і вперше — на власному папері |
| **«прилад мовчить»** | справи 4 і 10 → §9 | третій і останній раз, і єдиний про людину |
| **кнопка «повернути без атестата»** | вся гра → §7 | у фіналі вона мусить бути **фізично на столі**, а не в меню |
