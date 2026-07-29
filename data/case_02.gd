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
	# --- корпус: екран FURN ---
	&"z.sec.escutcheon": {
		"kind": &"img", "screen": &"C2PIECE", "surface": &"box_closed",
		"u": Vector2(0.50, 0.62), "shape": &"circle", "r": 0.045,
		"hint": "The keyhole escutcheon",
		"tools": [&"tool.loupe", &"tool.eye"],
	},
	&"z.sec.doors": {
		"kind": &"img", "screen": &"C2PIECE", "surface": &"box_closed",
		"u": Vector2(0.50, 0.36), "shape": &"rect", "half": Vector2(0.20, 0.08),
		"hint": "The upper doors",
		"tools": [&"tool.hand", &"tool.eye"],
	},
	&"z.sec.fallfront": {
		"kind": &"img", "screen": &"C2PIECE", "surface": &"box_closed",
		"u": Vector2(0.50, 0.47), "shape": &"rect", "half": Vector2(0.22, 0.10),
		"hint": "The fall-front — it lets down into a writing surface",
		"tools": [&"tool.hand", &"tool.eye"],
	},
	&"z.sec.drawer_front": {
		"kind": &"img", "screen": &"C2PIECE", "surface": &"box_closed",
		"u": Vector2(0.50, 0.70), "shape": &"rect", "half": Vector2(0.22, 0.06),
		"hint": "The lid of the box",
		"tools": [&"tool.hand", &"tool.eye"],
	},
	# --- писальний відділ (дошка відкинута): екран WELL ---
	&"z.well.back_board": {
		"kind": &"img", "screen": &"C2OPEN", "surface": &"box_open",
		"u": Vector2(0.40, 0.26), "shape": &"rect", "half": Vector2(0.16, 0.15),
		"hint": "The board in the lid — held by four screws",
		"tools": [&"tool.eye", &"tool.loupe", &"tool.screwdriver"],
	},
	&"z.void.lining": {
		"kind": &"img", "screen": &"C2GRAIN", "surface": &"c2_endgrain",
		"u": Vector2(0.32, 0.5), "shape": &"rect", "half": Vector2(0.28, 0.36),
		"hint": "The lining of the recess",
		"tools": [&"tool.loupe"],
		"requires_state": {&"z.well.back_board": &"open"},
	},
	&"z.void.floor": {
		"kind": &"img", "screen": &"C2RECESS", "surface": &"c2_recess",
		"u": Vector2(0.5, 0.6), "shape": &"rect", "half": Vector2(0.35, 0.28),
		"hint": "The floor of the recess",
		"tools": [&"tool.rake", &"tool.loupe"],
		"requires_state": {&"z.well.back_board": &"open"},
	},
	# --- вийнята шухляда в руках: екран DRAWER ---
	&"z.drawer.underside": {
		"kind": &"img", "screen": &"C2STAMP", "surface": &"box_under",
		"u": Vector2(0.555, 0.50), "shape": &"rect", "half": Vector2(0.10, 0.06),
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
		"hint": "A paper label in the pigeonhole",
		"tools": [&"tool.loupe", &"tool.eye"],
	},
}

