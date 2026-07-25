# СПРАВА 5 — «ПОРТРЕТ ІЗ ЗАПІЗНЕННЯМ» (THE LATE PORTRAIT)

**№ 5 · 35 хв · акт I, останній такт**

**Роль в акті.** Це справа, де **архів не збрехав**, і стоїть вона навмисно **до** того, як гравець
почне вірити текам. Він щойно (справа 4) побачив, що річ буває ні до чого, а папір — до чого.
Тут він уперше отримає прямий конфлікт «запис проти речі» — і виявить, що помилявся **він сам**,
бо читав дзеркальний відбиток і глядацьке «ліве». Ціна уроку: коли в справах 7 і 10 архів
справді ховатиме, гравець уже не зможе списати це на власну неуважність. Плюс наскрізна нитка:
дзеркальну картку підшив **попередник**, його рукою, і в книзі вона не одна.

Нова дія гри: **свічка на просвіт** (`tool.candle`). До цієї справи жодного разу не вживалась.

---

## 1. КЛІЄНТ

**Josefa Lindt**, 44, вдова. Приносить портрет, загорнутий у зелену вовняну ковдру,
несе його сама, боком, як несуть двері.

**Названа потреба (не пов'язана з річчю).**
> "The place on the ship is my son's, and it is paid for to the twelfth. On the twelfth they sell
> it again. I am not asking you to say the picture is good. I am asking you to say it by Thursday."

**Фізична деталь, яку кадр показує і жоден текст не коментує.**
Жалобна пов'язка на рукаві **прифастригована білою ниткою**, стібки великі, кравецькі —
її зшили похапцем і ще не підрубили. Смерть у домі — днів чотири-п'ять, не більше.
(Камера тримає рукав 1.2 с, коли вона кладе портрет на мольберт. Жодної репліки.)

**Дві репліки на печатку.**

| Умова | Репліка |
|---|---|
| **Швидко** — печатка поставлена до того, як здобуто `f.plate_read` (гравець не відкривав ящик із пластинами) | "You did not even go to the shelf. I will tell my son the office was quick." |
| **Довго** — печатка поставлена, коли здобуто ≥ 10 фактів **або** минуло > 18 хв | "I had begun to think you would send me home with it. People do." |

**Ім'я вписує гравець** на квитанції власною рукою. Перший некролог у грі (пошта наступного
ранку після цієї справи) — **Josefa Lindt**. Надіслано на адресу бюро «з люб'язності».

---

## 2. ПРЕДМЕТ І МАТЕРІАЛИ

**Річ.** Портрет олією на полотні: **Anton Lindt**, купець, погруддя, темне тло, сюртук,
рука на грудях. Підпис унизу праворуч: *F. BRANDT*. Полотно 61 × 48 см на підрамнику.
Наскрізь через око йде **тріщина** — не кракелюр, а справжній розрив ґрунту.

**Матеріали бюро** (усі вже в кімнаті, нічого не приносять ззовні):
- **Реєстр інвентаризації 1889** — велика книга; у ній картка **entry 212** з наклеєним
  фотовідбитком і рядком писаря;
- **Гросбух** (день-у-день, той самий, що в справах 1 і 4);
- **Ящик III зі скляними пластинами**, на архівній полиці; у ньому негатив **№ 473**
  у паперовій обгортці виробника.

**Атмосфера екрана PLATE:** архівний стіл, чорна тканина, свічка в бляшаному ліхтарі.
Пластина 13 × 18 см. Коли її беруть — звук скла об дерево, один раз, тихо.

---

## 3. ЗОНИ

Вісім зон, чотири екрани. Усі підписані, жодного pixel hunt.
2D-координати — **у частках ЗОБРАЖЕННЯ** (не екрана), радіус — у частках **ширини** зображення.

