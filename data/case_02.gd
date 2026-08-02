# data/case_02.gd — СПРАВА 2 «СЕКРЕТЕР» за специфікацією _src/cases/case_02.md.
#
# 27.07: годинник-чернетку («клікання слайд-шоу» — Віктор) ЗАМІНЕНО справжньою
# справою 2. Ядро: схованка не знаходиться — вона ОБЧИСЛЮЄТЬСЯ (486.0 − 12.0 −
# 455.0 = 19 мм), а тоді відкривається викруткою. Річ справжня; підроблена тиша.
#
# 3D-вузли: sec_body (корпус), sec_drawer (шухляда), sec_backboard (дощечка) —
# Meshy, високодеталізовані. Зони 3D — локальні координати відповідного вузла.
extends RefCounted

# Інструменти справи 2 доступні З ПОЧАТКУ (специфікація: викрутка — нове в поясі,
# решта успадкована зі справи 1). Ряд на екранах FURN/WELL/DRAWER.
# лише ФІЗИЧНІ предмети: рука й око — це сам гравець, їх не «беруть»
const START_TOOLS := [&"tool.loupe", &"tool.rake", &"tool.screwdriver"]

const ZONES := {
	# --- скринька на столі: екран C2PIECE (зони міряні по плиті) ---
	&"z.sec.escutcheon": {
		"kind": &"img", "screen": &"C2PIECE", "surface": &"box_closed",
		"u": Vector2(0.555, 0.715), "shape": &"circle", "r": 0.055,
		"hint": "The keyhole escutcheon",
		"tools": [&"tool.loupe", &"tool.eye"],
	},
	&"z.sec.fallfront": {
		"kind": &"img", "screen": &"C2PIECE", "surface": &"box_closed",
		"u": Vector2(0.545, 0.545), "shape": &"rect", "half": Vector2(0.30, 0.245),
		"hint": "The box — open it",
		"tools": [&"tool.hand", &"tool.eye"],
	},
	&"z.sec.drawer_front": {
		"kind": &"img", "screen": &"C2PIECE", "surface": &"box_closed",
		"u": Vector2(0.50, 0.755), "shape": &"rect", "half": Vector2(0.21, 0.035),
		"hint": "The underside of the box",
		"tools": [&"tool.hand", &"tool.eye"],
	},
	# --- предмет можна ДОСЛІДЖУВАТИ: кожна точка відповідає кожному інструменту
	# по-своєму (Віктор, 31.07: «в нас тільки одна халепа увесь час»). Виміряно:
	# до цього жила 20 % пар зона×інструмент — гравець тицяв туди, куди велить
	# драбина, тим, чим вона велить. Арт не додано: усе це вже на кадрі.
	&"z.box.slope": {
		"kind": &"img", "screen": &"C2OPEN", "surface": &"box_open",
		"u": Vector2(0.50, 0.52), "shape": &"rect", "half": Vector2(0.15, 0.09),
		"hint": "The writing slope",
		"tools": [&"tool.eye", &"tool.loupe", &"tool.rake"],
	},
	&"z.box.inkwells": {
		"kind": &"img", "screen": &"C2OPEN", "surface": &"box_open",
		"u": Vector2(0.53, 0.685), "shape": &"rect", "half": Vector2(0.19, 0.055),
		"hint": "The inkwells and the pen trough",
		"tools": [&"tool.eye", &"tool.loupe", &"tool.rake"],
	},
	&"z.box.hinges": {
		"kind": &"img", "screen": &"C2OPEN", "surface": &"box_open",
		"u": Vector2(0.565, 0.415), "shape": &"rect", "half": Vector2(0.055, 0.035),
		"hint": "The hinges of the lid",
		"tools": [&"tool.eye", &"tool.loupe", &"tool.rake"],
	},
	&"z.box.corners": {
		"kind": &"img", "screen": &"C2PIECE", "surface": &"box_closed",
		"u": Vector2(0.78, 0.44), "shape": &"rect", "half": Vector2(0.075, 0.075),
		"hint": "The brass corner mounts",
		"tools": [&"tool.eye", &"tool.loupe", &"tool.rake"],
	},
	# --- скринька відкрита: екран C2OPEN ---
	# клік будь-де по відкритій скриньці — закрити. Найбільша зона екрана, тож
	# дошка, ніша й ярличок виграють у pick_2d як менші.
	&"z.sec.lid_close": {
		"kind": &"img", "screen": &"C2OPEN", "surface": &"box_open",
		"u": Vector2(0.53, 0.50), "shape": &"rect", "half": Vector2(0.32, 0.45),
		"hint": "Close the box",
		"tools": [&"tool.hand", &"tool.eye"],
	},
	&"z.well.back_board": {
		"kind": &"img", "screen": &"C2OPEN", "surface": &"box_open",
		"u": Vector2(0.40, 0.26), "shape": &"rect", "half": Vector2(0.16, 0.15),
		"hint": "The board in the lid — held by four screws",
		"tools": [&"tool.eye", &"tool.loupe", &"tool.screwdriver"],
	},
	# --- дошку знято: входи в деталі з того самого середнього плану ---
	&"z.macro.screws": {
		"kind": &"img", "screen": &"M2SCREWS", "surface": &"m2_screws",
		"u": Vector2(0.45, 0.45), "shape": &"rect", "half": Vector2(0.40, 0.38),
		"hint": "The two heads, side by side",
		"tools": [&"tool.eye", &"tool.loupe"],
	},
	&"z.void.mouth": {
		"kind": &"img", "screen": &"C2OPEN", "surface": &"box_noboard",
		"u": Vector2(0.41, 0.27), "shape": &"rect", "half": Vector2(0.16, 0.13),
		"hint": "The cavity behind the board",
		"tools": [&"tool.hand", &"tool.eye"],
		"requires_state": {&"z.well.back_board": &"open"},
	},
	&"z.screws.loose": {
		"kind": &"img", "screen": &"C2OPEN", "surface": &"box_noboard",
		"u": Vector2(0.51, 0.824), "shape": &"rect", "half": Vector2(0.09, 0.045),
		"hint": "The four screws, out on the pad",
		"tools": [&"tool.hand", &"tool.eye"],
		"requires_state": {&"z.well.back_board": &"open"},
	},
	&"z.void.lining": {
		"kind": &"img", "screen": &"C2RECESS", "surface": &"c2_recess",
		"u": Vector2(0.885, 0.40), "shape": &"rect", "half": Vector2(0.085, 0.34),
		"hint": "Where the lining meets the wood of the box",
		"tools": [&"tool.loupe"],
		"requires_state": {&"z.well.back_board": &"open"},
	},
	&"z.void.floor": {
		"kind": &"img", "screen": &"C2RECESS", "surface": &"c2_recess",
		"u": Vector2(0.42, 0.45), "shape": &"rect", "half": Vector2(0.33, 0.36),
		"hint": "The floor of the recess",
		"tools": [&"tool.rake", &"tool.loupe"],
		"requires_state": {&"z.well.back_board": &"open"},
	},
	# --- вийнята шухляда в руках: екран DRAWER ---
	&"z.drawer.underside": {
		"kind": &"img", "screen": &"C2STAMP", "surface": &"box_under",
		"u": Vector2(0.425, 0.636), "shape": &"rect", "half": Vector2(0.11, 0.075),
		"hint": "The underside of the box",
		"tools": [&"tool.eye", &"tool.rake", &"tool.loupe"],
	},
	# --- папери: єдиний ловець 2D ---
	&"z.doc.daybook_intake": {
		"kind": &"img", "screen": &"C2DOCS", "surface": &"letter_client",
		"u": Vector2(0.50, 0.30), "shape": &"rect", "half": Vector2(0.34, 0.14),
		"hint": "The day-book: intake of the 3rd",
	},
	&"z.doc.register_gruber": {
		"kind": &"img", "screen": &"C2DOCS", "surface": &"letter_client",
		"u": Vector2(0.50, 0.62), "shape": &"rect", "half": Vector2(0.34, 0.14),
		"hint": "The register of workshops",
	},
	&"z.doc.ref_screws": {
		"kind": &"img", "screen": &"BOOK_SCREWS", "surface": &"plain_book_page",
		"u": Vector2(0.50, 0.45), "shape": &"rect", "half": Vector2(0.36, 0.30),
		"hint": "The chapter on screws",
	},
	&"z.doc.label_pigeonhole": {
		"kind": &"img", "screen": &"C2OPEN", "surface": &"box_open",
		"u": Vector2(0.60, 0.66), "shape": &"circle", "r": 0.05,
		"hint": "A paper label in the pen compartment",
		"tools": [&"tool.loupe", &"tool.eye"],
	},
}

