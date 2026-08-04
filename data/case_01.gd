# data/case_01.gd — СПРАВА 1 «СРІБНИЙ КЕЛИХ» як ДАНІ, не як код.
#
# ✅ 26.07: КЛЕЙМО ДІАНИ ДОМАЛЬОВАНО — центральна дедукція справи 1 стала можливою.
#
# Виявлено 26.07 картою зон (`godot ... -- zonemap`) і оглядом текстур очима:
# арт і специфікація реалізують ДВІ РІЗНІ загадки.
#
#   ЩО В АРТІ (foot_plate_maker.png / foot_plate_church.png):
#     щит майстра ліворуч + ЗАЧИЩЕНА ПЛЯМА праворуч, у якій під косим світлом
#     проступає потир із хрестом — зішліфоване церковне клеймо.
#     Текст у main.gd цьому точно відповідає.
#
#   ДОДАНО 26.07 (foot_plate_maker_v2 / foot_plate_church_v2):
#     голова Діани з цифрою 3 і літерою A ВСЕРЕДИНІ контуру. На ній тримається
#     весь стрибок думки: літера всередині = карбування не раніше 1872, а реєстр
#     каже, що клеймо Гоффманна викреслено 1871. Клейма молодші за майстерню.
#
# Клеймо додано прийомом «edit, don't re-roll»: правка наявної пластини, тоді
# накладення ТІЛЬКИ нового пунсона на обидві версії (нормальне й косе світло),
# щоб решта дна лишилась побітово тією самою і плити не «смикались» при перемиканні.
#
# ЩО ЩЕ РОЗХОДИТЬСЯ: специфікація зве клеймо майстра «прямокутником зі зрізаними
# кутами L·HOFFMANN», а в арті це ЩИТ із монограмою, і саме щит гра звіряє з
# каталогом. Тут правдивий арт — текст справи треба привести до нього, не навпаки.
#
# Джерело істини для змісту: _src/cases/case_01.md. Розбіжність між цим файлом і
# специфікацією — помилка, і ловить її tools/validate_cases.py.
#
# Закон, який тут не можна порушити (CLAUDE.md §6, PUZZLES_V4):
#   `say` — це СПОСТЕРЕЖЕННЯ. Ніколи не висновок. Жодного «отже», «підроблено»,
#   «пізніше за». Що це означає — вирішує гравець, і гра йому цього не каже.
extends RefCounted