| zone_id | де саме | kind | screen / surface | координати | r | стани |
|---|---|---|---|---|---|---|
| `z.canvas.crack` | тріщина: від брови через око праворуч від глядача вниз до коміра | `img`, `shape: rect` | EASEL / `portrait_front` | u = (0.575, 0.430), half = (0.052, 0.190) | — | `default` |
| `z.canvas.back` | зворот: середня поперечка підрамника з паперовим ярликом і трафаретним «212» | `img` | BACK / `portrait_back` | u = (0.512, 0.498) | 0.150 | `default` |
| `z.card.photo` | наклеєний фотовідбиток на картці entry 212 (разом із підрізаним низом паспарту) | `img` | ARCHIVE / `register_spread` | u = (0.302, 0.455) | 0.145 | `default` |
| `z.card.entry` | рядок писаря праворуч від відбитка + олівцева примітка внизу картки | `img` | ARCHIVE / `register_spread` | u = (0.655, 0.470) | 0.135 | `default` |
| `z.book.leaf` | перший (титульний) аркуш реєстру з друкованою передмовою; ріг **загнутий** | `img` | ARCHIVE / `register_front_leaf` | u = (0.480, 0.365) | 0.170 | `default` |
| `z.book.daybook` | гросбух на столі, розворот 1890 | `img` | DESK / `daybook_1890` | u = (0.560, 0.520) | 0.180 | `default` |
| `z.plate.wrapper` | паперова обгортка негатива, що лежить поруч на чорній тканині | `img` | PLATE / `plate_table` | u = (0.760, 0.680) | 0.090 | `default` |
| `z.plate.face` | сама пластина в руках, лицьова до гравця площина | `node3d` | PLATE, anchor `plate_pivot` | p = (0.0, 0.0, 0.004), n = (0, 0, 1) | 0.55 (світові од.), `facing_min` 0.15 | **`default`** = склом до ока (як лежала) · **`emulsion`** = емульсією до ока |

`tools` для курсора:
`z.canvas.crack` → loupe, rake · `z.canvas.back` → loupe, caliper ·
`z.card.photo` → loupe · `z.card.entry` → eye, loupe · `z.book.leaf` → eye ·
`z.book.daybook` → eye, loupe · `z.plate.wrapper` → eye · `z.plate.face` → hand, rake, candle, loupe.

---

## 4. ПРАВИЛА

`requires` — факти, які мусять уже бути. `note` — англійський текст **спостереження** в нотатник
і в репліку (`say_key`). Висновків у note нема ніде.

