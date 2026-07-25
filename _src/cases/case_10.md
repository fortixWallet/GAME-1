# СПРАВА 10 — «РІЧ №6»

**Хронометраж:** 50 хв · **найважча справа гри** · **ХВИЛЯ 3**
**Роль в акті:** остання справа перед фіналом. Дев'ять справ гравець учився вірити приладу —
тут прилад **справний і дає нуль**. Це єдине місце в грі, де гра не має відповіді, і саме тому
атестат вимагає від гравця вписати число **власною рукою двічі**. Справа не викриває злочинця:
вона змушує гравця **створити запис**, якого не існувало, і зрозуміти, що запис і є дія.

**Нових інструментів НЕ вводиться.** Лупа, косе світло, рука, штангенциркуль, ваги — усе
з попередніх справ. Ваги вживаються тим самим правилом, що у справах 1 і 8; змінилась лише
одна річ на шальці. **Це критично:** якщо гравець хоч раз мав підозру, що ваги брешуть,
уся справа розсипається. Тому тут є **контрольне зважування** (§3, `r.control_air`/`r.control_water`),
і воно чесне.

**Наскрізні числа справи:**

| що | значення | звідки |
|---|---|---|
| вага речі в повітрі | **1 429 г** | ваги, `z.rig.pan` |
| вага речі у воді | **1 429 г** | ті самі ваги, `z.rig.jar` |
| габарит речі | **154 × 108 × 72 мм** = **1 197.5 см³** | штангенциркуль |
| витиснена вода | **0 см³** / підйом рівня **0.0 мм** | ваги і рівень, дві незалежні дороги |
| контроль: латунний еталон | **500 г** → **441 г** у воді (втрата 59 г, п.в. 8.47) | той самий важіль, той самий слоїк |
| номер, який гравець присвоює сам | **6** | звільняється після розбору дубля |

> **1 429** — це число печаток попередника з гросбуха (V6 §3, віддано після справи 4).
> Тут воно повертається як вага в грамах. Гра **не коментує це жодним рядком**.
> Якщо Віктор вирішить, що це занадто акуратно — міняється на **1 462 г** правкою одного
> рядка даних; на механіку не впливає. Моя рекомендація: лишити.

---

## 1. КЛІЄНТ

**Удова з третьої справи.** Приходить **дякувати** — і це єдина причина її візиту.
Вона не має стосунку до речі №6 і ніколи про неї не дізнається.

> Якщо у справі 3 гравець вирішив на користь небожа — вона приходить **однаково**, з тією самою
> вдячністю, бо годинник їй віддав небіж. Змінюється **одне речення** (варіант `b` нижче).
> Другого портрета не треба; це навмисно.

**Frau Katharina Lorenz**, вдова, шістдесят один рік.

- **Названа потреба, не пов'язана з річчю:** «My sister has taken me in, at Znaim. The carrier
  comes Thursday for the furniture and wants half of it in advance. I have the half.»
- **Фізична деталь, яку кадр показує і жоден текст не коментує:** обидві руки закоричнені
  до другого суглоба — горіховою протравою. Вона сама фарбувала своє сіре в чорне.
  Ні вона, ні гравець, ні гра про це не скажуть нічого.
- **Її діло — клерикальне, на дві хвилини:** їй потрібна **завірена копія рядка інвентарної
  книги** про годинник — для суду в Знаймі. Саме заради цього гравець відкриває книгу.
  **Це і є вхід у справу** (§12).
- **Дві репліки на печатку** (на печатку по **її** копії, не по атестату №6):
  - **швидко** (< 90 с від відкриття книги): «You did not look it up. You knew the page.»
    …пауза… «He would have liked that in a man.»
  - **довго** (> 5 хв): «Take your time, sir. I have got out of the way of hurrying.»
  - **варіант `b`** (справу 3 вирішено на користь небожа), додається до обох:
    «The boy brought it to me himself. He did not have to.»

**Тепло як жах:** вона єдина людина в грі, яка дякує гравцеві за печатку. Її сцена
закінчується **до** того, як гравець розуміє, що з книгою щось не так. Далі він сам, у порожній
кімнаті, до кінця дня.

---

## 2. ЗОНИ

Одиниця 3D-моделі: **1.0 = 40 мм**. Габарит релікварія 3.85 × 1.80 × 2.70 од.
(154 × 72 × 108 мм; x — довжина, y — висота, z — глибина). Якір — `relic_pivot` у центрі.
2D-зони — у частках **ЗОБРАЖЕННЯ**, радіус у частках ширини зображення (ENGINE_SPEC §1.2).

### 2.1. Робочі зони (9)

| zone_id | де саме | kind | екран / surface | координати | r / half | стани |
|---|---|---|---|---|---|---|
| `z.relic.top` | верхня грань, посередині — врізаний рядок капітелей | `node3d` | HANDS / `relic_pivot` | p (0.00, 0.90, 0.00) · n (0,1,0) | r 1.10 · facing_min 0.18 | `default` → `open` |
| `z.relic.side` | довга бічна грань на рівні, де мав би бути шов кришки | `node3d` | HANDS / `relic_pivot` | p (0.00, 0.00, −1.35) · n (0,0,−1) | r 0.95 · facing_min 0.15 | — |
| `z.relic.under` | спід — місце, де на будь-якій речі стоїть клеймо | `node3d` | HANDS / `relic_pivot` | p (0.00, −0.90, 0.00) · n (0,−1,0) | r 1.10 · facing_min 0.14 | — |
| `z.relic.inside` | нутро; існує **лише** у стані `open` зони `z.relic.top` | `node3d` | HANDS / `relic_pivot` | p (0.00, 0.30, 0.00) · n (0,1,0) | r 1.00 · facing_min 0.20 | — |
| `z.shelf.slot6` | шоста згортка на полиці утриманих речей (крайня права) | `img` | SHELF / `shelf_retained` | u (0.792, 0.446) | r 0.072 | `on_shelf` → `taken` |
| `z.shelf.tag_gun` | лляна бирка на згортці з рушницею (третя зліва) | `img` | SHELF / `shelf_retained` | u (0.404, 0.452) | r 0.038 | — |
| `z.rig.pan` | ліва шалька ваг (зважування в повітрі) | `img` | DESK / `desk_balance` | u (0.352, 0.470) | r 0.090 | — |
| `z.rig.jar` | скляний слоїк під правим плечем коромисла; риска на склі | `img` | DESK / `desk_balance` | u (0.648, 0.532) · `shape: rect` | half (0.086, 0.128) | `empty` → `piece_in` → `standard_in` |
| `z.rig.standard` | латунний еталон 500 г у гнізді футляра | `img` | DESK / `desk_balance` | u (0.196, 0.612) | r 0.040 | — |

