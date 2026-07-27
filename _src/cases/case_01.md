# СПРАВА 1 — «СРІБНИЙ КЕЛИХ» (урізаний)

**Хронометраж:** 20 хв · **Акт I, перша справа** · **Роль:** туторіал з одним чесним стрибком думки.
**Що вона вчить:** інструмент діє на зону · зона дає СПОСТЕРЕЖЕННЯ, не висновок · довідник —
не декорація, а джерело · числова графа не вгадується · печатка незворотна.
**Що вона НЕ робить:** нема пропилу, реактиву, гідростатики, стратиграфії, монограми, свинцю.
Усе це — справа 8 (той самий арт, той самий предмет, новий шар). Дивись `SIUZHET_ZAHADKY_V6.md` §4.8.

**Ритм (орієнтир для плейтесту):**

| хв | що |
|---|---|
| 0:00 | клієнтка в кабінеті, чотири репліки, келих і квитанція лягають на стіл |
| 2:00 | келих у руки (HANDS), лупа на спід → два клейма |
| 4:30 | реєстр майстерень → Гоффманн 1859–1871 |
| 6:00 | довідник знаків (загнутий ріг сторінки) → хронологія Відня. **Стрибок ≈ 7:00** |
| 8:00 | горбики на верху піддона (рука), тоді лупа → однакові |
| 11:00 | квитанція 1807 → штангенциркуль і терези → розміри не сходяться |
| 14:00 | атестат: 6 граф, дві числові, «на підставі» — перетягування |
| 18:00 | печатка. Дві секунди тиші. Штамп у гніздо. День гасне |

---


> ## ✅ 26.07: КЛЕЙМО ДІАНИ ДОМАЛЬОВАНО — РОЗВИЛКУ ЗАКРИТО ВАРІАНТОМ 1
>
> Перевірено картою зон і оглядом текстур. На `foot_plate_maker.png` стоїть **щит майстра
> і зачищена пляма**, а під косим світлом (`foot_plate_church.png`) у плямі проступає
> **потир із хрестом** — зішліфоване церковне клеймо. Це зроблено добре й працює.
>
> **Голови Діани з цифрою 3 і літерою A всередині контуру в арті НЕ БУЛО — тепер є**
> (`foot_plate_maker_v2.png`, `foot_plate_church_v2.png`, додано правкою наявної пластини). А саме на ній
> тримається §10 «Стрибок думки»: літера всередині = не раніше 1872, реєстр закриває
> Гоффманна 1871, отже клейма молодші за майстерню. **Гравець цієї дедукції зробити не може
> — йому нема на що дивитися.**
>
> Реалізована зараз простіша загадка: «хтось зішліфував церковне клеймо». Вона чесна, але
> в ній нема суперечності, лише знахідка.
>
> **Зроблено:** клеймо Діани домальовано й підключено, під лупою читаються цифра 3 і
> літера A всередині контуру. Справа 1 стала двошаровою: підроблене датування (клейма
> молодші за майстерню) + зішліфоване церковне клеймо під косим світлом.
>
> **Лишається привести текст документа до арту:** тут клеймо майстра — це **ЩИТ із
> монограмою**, а не «прямокутник зі зрізаними кутами L·HOFFMANN». Саме щит гра звіряє
> з коміркою каталогу. Правдивий арт — правити треба §4 (`f.mark_maker`).

## 1. КЛІЄНТ

**Катаріна Райтгофер**, 34, у чорному, стоїть, хоча стілець є.
Ім'я **вписує сам гравець** у квитанцію бюро — до того, як воно з'явиться десь іще.

**Названа потреба, з річчю не пов'язана:**
> "The burial ground wants eight gulden by Saturday. After Saturday my father goes into the
> common ground and they do not mark where."

**Фізична деталь, яку кадр показує і жоден текст не коментує:**
на лівому рукаві **чорна жалобна пов'язка, пришита поверх старішої, вигорілої** — той самий
рукав уже був у жалобі. Свіжа нитка, стара нитка. Ніхто цього не називає.

**Чотири репліки (одна — неправда, і вона неправда сумлінна):**
1. "It stood in my grandmother's press. I never saw anyone drink from it."
2. "There is a paper with it. My great-grandmother's paper. It goes with the cup." → кладе квитанцію
3. "A man on the Graben said ninety gulden **if it is what the paper says**." → *це правда*
4. "It has never been out of the family." → **неправда**, і вона в неї вірить