| # | zone_id | tool | requires | fact_id | note (EN, спостереження) | sets_state |
|---|---|---|---|---|---|---|
| r.01 | `z.canvas.crack` | `tool.loupe` (dwell 0.4) | — | `f.canvas_crack_right` | "The fracture begins at the brow, crosses the eye that stands to my right as I look, and dies in the collar." | — |
| r.02 | `z.canvas.crack` | `tool.rake` (on_click) | `f.canvas_crack_right` | `f.canvas_craquelure` | "Under the slanted lamp the fracture stands up as a ridge. The ground is lifted along both lips of it. Near the collar it forks into three. In the trough lies newer paint, smooth where the rest of the surface is not." | — |
| r.03 | `z.canvas.back` | `tool.loupe` (dwell 0.5) | — | `f.label_restorer` | "A paper label pasted to the crossbar: 'Relined and cleaned; the loss along the fracture filled and retouched. Werkstatt A. Kolb, 1890.' Beside it, stencilled in office ink: 212." | — |
| r.04 | `z.canvas.back` | `tool.caliper` (on_click) | — | `f.canvas_size` | "Across the stretcher: 61.4 centimetres by 48.2." | — |
| r.05 | `z.card.entry` | `tool.eye` / `*` (on_click) | — | `f.card_entry` | "Inventory of 1889, entry 212. In a clerk's hand: 'Portrait in oils, half length; canvas 61 by 48; fracture through the left eye.' Below, in pencil: 'Neg. 473 — Kasten III.'" | — |
| r.06 | `z.card.entry` | `tool.loupe` (dwell 0.8) | `f.card_entry`, `f.daybook_restoration` | `f.card_hand` | "The crossed t and the open-tailed 7 on this card are the crossed t and the open-tailed 7 of the day-book. The same hand wrote both." | — |
| r.07 | `z.card.photo` | `tool.loupe` (dwell 0.4) | `f.card_entry` | `f.print_crack_left` | "In the photograph pasted to the card the fracture crosses the eye that stands to my left as I look, and near the collar it forks into three." | — |
| r.08 | `z.card.photo` | `tool.loupe` (dwell 1.2) | `f.print_crack_left` | `f.print_reversed_marks` | "In the same photograph the painter's name stands in the lower left corner, and a scratched number stands in the upper right. The letters of the one and the digits of the other are all turned back to front. The number, so turned, is 473." | — |
| r.09 | `z.card.photo` | `tool.loupe` (dwell 0.9) | `f.card_entry` | `f.mount_medals` | "The mount has been trimmed to fit the card, but its lower edge is still printed: ATELIER WEISS, Landstrasse 40 — Wien 1873 — Paris 1878 — Barcelona 1888." | — |
| r.10 | `z.book.leaf` | `*` (on_click) | — | `f.register_convention` | "Printed on the first leaf of the register: 'In this book left and right are given as of the person or figure portrayed, and not as of the beholder.' The corner of the leaf has been turned down and pressed flat." | — |
| r.11 | `z.book.daybook` | `*` (on_click) | `f.card_entry` | `f.daybook_restoration` | "Day-book, 1890: 'No. 212 to Kolb, 4 March. Returned 27 May. Four gulden, paid.'" | — |
| r.12 | `z.plate.wrapper` | `*` (on_click) | — | `f.plate_wrapper` | "The maker's wrapper: 'TROCKENPLATTEN — dry plates, 13 by 18. The coated face is dull; the glass is bright. Numbers are scratched in the coating so that they read forward when the coated face is toward the eye.'" | — |
| r.13 | `z.plate.face` | `tool.rake` (on_click) | — | `f.plate_sides` | "Held at a slant to the lamp: one face of the plate is dull and drinks the light. The other throws the flame straight back." | — |
| r.14a | `z.plate.face` | `tool.hand` (on_click, `repeat`) | `f.plate_sides` | — | "Turned over." | `z.plate.face → emulsion` |
| r.14b | `z.plate.face` | `tool.hand` (on_click, `repeat`, `zone_state: emulsion`) | — | — | "Turned back." | `z.plate.face → default` |
| r.15 | `z.plate.face` | `tool.candle` (dwell 1.0, `zone_state: emulsion`) | `f.plate_sides`, `f.plate_wrapper` | `f.plate_read` | "Dull face toward the eye, candle behind: the number in the corner reads 473, forward. In the picture the fracture is pale where the paint is dark, and it crosses the eye that stands to my right as I look." | — |
| r.16 | `z.plate.face` | `tool.candle` (dwell 1.0, `zone_state: default`, `repeat`) | — | **немає факту** — лише `say_key` | "Through the glass the fracture falls to my left, and the number stands back to front." | — |
| r.17 | `z.canvas.crack` | `tool.candle` (on_click) | — | **немає факту** — `say_key` | "The canvas is lined. Nothing goes through it." | — |

**Примітки для програміста.**
- r.16 — навмисний «майже»: гравець, який не знає, який бік емульсія, бачить рівно те, що на
  картці, і не отримує нічого. Факт народжується тільки після `f.plate_wrapper` + `f.plate_sides`
  і **тільки зі станом `emulsion`**. Це і є гейт розуміння, а не гейт кліку.
- r.14a/r.14b — `repeat: true`, стан перемикається скільки завгодно разів. `sets_zone` в рушії
  абсолютний, тому це два правила, а не одне.
- r.06 вимагає `f.daybook_restoration` не тому, що почерк без нього не видно, а тому, що
  **нема з чим порівнювати**: гросбух — єдиний зразок руки попередника, відкритий у цій справі.
- Один факт = один id. `f.print_reversed_marks` дається однією дією (проводка лупою по відбитку),
  бо перевернуті літери й перевернуті цифри — це одне спостереження, а не два.

---

## 5. ФАКТИ (14)