**Про `z.rig.jar`.** Це **одна** зона з трьома станами, а не три зони. Стан міняється правилом
підвішування (`r.hang_piece`, `r.hang_standard`, `r.jar_clear`). Ваги і штангенциркуль читають
її по-різному — тому обидва інструменти в `tools`.

**Про `z.relic.inside`.** Зона не має власного арту до ночі: у `_sync_view()` вона просто
не пікається, поки `z.relic.top != open`. Окремої зони «щілина» нема, бо щілини нема (§3, `f.no_seam`).

### 2.2. Зони нічної послідовності (2, дій без фактів)

| zone_id | де | kind | surface | u | r | стани |
|---|---|---|---|---|---|---|
| `z.room.lamp` | гвинт гнота настільної лампи | `img` | HUB / `hub_evening` | (0.362, 0.520) | 0.058 | `lit` → `out` |
| `z.room.curtain` | шнур штори, правий бік вікна | `img` | HUB / `hub_night` | (0.845, 0.360) | 0.110 | `open` → `drawn` |

### 2.3. Довідкові зони (6, у бюджет не входять)

| zone_id | де | kind | surface | u | r / half |
|---|---|---|---|---|---|
| `z.book.inventory` | розворот інвентарної книги, шість рядків | `img` | BOOKS / `inventory_spread` | (0.500, 0.470) · `rect` | half (0.400, 0.210) |
| `z.book.inv_dates` | сама колонка дат надходження | `img` | BOOKS / `inventory_spread` | (0.276, 0.470) · `rect` | half (0.052, 0.200) |
| `z.book.units` | сторінка «Maße und Gewichte» — віденські ваги й метрична реформа | `img` | BOOKS / `handbook_units` | (0.330, 0.520) | 0.150 |
| `z.book.gravities` | сторінка питомих ваг + метод гідростатичного зважування | `img` | BOOKS / `handbook_gravities` | (0.640, 0.500) · `rect` | half (0.240, 0.280) |
| `z.book.inscriptions` | перелік написів на речах, розділ «Латинські» | `img` | BOOKS / `inscription_list` | (0.700, 0.386) | 0.120 |
| `z.folder.blank` | тека без номера, внутрішній бік обкладинки | `img` | DOCS / `folder_blank_spread` | (0.700, 0.500) · `rect` | half (0.230, 0.240) |

**Бюджет чесно:** 9 робочих зон замість канонічних 6–8. Дев'ята — `z.rig.standard`, контрольне
зважування. Її **не можна різати**: без неї вся справа зводиться до «прилад зламався»,
і гравець має рацію. Дев'ята зона тут дорожча за решту вісім.

---

## 3. ПРАВИЛА (зона × інструмент → факт)

`note` — це `say_key`: рядок під рукою, який лягає в нотатник. **Жоден note не містить висновку.**
Порядок у таблиці — приблизний порядок гри, але жодне правило не залежить від порядку,
крім явних `requires`.

### 3.1. Книга, бирки, полиця (перші ~20 хв; тут живе хибний слід)

| zone_id | tool | requires | fact_id | note (EN, спостереження) | sets_state |
|---|---|---|---|---|---|
| `z.book.inventory` | `*` (`on_click`) | — | — | say: "Register of pieces retained. Printed at the head: *numbers are given in the order of the date of receipt*. Six lines are written in. The last of them is in a browner ink than the five above it." — **факту не дає: це не спостереження, це відкрита книга** | `sets_flag: {fl.inv_read: true}` |
| `z.book.inv_dates` | `tool.loupe` \| `tool.eye` (`dwell 0.8`) | `fl.inv_read` | `f.inv_inversion` | "Read straight down the dates, the numbers stand 1, 2, 3, 6, 4, 5. Two lines carry the same date: the 9th of November 1868." | — |
| `z.book.inventory` | `tool.loupe` (`dwell 1.0`) | `f.inv_inversion` | `f.inv_gun_weights` | "Line 3: a fowling piece, damascus barrel, Bräuer, J. — 5 Pfd 9 Lth. Line 6: a fowling piece, damascus, Bräuer, J. — 2 958 g." | — |
| `z.book.units` | `*` (`on_click`) | — | — | *(довідка; факту не дає — див. §5.1)* | `sets_flag: {fl.units_known: true}` |
| `z.shelf.tag_gun` | `tool.hand` (`on_click`) | — | — | *(бирку перевернуто; факту не дає)* | `z.shelf.tag_gun → turned` |
| `z.shelf.tag_gun` (`turned`) | `tool.loupe` (`dwell 0.5`) | — | `f.tag_two_numbers` | "One tag, on one bundle. Two numbers on it: a 3, and under the 3 a 6 in a browner ink. Nothing is struck out." | — |
| `z.shelf.slot6` | `tool.eye` \| `tool.rake` (`dwell 0.7`) | — | `f.shelf_six_five` | "Six bundles stand on the shelf. Five are in flannel and carry a tag on a string. The sixth is bare, and the shelf paper under all six is as bright as the day it was cut." | — |
| `z.folder.blank` | `*` (`on_click`) | — | `f.folder_blank` | "A folder at the back of the drawer. The panel for the number on the spine is blank. Inside, one line: *I have not dared to describe it. It is still in the house.* The inner cover carries no receipt stub; the gum has never been wetted." | — |
| `z.book.inventory` | `tool.hand` (`on_click`) | `f.tag_two_numbers`, `f.inv_gun_weights` | — | say: "The pen is by the book." → **відкриває дію «викреслити рядок 6»** (§3.4) | — |

### 3.2. Річ у руках (~10 хв)