const RULES := [
	{"zone": &"z.sec.fallfront", "tool": &"tool.hand", "sets_flag": {&"ff_toggle": true},
	 "say": "The lid comes up on its hinges; the box stands open."},
	{"zone": &"z.sec.drawer_front", "tool": &"tool.hand",
	 "sets_state": {&"z.sec.drawer_front": &"out"},
	 "say": "The box lifts and turns over in both hands."},
	{"zone": &"z.sec.escutcheon", "tool": &"tool.loupe",
	 "facts": [&"f.escutcheon_bright"], "screen": &"M2LOCK",
	 "say": "Four scratches run from the keyhole to the lower left. Their metal is bright; the metal around them is brown."},

	{"zone": &"z.doc.daybook_intake", "tool": &"*", "facts": [&"f.daybook_locksmith"],
	 "say": "Intake, the 3rd: 'Writing box, walnut, from the estate of Herr F. Opened on arrival by Krenn, our locksmith — lock seized. House keys surrendered with the piece.'"},

	{"zone": &"z.drawer.underside", "tool": &"tool.eye",
	 "facts": [&"f.stamp_gruber"],
	 "say": "Burnt into the box bottom, low and to the left: M. GRUBER · WIEN. Beside it, in chalk, a number: 367."},
	{"zone": &"z.drawer.underside", "tool": &"tool.rake",
	 "facts": [&"f.stamp_gruber"],
	 "say": "Burnt into the box bottom, low and to the left: M. GRUBER · WIEN. Beside it, in chalk, a number: 367."},
	{"zone": &"z.doc.register_gruber", "tool": &"*", "requires": [&"f.stamp_gruber"],
	 "req_say": "A hundred workshops, column after column. Nothing yet to look for in them.",
	 "facts": [&"f.reg_gruber_1822_1841"],
	 "say": "GRUBER, Michael. Möbeltischler, Wien, Gumpendorf. Workshop stamp in use 1822–1841. Numbered his work in chalk."},

	{"zone": &"z.well.back_board", "tool": &"tool.eye",
	 "facts": [&"f.board_screwed"],
	 "say": "This board is held by four screws. Everywhere else the box is pinned with wooden dowels and square nails."},
	{"zone": &"z.well.back_board", "tool": &"tool.loupe", "requires": [&"f.board_screwed"],
	 "req_say": "Look it over plainly first — how is this board held to the lid?",
	 "facts": [&"f.screw_points"], "screen": &"M2SCREWS",
	 "say": "The screws run to a sharp point. The thread is even from head to tip. Every slot passes through the centre of the head."},
	{"zone": &"z.macro.screws", "tool": &"tool.eye",
	 "say": "Two heads side by side: one turned and bright at the slot, the other dark, proud and sealed in its wax."},
	{"zone": &"z.macro.screws", "tool": &"tool.loupe", "requires": [&"f.screw_points"],
	 "facts": [&"f.slot_burr"],
	 "say": "Three of the four are like the left one: slots bright and torn, the wax cracked in a ring. Only the fourth stands proud, its wax whole."},
	{"zone": &"z.doc.ref_screws", "tool": &"*", "requires": [&"f.screw_points"],
	 "req_say": "Pages of screws, old and new. Without a screw in mind they are only pages.",
	 "facts": [&"f.ref_screw_points"],
	 "say": "Hand-made screws: blunt end, filed thread of uneven pitch, slot off centre. Pointed screws that cut their own way: patented 1846, made in quantity in Birmingham from 1854."},

	# --- дослідження предмета: одна точка, різні інструменти, різні відповіді ---
	{"zone": &"z.box.slope", "tool": &"tool.eye",
	 "say": "Green baize, worn pale in a patch the size of a forearm — right of centre. He wrote right-handed, and he wrote a great deal."},
	{"zone": &"z.box.slope", "tool": &"tool.loupe",
	 "say": "Ink specks, old and brown, scattered where a nib is shaken out. One long scratch where the pen was dragged, not lifted."},
	{"zone": &"z.box.slope", "tool": &"tool.rake",
	 "facts": [&"f.slope_impress"], "screen": &"M2BAIZE",
	 "say": "Under low light the baize holds impressions pressed through from above: figures in columns, and one line of them ends in a total that was underlined twice."},

	{"zone": &"z.box.inkwells", "tool": &"tool.eye",
	 "say": "Two glass wells with brass collars, and a trough between them worn smooth at the right-hand end."},
	{"zone": &"z.box.inkwells", "tool": &"tool.loupe", "screen": &"M2WELLS",
	 "say": "The right-hand well is crusted black to a third of its depth. The left is clean glass — filled once, if ever. A man with two wells who used one."},
	{"zone": &"z.box.inkwells", "tool": &"tool.rake",
	 "say": "Low light in the trough: two grooves, not one. A pen and something narrower, kept side by side for years."},

	{"zone": &"z.box.hinges", "tool": &"tool.eye",
	 "say": "Two brass butt hinges, let flush into the walnut, holding the lid."},
	{"zone": &"z.box.hinges", "tool": &"tool.loupe",
	 "facts": [&"f.hinge_original"],
	 "say": "The hinge screws are blunt-ended, their slots cut off centre, their pitch uneven — hand-filed work, and they have never been turned. The hinges are as old as the box."},
	{"zone": &"z.box.hinges", "tool": &"tool.rake",
	 "say": "Raking light shows the seating: the timber under each hinge is the same colour as the timber around it. Nothing was ever moved here."},

	{"zone": &"z.box.corners", "tool": &"tool.eye",
	 "say": "Brass mounts at the corners, the campaign fashion — meant to take the knocks of travel."},
	{"zone": &"z.box.corners", "tool": &"tool.loupe",
	 "say": "Three are rubbed to a dull gold at the edge. The fourth keeps its lacquer in the corners, where a rubbed one would have none."},
	{"zone": &"z.box.corners", "tool": &"tool.rake",
	 "say": "Under low light the wood beneath the mounts is unfaded — the box stood out of the sun, or stood shut."},

	# --- ті самі точки, інші інструменти: тепер відповідають усі ---
	{"zone": &"z.sec.escutcheon", "tool": &"tool.eye",
	 "say": "A brass escutcheon, and a keyhole worn to an oval by a key that was turned twice a day for a lifetime."},
	{"zone": &"z.sec.escutcheon", "tool": &"tool.rake",
	 "say": "Low light across the plate: the scratches all run the same way, from the keyhole down to the left. One hand, one habit, one angle."},

	{"zone": &"z.void.lining", "tool": &"tool.eye",
	 "say": "The recess is lined with a paler wood than the box, cut in and fitted — not the walnut of the carcass."},
	{"zone": &"z.void.lining", "tool": &"tool.rake",
	 "say": "Raking light along the lining: the joint between it and the walnut is tight, and the glue line is dark with age."},

	{"zone": &"z.void.floor", "tool": &"tool.eye",
	 "say": "The floor of the recess, grey with the dust of years."},
	{"zone": &"z.void.floor", "tool": &"tool.loupe",
	 "say": "The dust is fine and even — house dust, settled, not swept. Nobody cleaned in here; something simply lay on it."},

	{"zone": &"z.drawer.underside", "tool": &"tool.loupe",
	 "say": "The chalk beside the brand is the joiner\'s own numbering, in a hand that wrote the same figure a hundred times that year."},

	{"zone": &"z.well.back_board", "tool": &"tool.rake",
	 "say": "Low light across the board: the four screw heads sit at four slightly different depths. Whoever set them last was in a hurry."},
	# руйнівна дія — з підтвердженням (відмова не карається)
	{"zone": &"z.well.back_board", "tool": &"tool.screwdriver", "requires": [&"f.board_screwed"],
	 "req_say": "Unscrew what? See first how the board is held.",
	 "confirm": "Take a screwdriver to a client\'s furniture?  Click once more to do it.",
	 "screws": true,
	 "facts": [&"f.board_lifted"], "sets_state": {&"z.well.back_board": &"open"},
	 "say": "The last screw comes out. Behind the board there is a recess, lined, and no dust on its front lip."},

	{"zone": &"z.void.lining", "tool": &"tool.loupe",
	 "facts": [&"f.lining_fleck"],
	 "say": "End grain of the lining: close, pale, crossed by fine bright flecks. End grain of the walnut beside it: coarse, resinous, no flecks."},
	{"zone": &"z.void.floor", "tool": &"tool.rake",
	 "facts": [&"f.dust_rectangle"],
	 "say": "Under a low light the floor is grey with settled dust, except one rectangle clean to the wood. Its edges are sharp, and it is the size of a folded packet of papers."},
	{"zone": &"z.doc.label_pigeonhole", "tool": &"tool.loupe",
	 "facts": [&"f.trade_label"],
	 "say": "A paper label, lifted at one corner: 'J. HALBERT — Möbel & Antiquitäten, Wien I. Repaired and fitted, 1867.'"},
]