| fact_id | text (EN, у нотатнику) | cite (у графі "on the basis") | tag | weight |
|---|---|---|---|---|
| `f.card_entry` | "Inventory of 1889, entry 212: 'Portrait in oils, half length; canvas 61 by 48; fracture through the left eye.' In pencil below: 'Neg. 473 — Kasten III.'" | "the record of 1889 says: through the left eye" | `record` | 2 |
| `f.card_hand` | "The crossed t and the open-tailed 7 on the card are those of the day-book. The same hand wrote both." | "the card is in the office's own former hand" | `record` | 1 |
| `f.register_convention` | "Printed on the register's first leaf: 'left and right are given as of the person portrayed, and not as of the beholder.'" | "this register gives left and right as of the sitter" | `record` | 3 |
| `f.print_crack_left` | "In the photograph on the card the fracture crosses the eye to my left, and forks into three near the collar." | "in the filed photograph the fracture falls to the beholder's left" | `photo` | 2 |
| `f.print_reversed_marks` | "In that photograph the painter's name stands lower left and a scratched number stands upper right; letters and digits alike are turned back to front. The number is 473." | "every letter and digit in the filed photograph is turned back to front" | `photo` | 3 |
| `f.mount_medals` | "The trimmed mount is printed: ATELIER WEISS, Landstrasse 40 — Wien 1873 — Paris 1878 — Barcelona 1888." | "the mount carries a Barcelona medal of 1888" | `photo` | 2 |
| `f.canvas_crack_right` | "On the canvas the fracture begins at the brow, crosses the eye to my right, and dies in the collar." | "on the canvas the fracture falls to the beholder's right" | `object` | 2 |
| `f.canvas_craquelure` | "Under raking light the fracture stands up as a ridge; the ground is lifted along both lips; near the collar it forks into three. Newer paint lies in the trough, smooth where the rest is not." | "the fracture is lifted through the ground and forks in three" | `object` | 3 |
| `f.canvas_size` | "Across the stretcher: 61.4 centimetres by 48.2." | "the stretcher measures 61.4 by 48.2" | `object` | 1 |
| `f.label_restorer` | "Label on the crossbar: 'Relined and cleaned; the loss along the fracture filled and retouched. Werkstatt A. Kolb, 1890.' Stencilled beside it: 212." | "the canvas was relined and retouched in 1890" | `false_trail` | 1 |
| `f.daybook_restoration` | "Day-book, 1890: 'No. 212 to Kolb, 4 March. Returned 27 May. Four gulden, paid.'" | "the office itself sent 212 out and had it back" | `false_trail` | 2 |
| `f.plate_wrapper` | "Maker's wrapper: 'TROCKENPLATTEN, 13 by 18. The coated face is dull; the glass is bright. Numbers are scratched in the coating so that they read forward when the coated face is toward the eye.'" | "on a dry plate the coated face is the dull one" | `plate` | 1 |
| `f.plate_sides` | "One face of the plate is dull and drinks the light; the other throws the flame back." | "one face of plate 473 is dull, the other bright" | `plate` | 2 |
| `f.plate_read` | "Dull face toward the eye, candle behind: the number reads 473, forward; the fracture is pale where the paint is dark, and it crosses the eye to my right." | "on negative 473, read from the coated face, the fracture falls to the beholder's right" | `plate` | 4 |

---

## 6. ДОВІДНИКОВІ ТАБЛИЦІ

Усі — окремі мальовані розвороти (гравюра XIX ст.), відкриваються з полиці. Значення справжні.

### 6.1. Фотографічні процеси і дати (розворот «Lichtbild»)