| zone_id | tool | requires | fact_id | note (EN, спостереження) | sets_state |
|---|---|---|---|---|---|
| `z.shelf.slot6` | `tool.hand` (`on_click`) | — | — | *(взяти з полиці → екран HANDS)* | `z.shelf.slot6 → taken`, `screen = HANDS` |
| `z.relic.side` | `tool.rake` (`dwell 1.2`) | — | `f.no_seam` | "Under raking light the light runs from the top over the edge and down the side without a stop. There is no seam, no hinge, no lock plate and no keyhole. The corners are one piece with the sides." | — |
| `z.relic.under` | `tool.loupe` (`dwell 0.9`) | — | `f.under_bare` | "The underside is bare. No punch, no scratched number, no owner's initials, and no bright patch where any of them had been taken off." | — |
| `z.relic.top` | `tool.loupe` (`dwell 0.6`) | — | `f.inscription` | "Cut into the top, in capitals a little worn at the shoulders: NON AD LVCEM. The cut is V-shaped and the same depth from end to end." | — |
| `z.book.inscriptions` | `*` (`on_click`) | `f.inscription` | `f.motto_page` | "List of inscriptions, Latin: *non ad lucem* — 'not toward the light'. The note beside it: the words are not a church formula and stand on no altar plate known to the compiler; they are met with on the lids of boxes for photographic plates, and on jars of drugs that spoil in daylight." | — |
| `z.relic.top` \| `z.relic.side` | `tool.caliper` (`on_click`) | — | `f.caliper_dims` | "Across, twice, and down: 154 mm by 108 mm by 72 mm. The jaws close on it square at every corner." | — |
| `z.relic.top` | `tool.hand` (`on_click`) | — | — | say: "It does not lift, and there is nothing to lift it by." — **діегетичний тупик, факту не дає** | — |

### 3.3. Ваги (~12 хв; серце справи)

Усі правила зважування — `repeat: true`. Перезважувати можна скільки завгодно; **щоразу те саме
число**, і `add_fact()` не плодить рядків у нотатнику. Це не катсцена: правило б'є щоразу.

| zone_id | tool | requires | fact_id | note (EN, спостереження) | sets_state |
|---|---|---|---|---|---|
| `z.rig.pan` | `tool.scales` (`on_click`, `repeat`) | — | `f.weight_air` | "On the balance in air: 1 429 g. The beam comes to rest at once and does not creep." | — |
| `z.rig.jar` | `tool.hand` (`on_click`) | — | — | *(підвісити річ на волосині; вона висить вільно, дном на 40 мм вище дна слоїка)* | `z.rig.jar → piece_in` |
| `z.rig.jar` (`piece_in`) | `tool.scales` (`on_click`, `repeat`) | `f.weight_air` | `f.weight_water` | "Hanging clear on a horsehair, wholly under water, sides and bottom untouched: 1 429 g. The beam did not move when the water was reached." | — |
| `z.rig.jar` (`piece_in`) | `tool.caliper` (`on_click`) | — | `f.level_zero` | "The etched ring on the glass was set to the surface before the piece went in. Caliper from the ring down to the surface now: 0.0 mm. The inside of the jar measures 160 mm across." | — |
| `z.rig.jar` | `tool.hand` (`on_click`) | `f.weight_water` | — | *(зняти річ, підвісити еталон)* | `z.rig.jar → standard_in` |
| `z.rig.standard` | `tool.scales` (`on_click`, `repeat`) | — | — | say: "The brass standard on the same pan: 500 g. Stamped on its head: 500 g, and the assay office's crown." | `sets_flag: {fl.std_in_air: true}` |
| `z.rig.jar` (`standard_in`) | `tool.scales` (`on_click`, `repeat`) | `fl.std_in_air` | `f.control` | "The brass standard, 500 g in air, on the same beam, the same hair, the same water: 441 g. The ring on the glass now stands 2.9 mm above the surface." | — |
| `z.book.gravities` | `*` (`on_click`) | — | — | *(метод + таблиця; факту не дає — див. §5.3)* | `sets_flag: {fl.method_known: true}` |

**Пастка порядку, навмисна.** Гравець майже завжди зважує річ **до** еталона. Отже перші
кілька хвилин він упевнений, що ваги зламані — і має рацію, поки не поставить еталон.
Гра нічого не підказує. Якщо гравець так і не візьме еталон, він допише атестат із
гіпотезою (А) з §9, і це чесний, повний, неправильний прохід.

### 3.4. Дія без інструмента: викреслити рядок 6

Це **не** правило `RuleEngine` і не факт. Це `state.set_flag` + мальована анімація пера.

```gdscript
# доступна, коли є f.tag_two_numbers і f.inv_gun_weights
{"id": &"act.strike_line6", "kind": &"book_edit",
 "confirm_key": "confirm.strike",                  # «Strike the line?» — незворотно
 "sets_flag": {&"fl.line6_free": true},
 "surface_swap": {&"inventory_spread": &"inventory_spread_struck"}}
```

Після цього **звільняється номер 6** — і графа `s.number` атестата відкривається (§6).
Порожня клітинка «date of receipt» у новому рядку **лишається порожньою**: гра її не заповнює
і не підсвічує. Це єдина порожня клітинка на розвороті.

### 3.5. Нічна послідовність (~5 хв, після печатки)

Грає **безумовно**, незалежно від значень атестата. Це ХВИЛЯ 3.

| крок | зона / дія | tool | що відбувається |
|---|---|---|---|
| 1 | `z.room.lamp` | `tool.hand` | Лампа гасне. З полиці — стук-шкрябання, три рази, і тишa. |
| 2 | `z.room.lamp` (`out`) | `tool.eye` | say: "It stops each time the street lamp outside comes up, and starts again when it drops." — **причина видима, підказки нема** |
| 3 | `z.room.curtain` | `tool.hand` | Штора засувається. Кімната стає чорна. Ambience `darkness`. |
| 4 | `z.relic.top` | — | Кришка **стоїть відчинена**. Переходу нема, звуку відчинення нема: кадр просто інший. `z.relic.top → open` |
| 5 | `z.relic.inside` | `tool.eye` \| `tool.hand` | `f.nest` (див. §4) |

**Загасити лампу мало, і це доводиться грою, а не текстом.** Якщо гравець засуває штору,
не гасивши лампи — нічого не відбувається, і say: "The room is darker and the lamp is still lit."

---

## 4. ФАКТИ

`text` — рядок нотатника. `cite` — коротка форма, яка лягає в графу «на підставі».
`weight` — вага в OUTCOMES (ENGINE_SPEC §1.6).