# ── ДОПИТ КЛІЄНТКИ (01.08) ────────────────────────────────────────────────────
# Головне дієслово справи. Дані дослідження 31.07: «клієнт біля прилавка» хвалять
# у 9.2 % позитивних відгуків Strange Antiquities і в 0.0–0.2 % чистих дедуктивок —
# це рів бенчмарку, і в нас він лежав невикористаний. Друге: «історія/письмо/
# персонажі» — найбільша окрема категорія похвали (25.8–33.0 %).
#
# Кожна репліка або ЗВУЖУЄ (називає недосліджену частину речі), або СУПЕРЕЧИТЬ
# (ламається об уже здобутий факт і породжує факт-суперечність, який можна вписати
# в атестат як підставу). Просто емоційних реплік тут нема — це була б декорація.
#
#   ask     — питання, як його ставить гравець
#   say     — що вона відповідає
#   opens   — підказка-звуження: яку зону варто глянути (порожньо = нічого)
#   breaks  — факт, об який ця відповідь ламається
#   gives   — факт-суперечність, що народжується, коли breaks уже здобуто
#   needs   — питання з'являється лише коли цей факт уже є (порожньо = одразу)
const ASK := [
	{"id": &"q.provenance",
	 "ask": "How did it come to you?",
	 "say": "«He willed it to me. Twenty-two years I kept that house, and the box stood on his desk every one of them.»",
	 "opens": "The box bottom, then — a joiner burns his name where nobody looks.",
	 "needs": []},

	{"id": &"q.opened",
	 "ask": "Has anyone opened it since he died?",
	 "say": "«No one. It came here as it stood on his desk. I have not had the key off my own neck.»",
	 "breaks": &"f.slot_burr", "gives": &"f.contra.opened",
	 "opens": "The screws in the lid, then. Wax cracks when a head is turned.",
	 "needs": []},

	{"id": &"q.locked",
	 "ask": "When did you lock the box?",
	 "say": "«The day I decided to sell it. Until then it stood open on his desk — it always stood open.»",
	 "gives": &"f.window_mourning",
	 "opens": "Then whoever emptied the recess needed no key. The house was open, and so was the box.",
	 "needs": [&"f.dust_rectangle"]},
]