**Дві репліки на печатку:**
- **швидко (< 6 хв від приходу):** "Thank you. You did not even stop to doubt it."
- **довго (> 14 хв):** "I thought you were going to tell me no. I had the words ready."

**Повертається** у справі 8 — у коридорі, за спиною констебля, і не дивиться (V6 §4.8).

---

## 2. ЗОНИ ПРЕДМЕТА

Модель `goblet_pivot`, **1 локальна одиниця = 100 мм**. Келих 196 мм: низ піддона `y = −0.98`,
вінця `y = +0.98`. Вісь Z — на камеру. Формат полів — `ENGINE_SPEC.md` §1.2.

| id зони | де саме | вид | координати | радіус | екран · інструменти |
|---|---|---|---|---|---|
| `z.cup.whole` | увесь келих на сукні стола | **2d** (img) | `surface: case_desk`, `u = (0.508, 0.470)`, `shape: rect`, `half = (0.088, 0.262)` | — | DESK · caliper, scales, hand |
| `z.bowl.inner` | внутрішня поверхня чаші | 3d | `p = (0, 0.55, 0)`, `n = (0, 1, 0)` | `r = 0.34`, `facing_min = 0.20` | HANDS · eye, loupe, rake |
| `z.stem.knop` | нодус на стояку | 3d | `p = (0, −0.36, 0.10)`, `n = (0, 0.15, 0.99).normalized()` | `r = 0.13`, `facing_min = 0.05` | HANDS · eye, loupe, rake |
| `z.foot.top` | похила ВЕРХНЯ площина піддона | 3d | `p = (0, −0.86, 0.28)`, `n = (0, 0.80, 0.60).normalized()` | `r = 0.20`, `facing_min = 0.10` | HANDS · hand, rake, loupe |
| `z.foot.underside` | спід піддона, місце клейм | 3d | `p = (0, −0.69, 0)`, `n = (0, −1, 0)` *(виміряно з моделі 26.07: вгнуте дно піднімається до −0.69; специфікаційні −0.96 хибили на 77 px)* | `r = 0.45` *(порахований: клейма на 0.289 і 0.227 від осі; 0.22 не накривав би майстрове)* | HANDS · loupe, rake |
| `z.foot.edge` | вузький вертикальний рант по краю піддона | 3d | `p = (0, −0.93, 0.52)`, `n = (0, −0.30, 0.95).normalized()` | `r = 0.075`, `facing_min = 0.05` | HANDS · rake, loupe |

> **Залізна вимога до 3D-макета:** `z.foot.underside` і `z.foot.top` мусять стояти на **однаковій
> відстані від осі** (тут 0.28 = 28 мм). Горбик — це буквально зворот клейма. Якщо художник зсуне
> клейма ближче до краю, зони їдуть разом. Уся справа тримається на цій тотожності.

**Зони документів і довідників** (той самий рушій, `tool: &"*"`, `on_click: true`):

| id зони | де | вид | координати | екран |
|---|---|---|---|---|
| `z.papers.receipt` | квитанція 1807 (окремий екран DOCS_RECEIPT, вхід із теки) | 2d | `surface: paper_receipt_1807`, `u = (0.500, 0.430)`, `r = 0.190` | DOCS_RECEIPT |
| `z.papers.letter` | лист клієнтки в теці *(внесено з гри 26.07)* | 2d | `surface: letter_client`, `u = (0.50, 0.42)`, `rect half = (0.34, 0.26)` | DOCS |
| `z.news.robbery` + 4 зони-статті | газета: крадіжка в ризниці — факт; ще 4 матеріали читаються без фактів *(внесено з гри 26.07)* | 2d | `surface: newspaper_final` | NEWS |
| `z.book.register` | рядок HOFFMANN у реєстрі майстерень | 2d | `surface: reg_page_h`, `u = (0.315, 0.560)`, `shape: rect`, `half = (0.280, 0.045)` | BOOK_REG |
| `z.book.marks` | віденська сторінка довідника знаків | 2d | `surface: marks_page_vienna`, `u = (0.660, 0.480)`, `shape: rect`, `half = (0.300, 0.230)` | BOOK_MARKS |

**Інструменти справи 1** (6, і це навмисно мало):