| fact_id | text (EN, спостереження) | cite (EN) | tag | weight |
|---|---|---|---|---|
| `f.inv_inversion` | "Read down the dates of receipt, the numbers of the register stand 1, 2, 3, 6, 4, 5. Two lines carry the 9th of November 1868." | "the numbers out of order in the register" | `books` | 2 |
| `f.inv_gun_weights` | "Line 3: a fowling piece, damascus, Bräuer — 5 Pfd 9 Lth. Line 6: a fowling piece, damascus, Bräuer — 2 958 g." | "the two lines for one fowling piece" | `books` | 2 |
| `f.tag_two_numbers` | "One tag on one bundle, carrying a 3 and, under it in a browner ink, a 6. Nothing is struck out." | "the tag with two numbers on it" | `shelf` | 3 |
| `f.shelf_six_five` | "Six bundles on the shelf; five in flannel with a tag. The sixth is bare, and the shelf paper under all six is unfaded." | "six pieces on the shelf and five tags" | `shelf` | 3 |
| `f.folder_blank` | "A folder with a blank number panel: one line, *I have not dared to describe it. It is still in the house.* No receipt stub inside the cover; the gum has never been wetted." | "the folder with no number and no stub" | `papers` | 3 |
| `f.no_seam` | "Raking light runs from the top over the edge and down the side without a stop. No seam, no hinge, no lock plate, no keyhole." | "no seam anywhere on the piece" | `object` | 2 |
| `f.under_bare` | "The underside carries no punch, no scratched number, no initials, and no bright patch where any had been taken off." | "no mark of any kind underneath" | `object` | 1 |
| `f.inscription` | "Cut into the top in worn capitals: NON AD LVCEM. V-shaped, the same depth end to end." | "the words cut into the top" | `object` | 1 |
| `f.motto_page` | "List of inscriptions: *non ad lucem*, 'not toward the light'. Not a church formula; met with on boxes for photographic plates and on jars of drugs that spoil in daylight." | "the list of inscriptions" | `books` | 1 |
| `f.caliper_dims` | "154 mm by 108 mm by 72 mm. The jaws close square at every corner." | "the piece measured, 154 by 108 by 72 mm" | `object` | 2 |
| `f.weight_air` | "On the balance in air: 1 429 g. The beam comes to rest at once and does not creep." | "1 429 g in air" | `metal` | 2 |
| `f.weight_water` | "Hanging clear on a horsehair, wholly under water, sides and bottom untouched: 1 429 g. The beam did not move when the water was reached." | "1 429 g under water" | `metal` | 4 |
| `f.level_zero` | "The etched ring was set to the surface before the piece went in. Caliper from ring to surface now: 0.0 mm. The jar measures 160 mm inside." | "the water not moved by the piece" | `metal` | 4 |
| `f.control` | "The brass standard, 500 g in air, on the same beam, the same hair, the same water: 441 g, and the ring stands 2.9 mm above the surface." | "the standard weight, checked on the same beam" | `metal` | 4 |
| `f.nest` *(після печатки, у графи атестата не входить)* | "Inside, a bed of violet velvet, sunk in one shape: a disc the width of two thumbs, and a turned stem rising out of it. The velvet is not worn at the edges of the hollow." | — | `night` | 0 |

**14 фактів до атестата + `f.nest` після печатки.** Розкладка на 50 хв:
книга й бирки ≈ 20 хв (з них хибний слід ≈ 15) · річ у руках ≈ 8 хв · ваги і рівень ≈ 12 хв ·
довідники ≈ 4 хв · атестат ≈ 4 хв · ніч ≈ 2 хв.

**Один факт = один id.** Дороги, що дублюються:
`f.shelf_six_five` — і `eye`, і `rake`; `f.caliper_dims` — і з `z.relic.top`, і з `z.relic.side`;
`f.inv_inversion` — і `loupe`, і `eye`. У всіх трьох випадках id один, `add_fact()` ловить дубль.

**Ваги `f.weight_water`, `f.level_zero` і `f.control` — по 4.** Це найвищі ваги в грі.
Причина: OUTCOMES справи 10 мусить відрізнити гравця, який **перевірив прилад**, від гравця,
який просто списав однакове число. Без `f.control` у графі «на підставі» права гілка не бере.

**Чого в нотатнику НЕ буде.** Ні рядка про питому вагу, ні рядка про об'єм, ні рядка «0».
Гра не рахує за гравця. Ділення 1 429 ÷ 0 робить гравець, у себе в голові, і гра про це
не дізнається — вона дізнається тільки про те, що він вписав у графи.

---

## 5. ДОВІДКОВІ ТАБЛИЦІ

### 5.1. «Maße und Gewichte» — віденські ваги й метрична реформа (реальні числа)

| одиниця | у грамах | нотатка |
|---|---|---|
| 1 Wiener Pfund (Handelsgewicht) | **560.06 г** | торговий фунт, 32 лоти |
| 1 Loth | **17.502 г** | 1/32 фунта |
| 1 Quentchen | 4.376 г | 1/4 лота |
| 1 Mark (Silbergewicht) | 280.03 г | пробірна марка = 1/2 фунта |
| 1 Zentner | 56.006 кг | 100 фунтів |

> **Метрична система в Австро-Угорщині:** закон від **23 липня 1871**, обов'язкова
> з **1 січня 1876**. До 1876 конторські книги ведуть у фунтах і лотах, з 1876 — у грамах.
> Це історична правда, і в цій справі вона **датує чорнило**.

**Арифметика, яку робить гравець (і яка мусить сходитись до цифри):**
5 × 560.06 = 2 800.30; 9 × 17.502 = 157.52; разом **2 957.82 г**.
У книзі рядок 6 стоїть **2 958 г**. Це та сама річ, зважена двічі, з округленням до грама.

**Другий, незалежний доказ у тій самій клітинці:** рядок 6 датований **1868** роком,
а вага в ньому виписана **в грамах**. У 1868 в грамах ніхто не писав. Отже рядок написано
**не раніше 1876**, хоч би що стояло в колонці дати.

### 5.2. Інвентарна книга — «Verzeichnis der zurückbehaltenen Stücke»

Друком у головці розвороту: *Die Nummern werden nach dem Tage des Einganges vergeben.*
(«Номери присвоюються за днем надходження».) Номери рядків **не** друковані — на відміну
від гросбуха печаток (справа 4 §5.4), тут номер пише рука. Саме тому книга й зламалась.

