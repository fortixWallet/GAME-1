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
	&"f.testimony_read": {"cite": "the two statements, side by side", "tag": &"papers", "weight": 1},
	&"f.crown_wear":     {"cite": "the crown worn on its left side", "tag": &"body", "weight": 2},
	&"f.bow_scratches":  {"cite": "the fresh scratches at the bow", "tag": &"body", "weight": 2},
}