| id | verb | видається | нотатка |
|---|---|---|---|
| `tool.eye` | OBSERVE | завжди | голе око, `radius 0.09` |
| `tool.hand` | OBSERVE | завжди | обмацати / перевернути; `on_click` |
| `tool.loupe` | OBSERVE | шухляда кабінету (Хвиля 0) | `magnify 4.3`, `radius 0.045` |
| `tool.rake` | OBSERVE | нахилити лампу, перша дія гри | косе світло, мальований оверлей |
| `tool.caliper` | MEASURE | `unlocked_by: f.receipt_1807` | ноніус; **дає число, не висновок** |
| `tool.scales` | MEASURE | `unlocked_by: f.receipt_1807` | ваги в повітрі, грами. **Мусять чесно відпрацювати — на цьому тримається справа 10** |

---

## 3. ПРАВИЛА (зона × інструмент → факт)

`note` — це `say_key`: рядок, який гравець бачить під рукою і який лягає в нотатник.
**Жоден note не містить висновку.**

| zone_id | tool | requires | fact_id | note (EN, спостереження) | sets_state |
|---|---|---|---|---|---|
| `z.cup.whole` | `tool.caliper` | — | `f.height_196` | "Height, lip to table: 196 mm. Foot: 104 mm across." | — |
| `z.cup.whole` | `tool.scales` | — | `f.weight_331` | "On the balance: 331 g. It sits still at once." | `repeat: true` |
| `z.cup.whole` | `tool.hand` | — | — | → перехід на екран HANDS | `screen = HANDS` |
| `z.bowl.inner` | `tool.eye` \| `tool.loupe` | — | `f.bowl_gilt` | "The inside of the bowl is gilded. The gilding is thin in a crescent under one side of the lip." | — |
| `z.stem.knop` | `tool.eye` \| `tool.rake` | — | `f.knop_form` | "The stem swells into a knop the size of a walnut, cast in two shells and soldered round the girdle." | — |
| `z.foot.underside` | `tool.loupe` (`dwell 0.5`) | — | `f.mark_maker`, `f.mark_diana` | "Two punches, one under the other. A shield, and within it a winged monogram set between two letters. Beside it a woman's head in profile — a numeral 3 stands before the chin, and the letter A stands **inside the same outline**." *(приведено до арту 26.07)* | — |
| `z.foot.underside` | `tool.loupe` (`dwell 1.2`) | `f.hb_vienna_marks` | `f.marks_alone` | "The rest of the underside is bare. No third punch, no figures, and no bright patch where one had been taken off." | — |
| `z.foot.top` | `tool.hand` (`on_click`) | `f.mark_diana` | `f.domes` | "A finger run across the slope of the foot catches on two small domes in the metal — one behind each punch." | `z.foot.top → raised` |
| `z.foot.top` | `tool.loupe` \| `tool.rake` | `f.domes` | `f.domes_alike` | "Both domes rise to the same height and break at the same sharp shoulder." | — |
| `z.foot.underside` | `tool.loupe` (`dwell 0.5`) під **косим світлом**, потребує `f.mark_maker` | — | `f.church_mark` | "Where the silver was ground smooth, the raking light finds it: an engraved chalice — a church's mark." *(додано 26.07: правило було в грі й в арті, але не в цій таблиці)* | — |
| `z.foot.edge` | `tool.rake` (`dwell 0.8`) | — | `f.foot_edge_plain` | "The band round the edge of the foot is plain. Under raking light there is no lettering, and no shadow where lettering was taken off." | — |
| `z.papers.receipt` | `tool.loupe` \| `tool.eye` (`on_click`) | — | `f.receipt_1807` | "Receipt, Vienna, 12 March 1807, duty paid on re-marking: *one becher, silver, 13 löthig, weight 14 loth, height 8 zoll 4 linien* — for Anna Reithofer." | видає caliper + scales |
| `z.papers.receipt` | `tool.caliper` (`on_click`) | `f.receipt_1807`, `f.height_196`, `f.weight_331` | `f.receipt_mismatch` | "By the table on the wall: the becher of the receipt stands 219 mm and weighs 246 g. The cup on the desk stands 196 mm and weighs 331 g." | — |
| `z.book.register` | `*` (`on_click`) | `f.mark_maker` | `f.reg_hoffmann` | "Register of Vienna workshops: HOFFMANN, Leopold — silversmith. Mark entered 1859. Mark struck out 1871." | — |
| `z.book.marks` | `*` (`on_click`) | `f.mark_diana` | `f.hb_vienna_marks` | (повний текст сторінки — див. §6, таблиця Б) | — |