# ── ЗОНИ ─────────────────────────────────────────────────────────────────────
# 3D — локальні координати goblet_pivot, 1 одиниця = 100 мм, келих 196 мм.
# 2D — частки САМОГО ЗОБРАЖЕННЯ; радіус — частка ШИРИНИ зображення.
const ZONES := {
	&"z.cup.whole": {
		"kind": &"img", "screen": &"DESK", "surface": &"case_desk",
		# u.y виміряно з фактичного хотспота келиха в грі (аудит 26.07, знахідка 48):
		# специфікаційні 0.470 стояли на ~40 px нижче за намальований келих
		"u": Vector2(0.508, 0.414), "shape": &"rect", "half": Vector2(0.088, 0.262),
		"tools": [&"tool.caliper", &"tool.scales", &"tool.hand"],
	},
	&"z.bowl.inner": {
		"kind": &"mesh", "screen": &"HANDS", "node": &"goblet_pivot",
		"at": Vector3(0, 0.55, 0), "facing": Vector3(0, 1, 0),
		"r": 0.34, "facing_min": 0.20,
		"tools": [&"tool.eye", &"tool.loupe", &"tool.rake"],
	},
	&"z.stem.knop": {
		"kind": &"mesh", "screen": &"HANDS", "node": &"goblet_pivot",
		"at": Vector3(0, -0.36, 0.10), "facing": Vector3(0, 0.15, 0.99),
		"r": 0.13, "facing_min": 0.05,
		"tools": [&"tool.eye", &"tool.loupe", &"tool.rake"],
	},
	# Верх піддона і спід піддона стоять на ОДНАКОВІЙ відстані від осі (0.28).
	# Горбик — це буквально зворот клейма. Зсунути одне без одного не можна:
	# на цій тотожності тримається вся справа.
	&"z.foot.top": {
		"kind": &"mesh", "screen": &"HANDS", "node": &"goblet_pivot",
		"at": Vector3(0, -0.86, 0.28), "facing": Vector3(0, 0.80, 0.60),
		"r": 0.30, "facing_min": 0.02,
		"hint": "The slope of the foot — a short stroke of the finger, not a turn",
		"tools": [&"tool.hand", &"tool.rake", &"tool.loupe"],
	},
	# ⚠ КООРДИНАТА ВЗЯТА З МОДЕЛІ, НЕ ЗІ СПЕЦИФІКАЦІЇ. У case_01.md стоїть y = −0.96
	# (спід вважається плоским), а побудована поверхня обертання підіймає ВГНУТЕ дно
	# до y = −0.69. Різниця на екрані — 77 пікселів: за координатою з документа лупа
	# шукала б клеймо там, де його нема. Виявлено тіньовим прогоном рушія (0 збігів із 62).
	&"z.foot.underside": {
		"kind": &"mesh", "screen": &"HANDS", "node": &"goblet_pivot",
		# РАДІУС 0.45 — порахований, не вгаданий. Клейма стоять на 0.289 (майстрове) і
		# 0.227 (церковне) від центру пластини, сама пластина має радіус 0.34.
		# Специфікаційні 0.22 НЕ накрили б майстрове клеймо: гравець наводив би точно
		# на нього й не отримував нічого. Старий код мав ефективні 1.34 — учетверо
		# більше за все дно, тобто прицілювання не було взагалі.
		# 0.45 накриває обидва клейма із запасом у ширину клейма й лишається втричі
		# строгішим за старе: скло треба тримати над піддоном, а не «десь біля чаші».
		"at": Vector3(0, -0.69, 0.0), "facing": Vector3(0, -1, 0),
		"r": 0.45, "facing_min": 0.12,
		"tools": [&"tool.loupe", &"tool.rake"],
	},
	&"z.foot.edge": {
		"kind": &"mesh", "screen": &"HANDS", "node": &"goblet_pivot",
		"at": Vector3(0, -0.93, 0.52), "facing": Vector3(0, -0.30, 0.95),
		"r": 0.075, "facing_min": 0.05,
		"tools": [&"tool.rake", &"tool.loupe"],
	},
	# --- папери й довідники: той самий рушій, будь-який інструмент, on_click ---
	# ⚠ КРОК 6: екран квитанції ЩЕ НЕ ІСНУЄ (на DOCS зараз лист клієнтки — інший папір).
	# screen позначено майбутнім ім'ям, щоб ловець DOCS не пропонував зону без поверхні.
	&"z.papers.receipt": {
		"kind": &"img", "screen": &"DOCS_RECEIPT", "surface": &"paper_receipt_1807",
		"u": Vector2(0.500, 0.480), "shape": &"rect", "half": Vector2(0.440, 0.450),
		"tools": [], "on_click": true,
	},
	# --- ЗОНИ З ГРИ, ЩЕ НЕ ВНЕСЕНІ В case_01.md (аудит 26.07, знахідки 1 і 24):
	# лист клієнтки і газета. Вносити в §2–§4 специфікації разом із квитанцією (крок 6).
	&"z.papers.letter": {
		"kind": &"img", "screen": &"DOCS", "surface": &"letter_client",
		"u": Vector2(0.50, 0.42), "shape": &"rect", "half": Vector2(0.34, 0.26),
		"hint": "The client's letter", "tools": [], "on_click": true,
	},
	&"z.news.robbery": {
		"kind": &"img", "screen": &"NEWS", "surface": &"newspaper_final",
		"u": Vector2(0.499, 0.185), "shape": &"rect", "half": Vector2(0.392, 0.045),
		"hint": "The lead of the paper", "tools": [], "on_click": true,
	},
	&"z.news.later": {
		"kind": &"img", "screen": &"NEWS", "surface": &"newspaper_final",
		"u": Vector2(0.201, 0.830), "shape": &"rect", "half": Vector2(0.136, 0.104),
		"hint": "A later paragraph", "tools": [], "on_click": true,
	},
	&"z.news.society": {
		"kind": &"img", "screen": &"NEWS", "surface": &"newspaper_final",
		"u": Vector2(0.494, 0.541), "shape": &"rect", "half": Vector2(0.136, 0.100),
		"hint": "About the town", "tools": [], "on_click": true,
	},
	&"z.news.assayer": {
		"kind": &"img", "screen": &"NEWS", "surface": &"newspaper_final",
		"u": Vector2(0.502, 0.872), "shape": &"rect", "half": Vector2(0.132, 0.050),
		"hint": "Correspondence", "tools": [], "on_click": true,
	},
	&"z.news.market": {
		"kind": &"img", "screen": &"NEWS", "surface": &"newspaper_final",
		"u": Vector2(0.790, 0.897), "shape": &"rect", "half": Vector2(0.137, 0.053),
		"hint": "The market column", "tools": [], "on_click": true,
	},
	&"z.book.register": {
		"kind": &"img", "screen": &"BOOK_REG", "surface": &"reg_page_h",
		"u": Vector2(0.500, 0.500), "shape": &"rect", "half": Vector2(0.470, 0.470),
		"tools": [], "on_click": true,
	},
	&"z.book.marks": {
		"kind": &"img", "screen": &"BOOK_MARKS", "surface": &"marks_page_vienna",
		"u": Vector2(0.500, 0.500), "shape": &"rect", "half": Vector2(0.470, 0.470),
		"tools": [], "on_click": true,
	},
}