| порядок на сторінці | № | дата надходження | річ | вкладник | вага (колонка книги) |
|---|---|---|---|---|---|
| 1 | 1 | 28 квітня 1859 | one brass inkstand | Reindl, T. | 1 Pfd 12 Lth |
| 2 | 2 | 14 серпня 1861 | a snuff-box, horn, silver-mounted | Hackl, J. | 7 Lth |
| 3 | 3 | 9 листопада 1868 | a fowling piece, damascus barrel | Bräuer, J. | **5 Pfd 9 Lth** |
| 4 | 4 | 3 лютого 1874 | a mourning ring, jet and gold | Zeidler, M. | 1 Lth |
| 5 | 5 | 21 червня 1881 | a barometer, wheel pattern, walnut | Sedlmayer, F. | 2 310 г |
| 6 | **6** | **9 листопада 1868** | a fowling piece, damascus | Bräuer, J. | **2 958 г** |

**Рядок 1 — каламарка зі справи 4.** Її не забрали (лист повернувся, «No such person at this
address»), і вона лишилась у бюро. Гра цього не коментує; гравець сам упізнає річ, яку тримав
у руках сорок п'ять хвилин тому за грою.

**Чому рядок 6 існує.** У теці 3 лежить квитанція збройника: *«Valuation, 11 March 1884,
Ferd. Nowak, gunmaker, Wien VI»* — рушницю виносили на оцінку і принесли назад. Попередник,
записуючи повернення, **правильно поставив дату надходження** (колонка називається «дата
надходження», а не «дата запису») і **дав наступний вільний номер**. Одна людська помилка,
без злого умислу, 1884 рік.

**Що з цього виходить арифметично:**

| | до розбору | після розбору |
|---|---|---|
| рядків у книзі | 6 | 5 (шостий викреслено) |
| описаних речей | 6 | **5** |
| згорток на полиці | 6 | 6 |
| бирок на полиці | 5 | 5 |
| **вільний номер** | — | **6** |

Помилка попередника **рівно закривала** нестачу: 6 рядків = 6 речей, книга сходилась.
Побачити справжню проблему можна **тільько** розібравши дубль. Тому хибний слід тут
обов'язковий, а не декоративний (§8).

### 5.3. Гідростатичне зважування і питомі ваги (реальний метод доби)

Сторінка `handbook_gravities`, друком:

> **To find the specific gravity of a solid body.** Weigh the piece in air; call this W.
> Suspend it by a hair or fine wire and weigh it again, wholly under water, clear of the
> sides and bottom of the vessel; call this W′. The difference **W − W′** is the weight of
> the water the body has put out of its place, and one gramme of water fills one cubic
> centimetre. Then **W ÷ (W − W′)** is the specific gravity. Water is taken at 4 °C = 1.000;
> at ordinary room temperature 0.998, which may be neglected save in assay work.
> Allow for the weight of the hair below the surface.

| матеріал | питома вага | матеріал | питома вага |
|---|---|---|---|
| кора-корок | 0.24 | граніт | 2.6–2.8 |
| дуб сухий | 0.75 | залізо | 7.8 |
| **вода** | **1.000** | латунь | **8.4–8.7** |
| ебен (чорне дерево) | 1.15–1.33 | срібло 800 | 10.2 |
| гагат (jet) | 1.30–1.35 | свинець | 11.34 |
| обсидіан | 2.4 | ртуть | 13.55 |
| скло | 2.4–2.6 | золото | 19.3 |
| мармур | 2.7 | платина | 21.4 |

Усі числа — довідникові й правдиві. **Найлегший рядок таблиці — 0.24, найважчий — 21.4.**
Рядка для тіла, яке важить у воді стільки ж, скільки в повітрі, у таблиці **нема**,
бо такого тіла нема: W − W′ = 0 не ділиться ні на що.

**Контроль сходиться до цифри:** 500 ÷ (500 − 441) = 500 ÷ 59 = **8.47** — латунь.
Прилад показує рівно те, що мусить.
**Річ не сходиться взагалі:** 1 429 ÷ (1 429 − 1 429) = 1 429 ÷ 0.
А штангенциркуль тим часом дав об'єм: 15.4 × 10.8 × 7.2 = **1 197.5 см³**,
тобто у воді річ мусила б утратити майже **1 197 г** і майже сплисти.

**Рівень води, друга дорога, без коромисла:** слоїк 160 мм усередині,
площа перерізу π × 80² = **20 106 мм²**.
Еталон 500 г латуні витискає 59 см³ → підйом **2.9 мм** (спостережено).
Річ мусила б витиснути 1 197.5 см³ → підйом **59.6 мм** (не спостережено; спостережено **0.0**).

### 5.4. Перелік написів, розділ «Латинські» (сторінка `inscription_list`)

| напис | переклад | де трапляється |
|---|---|---|
| *ex dono* | «у дар від» | вкладні написи на церковному посуді |
| *fecit* | «зробив» | підпис майстра після імені |
| *ne varietur* | «щоб не змінювалось» | нотаріальні книги, оправи |
| **non ad lucem** | **«не до світла»** | не церковна формула; **на накривках коробок для фотопластин і на банках з ліками, що псуються від денного світла** |
| *nescit occasum* | «не знає заходу» | девіз, соняшники, годинники |

Два побутові прочитання — і жодне з них не пояснює скриньки без шва.
**Довідник дає переклад і не дає розгадки.** Це навмисно.

### 5.5. Гросбух печаток — перехресна звірка (справа 4 §5.4)

Номери рядків гросбуха **друковані** і йдуть підряд, 1…1 429. Кожен рядок має дату надходження
й галочку про видачу. **Рядка для чорної речі в гросбусі нема** — і його не можна було
ні вирвати (нумерація друком), ні підчистити (тоді бракувало б номера).
Отже річ ніколи не проходила прийманням.

**Це та сама книга, у якій гравець уже читав «1 429» на полі після справи 4.**

---

## 6. АТЕСТАТ (6 граф, **три числові**)