**Правила без факту** (потрібні для входу і для «нема глухих кутів»):

| zone_id | tool | requires | ефект |
|---|---|---|---|
| `z.foot.top` | `tool.eye` | — | say: "The lamp puts two small bright points on the slope of the foot." — **діегетичний вказівник на зону, без факту** |
| `z.foot.top` | `tool.hand` | немає `f.mark_diana` | say: "Smooth, and something under the finger. Nothing to say about it yet." — не дає факт до того, як гравець побачив клейма |
| `z.book.register` | `*` | немає `f.mark_maker` | say: "Four hundred names. Without a name to look for this is a wall." |

**Дороги до того самого факту** (один факт = один id, `add_fact()` ловить дублі):
`f.domes_alike` — і `loupe`, і `rake`. `f.bowl_gilt` — і `eye`, і `loupe`.
`f.receipt_mismatch` — вимагає обидва виміри, але викликається з квитанції будь-яким із двох MEASURE.

---

## 4. ФАКТИ

`text` — рядок нотатника. `cite` — коротка форма, яка лягає в графу «на підставі».
`weight` — вага в OUTCOMES (`ENGINE_SPEC` §1.6).

| fact_id | text (EN, спостереження) | cite (EN) | tag | weight |
|---|---|---|---|---|
| `f.mark_maker` | "A punch struck into the underside of the foot: a shield, and within it a winged monogram set between two letters." *(приведено до арту 26.07: на пластині ЩИТ із крилатою монограмою, а не прямокутник із написом. Саме цей щит гравець шукає в каталозі, і збіг дає «Hoffmann, Wien».)* | "the maker's shield on the foot" | `marks` | 1 |
| `f.mark_diana` | "Beside it, a woman's head in profile. A numeral **3** stands before the chin. The letter **A** stands **inside the same outline**, under the throat." | "the letter set inside the head" | `marks` | 2 |
| `f.marks_alone` | "The rest of the underside is bare. No third punch, no figures, no bright patch where one had been taken off." | "no earlier assay punch on the piece" | `marks` | 2 |
| `f.reg_hoffmann` | "Register of Vienna workshops: HOFFMANN, Leopold — silversmith. Mark entered 1859. Mark struck out 1871." | "the register: Hoffmann, 1859 to 1871" | `books` | 2 |
| `f.hb_vienna_marks` | "Handbook, Vienna assay office. 1807–1866: a punch with the last two figures of the year, the fineness in loth, and the office letter. From 1867: Diana's head with a numeral (1 = 950, 2 = 900, 3 = 800, 4 = 750) and no year at all. From 1872 the office letter is cut **inside** the head's outline; before 1872 it was struck as a separate punch beside it." | "the handbook of Vienna marks" | `books` | 2 |
| `f.domes` | "Two small domes stand up on the slope of the foot, one behind each punch." | "two domes on the top of the foot" | `body` | 2 |
| `f.domes_alike` | "Both domes rise to the same height and break at the same sharp shoulder." | "both domes alike, to the shoulder" | `body` | 3 |
| `f.foot_edge_plain` | "The band round the edge of the foot is plain. Under raking light there is no lettering, and no shadow where lettering was taken off." | "the foot band bears no lettering" | `body` | 1 |
| `f.bowl_gilt` | "The inside of the bowl is gilded. The gilding is thin in a crescent under one side of the lip." | "the bowl is gilt inside" | `body` | 1 |
| `f.knop_form` | "The stem swells into a knop the size of a walnut, cast in two shells and soldered round the girdle." | "a knop on the stem" | `body` | 1 |
| `f.height_196` | "Height, lip to table: 196 mm. Foot: 104 mm across." | "196 mm on the caliper" | `measure` | 1 |
| `f.weight_331` | "On the balance: 331 g." | "331 g on the balance" | `measure` | 1 |
| `f.receipt_1807` | "Receipt, Vienna, 12 March 1807, duty paid on re-marking: *one becher, silver, 13 löthig, weight 14 loth, height 8 zoll 4 linien* — for Anna Reithofer." | "the re-marking receipt of 1807" | `papers` | 1 |
| `f.receipt_mismatch` | "The becher of the receipt stands 219 mm and weighs 246 g. The cup on the desk stands 196 mm and weighs 331 g." | "the receipt is 219 mm, the cup is 196" | `papers` | 2 |
| `f.letter_read` | "She writes: from an aunt in the monastery, and she is told it is Viennese." *(внесено з гри 26.07)* | "the client's own letter" | `papers` | 1 |
| `f.news_robbery` | "St. Onuphrius' sacristy, broken into. Among the missing: antique silver goblets." *(внесено з гри 26.07)* | "the Herald of 14 March on the sacristy" | `papers` | 1 |
| `f.church_mark` | "Where the silver was ground smooth, the raking light finds it: an engraved chalice — a church's mark." | "the effaced church mark beneath" | `marks` | 3 |

