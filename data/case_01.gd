# data/case_01.gd — СПРАВА 1 «СРІБНИЙ КЕЛИХ» як ДАНІ, не як код.
#
# Джерело істини: _src/cases/case_01.md. Розбіжність між цим файлом і специфікацією —
# помилка, і ловить її tools/validate_cases.py.
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
	&"z.foot.underside": {
		"kind": &"mesh", "screen": &"HANDS", "node": &"goblet_pivot",
		"at": Vector3(0, -0.96, 0.28), "facing": Vector3(0, -1, 0),
		"r": 0.22, "facing_min": 0.12,
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
	 "say": "Two punches, side by side. A rectangle with clipped corners: L·HOFFMANN. Beside it a woman's head in profile — a numeral 3 before the chin, and the letter A inside the same outline."},
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
	&"f.mark_maker":      {"cite": "the maker's punch on the foot", "tag": &"marks", "weight": 1},
	&"f.mark_diana":      {"cite": "the letter set inside the head", "tag": &"marks", "weight": 2},
	&"f.marks_alone":     {"cite": "no earlier assay punch on the piece", "tag": &"marks", "weight": 2},
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
