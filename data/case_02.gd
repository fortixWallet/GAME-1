# data/case_02.gd — СПРАВА 2 «СПАДОК УДОВИ» (чернетка) як дані.
#
# Мінімальний набір для єдиного ловця 2D-зон (крок 5b): свідчення і дві деталі
# годинника. Повна специфікація справи 2 — _src/cases/case_02.md (секретер) —
# ІНША справа; цей годинник — тимчасовий контент, що переїде при кроці 9.
# Закон той самий: say — спостереження, не висновок.
extends RefCounted

const ZONES := {
	# --- аркуш свідчень: два місця, які треба ЗІСТАВИТИ ---
	&"z.testimony.widow": {
		"kind": &"img", "screen": &"TESTIMONY",
		"u": Vector2(0.50, 0.28), "shape": &"rect", "half": Vector2(0.36, 0.16),
		"hint": "The widow's statement",
	},
	&"z.testimony.nephew": {
		"kind": &"img", "screen": &"TESTIMONY",
		"u": Vector2(0.50, 0.63), "shape": &"rect", "half": Vector2(0.36, 0.16),
		"hint": "The nephew's statement",
	},
	# --- деталі НА САМОМУ ГОДИННИКУ (вимога Віктора 26.07: підказки на предметі,
	# а не окремі картинки — той самий закон, що зони на келиху). Кадр столу
	# 5504×3072 достатньо детальний; координати — частки зображення, зняті з кропу.
	&"z.watch.crown": {
		"kind": &"img", "screen": &"DESK2", "surface": &"case2_desk",
		"u": Vector2(0.487, 0.651), "r": 0.014,
		"hint": "The winding crown",
	},
	&"z.watch.bow": {
		"kind": &"img", "screen": &"DESK2", "surface": &"case2_desk",
		"u": Vector2(0.497, 0.660), "shape": &"rect", "half": Vector2(0.020, 0.048),
		"hint": "The bow, and the chain on it",
	},
}

const RULES := [
	{"zone": &"z.testimony.widow", "tool": &"*", "facts": [&"f.testimony_read"],
	 "say": "The widow: wound every night before the lamp, thirty years; the chain was his father's and never off the watch."},
	{"zone": &"z.testimony.nephew", "tool": &"*", "facts": [&"f.testimony_read"],
	 "say": "The nephew: given in the last week; the chain put on fresh, by his own hand. Right-handed, as the uncle was."},
	{"zone": &"z.watch.crown", "tool": &"*", "facts": [&"f.crown_wear"],
	 "say": "The crown is worn flat on its LEFT side — wound for years by a left hand."},
	{"zone": &"z.watch.bow", "tool": &"*", "facts": [&"f.bow_scratches"],
	 "say": "The bow is scratched bright and raw — this chain was put on lately, not worn for thirty years."},
]

const FACTS := {
	&"f.testimony_read": {"cite": "the two statements, side by side", "tag": &"papers", "weight": 1,
		"text": "The widow: wound every night, thirty years, the chain his father's. The nephew: given last week, the chain put on fresh by his own hand."},
	&"f.crown_wear":     {"cite": "the crown worn on its left side", "tag": &"body", "weight": 2,
		"text": "The crown is worn flat on its LEFT side — wound for years by a left hand."},
	&"f.bow_scratches":  {"cite": "the fresh scratches at the bow", "tag": &"body", "weight": 2,
		"text": "The bow is scratched bright and raw — this chain was put on lately, not worn for thirty years."},
}


# ── АТЕСТАТ справи 2 (чернетка, той самий формат, що в case_01) ──────────────
const SLOTS := [
	{"id": &"s.c2.winder", "pre": "The watch was wound, these thirty years,", "kind": &"CHOICE",
	 "needs": [&"f.crown_wear"],
	 "opts": [
		[&"o.left_hand", "by a left hand"],
		[&"o.right_hand", "by a right hand"],
		[&"o.several_hands", "by more hands than one"],
	]},
	{"id": &"s.c2.chain", "pre": "The chain now upon it", "kind": &"CHOICE",
	 "needs": [&"f.bow_scratches"],
	 "opts": [
		[&"o.worn_thirty", "has ridden on it for thirty years"],
		[&"o.put_on_lately", "was put on lately"],
	]},
	{"id": &"s.c2.belongs", "pre": "The watch answers the account of", "kind": &"CHOICE",
	 "needs": [&"f.testimony_read"], "needs_slot": [&"s.c2.winder", &"s.c2.chain"],
	 "opts": [
		[&"o.the_widow", "the widow"],
		[&"o.the_nephew", "the nephew"],
		[&"o.neither", "neither account as given"],
	]},
	{"id": &"s.c2.basis", "pre": "On the strength of:", "kind": &"FACTS",
	 "min_count": 2, "max_count": 3,
	 "needs_slot": [&"s.c2.belongs"], "clears_on": [&"s.c2.belongs"]},
]

const OUTCOMES := [
	{"id": &"out.c2.widow",
	 "when": {&"s.c2.winder": &"o.left_hand", &"s.c2.chain": &"o.put_on_lately",
			  &"s.c2.belongs": &"o.the_widow"},
	 "text": "The nephew did not come back for the paper. The widow carried the watch out wound, and wound it that night, the constable says, before her lamp."},
	{"id": &"out.c2.nephew",
	 "when": {&"s.c2.belongs": &"o.the_nephew"},
	 "text": "The nephew sold the watch by Friday. The chain he kept. A watch that remembered one hand for thirty years now lies in a drawer on the Graben, stopped."},
	{"id": &"out.c2.default", "when": {},
	 "text": "The claimants were sent away with the watch in neither hand. It sits in the bureau's iron press, wound by no one, and the ledger line reads: undecided."},
]
