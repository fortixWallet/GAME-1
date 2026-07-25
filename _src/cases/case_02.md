# СПРАВА 2 — «СЕКРЕТЕР»
### 30 хв · акт I, друга справа · роль: **інше дієслово одразу**

Справа 1 навчила дивитися (лупа, знак, реєстр). Справа 2 навчає **міряти й розбирати**:
руки, ноніус, викрутка. Головна відмінність від справи 1 — **схованка не знаходиться, вона
обчислюється**. Гравець не натрапляє на порожнину — він доводить, що вона мусить бути, ще до
того, як її побачить. Різниця 19 мм на 486 мм оком не видна ніколи; ноніус бачить її за три
дотики.

Річ **справжня**. Це принципово: після справи 1, де підробкою було все, друга справа мусить
навчити, що чесний предмет теж має що приховувати. Підроблена тут не річ, а **тиша**.

**Що нового в поясі:** `tool.screwdriver` (викрутка). `tool.caliper` і `tool.rake` уже є зі
справи 1, але тут вони вперше **вирішують**, а не підтверджують.

**Екрани:** `FURN` (секретер у 3/4, відкидна дошка опущена) · `OPEN` (нутро писального
відділу) · `HANDS` (3D: вийнята шухляда, потім знята задня дощечка) · `DOCS` (гросбух,
довідник столярень, витяг із заповіту).

---

## 1. КЛІЄНТ

**Frau Anna Vogl**, 54 роки. Двадцять два роки економка в домі покійного пана Ф. Секретер
відписаний їй за заповітом. Прийшла сама, пішки, без візника.

