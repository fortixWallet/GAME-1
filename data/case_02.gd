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
const START_TOOLS := [&"tool.loupe", &"tool.rake", &"tool.caliper", &"tool.screwdriver"]

const ZONES := {
	# --- корпус: екран FURN ---
	&"z.sec.escutcheon": {
		"kind": &"mesh", "screen": &"FURN", "node": &"sec_body",
		"at": Vector3(0.0, -0.02, 0.40), "facing": Vector3(0, 0.55, 1),
		"r": 0.06, "facing_min": 0.10,
		"hint": "The keyhole escutcheon",
		"tools": [&"tool.loupe", &"tool.eye"],
	},
	&"z.sec.drawer_front": {
		"kind": &"mesh", "screen": &"FURN", "node": &"sec_body",
		"at": Vector3(0.0, -0.25, 0.32), "facing": Vector3(0, 0, 1),
		"r": 0.26, "facing_min": 0.10,
		"hint": "The long drawer",
		"tools": [&"tool.hand", &"tool.caliper"],
	},
	&"z.sec.carcass_side": {
		"kind": &"mesh", "screen": &"FURN", "node": &"sec_body",
		"at": Vector3(-0.43, 0.02, 0.30), "facing": Vector3(-1, 0, 0.35),
		"r": 0.09, "facing_min": 0.08,
		"hint": "The front edge of the side",
		"tools": [&"tool.caliper", &"tool.eye"],
	},
	&"z.sec.back_edge": {
		"kind": &"mesh", "screen": &"FURN", "node": &"sec_body",
		"at": Vector3(0.44, 0.55, -0.30), "facing": Vector3(1, 0.2, -0.4),
		"r": 0.08, "facing_min": 0.06,
		"hint": "The exposed edge of the back board",
		"tools": [&"tool.caliper", &"tool.eye"],
	},
	# --- писальний відділ (дошка відкинута): екран WELL ---
	&"z.well.back_board": {
		"kind": &"mesh", "screen": &"WELL", "node": &"sec_body",
		"at": Vector3(0.0, 0.185, -0.05), "facing": Vector3(0, 0.2, 1),
		"r": 0.105, "facing_min": 0.08,
		"hint": "The back board of the writing well",
		"tools": [&"tool.eye", &"tool.loupe", &"tool.caliper", &"tool.screwdriver"],
	},
	&"z.void.lining": {
		"kind": &"mesh", "screen": &"WELL", "node": &"sec_body",
		"at": Vector3(0.0, 0.185, -0.12), "facing": Vector3(0, 0.2, 1),
		"r": 0.10, "facing_min": 0.06,
		"hint": "The lining of the recess",
		"tools": [&"tool.loupe"],
		"requires_state": {&"z.well.back_board": &"open"},
	},
	&"z.void.floor": {
		"kind": &"mesh", "screen": &"WELL", "node": &"sec_body",
		"at": Vector3(0.0, 0.095, -0.10), "facing": Vector3(0, 0.5, 1),
		"r": 0.08, "facing_min": 0.06,
		"hint": "The floor of the recess",
		"tools": [&"tool.rake", &"tool.loupe"],
		"requires_state": {&"z.well.back_board": &"open"},
	},
	# --- вийнята шухляда в руках: екран DRAWER ---
	&"z.drawer.underside": {
		"kind": &"mesh", "screen": &"DRAWER", "node": &"sec_drawer",
		"at": Vector3(0.0, -0.10, 0.0), "facing": Vector3(0, -1, 0),
		"r": 0.34, "facing_min": 0.10,
		"hint": "The underside of the drawer",
		"tools": [&"tool.rake", &"tool.loupe", &"tool.caliper"],
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
		"kind": &"img", "screen": &"BOOK_SCREWS", "surface": &"reg_page_h",
		"u": Vector2(0.50, 0.45), "shape": &"rect", "half": Vector2(0.36, 0.30),
		"hint": "The chapter on screws",
	},
	&"z.doc.label_pigeonhole": {
		"kind": &"mesh", "screen": &"WELL", "node": &"sec_body",
		"at": Vector3(0.34, 0.30, 0.02), "facing": Vector3(0, 0.2, 1),
		"r": 0.07, "facing_min": 0.06,
		"hint": "A paper label in the pigeonhole",
		"tools": [&"tool.loupe", &"tool.eye"],
	},
}