| # | slot_id | префікс (англ.) | kind | гейт | варіанти / істина |
|---|---|---|---|---|---|
| 1 | `s.material` | **The piece is ____** | CHOICE | `needs_any: [f.no_seam, f.caliper_dims]` | `o.wood` «a casket of black wood, closed» · `o.stone` «a casket of black stone, closed» · `o.solid` «a solid block, and no casket at all» · `o.not_named` «of a substance this bureau cannot name» |
| 2 | `s.w_air` | **Weight in air, in grammes ____** | **NUMBER** | `needs: [f.weight_air]` · `digits: 4, min: 1, max: 9999` | списку нема, валідації нема. Істина **1429** |
| 3 | `s.w_water` | **Weight in water, in grammes ____** | **NUMBER** | `needs: [f.weight_water]` · `digits: 4, min: 0, max: 9999` | списку нема, валідації нема. Істина **1429** |
| 4 | `s.number` | **Entered in the inventory under No. ____** | **NUMBER** | `needs: [f.shelf_six_five]` · `needs_flag: [fl.line6_free]` · `digits: 2, min: 1, max: 99` | списку нема. Істина **6** |
| 5 | `s.received` | **Received by this bureau ____** | CHOICE | `needs_slot: [s.number]` | `o.by_deposit` «by deposit, the receipt mislaid» · `o.with_office` «with the office, from its former holder» · `o.never` «not received: found standing on the shelf» |
| 6 | `s.basis` | **On the basis of ____** | FACTS | `needs_slot: [s.received]` · `min_count: 2, max_count: 4` · `clears_on: [s.received]` | джерело — `state.fact_order`, `group != night` |

**Графа 3 — головна графа гри.** Гравець уже вписав 1429 у графу 2. Тепер бланк просить
те саме число вдруге, і гравець вписує його **своєю рукою**, у власному почерку, без жодного
коментаря від гри. Нічого не підсвічується, нічого не звучить. Це і є ХВИЛЯ 3 у механіці —
хвиля в нічній сцені (§3.5) лише ставить під нею підпис.

**Гейт графи 4 — `fl.line6_free`, а не факт.** Поки дубль не викреслено, номер 6 зайнятий,
і графа **фізично не приймає введення** (перо в ній не пише — мальований стан «графа закрита»).
Це єдиний твердий гейт справи, і він стоїть саме там, де хибний слід мусить бути пройдений.
Гра не пояснює, чому графа не пише. Гравець сам дійде, що книга ще не в порядку.

**Гейт графи 2 і 3 роздільний.** Можна вписати вагу в повітрі, не зваживши у воді — і піти
далі. Тоді графа 3 лишиться порожня, і це окрема гілка наслідків (`out.left_it_blank`).

**Порядок граф на папері саме такий і не інший.** «Weight in air» стоїть **над**
«Weight in water» — так, щоб при заповненні другої графи перша була в полі зору.
Це верстка, і вона робить половину роботи.

---

## 7. НАСЛІДКИ

**Безумовні беати** (не гілка, грають завжди, у цьому порядку):
1. **Вечір, після печатки:** гравець кладе штамп у гніздо в шухляді. Десятий раз за гру.
   Той самий звук. Анімація не скорочена й не подовжена.
2. **Ніч:** послідовність §3.5. Кришка стоїть відчинена; усередині — гніздо (§4, `f.nest`).
   **Жодного тексту, жодної музики.** Ambience `darkness`, і все.
3. **Ранок:** інвентарна книга розкрита на столі на тому розвороті, де він писав.
   У **наступному** розлінованому рядку — за його рядком №6 — уже стоїть номер,
   **чужою рукою**: **7**. Колонка дати в рядку 7 порожня. (V6 §3, поштовх між 10 і фіналом.)
4. **Ранок:** на полиці **шість** згорток і **шість** бирок. Шоста — у його почерку.

