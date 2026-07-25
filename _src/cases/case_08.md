# СПРАВА 8 — «КЕЛИХ ПОВЕРТАЄТЬСЯ» (THE CUP COMES BACK)

**№ 8 · 45 хв · акт II, кульмінація ремесла**

**Роль в акті.** Це та сама річ і той самий арт, що у справі 1, — і саме тому справа працює:
гравець сім справ учився, а тепер повертається до першої задачі з повним поясом і **з судовим
дозволом різати**. Усе, що у справі 1 було заборонено (пропил, реактив, гідростатика, купеляція,
стратиграфія, свинець), робиться тут. Повторний огляд перестає бути «ще один погляд» і стає
найтехнічнішою справою гри. Заодно це головний двигун жаху: перше, що гравець читає, — **власний
атестат**, і на його зворотi рукою ломбардного писаря: *«taken on the strength of this»*.

**Що вона додає до вузла сюжету.** Сплав ніжки = сплав зливка з ломбарду = **друкарський гарт**.
Це вперше зшиває справи 1, 8 і 9 в один вузол: підробник має доступ до друкарні, а друкарня
друкує ще й **чорнобордюрні картки**. Восковий відтиск тавра лягає поруч із відтиском зі
справи 3, і це той самий пуансон.

**Ритм (орієнтир для плейтесту):**

| хв | що |
|---|---|
| 0:00 | констебль, лоток із двома речами, судовий дозвіл, власний атестат бюро. Клієнтка в коридорі |
| 2:30 | шафа з різальним і реактивами відмикається вперше за сім справ |
| 4:00 | клацнути по вінцях → глухо. Гідростатика → 331.0 / 298.2 → **10.09** (підозра, не доказ) |
| 8:00 | Шверте́р на чашу → **криваво-червона**. Гравець упевнений, що це срібло |
| 11:00 | пропил на ребрі піддона (підтвердження, незворотно) → Шверте́р у пропил → **зелена** |
| 15:00 | купеляція зішкребу шкірки → **994** проти «800» на клеймі |
| 20:00 | диск під піддоном підважено → сірий метал з усадковою раковиною |
| 24:00 | паяльна трубка: три нальоти на вугіллі. Довідник називає їх |
| 28:00 | те саме на зливку з ломбарду → **ті самі три, в тому ж порядку** |
| 31:00 | лупа на зливок → уламок очка літери й борозна нікса. **Стрибок ≈ 32:00** |
| 34:00 | стік припою й лот із кишені Новака → **тільки два нальоти**. Хибний слід умирає |
| 37:00 | спирт на затерту смугу стояка → IHS. Три картки стратиграфії |
| 41:00 | атестат: 6 граф, дві числові. Печатка. Штамп у гніздо |
| 44:00 | коридор порожній. Стілець стоїть там, де стояв |

---

## 1. КЛІЄНТ

**Wachmann Josef Prohaska**, 52, поліцейський вартовий. Не сідає, бо тримає лоток. Речі приносить
**не власник** — це перша справа, де клієнт не має до речі жодного інтересу, і саме тому він
небезпечніший за всіх попередніх: йому потрібен **папір**, а не правда.

**Названа потреба, з річчю не пов'язана:**
> "The inquiry sits on Friday and the sergeant counts closed dockets, not open ones. I am three
> short. A man three short does not get the day room, and I have eleven years to the day room."

**Фізична деталь, яку кадр показує і жоден текст не коментує:**
коли він ставить лоток, видно **лівий чобіт — рант розійшовся, і в щілину напхано газету**.
Газета біла, свіжа. Ніхто цього не називає.

**Клієнтка зі справи 1 — Katharina Reithofer — стоїть у коридорі за його спиною і не дивиться.**
Жодного слова за всю справу. Кадр тримає її 1.4 с, коли гравець уперше бере лоток: вона в тому
самому пальті, **жалобної пов'язки на рукаві більше нема, і нитка від неї лишилась**.
Стілець у коридорі є. Вона стоїть.

**Дві репліки на печатку:**

| Умова | Репліка |
|---|---|
| **Швидко** — печатка до того, як здобуто `f.blowpipe_ingot` (гравець не дійшов до зливка) | "Quick. I will tell the sergeant the office was certain. Certain reads well in a docket." |
| **Довго** — печатка при ≥ 14 фактах **або** > 34 хв | "You have kept me past my shift. I will say so, and I will say it was worth the saying." |

**Після печатки, у всіх гілках, один кадр без реплік:** коридор порожній. Стілець стоїть
там, де стояв.

---

## 2. ЗОНИ ПРЕДМЕТА

Модель `goblet_pivot` — **та сама, що у справі 1**, 1 локальна одиниця = 100 мм, келих 196 мм,
низ піддона `y = −0.98`, вінця `y = +0.98`. Другий предмет — `ingot_pivot`, зливок 78 × 22 × 14 мм,
1 одиниця = 100 мм. Формат полів — `ENGINE_SPEC.md` §1.2. 2D — частки **ЗОБРАЖЕННЯ**, радіус —
частка **ширини** зображення.

| id зони | де саме | вид | координати | радіус | екран · інструменти |
|---|---|---|---|---|---|
| `z.cup.whole` | келих на сукні, поруч лоток | **2d** (img) | `surface: case_desk_two`, `u = (0.372, 0.470)`, `shape: rect`, `half = (0.086, 0.258)` | — | DESK · `hand`, `scales`, `hydro`, `caliper` |
| `z.bowl.outer` | зовнішня стінка чаші, під вінцями | 3d | `p = (0, 0.55, 0.42)`, `n = (0, 0.18, 0.98).normalized()` | `r = 0.20`, `facing_min = 0.15` | HANDS · `schwerter`, `loupe`, `rake` |
| `z.bowl.rim` | самі вінця, кромка | 3d | `p = (0, 0.95, 0.30)`, `n = (0, 0.55, 0.84).normalized()` | `r = 0.085`, `facing_min = 0.05` | HANDS · `hand` (клацнути), `loupe` |
| `z.stem.shaft` | гладкий стояк **між нодусом і піддоном**; там затерта смуга | 3d | `p = (0, −0.60, 0.060)`, `n = (0, 0.0, 1.0)` | `r = 0.110`, `facing_min = 0.10` | HANDS · `rake`, `spirit`, `loupe`, `caliper` |
| `z.foot.underside` | спід піддона **по колу r = 0.28**: місце двох клейм зі справи 1 | 3d | `p = (0, −0.96, 0.28)`, `n = (0, −1, 0)` | `r = 0.20`, `facing_min = 0.12` | HANDS · `loupe`, `rake`, `wax` |
| `z.foot.disc` | **центр** споду піддона: круглий диск, обведений паяним швом | 3d | `p = (0, −0.965, 0.0)`, `n = (0, −1, 0)` | `r = 0.155`, `facing_min = 0.12` | HANDS · `rake`, `loupe`, `blade`, `blowpipe`, `cupel` |
| `z.foot.edge` | вертикальний рант по краю піддона | 3d | `p = (0, −0.93, 0.52)`, `n = (0, −0.30, 0.95).normalized()` | `r = 0.075`, `facing_min = 0.05` | HANDS · `saw`, `schwerter`, `loupe`, `caliper` |
| `z.ingot.body` | зливок сірого металу з ломбарду, лита («заливна») грань догори | 3d | anchor `ingot_pivot`, `p = (0, 0.07, 0)`, `n = (0, 1, 0)` | `r = 0.42`, `facing_min = 0.10` | INGOT · `loupe`, `rake`, `hand`, `blowpipe`, `caliper` |

> **Залізна вимога до 3D-макета.** `z.foot.underside` (клейма, радіус від осі **0.28**) і
> `z.foot.disc` (диск, **на осі**) не мають перекриватися: 0.28 − 0.20 = 0.08 зазору. Диск —
> це технологічний отвір, через який ніжку залито; клейма стоять по колу навколо нього. Якщо
> художник зсуне клейма до центру, дві різні дії справи склеяться в одну.
> **Стани зон, які змінює гра:** `z.foot.edge`: `default → cut` · `z.foot.disc`: `default → lifted`
> · `z.ingot.body`: `default → scraped` · `z.stem.shaft`: `default → wetted`.
> Стан `z.foot.top → raised` **успадковується зі справи 1** (горбики вже знайдені).

