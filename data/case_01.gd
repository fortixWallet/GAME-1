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
		"u": Vector2(0.508, 0.470), "shape": &"rect", "half": Vector2(0.088, 0.262),
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
		"r": 0.20, "facing_min": 0.10,
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
	&"z.papers.receipt": {
		"kind": &"img", "screen": &"DOCS", "surface": &"paper_receipt_1807",
		"u": Vector2(0.500, 0.430), "r": 0.190, "tools": [], "on_click": true,
	},
	&"z.book.register": {
		"kind": &"img", "screen": &"BOOK_REG", "surface": &"reg_page_h",
		"u": Vector2(0.315, 0.560), "shape": &"rect", "half": Vector2(0.280, 0.045),
		"tools": [], "on_click": true,
	},
	&"z.book.marks": {
		"kind": &"img", "screen": &"BOOK_MARKS", "surface": &"marks_page_vienna",
		"u": Vector2(0.660, 0.480), "shape": &"rect", "half": Vector2(0.300, 0.230),
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

	{"zone": &"z.book.register", "tool": &"*", "requires": [&"f.mark_maker"],
	 "facts": [&"f.reg_hoffmann"],
	 "say": "Register of Vienna workshops: HOFFMANN, Leopold — silversmith. Mark entered 1859. Mark struck out 1871."},
	{"zone": &"z.book.marks", "tool": &"*", "requires": [&"f.mark_diana"],
	 "facts": [&"f.hb_vienna_marks"],
	 "say": "Handbook, Vienna assay office. From 1867: Diana's head with a numeral (1 = 950, 2 = 900, 3 = 800, 4 = 750) and no year. From 1872 the office letter is cut inside the head's outline; before 1872 it stood as a separate punch beside it."},
]

# ── ФАКТИ ────────────────────────────────────────────────────────────────────
# `cite` — коротка форма для графи «на підставі». `weight` — вага в OUTCOMES.
const FACTS := {
	&"f.mark_maker":      {"cite": "the maker's shield on the foot", "tag": &"marks", "weight": 1},
	&"f.mark_diana":      {"cite": "the letter set inside the head", "tag": &"marks", "weight": 2},
	&"f.marks_alone":     {"cite": "no earlier assay punch on the piece", "tag": &"marks", "weight": 2},
	&"f.church_mark":     {"cite": "the effaced church mark beneath", "tag": &"marks", "weight": 3},
	&"f.reg_hoffmann":    {"cite": "the register: Hoffmann, 1859 to 1871", "tag": &"books", "weight": 2},
	&"f.hb_vienna_marks": {"cite": "the handbook of Vienna marks", "tag": &"books", "weight": 2},
	&"f.domes":           {"cite": "two domes on the top of the foot", "tag": &"body", "weight": 2},
	&"f.domes_alike":     {"cite": "both domes alike, to the shoulder", "tag": &"body", "weight": 3},
	&"f.foot_edge_plain": {"cite": "the foot band bears no lettering", "tag": &"body", "weight": 1},
	&"f.bowl_gilt":       {"cite": "the bowl is gilt inside", "tag": &"body", "weight": 1},
	&"f.knop_form":       {"cite": "a knop on the stem", "tag": &"body", "weight": 1},
	&"f.height_196":      {"cite": "196 mm on the caliper", "tag": &"measure", "weight": 1},
	&"f.weight_331":      {"cite": "331 g on the balance", "tag": &"measure", "weight": 1},
	&"f.receipt_1807":    {"cite": "the re-marking receipt of 1807", "tag": &"papers", "weight": 1},
	&"f.receipt_mismatch":{"cite": "the receipt is 219 mm, the cup is 196", "tag": &"papers", "weight": 2},
}