| # | id | умова | текст події наступного ранку (англ.) |
|---|---|---|---|
| 1 | `out.checked_the_beam` | `s.w_air = 1429` · `s.w_water = 1429` · `s.number = 6` · `s.received = o.never` · `basis_any: [f.control, f.level_zero]` · `basis_weight ≥ 8` | Nothing comes by either post. At ten the constable looks in on his round, sees the register open on the desk and reads the last line upside down out of politeness. *"Six,"* he says. *"You are tidier than he was."* He asks nothing about the empty column and does not seem to see it. When he has gone the room is exactly as quiet as it was before he came, and the shelf paper under the sixth bundle is still bright, in a rectangle its own size, as it has been since before the paper was cut. |
| 2 | `out.called_it_deposit` | `s.received = o.by_deposit` | By the first post, a printed form from the clerk of the district court, folded once, with a covering line in a clerk's hand: *"The Bureau's return of an unclaimed deposit is acknowledged. Column 4 requires the name and last known address of the depositor. The Bureau will please complete and return."* Column 4 is a ruled blank two inches long. Under it, printed small: *this column may not be left void.* |
| 3 | `out.left_it_blank` | `s.w_water` не заповнена | The balance is where it was left, and the jar with it. Some of the water has gone off overnight and the ring on the glass now stands a little above the surface, as it would in any room. The piece is on the shelf in its flannel. There is a note in the day-book in the player's own hand, dated yesterday, that reads *weighed* and nothing else. |
| 4 | `out.not_named` | `s.material = o.not_named` | The certificate comes back before nine, by the archive's own runner, with a printed slip gummed to the corner: *"Column 1 may not be returned indefinite. A certificate that names nothing has not been made out."* The slip is not signed. The seal on it is this bureau's own seal, and it is the seal the player set yesterday, because the archive has no other. |
| 5 | `out.default` | — (обов'язковий останній) | The register is open on the desk at yesterday's page, and the ink of the last line is dry. The line above it has been struck through with one stroke of the pen and initialled, and the initials are the player's. Somebody has laid the pen back in the tray with the nib to the left, which is not how it was left. |

**Жодна гілка не каже «правильно» чи «неправильно».** Гілка 1 — найтихіша, і саме вона правильна.
Гілка 2 — найстрашніша, і вона виглядає як звичайна пошта: суд ввічливо просить ім'я людини,
якої нема, і графа, яку не можна лишити порожньою, — це та сама графа, яку гравець щойно
лишив порожньою в книзі.

**Порядок збігу — зверху вниз, перший збіг виграє.** Умова гілки 3 (`s.w_water` порожня)
перевіряється **після** гілки 2 навмисно: гравець, який назвав річ вкладом і не зважив її
у воді, отримує суд, а не тишу.

---

## 8. ХИБНИЙ СЛІД

**Що саме спокушає.** Книга не сходиться: за датами номери стоять 1, 2, 3, **6**, 4, 5, і два
рядки датовані одним днем. Гравець прийшов у цю справу після справ 4, 5 і 7, де брехав **архів**,
і після справи 7, де в теках лежали **його власні** квитанції. Він уже знає головний прийом
цієї гри: канцелярська аномалія — це слід. Дубль виглядає точно як спосіб **сховати річ у книзі**:
одну річ записали двічі, щоб число рядків збіглося з числом речей, і хтось цим прикрив своє.

Це не параноя — це **правильне читання доказів**. Дубль справді прикриває нестачу.
Гравець помиляється лише в одному: він думає, що прикриття було **навмисне**.

**Куди веде.** У книгу нарядів збройника, у теку 3, у ваги, у таблицю віденських одиниць.
15 хвилин із 50: рушницю треба зняти з полиці, зважити (2 958 г), перевести 5 Pfd 9 Lth
у грами (2 957.8 г), перевернути бирку, знайти квитанцію Nowak'а від 11 березня 1884.
Руки зайняті, і зайняті чесною роботою.

**Чим спростовується — двічі, і жодного разу словами гри:**
1. **Арифметично:** 5 × 560.06 + 9 × 17.502 = 2 957.8 г проти 2 958 г у книзі. Одна річ,
   зважена двічі. Бирка з двома номерами і нічим не викресленим — та сама рука, той самий
   буріший чорнило, що в рядку 6.
2. **Датою чорнила:** рядок 6 датований 1868 роком, а вага в ньому **в грамах**.
   Грами в Австро-Угорщині обов'язкові з 1 січня 1876. Отже рядок написано не раніше 1876 —
   тобто це **пізніший запис старої дати**, а не підробка дати. Ніхто нічого не приховував:
   людина повернула рушницю на полицю і записала її вдруге.

**І ось чому цей хибний слід не декоративний.** Викресливши рядок 6, гравець **сам** ламає
рівновагу, яка сорок років закривала справжню нестачу: 5 описаних речей, 6 на полиці.
Хибний слід — не відгалуження від дороги, а **єдина** дорога до неї. Гравець мусить пройти
його до кінця й переконатися, що там нічого нема, — і саме цей рух відкриває графу 4 атестата.
Це найточніше застосування правила «руки зайняті, поки голова доходить» у грі.

---

## 9. ДВІ ГІПОТЕЗИ І РОЗВОДЖУВАЛЬНИЙ ФАКТ

**(А) Річ прийняли, а папери загубились.** Хтось приніс її, попередник не наважився описати
(його власний рядок у теці це і каже), тека лишилась без номера, квитанція запропала, і за сорок
років річ просто вросла в полицю. Ця гіпотеза переживає **все**: відсутність клейма, відсутність
шва, порожню теку, навіть однакові числа на вагах (бо шов може бути змазаний свинцем, а прилад
у бюро один і його ніхто не перевіряв від 1859-го). Під (А) правильна дія — вписати №6 і
написати листа вкладникові, і саме її просить графа 5 варіантом `o.by_deposit`.
**(Б) Річ ніколи не приймали.** Тоді запис у книзі — не впорядкування, а **набуття**:
бюро вперше в житті бере річ у власність, і рукою, яка це робить, є рука гравця.

**Розводить одне: `f.folder_blank`, і саме його друга половина.** У кожній теці бюро квитанція
**підклеєна** гумою до внутрішнього боку обкладинки — гравець бачив ці корінці дев'ять справ
поспіль. У теці без номера гума **ніколи не була змочена**: вона суха, гладка й блискуча по
всій смузі. Загублена квитанція лишає обірваний корінець або сліди гуми. Тут нема ні того,
ні того — отже квитанції не було **ніколи**, а не «була і зникла». Друга опора того самого:
номери рядків гросбуха **друковані** (справа 4), тому рядок не можна ні вирвати, ні підчистити
без дірки в нумерації, а дірки нема.

`f.weight_water` і `f.level_zero` гіпотези **не розводять**: вони лише роблять річ неможливою.
Розводить папір. Це навмисно, і це головна теза бюро: **фізика тут ні при чому, вирішує
діловодство.**

---

## 10. СТРИБОК ДУМКИ

Гравець виводить сам: **книга сходилась тільки тому, що одна помилка рівно закривала одну
нестачу — а коли він виправив помилку, з'ясувалось, що цієї речі ніхто ніколи не приймав,
і отже номер, який він зараз впише, не описує річ, а вперше робить її річчю бюро.**

---

## 11. ЧЕСНІСТЬ МЕТОДУ ТА IP-ЧЕК

**Перевірено і правда:**
- **Гідростатичне зважування** — стандартний метод з XVIII ст.: W ÷ (W − W′) = питома вага;
  підвіс на волосині або тонкому дроті, тіло цілком у воді, вільно від стінок і дна;
  вода при 4 °C = 1.000 г/см³, при 20 °C ≈ 0.998. Формулювання сторінки §5.3 — довідникове.
- **Питомі ваги** в §5.3 — довідникові числа (латунь 8.4–8.7, срібло 800 = 10.2, свинець 11.34,
  платина 21.4, ебен 1.15–1.33, гагат 1.30–1.35). Контроль 500 → 441 г дає 8.47 — латунь. Сходиться.
- **Витиснення за рівнем води** — метод, старший за ваги; для слоїка 160 мм усередині
  площа перерізу 20 106 мм², 59 см³ → 2.9 мм. Арифметика перевірена.
- **Віденські одиниці:** Pfund 560.06 г, Loth 17.502 г, Mark 280.03 г. Правда.
- **Метрична реформа Австро-Угорщини:** закон 23.07.1871, чинність з 01.01.1876. Правда,
  і це єдине справжнє датування в справі.
- **Практика конторських книг:** нумерація за датою надходження, вага в окремій колонці,
  бирки на згортках, підклеєні корінці квитанцій — усе це звичайне діловодство доби.
- **Латунний еталон 500 г із клеймом повірки** — реальний інвентар оцінювача після 1876.

**Прямо кажу, де метод сумнівний або авторський:**
1. **Сама аномалія фізично неможлива, і це навмисно.** Тіло з нульовим виштовхуванням
   не існує. Справа не пропонує наукового пояснення й **не має його дати**: атестат просить
   не тлумачення, а числа. Це єдина справа гри, де річ не має розв'язки, і на цьому тримається
   вся хвиля. Якщо на плейтесті гравці шукатимуть «наукову» відповідь і фруструватимуться —
   лікується не поясненням, а **посиленням канцелярської гілки** (гілка 2 наслідків), тобто
   тим, що справа ставить питання «як це записати», а не «що це».
2. **Напис NON AD LVCEM — авторський.** Латина правильна («не до світла»), але це **не
   атестований історичний напис**. Тому довідник §5.4 і каже прямо: не церковна формула,
   на відомому компіляторові посуді не трапляється. Побутові прочитання (коробки для фотопластин,
   банки світлочутливих ліків) — реальні практики; фраза на них авторська. Ця чесність
   вбудована в текст довідника, а не залишена поза грою.
3. **Річ 1 197.5 см³ вагою 1 429 г** дала б питому вагу 1.19 — рівно ебен. Це навмисно:
   гравець, який зважить у повітрі й обміряє, отримає **правдоподібний** матеріал і буде
   впевнений, що знає відповідь. Вода забирає цю впевненість, не давши нічого замість.
4. **Ваги в бюро одні.** Історично оцінювач мав один комплект, і саме тому контроль тут —
   не «зважити на інших вагах», а **еталонна гиря на тих самих** (родич методу подвійного
   зважування Гаусса зі справи 6, і навмисне його відлуння).
5. **1 429 г = 1 429 печаток** — авторський збіг, не історія. Обґрунтування й шлях відступу —
   у преамбулі файлу.

**IP-чек.** Усі імена вигадані й перевірені на відсутність відомого носія в цьому ремеслі:
*Katharina Lorenz*, *Hackl*, *Bräuer*, *Zeidler*, *Sedlmayer*, *Ferd. Nowak* (збройник),
*Reindl* (перенесено зі справи 4). **Znaim** (Znojmo) і **Wien VI** — реальні топоніми,
топоніми не є IP. Чорна скринька без шва — **не** релікварій зі Strange Antiquities:
там річ окультна й лавка окультна, тут річ проходить через **інвентарну книгу державної
установи**, і страшне в ній — порожня клітинка в колонці «дата надходження».
Буквального містичного пояснення справа не дає й не дасть (PLAN_V2 §5).

---

## 12. ВХІД

Чотири речі сходяться, і жодна з них — не кнопка.

1. **Удова.** Вона просить завірену копію рядка інвентарної книги. Це дрібне, тепле, законне
   прохання, і воно **змушує гравця відкрити саму книгу** — не гросбух печаток, у якому він
   сидить дев'ять справ, а іншу книгу, до якої він досі не мав діла.
   Він шукає рядок про годинник, знаходить його — і бачить головку розвороту:
   *«Номери присвоюються за днем надходження»*. Далі досить прочитати колонку дат.
   **Три хвилини головою, а не двадцять руками** (V6 §4, справа 10).
2. **Полиця, яку гравець бачив дев'ять справ.** Шість згорток стоять на ній із першого кадру
   гри. *Арт-вимога до справ 1–9: `shelf_retained` присутня в кадрі кабінету завжди, шоста
   згортка — крайня права, без бирки, і жодного разу не підсвічена.* Це коштує нуль
   і окупається тут (KARTA_ROZSHARUVANNIA: `shelf_item6` присутня **з дня 1**).
3. **Тека без номера.** У глибині шухляди, за текою 5, тека, у якої панель для номера на корінці
   **пуста**. Усередині — один рядок рукою попередника:
   > *"I have not dared to describe it. It is still in the house."*
   Гравець уже знає цей почерк: ним підписані стрічка-закладка справи 4, дзеркальна картка
   справи 5 і всі 1 429 рядків гросбуха.
4. **Щоденник, поштою, через дві хвилини після того, як гравець впише 6.** Сторінка
   надходить **після** дії, не до неї:
   > *"I could not bring myself to give it a number. It would have been the sixth."*
   Номер збігся не тому, що гра підказала, а тому, що номер **логічний**: обидва рахували
   ту саму книгу. Це і є найтихіший удар справи.

Перше речення дня — репліка вдови, і воно єдине, що гра дозволяє собі сказати вголос
до самого вечора:
> *"I have come to thank you, and then I will not trouble the Bureau again."*

---

## 13. ЗАЛЕЖНОСТІ Й БОРГИ ПЕРЕД ІНШИМИ СПРАВАМИ

| що | звідки / куди | навіщо |
|---|---|---|
| ваги, що **чесно** дають число | справи 1 (у повітрі) і 8 (гідростатика) | без цього §3.3 — катсцена, а не прилад |
| гідростатика вже застосована один раз | **справа 8** (келих, 10.1) | гравець мусить знати метод, а не вчити його тут |
| латунний еталон 500 г у футлярі ваг | арт справ 1 і 8: **лежить у кадрі з першої справи** | інакше він виглядає як реквізит, підкладений для цієї справи |
| `shelf_item6`, шоста згортка без бирки | справи 1–9, кожен кадр кабінету | вхід §12.2 |
| порожні гнізда й підклеєні корінці квитанцій у теках | справи 1–9 (арт тек) | розводжувальний факт §9 |
| друковані номери рядків гросбуха | **справа 4 §5.4** | §5.5: рядок не можна ні вирвати, ні підчистити |
| «1 429» на полі гросбуха | після справи 4 | вага речі в §6 графа 2 |
| каламарка Райндля, не забрана спадкоємцями | **справа 4**, `out.to_heirs` | рядок 1 інвентарної книги |
| удова та її годинник | **справа 3** | клієнт §1, вхід §12.1 |
| подвійне зважування Гаусса | **справа 6** | ідея «контроль на тому самому приладі» |
| гніздо для штампа в шухляді, щовечора | справи 1–9 | §7, беат 1: десятий раз перед тим, як гравець побачить друге гніздо |
| **гніздо у формі печатки в релікварії** | **фінал** | `f.nest` описує форму й **не називає** її. Називає її гравець, у фіналі, рукою |
| «7» чужою рукою в наступному рядку | між 10 і фіналом (V6 §3) | §7, беат 3 |
| порожня клітинка «date of receipt» | **фінал**, головний атестат | у фіналі порожні клітинки заповнюються даними його життя |