const RULES := [
	# простукати шухляду: прапорець справи, не факт — «глуха середина» ще нічого не доводить
	{"zone": &"z.sec.drawer_front", "tool": &"tool.hand",
	 "sets_flag": {&"knock_heard": true},
	 "say": "Rapped along the front, the drawer answers with a tone at the left and at the right, and flat in the middle third."},
	{"zone": &"z.sec.drawer_front", "tool": &"tool.hand", "requires_flag": {&"knock_heard": true},
	 "sets_state": {&"z.sec.drawer_front": &"out"}, "screen": &"DRAWER",
	 "say": "The drawer comes out whole and rides up into both hands."},
	{"zone": &"z.sec.escutcheon", "tool": &"tool.loupe", "dwell": 0.5,
	 "facts": [&"f.escutcheon_bright"],
	 "say": "Four scratches run from the keyhole to the lower left. Their metal is bright; the metal around them is brown."},

	{"zone": &"z.doc.daybook_intake", "tool": &"*", "facts": [&"f.daybook_locksmith"],
	 "say": "Intake, the 3rd: 'Secretaire, walnut, from the estate of Herr F. Opened on arrival by Krenn, our locksmith — lock seized. House keys surrendered with the piece.'"},

	{"zone": &"z.drawer.underside", "tool": &"tool.rake", "dwell": 0.6,
	 "facts": [&"f.stamp_gruber"],
	 "say": "Burnt into the drawer bottom, low and to the left: M. GRUBER · WIEN. Beside it, in chalk, a number: 367."},
	{"zone": &"z.doc.register_gruber", "tool": &"*", "requires": [&"f.stamp_gruber"],
	 "facts": [&"f.reg_gruber_1822_1841"],
	 "say": "GRUBER, Michael. Möbeltischler, Wien, Gumpendorf. Workshop stamp in use 1822–1841. Numbered his carcasses in chalk."},

	# --- ноніус: три числа, з яких СКЛАДАЄТЬСЯ схованка ---
	{"zone": &"z.sec.carcass_side", "tool": &"tool.caliper", "requires_flag": {&"knock_heard": true},
	 "facts": [&"f.outer_depth"],
	 "say": "Fixed jaw on the front edge of the side, sliding jaw on the outer face of the back board: 486.0 mm."},
	{"zone": &"z.sec.back_edge", "tool": &"tool.caliper", "requires": [&"f.outer_depth"],
	 "facts": [&"f.back_thickness"],
	 "say": "The back board, measured at its exposed edge: 12.0 mm."},
	{"zone": &"z.well.back_board", "tool": &"tool.caliper", "requires": [&"f.outer_depth"],
	 "facts": [&"f.inner_depth"],
	 "say": "Fixed jaw on the same front edge, sliding jaw on the face of the well's back board: 455.0 mm."},
	# друга дорога до inner_depth: дно вийнятої шухляди + упор
	{"zone": &"z.drawer.underside", "tool": &"tool.caliper", "requires": [&"f.outer_depth"],
	 "facts": [&"f.inner_depth"],
	 "say": "The drawer bottom runs 443.0 mm, and the drawer rides on a 12 mm stop: the well is 455.0 from the front edge."},

	{"zone": &"z.well.back_board", "tool": &"tool.eye", "dwell": 0.6,
	 "facts": [&"f.board_screwed"],
	 "say": "This board is held by four screws. Everywhere else the carcass is pinned with wooden dowels and square nails."},
	{"zone": &"z.well.back_board", "tool": &"tool.loupe", "dwell": 1.0, "requires": [&"f.board_screwed"],
	 "facts": [&"f.screw_points"],
	 "say": "The screws run to a sharp point. The thread is even from head to tip. Every slot passes through the centre of the head."},
	{"zone": &"z.well.back_board", "tool": &"tool.loupe", "dwell": 1.4, "requires": [&"f.screw_points"],
	 "facts": [&"f.slot_burr"],
	 "say": "Three slots are bright and torn along one edge; the wax around those three heads is cracked in a ring. The fourth head stands a hair proud of the board."},
	{"zone": &"z.doc.ref_screws", "tool": &"*", "requires": [&"f.screw_points"],
	 "facts": [&"f.ref_screw_points"],
	 "say": "Hand-made screws: blunt end, filed thread of uneven pitch, slot off centre. Pointed screws that cut their own way: patented 1846, made in quantity in Birmingham from 1854."},

	# руйнівна дія — з підтвердженням (відмова не карається)
	{"zone": &"z.well.back_board", "tool": &"tool.screwdriver", "requires": [&"f.board_screwed"],
	 "confirm": "Take a screwdriver to a client\'s furniture?  Click once more to do it.",
	 "facts": [&"f.board_lifted"], "sets_state": {&"z.well.back_board": &"open"},
	 "say": "The four screws come out. Behind the board there is a recess, lined, and no dust on its front lip."},

	{"zone": &"z.void.lining", "tool": &"tool.loupe", "dwell": 0.8,
	 "facts": [&"f.lining_fleck"],
	 "say": "End grain of the lining: close, pale, crossed by fine bright flecks. End grain of the carcass boards beside it: coarse, resinous, no flecks."},
	{"zone": &"z.void.floor", "tool": &"tool.rake", "dwell": 1.0,
	 "facts": [&"f.dust_rectangle"],
	 "say": "Under a low light the floor is grey with settled dust, except one rectangle, 148 × 96 mm, clean to the wood. Its edges are sharp."},
	{"zone": &"z.doc.label_pigeonhole", "tool": &"tool.loupe", "dwell": 0.5,
	 "facts": [&"f.trade_label"],
	 "say": "A paper label, lifted at one corner: 'J. HALBERT — Möbel & Antiquitäten, Wien I. Repaired and fitted, 1867.'"},
]