# ── ІНСТРУМЕНТИ ──────────────────────────────────────────────────────────────
# Шість, і це навмисно мало: справа 1 — туторіал.
const TOOLS := {
	&"tool.eye":     {"verb": &"observe", "from_start": true},
	&"tool.hand":    {"verb": &"observe", "from_start": true, "on_click": true},
	&"tool.rake":    {"verb": &"observe", "from_start": true},
	&"tool.loupe":   {"verb": &"observe", "magnify": 4.3},
	&"tool.caliper": {"verb": &"measure", "unlocked_by": &"f.receipt_1807"},
	# ваги мусять чесно відпрацювати: на цьому тримається справа 10
	&"tool.scales":  {"verb": &"measure", "unlocked_by": &"f.receipt_1807"},
}

# ── ПРАВИЛА: зона × інструмент → факт ────────────────────────────────────────
const RULES := [
	{"zone": &"z.cup.whole", "tool": &"tool.caliper", "facts": [&"f.height_196"],
	 "say": "Height, lip to table: 196 mm. Foot: 104 mm across."},
	{"zone": &"z.cup.whole", "tool": &"tool.scales", "facts": [&"f.weight_331"], "repeat": true,
	 "say": "On the balance: 331 g. It sits still at once."},
	{"zone": &"z.cup.whole", "tool": &"tool.hand", "facts": [], "screen": &"HANDS",
	 "say": "The cup comes up into both hands."},

	{"zone": &"z.bowl.inner", "tool": &"tool.eye", "facts": [&"f.bowl_gilt"],
	 "say": "The inside of the bowl is gilded. The gilding is thin in a crescent under one side of the lip."},
	{"zone": &"z.stem.knop", "tool": &"tool.eye", "facts": [&"f.knop_form"],
	 "say": "The stem swells into a knop the size of a walnut, cast in two shells and soldered round the girdle."},

	{"zone": &"z.foot.underside", "tool": &"tool.loupe", "dwell": 0.5,
	 "facts": [&"f.mark_maker", &"f.mark_diana"],
	 "say": "A maker's shield. Beside it a woman's head in profile — a numeral 3 before the chin, a letter A inside the same outline. The silver to the right is scored smooth."},
	# ЦЕ ПРАВИЛО БУЛО В ГРІ Й В АРТІ, АЛЕ НЕ В ДАНИХ. Якби дані підключили як є,
	# гра втратила б церковне клеймо — головну знахідку другого шару справи.
	# needs_flag: косе світло. Саме воно проявляє зішліфовану ділянку.
	{"zone": &"z.foot.underside", "tool": &"tool.loupe", "dwell": 0.5,
	 "needs_flag": {&"raking": true}, "requires": [&"f.mark_maker"],
	 "facts": [&"f.church_mark"],
	 "say": "Where the silver was ground smooth, the raking light finds it: an engraved chalice — a church's mark."},
	{"zone": &"z.foot.underside", "tool": &"tool.loupe", "dwell": 1.2,
	 "requires": [&"f.hb_vienna_marks"], "facts": [&"f.marks_alone"],
	 "say": "The rest of the underside is bare. No third punch, no figures, and no bright patch where one had been taken off."},

	{"zone": &"z.foot.top", "tool": &"tool.hand", "requires": [&"f.mark_diana"],
	 "facts": [&"f.domes"], "sets_state": {&"z.foot.top": &"raised"},
	 "say": "A finger run across the slope of the foot catches on two small domes in the metal — one behind each punch."},
	{"zone": &"z.foot.top", "tool": &"tool.loupe", "requires": [&"f.domes"],
	 "facts": [&"f.domes_alike"],
	 "say": "Both domes rise to the same height and break at the same sharp shoulder."},

	{"zone": &"z.foot.edge", "tool": &"tool.rake", "dwell": 0.8, "facts": [&"f.foot_edge_plain"],
	 "say": "The band round the edge of the foot is plain. Under raking light there is no lettering, and no shadow where lettering was taken off."},

	{"zone": &"z.papers.receipt", "tool": &"*", "facts": [&"f.receipt_1807"],
	 "unlocks": [&"tool.caliper", &"tool.scales"],
	 "say": "Receipt, Vienna, 12 March 1807, duty paid on re-marking: one becher, silver, 13 löthig, weight 14 loth, height 8 zoll 4 linien — for Anna Reithofer."},
	{"zone": &"z.papers.receipt", "tool": &"tool.caliper",
	 "requires": [&"f.receipt_1807", &"f.height_196", &"f.weight_331"],
	 "facts": [&"f.receipt_mismatch"],
	 "say": "By the table on the wall: the becher of the receipt stands 219 mm and weighs 246 g. The cup on the desk stands 196 mm and weighs 331 g."},

	# --- лист і газета (з гри; єдина копія say — ТУТ, main.gd більше їх не тримає) ---
	{"zone": &"z.papers.letter", "tool": &"*", "facts": [&"f.letter_read"],
	 "say": "She writes: from an aunt in the monastery, and she is told it is Viennese."},
	{"zone": &"z.news.robbery", "tool": &"*", "facts": [&"f.news_robbery"],
	 "say": "St. Onuphrius' sacristy, broken into. Among the missing: antique silver goblets."},
	{"zone": &"z.news.later", "tool": &"*", "facts": [],
	 "say": "The bell-rope of the sacristy had lately been renewed, and the old watchman dismissed a week before."},
	{"zone": &"z.news.society", "tool": &"*", "facts": [],
	 "say": "The Antiquarian Society meets Thursday: a paper on the perils of the re-struck punch."},
	{"zone": &"z.news.assayer", "tool": &"*", "facts": [],
	 "say": "A letter: 'a mark half-struck is not a mark honestly worn.' — An Old Assayer"},
	{"zone": &"z.news.market", "tool": &"*", "facts": [],
	 "say": "Market: old silver plate high; church work in brisk demand, and few questions asked."},

	{"zone": &"z.book.register", "tool": &"*", "requires": [&"f.mark_maker"],
	 "facts": [&"f.reg_hoffmann"],
	 "say": "Register of Vienna workshops: HOFFMANN, Leopold — silversmith. Mark entered 1859. Mark struck out 1871."},
	{"zone": &"z.book.marks", "tool": &"*", "requires": [&"f.mark_diana"],
	 "facts": [&"f.hb_vienna_marks"],
	 "say": "Handbook, Vienna assay office. From 1867: Diana's head with a numeral (1 = 950, 2 = 900, 3 = 800, 4 = 750) and no year. From 1872 the office letter is cut inside the head's outline; before 1872 it stood as a separate punch beside it."},
]