const FACTS := {
	&"f.escutcheon_bright":    {"cite": "bright scratches at the lock", "tag": &"lock", "weight": 1,
		"text": "Four scratches by the keyhole; their metal is bright, the metal around them brown."},
	&"f.daybook_locksmith":    {"cite": "our own locksmith opened it on the 3rd", "tag": &"papers", "weight": 2,
		"text": "Day-book, the 3rd: opened on arrival by Krenn, the bureau\'s locksmith. House keys surrendered with the piece."},
	&"f.stamp_gruber":         {"cite": "the workshop stamp on the underside", "tag": &"body", "weight": 2,
		"text": "Burnt into the box bottom: M. GRUBER · WIEN. Chalk number 367 beside it."},
	&"f.reg_gruber_1822_1841": {"cite": "the register dates the stamp to 1822–1841", "tag": &"books", "weight": 2,
		"text": "Register: Gruber, Michael, Möbeltischler, Wien-Gumpendorf. Stamp in use 1822–1841."},
	&"f.board_screwed":        {"cite": "screws where the rest of the box is dowelled", "tag": &"body", "weight": 2,
		"text": "Four screws hold the board in the lid. The rest of the box is dowelled and square-nailed."},
	&"f.screw_points":         {"cite": "pointed screws with even thread", "tag": &"body", "weight": 3,
		"text": "The screws end in a point; the thread is even head to tip; the slots run through the centre."},
	&"f.ref_screw_points":     {"cite": "the screw book puts that screw after 1854", "tag": &"books", "weight": 3,
		"text": "Reference: blunt, hand-filed screws before 1846; pointed self-starting screws patented 1846, in quantity from 1854."},
	&"f.slot_burr":            {"cite": "three heads turned, the wax broken around them", "tag": &"body", "weight": 3,
		"text": "Three slots bright and torn at one edge; the wax around those heads cracked in a ring. The fourth head stands proud."},
	&"f.board_lifted":         {"cite": "the recess behind the board", "tag": &"body", "weight": 2,
		"text": "Behind the board there is a recess, lined, with no dust on its front lip."},
	&"f.lining_fleck":         {"cite": "the lining is not the wood of the box", "tag": &"body", "weight": 3,
		"text": "Lining end grain: close, pale, fine bright flecks. The walnut beside it: coarse, resinous, no flecks."},
	&"f.dust_rectangle":       {"cite": "a clean rectangle in the dust", "tag": &"body", "weight": 3,
		"text": "Dust on the floor of the recess everywhere but one rectangle, clean to the wood, sharp at the edges — the size of a folded packet of papers."},
	&"f.contra.opened":        {"cite": "she says it was never opened; three screws say otherwise", "tag": &"client", "weight": 3,
		"text": "She says no one opened it since he died. Three of the four heads have been turned, and the wax around them is cracked."},
	&"f.window_mourning":      {"cite": "the box stood open through the mourning", "tag": &"client", "weight": 3,
		"text": "The box stood open on his desk until she locked it to sell. The packet\'s print in the dust is fresh. It was taken in the days of mourning, in an open house full of guests."},
	&"f.slope_impress":        {"cite": "columns of figures pressed into the baize", "tag": &"body", "weight": 2,
		"text": "Impressions pressed through into the writing baize: columns of figures, one total underlined twice. He kept accounts on this box."},
	&"f.hinge_original":       {"cite": "the hinge screws are blunt and never turned", "tag": &"body", "weight": 3,
		"text": "Hinge screws: blunt ends, off-centre slots, uneven pitch — hand-filed, and never turned since they were set. The hinges are original to the box."},
	&"f.trade_label":          {"cite": "the dealer\'s label of 1867", "tag": &"papers", "weight": 2,
		"text": "Paper label in the pen compartment: \'J. HALBERT — Möbel & Antiquitäten, Wien I. Repaired and fitted, 1867.\'"},
}