**17 фактів** *(з 26.07: + `f.church_mark`, `f.letter_read`, `f.news_robbery`)*. Жоден рядок не містить слів *plated, false, forged, stolen, later, therefore*.

---

## 5. ДОВІДНИКОВІ ТАБЛИЦІ

### А. Реєстр віденських майстерень (вигадані рядки в реальному форматі)

Читається на екрані BOOK_REG. Формат — як віденські цехові списки: прізвище, фах, рік запису,
рік викреслення. **Усі імена вигадані** (див. §13, застереження про Йозефа Гоффманна).

| Name | Trade | Mark entered | Mark struck out |
|---|---|---|---|
| HAAS, Ferdinand | silversmith | 1841 | 1863 |
| HERTL, Anton | goldsmith, silversmith | 1855 | 1889 |
| **HOFFMANN, Leopold** | **silversmith** | **1859** | **1871** |
| HOLZER, Michael | silversmith | 1868 | 1902 |
| HUBER, Karl & Son | silver, plated ware | 1874 | — |

### Б. Знаки віденської пробірної управи — **історично правдиве**

Це та сторінка, яку читає `z.book.marks`. Текст іде в гру дослівно.

| Період | Що б'ють | Джерело |
|---|---|---|
| до 1806 | міське цехове клеймо + клеймо майстра | silvercollection.it |
| **1806 — 1 серпня 1807** | **репунцирування**: старе срібло здають на переклеймування, знак = квитанція про сплачене мито. Обов'язкове переклеймування скасовано 1.08.1807 | silvercollection.it |
| **1807–1866** | у знаку: **дві останні цифри року** + проба **в лотах** + літера управи (**A** = Відень) | silvercollection.it |
| **з 1867** | **«голова Діани»** з цифрою проби: **1 = 950, 2 = 900, 3 = 800, 4 = 750**. **Року в знаку більше нема** | silvercollection.it |
| **1867–1872** | літера управи — **окремим пуансоном поруч** із Діаною | 925-1000.com |
| **з 1872** | код управи **повернуто ВСЕРЕДИНУ** пуансона Діани (та «дрібного знака») | silvercollection.it, 925-1000.com |

**Літери управ:** `A` = Wien — певно. Інші коди (Прага, Будапешт тощо) **не звіряти напам'ять** —
див. §13. Для справи 1 потрібна лише `A`.

⚠️ **Виняток, який НЕ ламає загадку і мусить бути на тій самій сторінці, щоб гра була чесною:**
після 1872 окремі літери управи **далі трапляються** на дрібних і складених виробах (ніжки,
ручки, накривки — щоб кожна частина мала свою пробу). Тобто «літера окремо» **не датує** нічим.
А от **літера всередині знака** буває **тільки з 1872**. Висновок односторонній — і саме тому
працює. Рядок довідника англійською:
> "On small work and on pieces made of several parts the office letter is still struck separately
> after 1872, so that each part carries its own. The letter cut **within** the head is not met
> before that year."

### В. Старі віденські міри (окрема табличка на стіні над столом, читається завжди)

| Одиниця | Метрично |
|---|---|
| 1 Wiener Fuß | 316.08 мм |
| 1 Wiener **Zoll** = ¹⁄₁₂ Fuß | **26.34 мм** |
| 1 **Linie** = ¹⁄₁₂ Zoll | **2.195 мм** |
| 1 Wiener **Mark** | **280.644 г** |
| 1 **Loth** = ¹⁄₁₆ Mark | **17.54 г** |
| проба в лотах: 16-лötig | 1000 / 1000 |
| 13-лötig | 812.5 / 1000 |