const RULES := [
	{"zone": &"z.sec.doors", "tool": &"tool.hand",
	 "say": "The upper doors stand open: shelves, and nothing on them but dust."},
	{"zone": &"z.sec.fallfront", "tool": &"tool.hand", "sets_flag": {&"ff_toggle": true},
	 "say": "The fall-front lets down on its hinges; the writing well stands open."},
	{"zone": &"z.sec.drawer_front", "tool": &"tool.hand",
	 "sets_state": {&"z.sec.drawer_front": &"out"}, "screen": &"DRAWER",
	 "say": "The drawer comes out whole and rides up into both hands."},
	{"zone": &"z.sec.escutcheon", "tool": &"tool.loupe",
	 "facts": [&"f.escutcheon_bright"],
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
	 "say": "GRUBER, Michael. Möbeltischler, Wien, Gumpendorf. Workshop stamp in use 1822–1841. Numbered his carcasses in chalk."},

	{"zone": &"z.well.back_board", "tool": &"tool.eye",
	 "facts": [&"f.board_screwed"],
	 "say": "This board is held by four screws. Everywhere else the carcass is pinned with wooden dowels and square nails."},
	{"zone": &"z.well.back_board", "tool": &"tool.loupe", "requires": [&"f.board_screwed"],
	 "req_say": "Look it over plainly first — how is this board held to the carcass?",
	 "facts": [&"f.screw_points"],
	 "say": "The screws run to a sharp point. The thread is even from head to tip. Every slot passes through the centre of the head."},
	{"zone": &"z.well.back_board", "tool": &"tool.loupe", "requires": [&"f.screw_points"],
	 "req_say": "The screws themselves first — what points, what thread?",
	 "facts": [&"f.slot_burr"],
	 "say": "Three slots are bright and torn along one edge; the wax around those three heads is cracked in a ring. The fourth head stands a hair proud of the board."},
	{"zone": &"z.doc.ref_screws", "tool": &"*", "requires": [&"f.screw_points"],
	 "req_say": "Pages of screws, old and new. Without a screw in mind they are only pages.",
	 "facts": [&"f.ref_screw_points"],
	 "say": "Hand-made screws: blunt end, filed thread of uneven pitch, slot off centre. Pointed screws that cut their own way: patented 1846, made in quantity in Birmingham from 1854."},

	# руйнівна дія — з підтвердженням (відмова не карається)
	{"zone": &"z.well.back_board", "tool": &"tool.screwdriver", "requires": [&"f.board_screwed"],
	 "req_say": "Unscrew what? See first how the board is held.",
	 "confirm": "Take a screwdriver to a client\'s furniture?  Click once more to do it.",
	 "facts": [&"f.board_lifted"], "sets_state": {&"z.well.back_board": &"open"},
	 "say": "The four screws come out. Behind the board there is a recess, lined, and no dust on its front lip."},

	{"zone": &"z.void.lining", "tool": &"tool.loupe",
	 "facts": [&"f.lining_fleck"],
	 "say": "End grain of the lining: close, pale, crossed by fine bright flecks. End grain of the carcass boards beside it: coarse, resinous, no flecks."},
	{"zone": &"z.void.floor", "tool": &"tool.rake",
	 "facts": [&"f.dust_rectangle"],
	 "say": "Under a low light the floor is grey with settled dust, except one rectangle, 148 × 96 mm, clean to the wood. Its edges are sharp."},
	{"zone": &"z.doc.label_pigeonhole", "tool": &"tool.loupe",
	 "facts": [&"f.trade_label"],
	 "say": "A paper label, lifted at one corner: 'J. HALBERT — Möbel & Antiquitäten, Wien I. Repaired and fitted, 1867.'"},
]

