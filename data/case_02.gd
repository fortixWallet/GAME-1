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
	# --- деталі годинника: зона = центральні ~60% фото ---
	&"z.watch.wear": {
		"kind": &"img", "screen": &"WATCH_WEAR",
		"u": Vector2(0.50, 0.50), "shape": &"rect", "half": Vector2(0.31, 0.31),
		"hint": "Bring the eye close.",
	},
	&"z.watch.chain": {
		"kind": &"img", "screen": &"WATCH_CHAIN",
		"u": Vector2(0.50, 0.50), "shape": &"rect", "half": Vector2(0.31, 0.31),
		"hint": "Bring the eye close.",
	},
}

const RULES := [
	{"zone": &"z.testimony.widow", "tool": &"*", "facts": [&"f.testimony_read"],
	 "say": "The widow: wound every night before the lamp, thirty years; the chain was his father's and never off the watch."},
	{"zone": &"z.testimony.nephew", "tool": &"*", "facts": [&"f.testimony_read"],
	 "say": "The nephew: given in the last week; the chain put on fresh, by his own hand. Right-handed, as the uncle was."},
	{"zone": &"z.watch.wear", "tool": &"*", "facts": [&"f.crown_wear"],
	 "say": "The crown is worn flat on its LEFT side — wound for years by a left hand."},
	{"zone": &"z.watch.chain", "tool": &"*", "facts": [&"f.bow_scratches"],
	 "say": "The bow is scratched bright and raw — this chain was put on lately, not worn for thirty years."},
]

const FACTS := {
	&"f.testimony_read": {"cite": "the two statements, side by side", "tag": &"papers", "weight": 1},
	&"f.crown_wear":     {"cite": "the crown worn on its left side", "tag": &"body", "weight": 2},
	&"f.bow_scratches":  {"cite": "the fresh scratches at the bow", "tag": &"body", "weight": 2},
}