**Арифметика квитанції (гравець робить її сам, гра ніде її не показує):**
8 Zoll 4 Linien = 8 × 26.34 + 4 × 2.195 = **219.5 мм** · 14 Loth = 14 × 17.54 = **245.6 г**.
Келих: **196 мм**, **331 г**. Розбіжність 23 мм і 85 г — це не похибка ноніуса.
Дрібний бонус для уважних: квитанція каже **13-лötig = 812.5**, а Діана каже **3 = 800**.

---

## 6. АТЕСТАТ — 6 граф

`kind` за `core/slots.gd`: CHOICE / NUMBER / FACTS. Варіанти — **id**, на папір лягає `tr("opt." + id)`.

| # | id графи | префікс (EN) | тип | гейт | варіанти |
|---|---|---|---|---|---|
| 1 | `s.origin` | "Wrought at ____" | CHOICE | `needs: [f.mark_maker, f.reg_hoffmann]` | `o.vienna_hoffmann` "Vienna — the workshop of L. Hoffmann" · `o.vienna_unrecorded` "Vienna — a hand not in the register" · `o.outside_empire` "Outside the Empire; the marks were added here" |
| 2 | `s.fineness` | "Fineness **claimed by the mark**: ____ in 1000" | **NUMBER** `digits 3, min 100, max 999` | `needs: [f.mark_diana, f.hb_vienna_marks]` | нема списку. *(істина: **800**)* |
| 3 | `s.not_before` | "The marks were struck not earlier than ____" | **NUMBER** `digits 4, min 1700, max 1900` | `needs: [f.mark_diana, f.hb_vienna_marks]` | нема списку. *(істина: **1872**)* |
| 4 | `s.marks` | "The marks were struck ____" | CHOICE | `needs_any: [f.domes]` | `o.on_the_flat` "on the flat metal, before the vessel was raised" · `o.by_office_later` "on the finished vessel, at the assay office" · `o.after_the_fact` "on the finished vessel, by a hand that was not the office's" |
| 5 | `s.provenance` | "The piece reached the bearer ____" | CHOICE | `needs_slot: [s.marks]` | `o.honest_inheritance` "by inheritance, as she states" · `o.legally_remarked` "as old plate, lawfully re-marked at a later sale" · `o.taken_from_church` "out of a church, and worked upon after it left" · `o.made_to_look_stolen` "as new work, carrying the marks of church plate" |
| 6 | `s.basis` | "On the strength of:" | FACTS `min 2, max 4` | `needs_slot: [s.provenance]`, `clears_on: [s.provenance]` | джерело — `state.fact_order`, без групи `strat` |

**Три залізні правила діють:** NUMBER без валідації й без фідбеку · CHOICE тримає id · FACTS
не має власних варіантів. Після печатки — **нуль** зворотного зв'язку. Правильність вирішує ранок.

---

## 7. НАСЛІДКИ (ранок наступного дня)

Матчер бере **перший** запис, що збігся. `out.default` — завжди останній.

| # | id | when | basis | текст ранку (EN) |
|---|---|---|---|---|
| 1 | `out.forgery_named` | `s.marks = o.after_the_fact` · `s.not_before = 1872` · `s.provenance = o.made_to_look_stolen` | `basis_any: [f.domes_alike, f.marks_alone]`, `basis_weight: 5` | "A dealer in the Judengasse writes. On Tuesday a man offered him the cup at a third of its silver and told him it had come out of a church at Pressburg. He read your certificate and did not buy. He asks — politely, and then again — who else you have written for. Frau Reithofer's eight gulden were found by the parish. The grave is marked." |
| 2 | `out.forgery_loose` | `s.provenance = o.made_to_look_stolen` | — | "The dealer did not buy, and did not answer your letter. A clerk at the assay office in Vienna returned your certificate by the second post. There is one pencil line in the margin, drawn against a single figure, and no signature under it." |
| 3 | `out.church_named` | `s.provenance = o.taken_from_church` | `basis_forbids: [f.domes_alike]` | "Two constables at eight. They took the cup, the certificate, and Frau Reithofer, who had come back to ask whether there was more to pay. No church in the city reports a cup missing. The file stays open until one does. Her father went into the common ground on Saturday." |
| 4a | `out.sold_clean` | `s.provenance = o.honest_inheritance` | — | (текст нижче) |
| 4b | `out.sold_clean` | `s.provenance = o.legally_remarked` | — | "The cup sold on Thursday, ninety gulden, to a house on the Graben. They copied your certificate into their book and spelled your name correctly. Frau Reithofer paid the burial ground and sent up a note of one line. On Friday the same house wrote to ask whether you would look at four more pieces from the same seller." |
| 5 | `out.default` | `{}` | — | "Nothing came in the morning post. The cup went out at eight in the same shawl, and she said nothing at all about it. The ledger line for the day reads: sealed, one." |