const FACTS := {
	&"f.escutcheon_bright":    {"cite": "bright scratches at the lock", "tag": &"lock", "weight": 1,
		"text": "Four scratches by the keyhole; their metal is bright, the metal around them brown."},
	&"f.daybook_locksmith":    {"cite": "our own locksmith opened it on the 3rd", "tag": &"papers", "weight": 2,
		"text": "Day-book, the 3rd: opened on arrival by Krenn, the bureau\'s locksmith. House keys surrendered with the piece."},
	&"f.stamp_gruber":         {"cite": "the workshop stamp under the drawer", "tag": &"body", "weight": 2,
		"text": "Burnt into the box bottom: M. GRUBER · WIEN. Chalk number 367 beside it."},
	&"f.reg_gruber_1822_1841": {"cite": "the register dates the stamp to 1822–1841", "tag": &"books", "weight": 2,
		"text": "Register: Gruber, Michael, Möbeltischler, Wien-Gumpendorf. Stamp in use 1822–1841."},
	&"f.board_screwed":        {"cite": "screws where the rest of the carcass is dowelled", "tag": &"body", "weight": 2,
		"text": "Four screws hold the well\'s back board. The rest of the carcass is dowelled and square-nailed."},
	&"f.screw_points":         {"cite": "pointed screws with even thread", "tag": &"body", "weight": 3,
		"text": "The screws end in a point; the thread is even head to tip; the slots run through the centre."},
	&"f.ref_screw_points":     {"cite": "the screw book puts that screw after 1854", "tag": &"books", "weight": 3,
		"text": "Reference: blunt, hand-filed screws before 1846; pointed self-starting screws patented 1846, in quantity from 1854."},
	&"f.slot_burr":            {"cite": "three heads turned, the wax broken around them", "tag": &"body", "weight": 3,
		"text": "Three slots bright and torn at one edge; the wax around those heads cracked in a ring. The fourth head stands proud."},
	&"f.board_lifted":         {"cite": "the recess behind the board", "tag": &"body", "weight": 2,
		"text": "Behind the board there is a recess, lined, with no dust on its front lip."},
	&"f.lining_fleck":         {"cite": "the lining is not the wood of the carcass", "tag": &"body", "weight": 3,
		"text": "Lining end grain: close, pale, fine bright flecks. Carcass end grain beside it: coarse, resinous, no flecks."},
	&"f.dust_rectangle":       {"cite": "a clean rectangle in the dust, 148 × 96", "tag": &"body", "weight": 3,
		"text": "Dust on the floor of the recess everywhere but one rectangle, 148 × 96 mm, clean to the wood, sharp at the edges."},
	&"f.trade_label":          {"cite": "the dealer\'s label of 1867", "tag": &"papers", "weight": 2,
		"text": "Paper label in the right pigeonhole: \'J. HALBERT — Möbel & Antiquitäten, Wien I. Repaired and fitted, 1867.\'"},
}

# ── АТЕСТАТ: 6 граф (case_02.md §6, канонічна таблиця) ───────────────────────
const SLOTS := [
	{"id": &"s.piece", "pre": "The piece is", "kind": &"CHOICE",
	 "hint": "( look under the drawer, then in the register )",
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
		[&"o.with_carcass", "with the carcass, by the workshop that made it"],
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
	 "basis_any": [&"f.dust_rectangle", &"f.slot_burr"], "basis_weight": 5,
	 "text": "The secretaire went out at nine, to a dealer in the Wollzeile, at the figure you set. At eleven a boy brought back the receipt, unsigned. Frau Vogl did not come for the money. The shipping office holds one ticket for Thursday, paid in full, in the name of her son. It was paid on the 4th — the day after the keys were given up, and three days before she came to you."},
	{"id": &"out.locksmith_broken",
	 "when": {&"s.lock_marks": &"o.forced"},
	 "text": "A constable called at eight and took the piece to the station as evidence of a forced entry. Krenn the locksmith was sent for at nine and kept until two. He has worked for this bureau eleven years. The note says he did not argue. The bureau\'s contract with him is on the desk, unsigned for renewal. Frau Vogl\'s son sailed. She was not on the quay."},
	{"id": &"out.sold_short",
	 "when": {&"s.void_origin": &"o.with_carcass"},
	 "text": "Sold at your figure: sixty gulden, walnut, sound, no faults recorded. A fortnight later the Wollzeile catalogue lists it: \'Biedermeier secretaire, Vienna, c. 1825, with concealed compartment behind the writing well — 260 gulden.\' Frau Vogl\'s rent was paid to the end of the month."},
	{"id": &"out.trade_fitting",
	 "when": {&"s.void_origin": &"o.trade_later"},
	 "basis_any": [&"f.trade_label"],
	 "text": "Halbert\'s shop answered the enquiry by return: they repaired the piece in 1867, a hinge and two feet, and they fit no compartments — \'we sell furniture, not conjuring.\' The letter is filed. The question it answers is not the one the certificate settled."},
	{"id": &"out.default", "when": {},
	 "text": "The piece sold, the money was paid out, and the ledger line closed. Nothing else came of it — that anyone has yet heard."},
]
