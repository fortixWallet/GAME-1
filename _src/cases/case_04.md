# СПРАВА 4 — «ТЕКА №1, ЛАТУННА КАЛАМАРКА»

**Хронометраж:** 15 хв · **Акт I, злам жанру** · **ХВИЛЯ 1**
**Роль:** перша справа, де річ ні до чого. Гравець три справи вчився дивитись на предмет —
тут предмет чесний до останнього шва, а бреше **один знак на папері**. Це передчасна щеплення
проти справи 5 («архів бреше») і єдиний спосіб поставити хвилю рукою гравця, а не текстом.
**Нових інструментів НЕ вводиться.** Ті самі лупа, косе світло, рука. Змінилась мішень.

**Дати справи (жорстко, звірено з календарем 1859):**

| подія | дата | день тижня |
|---|---|---|
| майстерня Гаусвірта внесена в реєстр | 1832 | — |
| ремонт вушка, наряд №214 | 1851 | — |
| майстерню викреслено з реєстру | 1861 | — |
| **прийом речі (квитанція)** | **21 квітня 1859** | четвер |
| **дата на атестаті в теці (виправлена)** | **23 квітня 1859** | субота |
| **печатка (гросбух, рядок №1)** | **28 квітня 1859** | четвер |
| **смерть вкладника (міський список)** | **4 травня 1859** | середа |
| теперішній час бюро | весна **1899** | — |

Квітень має 30 днів. 28.04 → 04.05 = **6**. 23.04 → 04.05 = 11. 21.04 → 04.05 = 13.
Три правдоподібні числа, одне правильне. Число не вгадується.

> **Наскрізний борг:** 1859 — рік, коли попередник відчинив бюро. У фіналі гравець впише
> саме цей рік у графу «не раніше ніж». Справа 4 віддає його тихо й без наголосу.
> 1 429 печаток за 1859–1899 = одна на ~10 днів (звірка з V6 §3 сходиться).

---

## 1. КЛІЄНТ

Клієнта в цієї справи **нема** — і це і є злам жанру. Річ приніс чоловік, який помер сорок
років тому. Людина в кімнаті одна, і вона не має до речі жодного стосунку.

**Хлопець із газетної палітурні** (років тринадцять). Привіз свіжо оправлений том за минулий
квартал і забирає старий на перепліт. Імені не називає; у книзі доставки друком стоїть назва
контори.

- **Названа потреба, не пов'язана з річчю:** «The bindery docks me a kreuzer for every
  quarter-hour I'm late back. I owe my mother for boots.»
- **Фізична деталь, яку кадр показує і жоден текст не коментує:** креповий жалобний рукав,
  на два розміри більший, підколотий ззаду англійською булавкою двічі. Ніхто про нього
  не заговорить — ні хлопець, ні гравець, ні гра.
- **Дві репліки на печатку** (він ще в кімнаті, чекає том):
  - **швидко** (печатка < 4 хв від відкриття теки): «That was quick. My master takes a week
    to say a thing is not worth doing.»
  - **довго** (> 10 хв): «You've been at that a long while, sir. Is it worth something?»
    …пауза… «My grandfather had one like it.»

**Функція хлопця в механіці:** забираючи старий том, він змушує гравця зняти з полиці підшивку
1859 року. Том розкривається на **стрічці-закладці**, покладеній попередником. Після його виходу
том лишається розкритим на пюпітрі — окремої зони «дістати підшивку» не потрібно.

---

## 2. ЗОНИ

Одиниця 3D-моделі: **1.0 = 45 мм**. Габарит каламарки 4.0 × 2.2 × 1.4 од. (180 × 99 × 63 мм).
Якір — `inkwell_pivot` у геометричному центрі. 2D-зони — у частках **ЗОБРАЖЕННЯ**,
радіус у частках ширини зображення (див. ENGINE_SPEC §1.2).