**Названа потреба (не пов'язана з річчю):**
> "My son sails on Thursday. The ticket is forty-one gulden and I have nineteen. I am not
> asking you for a good price. I am asking you for a quick one."

Гравець одразу знає, **на що піде його печатка**: на квиток. І знає дедлайн — четвер.
Це працює на обидві гілки наслідків: і на «продала задешево», і на «не прийшла по гроші».

**Фізична деталь, яку кадр показує і жоден текст не коментує:**
у складках правої долоні й під нігтями правої руки — **темна воскова мастика меблевої
політури**. Ліва рука чиста. У кадрі привітання руки лежать на столі, права зверху.
Жодної репліки про це. (Економка, яка двадцять два роки натирала цей секретер, — чесне
пояснення. Друге чесне пояснення — вона натирала його **позавчора**. Гра не обирає.)

**Дві репліки на печатку.**

| умова | репліка |
|---|---|
| швидко (< 12 хв від першого дотику до речі) | "So quickly. He used to say a thing tells you everything in the first minute, and after that it only repeats itself." |
| довго (> 22 хв) | "You kept me a long while. I don't mind. Nobody has looked at it that carefully since he died." |

**Ім'я** вписує сам гравець у квитанцію (правило V6 §5.4). *Anna Vogl.*

---

## 2. ЗОНИ ПРЕДМЕТА

Вісім зон на речі. Постійні, підписані, ніякого pixel hunt. Координати 2D — **у частках
ЗОБРАЖЕННЯ**, радіус — у частках **ширини** зображення (ENGINE_SPEC §2.1). 3D — у локальних
координатах `drawer_pivot`, де довжина шухляди ≈ 2.0 одиниці.

| zone_id | де саме | вид | координати | радіус | екран / поверхня |
|---|---|---|---|---|---|
| `z.sec.escutcheon` | накладка замка відкидної дошки | img | u (0.497, 0.352) | r 0.036 | FURN / `sec_front` |
| `z.sec.drawer_front` | передня стінка нижньої довгої шухляди | img `rect` | u (0.500, 0.688) | half (0.292, 0.052) | FURN / `sec_front` |
| `z.sec.carcass_side` | передній торець лівої бічної стінки корпусу, на рівні шухляди | img | u (0.188, 0.612) | r 0.048 | FURN / `sec_front` |
| `z.sec.back_edge` | торець задньої дошки, видний у 3/4 праворуч угорі | img | u (0.856, 0.446) | r 0.042 | FURN / `sec_front` |
| `z.well.back_board` | задня дощечка писального відділу (та, що на шурупах) | img `rect` | u (0.500, 0.566) | half (0.252, 0.128) | OPEN / `sec_interior` |
| `z.void.lining` | обшивка порожнини (видна лише коли `z.well.back_board` = `open`) | img `rect` | u (0.500, 0.548) | half (0.228, 0.098) | OPEN / `sec_interior` |
| `z.void.floor` | дно порожнини (видне лише при `open`) | img `rect` | u (0.500, 0.652) | half (0.214, 0.038) | OPEN / `sec_interior` |
| `z.drawer.underside` | спід дна нижньої шухляди (тавро столярні) | node3d | p (0.00, −0.41, 0.00) · n (0, −1, 0) | r 0.30 · `facing_min` 0.14 | HANDS / `drawer_pivot` |

**Стани зон** (`sets_zone`, не буліни):
`z.well.back_board`: `default` → `unscrewed` (шурупи викручені, дощечка ще на місці) → `open`
(дощечку знято, порожнина видна). `z.void.lining` і `z.void.floor` пікаються **тільки** при
`z.well.back_board == open` — це гарантується правилом `zone_state`, не окремим прапорцем.

**Паперові зони** (окремо, бо це не предмет):

| zone_id | що це | вид | координати | радіус | екран / поверхня |
|---|---|---|---|---|---|
| `z.doc.daybook_intake` | рядок прийому в гросбусі бюро | img `rect` | u (0.508, 0.437) | half (0.360, 0.022) | DOCS / `daybook_page` |
| `z.doc.register_gruber` | стаття «GRUBER, M.» у довіднику столярень | img `rect` | u (0.312, 0.588) | half (0.230, 0.030) | DOCS / `register_page` |
| `z.doc.ref_screws` | розворот «Screws» у технічному довіднику | img `rect` | u (0.700, 0.500) | half (0.240, 0.330) | DOCS / `register_page` |
| `z.doc.label_pigeonhole` | ярлик, підклеєний у стінці правого відсіку | img | u (0.786, 0.398) | r 0.040 | OPEN / `sec_interior` |

---

## 3. ПРАВИЛА

`requires` = `needs` у ENGINE_SPEC. `note` — англійський текст **спостереження**, який лягає
в нотатник і промовляється рядком під курсором. Висновку в ньому нема ніде.

| zone_id | tool | requires | fact_id | note (EN, спостереження) | sets_state |
|---|---|---|---|---|---|
| `z.sec.drawer_front` | `tool.hand` (click) | — | *(факту нема)* | "Rapped along the front, the drawer answers with a tone at the left and at the right, and flat in the middle third." | `flags.knock_heard = true`, `say.flat_middle` |
| `z.sec.escutcheon` | `tool.loupe` | — | `f.escutcheon_bright` | "Four scratches run from the keyhole to the lower left. Their metal is bright; the metal around them is brown." | — |
| `z.doc.daybook_intake` | `*` (click) | — | `f.daybook_locksmith` | "Intake, the 3rd: 'Secretaire, walnut, from the estate of Herr F. Opened on arrival by Krenn, our locksmith — lock seized. House keys surrendered with the piece.'" | — |
| `z.drawer.underside` | `tool.rake` | — | `f.stamp_gruber` | "Burnt into the drawer bottom, low and to the left: M. GRUBER · WIEN. Beside it, in chalk, a number: 214." | — |
| `z.doc.register_gruber` | `*` (click) | `f.stamp_gruber` | `f.reg_gruber_1822_1841` | "GRUBER, Michael. Möbeltischler, Wien, Gumpendorf. Workshop stamp in use 1822–1841. Numbered his carcasses in chalk." | — |
| `z.sec.carcass_side` | `tool.caliper` (click) | `flags.knock_heard` | `f.outer_depth` | "Fixed jaw on the front edge of the side, sliding jaw on the outer face of the back board: 486.0 mm." | — |
| `z.sec.back_edge` | `tool.caliper` (click) | `f.outer_depth` | `f.back_thickness` | "The back board, measured at its exposed edge: 12.0 mm." | — |
| `z.well.back_board` | `tool.caliper` (click) | `f.outer_depth` | `f.inner_depth` | "Fixed jaw on the same front edge, sliding jaw on the face of the well's back board: 455.0 mm." | — |
| `z.well.back_board` | `tool.eye` (dwell 0.6) | — | `f.board_screwed` | "This board is held by four screws. Everywhere else the carcass is pinned with wooden dowels and square nails." | — |
| `z.well.back_board` | `tool.loupe` (dwell 1.0) | `f.board_screwed` | `f.screw_points` | "The screws run to a sharp point. The thread is even from head to tip. Every slot passes through the centre of the head." | — |
| `z.well.back_board` | `tool.loupe` (dwell 1.4) | `f.screw_points` | `f.slot_burr` | "Three slots are bright and torn along one edge; the wax around those three heads is cracked in a ring. The fourth head stands a hair proud of the board." | — |
| `z.doc.ref_screws` | `*` (click) | `f.screw_points` | `f.ref_screw_points` | "Hand-made screws: blunt end, filed thread of uneven pitch, slot off centre, a hole must be bored first. Pointed screws that cut their own way: patented 1846, made in quantity in Birmingham from 1854." | — |
| `z.well.back_board` | `tool.screwdriver` (click, confirm) | `f.board_screwed` | `f.board_lifted` | "The four screws come out. Behind the board there is a recess, lined, and no dust on its front lip." | `z.well.back_board → open` |
| `z.void.lining` | `tool.loupe` (dwell 0.8) | `f.board_lifted` | `f.lining_fleck` | "End grain of the lining: close, pale, crossed by fine bright flecks. End grain of the carcass boards beside it: coarse, resinous, no flecks." | — |
| `z.void.floor` | `tool.rake` (dwell 1.0) | `f.board_lifted` | `f.dust_rectangle` | "Under a low light the floor is grey with settled dust, except one rectangle, 148 × 96 mm, clean to the wood. Its edges are sharp." | — |
| `z.doc.label_pigeonhole` | `tool.loupe` | — | `f.trade_label` | "A paper label, lifted at one corner: 'J. HALBERT — Möbel & Antiquitäten, Wien I. Repaired and fitted, 1867.'" | — |

**Гейт входу в порожнину.** Правило викрутки має `confirm_key: "confirm.unscrew"` —
мальоване вікно: *"Take a screwdriver to a client's furniture?"* / *Do it* · *Leave it*.
Відмова не карається, до дії можна повернутись.

**Дві дороги до `f.inner_depth`.** Ноніус по дощечці (вище) і ноніус по дну **вийнятої
шухляди** (`z.drawer.underside`, `tool.caliper`, дає 443.0 + шухляда стоїть на упорі 12 мм
від дощечки → те саме 455.0). Обидві дороги пишуть **той самий** `fact_id`. Один факт — один
id (V4 §8, пастка 7.3).

---

## 4. ФАКТИ

14 фактів. `cite` — як рядок звучить у графі «на підставі».

| fact_id | text (EN, у нотатнику) | cite | tag |
|---|---|---|---|
| `f.escutcheon_bright` | "Four scratches by the keyhole; their metal is bright, the metal around them brown." | "bright scratches at the lock" | `lock` · вага 1 |
| `f.daybook_locksmith` | "Day-book, the 3rd: opened on arrival by Krenn, the bureau's locksmith. House keys surrendered with the piece." | "our own locksmith opened it on the 3rd" | `papers` · вага 2 |
| `f.stamp_gruber` | "Burnt into the drawer bottom: M. GRUBER · WIEN. Chalk number 214 beside it." | "the workshop stamp under the drawer" | `body` · вага 2 |
| `f.reg_gruber_1822_1841` | "Register: Gruber, Michael, Möbeltischler, Wien-Gumpendorf. Stamp in use 1822–1841." | "the register dates the stamp to 1822–1841" | `books` · вага 2 |
| `f.outer_depth` | "Front edge of the side to the outer face of the back board: 486.0 mm." | "486.0 mm outside" | `measure` · вага 1 |
| `f.back_thickness` | "The back board at its edge: 12.0 mm." | "a back board of 12.0 mm" | `measure` · вага 1 |
| `f.inner_depth` | "Front edge of the side to the face of the well's back board: 455.0 mm." | "455.0 mm inside" | `measure` · вага 1 |
| `f.board_screwed` | "Four screws hold the well's back board. The rest of the carcass is dowelled and square-nailed." | "screws where the rest of the carcass is dowelled" | `body` · вага 2 |
| `f.screw_points` | "The screws end in a point; the thread is even head to tip; the slots run through the centre." | "pointed screws with even thread" | `body` · вага 3 |
| `f.ref_screw_points` | "Reference: blunt, hand-filed screws before 1846; pointed self-starting screws patented 1846, in quantity from 1854." | "the screw book puts that screw after 1854" | `books` · вага 3 |
| `f.slot_burr` | "Three slots bright and torn at one edge; the wax around those heads cracked in a ring. The fourth head stands proud." | "three heads turned, the wax broken around them" | `body` · вага 3 |
| `f.board_lifted` | "Behind the board there is a recess, lined, with no dust on its front lip." | "the recess behind the board" | `body` · вага 2 |
| `f.lining_fleck` | "Lining end grain: close, pale, fine bright flecks. Carcass end grain beside it: coarse, resinous, no flecks." | "the lining is not the wood of the carcass" | `body` · вага 3 |
| `f.dust_rectangle` | "Dust on the floor of the recess everywhere but one rectangle, 148 × 96 mm, clean to the wood, sharp at the edges." | "a clean rectangle in the dust, 148 × 96" | `body` · вага 3 |
| `f.trade_label` | "Paper label in the right pigeonhole: 'J. HALBERT — Möbel & Antiquitäten, Wien I. Repaired and fitted, 1867.'" | "the dealer's label of 1867" | `papers` · вага 2 |

*(Рахунок: 15 рядків, з них `f.board_lifted` — технічний факт-ключ, що відмикає зони
порожнини; у нотатнику він показується, у графі «на підставі» доступний. Змістовних фактів
для гравця — 14.)*

---

## 5. ДОВІДКОВІ ТАБЛИЦІ

Три розвороти, які гравець читає сам. Значення справжні; де метод має межу — межа написана.

### 5.1. Шурупи по дереву (розворот `ref_screws`)

| період | вигляд | як упізнати |
|---|---|---|
| до ~1760 | кований, головка бита молотком, шліц пропиляний вручну | різьба нерівна, кінець **тупий**, отвір мусить бути висвердлений |
| ~1760 – 1846 | заготовка точена на верстаті, різьба нарізана різцем | кінець досі **тупий**, крок різьби «гуляє», шліц часто **не по центру** |
| з **1846** | патент на **загострений** шуруп (США), який сам іде в дерево | вістря конічне, різьба рівна від головки до кінчика |
| з **1854** | масове виробництво в Британії (Nettlefold & Chamberlain, Birmingham, за американською ліцензією) | шліц строго по центру, головки однакові як краплі |

**Межа методу, написана в самому довіднику:** тупі шурупи не зникли 1846 року — старі запаси
доходили десятиліттями. Тому загострений шуруп дає **«не раніше ніж»**, і ніколи «саме тоді».
Це та сама логіка, що клеймо у справі 1.

### 5.2. Породи дерева по торцю (розворот `ref_wood`)

| порода | торець | густина, г/см³ | де в цій речі |
|---|---|---|---|
| ялина / смерека (*Picea abies*) | смоляні ходи, різкий перехід річних шарів, серцевинних променів не видно | 0.43–0.47 | **корпус, дно шухляд** — стандарт віденського корпусу |
| сосна (*Pinus sylvestris*) | смоляні ходи більші, ядро темніше | 0.49–0.52 | — |
| бук (*Fagus sylvatica*) | дрібні пори рівномірно, **широкі блискучі промені — «фleck»** упоперек торця | 0.68–0.72 | **обшивка порожнини** |
| дуб (*Quercus*) | кільцепоровий, промені **дуже широкі**, видні без лупи | 0.65–0.75 | — |
| горіх (*Juglans regia*) | напівкільцепоровий, тон теплий | 0.62–0.65 | **фанерування (шпон) фасадів** |
| вишня (*Prunus avium*) | дрібнопориста, рівна | 0.56–0.60 | альтернатива горіху в бідермаєрі |

Віденський бідермаєр 1820-х: **корпус хвойний, фасади фанеровані горіхом або вишнею**. Бук у
корпусі — це вже майстерня, яка бере те, що дешеве й міцне, а не те, що на очах. Бук у
**прихованій** обшивці — нормальне рішення пізнішого столяра.

### 5.3. Міри (розворот `ref_measures`)

| міра | у міліметрах |
|---|---|
| англійський дюйм | **25.40** |
| **3/4 англійського дюйма** | **19.05** |
| віденський цоль (Wiener Zoll) | 26.34 |
| 3/4 віденського цоля | 19.76 |
| віденський фус (12 цолів) | 316.10 |
| метрична система в Австро-Угорщині | обов'язкова **з 1 січня 1876** |

Порожнина в **19.0 мм** — це 3/4 англійського дюйма з точністю до соті. Це **не** кругла
віденська міра і **не** кругла метрична (було б 20). Колірна деталь, не доказ: австрійські
столярні цілком купували англійські шурупи й англійський інструмент. У довіднику це подано
рівно так — як збіг, вартий уваги, а не як висновок. *(Див. §13: тут я сам обережний.)*

### 5.4. Реєстр столярень (розворот `register_page`, фрагмент)

| майстерня | місто | тавро вживалось | нотатка |
|---|---|---|---|
| DANHAUSER, Josef | Wien | 1804–1838 | *(реальна історична фабрика — стоїть у реєстрі як тло)* |
| **GRUBER, Michael** | Wien-Gumpendorf | **1822–1841** | нумерував корпуси крейдою · **вигадана для гри** |
| HALBERT, J. | Wien I | торгівець, не столяр, з 1861 | «ремонт і доробка» — ярлики на чужих речах |

> **Чесно:** Гру не можна ставити на реальну фірму як на автора зміненої речі. Danhauser
> лишається згадкою в реєстрі (він справжній, 1804–1838), а наш секретер зроблено **вигаданим
> Ґрубером** — датування, конструкція й практика нумерації крейдою при цьому історично точні.

---

## 6. АТЕСТАТ

Шість граф. Одна числова. Гейти діегетичні: закрита графа показує в дужках, **чого бракує**,
а не що вписати (ENGINE_SPEC §5.1).

### Графа 1 — `s.piece`
**Префікс:** *"The piece is —"*
**Тип:** список
**Гейт:** `f.stamp_gruber` **і** `f.reg_gruber_1822_1841`
**Підказка при закритому гейті:** *"look under the drawer, then in the register"*
**Варіанти:**
- `o.vienna_1820s` — "a Viennese fall-front secretaire of the 1820s, walnut on softwood, by the workshop whose stamp it carries"
- `o.later_copy` — "a later copy in the Viennese manner"
- `o.marriage` — "two pieces married into one"

### Графа 2 — `s.void_mm`
**Префікс:** *"Depth measured outside, less the boards and less the depth measured inside, in millimetres —"*
**Тип:** **ЧИСЛО** · `digits: 2` · `min: 10` · `max: 99` · списку нема, валідації нема
**Гейт:** `f.outer_depth` **і** `f.back_thickness` **і** `f.inner_depth`
**Підказка:** *"three readings, and the arithmetic is yours"*
**Правильно:** **19** (486.0 − 12.0 − 455.0 = 19.0)
**Прийнятний допуск у наслідках:** 18–20 (ноніус чесно має похибку)

### Графа 3 — `s.void_origin`
**Префікс:** *"The recess was cut —"*
**Тип:** список
**Гейт:** `f.board_screwed` **і** `f.screw_points` **і** `f.ref_screw_points` **і** `f.lining_fleck`
**Підказка:** *"whoever cut it left his screws and his timber"*
**Варіанти:**
- `o.with_carcass` — "with the carcass, by the workshop that made it"
- `o.trade_later` — "later, in a dealer's workshop, as a selling feature"
- `o.private_later` — "later, by a hand working alone, in the house"

### Графа 4 — `s.last_opened`
**Префікс:** *"The recess was last opened —"*
**Тип:** список
**Гейт:** `f.dust_rectangle` **і** `f.slot_burr`
**Підказка:** *"dust keeps time better than people do"*
**Варіанти:**
- `o.never` — "not since it was fitted"
- `o.long_ago` — "years ago"
- `o.within_fortnight` — "within the fortnight"

### Графа 5 — `s.lock_marks`
**Префікс:** *"The marks on the lock are —"*
**Тип:** список
**Гейт:** `f.escutcheon_bright` (відкривається рано — і саме тому спокушає)
**Варіанти:**
- `o.forced` — "the work of someone who had no key"
- `o.our_locksmith` — "the work of this bureau, on the 3rd"
- `o.old_wear` — "the wear of forty years of use"

### Графа 6 — `s.basis`
**Префікс:** *"On the strength of —"*
**Тип:** **перетягування фактів** з нотатника · `min_count: 2` · `max_count: 4`
**Гейт:** `needs_slot: [s.void_origin, s.last_opened]`
**`clears_on`:** `[s.void_origin, s.last_opened]`

---

## 7. НАСЛІДКИ (`OUTCOMES`)

Перший збіг виграє; `out.default` завжди останній.

### 7.1. `out.void_named` — прочитано правильно
**Умова:** `s.void_origin = o.private_later` · `s.last_opened = o.within_fortnight` ·
`s.lock_marks = o.our_locksmith` · `s.void_mm` у [18, 20] ·
`basis_any: [f.dust_rectangle, f.slot_burr]` · `basis_weight ≥ 5`

> **Morning.** The secretaire went out at nine, to a dealer in the Wollzeile, at the figure
> you set. At eleven a boy brought back the receipt, unsigned.
> Frau Vogl did not come for the money.
> The shipping office holds one ticket for Thursday, paid in full, in the name of her son.
> It was paid on the 4th — the day after the keys were given up, and three days before she
> came to you.
> *(Гросбух: «Seals set: N». Ні коментаря, ні кольору.)*

### 7.2. `out.locksmith_broken` — гравець узяв хибний слід
**Умова:** `s.lock_marks = o.forced`

> **Morning.** A constable called at eight and took the piece to the station as evidence of a
> forced entry. Krenn the locksmith was sent for at nine and kept until two.
> He has worked for this bureau eleven years. The note says he did not argue.
> The bureau's contract with him is on the desk, unsigned for renewal.
> Frau Vogl's son sailed. She was not on the quay.

### 7.3. `out.sold_short` — порожнину не полічено
**Умова:** `s.void_origin = o.with_carcass` **або** `s.void_mm` ≤ 5 **або** графа 3 порожня
при запечатаній рештою

> **Morning.** Sold at your figure: sixty gulden, walnut, sound, no faults recorded.
> A fortnight later the Wollzeile catalogue lists it: *"Biedermeier secretaire, Vienna,
> c. 1825, with concealed compartment behind the writing well — 260 gulden."*
> Frau Vogl's rent was paid to the end of the month.

### 7.4. `out.trade_fitting` — обрано гіпотезу Б
**Умова:** `s.void_origin = o.trade_later` · `basis_any: [f.trade_label]`

> **Morning.** Halbert's shop answered the enquiry by return: they repaired the piece in 1867,
> a hinge and two feet, and they fit no compartments — "we sell furniture, not conjuring."
> The letter is filed. The certificate stands as written.
> Frau Vogl came for the money at four, thanked you, and asked whether the gentleman who
> bought it would be told about the little door at the back. You had not written about a door.

### 7.5. `out.default`
> **Morning.** The piece went out. The day-book has a line for it. Nothing else came.

---

## 8. ХИБНИЙ СЛІД

**Що спокушає.** `f.escutcheon_bright` — чотири свіжі, ще не потемнілі подряпини від
свердловини замка вниз-уліво, тобто рівно там, де їх лишає той, хто підважує язичок відмичкою
або викруткою. Це перше, що гравець бачить на екрані `FURN`, воно на самому видному місці, і
воно **справді свіже**. Графа `s.lock_marks` відкривається одразу, ще до будь-якого обміру, —
і бланк люб'язно пропонує варіант "someone who had no key".

**Куди веде.** У версію «дім обікрали, злодій дістався схованки, порожній прямокутник у пилюці
— слід крадіжки». Ця версія пояснює **все**: і подряпини, і зняту дощечку, і чистий прямокутник.
Вона програшна не тому, що безглузда, а тому, що **надто добра**.

**Чим спростовується.** Один рядок гросбуха бюро, `f.daybook_locksmith`: річ прийняли **3-го**
і **власний слюсар бюро Кренн відкрив її на прийманні** — замок заїв. Подряпини свіжі, бо їм
шість днів, і зробило їх **бюро**. Той самий рядок дає другу річ, яка потім б'є: **ключі від
дому здано разом із річчю**. Тобто до 3-го числа ключі були в руках.

**Ціна.** Хибний слід не декоративний: він має власну графу (5) і власний наслідок (7.2), у
якому чесна людина втрачає роботу через підпис гравця. Гросбух лежить на екрані `DOCS` від
першої секунди справи — його ніхто не ховає. Гравець програє не на браку доступу, а на
поспіху.

---

## 9. ДВІ ГІПОТЕЗИ І РОЗВОДЖУВАЛЬНИЙ ФАКТ

**(А)** Порожнину врізав **приватний** пізніший господар: буковою обшивкою, англійськими
машинними шурупами, десь через сорок років після Ґрубера, і вміст із неї винесли днями.
**(Б)** Порожнину влаштувала **торгова майстерня** — Гальберт, ярлик 1867 року: додати старим
меблям «таємну шухляду» було стандартним прийомом торгівців XIX ст. і піднімало ціну; чистий
прямокутник тоді — слід картонки з ціною або пакувального бруска, і йому теж тридцять років.
Обидві гіпотези пояснюють і бук, і шурупи, і навіть пил — доти, доки гравець не подивиться
лупою на **самі шліци**. Розводить `f.slot_burr`: три шліци **блискучі й задерті**, а восковий
наліт навколо трьох головок **тріснув кільцем** — дощечку піднімали й прикручували назад, і
віск не встиг затягтись; четверта головка не дотягнута. Торгова «таємна шухляда» — це
рекламний трюк: її роблять **такою, що відкривається рукою і показується покупцеві**.
Прикручена чотирма шурупами дощечка не показується нікому — а її все одно **відкрили**, і
не тридцять років тому.

---

## 10. СТРИБОК ДУМКИ

Схованка на сорок років молодша за меблі — отже те, що в ній лежало, поклала не рука, яка
робила річ, а рука, яка жила в домі й мала від нього ключ; і вийняла те саме — та сама рука,
у ті кілька днів, коли ключі ще були в неї.

---

## 11. ВХІД

**Три двері, жодного натяку від інтерфейсу.**

1. **Звук.** Клієнтка, ставлячи річ, спирається на нижню шухляду, і та **відповідає глухо**.
   Це чути в самій сцені привітання, до будь-якого інструменту. Перший же удар рукою
   (`tool.hand` по `z.sec.drawer_front`) дає рядок: *"…a tone at the left and at the right,
   and flat in the middle third."* Факту нема — є прапорець `knock_heard`, який **відмикає
   правило ноніуса** на корпусі. Тобто гра не каже «міряй», гра робить обмір можливим рівно
   тоді, коли гравець уже здивувався.

2. **Записка попередника.** У довіднику столярень, закладкою на віденському розвороті, —
   смужка паперу його почерком:
   > *"A joiner is paid for wood, and hides air."*

   Ні пояснення, ні підпису. (Це та сама рука, що заповнила атестат у день 1.)

3. **Репліка клієнтки, коли гравець уперше відкриває відкидну дошку:**
   > "He wrote his letters standing up. He said a man who sits at a desk tells it things."

   Жодного натяку на схованку. Але це єдина фраза за всю справу, у якій вона говорить про
   покійного в теперішньому часі речі, а не минулому людини.

---

## 12. ТЕХНІЧНА ПРИМІТКА ДЛЯ РЕАЛІЗАЦІЇ

- Справа пишеться **одним файлом** `data/case_02.gd` (`const ZONES / RULES / FACTS / SLOTS /
  OUTCOMES`), без жодного рядка в `core/*` і `main.gd` — це критерій приймання §8.1
  ENGINE_SPEC. Єдине, що додається поза даними, — `data/tools/screwdriver.tres` (інстанс
  ToolDef, не код).
- `tool.screwdriver`: `verb = APPLY`, `on_click = true`, `radius = 0.030`, `uses_max = -1`,
  `needs_hands = false`, `on_papers = false`, `confirm` — на правилі, не на інструменті.
- `tool.caliper`: `verb = MEASURE`, `radius = 0.012` (гострий — вимагає точності),
  `on_click = true`.
- Стратиграфії в цій справі **нема** (вона у справі 8). «Загадка на відсутність» за V4 §1.5
  тут виконана `f.dust_rectangle`: гравець мусить помітити, чого **нема** в пилюці.
- Три звірки з довідниками: реєстр столярень · розворот шурупів · розворот порід дерева.
  Четверта (міри) — необов'язкова, для тих, хто піде далі.
- Числова графа `s.void_mm` **не валідується**. 19 і 41 виглядають однаково до самого ранку.
- `f.board_lifted` мусить лягати в `state` через `add_fact`, а стан зони — через `sets_zone`
  тим самим правилом. Ніяких окремих булінів «порожнина відкрита».

---

## 13. ДЕ Я САМ СУМНІВАЮСЯ (чесно, за правилом 9 CLAUDE.md)

1. **Дата загострених шурупів.** У літературі кочують три дати: 1846 (американський патент),
   1854 (масове британське виробництво Nettlefolds за ліцензією), 1856 (патент Каллена Віппла
   на машину). Я взяв **1846 як патент і 1854 як реальну доступність у Європі**, і написав у
   довіднику межу методу прямо: старі тупі шурупи доживали десятиліттями, тому це
   **«не раніше ніж»**. Якщо історик схоче однієї дати — брати **1854**, бо гра про Відень,
   а не про Провіденс.
2. **19 мм = 3/4 англійського дюйма.** Арифметика точна (19.05), але **висновок про
   англійський інструмент — м'який**: віденські майстерні купували англійські шурупи вільно, а
   з 1876 працювали в метричній. Тому в грі це подано як колір у довіднику мір, а **не** як
   доказ, і жодна графа атестата на нього не спирається. Якщо ми захочемо зробити з цього
   доказ — потрібна ще одна незалежна англійська деталь у порожнині (наприклад, різьба
   шурупа під британський калібр), і тоді це вже друга справа, не ця.
3. **Бук проти ялини на око.** Промені бука видні лупою на **свіжому торці** впевнено, на
   старому засмальцьованому — гірше. Тому правило `f.lining_fleck` дає лупа на **торець
   обшивки в місці різу**, який щойно відкрився з-під дощечки й тому чистий. Це в тексті
   ноти є («End grain of the lining»); художник мусить намалювати саме торець, а не пласть,
   інакше факт стане неправдою.
4. **Чи витримає економка драматургію.** Наслідок 7.1 не називає її злодійкою — і не мусить:
   вона винесла з дому свого паперу, і гра ніде не каже, чи мала право. Це навмисно. Але
   якщо на плейтесті казуал прочитає 7.1 як «я її здав» — текст переписати ще холодніше, до
   самих фактів судноплавної контори.