| Процес | Роки | Ознака в руці | Дзеркальність |
|---|---|---|---|
| Дагеротип | 1839 – бл. 1860 | дзеркально-полірована срібна пластина, зображення «плаває» при нахилі | **зображення дзеркальне** |
| Амбротип (колодієвий позитив на склі) | 1852 – бл. 1880 | скло з чорним тлом позаду | **дзеркальне** |
| Тинтип / феротипія | 1856 – 1900-ті | лакована залізна пластинка, магнітна | **дзеркальне** |
| Мокроколодієвий негатив на склі | 1851 – бл. 1885 | шар **не доходить до країв**, сліди зливу, відбиток пальця в кутку, зверху **лак** | негатив, дзеркальність вирішує друк |
| **Желатинова суха пластина** | **комерційно з 1878** (Wratten & Wainwright, Лондон) | шар машинний, **до всіх чотирьох країв**, рівний, **без лаку**, матовий | негатив, дзеркальність вирішує друк |
| Альбуміновий відбиток | 1850 – бл. 1895 | глянець, жовтуватий, тріскається сіткою | — |
| Желатиновий POP / матовий колодій | з 1885 | щільніший, холодніший тон | — |

> **Чесно про метод.** Проба «матове/блискуче» надійна на **нелакованій желатиновій** пластині.
> **Лакований колодієвий негатив блищить з обох боків** — там працюють інші дві ознаки:
> край шару (мокрий колодій не доходить до країв, суха пластина доходить) і сам продряпаний
> номер. У цій справі пластина — суха желатинова, обгортка це каже прямо, і всі три ознаки
> сходяться. Гру на «здогадайся, що це за процес» ми тут не робимо.

### 6.2. Читання скляного негатива (розворот «Platte»)

| Що | Правило |
|---|---|
| емульсійний (шар) бік | **матовий**, теплий, гасне під косим світлом |
| скляний бік | **блискучий**, віддає полум'я |
| номер фотографа | продряпується в шарі на полі, **читається прямо, коли шар до ока** |
| контактний друк «шар до шару» | відбиток **прямий**; літери й цифри прямі |
| друк **крізь скло** (пластина перевернута) | відбиток **дзеркальний**, і разом із ним дзеркальні **всі** літери й цифри |
| наслідок | **перевернута літера — єдине, що не має другого пояснення** |

### 6.3. Ліве і праве в описах (розворот «Dexter»)

| Система | Що значить «ліве» |
|---|---|
| **Proper left / proper right** (музейна, інвентарна) | бік **самої зображеної особи** |
| Геральдика | **dexter** = правий бік носія = **лівий бік глядача**; **sinister** = лівий носія = правий глядача |
| Каталог торговця, газета, аукційний опис XIX ст. | здебільшого **глядацьке**, і майже ніколи не обумовлено |
| Медичний і кравецький запис доби | бік пацієнта / замовника, тобто proper |

> **Чесно про метод.** Універсального правила доби **не існує** — тому «ліве» ніколи не читається
> з ерудиції. Конвенцію треба взяти **з передмови тієї самої книги**, у якій зроблено запис.
> Реєстр 1889 має її друком на першому аркуші (`f.register_convention`). Це не підказка, це
> сторінка, з якої починається книга.

### 6.4. Медалі ательє (розворот «Ausstellungen») — реальні роки

| Виставка | Рік |
|---|---|
| Weltausstellung Wien | **1873** |
| Exposition Universelle, Paris | **1878** |
| Internationale Tentoonstelling, Amsterdam | 1883 |
| Wereldtentoonstelling, Antwerpen | 1885 |
| **Exposición Universal, Barcelona** | **1888** |
| Exposition Universelle, Paris | 1889 |

> Паспарту не може бути надруковане раніше за **останню** медаль на ньому.
> На нашому: Wien 1873 · Paris 1878 · **Barcelona 1888** → **не раніше 1888**.
> Пастка навмисна: 1873 і 1878 стоять великим кеглем угорі підрізаного поля, 1888 —
> дрібним, при самому зрізі. Побіжний погляд дає 1878.

### 6.5. Ознаки дзеркального знімка без тексту (розворот «Verkehrt»)

| Ознака | Правило | Наскільки надійна |
|---|---|---|
| чоловіча застібка | ліва пола **поверх** правої; ґудзики на правому боці носія | **тільки на однобортному**; двобортний застібається на оба боки — не доказ |
| обручка | Австрія, Німеччина, Росія, Польща — **права** рука; Франція, Британія — ліва | залежить від країни й від того, вдівець чи ні |
| орденська зірка | на **лівих** грудях | так, але стрічки різних орденів ідуть через різне плече |
| проділ, шрам, ґудзик манжети | — | **не доказ узагалі** |
| **перевернута літера або цифра** | — | **єдине, що вирішує** |