| zone_id | де саме | kind | екран / surface | координати | r / half | стани |
|---|---|---|---|---|---|---|
| `z.ink.base` | спід підставки, лівий (перовий) кінець; сукно відстало кутом | `node3d` | HANDS / `inkwell_pivot` | p (−0.55, −0.55, 0.00) · n (0,−1,0) | r 0.42 · facing_min 0.12 | `default` → `felt_lifted` |
| `z.ink.lug` | вушко завіси ззаду кришки | `node3d` | HANDS / `inkwell_pivot` | p (0.90, 0.34, −0.46) · n (0.00, 0.26, −0.97).normalized() | r 0.18 · facing_min 0.10 | — |
| `z.ink.lid` | кришка чорнильниці; у стані `open` — нутро колодязя | `node3d` | HANDS / `inkwell_pivot` | p (0.90, 0.62, 0.00) · n (0,1,0) | r 0.34 · facing_min 0.15 | `default` → `open` |
| `z.papers.receipt` | рядок дати на квитанції (ліва половина теки) | `img` | DOCS / `folder_01_spread` | u (0.268, 0.372) | r 0.058 | — |
| `z.papers.cert` | низ атестата: дата + печатка + «No. 1» | `img` | DOCS / `folder_01_spread` | u (0.714, 0.598) · `shape: rect` | half (0.150, 0.052) | — |
| `z.book.ledger_row` | перший розлінований рядок гросбуха | `img` | BOOKS / `ledger_spread_1859` | u (0.310, 0.284) · `shape: rect` | half (0.230, 0.026) | — |
| `z.book.gazette_col` | права колонка підшивки: міський список померлих | `img` | BOOKS / `gazette_1859_w18` | u (0.806, 0.560) · `shape: rect` | half (0.078, 0.240) | — |

**Довідкові зони** (рядки в книзі, окремого арту предмета не мають, у бюджет «6–8 зон» не входять):

| zone_id | де | kind | surface | u | r |
|---|---|---|---|---|---|
| `z.book.trade_founders` | «Gewerbe-Register», розділ ливарників | `img` | BOOKS / `trade_register_spread` | (0.290, 0.430) | 0.115 |
| `z.book.trade_repairs` | той самий розворот, розділ ремонтних майстерень | `img` | BOOKS / `trade_register_spread` | (0.735, 0.520) | 0.115 |

