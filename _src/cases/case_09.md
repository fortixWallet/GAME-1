# СПРАВА 9 — «БІНОКЛЬ З ЛОЖІ №4» (THE GLASS FROM BOX FOUR)

**№ 9 · 35 хв · акт III, другий такт (після «Келих повертається»)**

**Роль в акті.** Дві справи поспіль гравець дивився на власний підпис (7) і на власну першу
печатку (8). Тут він уперше бачить **живу людину, чий некролог уже надруковано**, — і сам
доводить, що некролог **набрано раніше за смерть, яку він повідомляє**. Це та справа, де патерн
перестає бути статистикою тек і стає годиною в книзі: вісім вечора, двадцять чотири рядки,
готівкою, без імені платника. Кнопки «попередити» в грі нема. Гравець ставить печатку на
атестат про **бінокль**, а не про людину, і мусить це зробити свідомо.

**Вузол із справами 1 і 8.** Підробник має доступ до **друкарні** (гарт у ніжці келиха). Тут
той самий доступ виявляється з іншого боку: не до металу, а до **шпальти**. Гра цього не каже.

**Малий поштовх §3 сюжету відбувається тут:** констебль просить підтвердити власний підпис —
гравець розписується **вдруге, поруч із першим**, на тому самому аркуші.

**Нових інструментів нема.** Нова дія: **звірка двох примірників одного числа** (екран `SHEETS`,
дві газети поруч, гравець тягне лупу по одній і по другій).

---

## 1. КЛІЄНТ

**Heinrich Wallner**, 50, крамар з Відня-Віден, торгує ґудзиками й позументом. Приходить сам,
пішки, з футляром під пахвою і складеною газетою в руці. Кладе газету на стіл першою, не бінокль.