const FACTS := {
	&"f.escutcheon_bright":    {"cite": "bright scratches at the lock", "tag": &"lock", "weight": 1,
		"text": "Four scratches by the keyhole; their metal is bright, the metal around them brown."},
	&"f.daybook_locksmith":    {"cite": "our own locksmith opened it on the 3rd", "tag": &"papers", "weight": 2,
		"text": "Day-book, the 3rd: opened on arrival by Krenn, the bureau\'s locksmith. House keys surrendered with the piece."},
	&"f.stamp_gruber":         {"cite": "the workshop stamp under the drawer", "tag": &"body", "weight": 2,
		"text": "Burnt into the drawer bottom: M. GRUBER · WIEN. Chalk number 367 beside it."},
	&"f.reg_gruber_1822_1841": {"cite": "the register dates the stamp to 1822–1841", "tag": &"books", "weight": 2,
		"text": "Register: Gruber, Michael, Möbeltischler, Wien-Gumpendorf. Stamp in use 1822–1841."},
	&"f.outer_depth":          {"cite": "486.0 mm outside", "tag": &"measure", "weight": 1,
		"text": "Front edge of the side to the outer face of the back board: 486.0 mm."},
	&"f.back_thickness":       {"cite": "a back board of 12.0 mm", "tag": &"measure", "weight": 1,
		"text": "The back board at its edge: 12.0 mm."},
	&"f.inner_depth":          {"cite": "455.0 mm inside", "tag": &"measure", "weight": 1,
		"text": "Front edge of the side to the face of the well\'s back board: 455.0 mm."},
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
	 "needs": [&"f.stamp_gruber", &"f.reg_gruber_1822_1841"],
	 "opts": [
		[&"o.vienna_1820s", "a Viennese fall-front secretaire of the 1820s, by the workshop whose stamp it carries"],
		[&"o.later_copy", "a later copy in the Viennese manner"],
		[&"o.marriage", "two pieces married into one"],
	]},
	{"id": &"s.void_mm", "pre": "Depth outside, less the boards, less the depth inside — in millimetres:",
	 "suf": "mm", "kind": &"NUMBER", "digits": 2, "min": 10, "max": 99,
	 "needs": [&"f.outer_depth", &"f.back_thickness", &"f.inner_depth"]},
	{"id": &"s.void_origin", "pre": "The recess was cut", "kind": &"CHOICE",
	 "needs": [&"f.board_screwed", &"f.screw_points", &"f.ref_screw_points", &"f.lining_fleck"],
	 "opts": [
		[&"o.with_carcass", "with the carcass, by the workshop that made it"],
		[&"o.trade_later", "later, in a dealer\'s workshop, as a selling feature"],
		[&"o.private_later", "later, by a hand working alone, in the house"],
	]},
	{"id": &"s.last_opened", "pre": "The recess was last opened", "kind": &"CHOICE",
	 "needs": [&"f.dust_rectangle", &"f.slot_burr"],
	 "opts": [
		[&"o.never", "not since it was fitted"],
		[&"o.long_ago", "years ago"],
		[&"o.within_fortnight", "within the fortnight"],
	]},
	{"id": &"s.lock_marks", "pre": "The marks on the lock are", "kind": &"CHOICE",
	 "needs": [&"f.escutcheon_bright"],
	 "opts": [
		[&"o.forced", "the work of someone who had no key"],
		[&"o.our_locksmith", "the work of this bureau, on the 3rd"],
		[&"o.old_wear", "the wear of forty years of use"],
	]},
	{"id": &"s.basis", "pre": "On the strength of:", "kind": &"FACTS",
	 "min_count": 2, "max_count": 4,
	 "needs_slot": [&"s.void_origin", &"s.last_opened"],
	 "clears_on": [&"s.void_origin", &"s.last_opened"]},
]

# ── НАСЛІДКИ РАНКУ (case_02.md §7): перший збіг виграє ───────────────────────
const OUTCOMES := [
	{"id": &"out.void_named",
	 "when": {&"s.void_origin": &"o.private_later", &"s.last_opened": &"o.within_fortnight",
			  &"s.lock_marks": &"o.our_locksmith", &"s.void_mm": {"min": 18, "max": 20}},
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