# ── МАПА СТАРИХ id → КАНОН (для кроку 5, підключення core/rules.gd) ──────────
# Словники фактів у main.gd і тут РІЗНІ, і мапа НЕ 1:1 (аудит 26.07, знахідка 14):
#   found_marks    ≈ f.mark_maker + f.mark_diana   (одна дія гравця видає ДВА факти)
#   found_church   = f.church_mark
#   matched_maker  = f.reg_hoffmann                (каталог = атрибуція майстра)
#   read_docs      → відповідника НЕМА: у грі на DOCS лист клієнтки, у специфікації
#                    там квитанція 1807 (f.receipt_1807) — це РІЗНІ папери, і лист
#                    у специфікацію ще не внесений
#   read_news      → відповідника НЕМА: газети в специфікації справи 1 не існує
# Підключати rules.gd МОЖНА тільки після рішення по цих двох останніх рядках.

# ── ФАКТИ ────────────────────────────────────────────────────────────────────
# `cite` — коротка форма для графи «на підставі». `weight` — вага в OUTCOMES.
const FACTS := {
	&"f.mark_maker":      {"cite": "the maker's shield on the foot", "tag": &"marks", "weight": 1,
		"text": "A punch struck into the underside of the foot: a shield, and within it a winged monogram set between two letters.",
		"crop": {"tex": &"foot_plate_maker", "region": Rect2(180, 435, 160, 170)}},
	&"f.mark_diana":      {"cite": "the letter set inside the head", "tag": &"marks", "weight": 2,
		"text": "Beside it, a woman's head in profile. A numeral 3 stands before the chin. The letter A stands inside the same outline.",
		"crop": {"tex": &"foot_plate_maker", "region": Rect2(208, 588, 168, 185)}},
	&"f.marks_alone":     {"cite": "no earlier assay punch on the piece", "tag": &"marks", "weight": 2,
		"text": "The rest of the underside is bare. No third punch, no figures, no bright patch where one had been taken off."},
	&"f.reg_hoffmann":    {"cite": "the register: Hoffmann, 1859 to 1871", "tag": &"books", "weight": 2,
		"text": "Register of Vienna workshops: HOFFMANN, Leopold — silversmith. Mark entered 1859. Mark struck out 1871."},
	&"f.hb_vienna_marks": {"cite": "the handbook of Vienna marks", "tag": &"books", "weight": 2,
		"text": "Handbook: from 1867, Diana's head with a numeral, no year. From 1872 the letter is cut INSIDE the outline.",
		"crop": {"tex": &"marks_page_vienna", "region": Rect2(150, 1330, 720, 780)}},
	&"f.domes":           {"cite": "two domes on the top of the foot", "tag": &"body", "weight": 2,
		"text": "Two small domes stand up on the slope of the foot, one behind each punch."},
	&"f.domes_alike":     {"cite": "both domes alike, to the shoulder", "tag": &"body", "weight": 3,
		"text": "Both domes rise to the same height and break at the same sharp shoulder."},
	&"f.foot_edge_plain": {"cite": "the foot band bears no lettering", "tag": &"body", "weight": 1,
		"text": "The band round the edge of the foot is plain. Under raking light there is no lettering, and no shadow where lettering was taken off."},
	&"f.bowl_gilt":       {"cite": "the bowl is gilt inside", "tag": &"body", "weight": 1,
		"text": "The inside of the bowl is gilded. The gilding is thin in a crescent under one side of the lip."},
	&"f.knop_form":       {"cite": "a knop on the stem", "tag": &"body", "weight": 1,
		"text": "The stem swells into a knop the size of a walnut, cast in two shells and soldered round the girdle."},
	&"f.height_196":      {"cite": "196 mm on the caliper", "tag": &"measure", "weight": 1,
		"text": "Height, lip to table: 196 mm. Foot: 104 mm across."},
	&"f.weight_331":      {"cite": "331 g on the balance", "tag": &"measure", "weight": 1,
		"text": "On the balance: 331 g."},
	&"f.receipt_1807":    {"cite": "the re-marking receipt of 1807", "tag": &"papers", "weight": 1,
		"text": "Receipt, Vienna, 12 March 1807, duty paid on re-marking: one becher, silver, 13 löthig, 14 loth, 8 zoll 4 linien — for Anna Reithofer."},
	&"f.receipt_mismatch":{"cite": "the receipt is 219 mm, the cup is 196", "tag": &"papers", "weight": 2,
		"text": "By the table on the wall: the becher of the receipt stands 219 mm and weighs 246 g. The cup on the desk stands 196 mm and weighs 331 g."},
	&"f.letter_read":     {"cite": "the client's own letter", "tag": &"papers", "weight": 1,
		"text": "She writes: from an aunt in the monastery, and she is told it is Viennese."},
	&"f.news_robbery":    {"cite": "the Herald of 14 March on the sacristy", "tag": &"papers", "weight": 1,
		"text": "St. Onuphrius' sacristy, broken into. Among the missing: antique silver goblets."},
	&"f.church_mark":     {"cite": "the effaced church mark beneath", "tag": &"marks", "weight": 3,
		"text": "Where the silver was ground smooth, the raking light finds it: an engraved chalice — a church's mark.",
		"crop": {"tex": &"foot_plate_church", "region": Rect2(620, 420, 190, 220)}},
}