**Зони речових доказів і паперів** (той самий рушій, `on_click: true`):

| id зони | де | вид | координати | екран |
|---|---|---|---|---|
| `z.papers.own_cert` | атестат бюро зі справи 1, зі зворотом наверх | 2d | `surface: cert_01_returned`, `u = (0.500, 0.455)`, `shape: rect`, `half = (0.300, 0.210)` | DOCS |
| `z.papers.pawn` | ломбардна квитанція + вирваний аркуш прилавкової книги | 2d | `surface: pawn_leaf`, `u = (0.470, 0.520)`, `r = 0.210` | DOCS |
| `z.papers.warrant` | судовий дозвіл на руйнівний огляд | 2d | `surface: warrant`, `u = (0.510, 0.400)`, `r = 0.180` | DOCS |
| `z.papers.wrapper` | папір, у який був загорнутий зливок | 2d | `surface: ingot_wrapper`, `u = (0.520, 0.480)`, `shape: rect`, `half = (0.280, 0.230)` | DOCS |
| `z.exhibit.stock` | у лотку окремо: стік припою і лот-грузило **з кишені заставника** | 2d | `surface: constable_tray`, `u = (0.735, 0.610)`, `r = 0.120` | DESK · `blowpipe`, `loupe`, `caliper` |
| `z.book.alloys` | **один розворот, дві таблиці**: ліва сторінка «Löthrohr» (нальоти на вугіллі), права «Bleilegierungen» (сплави по ремеслах) | 2d | `surface: hb_alloys_spread`, `u = (0.500, 0.470)`, `shape: rect`, `half = (0.460, 0.250)` | BOOK_ALLOY |
| `z.book.church` | розворот «Kirchengerät» — де на потирі що стоїть | 2d | `surface: hb_church`, `u = (0.660, 0.500)`, `r = 0.260` | BOOK_CHURCH |
| `z.drawer.squeezes` | шухляда з восковими відтисками попередника й гравця | 2d | `surface: squeeze_drawer`, `u = (0.500, 0.560)`, `r = 0.240` | DRAWER |
| `z.wall.sg` | таблиця «вага проти води» на стіні над столом — **читається завжди, факту не дає** | 2d | `surface: wall_sg_table`, `u = (0.820, 0.190)`, `r = 0.110` | DESK |

---

## 3. ІНСТРУМЕНТИ

Шість перенесених і **сім нових**. Це навмисно найбільший пояс гри: справа 8 — це складання
всього ремесла в одну руку. Сім нових інструментів **не падають з неба**: усі вони лежали в
**замкненій шафі за столом**, яку гравець бачив сім справ поспіль і не міг відчинити. Ключ
приносить не гра, а **судовий дозвіл** (§12).

| id | verb | видається | нотатка |
|---|---|---|---|
| `tool.eye` | OBSERVE | є | `radius 0.09` |
| `tool.hand` | OBSERVE | є | обмацати · перевернути · **клацнути** по вінцях; `on_click` |
| `tool.loupe` | OBSERVE | є | `magnify 4.3`, `radius 0.045` |
| `tool.rake` | OBSERVE | є | косе світло; `exclusive_with = [tool.candle]` |
| `tool.caliper` | MEASURE | є | ноніус, дає число |
| `tool.scales` | MEASURE | є | вага в повітрі, грами; `repeat: true` |
| **`tool.hydro`** | MEASURE | `unlocked_by: ev.case_08_warrant` | **гідростатичне стремено** під чашку терезів: та сама вага, підвіс і склянка. `repeat: true`. Дає **два** числа, ніколи не ділить їх сама |
| **`tool.saw`** | DESTRUCTIVE | `unlocked_by: ev.case_08_warrant` | тригранний надфіль. `uses_max = 1`, `confirm_key = "confirm.saw"`. **Незворотно, і гра це каже словами дозволу, не попередженням** |
| **`tool.schwerter`** | APPLY | `unlocked_by: ev.case_08_warrant` | розчин Шверте́ра в піпетці. `uses_max = 4`. Дає **колір**, не «так/ні» |
| **`tool.blade`** | APPLY | `unlocked_by: ev.case_08_warrant` | тонкий підважувач; `uses_max = -1`, `confirm_key = "confirm.blade"` на диску |
| **`tool.blowpipe`** | APPLY | `unlocked_by: ev.case_08_warrant` | паяльна трубка + вугільна плитка. `uses_max = 4`. Бере зішкреб із зони, дає **нальоти**, не назви |
| **`tool.cupel`** | DESTRUCTIVE | `unlocked_by: ev.case_08_warrant` | купель із кістяного попелу + муфельна печурка в задній кімнаті. **`uses_max = 2`**, `confirm_key = "confirm.cupel"`. Дає **дві ваги**: узятого й того, що лишилось |
| **`tool.spirit`** | APPLY | `unlocked_by: ev.case_08_warrant` | спирт на ваті; `uses_max = 3` |
| **`tool.wax`** | APPLY | `unlocked_by: ev.case_08_warrant` | восковий відтиск; `uses_max = 2` |

> **Правило двох зарядів купеляції — це і є вся драматургія інструмента.** Два заряди, три
> спокуси (шкірка, заливка, зливок). Гра ніде не підказує, які два взяти; жоден вибір не тупик,
> бо шкірка й заливка розводять гіпотези з різних боків. Витратив обидва не туди — лишається
> паяльна трубка, і вона безмежна. **Глухого кута нема, ціна помилки — час.**

---

## 4. ПРАВИЛА (зона × інструмент → факт)

`requires` — факти, які мусять уже бути. `note` — англійський текст **СПОСТЕРЕЖЕННЯ**: він іде
і в репліку (`say_key`), і в нотатник. **Жоден note не містить висновку.** Слів
*plated, false, forged, lead, antimony, type, therefore, later* у note немає ніде — метали
називає **довідник**, а порядок шарів складає **гравець**.