---

## 7. АТЕСТАТ (6 граф, дві числові)

Бланк: `cert_05_late_portrait`. Порядок жорсткий, гейти — по фактах.

| # | slot_id | префікс (EN) | тип | гейт | варіанти / межі |
|---|---|---|---|---|---|
| 1 | `s.subject_side` | "The fracture crosses the sitter's ____ eye." | CHOICE | `needs`: `f.canvas_crack_right`, `f.register_convention` | `o.proper_left` ("proper left — his own") · `o.proper_right` ("proper right — his own") · `o.beholders_left` ("left as the beholder stands") |
| 2 | `s.photo_not_before` | "The photograph filed with entry 212 was made not earlier than ____." | **NUMBER**, digits 4, min 1700, max 1900 | `needs_any`: `f.mount_medals` | списку нема, валідації нема |
| 3 | `s.days_out` | "Out of this office in 1890, ____ days." | **NUMBER**, digits 3, min 0, max 999 | `needs`: `f.daybook_restoration` | списку нема, валідації нема |
| 4 | `s.identity` | "The canvas on the easel is ____." | CHOICE | `needs_any`: `f.plate_read`, `f.canvas_size` | `o.same_canvas` ("the canvas of entry 212") · `o.other_canvas` ("another canvas") · `o.copy_after_1890` ("a copy made after the relining") · `o.cannot_say` ("not to be told from this record") |
| 5 | `s.record_verdict` | "The office record of 1889 is ____." | CHOICE | `needs_slot`: `s.subject_side`, `s.identity` | `o.words_right_picture_reversed` ("right in its words; its photograph printed in reverse") · `o.words_wrong` ("wrong in its words") · `o.wrong_throughout` ("wrong in words and picture both") · `o.made_to_mislead` ("made so as to mislead") |
| 6 | `s.basis` | "On the basis of ____." | FACTS | `needs_slot`: `s.record_verdict`; `clears_on`: `s.record_verdict` | min 2, max 4; джерело — `state.fact_order` |

**Правильні значення** (рушій їх не знає — знають тільки OUTCOMES):
`s.subject_side = o.proper_left` · `s.photo_not_before = 1888` · `s.days_out = 84`
(4 березня → 27 травня 1890 = 84 дні) · `s.identity = o.same_canvas` ·
`s.record_verdict = o.words_right_picture_reversed`.

---

## 8. НАСЛІДКИ (ранок наступного дня)

Матчер бере **перший** запис, чиї умови збіглися. `out.default` — завжди останній.

### O1 · `out.record_stands` — запис устояв
```
when: s.identity = o.same_canvas
      s.record_verdict = o.words_right_picture_reversed
      s.subject_side = o.proper_left
      s.photo_not_before = {min: 1888, max: 1888}
basis_any: [f.plate_read, f.print_reversed_marks]
basis_weight: 5
```
> The register came back from the binder with a slip pasted over entry 212, in your hand:
> *photograph printed through the glass; the entry itself is correct.* Frau Lindt's son sailed on
> the twelfth. She sent no word, but the fare was paid at the shipping office on Thursday afternoon,
> which is a thing the shipping office records.
>
> Turning back to shelve the register, you find four more cards where the sitter buttons his coat
> the wrong way. All four are in the same hand as entry 212. The book gives no dates for when they
> were filed.

### O2 · `out.called_it_a_swap` — названо підміну
```
when: s.identity ∈ {o.other_canvas, o.copy_after_1890}
```
> The constable took the portrait away in the green blanket at eight in the morning and gave
> Frau Lindt a receipt for it. The place on the ship was resold on the twelfth.
>
> Kolb's workshop sent up the lining canvas, the old tacking margins and their own book, all
> matching No. 212. A clerk from the court has asked the office, in writing, on what the finding
> rested. The letter is on the desk. It is polite.