# ── АТЕСТАТ: 6 граф (case_02.md §6, канонічна таблиця) ───────────────────────
const SLOTS := [
	{"id": &"s.piece", "pre": "The piece is", "kind": &"CHOICE",
	 "hint": "( turn the box over, then look in the register )",
	 "needs": [&"f.stamp_gruber", &"f.reg_gruber_1822_1841"],
	 "opts": [
		[&"o.vienna_1820s", "a Viennese walnut writing box of the 1820s, by the stamped workshop"],
		[&"o.later_copy", "a later copy in the Viennese manner"],
		[&"o.marriage", "two pieces married into one"],
	]},
	{"id": &"s.void_origin", "pre": "The recess was cut", "kind": &"CHOICE",
	 "hint": "( whoever cut it left his screws and his timber )",
	 "needs": [&"f.board_screwed", &"f.screw_points", &"f.ref_screw_points", &"f.lining_fleck"],
	 "opts": [
		[&"o.with_carcass", "with the box, by the workshop that made it"],
		[&"o.trade_later", "later, in a dealer\'s workshop, as a selling feature"],
		[&"o.private_later", "later, by a hand working alone, in the house"],
	]},
	{"id": &"s.last_opened", "pre": "The recess was last opened", "kind": &"CHOICE",
	 "hint": "( dust keeps time better than people do )",
	 "needs": [&"f.dust_rectangle", &"f.slot_burr"],
	 "opts": [
		[&"o.never", "not since it was fitted"],
		[&"o.long_ago", "years ago"],
		[&"o.within_fortnight", "within the fortnight"],
	]},
	{"id": &"s.lock_marks", "pre": "The marks on the lock are", "kind": &"CHOICE",
	 "hint": "( the loupe on the keyhole plate )",
	 "needs": [&"f.escutcheon_bright"],
	 "opts": [
		[&"o.forced", "the work of someone who had no key"],
		[&"o.our_locksmith", "the work of this bureau, on the 3rd"],
		[&"o.old_wear", "the wear of forty years of use"],
	]},
	{"id": &"s.basis", "pre": "On the strength of:", "kind": &"FACTS",
	 "hint": "( name the rulings above, first )",
	 "min_count": 2, "max_count": 4,
	 "needs_slot": [&"s.void_origin", &"s.last_opened"],
	 "clears_on": [&"s.void_origin", &"s.last_opened"]},
]