Гілка **4** — найстрашніша, і саме тому вона мусить читатися як удача. Гра не каже, що гравець
помилився; вона каже, що млин запрацював. Це задає тон усім одинадцяти справам.

---

## 8. ХИБНИЙ СЛІД

**Що спокушає:** квитанція про **репунцирування 1807 року**, яку клієнтка кладе на стіл сама.
Папір **справжній**: правильний формат, правильне мито, правильне вікно (обов'язкове
переклеймування діяло до 1.08.1807), правильне ім'я прабабусі. Гравець одразу отримує
пояснення, що знімає всю суперечність: **річ старша за 1807, а Діана з'явилась пізніше й
законно** — отже пізніше клеймо не злочин, а формальність.

**Куди веде:** просто в `o.legally_remarked` і в гілку наслідків 4 — «продано, все добре,
принесіть ще чотири».

**Чим спростовується:** квитанція описує **інший келих**. 8 Zoll 4 Linien = 219.5 мм і 14 Loth
= 245.6 г; на столі 196 мм і 331 г. Папір справжній — він просто не про цю річ.
Спростування коштує двох вимірів і однієї таблиці на стіні; воно **не безкоштовне** й потребує
двох інструментів, які до цієї миті лежали без діла.

**Чому це чесний хибний слід, а не декорація:** він (а) пояснює **все**, що гравець уже знайшов;
(б) видається клієнткою, тобто виглядає як доказ на її користь; (в) має власну гілку наслідків;
(г) спростовується вимірюванням, а не «здогадкою». І (д) — він **не бреше**: квитанція
справжня, бреше тільки припущення, що вона про цей келих. Це той самий прийом, що потім
у справі 3 (лист дядька про *інший* годинник) і в справі 9 (одруківка в некролозі).

---

## 9. ДВІ ГІПОТЕЗИ І РОЗВОДЖУВАЛЬНИЙ ФАКТ

**(А) Стара чесна річ, законно переклеймована пізніше.** Гоффманн зробив келих між 1859 і 1871;
на пізнішому перепродажі (або за квитанцією 1807, якщо в неї повірити) річ подали в управу
вдруге, і на неї лягла Діана нового зразка. Знак пізніший за майстерню — але це не злочин,
а канцелярія. **(Б) Річ, на якій клейма набили постфактум.** Хтось узяв готовий келих і
поставив на нього обидва знаки разом, щоб він читався як стара віденська робота.
Обидві гіпотези пояснюють і клеймо Гоффманна, і Діану з літерою всередині, і відсутність
раннього пробірного знака (управа могла старий знак не чіпати; річ могла ніколи не проходити
управу). Розводить їх **одне**: `f.domes_alike` — **горбик за клеймом майстра однаковий із
горбиком за Діаною**. Пробірна управа ніколи не б'є клеймо майстра — це не її знак; отже якби
гіпотеза А була правдива, знак Гоффманна був би набитий на плоскій заготовці до підняття посудини
(без горбика), а Діана — по готовому (з горбиком), і горбики були б **різні або один**. Вони
однакові й на однаковій відстані від осі — значить обидва знаки набила **одна рука, одного дня,
по готовій речі**. Майстерня, викреслена 1871-го, не могла набити пуансон, який існує **з 1872**;
управа не могла набити клеймо майстра. Лишається третя рука.

---

## 10. СТРИБОК ДУМКИ

Обидва горбики однакові — отже клеймо майстра таке ж молоде, як пробірне: не стару річ
переклеймували, а нову річ зробили старою.

---

## 11. ВХІД (як гравець дізнається, що тут треба діяти)

Чотири діегетичні двері, жодної підказки:

1. **Клієнтка сама кладе квитанцію** і каже "It goes with the cup" — папери відкриті з першої хвилини.
2. **Довідник знаків уже лежить на столі розгорнутий**, з **загнутим рогом** віденської сторінки
   і **олівцевою рискою попередника під одним рядком** — під тим, що про 1872. Ризику зробив не
   гравець і не для гравця; попередник тут уже щось звіряв. (Той самий прийом, що в справі 3.)