| # | zone_id | tool | requires | fact_id | note (EN, спостереження) | sets_state |
|---|---|---|---|---|---|---|
| r.01 | `z.papers.warrant` | `*` (on_click) | — | **факту нема** — `say_key` | "Order of the district court: *the office may cut, burn and consume so much of the article as is needful to the finding, and shall enter what it has consumed.*" | `flag: warrant = true`, видає 7 інструментів |
| r.02 | `z.papers.own_cert` | `*` (on_click) | — | `f.cert_returned` | "The office's own certificate, sealed the fourteenth of March, in my hand. On the back, in a clerk's hand: 'taken on the strength of this, 40 fl.', and a counter number." | — |
| r.03 | `z.papers.pawn` | `tool.loupe` \| `tool.eye` (on_click) | — | `f.pawn_ticket` | "Pledge ticket: nineteenth of March, forty gulden, *one cup, silver, with paper* and *one bar of grey metal* — both on one line. Pledger: Franz Novak, lead-worker, Gumpendorf. On the facing leaf of the counter book the same name stands eleven times in two years, and beside four of them: 'for a customer'." | — |
| r.04 | `z.papers.wrapper` | `tool.eye` \| `tool.loupe` (on_click) | `f.pawn_ticket` | `f.wrapper_proof` | "The paper the bar was wrapped in is printed on one side only: a black border, the wording of a death notice set out in full, and the place for the name left empty. At the foot, a line of small type starved of ink: ' … R U C K E R E I … ' and then a word too pale to read." | — |
| r.05 | `z.cup.whole` | `tool.hand` | — | — | → перехід на екран HANDS | `screen = HANDS` |
| r.06 | `z.cup.whole` | `tool.scales` (`repeat`) | — | `f.weight_331` | "On the balance, in air: 331.0 g." *(той самий факт і той самий id, що у справі 1 — переноситься зі збереження, якщо вже є)* | — |
| r.07 | `z.cup.whole` | `tool.hydro` (`repeat`) | `f.weight_331` | `f.hydrostatic` | "Wetted, hung in the stirrup, the bubbles wiped from under the foot: in water the balance calls it 298.2 g. In air, on the same balance, 331.0 g. The water stands at fifteen degrees." | — |
| r.08 | `z.bowl.rim` | `tool.hand` (on_click, `repeat`) | — | `f.tap_dead` | "Struck with the nail: no note at all. The sound stops where the stem swells and does not travel down." | — |
| r.09 | `z.bowl.outer` | `tool.schwerter` (on_click, `uses 1`) | `flag: warrant` | `f.acid_bowl_red` | "One drop on the wall of the bowl: it opens into a bright red, blood-coloured, and it does not go brown while I watch it." | — |
| r.10 | `z.foot.edge` | `tool.loupe` \| `tool.rake` | — | — | say: "The rant of the foot is the only place on the piece where the wall shows its edge." — **вказівник, без факту** | — |
| r.11 | `z.foot.edge` | `tool.saw` (on_click, `uses 1`, `confirm`) | `flag: warrant`, `f.tap_dead` | `f.rim_cut` | "Three strokes of the file across the rant. Under a white skin two tenths of a millimetre deep lies a metal the colour of a new copper heller, and it runs on inward as far as the cut goes." | `z.foot.edge → cut` |
| r.12 | `z.foot.edge` | `tool.schwerter` (on_click, `uses 1`, `zone_state: cut`) | `f.rim_cut` | `f.acid_rim_green` | "One drop in the cut: it turns green, and the green creeps along the bottom of the cut." | — |
| r.13 | `z.foot.edge` | `tool.schwerter` (on_click, `uses 1`, `zone_state: default`) | `flag: warrant` | — | say: "One drop on the rant: bright red, as on the bowl." — **хибне підтвердження, факту не дає, заряд з'їдає** | — |
| r.14 | `z.foot.edge` | `tool.cupel` (on_click, `uses 1`, `zone_state: cut`, `confirm`) | `f.rim_cut` | `f.assay_skin` | "Scraped from the skin at the cut, 0.500 g into the cupel. What came out of the muffle, and cooled, and was brushed: a bead the balance calls 0.497 g." | — |
| r.15 | `z.foot.disc` | `tool.rake` \| `tool.loupe` | — | `f.disc_seam` | "A disc the width of two thumbs is let into the middle of the foot and closed round with a run of solder. The solder stands proud of both metals and has never been dressed down." | — |
| r.16 | `z.foot.disc` | `tool.blade` (on_click, `confirm`) | `f.disc_seam`, `flag: warrant` | `f.disc_lifted` | "The disc comes up whole. Under it, filling the stem to within a finger of the top: a grey metal, dull, with a sunken hollow in the middle of its face and a skin on it that was made by whatever it was poured into." | `z.foot.disc → lifted` |
| r.17 | `z.foot.disc` | `tool.blowpipe` (on_click, `uses 1`, `zone_state: lifted`) | `f.disc_lifted` | `f.blowpipe_load` | "A scraping of the grey metal on the charcoal. It runs at once to a bead. Close about the bead, a yellow crust that goes white as it cools; the reducing flame drives it back into metal, and the flame carries a pale blue. Further off, a white crust with a blue cast to it, and that one the flame drives away altogether. Under the bead, a third white crust that will not melt and will not be driven. No smell of garlic at any time." | — |
| r.18 | `z.foot.disc` | `tool.cupel` (on_click, `uses 1`, `zone_state: lifted`, `confirm`) | `f.disc_lifted` | `f.assay_load` | "Fifty grammes of the grey metal into the cupel. The bone ash drinks nearly all of it. What is left on the cupel, weighed: 2.4 mg." | — |
| r.19 | `z.ingot.body` | `tool.loupe` (`dwell 0.6`) | — | `f.ingot_counter` | "On the poured face of the bar, standing up out of the flow skin: two strokes meeting at a shoulder about a closed oval void, a shade under a millimetre high. Beside it, running the whole length of the bar, one straight-sided groove with a flat bottom." | — |
| r.20 | `z.ingot.body` | `tool.blowpipe` (on_click, `uses 1`) | — | `f.blowpipe_ingot` | "A scraping of the bar on the charcoal. Yellow crust close about the bead, gone under the reducing flame, pale blue in the flame. Further off a white crust with a blue cast, driven away. Under the bead a white crust that will not melt. The same three, in the same places, as the grey metal out of the foot." | `z.ingot.body → scraped` |
| r.21 | `z.exhibit.stock` | `tool.blowpipe` (on_click, `uses 1`) | `f.pawn_ticket` | `f.blowpipe_solder` | "A scraping off the pledger's own stick, and a second off his sounding lead, on the charcoal. Both give the yellow crust close about the bead, and the pale blue flame; both give the white crust under the bead that will not melt. Neither gives the crust with the blue cast further off, and I went to it three times." | — |
| r.22 | `z.book.alloys` | `*` (on_click) | `needs_any: [f.blowpipe_load, f.blowpipe_ingot, f.blowpipe_solder]` | `f.hb_lead_trades` | (повний текст **розвороту з двох таблиць** — §6, В і Г) | — |
| r.24 | `z.stem.shaft` | `tool.rake` | — | **факту нема** — `say_key` | "Under the slanted lamp a band two fingers wide across the stem takes the light differently from the metal above and below it. Nothing is written on it." | `flag: band_seen = true` |
| r.25 | `z.stem.shaft` | `tool.spirit` (on_click, `uses 1`) | `flag: band_seen` | `f.mono_read` | "Wetted with spirit and let dry: three letters stand out of the band, I H S, the middle one carrying a bar, and on the bar a cross." | `z.stem.shaft → wetted` |
| r.26 | `z.stem.shaft` | `tool.loupe` (`dwell 0.5`, `zone_state: wetted`) | `f.mono_read` | `f.strat_scratch` | "A hair-line scratch comes down the stem and crosses the band. In the bottom of it the metal is grey, not bright." | — |
| r.27 | `z.stem.shaft` | `tool.rake` (`dwell 0.8`, `zone_state: wetted`) | `f.strat_scratch` | `f.strat_polish` | "Across the band the burnisher's strokes all run one way, and for the length of the band the scratch goes shallow under them and comes out the other side at its old depth." | — |
| r.28 | `z.stem.shaft` | `tool.loupe` (`dwell 1.0`, `zone_state: wetted`) | `f.strat_polish` | `f.strat_engrave` | "The walls of the letters are cut bright and they break the burnisher's strokes across. Along their edges stands a burr that nothing has gone over since." | — |
| r.29 | `z.stem.shaft` | `tool.caliper` (on_click) | `f.mono_read` | `f.stem_thin` | "On the band the wall measures 0.9 mm. A finger above the band, 1.4 mm." | — |
| r.30 | `z.book.church` | `*` (on_click) | `f.mono_read` | `f.hb_church` | (повний текст сторінки — §6, таблиця Ґ) | — |
| r.31 | `z.foot.underside` | `tool.wax` (on_click, `uses 1`) | `flag: warrant` | **факту нема** — `say_key` | "The punch takes in the wax: L·HOFFMANN, with the left upright of the H broken away a third of the way up, and a nick out of the middle bar." | `flag: squeeze_taken = true` |
| r.32 | `z.drawer.squeezes` | `*` (on_click) | `flag: squeeze_taken` | `f.wax_match` | "In the drawer, filed with the dockets: a squeeze taken in this office from the inside of a watch case, docket of the eleventh of April, in my own hand. Its H is broken away a third of the way up, and its middle bar has a nick out of the middle." | — |
| r.33 | `z.bowl.outer` | `tool.loupe` (`dwell 0.6`) | `f.rim_cut` | — | say: "The wall of the bowl shows no edge anywhere. There is nowhere on it to see through the skin." — **закриває спокусу пиляти чашу** | — |