# ── НАСЛІДКИ РАНКУ (case_02.md §7): перший збіг виграє ───────────────────────
const OUTCOMES := [
	{"id": &"out.void_named",
	 "when": {&"s.void_origin": &"o.private_later", &"s.last_opened": &"o.within_fortnight",
			  &"s.lock_marks": &"o.our_locksmith"},
	 "basis_any": [&"f.dust_rectangle", &"f.slot_burr", &"f.window_mourning", &"f.contra.opened"], "basis_weight": 5,
	 "text": "The certificate went to the notary before noon, and the notary sent for the constable. The sale is stayed; the house is asked, room by room, who was alone with the open box in the days of mourning. Frau Vogl came at one. She did not ask about the money. She asked to keep the paper."},
	{"id": &"out.locksmith_broken",
	 "when": {&"s.lock_marks": &"o.forced"},
	 "text": "A constable called at eight and took the piece to the station as evidence of a forced entry. Krenn the locksmith was sent for at nine and kept until two. He has worked for this bureau eleven years. The note says he did not argue. The bureau\'s contract with him is on the desk, unsigned for renewal. Frau Vogl\'s son sailed. She was not on the quay."},
	{"id": &"out.sold_short",
	 "when": {&"s.void_origin": &"o.with_carcass"},
	 "text": "Sold at your figure: sixty gulden, walnut, sound, no faults recorded. A fortnight later the Wollzeile catalogue lists it: \'Biedermeier writing box, Vienna, c. 1825, with a concealed recess behind the board in the lid — 260 gulden.\' Frau Vogl\'s rent was paid to the end of the month."},
	{"id": &"out.trade_fitting",
	 "when": {&"s.void_origin": &"o.trade_later"},
	 "basis_any": [&"f.trade_label"],
	 "text": "Halbert\'s shop answered the enquiry by return: they repaired the piece in 1867, a hinge and two feet, and they fit no compartments — \'we sell furniture, not conjuring.\' The letter is filed. The question it answers is not the one the certificate settled."},
	{"id": &"out.default", "when": {},
	 "text": "The piece sold, the money was paid out, and the ledger line closed. A month on, the nephew entered the estate unopposed; nothing in writing stood against him. Nothing came back."},
]