3. **Лампа дає два дзеркальні відблиски на схилі піддона.** Це намальовано в арті, видно голим
   оком, і `tool.eye` на `z.foot.top` каже: *"The lamp puts two small bright points on the slope
   of the foot."* Без факту, без стрілки. Гравець сам візьме руку або косе світло.
4. **Штангенциркуль і ваги з'являються в поясі рівно тоді**, коли прочитано квитанцію
   (`unlocked_by: f.receipt_1807`): у документі є число в цолях — рука сама тягнеться до ноніуса.

**Гарантія від глухого кута:** якщо через 4 хвилини без нового факту — клієнтка переступає з
ноги на ногу й каже одну з двох реплік, що вказують на невикористаний **рід** дії, не на місце:
"You have not touched the paper." / "You may turn it over. It is only silver."

---

## 12. ГЕЙТ ЯКОСТІ

Свіжий агент-казуал проходить справу й мусить сказати **своїми словами**:
> «Клеймо майстра показалося наскрізь так само, як пробірне, — значить їх набили разом і по
> готовому келиху; а літера всередині знака буває тільки з 1872-го, коли майстерня вже три роки
> як закрита.»

Сказав «я перебрав інструменти й вписав, що знайшлось» — справа переробляється (`PUZZLES_V4` §0).

---

## 13. ДЕ Я САМ СУМНІВАЮСЯ (читати перед артом і перед кодом)

1. **Тремолірштих я навмисно ВИКИНУВ зі справи 1.** Зигзаг пробірника — реальна практика
   німецьких земель, але його присутність на віденському сріблі 1860–70-х **не універсальна**;
   будувати доказ на його відсутності — хитко. `PUZZLES_V4` §1.5 пропонував саме це. Замінено на
   відсутність **раннього пробірного знака** (`f.marks_alone`) — це перевірено й безпечно.
2. **Сам по собі горбик не доводить нічого.** Управа таки клеймувала готові вироби. Доказ
   тримається **не** на «клеймо набите по готовому», а на **тотожності двох горбиків**, тобто на
   тому, що клеймо МАЙСТРА теж молоде. Якщо на плейтесті виявиться, що гравці читають горбик як
   самостійний доказ, — переписати note `f.domes`, а не додавати інструмент.
3. **Літери управ, крім `A` = Wien, я не звіряв** і в довідник не ставлю. Перед артом сторінки
   BOOK_MARKS звірити повний список по 925-1000.com; поки що на сторінці лише `A`.
4. **Ім'я Гоффманн.** У V6 воно є, але **Йозеф Гоффманн (1870–1956)** — реальний і дуже відомий
   віденський дизайнер. Тому в справі майстер — **Leopold Hoffmann**, і в реєстрі поруч стоять
   HAAS, HERTL, HOLZER, HUBER, щоб прізвище читалось як рядок списку, а не як цитата (правило 4,
   IP-чек). Якщо Віктор захоче ще чистіше — замінити на **HOFFMEISTER**.
5. **Повне прізвище в пуансоні** — невелика вільність: віденські клейма майстрів частіше ініціали
   в фігурному щитку. Повне прізвище трапляється, але я взяв його заради **читабельності
   в реєстрі**: гравець мусить мати що шукати. Якщо історичніше — `L·H` у щитку, і тоді реєстр
   треба індексувати по ініціалах, що додає 2 хвилини й одну зайву фрустрацію в туторіалі.
   Моя рекомендація: лишити прізвище саме в першій справі, а з другої переходити на ініціали.
6. **Голова Діани: у який бік профіль** і де саме стоїть цифра — звірити по фото знаків перед
   тим, як художник намалює `foot_plate_marks`. У тексті я описав нейтрально («numeral before
   the chin, letter under the throat»), щоб текст не розійшовся з артом.
7. **331 г для келиха 196 мм** — правдоподібно для срібла 800 з важким піддоном, але цифру
   варто перерахувати, коли буде фінальна 3D-модель з товщиною стінки. Головне — щоб вона
   **не збіглася** з 245.6 г квитанції і **не спокушала** рахувати щільність: гідростатика
   з'явиться тільки у справі 8, і в справі 1 ваги дають число в повітрі, крапка.