**Названа потреба (не пов'язана з річчю).**
> "My daughter signs her marriage contract on Saturday, and the notary will not sit down without
> a schedule of everything in the house, down to the spoons. I have come to you for the schedule,
> not for the joke. The joke I brought because a man cannot keep a thing like this to himself."

**Фізична деталь, яку кадр показує і жоден текст не коментує.**
На капелюсі, що лежить на кутку стола, — **чорна крепова стрічка, пришита свіжою ниткою**:
стібки нерівні, кінець нитки не обрізаний, вузол назовні. Він її не згадує жодного разу.
Камера тримає капелюх 1.4 с, коли Валльнер розгортає газету. Жодної репліки, жодного курсора.
*(Гра ніколи не пояснює, по кому траур. Це не загадка — це деталь.)*

**Друга деталь, яку помітить не кожен:** газета складена сторінкою 3 назовні, і згин **пухнастий,
протертий до ворсу** — її розгортали й складали разів двадцять. Він каже, що це смішно.

**Дві репліки на печатку.**

| Умова | Репліка |
|---|---|
| **Швидко** — печатка поставлена до того, як здобуто `f.adbook_wallner` (гравець не заглядав у книгу прийому) | "Quick work. My wife will be glad. She has not laughed at it once, and I have been at her about it since Tuesday." |
| **Довго** — печатка поставлена, коли здобуто ≥ 10 фактів **або** минуло > 20 хв | "You have been a long while over a pair of glasses. — What is it. You may tell me. I am not a nervous man." |

**Ім'я вписує гравець** на квитанції власною рукою: *Heinrich Wallner*. Він стоїть і дивиться,
як гравець це робить. У некролозі, що лежить розгорнутий на тому самому столі, це ім'я вже надруковане.

---

## 2. ПРЕДМЕТ І МАТЕРІАЛИ

**Річ.** Театральний бінокль (галілеївська система, без призм), стволи обклеєні перламутром,
оправа й міст — золочена латунь. Окулярне кільце штамповане по колу: **LEMAIRE FABt PARIS**,
поруч — **бджола**. Через міст різцем прорізано: **BENEFIZ · LOGE IV**. Центральний гвинт
фокусування ходить туго. Лівий об'єктив **замінений**; на правому — **свіжий скол** при краю.

**Футляр.** Циліндричний, шкіра по картону, шовкова підбивка, всередині кришки — тиснена
марка галантерейника. Під оксамитом при завісі **затиснута половинка контрамарки**.

**Папери на столі (нічого не приносять ззовні по ходу справи).**
- **Газета клієнта** — *Abendblatt*, 14 травня, число **132**, при заголовку **три зірки**;
- **Примірник бюро** — те саме число 132, при заголовку **одна зірка** (бюро передплачує ранню
  розноску; підшивка стоїть у кімнаті з першої справи);
- **Книга прийому оголошень** (`Anzeigen-Annahmebuch`) газети — **її приніс констебль**, у справі
  про іншу об'яву (див. §12 ВХІД). Лежить розгорнута, з вкладеними рукописними копіями;
- **Підшивка театральних афіш** сезону — на полиці довідників, оправлена в холст.

**Атмосфера екрана `SHEETS`:** дві газети на столі поруч, притиснуті лінійкою і чорнильницею,
щоб не згорталися. Коли гравець кладе лупу на одну — друга темніє на третину. Звук паперу
глухий, як у вологого.

---

## 3. ЗОНИ

Вісім зон, чотири екрани. Усі підписані, жодного pixel hunt.
2D-координати — **у частках ЗОБРАЖЕННЯ** (не екрана), радіус — у частках **ширини** зображення.

| zone_id | де саме | kind | screen / surface | координати | r | стани |
|---|---|---|---|---|---|---|
| `z.glass.bridge` | латунний міст між стволами: різьблений напис + головка гвинта фокусування | `node3d` | OBJECT, anchor `glass_pivot` | p = (0.000, 0.012, 0.031), n = (0, 1, 0) | 0.40 (світові од.), `facing_min` 0.20 | `default` |
| `z.glass.objectives` | обидва об'єктиви, скло в кільцях; на правому — скол при краю на 4 години. **Дві інстанції однієї зони:** `instance: left` / `instance: right` | `node3d` | OBJECT, anchor `glass_pivot` | `left` p = (−0.041, −0.004, 0.058) · `right` p = (+0.041, −0.004, 0.058), n = (0, 0, 1) | 0.26 (світові од.), `facing_min` 0.30 | `default` |
| `z.glass.eyering` | окулярне кільце лівого ствола, штамп по колу + бджола | `node3d` | OBJECT, anchor `glass_pivot` | p = (−0.041, −0.004, −0.052), n = (0, 0, −1) | 0.22, `facing_min` 0.35 | `default` |
| `z.case.lining` | футляр: шовк при завісі, де під підбивку затиснуто папір | `img` | CASE / `case_open` | u = (0.435, 0.610) | 0.130 | **`default`** = підбивка ціла · **`marque_out`** = половинка витягнута й лежить лицем угору |
| `z.paper.head` | верх сторінки 1: назва, дата, число, **зірки видання**, вихідні дані внизу шпальти | `img` | SHEETS / `sheets_pair` (діє на обидва примірники, курсор ловить ближчий) | u = (0.262, 0.180) і (0.738, 0.180) — **дві інстанції однієї зони**, `instance: office` / `instance: client` | 0.115 | `default` |
| `z.paper.p3` | сторінка 3, друга шпальта згори: некролог Валльнера у рамці | `img` | SHEETS / `sheets_p3` | u = (0.300, 0.395) і (0.762, 0.395), `instance: office` / `client` | 0.120 | `default` |
| `z.paper.p4` | сторінка 4, низ третьої шпальти: у примірника бюро — курс борошна й вугілля, у клієнта — рамка BERICHTIGUNG | `img` | SHEETS / `sheets_p4` | u = (0.318, 0.712) і (0.780, 0.712), `instance: office` / `client` | 0.120 | `default` |
| `z.book.ads` | книга прийому оголошень, розворот 13–14 травня; праворуч у кишеньці — рукописні копії | `img` | DESK / `adbook_spread` | u = (0.545, 0.505) | 0.185 | **`default`** = розворот · **`copies_out`** = копії витягнуті з кишеньки й розгорнуті |

> **Зон рівно 8.** Чотири з них існують у **двох інстанціях**: `z.glass.objectives`
> (`left` / `right`) і `z.paper.head` / `p3` / `p4` (`office` / `client`). Це **одна зона з полем
> `instance`**, а не дві зони: спільний підпис, спільний набір інструментів, спільні правила.
> Правило, якому потрібна звірка, вимагає `instance: both` і спрацьовує лише тоді, коли той
> самий інструмент побував на обох інстанціях. **Уся справа побудована на одному дієслові —
> «покласти поруч»**, і зонна модель це повторює.

`tools` для курсора:
`z.glass.bridge` → loupe, hand · `z.glass.objectives` → loupe, candle, rake ·
`z.glass.eyering` → loupe · `z.case.lining` → hand, loupe · `z.paper.head` → eye, loupe ·
`z.paper.p3` → eye, loupe · `z.paper.p4` → eye, loupe · `z.book.ads` → eye, loupe, hand.

---

## 4. ПРАВИЛА

`requires` — факти, які мусять уже бути. `note` — англійський текст **спостереження** в нотатник
і в репліку (`say_key`). Висновків у note нема ніде.

| # | zone_id | tool | requires | fact_id | note (EN, спостереження) | sets_state |
|---|---|---|---|---|---|---|
| r.01 | `z.glass.bridge` | `tool.loupe` (dwell 0.4) | — | **немає факту** — `say_key` | "Cut across the brass of the bridge, in a jobbing engraver's script: BENEFIZ · LOGE IV. The cut is bright at the bottom of the furrow." | — |
| r.02 | `z.glass.eyering` | `tool.loupe` (dwell 0.6) | — | `f.maker_mark` | "Stamped round the eye-ring, small and even: LEMAIRE FABt PARIS. Beside the last letter, a bee, wings out, about a millimetre across." | — |
| r.03 | `z.glass.objectives` | `tool.candle` (dwell 0.9, `instance: both`) | — | `f.obj_reflections` | "A candle held off to one side and the glasses turned to it: the left object-glass throws back two images of the flame. The right throws back two bright ones and a third, dim, lying between them." | — |
| r.04 | `z.glass.objectives` | `tool.loupe` (dwell 0.5, `instance: both`) | `f.obj_reflections` | `f.obj_left_ring` | "The ring that holds the left glass is bright in both its slots and its rim stands proud of the tube by about a hair's thickness. The right ring is dull all round and sits flush. Along the edge of the left field, a fringe of colour, yellow on one side of a line and blue on the other." | — |
| r.05 | `z.glass.objectives` | `tool.rake` (on_click, `instance: right`) | — | **немає факту** — `say_key` | "A chip at the edge of the right glass, the size of a grain of wheat. Its faces are clean and take the lamp. The scratches on the brass beside it are grey to the bottom." | — |
| r.06 | `z.case.lining` | `tool.hand` (on_click) | — | `f.case_marque` | "Pressed under the silk at the hinge, flat and hard: half a card, torn across. Printed on it — VORSTELLUNG N° 1147 · LOGE IV · AUSGANG. The torn edge is white to the tear; the rest of the card has gone cream." | `z.case.lining → marque_out` |
| r.07 | `z.case.lining` | `tool.loupe` (dwell 0.5, `zone_state: marque_out`) | `f.case_marque` | **немає факту** — `say_key` (правило → довідник §6.3) | "Printed small along the foot of the half card: 'Der Besucher behält diese Hälfte und gibt sie beim Wiedereintritt ab.' — The visitor keeps this half and surrenders it on re-entering. This half was not surrendered." | — |
| r.08 | `z.paper.p3` | `tool.eye` / `*` (on_click, `instance: any`) | — | `f.notice_wallner` | "Page 3, second column, in a black rule: 'HEINRICH WALLNER, Kaufmann, of the Wieden, departed this life on the 14th of May at six in the morning, in his fifty-first year. The funeral from the house of mourning on the 16th, at three.' Twenty-four lines." | — |
| r.09 | `z.paper.head` | `tool.eye` / `*` (on_click, `instance: both`) | — | `f.two_editions` | "Both sheets are the Abendblatt of the 14th of May, number 132. Beside the title of the office's copy stands one star. Beside the title of his, three." | — |
| r.10 | `z.paper.p3` | `tool.loupe` (dwell 1.0, `instance: both`) | `f.notice_wallner`, `f.two_editions` | `f.p3_identical` | "Pages 2 and 3 are the same in both sheets, letter for letter. In the fourth line of the Wallner notice the same 'e' is broken away at the shoulder in the one as in the other, and the same word ends the same line." | — |
| r.11 | `z.paper.p4` | `tool.eye` / `*` (on_click, `instance: both`) | `f.two_editions` | `f.p4_differs` | "Page 4 is not the same in the two sheets. Where the office's copy has the price of flour and of coal, his has a framed notice: BERICHTIGUNG." | — |
| r.12 | `z.paper.p4` | `tool.loupe` (dwell 0.5, `instance: client`) | `f.p4_differs` | `f.correction_zeller` | "BERICHTIGUNG: 'In the first impression of this day's sheet the death notice for Fräulein A. ZELLER was given under the name KELLER. The fault is the printing house's, and it is regretted. The notice stands corrected below.'" | — |
| r.13 | `z.paper.head` | `tool.loupe` (dwell 0.8, `instance: any`) | `f.two_editions` | `f.imprint_hours` | "In the six-point matter at the foot of the last column: 'Inner sheet (pp. 2 and 3) closed at ten at night. Outer sheet (pp. 1 and 4) closed at three. Later matter is taken for pages 1 and 4 only, up to the striking of the machine.'" | — |
| r.14 | `z.book.ads` | `tool.eye` / `*` (on_click) | — | `f.adbook_wallner` | "Receiving book, entry 4471: 'Todesanzeige — Wallner. 24 lines, black rule. Taken 13 May, eight in the evening. 4 fl. 80, paid in coin. Name of payer not given. Copy in the pocket.'" | — |
| r.15 | `z.book.ads` | `tool.hand` (on_click) | `f.adbook_wallner` | `f.adbook_copy` | "The copy for 4471, taken out of the pocket: a counter clerk's hand, ink, on the paper's own ruled slip. The name is written out full — Heinrich Wallner — and the hour of death stands in the copy exactly as it stands in print. Below it the clerk's own line: 'dictated at the counter; the gentleman would not give his name.'" | `z.book.ads → copies_out` |
| r.16 | `z.book.ads` | `tool.eye` / `*` (on_click, `zone_state: copies_out`) | `f.correction_zeller` | `f.adbook_zeller` | "Entry 4479, the Zeller notice: 'Taken 13 May, half past eleven at night. Set for page 4.' Across it in red: 'name mis-set; corrected in the third impression, no charge.'" | — |
| r.17 | `z.book.ads` | `tool.loupe` (dwell 1.4, `zone_state: copies_out`) | `f.adbook_wallner`, `f.adbook_copy` | `f.adbook_run` | "Turning back through the book: four other death notices of twenty-four lines, black rule, each taken between eight and nine in the evening, each paid in coin, each with the name of the payer left blank. They are two, three and five weeks apart. One of the names is a name you wrote out yourself, on a receipt, in this office." | — |
| r.18 | `z.glass.bridge` | `tool.hand` (on_click, `repeat`) | — | **немає факту** — `say_key` | "The focusing screw is stiff and takes both thumbs. Between the barrels, where no cloth has ever been, the gilding is still whole." | — |
| r.19 | `z.paper.p3` | `tool.loupe` (dwell 1.0, `instance: office` **або** `client`, не обидва) | `f.notice_wallner` | **немає факту** — `say_key` | "The same notice, the same words. There is nothing here that was not here a moment ago." | — |
| r.20 | `z.glass.objectives` | `tool.candle` (dwell 0.9, `instance: left` **або** `right`, не обидва) | — | **немає факту** — `say_key` | "Two images of the flame, one behind the other. Two of anything is not a number until there is something to set it against." | — |
| r.21 | `z.glass.objectives` | `tool.eye` (on_click, `instance: any`) | — | **немає факту** — `say_key` | "Straight on, under the desk lamp, both glasses give back the lamp and nothing else." | — |

**Примітки для програміста.**
- **r.19 і r.20 — навмисні «майже», по одному на кожну половину справи.** Гравець, який водить
  лупою по одному примірнику (чи свічкою по одному об'єктиву) скільки завгодно, не отримує нічого.
  `f.p3_identical` і `f.obj_reflections` народжуються **тільки** з поля `instance: both` — коли той
  самий інструмент побував на обох інстанціях. Це гейт **розуміння** («покласти поруч»), а не гейт
  кліку. Технічно: правило тримає `seen: Set[instance]`, скидається разом із фактами.
  `say_key` r.20 навмисно формулює саме те, чого гравцеві бракує, і **не** каже, що робити.
- **r.21** ловить очевидну хибну дію (дивитися просто оком при настільній лампі) і пояснює її
  провал фізикою, а не забороною. Див. §6.5: тьмяне третє відображення видно лише при **боковому
  полум'ї**, тобто тільки з `tool.candle`. Нових інструментів справа не вводить.
- **r.03 і r.04 дають обидва об'єктиви одним фактом кожне.** І кількість відображень, і стан
  кілець мають сенс лише як порівняння лівого з правим — це одне спостереження, не два.
  Один факт = один id.
- **r.06 / r.07** — витягання й читання розділені: рука дістає, лупа читає дрібний рядок.
  `sets_zone` абсолютний, тому `marque_out` назад не вертається (половинка вже на столі).
- **r.15 / r.16 / r.17** — `copies_out` відкриває три різні глибини одного розвороту.
  r.17 має `dwell 1.4` навмисно: це найдовше затримання в грі до цієї миті.
- **r.11 не потребує лупи** — різницю сторінок 4 видно оком. Лупа (r.12) потрібна лише
  прочитати, **що саме** там надруковано. Так хибний слід приходить сам, без зусиль.
- `f.notice_wallner` і `f.p3_identical` — **різні** факти (зміст проти тотожності набору).
- Дублі ловить `add_fact()`. `instance` у факт **не** записується.

---

## 5. ФАКТИ (14)

| fact_id | text (EN, у нотатнику) | cite (у графі "on the basis") | tag | weight |
|---|---|---|---|---|
| `f.maker_mark` | "Stamped round the eye-ring: LEMAIRE FABt PARIS, and beside it a bee about a millimetre across." | "the eye-ring carries Lemaire's name and the bee" | `object` | 2 |
| `f.obj_reflections` | "The left object-glass throws back two images of a candle. The right throws back two bright and a third, dim, between them." | "the left object-glass returns two images of a flame where its fellow returns three" | `object` | 3 |
| `f.obj_left_ring` | "The left retaining ring is bright in its slots and stands proud by a hair; the right is dull and flush. Along the edge of the left field, colour fringes yellow one side of a line and blue the other." | "the left glass sits in a ring that has been turned, and its field is fringed with colour" | `object` | 2 |
| `f.case_marque` | "Under the silk at the hinge of the case, pressed flat: half a torn card — VORSTELLUNG N° 1147 · LOGE IV · AUSGANG. The torn edge is white; the rest of the card is cream." | "half a pass-check for performance 1147, box four, was in the case" | `marque` | 3 |
| `f.notice_wallner` | "Page 3, in a black rule, twenty-four lines: 'HEINRICH WALLNER, Kaufmann, of the Wieden, departed this life on the 14th of May at six in the morning, in his fifty-first year. Funeral from the house on the 16th, at three.'" | "the notice gives the death as the 14th of May, at six in the morning" | `paper` | 2 |
| `f.two_editions` | "Both sheets are the Abendblatt of 14 May, number 132. One star beside the office's title; three beside his." | "there are two impressions of number 132, marked one star and three" | `paper` | 2 |
| `f.p3_identical` | "Pages 2 and 3 are the same in both sheets letter for letter — the same broken 'e' at the shoulder in the fourth line, the same word ending the same line." | "page 3 is one and the same setting in both impressions" | `paper` | 3 |
| `f.p4_differs` | "Page 4 is not the same in the two sheets: prices of flour and coal in the office's, a framed BERICHTIGUNG in his." | "page 4 was re-set between the impressions and page 3 was not" | `paper` | 2 |
| `f.correction_zeller` | "BERICHTIGUNG: the death notice for Fräulein A. ZELLER was given under the name KELLER in the first impression; the fault is the printing house's; the notice stands corrected below." | "a name mis-set in this same issue was corrected the same night" | `false_trail` | 2 |
| `f.imprint_hours` | "At the foot of the last column: 'Inner sheet (pp. 2 and 3) closed at ten at night. Outer sheet (pp. 1 and 4) closed at three. Later matter is taken for pages 1 and 4 only, up to the striking of the machine.'" | "pages 2 and 3 were locked up at ten the night before" | `paper` | 3 |
| `f.adbook_wallner` | "Receiving book, entry 4471: 'Todesanzeige — Wallner. 24 lines, black rule. Taken 13 May, eight in the evening. 4 fl. 80, paid in coin. Name of payer not given.'" | "the notice was lodged at eight on the evening of the 13th" | `book` | 4 |
| `f.adbook_copy` | "The counter copy for 4471: a clerk's hand, the name written out full, the hour of death standing in the copy as it stands in print. The clerk's own line: 'dictated at the counter; the gentleman would not give his name.'" | "the counter copy has the name and the hour right, in a clerk's hand" | `book` | 3 |
| `f.adbook_zeller` | "Entry 4479, the Zeller notice: taken 13 May at half past eleven at night, set for page 4; across it in red, 'name mis-set; corrected in the third impression, no charge.'" | "the mis-set notice was lodged at half past eleven and went to page 4" | `false_trail` | 2 |
| `f.adbook_run` | "Four other death notices in the same book: twenty-four lines, black rule, each taken between eight and nine in the evening, each paid in coin, each with the payer's name left blank, two to five weeks apart. One of the names is a name you wrote out yourself, on a receipt, in this office." | "four notices before this one were lodged in the same hour, at the same length, by no one" | `book` | 5 |

> **Разом 14 фактів, 14 різних `fact_id`.** Тег `false_trail` не ховає факт і не позначає його
> в нотатнику — це поле лише для матчера наслідків (§8).
>
> **Три спостереження навмисно НЕ є фактами** і живуть тільки як `say_key`:
> гравіювання «BENEFIZ · LOGE IV» на мосту (r.01), свіжий скол на правому об'єктиві (r.05)
> і друкований припис на контрамарці (r.07). Перше — упізнання речі (номер ложі дублюється
> в `f.case_marque`); друге — **стан речі**, який іде в оцінку, а не в доказ; третє — **правило**,
> а не спостереження: його місце в довіднику §6.3, а не в нотатнику. У графу «на підставі»
> правила не тягнуться ніколи — тільки побачене.

---

## 6. ДОВІДНИКОВІ ТАБЛИЦІ

Усі — окремі мальовані розвороти (гравюра XIX ст.), стоять на полиці довідників.
Значення справжні; там, де метод має межу, межа написана в самій таблиці.

### 6.1. Формa, спуск і видання щоденної газети (розворот «Die Form»)

Джерело: J. Southward, *A Dictionary of Typography and its Accessory Arts*, London 1871,
статті **Inner Forme / Outer Forme / Perfecting**; практика «patent insides» (A. J. Aikens, 1863).

| Термін | Що це | Порядок роботи |
|---|---|---|
| **Внутрішня форма** (inner forme) | сторінки **2 і 3** одноаркушевого числа | **друкується ПЕРШОЮ.** Southward: *«It perfects the first or outer forme, and is usually worked first»* |
| **Зовнішня форма** (outer forme) | сторінки **1 і 4** | друкується другою, по звороту вже задрукованого аркуша |
| Наслідок для редакції | пізні телеграми, біржа, поправки | ідуть **тільки на 1 і 4** — інші дві сторінки на той час уже на папері |
| **Видання** (Ausgabe, impression) | те саме число, той самий номер | позначається **зірками / літерами при заголовку**. Перезаливають **зовнішню** форму; внутрішню — ні |
| «Готовий фарш» (patent insides, з 1863) | внутрішні сторінки, віддруковані **наперед**, іноді за тиждень | доводить правило в крайньому вигляді |

> ⚠️ **Правку внесено проти плану.** У плані стояло «зовнішні сторінки друкувалися раніше за
> внутрішні». **Це навпаки.** Перевірено за словником Саутворда (1871) і за практикою
> преддрукованих внутрішніх аркушів: **першою йде внутрішня форма (стор. 2–3), останньою —
> зовнішня (стор. 1 і 4)**. Загадка від цього стає **кращою**: некролог сидить на сторінці 3,
> тобто на аркуші, який **не можна виправити** після десятої вечора, — а сусідня одруківка
> сидить на сторінці 4, яку виправили тієї самої ночі. Різниця в долі двох об'яв **і є доказ**.

### 6.2. Прийом об'яв і похоронних сповіщень (розворот «Annahme»)

| Правило контори | Як це виглядає в книзі |
|---|---|
| Кожна платна об'ява дістає **номер прийому** підряд по книзі | `4471`, `4479` |
| Записується **година подачі**, не лише день | «13. Mai, 8 Uhr abends» |
| Рахунок береться **з рядка**; похоронна об'ява — у чорній рамці, ціна вища | «24 Zeilen, Trauerrand, 4 fl. 80» |
| **Рукописна копія** лишається в кишеньці розвороту (претензії) | слип контори, рука прикажчика |
| Ім'я **платника** записується, коли той його дає; готівкою можна без імені | «Name des Aufgebers nicht angegeben» |
| Похоронну об'яву **не перевіряють** ні в парафії, ні в поліції | у книзі нема відповідної графи взагалі |
| Помилку набору виправляють **безкоштовно** й у найближчому виданні | «berichtigt, 3. Ausgabe, ohne Berechnung» |

> **Чесно про метод.** Це і є найтемніше місце доби: **об'ява про смерть не потребувала жодного
> підтвердження**. Досить було прийти, продиктувати й заплатити. Саме тому фальшиві некрологи —
> реальна тодішня прикрість, а не вигадка сюжету. Гра не мусить це проговорювати: **порожня графа
> в друкованому бланку книги** каже більше за абзац.

### 6.3. Контрамарка і нумерація вистав (розворот «Kontramarke»)

| Що | Правило |
|---|---|
| **Kontramarke / contremarque** | не квиток. Це **перепустка на повернення**: глядач, що виходить під час дії, отримує картку, рвану надвоє |
| Половина глядача | несе **номер вистави** і номер місця; **здається при поверненні** |
| Половина каси | лишається на дверях, нанизується на дріт, здається до звіту |
| Наслідок | половина глядача, що вціліла, означає **не повернувся** |
| **Нумерація вистав** | театри вели наскрізний рахунок вистав від початку сезону (`Vorstellung Nr.`); підшивка афіш дає номер → дату |

**Витяг із підшивки афіш сезону (розворот «Spielplan», реквізит):**

| Vorstellung Nr. | Дата | Вистава |
|---|---|---|
| 1143 | 22 травня | *Der Verschwender* |
| 1145 | 25 травня | *Die Journalisten* |
| **1147** | **28 травня** | **Benefiz-Vorstellung für Herrn Wallner ~~~ Die Räuber** |
| 1149 | 31 травня | *Der Zerrissene* |

> Афішу бенефісу підшито **окремим кольором** (жовтий папір, як у доби). Ім'я на ній —
> **не наш клієнт**: бенефіс дано на честь **актора Йозефа Валльнера**, однофамільця.
> Гра цього не коментує; збіг прізвищ пояснює гравіювання «BENEFIZ · LOGE IV» без жодної містики.
> *(Це не хибний слід, а закриття дірки: інакше гравець підозрює, що бенефіс — на честь клієнта.)*

### 6.4. Паризькі виробники театральних біноклів і їхні марки (розворот «Lorgnettes»)

| Марка на кільці | Майстерня | Роки в ужитку | Ознака |
|---|---|---|---|
| **LEMAIRE FABt PARIS + бджола** | Lemaire, Париж | бл. **1846** — і в наступників до 1900-х | бджола б'ється **окремим пуансоном** біля напису; перламутр підібраний по хвилі |
| **COLMONT FABt PARIS** | Colmont, Париж | бл. 1850 — 1890-ті | без емблеми, шрифт ширший |
| **BARDOU & FILS PARIS** | Bardou, Париж | 1819 — 1900-ті | здебільшого труби й підзорні, біноклі рідші |
| **CHEVALIER PARIS** | Chevalier | XVIII ст. — 1880-ті | найстаріша фірма, ранні оправи |
| без марки | збірка з готових частин | увесь період | кільце гладке |

> **Чесно про метод.** Роки взято з колекціонерської літератури й каталогів, **не з архіву
> фірми**. Марка Lemaire з бджолою датує річ **широко** (друга половина століття) і **не датує
> вужче**. Тому в атестаті графа про майстра — **вибір, а не число**: числову вагу несуть
> година в книзі й номер вистави. Так і має бути.

### 6.5. Скільки скла в об'єктиві: рахунок відображень (розворот «Die Gläser»)

Метод оптика: скло **не розбирають**, а рахують відображення полум'я. Кожна межа
«повітря–скло» дає **яскраве** відображення; склеєна межа «скло–скло» — **слабке**.

| Що в оправі | Відображень полум'я | Як це видно |
|---|---|---|
| **одиночна лінза** | **2**, обидва яскраві | і все |
| **склеєний ахромат** (крон + флінт, канадський бальзам) | **2 яскраві + 1 тьмяне між ними** | тьмяне — від шва клею |
| ахромат **без клею, з повітряним проміжком** | **4 яскраві** | рідко в театральних біноклях |

| Ознака | Одиночна лінза | Ахромат |
|---|---|---|
| край поля зору | **кольорова облямівка**: жовте з одного боку контуру, синє з другого | облямівки практично нема |
| ціна ремонту | дешево, будь-який окуляриста | дорого, під замовлення |

> **Чесно про метод.** Рахунок відображень надійний і фаховий для доби; єдина пастка —
> **тьмяне третє відображення видно лише при боковому полум'ї в темряві**, тому правило r.03
> вимагає саме `tool.candle`, а не лампу. Кольорова облямівка (`f.obj_left_ring`) — друга,
> незалежна ознака того самого. Дві ознаки, а не одна: цього досить.

---

## 7. АТЕСТАТ (6 граф, дві числові)

Бланк: `cert_09_box_four`. Порядок жорсткий, гейти — по фактах.

| # | slot_id | префікс (EN) | тип | гейт | варіанти / межі |
|---|---|---|---|---|---|
| 1 | `s.maker` | "Made by ____." | CHOICE | `needs`: `f.maker_mark` | `o.lemaire` ("Lemaire of Paris") · `o.colmont` ("Colmont of Paris") · `o.unsigned_french` ("a French shop, unsigned") · `o.later_copy` ("a later copy carrying the bee") |
| 2 | `s.optics` | "The object-glasses are ____." | CHOICE | `needs`: `f.obj_reflections`, `f.obj_left_ring` | `o.pair_original` ("a matched pair, both as made") · `o.left_replaced` ("unmatched: the left a single glass where the right is a cemented pair") · `o.both_replaced` ("both renewed") · `o.cannot_say` ("not to be told without opening the tubes") |
| 3 | `s.hours_before` | "The notice was lodged with the paper ____ hours before the hour of death it gives." | **NUMBER**, digits 2, min 0, max 99 | `needs`: `f.notice_wallner`, `f.adbook_wallner` | списку нема, валідації нема |
| 4 | `s.day_in_house` | "The glass was last carried into the theatre on the ____ day of May." | **NUMBER**, digits 2, min 1, max 31 | `needs`: `f.case_marque` | списку нема, валідації нема |
| 5 | `s.notice_verdict` | "The notice on page 3 of number 132 is ____." | CHOICE | `needs_slot`: `s.hours_before`; `needs_any`: `f.imprint_hours`, `f.p3_identical`, `f.adbook_copy` | `o.set_before` ("matter set and paid for before the death it reports") · `o.printers_error` ("a fault of the printing house, of the kind corrected on page 4") · `o.wrong_man` ("a true notice of another man of the same name") · `o.true_and_late` ("a true notice, printed after the fact") · `o.cannot_say` ("not to be told from these sheets") |
| 6 | `s.basis` | "On the basis of ____." | FACTS | `needs_slot`: `s.notice_verdict`; `clears_on`: `s.notice_verdict` | min 2, max 4; джерело — `state.fact_order` |

**Правильні значення** (рушій їх не знає — знають тільки OUTCOMES):
`s.maker = o.lemaire` · `s.optics = o.left_replaced` ·
**`s.hours_before = 10`** (подано 13 травня о 8-й вечора → година смерті 14 травня о 6-й ранку) ·
**`s.day_in_house = 28`** (вистава № 1147 за підшивкою афіш) ·
`s.notice_verdict = o.set_before`.

**Чому 10, а не 9 і не 11.** Гравець рахує **від години подачі до години смерті**: 20:00 → 06:00.
Проміжна пастка навмисна: хто рахує **від закриття внутрішньої форми** (22:00 → 06:00), впише **8**.
Це не помилка неуважного, це помилка **іншої, теж розумної думки**, і вона має власну гілку
наслідків (див. O2). Гра ніде не каже, від чого рахувати; префікс графи каже: **«lodged … before»**.

**Заборонено:** підсвічувати правильну цифру, показувати «✓», блокувати печатку при 8.
Числова графа перевіряється **тільки завтрашнім ранком**.

---

## 8. НАСЛІДКИ (ранок наступного дня)

Матчер бере **перший** запис, чиї умови збіглися. `out.default` — завжди останній.

### O1 · `out.named_the_hour` — година названа правильно
```
when: s.notice_verdict = o.set_before
      s.hours_before    = {min: 10, max: 10}
basis_any:    [f.adbook_wallner, f.adbook_run]
basis_weight: 6
```
> The certificate went out with the noon post. At four the newspaper's business manager came
> himself, without his hat, and asked to see the entry you had cited. He read 4471 twice. Then he
> turned back four leaves, the way you had turned them, and stopped where you had stopped, and did
> not read that one aloud.
>
> He has given orders that death notices be taken only against a name and an address. The order is
> dated today. He asked whether the office would put its seal to a letter saying the fault was not
> the printing house's, and was told the office does not seal letters.
>
> In the evening post, one line on a card, unsigned, in a printer's hand:
> *You have made the counter slower. That is all you have made.*

### O2 · `out.right_word_wrong_clock` — сказано правильно, полічено від не тієї години
```
when: s.notice_verdict = o.set_before
      s.hours_before  ≠ 10
```
> The manager came, and read the entry, and put his finger on your figure and then on the book.
> *Eight in the evening*, he said. *Not ten. Ten is when I lock the forme. Anybody may lock a
> forme. The counter is where a thing is done.*
>
> He took the certificate away to have the number amended, which means it will be amended in his
> hand and not in yours, and the amended sheet will be the one that is kept. He was not unkind
> about it. He said the office had been nearer than the police.
>
> Wallner's daughter signed her contract on Saturday. The schedule of the house was accepted
> without the glasses being looked at.

### O3 · `out.called_it_a_misprint` — списано на друкарню
```
when: s.notice_verdict ∈ {o.printers_error, o.wrong_man}
   OR (s.basis contains f.correction_zeller AND s.basis does not contain f.adbook_wallner)
```
> The printing house was glad of it and said so in print. A paragraph on page 4 of the third
> impression thanks *a private office of valuation* for establishing that the notice of the 14th
> was a fault of the composing room, of the same kind as the Zeller notice, and regrets both.
>
> Wallner had it framed. He came by with it to show you, in a good humour, and left his hat on
> the desk while he unwrapped it, and the crape band was gone off the hat, and the needle holes
> were still in the felt.
>
> Entry 4471 stands in the receiving book, uncontradicted. The next one will be taken the same way.

### O4 · `out.default` — печатка стоїть, і на цьому все
```
when: {}
```
> The glasses went home in their case, valued and sealed, and the schedule was accepted by the
> notary on Saturday.
>
> On Tuesday the constable came back for the receiving book, which he had left here longer than he
> should have. He asked, since he was in the door, whether you would put your signature to the
> sheet again — the office requires the second signature beside the first, for the file. You wrote
> it. The two are not the same size. The first is the one you wrote when you were not thinking
> about it.
>
> He took the book. On the desk he had left, folded once, the *Abendblatt* of that morning. It is
> the first impression, one star. Page 3, second column, black rule, twenty-four lines.

> **Постановка.** Констебль і другий підпис приходять **у всіх чотирьох гілках** — у O1–O3
> третім абзацом, у O4 несуть кінець. Це «малий поштовх» §3 сюжету, і він не має гілок:
> що б гравець не вписав, він розписується вдруге поруч із собою.
>
> **Заборонено в усіх гілках:** повідомляти, чи Валльнер живий на ранок. Гра цього не каже
> **ніколи** — ні тут, ні в справі 10, ні у фіналі. Пошта наступного тижня приносить
> **інше** ім'я. Це і є найгірше.

---

## 9. ХИБНИЙ СЛІД

**Що спокушає.** У тому самому числі 132 надрукована **справжня одруківка з іменем**: некролог
панни A. **Zeller** вийшов під іменем **Keller**, і в третьому виданні того ж вечора стоїть
**BERICHTIGUNG** — печатне визнання друкарні. Гравець отримує це майже задарма: різницю сторінок 4
видно **оком, без лупи** (r.11), а рамка «BERICHTIGUNG» набрана великим кеглем.

Слід не декоративний, бо **пропонує повне пояснення всього**: набірник узяв не ту рукопиcну копію
з тієї самої стопки, переставив прізвище — і ось живий чоловік читає про себе. Прецедент **не
уявний, а надрукований у цьому ж номері**. Гіпотеза приходить сама, вона милосердна, і вона
знімає з гри весь жах. Гравець тримається за неї 8–10 хвилин.

**Куди веде.** До `s.notice_verdict = o.printers_error` і до гілки **O3**, де друкарня публічно
дякує бюро за зняте з неї звинувачення, а наступний запис у книзі приймуть так само.

**Чим спростовується — трьома незалежними речами, і всі три лежать по дорозі, а не збоку.**

1. **Годинами.** `f.adbook_zeller`: Целлер подано **13 травня о пів на дванадцяту ночі** — після
   закриття внутрішньої форми (десята) — тому й пішла **на сторінку 4**, у поспіх, і тому її
   **можна було виправити тієї ж ночі**. Валльнера подано **о восьмій вечора**, за дві години до
   закриття, **без поспіху**, і поставлено на сторінку 3. Одруківки роблять у поспіху, а не за дві
   години запасу.
2. **Формою.** `f.p3_identical` + `f.imprint_hours`: сторінка 3 в обох виданнях — **той самий
   набір**, до відламаного плечика в літері «e». Її не перезаливали, бо **не можна**. Якби це була
   помилка друкарні, її виправили б **так само, як Целлер**, — і не виправили. Не тому, що не
   хотіли: тому що ніхто не поскаржився.
3. **Рукою.** `f.adbook_copy`: у кишеньці лежить **рукописна копія 4471**, і в ній ім'я виписане
   повністю й **правильно**, і година смерті стоїть у копії така сама, як у друці. Одруківка
   не відтворюється в рукописі. Набірник не міг переставити те, чого в копії не було.

**Чому це чесний хибний слід.** Він гине не від зовнішнього одкровення, а від **тієї самої
книги, по яку гравець прийшов його підтверджувати**: гравець іде в `z.book.ads` шукати запис
Целлер, щоб укріпити версію друкарні, — і на сусідньому розвороті лежить 4471 з годиною.
Слід сам себе приводить на страту. І він **лишає слід у наслідках**: цитування
`f.correction_zeller` **без** `f.adbook_wallner` тягне O3 незалежно від того, що вписано в графи.

**Друга, менша спокуса (закрита навмисно):** гравіювання «BENEFIZ · LOGE IV» + афіша бенефісу
підказують, що бенефіс дано на честь клієнта, і що вся справа про театр. Підшивка афіш (§6.3)
показує ім'я бенефіціанта — **актор Йозеф Валльнер**, однофамілець. Дірку закрито в один рядок,
без сцени.

---

## 10. ДВІ ГІПОТЕЗИ І РОЗВОДЖУВАЛЬНИЙ ФАКТ

**(А) Хтось пожартував або помстився.** Некролог на живого — річ доби відома й дешева: за
чотири гульдени вісімдесят будь-хто міг прийти до віконця, продиктувати двадцять чотири рядки й
піти, бо **графи «підтвердження» в книзі прийому просто нема** (§6.2). Ворог, конкурент по
позументу, кинутий кредитор — і ось людина читає про себе, а газета нічого не порушила.
Ця гіпотеза пояснює **все**: і годину, і рукопис, і те, що ніхто не виправляв — бо скаржитися
мав би небіжчик. **(Б) Об'яву замовлено наперед, під смерть, якої ще не сталося.** Тоді година
подачі — не дотепність, а **логістика**: подати до десятої, щоб лягло на внутрішню форму, яку
вже не чіпають, і щоб у місті з ранку лежало готове. Обидві гіпотези до кінця живі, і жоден із
паперових фактів їх не розводить: година, форма, рукопис, невиправлення однаково добре
обслуговують і жарт, і план. **Розводить одна річ, і вона лежить не в цьому номері, а раніше
в книзі:** `f.adbook_run` — **чотири** такі самі об'яви, **двадцять чотири рядки**, чорна рамка,
**подані між восьмою і дев'ятою вечора**, готівкою, платник не названий, з інтервалом у два-п'ять
тижнів. Жарт — одиничний акт однієї злості проти однієї людини; він не має **сталої довжини,
сталої години й сталого способу платити**. Те, що повторюється п'ять разів однаково, — це не
злість, це **порядок роботи**. І одне з чотирьох імен гравець **вивів власною рукою на квитанції**
в цьому кабінеті.

---

## 11. СТРИБОК ДУМКИ

Гравець сам виводить, що некролог — **не повідомлення про смерть, а розпорядження про неї**:
двадцять чотири рядки, подані о восьмій вечора на сторінку, яку після десятої вже не перебереш,
роблять смерть **надрукованим фактом раніше, ніж вона стане фактом**, — і тоді бюро, яке ставить
печатки на речі мертвих, стоїть у цьому порядку не збоку, а **наступним номером**.

---

## 12. ВХІД

Чотири двері, всі діегетичні, жодної підказки. Жодна не вимагає здогаду, щоб **почати**.

1. **Клієнт кладе газету першою.** До того, як відкрити футляр, Валльнер розгортає *Abendblatt*
   на сторінці 3, розвертає до гравця й тримає:
   > "There. Read it and tell me I am not a well-preserved man for a corpse. My wife will not
   > have it in the house, so it lives in my pocket."
   Курсор на некролозі активний одразу. Це вся зав'язка: далі гравець хоче звірити.

2. **Констебль і книга прийому.** Констебль уже в кімнаті, коли Валльнер заходить, — він прийшов
   **у справі Целлер** (родина панни Целлер подала скаргу на друкарню), і **книга прийому лежить
   на столі бюро**, бо він забрав її з контори газети як доказ. Він каже:
   > "You may look at it if it amuses you. It is a book of hours and shillings. There is nothing
   > in it but hours and shillings."
   Гравець отримує доступ до головного документа справи **як до чужого паперу**, не питаного, —
   і це найкраще, що з ним могло статися.
   *Констебль лишається до кінця сцени. Другий підпис (§8) він просить, уже забираючи книгу.*

3. **Підшивка бюро.** У кімнаті з першої справи стоїть власна підшивка *Abendblatt* — гравець
   бачив її корінець дев'ять справ поспіль і жодного разу не мав приводу відкрити. Тепер число
   132 у нього **вже є на столі**, а друге — на полиці, за два кроки. Ніхто цього не пропонує.
   Дія «покласти поруч» — рух руки, не здогад.

4. **Футляр стукає.** Коли гравець уперше бере бінокль, футляр лишається на столі, і
   **кришка не сідає до кінця** — під шовком щось є. Один кадр, без репліки: кришка піднімається
   на два міліметри й зупиняється. Хто не помітив — помітить, коли покладе бінокль назад.

---

## 13. ТЕХНІЧНІ ДРІБНИЦІ, ЩОБ НЕ ПИТАТИ

- **`instance` — нове поле зони й правила.** Зона з масивом `instances: [office, client]` малює
  дві точки на одному екрані. Правило приймає `instance: any` (спрацьовує від будь-якої),
  `instance: office|client` (тільки від названої) або **`instance: both`** — накопичує
  `seen: Set` і видає факт, коли множина повна. `seen` скидається разом із `CaseState`.
  Це єдине, що ця справа додає в рушій; більше нічого нового немає.
- **Екран `SHEETS`** — не дві сцени, а **один екран із двома аркушами** і станом
  `page: 1|3|4` (гортання перегортає **обидва** синхронно). Інакше гравець порівнює різні сторінки
  і фальшиво «знаходить» різницю. Синхронне гортання — мальована анімація двох рук.
- **Затемнення другого аркуша на третину**, коли лупа на першому, — **мальований оверлей**
  (`sheets_dim_left.png` / `sheets_dim_right.png`), не `modulate` кодом. Правило 1 проєкту.
- **Відламане «e»** у `f.p3_identical` — **та сама вирізка арту** (`crop`) в обох аркушах, з
  того самого файлу. Не малювати двічі: ідентичність мусить бути ідентичністю на диску.
  У нотатнику факт показує **обидві вирізки поруч**, у рамці.
- **`tool.candle` вже розблоковано** (справа 5). У r.03 воно потрібне буквально: тьмяне третє
  відображення видно **тільки** при боковому полум'ї. Лампа дає лише два яскравих на обох
  об'єктивах — це `say_key` без факту, і це чесно (див. §6.5).
- **`tool.rake` і `tool.candle`** лишаються `exclusive_with` одне одного (справа 5).
- **Половинка контрамарки** після r.06 лишається на столі назавжди (`marque_out` не вертається)
  і **потрапляє в нотатник вирізкою арту**, як картки в справі 5.
- **Числові графи зберігають `int`.** `s.hours_before` і `s.day_in_house` — **різні** діапазони
  (0–99 і 1–31); не робити один віджет на обидві.
- **`cvals` тримає `o.*`**, ніколи англійський рядок.
- **Матчер O3 має гілку по `s.basis`** — це перший випадок у грі, коли **склад підстав** тягне
  наслідок сам, поза графами. Формат `basis contains` / `basis does not contain` уже є в справі 5
  (O3), нового коду не треба.
- **Іменa у грі — англійська проза з німецькими власними назвами** (Wieden, Abendblatt,
  Berichtigung, Vorstellung), як у справі 5. Рядкові таблиці — `case_09.en.csv`.
- **Формат збереження з `version`.** `f.*` цієї справи ще можуть перейменуватися.