### O3 · `out.blamed_the_restorer` — винен реставратор
```
when: s.record_verdict = o.made_to_mislead
   OR (s.basis contains f.label_restorer AND s.basis does not contain f.daybook_restoration)
```
> Anton Kolb is seventy-one and came himself, on foot, with his day-book under his arm. He had
> the same four gulden entered on the same date as yours. He did not raise his voice. He asked
> whether he might have that in writing, and when told he might, he said he would wait.
>
> He waited until the office closed.

### O4 · `out.default` — печатка стоїть, і на цьому все
```
when: {}
```
> The portrait went home in the blanket. Frau Lindt signed for it with her left hand, the right
> being full.
>
> In the afternoon post: a printed card, black-edged, from the parish of St. Ulrich. It is a death
> notice, and it is sent to this office **by courtesy**. The name on it is one you wrote out
> yesterday in your own hand on the receipt.
>
> Death notices are not sent to valuers.

> **Постановка:** O4 — не «нейтральна» гілка. Некролог приходить **у всіх чотирьох**;
> у O1–O3 він іде другим абзацом після події. Це той самий «малий поштовх» із §3 сюжету.

---

## 9. ХИБНИЙ СЛІД

**Що спокушає.** Ярлик на поперечці: *«Relined and cleaned; the loss along the fracture filled
and retouched. Werkstatt A. Kolb, 1890»*. Реставрація **на рік пізніша** за інвентаризацію
1889. І ярлик каже прямим текстом дві речі, які складаються самі: **«тріщину зашпаклювали й
записали»** та **«полотно дублювали»**. Гіпотеза виникає сама і дуже гарна:
*стару тріщину зашпаклювали, а нову підмалювали з іншого боку обличчя — тобто нам підсунули
або перероблене, або зовсім інше полотно.*

**Куди веде.** До графи `s.identity = o.copy_after_1890` і до `s.record_verdict = o.made_to_mislead`.
Гравець витрачає на це 6–8 хвилин і почувається розумним: у нього є дата, майстерня і мотив.

**Чим спростовується — двома незалежними речами.**
1. **Фізично.** Косе світло (`f.canvas_craquelure`): тріщина **піднята через ґрунт**, обидві губи
   задерті, і вона **роздвоюється на три** біля коміра. Намальована тріщина не деформує ґрунт.
   А той самий трипалий розділок біля коміра видно **й на відбитку** (`f.print_crack_left`) —
   дзеркально, але той самий. Одну й ту саму тріщину не малюють двічі з двох боків обличчя.
2. **Документально.** Гросбух (`f.daybook_restoration`): «No. 212 to Kolb, 4 March. Returned
   27 May. Four gulden, paid.» Реставрацію **замовило саме бюро**, вона в книзі, і номер той самий.
   Ярлик не приховує — ярлик звітує.

**Чому це чесний хибний слід, а не декорація.** Він дає власну числову графу (`s.days_out = 84`),
тобто гравець мусить **дочитати** гросбух, щоб заповнити бланк, — і рівно в цю мить слід вмирає
в нього в руках. Спростування не приходить ззовні; воно лежить у тому самому рядку, по який
гравець прийшов за цифрою.

---

## 10. ДВІ ГІПОТЕЗИ І РОЗВОДЖУВАЛЬНИЙ ФАКТ

**(А) Річ не та.** Запис 1889 і знімок при ньому описують портрет із тріщиною на одному боці
обличчя; на мольберті — портрет із тріщиною на другому. Отже за одинадцять років полотно
підмінили (або переписали при дублюванні 1890 року), а вдова принесла не те, за що просить
печатку. **(Б) Річ та, а картка бреше** — точніше, картка **показує неправду, не кажучи її**:
фотовідбиток надруковано **крізь скло**, дзеркально, тому все на ньому перекинуто зліва направо.
Обидві гіпотези до кінця живі: розміри збігаються (це не доказ — копію роблять у розмір),
ярлик реставратора підпирає (А), перевернуті літери підпирають (Б), але й підробник міг би
підсунути дзеркальний знімок, щоб виправдати розбіжність. **Розводить одна річ, і вона фізична:**
негатив **№ 473** із того самого ящика III, на який картка сама посилається олівцем.
Матовий бік до ока, свічка позаду — і продряпаний фотографом номер читається **прямо**, а
тріщина на негативі лежить **праворуч від глядача, як на полотні**. Номер на негативі й номер
на відбитку — **один і той самий 473**: значить, відбиток зроблено з цього негатива, значить
знімали **це полотно**, значить (А) мертва; а на відбитку той самий номер стоїть **навиворіт** —
значить перевернуто **відбиток**, а не річ. Одна пластина вбиває обидві половини суперечності
з двох різних боків.

