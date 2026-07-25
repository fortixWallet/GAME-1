# СПРАВА 6 — «ТЕРЕЗИ АПТЕКАРЯ»

**№:** 6 з 11 · **Хронометраж:** 35 хв · **Роль в акті:** друга справа після зламу довіри до
архіву (сп. 5). Тут ламається довіра до **приладу і до документа**: клеймо повірки справжнє,
папери в порядку, а річ бреше. Це підготовка до сп. 10, де прилад мовчить зовсім.

**Одним рядком:** у язичку коромисла (стрілці) — м'яка залізна вставка під перепаяним швом;
у підставці, під сукном, точно під індексом, — сталевий підковоподібний магніт із полюсами
догори. Магніт **тримає язичок у нулі**: стрілка стоїть рівно, поки різниця шальок не
перевищить 3 грани. Терези не брешуть — вони **глухі**, і глухі **тільки на своїй підставці**,
**на ту саму величину при будь-якій вазі**. Аптекар сипле порошок, доки стрілка вперше стане
рівно, — і щоразу віддає на 3 грани менше, ніж поставив різноважок. Двадцять два роки
прилад **погоджувався сам із собою щодня**, і саме це його переконало.

**⚠️ Фізична правка плану (обов'язкова, інакше справа не працює):** постійна сила, що тягне
плече вниз, **знімається встановленням нуля** — аптекар побачив би відхилення на порожніх
шальках першого ж дня, підкрутив гайку (або підклав тару) і тим скасував би магніт назавжди.
Тому магніт діє не як тяга плеча, а як **детент на залізному язичку**: стрілку притягує до
положення максимального потоку, тобто **рівно до нуля**. Такий рушій:
(1) не знімається виставлянням нуля — навпаки, нуль ідеальний;
(2) дає **мертву смугу** сталої ширини незалежно від вантажу;
(3) робить прилад **повторюваним і неточним одночасно** — точність без правильності;
(4) вимагає, щоб залізо було близько до магніту, а язичок пілярних аптечних терезів
    і проходить крізь індекс **біля самої підставки** (коромисло — на 20 см вище, до нього
    магніт із-під стільниці не дотягнеться взагалі).

**Технічна примітка (одне доповнення рушія, 4 рядки):** правилам цієї справи потрібна
перехресна умова на стан **іншої** зони. Додати необов'язкове поле
`zone_states: {zone_id: StringName}` у `RULES`, перевірка в `RuleEngine._ok()`:
`for z in r.get("zone_states", {}): if st.zone_st(z) != r["zone_states"][z]: return false`.
Без нього «зважити, поки терези на підставці» не виражається таблицею.

---

## 1. КЛІЄНТ

**Йоганн Ебергард, аптекар, 61 рік.** «Аптека під Оленем», тримає 22 роки — купив уже з
обстановкою у вдови попереднього власника.

**Названа потреба, не пов'язана з річчю:** він продає аптеку. Дружині приписали гори —
легені; на це потрібні гроші, а повірений покупця вимагає атестації обстановки. Терези —
рядок в описі, дрібниця, він приніс їх «щоб не було затримки в четвер».

**Фізична деталь, яку кадр показує і жоден текст не коментує:** суха біла лінія порошку в
складці лівої долоні; він двічі витирає її об полу й вона знову там. Ніготь великого пальця
згризений до м'яса.

**Він приносить:** терези, пригвинчені до червонодеревної підставки (не знімає — «не знімайте
з дошки, гвинти старі»), скриньку різноважок, і **паперовий пакетик, зроблений цього ранку**
власною рукою надписаний `Chin. sulph. gr. cxx` — «щоб ви бачили, як я працюю».

**Репліки на печатку:**
- **швидко (< 12 хв):** *"That was quick. My old master used to say a good balance tells you inside a minute."*
- **довго (> 25 хв):** *"You have weighed it four times. Nobody has weighed it since I bought the shop."*

---

## 2. ЗОНИ ПРЕДМЕТА

3D-зони — у локальних координатах `anchor: &"balance_pivot"` (одиниця ≈ 10 см натури).
Коромисло: центр обертання в `(0, 0.60, 0)`, плечі до `x = ±0.95`. Підставка (дошка):
верх на `y = −0.05`, розмір 1.6 (x) × 1.1 (z).

| id зони | де саме | вид | координати | радіус | інструменти |
|---|---|---|---|---|---|
| `z.beam.center` | середина коромисла, передня грань — клеймо повірки | `node3d` | `p(0.00, 0.62, 0.05)` `n(0,0,1)` | `r 0.11` `facing_min 0.10` | лупа, косе світло |
| `z.pointer.blade` | **язичок (стрілка)**, що звисає з середини коромисла крізь індекс — шов і опал лаку | `node3d` | `p(0.00, 0.20, 0.045)` `n(0,0,1)` | `r 0.10` `facing_min 0.10` | косе світло, лупа, компас |
| `z.beam.arm_right` | праве плече, низ — контроль (шва нема) | `node3d` | `p(+0.55, 0.585, 0.00)` `n(0,−1,0)` | `r 0.17` `facing_min 0.08` | косе світло, компас |
| `z.pan_left` | ліва шалька (товар) | `node3d` | `p(−0.92, 0.10, 0.00)` `n(0,1,0)` | `r 0.20` | — (ціль анімації, правил не має) |
| `z.pan_right` | права шалька (різноважки) | `node3d` | `p(+0.92, 0.10, 0.00)` `n(0,1,0)` | `r 0.20` | — (ціль анімації, правил не має) |
| `z.board.top` | верх підставки, вільне поле перед колонкою | `node3d` | `p(0.00, −0.05, 0.34)` `n(0,1,0)` | `r 0.42` | рука (зняти/поставити) |
| `z.board.under_mid` | **низ** підставки, передній центр — рівно під індексом і кінцем язичка: сукно | `node3d` | `p(0.00, −0.14, 0.32)` `n(0,−1,0)` | `r 0.26` `facing_min 0.06` | рука, компас, косе світло |
| `z.weights.box` | скринька різноважок, **етикетка у кришці** | `node3d` | `p(1.32, 0.06, 0.28)` `n(0, 0.35, 0.94)` | `r 0.22` | лупа |
| `z.weights.drachm` | драхмова різноважка, стоїть на лотку | `node3d` | `p(1.02, 0.02, 0.06)` `n(0,1,0)` | `r 0.075` | рука, лупа |

**Стани зон** (початковий завжди `&"default"`):

| зона | стани |
|---|---|
| `z.board.top` | `default` = терези на підставці · `off` = терези зняті, стоять на столі бюро |
| `z.obj.packet` (доп.) | `default` · `left` (у лівій шальці, зважено) · `both` (перекладено й зважено вдруге) |
| `z.obj.ounce` (доп.) | те саме |
| `z.weights.drachm` | `default` · `turned` (перевернута основою догори) |
| `z.board.under_mid` | `default` · `lifted` (сукно відігнуте, кишеня видна) |

**Допоміжні зони (не предмет):**

| id | екран | що це |
|---|---|---|
| `z.obj.packet` | HANDS | паперовий пакетик клієнта, `Chin. sulph. gr. cxx`, лежить на лотку |
| `z.obj.ounce` | HANDS | власна повірена унцієва гиря бюро (480 гранів), еталон для контролю |
| `z.desk.balance` | DESK | **власні терези бюро** (ті самі, що в справах 1 і 8), метричні |
| `z.papers.recipe` | DOCS | копія рецепта в теці клієнта, 11 березня |
| `z.book.units` | BOOK | таблиця медичної ваги (нюрнберзька), стор. з переліком |
| `z.book.eich` | BOOK | реєстр знаків повірочної управи |
| `z.book.gauss` | BOOK | посібник ваговимірювання, **загнутий кут** на «подвійне зважування» |

---

## 3. ІНСТРУМЕНТИ, ЯКІ ТУТ ПРАЦЮЮТЬ

| tool id | verb | новий? | що робить у цій справі |
|---|---|---|---|
| `tool.loupe` | OBSERVE | ні | клейма, шов, лак у лунці пуансона, етикетка |
| `tool.rake` | OBSERVE | ні | косе світло: шов і опалений лаковий обідок |
| `tool.hand` | APPLY | ні | зняти терези з дошки й поставити назад; перевернути різноважку; відігнути сукно (confirm) |
| `tool.compass` | OBSERVE | **так** | кишеньковий компас; вводиться цією справою, лишається в поясі |
| `tool.weigh` | MEASURE | **так** | виконати зважування: перше прикладання — у ліву шальку, друге — перекласти в праву |

`tool.compass`: `magnify 1.0`, `radius 0.05`, `dwell 0.6`, `on_papers false`, `needs_hands true`.
`tool.weigh`: `on_click true`, `uses_max −1`, `needs_hands true`; на `z.desk.balance` працює
як метричне зважування (грами), на предметі клієнта — як зважування його різноважками (грани).

**Знято з цієї справи свідомо:** `tool.caliper` (плечі коромисла однакові — вимір нічого не
розводить, бо зношений ніж лишає гіпотезу А живою; гіпотезу А вбиває сталість похибки,
а не мікрометр) і `tool.schwerter` (метал тут не питання).

---

## 4. ПРАВИЛА (зона × інструмент → факт)

`sets_state` — зміна стану зони (`sets_zone`). `zone_states` — перехресна умова (див. примітку
на початку). Правила без `fact_id` дають лише `say_key` — це навмисно: контрольні
спостереження, які нічого не доводять, мусять бути доступні, інакше «немає що перевіряти».

**Що робить одне прикладання `tool.weigh` (анімація, не текст):** різноважки лягають у другу
шальку до нуля, тоді рука **докладає наїзники по чверті грана**, доки язичок ворухнеться, і
знімає їх назад. Тому note цього інструмента — завжди **смуга**, а не одне число: гравець
бачить, від якої ваги до якої стрілка стоїть мертво. На столі бюро та сама анімація дає смугу
шириною нуль. Ніде не сказано «прилад глухий» — сказано, від скількох до скількох він мовчить (EN say-ключі — у таблиці нижче).

| # | zone_id | tool | requires | fact_id | note (EN, спостереження) | sets_state |
|---|---|---|---|---|---|---|
| R1 | `z.desk.balance` | `tool.weigh` `on_click` | — | `f.packet_short` | *His packet, inscribed gr. cxx in his own hand, weighs 7.27 g on the bureau balance.* | — |
| R2 | `z.weights.box` | `tool.loupe` `dwell 0.5` | — | `f.grain_nuremberg` | *Pasted inside the lid: NÜRNBERGER MEDICINAL-GEWICHT. 20 grains = 1 scruple · 60 grains = 1 drachm · 480 grains = 1 ounce · 1 grain = 0.0621 g.* | — |
| R3 | `z.book.units` | `*` `on_click` | — | `f.grain_nuremberg` *(той самий id — друга дорога)* | (той самий note) | — |
| R4 | `z.book.gauss` | `*` `on_click` | — | — | say: *"Weigh the body in the one pan; then change body and weights about and weigh again. The truth lies midway between the two."* | — |
| R5 | `z.obj.packet` | `tool.weigh` `on_click` | `zone_state default` · `zone_states {z.board.top: default}` | — | say: *Level against 114 grains — and level still when three more grains are laid on. The pointer does not stir.* | `z.obj.packet → left` |
| R6 | `z.obj.packet` | `tool.weigh` `on_click` | `zone_state left` · `zone_states {z.board.top: default}` | `f.w_p_pair` | *On its own board the pointer stands at zero against 114 grains, and stands at zero still against 120, and against everything between; and it does the same with the packet moved to the other pan.* | `z.obj.packet → both` |
| R7 | `z.obj.ounce` | `tool.weigh` `on_click` | `zone_state default` · `zone_states {z.board.top: default}` | — | say: *Level against 477 grains, and level still at 483.* | `z.obj.ounce → left` |
| R8 | `z.obj.ounce` | `tool.weigh` `on_click` | `zone_state left` · `zone_states {z.board.top: default}` | `f.w_q_pair` | *The bureau's own ounce, 480 grains: the pointer stands at zero from 477 grains to 483, in either pan alike.* | `z.obj.ounce → both` |
| R9 | `z.board.top` | `tool.hand` `on_click` | `needs_any [f.w_p_pair, f.w_q_pair]` · `zone_state default` | — | say: *It lifts off its board whole. Four short screws; the slots are bright, the wood about them dark.* | `z.board.top → off` · `z.obj.packet → default` · `z.obj.ounce → default` |
| R10 | `z.board.top` | `tool.hand` `on_click` `repeat` | `zone_state off` | — | say: *Back on its board.* | `z.board.top → default` · обидва об'єкти → `default` |
| R11 | `z.obj.packet` | `tool.weigh` `on_click` | `zone_state default` · `zone_states {z.board.top: off}` | — | say: *Level against 117 grains, and it will not stand level against 118.* | `z.obj.packet → left` |
| R12 | `z.obj.packet` | `tool.weigh` `on_click` | `zone_state left` · `zone_states {z.board.top: off}` | `f.w_off_board` | *Standing on the bureau's own desk the packet holds zero at 117 grains and nowhere else; a quarter-grain rider laid on either pan moves the pointer.* | `z.obj.packet → both` |
| R13 | `z.board.under_mid` | `tool.compass` `dwell 0.6` | — | `f.compass_board` | *Held beneath the front of the board, under the index, the needle swings hard over and holds there; a thumb's breadth to the side it turns end for end.* | — |
| R14 | `z.pointer.blade` | `tool.compass` `dwell 0.6` | `needs [f.compass_board]` | `f.compass_beam` | *Held beside the tongue the needle is drawn to it, and points at it from either side, whichever end is offered.* | — |
| R15 | `z.beam.arm_right` | `tool.compass` `dwell 0.6` | — | — | say: *The needle hangs north. The right arm is nothing to it.* | — |
| R16 | `z.pointer.blade` | `tool.rake` `dwell 0.8` | — | `f.seam_flux` + картка `c.flux` | *Under raking light a bright line runs the whole length of the tongue, and a narrow band of the lacquer beside it is scorched brown.* | — |
| R17 | `z.beam.arm_right` | `tool.rake` `dwell 0.8` | — | — | say: *Unbroken lacquer, and the maker's file marks under it.* | — |
| R18 | `z.beam.center` | `tool.loupe` `dwell 0.6` | — | `f.stamp_year` + картки `c.punch`, `c.lacquer` | *Struck on the beam: an eagle, XII, and the figures 76. The rim of the punch stands full of the same lacquer that covers the beam.* | — |
| R19 | `z.book.eich` | `*` `on_click` | `needs [f.stamp_year]` | `f.eich_register` | *The assize register: office XII is this city; the two figures are the year of verification; an adjusting cavity filled with lead and struck over is the office's own work.* | — |
| R20 | `z.weights.drachm` | `tool.hand` `on_click` | `zone_state default` | — | say: *It turns over. The base is not flat.* | `z.weights.drachm → turned` |
| R21 | `z.weights.drachm` | `tool.loupe` `dwell 0.5` | `zone_state turned` | `f.plug_lead` | *A shallow cavity in the base of the drachm weight, filled with lead; an eagle and XII are struck across the lead and the brass together.* | — |
| R22 | `z.board.under_mid` | `tool.hand` `on_click` `confirm_key confirm.baize` | `needs [f.compass_board]` · `zone_states {z.board.top: off}` · `zone_state default` | `f.magnet_under` | *Under the baize, in a pocket cut into the wood, a horseshoe of steel held by two screws. The slots of the screws are bright.* | `z.board.under_mid → lifted` |
| R23 | `z.papers.recipe` | `*` `on_click` | — | `f.recipe_child` | *The copy in his folder, 11 March: Chin. sulph. gr. xij, div. in pulv. no. vj — for a child of four years.* | — |
| R24 | нотатник, порядок карток | — | `c.punch, c.lacquer, c.flux` у правильному порядку | `f.seam_after_stamp` | *The lacquer lies in the punch; the scorch lies on the lacquer.* | — |

**Скидання зважування:** `tool.hand` на `z.obj.packet` / `z.obj.ounce` у стані `left` або
`both` → `default`, `repeat: true`. Переважувати можна скільки завгодно, і це не дрібниця:
у справі 10 той самий інструмент мусить бути **справний і звичний**, інакше його мовчання
не спрацює.

**`confirm.baize`** (EN): *"You will have to lift the client's baize. It will not lie down the same way."*

**Стратиграфія — три картки, істина порядку:**
`STRAT_TRUTH := [c.punch, c.lacquer, c.flux]` → `STRAT_GIVES := f.seam_after_stamp`
- `c.punch` — *the punch of the assize stamp, its rim standing full of lacquer*
- `c.lacquer` — *the brass lacquer, whole over beam and stamp alike*
- `c.flux` — *the scorched band where the flux ran, beside the solder line*

---

## 5. ФАКТИ

| fact_id | text (EN, спостереження) | cite («на підставі») | tag / вага |
|---|---|---|---|
| `f.packet_short` | *His packet, inscribed gr. cxx in his own hand, weighs 7.27 g on the bureau balance.* | *the packet weighed against the bureau's own metric weights* | `dose` · 2 |
| `f.grain_nuremberg` | *NÜRNBERGER MEDICINAL-GEWICHT: 20 gr = 1 scruple · 60 gr = 1 drachm · 480 gr = 1 ounce · 1 grain = 0.0621 g.* | *the table pasted in the lid of his weight box* | `books` · 1 |
| `f.w_p_pair` | *On its own board the pointer stands at zero against 114 grains, and stands at zero still against 120, and against everything between; and it does the same with the packet moved to the other pan.* | *a double weighing of the packet, transposed* | `weighing` · 3 |
| `f.w_q_pair` | *The bureau's own ounce, 480 grains: the pointer stands at zero from 477 grains to 483, in either pan alike.* | *a double weighing of a known ounce, transposed* | `weighing` · 3 |
| `f.w_off_board` | *Standing on the bureau's own desk the packet holds zero at 117 grains and nowhere else; a quarter-grain rider laid on either pan moves the pointer.* | *the same balance weighed off its own stand* | `weighing` · 3 |
| `f.compass_board` | *Held beneath the front of the board, under the index, the needle swings hard over and holds there; a thumb's breadth to the side it turns end for end.* | *the compass carried under the stand* | `magnet` · 3 |
| `f.compass_beam` | *Held beside the tongue the needle is drawn to it, and points at it from either side, whichever end is offered.* | *the compass carried along the tongue* | `magnet` · 2 |
| `f.seam_flux` | *A bright line runs the whole length of the tongue, and a narrow band of the lacquer beside it is scorched brown.* | *the soldered line down the tongue of the beam* | `beam` · 3 |
| `f.stamp_year` | *Struck on the beam: an eagle, XII, and the figures 76. The rim of the punch stands full of lacquer.* | *the assize stamp on the beam* | `marks` · 2 |
| `f.eich_register` | *Office XII is this city; the two figures are the year of verification; an adjusting cavity filled with lead and struck over is the office's own work.* | *the register of the assize office* | `books` · 1 |
| `f.seam_after_stamp` | *The lacquer lies in the punch; the scorch lies on the lacquer.* | *the order of the three layers on the beam* | `beam` · 3 |
| `f.plug_lead` | *A shallow cavity in the base of the drachm weight, filled with lead; an eagle and XII are struck across the lead and the brass together.* | *the leaded base of the drachm weight* | `weights` · 1 |
| `f.magnet_under` | *Under the baize, in a pocket cut into the wood, a horseshoe of steel held by two screws. The slots of the screws are bright.* | *what the stand carries under its baize* | `magnet` · 3 |
| `f.recipe_child` | *The copy in his folder, 11 March: Chin. sulph. gr. xij, div. in pulv. no. vj — for a child of four years.* | *the prescription copied into his folder* | `dose` · 2 |

**14 фактів + 3 картки стратиграфії.** Жоден note не містить висновку: ніде не сказано
«магніт тягне», «терези брешуть», «різноважка чесна» — лише що видно, чути й скільки показало.

---

## 6. ДОВІДНИКОВІ ТАБЛИЦІ

### 6.1. Медична (нюрнберзька) вага — `z.book.units`, та сама таблиця в кришці скриньки

| знак | назва | у гранах | у грамах |
|---|---|---|---|
| ℔ | pound (libra medicinalis) | 5760 | **357.854** |
| ℥ | ounce (uncia) | 480 | **29.821** |
| ʒ | drachm (drachma) | 60 | **3.7276** |
| ℈ | scruple (scrupulus) | 20 | **1.2425** |
| gr | grain (granum) | 1 | **0.0621** |

Це справжня нюрнберзька медична вага, спільна для німецькомовних аптек XIX ст.

### 6.2. Рядок-пастка на тій самій сторінці (щоб одиниця не була самоочевидна)

| система | гран | звідки |
|---|---|---|
| нюрнберзька медична | **0.0621 г** | етикетка **його** скриньки |
| віденська аптекарська (до метрики) | 0.0729 г | ℔ = 420.045 г |
| англійський troy grain | 0.0648 г | ℔ troy = 373.24 г |

**Тому графа «похибка в гранах» відкривається лише після `f.grain_nuremberg`** — гравець
мусить спершу прочитати, **чиї** грани він рахує. Без цього гейта числова графа стає лотереєю
з трьох одиниць, а це нечесно.

**Історична правда, яку не ховаємо:** метричну систему в Австрії зроблено обов'язковою
законом від 23 липня 1871 р. з 1 січня 1876 р. Аптекар **зобов'язаний** відпускати в грамах —
і відпускає; але старий комплект різноважок медичної ваги лишився в шухляді робочого столу
й ним він робить порошки за старими прописами, як робив його попередник. Саме тому в теці
рецепт у гранах, а на терезах бюро — грами. Ця подвійність не декорація: вона й тримає загадку.

### 6.3. Знаки повірочної управи — `z.book.eich`

| елемент знака | що означає |
|---|---|
| двоголовий орел | k.k. Eichamt, державна повірка |
| римське число під орлом | номер управи (**XII — це місто**) |
| дві арабські цифри | останні дві цифри року повірки (**76 = 1876**) |
| знак на терезах | б'ється на коромислі біля середньої призми |
| знак на різноважці | б'ється на верхівці або на голівці |
| **юстирувальна порожнина** | висвердлена знизу, залита свинцем, **прибита знаком поверх свинцю й латуні одразу** — це робота самої управи, а не підробка |

### 6.4. Метал і магніт

| матеріал | густина | компас |
|---|---|---|
| м'яке залізо | 7.87 | притягує **обидва** кінці стрілки однаково |
| гартована сталь (магніт) | 7.8 | один кінець притягує, другий **відштовхує** |
| латунь | 8.4–8.7 | не діє |
| свинець | 11.34 | не діє |

**Це фізика, а не умовність:** намагнічена сталь має полюси, м'яке залізо їх не має — воно
намагнічується наведено й притягується до **будь-якого** кінця стрілки. Тому одним компасом
розрізняється, що в дошці (магніт із двома полюсами) і що в язичку (залізо без полюсів).

### 6.5. Подвійне зважування — `z.book.gauss` (загнутий кут)

> Метод К. Ф. Гаусса (1836), у посібниках доби — *Doppelwägung*, зважування переміною місць.
> Тіло в лівій шальці зрівноважується вагою **W₁**; тіло переставляється в праву й
> зрівноважується вагою **W₂**.
> Істинна маса **m = (W₁ + W₂) / 2** (точно: √(W₁·W₂), різниця тут менша за 0.05 грана).
> Метод створено проти **нерівноплечості**, і саме це він тут і робить: якщо смуга «стрілка
> стоїть рівно» має **той самий центр** в обох шальках, плечі рівні. Нерівні плечі дали б
> два різні центри, і відстань між ними **зростала б із вантажем**.
> **Що метод НЕ показує:** ширину смуги. Її дає окремий, теж фаховий, дослід —
> **проба чутливості**: покласти малий важок (наїзник) на зрівноважену шальку й дивитись,
> чи стрілка ворухнулась. Повірочні управи вимагали, щоб терези відповідали на завідомо
> малу частку навантаження; глухий прилад повірку не проходив би — тому клеймо на ньому
> **старіше за шов**, і це головна суперечність справи.

### 6.6. Дози (для рецепта в теці)

| припис доби | значення |
|---|---|
| Chininum sulphuricum, доросла доза | 2–10 гранів |
| правило Юнґа (дитяча доза) | вік / (вік + 12) × доросла → дитина 4 років = **¼** |
| рецепт у теці | gr. xij на 6 порошків = по 2 грани в порошку |

### 6.7. АРИФМЕТИКА СПРАВИ (для програміста — всі числа зійшлись)

```
істинна маса пакетика P        117 гранів = 7.266 г → терези бюро: 7.27 г
надпис на пакетику             gr. cxx = 120 гранів = 7.452 г   (він ставив 120 різноважок)
унцієва гиря бюро Q            480 гранів = 29.821 г (точно)
мертва смуга (магнітний детент) d = 3 грани = 0.186 г на бік, 6 гранів усього

НА СВОЇЙ ПІДСТАВЦІ (стрілка стоїть у нулі, поки |різниця| <= 3):
   P (117) → рівно від 114 до 120 гранів, В ОБОХ шальках однаково
   Q (480) → рівно від 477 до 483 гранів, В ОБОХ шальках однаково
   центр смуги = істина (117 і 480) → плечі рівні (перевірено Гауссом)
   ширина смуги та сама при вчетверо більшому вантажі → 3 і 3

НА СТОЛІ БЮРО (без магніту):
   P → рівно тільки на 117; наїзник 1/4 грана рушить стрілку

ЯК ВИНИКАЄ НЕДОВАЖОК (це не похибка приладу, це похибка ПРОЦЕДУРИ):
   він ставить 120 гранів різноважок і сипле порошок, доки стрілка вперше стане рівно.
   вперше вона стає рівно на 117 → у пакет іде 117, замість 120. Щоразу 3 грани.
   верхній край смуги (120) — це рівно те число, яке він написав на пакетику.

ЧОМУ ВІН НЕ БАЧИВ 22 РОКИ:
   нуль ідеальний · повторюваність ідеальна · переважування дає те саме число.
   глухий прилад завжди погоджується сам із собою. Точність без правильності.

ЧОМУ ЦЕ НЕ ЗНОШЕНІ ПРИЗМИ (гіпотеза А):
   тертя на призмі дає мертву смугу, ЩО ЗРОСТАЄ з навантаженням (нормальна сила більша):
   при 480 смуга була б приблизно вчетверо ширша за смугу при 120. Вона та сама.
   плюс: призми ті самі, а на столі бюро смуги нема зовсім.

РЕЦЕПТ: gr. xij на 6 порошків → у пакет пішло 9 гранів, у порошку 1.5 замість 2.
        доза дорослого 2–10 гранів: 3 грани недоважку — надкус.
        доза дитини 4 років (правило Юнґа, 1/4) — 3 грани недоважку з'їдають її цілком.
```

---

## 7. АТЕСТАТ (6 граф, дві числові)

| # | slot id | префікс (EN) | тип | гейт | варіанти |
|---|---|---|---|---|---|
| 1 | `s.instrument` | *"The balance, tried off its own stand, is ____"* | CHOICE | `needs [f.w_off_board]` | `o.true_and_quick` (true, and quick to a quarter-grain) · `o.arms_unequal` (unequal in the arms) · `o.knives_worn` (dull at the knives) |
| 2 | `s.beam` | *"The beam has been ____"* | CHOICE | `needs [f.seam_flux]` | `o.never_opened` (never opened) · `o.opened_and_resoldered` (opened down the tongue and soldered up again) · `o.repaired_by_maker` (repaired by the maker before it was verified) |
| 3 | `s.opened_not_before` | *"Opened not earlier than ____"* | **NUMBER**, `digits 4`, `min 1700`, `max 1900` | `needs [f.stamp_year, f.eich_register, f.seam_after_stamp]` | списку нема. Істина: **1876** |
| 4 | `s.error_grains` | *"On its own stand the pointer keeps zero over ____ grains to either side of the true weight, at every load alike"* | **NUMBER**, `digits 2`, `min 0`, `max 99` | `needs [f.w_p_pair, f.w_q_pair, f.grain_nuremberg]` | списку нема. Істина: **3** |
| 5 | `s.cause` | *"The short weight proceeds from ____"* | CHOICE | `needs_slot [s.error_grains]` | `o.false_weights` (weights falsely adjusted) · `o.worn_knives` (an old instrument dull at the knives) · `o.iron_and_magnet` (iron let into the tongue and a magnet in the stand) · `o.careless_hand` (a careless hand at the counter) |
| 6 | `s.basis` | *"Upon the following ____"* | FACTS, `min_count 2`, `max_count 4` | `needs_slot [s.cause]`, `clears_on [s.cause]` | перетягування рядків нотатника (картки стратиграфії відфільтровано) |

**Чому графа 3 має ім'я «opened», а не «rigged»:** бланк ніколи не називає злочин.
Він питає про **дію над річчю**, і датує її гравець.

**Чому графа 4 сформульована саме так:** префікс несе **форму** величини («to either side»,
«at every load alike») — тобто те, що гравець уже довів двома дослідами, — і просить **лише
число**. Без «to either side» гравець не знав би, писати ширину смуги (6) чи половину (3);
з ним двозначності нема, а величина не підказана. Слово «true weight» змушує спершу
встановити істину (117) — інакше нема від чого відкладати.

**Гейт одиниці:** без `f.grain_nuremberg` графа 4 не відкривається — бо «3» у трьох різних
гранах доби це три різні маси (див. §6.2).

---

## 8. НАСЛІДКИ (ранок наступного дня)

| # | outcome id | умова (`when` / `basis`) | подія (EN) |
|---|---|---|---|
| 1 | `out.stand_named` | `s.cause = o.iron_and_magnet` · `s.error_grains = 3` · `s.opened_not_before ∈ [1876,1876]` · `basis_any [f.magnet_under, f.compass_board]` · `basis_weight ≥ 5` | *The assize office took the stand away before noon and left the balance. Eberhard came at four to sign for it and stayed by the door. "Twenty-two years," he said, "and it agreed with itself every single day." Then, quieter: "The fittings were attested when I bought the shop. Somebody sat where you sit and put a seal on this." — The ledger for 1878 is on your shelf. The hand in it is your predecessor's.* |
| 2 | `out.weights_blamed` | `s.cause = o.false_weights` (хибний слід) | *The office suspended his licence at nine and sealed the shop. The fittings go to the buyer on Thursday, stand and all; the notice in the paper says "complete, in working order." Eberhard's letter came by the second post. He does not argue. He asks which weight it was.* |
| 3 | `out.instrument_blamed` | `s.cause = o.worn_knives` **або** `s.instrument ∈ {o.arms_unequal, o.knives_worn}` | *He had it to the instrument-maker the same evening. The beam came back trued and bright, screwed to its own board again, and he has written to thank you: it agrees with itself to a hair. He asks whether he must trouble the assize office at all, since it is mended.* |
| 4 | `out.passed_clean` | `s.instrument = o.true_and_quick` · `s.beam = o.never_opened` | *The sale went through on Thursday. Six weeks later, among the printed notices, a small one: the fever in Kirchgasse took two of the four children it began with. The new man keeps the old fittings. He says the balance is a good one — it never argues.* |
| 5 | `out.default` | `{}` — завжди останній | *Nothing came of it. The shop is sold; the stand went with the shop.* |

**Через два тижні, у гілці 1 (і тільки в ній):** поштою приходить **одна різноважка** в
ваті, і записка: *"Would you weigh this one for me. I cannot make myself believe the new pair."*
Це та сама поява аптекаря в списку «хто повертається» (СЮЖЕТ §5).

**Ніде — жодного «правильно/хибно».** Гілка 3 — найтихіша й найгірша: річ полагоджено,
магніт лишився в дошці, і подяка написана щиро.

---

## 9. ХИБНИЙ СЛІД

**Що спокушає.** Драхмова різноважка перевертається рукою — і в основі **висвердлена
порожнина, залита свинцем**. Це канонічна фальшивка з усіх книжок про обважування, і гравець
уже двічі бачив свинець у цій грі (справи 1 і 8) як підпис підробника. Свинець = злочин.
Крім того, версія «фальшиві різноважки» пояснює **все**, що гравець має на цю мить: товару
менше, ніж показано, і винен той, хто тримає різноважки, — тобто аптекар. Людина з порошком
у складці долоні, яка щойно сказала, що продає аптеку й поспішає.

**Куди веде.** До графи `s.cause = o.false_weights` і до гілки наслідків 2: печатку знімають
із самого аптекаря, аптеку опечатують, **обстановку разом із підставкою продають далі**.
Магніт їде до нового власника з написом «complete, in working order».

**Чим спростовується — три дороги, усі фізичні:**
1. **Реєстр повірочної управи** (`f.eich_register`): юстирувальна порожнина, залита свинцем
   і **прибита знаком поверх свинцю й латуні одночасно**, — робота самої управи. Знак не
   можна набити після заливки інакше, ніж рукою управи: він лежить **на обох матеріалах**.
   Це не «дозвіл у книжці», це видима послідовність шарів на самій різноважці.
2. **Фальшива різноважка не може дати смугу.** Брехлива гирька зсуває **місце**, де стрілка
   стає рівно, — вона не робить так, щоб стрілка стояла рівно на **шести гранах підряд**.
   А смуга 114–120 видна тими самими різноважками, і при 480 вона така сама. Хибна вага дала б
   зсув, пропорційний своїй частці в накладеному (на 120 драхма — половина, на 480 — восьма);
   тут ні зсуву, ні пропорції — тут глухота.
3. **Проба наїзником.** На своїй підставці стрілка стоїть у нулі й **не ворушиться**, коли
   на зрівноважену шальку класти по чверті грана до трьох гранів. На столі бюро та сама
   чверть грана її рушить. Різноважки при цьому ті самі, у тій самій скриньці.

Спростування **не приходить само**: реєстр треба відкрити, друге зважування зробити.
Гравець, який зупинився на свинці, спокійно допише атестат і отримає гілку 2. Так і треба.

---

## 10. ДВІ ГІПОТЕЗИ І РОЗВОДЖУВАЛЬНИЙ ФАКТ

**(А) Річ стара й глуха від зносу.** Терези 1870-х, двадцять два роки щоденної роботи:
призми затупились і забились аптечним пилом, тертя в опорах з'їло чутливість — стрілка спить,
і аптека недоважувала не зі злого наміру, а з віку. Гіпотеза тримається на всьому, що видно
зразу: старий прилад, старий власник, шов на язичку — від чесного ремонту (клеймо ж на
місці, документ у порядку). **(Б) Стрілку тримає щось ззовні, і тільки там, де річ стоїть.**
Тримається на компасі й на тому, що на столі бюро прилад раптом чутливий до чверті грана.
Обидві живі, поки гравець зважив **одну** масу: одна смуга не має з чим порівнятися.
**Розводить одне: та сама проба при вчетверо більшому вантажі.** Тертя в опорі росте разом
із навантаженням — нормальна сила на призму більша, смуга ширшає; при 480 гранах вона мусила
б бути приблизно вчетверо ширша за смугу при 120. Вона та сама: три грани й три грани.
Магнітний детент не знає, скільки лежить на шальках, — і не поїхав із приладом на стіл бюро,
бо лишився в дошці.

---

## 11. СТРИБОК ДУМКИ

Прилад, який ніколи не сперечається, не точний, а **глухий** — і глухота стала, тому вона
надкушує дозу дорослого й **з'їдає дитячу цілком**; а що глухота лишилася на столі, коли
терези з нього зняли, — значить бреше не річ, а **місце, де вона стоїть**.

---

## 12. ВХІД (як гравець дізнається, що тут треба діяти)

Три двері, всі діегетичні, жодних підказок:

1. **Клієнт сам.** Ставлячи терези на стіл: *"Don't take it off the board — the screws are
   old."* Прохання, яке нічого не пояснює, і яке гравець згадає через двадцять хвилин.
2. **Пакетик.** Він приносить порошок, зроблений цього ранку, **щоб похвалитися точністю**:
   `Chin. sulph. gr. cxx`. Терези бюро (інструмент, яким гравець уже користувався у справах
   1 і 8) кажуть 7.27 г. Таблиця в кришці його ж скриньки каже, що 120 гранів — це 7.45 г.
   **Розходження знайдено власним приладом бюро за першу хвилину, і воно ще нічого не значить.**
3. **Загнутий кут попередника** у посібнику ваговимірювання — сторінка «Doppelwägung»,
   і на полі олівцем, тією самою рукою, що заповнювала атестат у перший день:
   *"Twice. Always twice."* Це і є драбина: не підказка, а звичка мертвого чоловіка.

Компас лежить у шухляді столу від першого дня гри (гравець його бачив), але **інструментом
стає тут**: коли терези вперше показують різні числа на двох столах, компас підсвічується
в поясі. `unlocked_by: f.w_off_board`.

---

## 13. ЧЕСНІСТЬ ІСТОРІЇ — ДЕ Я ВПЕВНЕНИЙ І ДЕ НІ

**Тверде (перевірене, можна будувати):**
- Подвійне зважування переміною місць — Гаусс, 1836; стандарт аптечної й лабораторної
  практики XIX ст. Формула m = (W₁+W₂)/2 і точна √(W₁·W₂) — обидві правильні.
- Нюрнберзька медична вага: ℔ 357.854 г, ℥ 29.821 г, ʒ 3.7276 г, ℈ 1.2425 г, гран 0.0621 г.
- Віденська аптекарська ℔ 420.045 г (гран 0.0729 г) — саме тому одиницю треба гейтити.
- Метрика в Австрії: закон 23.07.1871, обов'язково з 01.01.1876.
- Магніт vs м'яке залізо на компасну стрілку: полюси проти наведеного намагнічування. Фізика.
- Юстирувальна порожнина в різноважці, залита свинцем і прибита клеймом, — реальна
  практика повірочних управ, а не вигадка для сюжету.
- Правило Юнґа для дитячої дози; хініну сульфат як звичайний дитячий припис при пропасниці.

**М'яке (кажу прямо):**
1. **Періодичність повірки терезів в Австрії близько 1900.** Я не маю під рукою джерела на
   точний інтервал Nacheichung саме для торгових терезів. Тому в грі авторитетом є **реєстр
   управи** (діегетичний текст), а не реальний параграф. **Запасний варіант, якщо звірка
   покаже обов'язкову щорічну перевірку:** цифри клейма стають `94`, число в графі 3 — **1894**,
   а термін обману скорочується до шести років; репліка клієнта «Nobody has weighed it since
   I bought the shop» міняється на «…since the office was here». Решта справи не рухається.
2. **Магніт під прилавком як задокументована афера XIX ст.** Фізика бездоганна (магнітний
   детент — те саме, що тримає стрілку компаса в арретирі), магніти доступні, трюк відомий;
   але **конкретного судового випадку доби я не цитую**. Це правдоподібна, не засвідчена
   афера. Якщо потрібна засвідчена — заміна дешева: замість магніту **шовкова волосина через
   щілину стільниці** (задокументовано на ярмаркових терезах), але вона програє: видно оком,
   і компас тоді не потрібен, а компас — найкращий інструмент цієї справи.
3. **Ширина смуги 3 грани — груба.** Аптечні терези доби впевнено брали 1/4 грана, тож
   6 гранів глухоти помітив би будь-хто, **хто зробив би пробу наїзником**. Це навмисно:
   жах справи не в тому, що похибку неможливо було знайти, а в тому, що **її ніхто не шукав
   двадцять два роки** — бо річ щодня погоджувалася сама з собою, а погодженість люди
   (і повірочні управи) читають як правильність.
4. **Кому вигода.** Магніт ставив не аптекар. Ставив той, хто продавав аптеку 1878-го (або
   робив обстановку 1876–77), бо глухі терези **щодня лишають товар у крамниці**. Цієї
   людини в кадрі нема й вона, найпевніше, мертва — і це правильно: справа не про лиходія,
   а про річ, яка переживає всіх, хто її торкався. У гілці 1 виявляється, що обстановку
   1878-го **атестував попередник гравця**, і його рука в гросбусі.
5. **Чого я НЕ став робити.** Не став залишати «сталу тягу плеча» з плану: вона
   математично знімається виставлянням нуля, і будь-який фізик у відгуках це побачить за
   хвилину. Мертва смуга дає той самий сюжет, той самий недоважок і той самий магніт —
   але витримує перевірку.

---

## 14. ЩО ПОТРІБНО НАМАЛЮВАТИ (для ASSETS)

Терези аптечні колонкові з латунним коромислом і **язичком, що звисає крізь індекс майже до
дошки**, на червонодеревній підставці **на чотирьох точених ніжках** (щоб компас проходив під
дошкою — це ігромеханіка, не декор). Стани: на підставці / зняті на стіл бюро · язичок крупно:
чистий / шов і опалена смуга під косим світлом · середина коромисла: клеймо крупно
(орел, XII, 76) · низ підставки під індексом: сукно ціле / сукно відігнуте з кишенею й
підковою · скринька різноважок відкрита, етикетка в кришці · драхмова різноважка: стоїть /
перевернута зі свинцевою пробкою й клеймом поверх · пакетик `Chin. sulph. gr. cxx` ·
три картки стратиграфії (лунка пуансона · лак · опалена смуга).
**Язичок — окремий спрайт**, положення: нуль · ліворуч · праворуч. І це головна анімаційна
робота справи: на підставці язичок **клацає в нуль і стоїть як мертвий**; знятий зі
підставки — **гуляє й довго затихає**. Різниця мусить читатися оком без жодного тексту.

**Гейт приймання (за PUZZLES §8):** свіжий агент-казуал після проходження мусить сказати
вголос щось на кшталт: *«Похибка однакова і на маленькій вазі, і на великій, а на іншому
столі її нема — значить діє не прилад, а підставка».* Не сформулював — справа переробляється.