# ── АТЕСТАТ: 6 граф (case_01.md §6). CHOICE тримає id; NUMBER без валідації
# відповіді (межі — формат поля, не підказка); FACTS — вибір 2..4 зібраних фактів.
# Істину рушій НЕ знає — її знають лише OUTCOMES.
# питання клієнтки — стоїть зверху атестата; атестат = ВІДПОВІДЬ на нього
const QUESTION := "Is it real \u2014 and what will it fetch?"

const SLOTS := [
	{"id": &"s.origin", "pre": "Wrought at", "kind": &"CHOICE",
	 "needs": [&"f.mark_maker", &"f.reg_hoffmann"],
	 "opts": [
		[&"o.vienna_hoffmann", "Vienna — the workshop of L. Hoffmann"],
		[&"o.vienna_unrecorded", "Vienna — a hand not in the register"],
		[&"o.outside_empire", "outside the Empire"],
	]},
	{"id": &"s.fineness", "pre": "Fineness claimed by the mark:", "suf": "in 1000",
	 "kind": &"NUMBER", "digits": 3, "min": 100, "max": 999,
	 "needs": [&"f.mark_diana", &"f.hb_vienna_marks"]},
	{"id": &"s.not_before", "pre": "The marks were struck not earlier than", "suf": "",
	 "kind": &"NUMBER", "digits": 4, "min": 1700, "max": 1900,
	 "needs": [&"f.mark_diana", &"f.hb_vienna_marks"]},
	{"id": &"s.marks", "pre": "The marks were struck", "kind": &"CHOICE",
	 "needs_any": [&"f.domes"],
	 "opts": [
		[&"o.on_the_flat", "on the flat metal, before the vessel was raised"],
		[&"o.by_office_later", "on the finished vessel, at the assay office"],
		[&"o.after_the_fact", "later, by a hand not the office's"],
	]},
	{"id": &"s.provenance", "pre": "The piece reached the bearer", "kind": &"CHOICE",
	 "needs_slot": [&"s.marks"],
	 "opts": [
		[&"o.honest_inheritance", "by inheritance, as she states"],
		[&"o.legally_remarked", "as old plate, lawfully re-marked at a later sale"],
		[&"o.taken_from_church", "out of a church, and worked upon after it left"],
		[&"o.made_to_look_stolen", "as new work, carrying the marks of church plate"],
	]},
	{"id": &"s.basis", "pre": "On the strength of:", "kind": &"FACTS",
	 "min_count": 2, "max_count": 4,
	 "needs_slot": [&"s.provenance"], "clears_on": [&"s.provenance"]},
]