*(r.23 нема: розворот «Löthrohr» і розворот «Bleilegierungen» зведено в один розворот і одне
правило r.22 — обидві таблиці читаються за один дотик. Нумерацію не зсуваю, щоб `id` правил у
`data/case_08.gd` не роз'їхалися з цим документом.)*

**Правила без факту — проти глухих кутів і проти сліпого перебору:**

| zone_id | tool | requires | ефект |
|---|---|---|---|
| `z.foot.edge` | `tool.saw` | немає `flag: warrant` | say: "Not without a paper that says I may." — до дозволу пиляти не можна взагалі |
| `z.foot.disc` | `tool.blade` | немає `f.disc_seam` | say: "Smooth. Something is let in here, and I have not yet looked at how." |
| `z.book.alloys` | `*` | немає жодного `tool.blowpipe`-факту | say: "Columns of parts in the hundred, and a page of crusts on charcoal. Without something to match them against, this is a wall." |
| `z.cup.whole` | `tool.hydro` | немає `f.weight_331` | say: "One weight is not two weights." |
| `z.ingot.body` | `tool.hand` | — | say: "Cast in an open trough: three faces smooth from the mould, the fourth left as it ran." — **вказівник на литу грань** |
| `z.exhibit.stock` | `tool.eye` | — | say: "A stick of soft solder, half used, and a lead sounding weight on a cord. Both out of the pledger's coat." |
| `z.wall.sg` | `*` | — | таблиця §6-А, **факту не дає**: гра не дарує ділення |

**Дороги до того самого факту** (один факт = один id, `add_fact()` ловить дублі):
`f.disc_seam` — `rake` і `loupe`. `f.pawn_ticket` — `eye` і `loupe`. `f.wrapper_proof` — `eye` і `loupe`.
`f.weight_331` — **переноситься зі справи 1**, якщо гравець його вже мав: `state.world` тримає
факти справ між справами, і r.06 просто нічого не додає (`add_fact` повертає `false`).
`f.blowpipe_load` і `f.blowpipe_ingot` — **різні** факти (різні об'єкти спостереження);
не зливати, бо на їхньому **збігу** тримається вся справа.

---

## 5. ФАКТИ

`text` — рядок нотатника. `cite` — коротка форма, яка лягає в графу «on the strength of».
`weight` — вага в OUTCOMES (`ENGINE_SPEC` §1.6). Групи: `papers` · `metal` · `body` · `books` · `strat`.

| fact_id | text (EN, спостереження) | cite (EN) | tag | weight |
|---|---|---|---|---|
| `f.cert_returned` | "The office's own certificate, sealed the fourteenth of March, in my hand. On the back, in a clerk's hand: 'taken on the strength of this, 40 fl.'" | "this office's own certificate of 14 March" | `papers` | 1 |
| `f.pawn_ticket` | "Pledge ticket, nineteenth of March, forty gulden: *one cup, silver, with paper* and *one bar of grey metal*, both on one line. Pledger: Franz Novak, lead-worker. On the facing leaf the same name stands eleven times in two years, four of them marked 'for a customer'." | "the ticket of 19 March, two articles on one line" | `papers` | 2 |
| `f.wrapper_proof` | "The bar was wrapped in a sheet printed on one side only: a black border, the wording of a death notice set out in full, the place for the name left empty. At the foot, small type starved of ink: ' … R U C K E R E I … '" | "the bar came wrapped in a spoiled death notice" | `papers` | 3 |
| `f.weight_331` | "On the balance, in air: 331.0 g." *(перенесений зі справи 1 — той самий id)* | "331.0 g in air" | `body` | 1 |
| `f.hydrostatic` | "In water, wetted and hung in the stirrup, the balance calls it 298.2 g; in air, on the same balance, 331.0 g. Water at fifteen degrees." | "331.0 g in air against 298.2 g in water" | `body` | 2 |
| `f.tap_dead` | "Struck with the nail: no note at all. The sound stops where the stem swells and does not travel down." | "the piece will not ring below the knop" | `body` | 1 |
| `f.acid_bowl_red` | "One drop on the wall of the bowl opens into a bright red, blood-coloured, and does not go brown." | "bright red on the bowl" | `metal` | 1 |
| `f.rim_cut` | "Filed across the rant of the foot: under a white skin two tenths of a millimetre deep lies a metal the colour of a new copper heller, running inward as far as the cut goes." | "a skin two tenths deep over a red metal" | `metal` | 3 |
| `f.acid_rim_green` | "One drop in the cut turns green, and the green creeps along the bottom of the cut." | "green in the cut on the foot" | `metal` | 3 |
| `f.assay_skin` | "0.500 g scraped from the skin at the cut, into the cupel; the bead that came out weighs 0.497 g." | "the skin assays 0.497 out of 0.500" | `metal` | 3 |
| `f.disc_seam` | "A disc the width of two thumbs is let into the middle of the foot and closed round with a run of solder. The solder stands proud of both metals and has never been dressed down." | "a soldered disc let into the foot, never dressed" | `body` | 2 |
| `f.disc_lifted` | "Under the disc, filling the stem to within a finger of the top: a grey metal, dull, with a sunken hollow in the middle of its face and a skin on it made by whatever it was poured into." | "the stem is run full of a grey metal" | `body` | 3 |
| `f.blowpipe_load` | "The grey metal on charcoal: a yellow crust close about the bead, white as it cools, driven back to metal by the reducing flame, the flame pale blue; further off a white crust with a blue cast, driven away altogether; under the bead a third white crust that will not melt. No garlic at any time." | "three crusts from the metal in the stem" | `metal` | 3 |
| `f.assay_load` | "Fifty grammes of the grey metal into the cupel. What is left on the cupel weighs 2.4 mg." | "50 g of the loading left 2.4 mg on the cupel" | `metal` | 2 |
| `f.ingot_counter` | "On the poured face of the bar, standing up out of the flow skin: two strokes meeting at a shoulder about a closed oval void, a shade under a millimetre high; and along the whole length of the bar one straight-sided groove with a flat bottom." | "a letter's void and a long groove in the bar" | `metal` | 4 |
| `f.blowpipe_ingot` | "The bar on charcoal gives the same three crusts, in the same places, as the grey metal out of the foot." | "the bar gives the same three crusts as the loading" | `metal` | 4 |
| `f.blowpipe_solder` | "The pledger's own stick and his sounding lead both give the yellow crust and the pale blue flame, and both give the white crust under the bead. Neither gives the crust with the blue cast, and I went to it three times." | "the pledger's own metal wants the third crust" | `metal` | 4 |
| `f.hb_lead_trades` | "Handbook: at the blowpipe, lead crusts yellow close about the bead and is easily reduced; antimony crusts white with a blue cast, at a distance, and is easily driven off; tin crusts white under the bead and will not be driven; arsenic smells of garlic. — Antimony is put into lead only where the casting must hold an edge: printing type, stereotype plate, bearings. Plumber's solder and sounding lead carry tin and no antimony." | "the handbook of alloys and of the blowpipe" | `books` | 3 |
| `f.mono_read` | "Wetted with spirit and let dry: three letters stand out of the band, I H S, the middle one carrying a bar, and on the bar a cross." | "I H S on the band of the stem" | `body` | 2 |
| `f.stem_thin` | "On the band the wall measures 0.9 mm; a finger above the band, 1.4 mm." | "the wall is 0.9 mm on the band, 1.4 above it" | `body` | 2 |
| `f.hb_church` | "Handbook of church furniture: the giver's words are cut round the band of the foot; the sacred monogram is met on the foot and on the node. The plain stem between them is left bare, and the inside of the cup is gilt." | "the handbook of church plate" | `books` | 2 |
| `f.hb_vienna_marks` | *(перенесений зі справи 1 — той самий id, той самий розворот; тут відкритий від початку)* "Handbook, Vienna assay office. 1807–1866: a punch with the last two figures of the year, the fineness in loth, and the office letter. From 1867: Diana's head with a numeral (1 = 950, 2 = 900, 3 = 800, 4 = 750) and no year at all. From 1872 the office letter is cut **inside** the head's outline; before 1872 it was struck as a separate punch beside it." | "the handbook of Vienna marks" | `books` | 1 |
| `f.wax_match` | "In the drawer, filed with the dockets: a squeeze taken in this office from the inside of a watch case, docket of the eleventh of April, in my own hand. Its H is broken away a third of the way up and its middle bar has the same nick out of the middle as this one." | "the same broken punch on the watch case of 11 April" | `papers` | 3 |

**Картки стратиграфії** (`group: strat`, `strat: true`) — у графу «on the strength of» **не** йдуть:

| fact_id | text (EN) | crop |
|---|---|---|
| `f.strat_scratch` | "A hair-line scratch comes down the stem and crosses the band. In the bottom of it the metal is grey, not bright." | `strat_cards_08` uv (0.000, 0, 0.333, 1) |
| `f.strat_polish` | "Across the band the burnisher's strokes all run one way, and for the length of the band the scratch goes shallow under them and comes out the other side at its old depth." | `strat_cards_08` uv (0.333, 0, 0.333, 1) |
| `f.strat_engrave` | "The walls of the letters are cut bright and they break the burnisher's strokes across. Along their edges stands a burr that nothing has gone over since." | `strat_cards_08` uv (0.666, 0, 0.334, 1) |

```gdscript
const STRAT_TRUTH := [&"f.strat_scratch", &"f.strat_polish", &"f.strat_engrave"]
const STRAT_GIVES := &"f.engraved_last"
```

| fact_id | text (EN) | cite (EN) | tag | weight |
|---|---|---|---|---|
| `f.engraved_last` | "The scratch was there first; the burnisher went over it; the letters were cut through the burnisher's work." | "the letters were cut last of the three" | `strat_out` | 4 |

**22 факти нотатника** (з них `f.weight_331` перенесений зі справи 1, а чотири перші читаються
з паперів у перші три хвилини), **3 картки стратиграфії** і **1 виведений**. Це більше за норму
`PUZZLES_V4` §5 (10–14 на 35–40 хв) — і це навмисно: справа 8 єдина, де за 45 хвилин працює
**весь** пояс. Див. §13, п. 1.

**Жоден рядок** не містить слів *plated, silvered, false, forged, lead, antimony, tin, type,
stolen, later, therefore*. Метали називає тільки довідник (`f.hb_lead_trades`); порядок шарів
складає тільки гравець.

---

## 6. ДОВІДНИКОВІ ТАБЛИЦІ

Усі — мальовані розвороти (гравюра XIX ст.) або таблиця на стіні. **Значення справжні.**
Текст іде в гру дослівно.

### А. «Вага проти води» — таблиця на стіні (`z.wall.sg`, факту не дає)

Опубліковані значення доби. Друкується в тому вигляді, у якому гравець мусить писати в атестат:
**вода = 100**.

| Метал | Вага проти води (вода = 100) |
|---|---|
| Silver, fine | **1050** |
| Silver, 800 in the thousand | **1020** |
| Silver, 750 | 1010 |
| Copper | **893** |
| Lead | **1135** |
| Tin | **729** |
| Antimony | **670** |
| Zinc | 714 |
| Brass | 840 – 870 |
| Nickel silver (Argentan) | 840 – 870 |
| Pewter | 730 – 780 |
| **Type metal, for hand-setting** | **950** |
| **Stereotype metal** | **1040** |
| Gold, fine | 1930 |

> Під таблицею — друкована примітка, і вона тут головна:
> "The rule holds for a solid body only. A hollow body, a body run full of another metal, or a
> body soldered up out of parts, gives a number that belongs to nothing."
>
> **Арифметика, яку гравець робить сам і якої гра ніде не показує:**
> 331.0 − 298.2 = **32.8** (об'єм у кубічних сантиметрах, бо грам води = кубічний сантиметр);
> 331.0 ÷ 32.8 = **10.09** → в атестат **1009**.
> Це число лежить **між** сріблом 800 (1020) і 750 (1010) — тобто ідеально брехливе. Воно
> **не доводить нічого** і мусить бути записане саме тому, що не доводить: бюро пише, що зміряло.

### Б. Розчин Шверте́ра — шкала, а не «так/ні» (на етикетці піпетки й на розвороті)

Реактив доби: біхромат калію в азотній кислоті. **Дає колір, і колір читається за шкалою.**

| Що під краплею | Колір |
|---|---|
| Silver, fine (990 і вище) | **bright blood red**, тримається |
| Silver 925 | dark red |
| **Silver 800** | **brown** |
| Silver 500 | green-brown |
| Copper, brass | **green** |
| Nickel silver | blue |
| Tin, lead | сірий бруд, кольору нема |

> Дві друковані примітки на етикетці, обидві історичні й обидві потрібні:
> 1. "On plated work the first touch answers for the skin and for nothing under it. Cut, then touch."
> 2. "A mark of 800 that answers bright red does not answer for the mark."
>
> Тобто **криваво-червона на чаші — це вже суперечність із клеймом «3 = 800»** зі справи 1,
> і уважний гравець ловить її за десять хвилин до пропилу. Пропил це лише **підтверджує**.

### В. Паяльна трубка: нальоти на вугіллі (ліва сторінка розвороту `hb_alloys_spread`)

Пробірне мистецтво паяльною трубкою (Берцеліус, Платтнер) — стандарт з 1820-х і цілком у добі.
Ознаки справжні.

| Метал | Наліт на вугіллі | Де | Летючість | Ще |
|---|---|---|---|---|
| **Lead** | жовтий гарячим, білуватий холодним | **близько до кульки** | відновним полум'ям **зводиться назад у метал** | полум'я **бліде синє** |
| **Antimony** | білий **із синюватим відтінком**, густий дим | **далі від кульки** | **легко здувається геть** | запаху нема |
| **Arsenic** | білий | далеко | летючий | **запах часнику** — ознака-заперечення |
| **Tin** | білий, ледь жовтявий гарячим | **під кулькою** | **не здувається** | від краплі кобальтового розчину й нового жару — **синьо-зелений** |
| **Zinc** | жовтий гарячим, білий холодним | близько | не здувається | з кобальтом — **зелений** |
| **Bismuth** | оранжево-жовтий | далі | летючий | — |
| **Silver, copper** | нальоту не дають | — | — | лишається кулька металу |

### Г. Свинець і його сплави по ремеслах (права сторінка того ж розвороту)

Реальні склади доби.

| Ремесло, річ | Сплав | Частин на сто |
|---|---|---|
| Plumber's soft solder («half-and-half») | lead · tin | 50 · 50 |
| Plumber's wiping metal | lead · tin | 65 · 35 |
| Sounding lead, sash weight, pipe | lead | 100 |
| Shot | lead · arsenic | 99.6 · 0.4 |
| Pewter, common | tin · lead · antimony · copper | tin 80 і більше |
| Britannia metal | tin · antimony · copper | tin 90 |
| **Printing type, cast for hand-setting** | **lead · antimony · tin** | **70–75 · 18–25 · 3–8** |
| **Stereotype plate metal** | **lead · antimony · tin** | **80–86 · 11–16 · 3–5** |
| Type metal much remelted, «grown soft» | lead · antimony · tin | до 90 · 8 · 2 |
| Bearing (white) metal | lead або tin · antimony · copper | різно |

> Друкована примітка внизу сторінки — **та, на якій стоїть уся справа**:
> "Antimony is put into lead for one reason only: that the casting shall hold a sharp edge when it
> is cold. It is met in printing type, in stereotype plate and in bearings. The plumber's trade has
> no use for it, and his solder and his sounding lead carry tin and no antimony at all."
>
> Друга примітка — чому сплав виявився м'якшим за нову літеру:
> "Type that has been melted and cast again many times loses its antimony into the dross, and the
> founder must harden it afresh. Scrap type run into a bar is poorer in antimony than new type."

### Ґ. Літера в металі (там же, на полі правої сторінки — дрібним, з гравюрою)

| Що | Правило |
|---|---|
| **counter** (очко) | замкнена порожнина всередині літери: у **a, b, d, e, g, o, p, q, R, B, D, O** |
| **nick** (нікс) | одна або кілька **прямостінних борозен по череву літери** на всю її довжину: щоб набірник наосліп знайшов, де в літери низ |
| висота літери | у Відні — за системою Дідо, **1 пункт = 0.376 мм**; кегль тексту 8–10 пунктів |
| що лишається в недбалому зливку | шматок літери не встигає розчинитися й **застигає в шкірці заливної грані**: видно очко й видно борозну нікса |

> Ключ, і він односторонній: **очко буває в будь-якій литві. Борозна нікса на всю довжину буває
> тільки в літери.** Разом вони не мають другого пояснення. Ось звідки друкарня.

### Д. Купеляція (табличка на дверцятах печурки)

| Що | Правило |
|---|---|
| що робить купель | кістяний попіл п'є свинець і його окиси; **срібло й золото лишаються кулькою** |
| як читається | **проба = вага кульки ÷ вага взятого × 1000** |
| гальванічне срібло | осад **майже чисте срібло, 990 і вище** |
| накладне срібло (плакування, до 1840) | шкірка **стерлінгова, близько 925** |
| кована річ із пробою | **дає свою пробу**: 800 дає 800 |
| товарний свинець доби | несе слідове срібло, **десятки частин на мільйон**; це не проба, а домішка руди |

> **Арифметика гравця:** 0.497 ÷ 0.500 × 1000 = **994**. Клеймо каже **3 = 800**.
> Це не «майже», це інший метал і інший спосіб його туди покласти.
> Друга кулька: 2.4 мг із 50 г = 48 частин на мільйон, тобто **срібла в заливці нема**:
> заливка не «срібний баласт», а звичайний товарний свинець із домішкою руди.

### Е. Знаки віденської пробірної управи

Той самий розворот, що у справі 1 (`hb_vienna_marks`), і той самий факт `f.hb_vienna_marks`,
який гравець уже має зі збереження. Тут він потрібен рівно для одного: **«3» у голові Діани
означає 800 у тисячі**, а шкірка дає 994.

---

## 7. АТЕСТАТ — 6 граф, дві числові

Бланк `cert_08_cup_returned` — **той самий бланк, що у справі 1**, але з надрукованим угорі
рядком: *«Second examination, upon the order of the court. The first certificate of this office
is annexed.»* І атестат справи 1 **справді підшитий збоку**, розгорнутий, поки гравець пише.
`kind` за `core/slots.gd`: CHOICE / NUMBER / FACTS. `opts` тримають **id**, на папір лягає
`tr("opt." + id)`.

| # | slot_id | префікс (EN) | тип | гейт | варіанти / межі |
|---|---|---|---|---|---|
| 1 | `s.body` | "The body of the piece is ____" | CHOICE | `needs_any: [f.rim_cut, f.acid_rim_green]` | `o.silver_throughout` "silver throughout, 800 in the thousand, as the mark says" · `o.silver_skin_hollow` "a skin of silver upon copper, and hollow beneath" · `o.silver_skin_loaded` "a skin of silver upon copper, the stem and foot run full of a lead alloy" · `o.no_silver` "copper, whitened, with no silver upon it at all" |
| 2 | `s.sg` | "Weight against water, water being 100: ____" | **NUMBER** `digits 4, min 500, max 2000` | `needs: [f.hydrostatic]` | списку нема, валідації нема. *(істина: **1009**)* |
| 3 | `s.skin_fineness` | "The white surface assays ____ in the thousand" | **NUMBER** `digits 3, min 0, max 999` | `needs: [f.assay_skin]` | списку нема, валідації нема. *(істина: **994**)* |
| 4 | `s.mono_order` | "The letters upon the stem were cut ____" | CHOICE | `needs: [f.mono_read]`, `needs_any: [f.engraved_last, f.strat_engrave]` | `o.before_the_scratch` "before the piece was ever scratched" · `o.before_the_burnish` "before the band was burnished" · `o.after_the_burnish` "after the band was burnished" · `o.cannot_be_told` "not to be told from the surface" |
| 5 | `s.trade` | "The metal in the stem was got from ____" | CHOICE | `needs: [f.blowpipe_load, f.hb_lead_trades]` | `o.plumbers_trade` "the pledger's own trade — solder and sounding lead" · `o.printing_house` "a house that casts and prints letters" · `o.church_plate_melted` "church plate, melted down" · `o.merchant_pig` "a merchant's pig lead, of no trade at all" · `o.cannot_be_told` "not to be told" |
| 6 | `s.basis` | "On the strength of:" | FACTS `min 2, max 4` | `needs_slot: [s.trade]`, `clears_on: [s.trade, s.body]` | джерело — `state.fact_order`, без групи `strat` |

**Істина** (рушій її не знає — знають тільки OUTCOMES):
`s.body = o.silver_skin_loaded` · `s.sg = 1009` · `s.skin_fineness = 994` ·
`s.mono_order = o.after_the_burnish` · `s.trade = o.printing_house`.

**Чому графа 2 мусить бути в бланку, хоч її число нічого не доводить.** Бо бюро пише те, що
зміряло, а не те, що вирішило. 1009 стоїть **між** сріблом 800 (1020) і 750 (1010) — і буде
стояти в підшивці як єдине число справи, яке не працює. Це і є урок перед справою 10, де прилад
замовкне зовсім. Валідації нема, фідбеку нема; вписати 1020 можна, і ніхто не скаже слова.

**Різниця дат — числа в бланку нема, а число є.** `f.cert_returned` дає 14 березня,
`f.pawn_ticket` дає 19 березня. **П'ять днів.** Гра ніде не робить це віднімання й ніде його не
згадує. Воно потрібне лише в одному місці: якщо гравець кладе **обидва** ці факти в графу
«on the strength of» — це змінює гілку наслідків (див. O1, `basis_needs`). Бюро не пише, скільки
днів; бюро вирішує, чи згадувати про них.

---

## 8. НАСЛІДКИ (ранок наступного дня)

Матчер бере **перший** запис, чиї умови збіглися. `out.default` — завжди останній.
У **кожній** гілці є рядок про Катаріну Райтгофер. Гра ніде не каже, чи гравець мав рацію.

### O1 · `out.printing_house` — названо ремесло
```
when: s.trade = o.printing_house
      s.body  = o.silver_skin_loaded
      s.mono_order = o.after_the_burnish
      s.skin_fineness = {min: 990, max: 999}
basis_any:   [f.blowpipe_ingot, f.blowpipe_solder, f.ingot_counter]
basis_weight: 8
```
> Prohaska at half past seven, out of breath, with his docket closed and his boot still open.
> Novak was let go at six and stood in the street a while before he understood he might walk. He
> pledges for eleven people and does not read; he says the cup and the bar came to him together,
> in that paper, from a man he meets at a beer house and knows by his hands.
>
> The type-founders keep a list of the houses they supply. There are nine in the district. The
> constables went to the fourth on the list, in Wieden, at eight; the presses were running and the
> foreman's apron was on his hook and the foreman was not. In the waste under his frame: black
> bordered forms, standing set up, the name-space left blank, thirty of them.
>
> The office has had one of those before. It is in the file, under the fifth of last month, and
> the name on it was written out in this office, in your hand, the day before it came.
>
> Frau Reithofer was not in the corridor and had not been seen to leave. The chair had not been moved.

### O2 · `out.blamed_the_pledger` — названо заставника
```
when: s.trade = o.plumbers_trade
```
> Novak was committed for trial at ten. He asked for the paper to be read to him twice, and after
> the second reading he asked who had weighed the cup, and was told it was not his business.
>
> His wife came in the afternoon to ask whether the office would take his tools in pledge, the
> tools being all there is. She was told the office does not lend. She put them on the desk anyway
> and left them: a stick of soft solder, half used, and a sounding lead on a cord.
>
> Six weeks later a broker in the Leopoldstadt sends up a cup for opinion. It stands 196 mm, weighs
> 331 g, and the stem is closed with a soldered disc that has never been dressed down.
>
> Frau Reithofer's name is on that broker's counter book, twice, in a hand that is not hers.

### O3 · `out.honest_silver` — річ визнано срібною
```
when: s.body = o.silver_throughout
   OR s.body = o.silver_skin_hollow
```
> The court released the cup to the broker on your certificate, the second one strengthening the
> first, and the broker sold it on the Thursday for a hundred and ten gulden to a house on the
> Graben, which copied both certificates into its book and spelled your name correctly on the
> second attempt.
>
> On Friday the same house wrote to ask whether the office would look at four more pieces from the
> same seller, and whether, this time, it would be so good as to cut.
>
> Frau Reithofer came in the morning to sign for nothing at all, since the cup was not hers to take
> back, and signed, and thanked you, and asked whether the paper meant it had all been in order
> from the start.

### O4 · `out.named_the_church` — визнано церковне срібло
```
when: s.mono_order = o.before_the_burnish
   OR s.mono_order = o.before_the_scratch
```
> Two constables and a priest at nine, with a list of the parishes of two dioceses. Nothing is
> missing from any of them and nothing has been missing for eleven years. The priest was patient
> about it and asked to see the letters himself, and looked at them a long time, and said that the
> place they stand in is not the place they stand in.
>
> Frau Reithofer was taken to the district office at eleven to say where the cup had been kept,
> and said the press in her grandmother's room, and was asked again in the afternoon, and said the
> press in her grandmother's room.
>
> The file stays open until a parish reports a cup. The court has asked the office, in writing, on
> what the finding rested, and the letter is on the desk, and it is polite.

### O5 · `out.default` — печатка стоїть, і на цьому все
```
when: {}
```
> The cup and the bar went back into the tray at eight and Prohaska carried them out with his
> docket. He was pleased. On the stairs he said the office had been very thorough and that he
> would say so.
>
> The ledger line for the day reads: *sealed, one; consumed in the examination: 0.500 g of the
> surface, 50 g of the loading, one file cut in the foot.* This is the first line in the book in
> forty years that says what the office destroyed. The line above it, in the other hand, says
> nothing of the kind, and there are one thousand four hundred and twenty-nine of them.
>
> The corridor was empty. The chair stood where it stood.

---

## 9. ХИБНИЙ СЛІД

**Що спокушає.** **Franz Novak, lead-worker** — і все, що про нього відомо, складається саме так,
як має складатися. Констебль викладає його першою реплікою, не питаний:

> "We have the man. Novak, lead-worker, out of Gumpendorf. He had the bar in his coat pocket and
> the grey in the creases of his hands and under every nail of them, and he did not wash it off
> before he came to the counter. A man who works in lead pawns a cup that is run full of lead. The
> inquiry sits on Friday."

Далі гравець власними руками добуває чотири підтвердження: ніжка залита сірим металом · зливок із
того самого металу лежав на одній квитанційній лінії з келихом · зливок був **у кишені** Новака ·
його ремесло називається «свинцевих справ майстер». Свинець на руках, свинець у кишені, свинець
у ніжці. **Хибний слід не бреше жодним словом** — він просто складається з правильних фактів у
неправильний висновок.

**Куди веде.** У графу `s.trade = o.plumbers_trade` і в гілку **O2**: Новака віддають під суд,
його дружина приносить на стіл його інструмент, а через шість тижнів у Леопольдштадті з'являється
другий келих із такою самою заливкою. Слід має власну повноцінну гілку наслідків і власне
завершення — тобто він **не карається** і не позначається як помилка. Гравець може закрити справу
за 18 хвилин, і вона буде виглядати закритою.

**Чим спростовується — двома незалежними речами.**

1. **Фізично, і це головне.** Паяльна трубка на **його власний матеріал** із кишені
   (`f.blowpipe_solder`): стік припою і лот-грузило дають **два** нальоти — свинцевий біля кульки
   й олов'яний під кулькою. **Третього — білого з синюватим відтінком, здаля, летючого — нема, і
   немає з трьох спроб.** А заливка ніжки (`f.blowpipe_load`) і зливок (`f.blowpipe_ingot`) дають
   **усі три, в тому самому порядку**. Довідник (`f.hb_lead_trades`) друком каже, чому це
   вирішує: сурму кладуть у свинець **тільки** там, де відливок мусить тримати гостру кромку, і в
   паяльному ремеслі її нема **взагалі**. Свинець на руках доводить, що людина працює зі свинцем.
   Він **не доводить, з яким саме**.
2. **Літера.** У шкірці заливної грані зливка стоїть уламок: замкнене овальне очко **і борозна
   нікса на всю довжину бруска** (`f.ingot_counter`). Очко буває в будь-якій литві; борозна нікса
   по всьому череву — тільки в друкарської літери. Ремесло Новака літер не ллє.

**Чому це чесний хибний слід, а не декорація.** (а) Він пояснює **все**, що гравець уже здобув, і
робить це раніше, ніж гравець дійде до трубки. (б) Його приносить **клієнт**, тобто той, кому
потрібен саме такий висновок і в кого термін до п'ятниці. (в) Він має власну гілку наслідків, і
вона тиха. (г) Спростовується **інструментом і зішкребом**, а не здогадкою, і коштує одного
заряду трубки на річ, яку гравець спершу вважав декорацією в лотку. (ґ) І він **не бреше**:
Новак справді свинцевий майстер, зливок справді був у нього, метал справді свинцевий. Бреше лише
припущення, що свинець буває один. Той самий прийом, що у справі 1 (квитанція про *інший* келих),
у справі 3 (лист про *інший* годинник) і у справі 9 (одруківка в *іншому* некрологу).

**Друга, менша спокуса, яка вбиває себе сама** (r.13): краплю Шверте́ра можна поставити на рант
**до** пропилу. Вона дасть **криваво-червону**, як на чаші, з'їсть заряд і не дасть факту. Це
буквальна пастка правила «на накладній речі перша проба відповідає за шкірку».

---

## 10. ДВІ ГІПОТЕЗИ І РОЗВОДЖУВАЛЬНИЙ ФАКТ

**(А) Річ зробив і заклав той, хто працює зі свинцем — заставник.** Ніжка залита свинцевим
сплавом; зливок того самого сплаву лежав у нього в кишені й пішов у заставу на одній лінії з
келихом; ремесло його — свинець; свинець у нього під нігтями. Він мав метал, мав руки і мав
причину: атестат бюро зробив річ продажною, і рівно через п'ять днів річ стала грішми.
**(Б) Річ зробили в друкарні, а заставник — тільки рука, яка донесла її до прилавка.** Сплав
ніжки і сплав зливка — один, і це сплав, який тримає кромку; такий сплав ллють там, де ллють
літери; у шкірці зливка стоїть уламок літери; зливок був загорнутий у зіпсований відтиск
чорнобордюрної картки з ненадрукованим ім'ям; на прилавковій книзі те саме прізвище стоїть
одинадцять разів за два роки, і чотири рази з поміткою «за замовника». Обидві гіпотези до кінця
живі, і жоден із трьох великих доказів справи їх не розводить: **пропил, купеляція і
стратиграфія однаково добре працюють на обидві** — вони кажуть, що річ підробка й що монограму
дорізали пізніше, але **ні слова про те, чия рука**. Гідростатика теж не розводить: 1009 стоїть
між двома пробами срібла і не показує ні на кого. **Розводить одна річ, і вона з третього боку:**
**сурма** — той білий із синюватим відтінком наліт, що сідає на вугіллі **далеко** від кульки й
здувається полум'ям. Він є в заливці ніжки. Він є в зливку. **Його нема у власному металі
заставника, і нема з трьох спроб.** Один елемент, присутній у двох місцях і відсутній у третьому,
розтинає (А) і (Б) навпіл: людина зі свинцем на руках не має нічого, що містить сурму, а сурму
кладуть у свинець тільки для того, щоб відливок тримав кромку літери.

---

## 11. СТРИБОК ДУМКИ

Гравець сам виводить, що шукати треба не людину зі свинцем на руках, а людину, у якої свинець
**твердий**, — бо твердим свинець роблять лише там, де він мусить тримати кромку літери, а отже
підробник стоїть не біля паяльної лампи, а біля друкарського станка.

---

## 12. ВХІД (як гравець дізнається, що тут треба діяти)

П'ять діегетичних дверей, жодної підказки. Три перші відкриваються в перші дві хвилини, до
жодного інструмента.

1. **Власний атестат приходить назад.** Констебль кладе його першим, зворотом догори, і на звороті
   чужою рукою: *«taken on the strength of this, 40 fl.»* Гравець читає власний почерк і власну
   печатку. Дата — 14 березня. Це вхід не в загадку, а в справу: **річ повернулась через тебе.**
2. **Судовий дозвіл — і шафа.** Другим на стіл лягає дозвіл: *«the office may cut, burn and consume
   so much of the article as is needful»*. У ту саму мить **клацає замок шафи за столом** — тієї,
   що стояла замкнена сім справ, і яку гравець пробував відчинити (у справі 1 `tool.saw` каже:
   *«Not without a paper that says I may»*). Із неї виходять надфіль, піпетка, трубка, вугільна
   плитка, купелі й спирт. **Головна відповідь гри на питання «чому я не зробив цього у справі 1»
   — не механічна, а адміністративна**, і вона лежить на столі папером.
3. **Друга річ у лотку, якої ніхто не просив атестувати.** Констебль: *"The broker had this on the
   shelf beside it and booked them on one line, so it comes with it. I do not know what it is for."*
   Зливок нікому не потрібен, ні в бланку його нема, ні в дозволі. **Уся справа в ньому.**
4. **Папір, у який був загорнутий зливок**, лежить у лотку зім'ятий, як пакувальне. Розгорнути —
   дія на один клік; чорна рамка видна голим оком **з екрана DESK**, ще до інструментів.
   Ім'я не надруковане. Гра не коментує.
5. **Затерта смуга на стояку.** Косе світло у справі 8 увімкнене з першого кадру (лампа нахилена
   від справи 1), і смуга **видна голим оком**: `tool.eye` на `z.stem.shaft` каже
   *"Two fingers of the stem take the light differently. Nothing is written there."* — без факту.
   Гравець сам візьме спирт.

**Гарантія від глухого кута.** Якщо 4 хвилини без нового факту, констебль показує на **рід
невикористаної дії**, ніколи на місце:

| Що ще не роблено | Репліка |
|---|---|
| нема `f.hydrostatic` | "They weigh things in water at the mint. I have seen it. It looks like nothing at all." |
| нема `f.rim_cut`, дозвіл прочитано | "The paper says you may cut. It says so twice." |
| нема жодного `blowpipe`-факту | "The assayer at the pledge office burns a scrape of it on a coal. It smells." |
| нема `f.blowpipe_solder` | "His own things are in the tray. I put them in myself." |
| нема `f.wrapper_proof` | "The paper it came in is in the tray. I did not throw it away." |
| стратиграфія розкладена неправильно | **мовчання.** Картки просто лежать. Ніякого червоного |

---

## 13. ГЕЙТ ЯКОСТІ

Свіжий агент-казуал проходить справу і мусить сказати **своїми словами**:

> «У ніжку залито свинець із сурмою, і точно такий самий сплав лежав у ломбарді поруч, а в тому
> зливку застиг шматок літери з борозною. Сурму кладуть у свинець тільки щоб він тримав кромку —
> для літер. А у власного свинцю заставника сурми нема взагалі. Значить це не він: річ прийшла з
> друкарні, а він тільки заклав.»

Сказав «я перебрав інструменти й вписав, що знайшлось» — справа переробляється (`PUZZLES_V4` §0).

---

## 14. ДЕ Я САМ СУМНІВАЮСЯ (читати перед артом і перед кодом)

1. **Фактів більше за норму: 22 замість 10–14.** Я це зробив свідомо (45 хв, повний пояс, дві
   речі замість однієї, чотири факти читаються з паперів у перші три хвилини), але це **єдина**
   справа, де я вийшов за норму `PUZZLES_V4` §5. Якщо на плейтесті нотатник стане списком покупок
   — різати першими: `f.stem_thin`, `f.assay_load`, `f.disc_seam`, `f.hb_church`. Жоден із
   чотирьох не тримає жодну гілку наслідків.
2. **Щільність 10.1 і внутрішня арифметика речі — найслабше місце справи, і я мусив це сказати
   прямо.** Число 10.09 (331.0 / 32.8) я взяв із V6, а вага 331 г — зі справи 1, і вони обидва
   зафіксовані. Але **скласти з них правдоподібну начинку важко**: мідь (8.93) тягне середнє вниз
   так сильно, що 10.09 виходить лише за дуже вузького розкладу — приблизно **96 г мідної шкаралупи
   (≈0.35 мм стінки), 224 г заливки й 11 г срібної шкірки**. За такого розкладу заливка мусить мати
   вагу проти води ≈ **1065**, тобто **Pb 90 · Sb 8 · Sn 2**, а це не нова літера (950), а
   **багато разів перелитий гарт** — тому в довіднику Г я і поставив рядок «type metal much
   remelted, grown soft». Це історично правда (сурма йде в шлак при кожному перетопі), і воно
   врятувало числа, але **порядок дій був зворотний: я підганяв склад під задану щільність.**
   Що з цим робити: (а) лишити як є — сходиться, і в грі жодна арифметика цього не показує;
   (б) якщо Віктор хоче твердого гарту 70/20/10 (950), тоді щільність цілого келиха падає до
   **≈9.5**, і V6 треба правити на 9.5 — до речі, стало б **краще**: 9.5 не схоже ні на срібло, ні
   на мідь, і графа 2 брехала б інакше. **Моя рекомендація: лишити 10.09 і рядок «перелитий гарт»**,
   бо 10.09 «майже срібло» працює як пастка, а 9.5 — ні. Але вирішувати треба **до** 3D-моделі,
   бо товщина стінки 0.35 мм — це те, що художник намалює або не намалює.
3. **Купеляція в бюро — вільність, і я знаю, яка.** Муфельна печурка, купелі з кістяного попелу й
   аналітична вага, що читає 0.1 мг, — це обладнання **пробірної лабораторії**, а не оцінювача.
   Ваги доби таку точність давали (Ертлінг, Беккер читали до 0.01 мг), і мала муфельна печурка в
   задній кімнаті ювелірного/пробірного дому — річ звичайна; але «бюро атрибуції» з власною
   печуркою — це те, у що Віктор мусить повірити **артом**, а не текстом. Якщо не вірить —
   заміна є і вона чесна: **проба на камені з ігольником** (touchstone + touch needles), і тоді
   графа 3 стає не «994», а «higher than the needle of 950», тобто CHOICE, і справа втрачає одну
   числову графу. Я цього не хочу — 994 проти 800 найкрасивіше число гри.
4. **«Вага проти води, вода = 100» — моє формулювання, не цитата.** Таблиці доби друкували питому
   вагу і як «10.474», і як «10474, вода = 1000». Я звів до трьох-чотирьох цифр (вода = 100), щоб
   графа NUMBER була цілим числом і щоб гравець ділив у стовпчик один раз. Формулювання префікса
   треба **прочитати вголос** перед версткою бланка: якщо звучить як механіка, а не як бюрократія
   — переписати, але **число лишити цілим**.
5. **Зішкреб для паяльної трубки — це витрата речі, і дозвіл на неї є в тексті ордера, але
   формально це друга руйнівна дія**, а `tool.blowpipe` у мене APPLY, не DESTRUCTIVE, і без
   `confirm`. Зроблено, щоб не питати підтвердження чотири рази поспіль. Якщо Віктор вважає, що
   бюро мусить питати щоразу — поставити `confirm` **тільки на перший** заряд трубки
   (`uses_max` лишити 4), а не на кожен.
6. **Уламок літери в зливку — найтонше місце історичної правди.** Що літера не встигає
   розчинитися й лишає рельєф у шкірці недбало вилитого зливка — правдоподібно, але я не маю на це
   документованого прикладу; це висновок із того, як застигає перелив. Що **нікс — прямостінна
   борозна по череву літери на всю довжину** — правда і легко перевіряється. Тому доказ я поставив
   на **пару** «очко + нікс», а не на очко: очко саме по собі можна списати на будь-яку литву.
   Перед артом `ingot_face` звірити фото друкарської літери збоку.
7. **Дати: 14 і 19 березня, «сьогодні» — 4 травня.** Ці три числа мусять узгодитися з глобальним
   календарем гри (справа 1 = день 1). Я їх поставив, бо графа різниці дат і рядок гросбуха на них
   тримаються. **Якщо календар зсунеться — правити тут і в `cert_01_returned`, і слідкувати, щоб
   різниця лишилась 5.** П'ять днів — це не довільна цифра: вона мусить бути **менша за тиждень**,
   щоб гравець відчув, що річ пішла в заставу практично з його рук.
8. **Восковий відтиск і справа 3.** Я зробив `f.wax_match` **бонусом**, а не гейтом: він не
   потрібен жодній графі, а важить у O1 через `basis_any`. Причина — надійність: якщо гравець у
   справі 3 не знімав відтиску, картка все одно лежить у шухляді (її підшив попередник/бюро
   автоматично, і на ній **власний почерк гравця**). Але **докет «11 квітня» мусить збігтися з
   днем справи 3** — інакше найстрашніша деталь справи стає помилкою верстки.
9. **`f.acid_bowl_red` як суперечність із клеймом 800.** За шкалою Шверте́ра 800 дає **буру**, а
   не червону, — отже уважний гравець ловить підробку ще до пропилу, з однієї краплі. Це чесно й
   історично, але **зменшує потребу в пропилі**. Я лишив це навмисно (три дороги до висновку,
   правило 5 CLAUDE.md), але якщо на плейтесті пропил почнуть пропускати — не прибирати шкалу, а
   **перенести гейт `s.body` на `needs: [f.rim_cut]`** замість `needs_any`.
10. **Ім'я Novak** — одне з найпоширеніших прізвищ у Відні доби, узяте саме тому: воно читається
    як рядок списку, а не як конкретна людина (правило 4, IP-чек). Prohaska — так само.
    **Друкарню в жодній гілці не названо** — тільки район і номер у списку постачальників: ім'я
    друкарні належить справі 9, а не цій.