**Заборона:** свічка на просвіт у цій справі **не працює** (`tool.candle` ще не в поясі —
його прем'єра у справі 5, V6). Усе, що робиться з папером тут, робиться лупою і косим світлом.

---

## 3. ПРАВИЛА

| rule_id | zone_id | tool | requires | fact_id | note (англ., у нотатник — БЕЗ висновку) | sets_state |
|---|---|---|---|---|---|---|
| `r.receipt_ring` | `z.papers.receipt` | `tool.eye` (on_click) | — | `f.receipt_ringed` | The date on the receipt is ringed in pencil. Beside the ring, a question mark, in the same pencil. Everything else on the sheet is ink. | — |
| `r.cert_read` | `z.papers.cert` | `tool.eye` (on_click) | — | `f.cert_no1` | The certificate is filled out, sealed and dated the 23rd of April 1859. Beside the seal, in the same hand: No. 1. | — |
| `r.felt` | `z.ink.base` | `tool.hand` (on_click) | — | — | *(звук відклеєного сукна; факт не дає)* | `z.ink.base` → `felt_lifted` |
| `r.maker` | `z.ink.base` (state `felt_lifted`) | `tool.loupe` (dwell 0.6) | — | `f.founder_mark` | Struck into the bare brass: a lozenge, the letters L·H, and a bee. | — |
| `r.job_scratch` | `z.ink.base` (state `felt_lifted`) | `tool.rake` (dwell 0.8) | `f.founder_mark` | `f.scratched_job` | Scratched, not struck, in the corner: an anvil and 214. Fine strokes, shallow, one pass each. | — |
| `r.lid_open` | `z.ink.lid` | `tool.hand` (on_click) | — | — | *(завіса; факт не дає)* | `z.ink.lid` → `open` |
| `r.ink_ring` | `z.ink.lid` (state `open`) | `tool.loupe` (dwell 0.5) | — | `f.ink_ring` | Inside the well a black ring stands high up the glass, and where glass meets brass there is a green bloom. | — |
| `r.seam` | `z.ink.lug` | `tool.loupe` (dwell 0.7) | — | `f.lug_seam` | The back lug is joined by a seam a shade paler than the metal beside it. There is no grey in the seam. | — |
| `r.lacquer` | `z.ink.lug` | `tool.rake` (dwell 1.0) | `f.lug_seam` | `f.lacquer_unbroken` | Under raking light the yellow film crazes in one continuous net. The net does not stop, thicken or change direction at the seam. | — |
| `r.reg_founder` | `z.book.trade_founders` | `*` (on_click) | `f.founder_mark` | `f.founder_register` | Trade register: L. Hauswirth, brassfounder, Wien VII. Entered 1832, struck off 1861. Mark: lozenge, L·H, bee. | — |
| `r.reg_repair` | `z.book.trade_repairs` | `*` (on_click) | `f.scratched_job` | `f.repair_register` | Trade register, repairing shops: the anvil is the job mark of Sedlák & Son, coppersmiths and girdlers. Job numbers 199–261 stand under the year 1851. | — |
| `r.cert_scrape` | `z.papers.cert` | `tool.loupe` (dwell 1.2) | `f.cert_no1` | `f.cert_scraped` | The last figure of the day sits on a patch where the nap of the paper is gone. The ink of that figure spreads sideways into the roughened fibres; no other figure on the sheet does. | — |
| `r.cert_furrow` | `z.papers.cert` | `tool.rake` (dwell 1.4) | `f.cert_scraped` | `f.cert_furrow` | Under raking light a furrow runs beneath the last figure — a stroke pressed by a pen and no longer inked. It closes at the top and runs back on itself. | — |
| `r.ledger` | `z.book.ledger_row` | `*` (on_click) | `f.cert_no1` | `f.ledger_line` | Ledger, first line: No. 1 · 28 April 1859 · one brass inkstand · Reindl, T. The line numbers are printed by the stationer, the dates written in. | — |
| `r.ledger_tick` | `z.book.ledger_row` | `tool.loupe` (dwell 0.6) | `f.ledger_line` | `f.ledger_no_tick` | In the last column every line of the book carries a tick. Line 1 does not. | — |
| `r.gazette` | `z.book.gazette_col` | `tool.eye` (on_click) | — | `f.death_notice` | Municipal list of deaths, week ending Saturday the 7th of May 1859: REINDL, Tobias — 51 years — of Schleifmühlgasse — the 4th of May — apoplexy. | — |

Примітки для програміста:
- `r.gazette` не має `requires`, бо підшивка вже відкрита на стрічці попередника (див. §12).
  Гейт тут діегетичний, не механічний.
- Жодне правило не є `DESTRUCTIVE`, підтверджень нема. У справі 4 нічого не ламається —
  теж навмисно: рука не має чим зайнятись, коли річ чесна.
- `r.felt` і `r.lid_open` — єдині дві дії рукою; обидві дають звук і стан, не факт.

---

## 4. ФАКТИ

| fact_id | text (англ., спостереження) | cite («на підставі») | tag / group | weight |
|---|---|---|---|---|
| `f.receipt_ringed` | The date on the receipt is ringed in pencil, with a question mark beside it. | *a pencil ring on the receipt date* | `papers` | 1 |
| `f.cert_no1` | The certificate is complete, sealed, dated 23 April 1859, and numbered No. 1. | *the certificate in the folder, No. 1* | `papers` | 1 |
| `f.founder_mark` | A lozenge, L·H and a bee, struck into the bare brass of the underside. | *the founder's mark under the felt* | `object` | 1 |
| `f.founder_register` | Register: L. Hauswirth, Wien VII, brassfounder, 1832–1861. | *the trade register, founders* | `object` | 2 |
| `f.scratched_job` | An anvil and 214, scratched shallow in the corner of the underside. | *a scratched job number, 214* | `object` | 1 |
| `f.lug_seam` | A seam a shade paler than the metal, no grey in it, across the back lug. | *the pale seam on the lug* | `object` | 1 |
| `f.lacquer_unbroken` | The crazed lacquer runs in one net across the seam without change. | *the lacquer crazing across the seam* | `object` | 2 |
| `f.repair_register` | Register: the anvil is Sedlák & Son; jobs 199–261 stand under 1851. | *the trade register, repairers* | `object` | 2 |
| `f.ink_ring` | A black ring high on the glass liner and a green bloom at the brass. | *the ink line inside the well* | `object` | 1 |
| `f.cert_scraped` | The last figure of the day sits on paper whose nap is gone; the ink spreads into it. | *the scraped patch under the date* | `papers` | 2 |
| `f.cert_furrow` | A pressed, uninked furrow runs beneath the last figure of the date. | *the pen furrow under the date* | `papers` | 3 |
| `f.ledger_line` | Ledger, printed line 1: 28 April 1859, one brass inkstand, Reindl, T. | *the first line of the ledger* | `papers` | 3 |
| `f.ledger_no_tick` | Every line of the ledger is ticked in the last column. Line 1 is not. | *the unticked line* | `papers` | 2 |
| `f.death_notice` | Municipal list, week ending 7 May 1859: Reindl, Tobias, 51, the 4th of May. | *the municipal list of deaths* | `papers` | 3 |

**14 фактів, 7 зон + 2 довідкові.** Чотири факти — вільне читання оком (0 інструментів),
три — довідник. Робочих спостережень під інструмент лише сім. Розкладка на 15 хв:
річ ≈ 5 хв · папери теки ≈ 4 хв · довідники ≈ 2 хв · підшивка + арифметика ≈ 2 хв · атестат ≈ 2 хв.

**Один факт = один id.** До `f.ledger_line` є дві дороги (з атестата за номером печатки; з полиці,
якщо гравець сам відкрив гросбух) — id один.

---

## 5. ДОВІДКОВІ ТАБЛИЦІ

### 5.1. Gewerbe-Register, розділ «Gelbgießer» (ливарники латуні)
*Структура реальна (віденський промисловий реєстр вів дату внесення і викреслення та відбиток
клейма). Прізвища вигадані — див. §11.*

| клеймо | майстерня | округ | внесено | викреслено |
|---|---|---|---|---|
| ромб, **L·H**, бджола | **L. Hauswirth** | Wien VII | **1832** | **1861** |
| овал, **F·B** | F. Bittner, Sohn | Wien III | 1844 | 1878 |
| щит, три цвяхи | Nadler & Kraus | Wien II | 1851 | 1889 |
| без клейма, тавро контори | Nürnberger Handelsware (гуртовий імпорт) | — | — | — |

### 5.2. Gewerbe-Register, розділ ремонтних майстерень: наряди Sedlák & Son
*Практика: ремісник позначає виріб **номером наряду**, і номери йдуть підряд по книзі нарядів.
Історично засвідчено для годинникарів (номер і дата, продряпані всередині кришки) і поширювалось
на мідників та лимарів. **Струшене (набите) тавро ремонту на латуні — не задокументовано**;
тому тут номер саме **продряпаний**, а не набитий (див. §11, чесність методу).*

| рік | номери нарядів |
|---|---|
| 1848 | 1–74 |
| 1849 | 75–146 |
| 1850 | 147–198 |
| **1851** | **199–261** |
| 1852 | 262–330 |
| 1853 | 331–402 |

→ **214 = 1851.** На вісім років раніше за прийом речі.

### 5.3. Припої та лак (реальні числа; сторінка «Technik» у довіднику)

| з'єднання | склад | температура | як виглядає шов |
|---|---|---|---|
| м'який припій | олово/свинець 50/50 | плавиться **183–216 °C** | тьмяно-сірий, білястий, ширший |
| твердий (латунний, «шпіаутер») | мідь/цинк | **~870 °C**, річ доводять до червоного жару | жовтий, на тон блідіший за метал |
| срібний припій | Ag/Cu/Zn | ~700–800 °C | блідо-жовтий, вузький |
| лак ливарника | шеляк у спирті, підфарбований куркумою / драконовою кров'ю; кладеться на теплий метал | розм'якає ~**80 °C**, обвуглюється задовго до жару пайки | з роками жовтіє й береться сіткою кракелюр |

**Наслідок, який гравець мусить вивести САМ:** будь-яка пайка — навіть м'яка — псує лакову
плівку на місці шва. Суцільна, однаково стара сітка кракелюр **поверх** шва означає, що лак
клали після ремонту й відтоді не чіпали.

### 5.4. Гросбух печаток, перша сторінка (розлініяний бланк, номери рядків друковані)

| № | дата | річ | вкладник | видано (галочка) |
|---|---|---|---|---|
| **1** | **28 квітня 1859** | one brass inkstand | Reindl, T. | **—** |
| 2 | 9 травня 1859 | a pair of steel snuffers | Wieser, A. | ✓ |
| 3 | 21 травня 1859 | a mourning ring | Pohl, K. | ✓ |
| 4 | 2 червня 1859 | a fowling piece, damascus | Bräuer, J. | ✓ |
| … | … | … | … | ✓ |
| остання сторінка, на полі рукою попередника | | | **1 429** | |

Друковані номери рядків — не оздоба, а доказ: одиничну дату можна виправити, порядок номерів —
ні (це різниця між гросбухом і атестатом, і вона вирішує числову графу).

### 5.5. Календар, квітень–травень 1859 (звірено)

| | Пн | Вт | Ср | Чт | Пт | Сб | Нд |
|---|---|---|---|---|---|---|---|
| квітень | 18 | 19 | 20 | **21** | 22 | **23** | 24 |
| квітень | 25 | 26 | 27 | **28** | 29 | 30 | 1 трав. |
| травень | 2 | 3 | **4** | 5 | 6 | **7** | 8 |

Квітень має 30 днів. Сторінка календаря лежить у книзі — це не мета-довідка, а реквізит бюро.

### 5.6. Підшивка, тиждень 1–7 травня 1859 (історична фактура, необов'язкова до читання)
Перші шпальти зайняті війною: ультиматум Австрії Сардинії минув **23 квітня**, австрійські
війська перейшли Тічино **29 квітня 1859**. Це правда, і вона працює на нас: у тому тижні
звичайна смерть п'ятдесятиоднорічного чоловіка не отримала ні некролога, ні рядка —
тільки казенний рядок у міському списку в куті останньої шпальти.

---

## 6. АТЕСТАТ (6 граф, одна числова)

| # | slot_id | префікс (англ.) | kind | гейт | варіанти |
|---|---|---|---|---|---|
| 1 | `s.origin` | **Made at ____** | CHOICE | `needs: [f.founder_register]` | `o.wien_hauswirth` «Vienna — L. Hauswirth, brassfounder» · `o.wien_unnamed` «Vienna — workshop not identified» · `o.nuremberg_trade` «Nuremberg — trade goods» |
| 2 | `s.condition` | **The piece itself is ____** | CHOICE | `needs_any: [f.lug_seam, f.lacquer_unbroken]` | `o.as_made` «as it left the founder» · `o.repaired_honestly` «repaired once, in a shop, properly» · `o.made_up_from_parts` «made up from parts of more than one piece» |
| 3 | `s.papers` | **The papers in this folder are ____** | CHOICE | `needs: [f.cert_no1]`, `needs_any: [f.cert_scraped, f.ledger_line]` | `o.papers_in_order` «in order» · `o.one_figure_changed` «altered in one figure» · `o.papers_not_this_object` «not written for this object» |
| 4 | `s.interval` | **Days between the seal and the death of the depositor: ____** | **NUMBER** | `needs: [f.death_notice]`, `needs_any: [f.cert_no1, f.ledger_line]` · `digits: 2, min: 0, max: 99` | **списку нема, валідації нема.** Істина = **6** |
| 5 | `s.disposition` | **Disposition ____** | CHOICE | `needs_slot: [s.papers]` | `o.deliver_to_heirs` «to be delivered to the depositor's heirs» · `o.remain_in_bureau` «to remain in the bureau» · `o.sold_for_charges` «to be sold to defray charges» |
| 6 | `s.basis` | **On the basis of ____** | FACTS | `needs_slot: [s.disposition]` · `min_count: 2, max_count: 4` · `clears_on: [s.papers]` | джерело — `state.fact_order` |

**Пастка графи 4 навмисна.** Гейт відкривається вже з `f.cert_no1` — тобто гравець може вписати
**11** (за атестатом у теці) або **13** (за квитанцією), не заглянувши в гросбух. Гра не заперечує
і не підсвічує. Правильні **6** дає тільки `f.ledger_line`.

---

## 7. НАСЛІДКИ (порядок збігу — зверху вниз, перший збіг виграє)

**Безумовні беати того ж вечора й ранку** (не гілка, грають завжди):
- **Вечір:** щілина для листів порожня. Гравець підходить до неї двічі. Пошти нема — вперше за гру.
- **Ранок:** картка теки №1 стає в картотеку в **перше гніздо**, порожнє відтоді, як гравець сів
  за цей стіл. Шухляда вперше зачиняється врівень.
- **Ранок:** розкритий гросбух, на полі останньої сторінки рукою попередника підсумок: **1 429**.
  Жоден рядок гри це не коментує. (V6 §3.)

| # | id | умова | текст події наступного ранку (англ.) |
|---|---|---|---|
| 1 | `out.blamed_the_shop` | `s.condition = o.made_up_from_parts` | A note by the first post, on ruled shop paper. *"Sedlák & Son, coppersmiths, third generation at the same door. We are told the Bureau has questions of a piece bearing our anvil. We keep our job books. No. 214, entered 1851: new lug to a brass inkstand, brazed, forty kreuzer, paid. We should be glad to know what is in question."* It is signed by a grandson, in a careful hand, and he has drawn the anvil beside his name so there can be no mistake. |
| 2 | `out.sold_off` | `s.disposition = o.sold_for_charges` | The auction rooms send a runner before nine. He has a chit, a crate and two nails in his mouth. The inkstand goes out of the door in straw, and the porter signs for it in the book with a cross. The receipt of the 21st of April stays where it is, in the folder, and the folder is now empty enough to fold flat. |
| 3 | `out.to_heirs` | `s.disposition = o.deliver_to_heirs` | The letter comes back on the fourth day, refused. Across the face of it, in the post office's hand: *"No such person at this address. House pulled down 1877."* The stamp is not cancelled; they have not charged for the journey. |
| 4 | `out.counted_six` | `s.interval = 6` · `s.papers = o.one_figure_changed` · `basis_any: [f.cert_furrow, f.ledger_line]` · `basis_weight ≥ 5` | Nothing comes. Not by the first post, not by the second. The boy does not come back; the bindery has no reason to. By eleven the room is so quiet that the clock in the corridor can be heard changing its mind before it strikes. On the desk, where the folder was for forty years, there is a rectangle of desk that is a different colour. |
| 5 | `out.default` | — (обов'язковий останній) | The boy is back for the old volume, and stands turning his cap. The bindery cannot rebind it as it is: a page has been cut out — an old cut, he says, the edge browned all along. Would the Bureau like a replacement page ordered from the office? Three kreuzer. He waits for an answer with his hand out. |

Жодна гілка не каже «правильно» чи «неправильно». Гілка 4 — найтихіша, і саме вона правильна;
це навмисно, і це той самий закон, що в справі 1.

---

## 8. ХИБНИЙ СЛІД

**Що спокушає.** Вушко завіси перепаяне, і на споді продряпано **ковадло і 214**. Гравець уже
три справи знає, що перепаяний вузол = чуже місце, а чуже тавро = чужа річ. Тут воно лягає на
папери, яким він уже не довіряє: якщо річ ремонтували, значить, її **виймали з теки**, а якщо
виймали — тека брехлива не в даті, а вся.

**Куди веде.** У розділ ремонтних майстерень довідника, потім у наряди Sedlák & Son. Це чесні
5–6 хвилин із 15: руки зайняті, голова паралельно доходить, що річ ні до чого. Саме цього
хотів V6 («руки зайняті, поки голова доходить»).

**Чим спростовується — двічі, і жодного разу словами гри:**
1. **Документально:** наряди 199–261 стоять під **1851** роком. Ремонт на вісім років старший
   за квитанцію. Річ ремонтували, коли вона ще була вдома у власника.
2. **Фізично:** сітка кракелюр лакової плівки йде **суцільна через шов** і ніде не міняє
   ні густини, ні напрямку. Найм'якший припій плавиться при 183 °C, лак шеляку розм'якає при 80 °C —
   пізня пайка неминуче лишила б у плівці розрив або міхур. Отже лак покладено **після** пайки,
   і відтоді його ніхто не зрушив.

Другий доказ важливіший за перший: він не потребує довідника і працює, навіть якщо гравець
вирішив, що довідник теж бреше. Це той самий урок, що поставить справа 5.

---

## 9. ДВІ ГІПОТЕЗИ І РОЗВОДЖУВАЛЬНИЙ ФАКТ

**(А) Тека лишилась відкритою з канцелярської причини.** Вкладник помер, спадкоємець не з'явився,
річ ніхто не забрав — а обережна людина не закриває справу над майном покійного без розпорядження.
Ця гіпотеза переживає **все**: чесний ремонт, справне клеймо, слід чорнила в колодязі, порожню
графу видачі в гросбусі, навіть саму смерть. Вона нудна, повна й майже правильна.
**(Б) Тека лишилась відкритою тому, що її переписували.** Атестат був заповнений, запечатаний
і пронумерований — і **потім** у ньому змінили одну цифру дати, на п'ять днів назад.
**Розводить одне: `f.cert_furrow`** — вдавлена, вже незачорнена борозна пера під останньою цифрою
дня, на дряпаному місці. Гіпотеза А не має жодної причини рухати дату — під нею тека не
редагується, вона просто лежить. Борозна доводить редагування; друковані номери рядків гросбуха
доводять напрямок (з 28-го на 23-є, а не навпаки, бо в гросбусі 28-е не можна виправити локально).
Олівцевий кружечок із питальником на квитанції — не доказ, а свідчення того, що **сам попередник**
цю дату колись перечитував.

---

## 10. СТРИБОК ДУМКИ

Гравець виводить сам: **із річчю не було нічого — єдине, що в цій теці колись чіпали, це дата,
а дата має значення тільки для того, хто рахує дні до чогось; і коли він сам їх порахує, вийде шість.**

---

## 11. ЧЕСНІСТЬ МЕТОДУ ТА IP-ЧЕК

**Перевірено і правда:**
- Спиртовий (шелячний) лак ливарників XIX ст., тонований куркумою/драконовою кров'ю, кладеться
  на теплий метал, з десятиліттями жовтіє і береться сіткою кракелюр. Розм'якає ~80 °C.
- Температури припоїв (м'який 183–216 °C, латунний ~870 °C) — довідникові.
- Виявлення підчистки: зіскоблене місце має збитий ворс, чорнило по ньому розтікається вбік,
  а вдавлення пера від первісного штриха лишається в папері й читається **косим світлом**.
  Це метод доби, і він не потребує ні хімії, ні просвітлення.
- Друковані номери рядків у розлінованих конторських книгах — стандарт стаціонерів.
- Міські списки померлих у пресі (ім'я, вік, адреса, дата, причина) — реальна практика.
- 23.04.1859 минув ультиматум Австрії, 29.04.1859 війська перейшли Тічино. Дати справжні.
- Календар квітня–травня 1859 звірено (28.04 — четвер, 04.05 — середа, 07.05 — субота).

**Прямо кажу, де метод був би сумнівним, і що зроблено натомість:**
- **Набите тавро ремонтної майстерні на латуні не задокументоване.** Тому номер наряду тут
  **продряпаний**, а не набитий — а це якраз засвідчена практика (годинникарі писали номер і дату
  всередині кришки; V6 уже спирається на неї у справі 3).
- **Латунь не датується за складом** у 1900-х із потрібною точністю; гідростатична вага дає
  8.4–8.7 і для віденського, і для нюрнберзького виробу. Тому вага в цій справі **не використана
  взагалі** — і це не пропуск, а перший тихий крок до справи 10, де прилад мовчить.

**IP-чек.** Усі власні імена вигадані й перевірені на відсутність відомого носія в цьому ремеслі:
*L. Hauswirth* (ливарник), *Sedlák & Son* (мідники), *Tobias Reindl* (вкладник), *Bittner*,
*Nadler & Kraus*, *Wieser*, *Pohl*, *Bräuer*. Schleifmühlgasse — справжня віденська вулиця
(адреси не є IP). Жодного обличчя в цій справі, крім хлопця-посланця (новий портрет).

---

## 12. ВХІД

Три речі сходяться, і жодна з них — не кнопка.

1. **Порожнє перше гніздо.** Три справи поспіль гравець дивився, як картка з'їжджає в картотеку.
   Щоразу вона лягала **другою**: гніздо №1 порожнє від першого кадру гри.
   *Арт-вимога до справ 1–3: у кадрі шухляди перше гніздо видиме й порожнє. Це коштує нуль і
   окупається тут.*
2. **Тека на столі.** Вранці справи 4 клієнта нема. Під бюваром лежить тека, підписана рукою
   попередника: **«№ 1»**, стрічка зав'язана бантом, який зав'язували сорок років тому.
   Усередині — латунна каламарка, загорнута в фланель, квитанція, атестат.
   **На квитанції дата обведена олівцем і поруч питальник** — тим самим олівцем, тією ж рукою.
   Питальник поставив не гравець.
3. **Стрічка в підшивці.** Хлопець із палітурні забирає старий том. Щоб віддати, гравець знімає
   його з полиці — і том розкривається сам, на **стрічці-закладці**, на тижні 1–7 травня 1859.
   Закладку поклав попередник. Гра не каже про це ні слова; стрічка просто там,
   і вона тієї ж вицвілої зелені, що бант на теці.

Перше речення дня, і єдине, яке гра дозволяє собі сказати вголос:
> *"No one is coming today."*

---

## 13. ЗАЛЕЖНОСТІ Й БОРГИ ПЕРЕД ІНШИМИ СПРАВАМИ

| що | куди | навіщо |
|---|---|---|
| порожнє гніздо №1 у картотеці | справи 1–3 (арт) | вхід справи 4 |
| анімація підшивання картки після кожної печатки | справи 1–3 | і §12, і удар справи 7 |
| **рік 1859** (перша печатка попередника) | **фінал**, графа «не раніше ніж» | гравець уже тримав це число в руках |
| **1 429** печаток | після справи 4, безумовно | поштовх V6 §3: одна на 10 днів, а тут — шість |
| вирізана сторінка в підшивці (`out.default`) | справа 5, «архів бреше» | архів уже неповний, і це помітив палітурник, а не гра |
| гросбух як інструмент екстраполяції | справа 7 (вивід року по темпу печаток) | тут гравець уперше читає гросбух як хронологію |
| «прилад мовчить» | справа 10 | у справі 4 вага вперше не потрібна взагалі |