# ── НАСЛІДКИ РАНКУ (case_01.md §7): перший збіг виграє, default — останній. ──
const OUTCOMES := [
	{"id": &"out.forgery_named",
	 "when": {&"s.marks": &"o.after_the_fact", &"s.not_before": 1872,
			  &"s.provenance": &"o.made_to_look_stolen"},
	 "basis_any": [&"f.domes_alike", &"f.marks_alone"], "basis_weight": 5,
	 "text": "A dealer in the Judengasse writes. On Tuesday a man offered him the cup at a third of its silver and told him it had come out of a church at Pressburg. He read your certificate and did not buy. He asks — politely, and then again — who else you have written for. Frau Reithofer's eight gulden were found by the parish. The grave is marked."},
	{"id": &"out.forgery_loose",
	 "when": {&"s.provenance": &"o.made_to_look_stolen"},
	 "text": "The dealer did not buy, and did not answer your letter. A clerk at the assay office in Vienna returned your certificate by the second post. There is one pencil line in the margin, drawn against a single figure, and no signature under it."},
	{"id": &"out.church_named",
	 "when": {&"s.provenance": &"o.taken_from_church"},
	 "basis_forbids": [&"f.domes_alike"],
	 "text": "Two constables at eight. They took the cup, the certificate, and Frau Reithofer, who had come back to ask whether there was more to pay. No church in the city reports a cup missing. The file stays open until one does. Her father went into the common ground on Saturday."},
	{"id": &"out.sold_clean",
	 "when": {&"s.provenance": &"o.honest_inheritance"},
	 "text": "The cup sold on Thursday, ninety gulden, to a house on the Graben. They copied your certificate into their book and spelled your name correctly. Frau Reithofer paid the burial ground and sent up a note of one line. On Friday the same house wrote to ask whether you would look at four more pieces from the same seller."},
	{"id": &"out.sold_clean",
	 "when": {&"s.provenance": &"o.legally_remarked"},
	 "text": "The cup sold on Thursday, ninety gulden, to a house on the Graben. They copied your certificate into their book and spelled your name correctly. Frau Reithofer paid the burial ground and sent up a note of one line. On Friday the same house wrote to ask whether you would look at four more pieces from the same seller."},
	{"id": &"out.default", "when": {},
	 "text": "Nothing came in the morning post. The cup went out at eight in the same shawl, and she said nothing at all about it. The ledger line for the day reads: sealed, one."},
]