---

## 11. СТРИБОК ДУМКИ

Гравець сам виводить, що **розійшлися не річ і запис, а два способи стояти перед обличчям**:
слово «ліве» в книзі належить тому, кого малювали, а картинка в книзі надрукована навпаки, —
і те, що виглядало як брехня архіву, було двома чесними речами, прочитаними з не того боку.

---

## 12. ВХІД

Три двері, всі діегетичні, жодної підказки.

1. **Трафарет на підрамнику.** Коли гравець ставить портрет на мольберт і повертає зворотом
   (перше, що роблять із картиною), на поперечці стоїть **«212»** казенною чорною фарбою —
   рука бюро. Клієнтка, не питана: *"There is a number on the back. My husband's father said your
   office had it once, when the bank was difficult."* → гравець іде до реєстру 1889.
2. **Загнутий ріг першого аркуша.** Реєстр відкривається сам на титульному аркуші з друкованою
   передмовою, бо **ріг загнуто й придавлено** — попередником, давно. Гравець читає конвенцію
   *до* того, як побачить суперечність, і не розуміє, навіщо. Через двадцять хвилин зрозуміє.
   (Той самий прийом закладки, що в справі 3, — і це навмисно: він уже знає, що загнута сторінка
   в цьому бюро щось значить.)
3. **Олівець на картці.** Під рядком писаря — *«Neg. 473 — Kasten III»*. На архівній полиці
   стоять ящики, підписані I, II, III, IV. Пластина 473 лежить у своїй паперовій обгортці
   з друкованою інструкцією виробника. Свічка вже горить на архівному столі — вона горіла там
   усі чотири попередні справи, і її **жодного разу не можна було взяти в руку**. Тепер можна.

---

## 13. ТЕХНІЧНІ ДРІБНИЦІ, ЩОБ НЕ ПИТАТИ

- **Новий інструмент** `tool.candle`: `verb = OBSERVE`, `magnify = 1.0`, `radius = 0.06`,
  `dwell` задається правилом, `exclusive_with = [tool.rake]` (косе світло гасне, коли береш
  свічку), `on_papers = true`, `uses_max = -1`. Оверлей — мальоване тепле світло на просвіт.
  Розблоковується подією `case_05_start` (не фактом).
- **Стан `emulsion`** зони `z.plate.face` малюється **іншим спрайтом пластини** (матовий бік,
  номер прямо), не дзеркаленням текстури кодом. Дзеркальний варіант — окремий мальований файл.
  Правило 1 проєкту: жоден піксель не робиться кодом.
- **`z.plate.face` початковий стан — `default` (склом до ока)**. Це важливо: перший погляд
  гравця має бути хибним.
- **Свічка на полотні** (r.17) навмисно нічого не дає: полотно дубльоване, наскрізь не світить.
  Один рядок репліки — і гравець розуміє, що просвіт існує не для картин.
- **Дублі фактів** ловить `add_fact()`. `f.print_crack_left` і `f.canvas_crack_right` — **різні**
  факти (різні об'єкти спостереження), не переплутати.
- **Локалізація:** `cvals` тримає `o.*`, ніколи англійський рядок. Числові графи зберігають `int`.
- **Порядок екранів у `_sync_view`:** EASEL ↔ BACK — переворот тієї самої речі (стан екрана,
  не окрема сцена). ARCHIVE і PLATE — окремі екрани, PLATE відкривається з полиці ящиків.
