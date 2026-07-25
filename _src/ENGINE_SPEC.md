# ENGINE_SPEC — рушій «справа як дані»
### 25.07.2026. Реалізаційна специфікація до PUZZLES_V4 §6, §8 і SIUZHET_ZAHADKY_V6.
### Читати після PUZZLES_V4. Це не пропозиція, а те, що пишеться в код.

Правило номер один цього документа: **рушій не знає слова «келих»**. Він знає ToolDef, зону,
правило, факт, слот і вихід. Справа 11 має додатися файлом даних і нулем рядків рушія — це
критерій приймання кроку 9 з PUZZLES_V4 §8.

---

## 0. ФАЙЛИ І МЕЖІ

```
core/surface.gd     class_name Surface      2D: зображення ↔ екран, з аспектом
core/zones.gd       class_name ZoneHit      пікінг 2D і 3D, вибір найкращої зони
core/tool_def.gd    class_name ToolDef      Resource: арт, звук, курсор, verb
core/state.gd       class_name CaseState    факти, зони, слоти, мета — ЄДИНЕ джерело правди
core/rules.gd       class_name RuleEngine   індекс правил, apply()
core/notebook.gd    class_name Notebook     порядок фактів, вирізки, стратиграфія
core/save.gd        class_name SaveIO       version + міграції
core/catcher.gd     class_name ToolCatcher  Control-ловець вводу інструмента
data/tools/*.tres   інстанси ToolDef
data/case_01.gd     class_name Case01 — const ZONES / RULES / FACTS / SLOTS / OUTCOMES
main.gd             складання картинок + _sync_view(). Стану НЕ тримає.
```

**Resource (.tres)** — там, де є посилання на асет: Godot пише `uid://`, перейменування файлу
не ламає гру. **const у .gd** — сотні однорідних рядків правил: git-diff читний, мердж без конфліктів.

**Межа, яку не переступаємо:** `main.gd` читає `CaseState` і не пише в нього нічого, крім
через `RuleEngine.apply()` та явні `state.set_slot()`. Жоден обробник кнопки не виставляє
буліни вигляду — вигляд виводиться в `_sync_view()`.

---

## 1. СТРУКТУРИ

### 1.1. ToolDef — `core/tool_def.gd`

```gdscript
@tool
class_name ToolDef extends Resource

enum Verb {
	OBSERVE,     # дивитись: лупа, косе світло, свічка на просвіт — стан речі не міняє
	APPLY,       # прикласти: спирт, віск, магніт — зворотне
	MEASURE,     # виміряти: штангенциркуль, вага, терези — дає ЧИСЛО
	DESTRUCTIVE, # незворотне: пропил на ребрі піддона, купеляція. Питає підтвердження
}

@export var id: StringName = &""              # &"tool.loupe" — унікальний, у збереженні
@export var name_key: String = ""             # ключ локалізації, НЕ англійський рядок
@export var verb: Verb = Verb.OBSERVE

@export_group("Арт")
@export var icon: Texture2D                   # у поясі інструментів
@export var held: Texture2D                   # спрайт у руці (лупа зі склом, свічка)
@export var held_pivot := Vector2(0.31, 0.33) # точка дії у частках СПРАЙТА (центр скла)
@export var cursor: Texture2D                 # мальований курсор; null → held
@export var cursor_hotspot := Vector2.ZERO    # у пікселях курсора
@export var overlay: Texture2D                # мальований оверлей ефекту (косе світло тощо)

@export_group("Звук")
@export var sfx_take: StringName = &"ui_soft"
@export var sfx_use: StringName = &"page_turn"
@export var sfx_fail: StringName = &""

@export_group("Поведінка")
@export var magnify: float = 1.0              # 1.0 = не збільшує; лупа 4.3
@export var radius: float = 0.055             # активна пляма, частка ШИРИНИ зображення/екрана
@export var dwell: float = 0.0                # с. утримання над зоною (0 = діє кліком)
@export var on_click: bool = false            # true → діє натисканням, не наведенням
@export var needs_hands: bool = false         # лише на 3D-екранах (HANDS)
@export var on_papers: bool = true            # чи працює на паперових екранах
@export var uses_max: int = -1                # -1 = нескінченно; спирт, віск, реактив — 3..6
@export var exclusive_with: Array[StringName] = []  # свічка гасне, коли береш лупу
@export var unlocked_by: StringName = &""     # факт/подія, що дає інструмент у пояс
```

Стани в `.tres` не зберігаються — витрачені заряди живуть у `CaseState.tool_uses`.
Resource у Godot спільний між інстансами; писати в нього під час гри **заборонено**.

### 1.2. ZONES — постійні, підписані, ніякого pixel hunt

Зона має **один** із двох видів. `kind` вирішує, який пікінг.

```gdscript
# data/case_01.gd
const ZONES := {
	# --- 2D: частки ЗОБРАЖЕННЯ, не екрана ---
	&"z.papers.receipt": {
		"kind": &"img",
		"screen": &"DOCS",          # на якому екрані існує
		"surface": &"letter_client",# ключ поверхні (арт), над якою рахуються частки
		"u": Vector2(0.512, 0.331), # центр у частках ЗОБРАЖЕННЯ (0..1)
		"r": 0.070,                 # радіус у частках ШИРИНИ зображення → коло лишається колом
		"label_key": "zone.receipt_date",
		"tools": [&"tool.loupe", &"tool.caliper"],   # які інструменти тут щось дають (для курсора)
	},
	&"z.desk.goblet": {
		"kind": &"img", "screen": &"DESK", "surface": &"case_desk",
		"u": Vector2(0.508, 0.414), "r": 0.086,
		"shape": &"rect", "half": Vector2(0.085, 0.258),  # опційно: прямокутник замість кола
		"label_key": "zone.goblet",
	},

	# --- 3D: точка на моделі + нормаль + світовий радіус ---
	&"z.foot.underside": {
		"kind": &"node3d",
		"screen": &"HANDS",
		"anchor": &"goblet_pivot",       # ім'я Node3D, у чиїх ЛОКАЛЬНИХ координатах усе нижче
		"p": Vector3(0.0, -0.690, 0.0),  # центр зони
		"n": Vector3(0.0, -1.0, 0.0),    # куди зона дивиться (спід — вниз)
		"r": 0.34,                       # радіус у СВІТОВИХ одиницях моделі
		"facing_min": 0.12,              # cos кута: <= → зона відвернута, не пікається
		"label_key": "zone.foot_underside",
		"tools": [&"tool.loupe", &"tool.rake"],
	},
	&"z.foot.rim": {
		"kind": &"node3d", "screen": &"HANDS", "anchor": &"goblet_pivot",
		"p": Vector3(0.0, -0.860, 0.320), "n": Vector3(0.0, -0.35, 0.94).normalized(),
		"r": 0.09, "facing_min": 0.05, "label_key": "zone.foot_rim",
	},
}
```

Поле `state` зони не оголошується — початковий стан завжди `&"default"`,
змінюється лише правилом (`"sets_zone"`). Так «пропил на ребрі» — це `z.foot.rim` у стані
`&"cut"`, а не окрема зона й не окремий буль.

### 1.3. RULES — «інструмент × зона × умови → факти»

```gdscript
const RULES := [
	# лупа на спід: два знаки за одне наведення — один факт про кожен
	{"id": &"r.marks", "tool": &"tool.loupe", "zone": &"z.foot.underside",
	 "dwell": 0.5, "gives": [&"f.mark_hoffmann", &"f.mark_diana"],
	 "sfx": &"page_turn", "say_key": "say.marks_seen"},

	# те саме місце, але вже знаючи, що шукати: відсутність тремолірштиха
	{"id": &"r.no_tremolier", "tool": &"tool.loupe", "zone": &"z.foot.underside",
	 "needs": [&"f.reg_tremolier_required"], "dwell": 1.2,
	 "gives": [&"f.no_tremolier"], "say_key": "say.no_zigzag"},

	# пальці по внутрішньому дну — горбик. Інструмент «рука», не лупа
	{"id": &"r.dome", "tool": &"tool.hand", "zone": &"z.bowl.inner_bottom",
	 "on_click": true, "gives": [&"f.dome_inside"], "say_key": "say.dome"},

	# незворотна дія міняє СТАН ЗОНИ, а не буль
	{"id": &"r.saw_rim", "tool": &"tool.saw", "zone": &"z.foot.rim",
	 "on_click": true, "confirm_key": "confirm.saw",
	 "sets_zone": {&"z.foot.rim": &"cut"}, "gives": [&"f.rim_cut"]},

	# реактив читається інакше по стану зони — те саме правило-ключ, різні гілки
	{"id": &"r.acid_rim_cut", "tool": &"tool.schwerter", "zone": &"z.foot.rim",
	 "zone_state": &"cut", "on_click": true, "uses": 1,
	 "gives": [&"f.acid_green_copper"], "say_key": "say.acid_green"},
	{"id": &"r.acid_rim_intact", "tool": &"tool.schwerter", "zone": &"z.foot.rim",
	 "zone_state": &"default", "on_click": true, "uses": 1,
	 "gives": [&"f.acid_red_silver"], "say_key": "say.acid_red"},   # хибний слід, і він чесний

	# правило без інструмента: спрацьовує на подію (відкриття довідника, звірка)
	{"id": &"r.register", "tool": &"*", "zone": &"z.book.register_hoffmann",
	 "on_click": true, "needs": [&"f.mark_hoffmann"],
	 "gives": [&"f.reg_hoffmann_1859_1871", &"f.reg_tremolier_required"]},
]
```

Поля правила (усі, крім `id`, необов'язкові):

| поле | тип | що робить |
|---|---|---|
| `id` | StringName | унікальний; лягає в `state.fired`, тому спрацювання переживає збереження |
| `tool` | StringName | `&"*"` = будь-який, зокрема «голе око» `&"tool.eye"` |
| `zone` | StringName | `&"*"` = будь-яка зона екрана |
| `needs` | Array | усі факти мусять бути |
| `needs_any` | Array | хоча б один |
| `forbids` | Array | жодного з цих |
| `zone_state` | StringName | вимога до стану зони |
| `dwell` | float | секунд утримання; 0 = миттєво |
| `on_click` | bool | діє натисканням, не наведенням |
| `uses` | int | скільки зарядів інструмента з'їдає |
| `confirm_key` | String | текст діалогу підтвердження для DESTRUCTIVE |
| `gives` | Array | факти |
| `sets_zone` | Dictionary | zone_id → новий стан |
| `sets_flag` | Dictionary | вільні мітки справи (не факти нотатника) |
| `sfx`, `say_key` | StringName/String | звук і репліка-спостереження |
| `repeat` | bool | `true` → правило не «згорає» (вага, яку можна перезважувати) |

**Одна дорога = одне правило. Один факт = один id, скільки б правил його не давали.**

Рушій правил — `core/rules.gd`. Індекс будується раз, `apply()` кличеться з ловця:

```gdscript
class_name RuleEngine extends RefCounted

var _rules: Array = []
var _idx: Dictionary = {}                       # "tool|zone" -> PackedInt32Array

func _init(table: Array) -> void:
	_rules = table
	for i in _rules.size():
		var r: Dictionary = _rules[i]
		var k: String = String(r.get("tool", &"*")) + "|" + String(r.get("zone", &"*"))
		if not _idx.has(k): _idx[k] = PackedInt32Array()
		(_idx[k] as PackedInt32Array).append(i)

func _candidates(tool: StringName, zone: StringName) -> PackedInt32Array:
	var out := PackedInt32Array()
	for k in [String(tool) + "|" + String(zone), "*|" + String(zone), String(tool) + "|*"]:
		if _idx.has(k): out.append_array(_idx[k])
	return out

func _ok(st: CaseState, r: Dictionary, zone: StringName) -> bool:
	if st.fired.has(r["id"]) and not bool(r.get("repeat", false)): return false
	if not st.has_all(r.get("needs", [])): return false
	if not st.has_any(r.get("needs_any", [])): return false
	for f in r.get("forbids", []):
		if st.has(f): return false
	if r.has("zone_state") and st.zone_st(zone) != r["zone_state"]: return false
	return true

# strength з ZoneHit; dt — get_process_delta_time(); click — чи це було натискання.
# Повертає {"new_facts": Array[StringName], "say": String, "progress": float}
func apply(st: CaseState, tool: ToolDef, zone: StringName, strength: float,
		dt: float, click: bool) -> Dictionary:
	var res := {"new_facts": [] as Array[StringName], "say": "", "progress": 0.0}
	if zone == &"" or strength < 0.0: return res
	for i in _candidates(tool.id, zone):
		var r: Dictionary = _rules[i]
		if not _ok(st, r, zone): continue
		var need_click: bool = bool(r.get("on_click", false))
		if need_click != click: continue
		var need_dwell: float = float(r.get("dwell", 0.0))
		if need_dwell > 0.0:
			var t: float = st.dwell_add(r["id"], dt * strength)
			res["progress"] = maxf(res["progress"], t / need_dwell)
			if t < need_dwell: continue
		if int(r.get("uses", 0)) > 0:
			if st.uses_left(tool) < int(r["uses"]): continue
			st.tool_uses[tool.id] = int(st.tool_uses.get(tool.id, 0)) + int(r["uses"])
		st.fired[r["id"]] = true
		for z in r.get("sets_zone", {}):
			st.set_zone(z, r["sets_zone"][z])
		for fl in r.get("sets_flag", {}):
			st.flags[fl] = r["sets_flag"][fl]
		for f in r.get("gives", []):
			if st.add_fact(f): (res["new_facts"] as Array).append(f)   # ЄДИНА двері фактів
		if r.has("say_key"): res["say"] = tr(r["say_key"])
		res["sfx"] = r.get("sfx", tool.sfx_use)
	return res
```

`DESTRUCTIVE` із `confirm_key` не викликає `apply()` одразу: ловець спершу піднімає
мальоване вікно підтвердження, і лише «так» кличе `apply()` з `click = true`.

### 1.4. FACTS — рядок нотатника + вирізка арту

```gdscript
const FACTS := {
	&"f.mark_hoffmann": {
		"text_key": "fact.mark_hoffmann",     # «A struck shield: HOFFMANN, Wien.»
		"group": &"marks",                    # розділ нотатника
		"crop": {"tex": &"foot_plate_maker", "uv": Rect2(0.38, 0.41, 0.24, 0.22)},
		"weight": 2,                          # вага в OUTCOMES: 2 = твердий доказ, 1 = натяк
	},
	&"f.mark_diana": {
		"text_key": "fact.mark_diana", "group": &"marks",
		"crop": {"tex": &"foot_plate_maker", "uv": Rect2(0.62, 0.44, 0.18, 0.20)}, "weight": 2},
	&"f.dome_inside": {
		"text_key": "fact.dome_inside", "group": &"body",
		"crop": {"tex": &"bowl_inner", "uv": Rect2(0.40, 0.52, 0.30, 0.26)}, "weight": 3},
	&"f.acid_red_silver": {
		"text_key": "fact.acid_red", "group": &"metal", "weight": 1},   # хибний слід, вага 1

	# картки стратиграфії — сортуються гравцем, тому мають strat
	&"f.strat_scratch":  {"text_key": "fact.scratch",  "group": &"strat", "strat": true,
		"crop": {"tex": &"strat_cards", "uv": Rect2(0.00, 0.0, 0.333, 1.0)}},
	&"f.strat_polish":   {"text_key": "fact.polish",   "group": &"strat", "strat": true,
		"crop": {"tex": &"strat_cards", "uv": Rect2(0.333, 0.0, 0.333, 1.0)}},
	&"f.strat_engrave":  {"text_key": "fact.engrave",  "group": &"strat", "strat": true,
		"crop": {"tex": &"strat_cards", "uv": Rect2(0.666, 0.0, 0.334, 1.0)}},
}

# істина стратиграфії живе в даних справи, а не в рушії
const STRAT_TRUTH := [&"f.strat_scratch", &"f.strat_polish", &"f.strat_engrave"]
const STRAT_GIVES := &"f.engraved_after_polish"   # факт, що видається за правильний порядок
```

`uv` — частки ЗОБРАЖЕННЯ. Вирізка малюється `AtlasTexture` (див. §4), тобто це буквально
шматок мальованого арту, а не намальований кодом прямокутник.

### 1.5. SLOTS — атестат

```gdscript
# core/slots.gd — глобальний, щоб дані справ і рушій говорили одними числами
class_name Slots extends Object
enum { CHOICE = 0, NUMBER = 1, FACTS = 2 }
```

```gdscript
# data/case_01.gd
const SLOTS := [
	{"id": &"s.origin", "kind": Slots.CHOICE,
	 "pre_key": "cert.origin.pre",
	 "needs": [&"f.reg_hoffmann_1859_1871"],
	 "hint_key": "cert.origin.hint",              # діегетично: «звір клеймо в реєстрі»
	 "opts": [&"o.vienna_hoffmann", &"o.prague_court", &"o.augsburg_guild"]},

	{"id": &"s.not_before", "kind": Slots.NUMBER,
	 "pre_key": "cert.not_before.pre",            # «Struck not earlier than ____»
	 "needs_any": [&"f.mark_diana"],
	 "digits": 4, "min": 1700, "max": 1900},      # СПИСКУ НЕМА. Рушій не знає, що правильно 1872

	{"id": &"s.metal", "kind": Slots.CHOICE,
	 "pre_key": "cert.metal.pre",
	 "needs_any": [&"f.acid_red_silver", &"f.acid_green_copper"],
	 "opts": [&"o.silver_900", &"o.copper_plated", &"o.silver_ballasted"]},

	{"id": &"s.provenance", "kind": Slots.CHOICE,
	 "pre_key": "cert.prov.pre", "needs_slot": [&"s.origin"],
	 "opts": [&"o.honest_inheritance", &"o.taken_from_church", &"o.made_to_look_stolen"]},

	{"id": &"s.basis", "kind": Slots.FACTS,
	 "pre_key": "cert.basis.pre", "needs_slot": [&"s.provenance"],
	 "min_count": 2, "max_count": 4,
	 "clears_on": [&"s.provenance"]},             # змінив походження → підстава злітає
]
```

Три залізні правила граф:

1. **NUMBER не має списку і не має валідації.** Гравець вписує чотири цифри й отримує
   рівно нуль зворотного зв'язку. Правильність вирішує тільки OUTCOMES наступного ранку.
2. **CHOICE тримає `id` варіанта**, а на папір лягає `tr("opt." + id)`. Англійський рядок
   у `cvals` — це зламана локалізація і зламані вироки. Забороняється.
3. **FACTS не має власних варіантів узагалі.** Джерело — `state.fact_order`, відфільтрований
   за `FACTS[f].group != &"strat"`. Простір відповідей = простір здобутого, спойлити нема чого.

### 1.6. OUTCOMES — подія наступного ранку, не «вірно/хибно»

```gdscript
const OUTCOMES := [
	{"id": &"out.forgery_caught",
	 "when": {&"s.provenance": &"o.made_to_look_stolen",
	          &"s.not_before": {"min": 1872, "max": 1872},
	          &"s.metal": &"o.silver_ballasted"},
	 "basis_any": [&"f.dome_inside", &"f.no_tremolier"],
	 "basis_weight": 4,
	 "text_key": "out.forgery_caught"},

	{"id": &"out.named_thief_wrongly",
	 "when": {&"s.provenance": &"o.taken_from_church"},
	 "basis_forbids": [&"f.dome_inside"],
	 "text_key": "out.named_thief_wrongly"},

	{"id": &"out.passed_it_clean",
	 "when": {&"s.provenance": &"o.honest_inheritance"},
	 "text_key": "out.passed_it_clean"},

	{"id": &"out.default", "when": {}, "text_key": "out.default"},   # завжди останній
]
```

Матчер (`RuleEngine.resolve_outcome`) бере **перший** запис, у якого:
`when` збігається по всіх ключах · усі `basis_needs` є серед фактів графи «на підставі» ·
хоч один `basis_any` є · жодного `basis_forbids` · сума `FACTS[f].weight` по графі ≥ `basis_weight`.
Порівняння NUMBER — або точне (`1872`), або словником `{"min":…, "max":…}`.

`out.default` без умов зобов'язаний бути останнім: рушій ніколи не повертає порожній вихід.

### 1.7. CaseState — `core/state.gd`

```gdscript
class_name CaseState extends RefCounted

signal fact_added(id: StringName, index: int)
signal zone_changed(id: StringName, st: StringName)
signal slot_changed(id: StringName)
signal tool_changed(id: StringName)
signal sealed_now()

var case_id: StringName = &""
var day: int = 1
var tod: StringName = &"day"                    # day | evening | night

# --- факти: порядок здобуття — це і є нотатник ---
var _facts: Dictionary = {}                     # StringName -> int (індекс здобуття)
var fact_order: Array[StringName] = []

# --- зони й правила ---
var zone_state: Dictionary = {}                 # StringName -> StringName
var fired: Dictionary = {}                      # rule_id -> true
var flags: Dictionary = {}                      # вільні мітки справи (НЕ факти нотатника)

# --- інструменти ---
var tool_active: StringName = &""
var tool_owned: Dictionary = {}                 # id -> true
var tool_uses: Dictionary = {}                  # id -> витрачено зарядів
var _dwell: Dictionary = {}                     # "rule_id" -> накопичені секунди

# --- нотатник ---
var strat_order: Array[StringName] = []         # порядок карток, який виклав гравець
var strat_locked: bool = false

# --- атестат ---
var cvals: Dictionary = {}                      # slot_id -> StringName | int | Array[StringName]
var active_slot: StringName = &""
var sealed: bool = false
var outcome_id: StringName = &""

# --- мета: переживає справу, живе у збереженні окремо ---
var world: Dictionary = {
	"seals_set": 0, "cases_sealed": [], "returned_unsealed": 0,
	"predecessor_seals": 1429, "signed_twice": false,
}

func has(id: StringName) -> bool:
	return _facts.has(id)

func has_all(ids: Array) -> bool:
	for i in ids:
		if not _facts.has(i): return false
	return true

func has_any(ids: Array) -> bool:
	if ids.is_empty(): return true
	for i in ids:
		if _facts.has(i): return true
	return false

func fact_index(id: StringName) -> int:
	return _facts.get(id, -1)

# ЄДИНЕ місце в грі, де народжується факт. Дублі гинуть тут і більше ніде.
func add_fact(id: StringName) -> bool:
	if id == &"" or _facts.has(id): return false
	_facts[id] = fact_order.size()
	fact_order.append(id)
	fact_added.emit(id, _facts[id])
	return true

func zone_st(id: StringName) -> StringName:
	return zone_state.get(id, &"default")

func set_zone(id: StringName, st: StringName) -> void:
	if zone_st(id) == st: return
	zone_state[id] = st
	zone_changed.emit(id, st)

func uses_left(t: ToolDef) -> int:
	return 999999 if t.uses_max < 0 else t.uses_max - int(tool_uses.get(t.id, 0))

# Дозрівання. НЕ зберігається: недодивився — почни спочатку (див. пастку §7.6).
func dwell_add(rule_id: StringName, amount: float) -> float:
	var t: float = float(_dwell.get(rule_id, 0.0)) + amount
	_dwell[rule_id] = t
	return t

func dwell_clear() -> void:      # на зміну екрана, інструмента і на відпускання зони
	_dwell.clear()

func set_slot(id: StringName, v: Variant) -> void:
	if sealed: return
	cvals[id] = v
	slot_changed.emit(id)

func slot_filled(s: Dictionary) -> bool:
	var v: Variant = cvals.get(s["id"], null)
	if v == null: return false
	match int(s["kind"]):
		Slots.FACTS:
			return (v as Array).size() >= int(s.get("min_count", 1))
		Slots.NUMBER:
			var n: int = int(v)
			return n >= int(s.get("min", 0)) and n <= int(s.get("max", 9999)) \
				and str(n).length() == int(s.get("digits", 4))
		_:
			return String(v) != ""
```

`flags` проти фактів: **факт бачить гравець у нотатнику**, флаг — ні (лампа ввімкнена,
штори засунуті, клієнтка вже заговорила). Плутати їх — той самий гріх, що буліни в V1.

---

## 2. ПІКІНГ

### 2.1. 2D — частки ЗОБРАЖЕННЯ з корекцією аспекту

Латентний баг поточного `main.gd`: `OBJ` задано в частках **екрана** (`x*W`, `y*H`).
Мінятися вікну — і зона з'їде з мальованої речі, а коло стане еліпсом. Лікується так:

```gdscript
class_name Surface extends RefCounted
# Прямокутник, у якому зображення РЕАЛЬНО лежить на екрані. Усі частки — від зображення.

var rect: Rect2 = Rect2()
var img: Vector2 = Vector2.ONE

static func cover(img_size: Vector2, vp: Vector2) -> Surface:
	# STRETCH_KEEP_ASPECT_COVERED — так лежать фони столу
	var s := Surface.new(); s.img = img_size
	var k: float = maxf(vp.x / img_size.x, vp.y / img_size.y)
	var d: Vector2 = img_size * k
	s.rect = Rect2((vp - d) * 0.5, d); return s

static func contain(img_size: Vector2, vp: Vector2) -> Surface:
	# STRETCH_KEEP_ASPECT_CENTERED — так лежать папери на весь екран
	var s := Surface.new(); s.img = img_size
	var k: float = minf(vp.x / img_size.x, vp.y / img_size.y)
	var d: Vector2 = img_size * k
	s.rect = Rect2((vp - d) * 0.5, d); return s

static func fixed(r: Rect2, img_size: Vector2) -> Surface:
	# явно покладений аркуш (сторінка каталогу, лист): rect задано кодом розкладки
	var s := Surface.new(); s.img = img_size; s.rect = r; return s

func to_screen(u: Vector2) -> Vector2:
	return rect.position + u * rect.size

func to_uv(p: Vector2) -> Vector2:
	return (p - rect.position) / rect.size

# КОРЕКЦІЯ АСПЕКТУ: радіус міряється по ШИРИНІ. Обидві осі поверхні масштабовані
# однаково (аспект зображення збережено), тож коло лишається колом при будь-якому вікні.
func radius_px(r_of_width: float) -> float:
	return r_of_width * rect.size.x

# для прямокутних зон: half задано в частках ширини І висоти зображення
func half_px(half: Vector2) -> Vector2:
	return Vector2(half.x * rect.size.x, half.y * rect.size.y)
```

Тест влучання (повертає **силу** 0..1, щоб перекриття зон вирішувалось однозначно):

```gdscript
static func hit_2d(z: Dictionary, surf: Surface, p: Vector2) -> float:
	var c: Vector2 = surf.to_screen(z["u"])
	if z.get("shape", &"circle") == &"rect":
		var h: Vector2 = surf.half_px(z["half"])
		var d: Vector2 = (p - c).abs()
		if d.x > h.x or d.y > h.y: return -1.0
		return 1.0 - maxf(d.x / h.x, d.y / h.y)
	var r: float = surf.radius_px(float(z["r"]))
	var d2: float = p.distance_to(c)
	return -1.0 if d2 > r else 1.0 - d2 / r
```

Радіус інструмента складається з радіусом зони: `r_eff = surf.radius_px(z.r + tool.radius)`.
Тому штангенциркуль (гострий, `radius = 0.012`) вимагає точності, а рука (`0.09`) — ні.

**Клік-маска за силуетом** (`BitMap` з альфи оверлея) лишається для речей-спрайтів, але
тепер вона перевіряється **в частках зображення спрайта**, а не екрана — див. пастку §7.4.

### 2.2. 3D — unproject + тест повернутості + проєктований радіус

Узагальнення `_check_underside`. Колайдери **не потрібні**: у нас відомі точка й нормаль.

```gdscript
# Повертає силу 0..1, або -1.0 якщо промах / зона відвернута / зона за камерою.
static func hit_3d(z: Dictionary, anchor: Node3D, cam: Camera3D, p: Vector2,
		zoom: float = 1.0) -> float:
	if anchor == null or cam == null: return -1.0
	var xf: Transform3D = anchor.global_transform
	var wp: Vector3 = xf * (z["p"] as Vector3)
	var wn: Vector3 = (xf.basis * (z["n"] as Vector3)).normalized()

	# 1) ТЕСТ ПОВЕРНУТОСТІ: зона дивиться в наш бік?
	var to_cam: Vector3 = (cam.global_position - wp).normalized()
	if wn.dot(to_cam) <= float(z.get("facing_min", 0.12)): return -1.0

	# 2) за спиною камери unproject_position бреше — відсікаємо явно
	if cam.is_position_behind(wp): return -1.0

	# 3) ПРОЄКТОВАНИЙ РАДІУС: беремо точку на межі зони, зміщену «вправо по екрану»,
	#    і міряємо, скільки пікселів вона дає. Далеко → мало, під лупою → багато.
	#    Саме тому зона САМА росте під лупою: loupe_cam ближче, той самий світовий радіус
	#    дає більший r_px, і цілитись стає легше рівно в міру збільшення.
	var c: Vector2 = cam.unproject_position(wp)
	var right: Vector3 = cam.global_transform.basis.x
	var edge: Vector3 = wp + right * float(z["r"])
	if cam.is_position_behind(edge): return -1.0
	var r_px: float = c.distance_to(cam.unproject_position(edge)) * zoom
	if r_px < 2.0: return -1.0                       # зона менша за 2 пікселі — це не влучання

	var d: float = p.distance_to(c)
	return -1.0 if d > r_px else 1.0 - d / r_px
```

**Два режими цілення в HANDS:**

| режим | камера | точка тесту | нащо |
|---|---|---|---|
| голе око / рука | `main_cam3` | позиція миші | грубий дотик, великі зони |
| лупа в руці | `loupe_cam` | **центр в'юпорта лупи** `loupe_vp.size * 0.5` | точне читання |

Лупа націлюється на те, що під центром скла (`_aim_loupe`), тому зона під прицілом
проєктується біля центру `loupe_vp`, і `r_px` там уже помножений на `LOUPE_MAG`.
Ніяких окремих «щедрих радіусів» і магічних `loupe_lw*0.7` більше не буде.

### 2.3. Вибір однієї зони

```gdscript
static func pick(case_data, st: CaseState, screen: StringName, surfaces: Dictionary,
		ctx: Dictionary, p: Vector2) -> Dictionary:
	var best := {"zone": &"", "strength": -1.0}
	for zid in case_data.ZONES:
		var z: Dictionary = case_data.ZONES[zid]
		if z["screen"] != screen: continue
		var s: float = -1.0
		if z["kind"] == &"img":
			var surf: Surface = surfaces.get(z["surface"], null)
			if surf != null: s = hit_2d(z, surf, p)
		else:
			s = hit_3d(z, ctx.get(z["anchor"]), ctx["cam"], p, ctx.get("zoom", 1.0))
		if s > best["strength"]: best = {"zone": zid, "strength": s}
	return best
```

Перекриття вирішується силою (ближче до центру перемагає), а не порядком у словнику.
Це важливо для §7: словники в Godot зберігають порядок вставки, і покладатись на нього — пастка.

---

## 3. ЛОВЕЦЬ ВВОДУ ІНСТРУМЕНТА

**Пастка, яку закриваємо:** GUI-пікінг Godot іде **зворотним порядком дітей** — остання
дитина опитується першою. `z_index` на мишачий пікінг Control **не впливає взагалі**
(він лише про порядок малювання). Тому ловець мусить бути останньою дитиною екрана,
а не «зверху за z_index».

```gdscript
class_name ToolCatcher extends Control

signal hover(zone: StringName, strength: float)
signal used(zone: StringName, strength: float)
signal cancelled()

var _armed: bool = false

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false

# visible == «режим інструмента». Один інстанс на гру; переїжджає на активний екран.
func arm(screen: Control) -> void:
	if get_parent() != screen:
		if get_parent(): get_parent().remove_child(self)
		screen.add_child(self)
	screen.move_child(self, screen.get_child_count() - 1)   # ОСТАННЯ дитина — завжди
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = true; _armed = true

func disarm() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false; _armed = false

# курсор у ЛОКАЛЬНИХ координатах ловця == екранних (ловець на весь екран)
func _probe(p: Vector2) -> Dictionary:
	return ZoneHit.pick(_data, _st, _screen_id, _surfaces, _ctx, p)

func _gui_input(e: InputEvent) -> void:
	if not _armed: return
	if e is InputEventMouseButton:
		var mb := e as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed:
			cancelled.emit(); accept_event(); return
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				var h: Dictionary = _probe(mb.position)
				if h["strength"] >= 0.0:
					used.emit(h["zone"], h["strength"]); accept_event(); return
			# ПОРОЖНІЙ КЛІК З ІНСТРУМЕНТОМ: не з'їдаємо — це початок/кінець оберту речі
			_forward_to_orbit(mb); return
	elif e is InputEventMouseMotion:
		var h2: Dictionary = _probe((e as InputEventMouseMotion).position)
		hover.emit(h2["zone"], h2["strength"])
		_forward_to_orbit(e)          # тягнути й обертати можна З інструментом у руці
```

**Чому окремий Control, а не `_input`:**
`_input` спрацьовує **до** GUI, тобто інструмент з'їдав би події ще до того, як їх побачить
хоч одна кнопка, і жоден `accept_event()` уже не допоміг би розрулити. Порядок Godot:
`_input` → **GUI (`_gui_input`)** → `_shortcut_input` → `_unhandled_key_input` → `_unhandled_input`.
Ловець стоїть у GUI-фазі, тобто грає за тими самими правилами, що й кнопки, і його
пріоритет задається однією зрозумілою річчю — порядком дітей.

**Три яруси, і це весь контракт порядку:**

```
Main
├── screens[...]                  ← кожен екран
│   ├── фон, спрайти, хотспоти    (опитуються ОСТАННІМИ)
│   └── ToolCatcher               ← остання дитина екрана: б'є все всередині екрана
└── chrome                        ← додається ПІСЛЯ всіх екранів: пояс інструментів,
    ├── tool_belt                   навігація, підказка, лупа-спрайт.
    ├── nav_row                     Б'є ловця, бо це пізніша дитина Main.
    └── hint_label
```

GUI-пікінг іде **зворотним порядком дітей**, тому «пізніший = вищий». `z_index` на
мишачий пікінг Control **не впливає** — він лише про порядок малювання, і покладатись на
нього тут не можна. Кнопки навігації живуть у `chrome`, а не всередині екрана — тому
вийти зі столу з лупою в руці можна завжди, а ловець при цьому ловить усю площу під ними.
`main.gd` уже так тримає `hint_label` і `set_down_btn` — ярус лише формалізується.

**Наслідок для 3D-оберту:** `_unhandled_input` не отримає рух миші, поки ловець активний.
Тому ловець сам пересилає драг у `_forward_to_orbit()` — обертати чашу з лупою в руці
мусить бути можна, це половина відчуття речі.

**Курсор:** `Input.set_custom_mouse_cursor(tool.cursor, Input.CURSOR_ARROW, tool.cursor_hotspot)`
при взятті інструмента, `null` при відкладанні. Курсор — мальований PNG із ToolDef.
Коли `strength >= 0` — `main.gd` міняє курсор на «активний» варіант того ж арту.
Жодних кодом намальованих кілець.

**Гаряче правило:** ловець НЕ знає про факти. Він знає координати й видає зону.
Що з цього вийде — вирішує `RuleEngine`.

---

## 4. НОТАТНИК

### 4.1. Порядок

Порядок фактів = `state.fact_order`, тобто **порядок здобуття**, і він ніколи не сортується
заново. Це не косметика: гравець упізнає власний шлях, а «на підставі чого» пропонує
факти в тому ж порядку, у якому він їх бачив.

Групування в розділи (`marks` / `body` / `metal` / `papers`) — це **вигляд**, не стан:
`Notebook.pages()` фільтрує `fact_order` за групою, зберігаючи відносний порядок.

```gdscript
class_name Notebook extends RefCounted

static func lines(st: CaseState, data, group: StringName = &"") -> Array[StringName]:
	var out: Array[StringName] = []
	for f in st.fact_order:
		var d: Dictionary = data.FACTS.get(f, {})
		if d.is_empty(): continue                        # факт із майбутньої справи — тихо ігноруємо
		if d.get("group", &"") == &"strat": continue     # картки живуть на своїй сторінці
		if group != &"" and d.get("group", &"") != group: continue
		out.append(f)
	return out
```

### 4.2. Вирізки арту (crop)

Малюємо шматок наявної картини — не малюємо піксель.

```gdscript
static func crop_of(data, tex_bank: Dictionary, fid: StringName) -> Texture2D:
	var d: Dictionary = data.FACTS.get(fid, {})
	if not d.has("crop"): return null
	var c: Dictionary = d["crop"]
	var src: Texture2D = tex_bank.get(c["tex"], null)
	if src == null: return null
	var sz := Vector2(src.get_width(), src.get_height())
	var uv: Rect2 = c["uv"]
	var at := AtlasTexture.new()
	at.atlas = src
	at.region = Rect2(uv.position * sz, uv.size * sz)   # частки → пікселі джерела
	at.filter_clip = true                                # без підтікання сусіднього пікселя
	return at
```

Картка в нотатнику = `TextureRect` із цим `AtlasTexture` + `Label` із `tr(text_key)` на
мальованій підкладці `note_card.png`. Пропорції вирізки зберігаються
(`stretch_mode = KEEP_ASPECT_CENTERED`) — розтягнута вирізка читається як брак.

`AtlasTexture` не копіює зображення в пам'ять: це посилання на регіон уже завантаженої
текстури. Тому нотатник із 14 вирізок коштує нуль додаткової VRAM.

### 4.3. Стратиграфія

Окрема сторінка. Три (у справі 8) картки з `strat: true`, які гравець тягне у три гнізда.
Порядок гравця — `state.strat_order`. Перевірка декларативна, у даних справи:

```gdscript
func check_strat(st: CaseState, data) -> bool:
	if st.strat_locked: return true
	if st.strat_order.size() != data.STRAT_TRUTH.size(): return false
	for i in st.strat_order.size():
		if st.strat_order[i] != data.STRAT_TRUTH[i]: return false
	st.strat_locked = true
	st.add_fact(data.STRAT_GIVES)     # «гравіювання нанесено ПІСЛЯ зачистки»
	return true
```

Неправильний порядок **не карається й не коментується**: картки просто лишаються лежати.
Ніякого червоного. Гейт §6 CLAUDE.md: гра не каже відповідь до атестата.

---

## 5. АТЕСТАТ

### 5.1. Гейти

```gdscript
static func gate_open(st: CaseState, s: Dictionary) -> bool:
	if not st.has_all(s.get("needs", [])): return false
	if not st.has_any(s.get("needs_any", [])): return false
	for other in s.get("needs_slot", []):
		if not st.cvals.has(other) or String(st.cvals[other]) == "": return false
	return true
```

Закритий гейт показує **`tr(s.hint_key)` в дужках**, і підказка каже, чого бракує
діегетично («звір клеймо в реєстрі»), а не що вписати. Це та сама «діегетична драбина»
з CLAUDE.md §6 — не кнопка «підказка».

### 5.2. Числова графа

Мальоване поле на бланку + чотири цифри шрифтом. Ввід: клавіатура (0–9, Backspace) або
клік по мальованих цифрових клавішах — обидва шляхи пишуть у той самий `state.set_slot`.

```gdscript
func number_input(sid: StringName, digit: int, s: Dictionary) -> void:
	var cur: int = int(st.cvals.get(sid, 0))
	var nxt: int = cur * 10 + digit
	if nxt > int(s["max"]) : nxt = digit          # переповнення → починаємо число заново
	st.set_slot(sid, nxt)
```

Заповненою графа вважається лише при `digits` цифрах у діапазоні `[min, max]`.
**Жодної перевірки на правильність, жодного кольору, жодного звуку відмови.**
`1872` і `1806` виглядають однаково до самого ранку.

### 5.3. Перетягування фактів

Штатний drag&drop Godot — і прев'ю теж мальоване (та сама картка нотатника).

```gdscript
# картка в нотатнику
func _get_drag_data(_p: Vector2) -> Variant:
	var ghost: Control = build_card(fact_id)          # той самий мальований арт
	ghost.modulate.a = 0.85
	set_drag_preview(ghost)
	return {"kind": &"fact", "id": fact_id}

# гніздо графи «на підставі»
func _can_drop_data(_p: Vector2, d: Variant) -> bool:
	if st.sealed: return false
	if typeof(d) != TYPE_DICTIONARY or d.get("kind") != &"fact": return false
	var cur: Array = st.cvals.get(&"s.basis", [])
	if cur.has(d["id"]): return false                          # дубль у графі — ні
	return cur.size() < int(SLOT_BASIS["max_count"])

func _drop_data(_p: Vector2, d: Variant) -> void:
	var cur: Array = (st.cvals.get(&"s.basis", []) as Array).duplicate()
	cur.append(d["id"])
	st.set_slot(&"s.basis", cur)
```

Витягнути факт назад — тягнути картку з гнізда в нотатник (`kind: &"basis_slot"`).
Зміна `s.provenance` чистить `s.basis` (`clears_on`) — інакше доказ лишається
прив'язаним до знятого твердження.

### 5.4. Печатка

```gdscript
func can_seal(st: CaseState, data) -> bool:
	for s in data.SLOTS:
		if not st.slot_filled(s): return false
	return true

func do_seal(st: CaseState, data) -> void:
	if st.sealed or not can_seal(st, data): return
	st.sealed = true
	st.outcome_id = RuleEngine.resolve_outcome(st, data)
	st.world["seals_set"] = int(st.world["seals_set"]) + 1
	(st.world["cases_sealed"] as Array).append({
		"case": st.case_id, "outcome": st.outcome_id,
		"cvals": st.cvals.duplicate(true)})
	st.sealed_now.emit()
	SaveIO.write(st)              # незворотність мусить пережити краш
```

Після печатки: жодного зеленого, жодного «CASE CLOSED», дві секунди тиші.
Кнопка «повернути без атестата» — окремий вихід (`world.returned_unsealed += 1`),
жива в кожній справі, і саме тому гросбух у §3 SIUZHET б'є.

---

## 6. ЗБЕРЕЖЕННЯ

JSON, не бінар: id фактів іще перейменовуються, і збереження має читатись очима й diff-итись.

```gdscript
class_name SaveIO extends RefCounted

const VERSION := 4
const PATH := "user://save_0.json"

static func write(st: CaseState) -> void:
	var d := {
		"version": VERSION,
		"saved_at": Time.get_unix_time_from_system(),
		"case_id": String(st.case_id),
		"day": st.day, "tod": String(st.tod),
		"facts": _sn_to_str(st.fact_order),          # ПОРЯДОК здобуття — частина стану
		"zone_state": _dict_to_str(st.zone_state),
		"fired": st.fired.keys().map(func(k): return String(k)),
		"flags": st.flags.duplicate(true),
		"tool_owned": st.tool_owned.keys().map(func(k): return String(k)),
		"tool_uses": _dict_to_str(st.tool_uses),
		"strat_order": _sn_to_str(st.strat_order), "strat_locked": st.strat_locked,
		"cvals": _cvals_out(st.cvals),
		"sealed": st.sealed, "outcome": String(st.outcome_id),
		"world": st.world.duplicate(true),
	}
	var tmp := PATH + ".tmp"                          # атомарний запис: temp → rename
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	f.store_string(JSON.stringify(d, "\t")); f.close()
	DirAccess.rename_absolute(ProjectSettings.globalize_path(tmp),
		ProjectSettings.globalize_path(PATH))

# JSON знає лише String — StringName туди й назад ганяємо явно, без сюрпризів
static func _sn_to_str(a: Array) -> Array:
	return a.map(func(x): return String(x))

static func _dict_to_str(d: Dictionary) -> Dictionary:
	var o := {}
	for k in d: o[String(k)] = (String(d[k]) if d[k] is StringName else d[k])
	return o

static func _cvals_out(c: Dictionary) -> Dictionary:
	var o := {}
	for k in c:
		var v: Variant = c[k]
		o[String(k)] = (_sn_to_str(v) if v is Array else
			(String(v) if v is StringName else v))
	return o
```

**Міграції.** Кожна піднімає рівно на одну версію; ланцюг проганяється поспіль.

```gdscript
const FACT_ALIAS := {                     # перейменування id — не втрата проходження
	"found_marks": "f.mark_hoffmann",
	"found_church": "f.strat_engrave",
	"f.density_896": "f.density_101",     # виправлення історичної помилки з V5
}

static func _m2to3(d: Dictionary) -> Dictionary:
	d["facts"] = (d.get("facts", []) as Array).map(
		func(x): return FACT_ALIAS.get(x, x))
	d["version"] = 3; return d

# Callable не буває константою в GDScript — міграції розводяться match'ем, не таблицею
static func _migrate_once(d: Dictionary, from_v: int) -> Dictionary:
	match from_v:
		2: return _m2to3(d)
		3: return _m3to4(d)
	return d

static func read() -> Dictionary:
	if not FileAccess.file_exists(PATH): return {}
	var raw = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if typeof(raw) != TYPE_DICTIONARY: return {}
	var d: Dictionary = raw
	var v: int = int(d.get("version", 1))
	while v < VERSION:
		var nd: Dictionary = _migrate_once(d, v)
		if int(nd.get("version", v)) == v: break     # міграції нема — далі не мучимось
		d = nd; v = int(d["version"])
	if v != VERSION:
		push_warning("save v%d не мігрує до v%d — старт із чистого" % [v, VERSION]); return {}
	return d
```

**Правила відновлення, які не можна порушувати:**
- невідомий id факта/зони/правила при завантаженні — **пропускається з `push_warning`**,
  а не валить гру: збереження з попереднього білда мусить відкриватись;
- `fired` відновлюється **до** `facts`, інакше правило «спрацює вдруге» під час синку;
- `cvals` числових слотів читаються як `int`, факт-слоти — як `Array[StringName]`;
- після завантаження — рівно один `_sync_view()`, який будує ВЕСЬ вигляд зі стану;
- автозапис: на печатку, на зміну дня, на вихід із справи. Не на кожен факт.

---

## 7. ПАСТКИ І КОНКРЕТНІ РІШЕННЯ

### 7.1. Порядок вводу
**Пастка.** `z_index` не керує мишачим пікінгом Control; пікінг іде зворотним порядком
дітей. Ловець «зверху за z_index» тихо не ловитиме — а ловець, покладений останнім і
без ярусу `chrome`, навпаки з'їсть навігацію, і гравець замкнеться на екрані з лупою в руці.
**Рішення.** три яруси з §3: `chrome` (остання дитина Main) > `ToolCatcher` (остання дитина
екрана) > вміст екрана. `arm()` робить `move_child(catcher, get_child_count()-1)` **щоразу**
в `_sync_view()`, бо екран міг дістати нових дітей. `visible` = «режим інструмента».
Порожній клік і драг ловець пересилає в оберт моделі сам — `_unhandled_input` після GUI
події вже не дістане.
**Перевірка.** `clicktest`: з лупою в руці клік по «back to the desk» веде на стіл;
клік по споду дає факт; драг обертає чашу; клік по порожньому столу не дає нічого.

### 7.2. Скид стану
**Пастка.** Зараз не скидаються: `raking`, кільце каталогу, діти `cert_layer`,
`loupe_held`, `goblet_pivot.rotation`, `mag_btn.visible`, `desk_bg.texture`,
`maker_mat.albedo_texture`, `key_light`. Кожен — окремий рядок у `_reset_run`, і кожен
новий інструмент додасть свій.
**Рішення.** `_load_case(id)` створює **новий** `CaseState` і викликає `_sync_view()`.
`_sync_view()` виводить УВЕСЬ вигляд зі стану: текстура столу — з `state.tool_active`,
пластина дна — з `zone_st(&"z.foot.underside")`, кут світла — з `flags.raking`,
позначка каталогу — з `has(&"f.reg_hoffmann_1859_1871")`. Обробники стану не мутують вигляд.
**Перевірка.** `_load_case(1)` двічі поспіль → знімки збігаються попіксельно.
Це буквальний критерій кроку 2 з PUZZLES_V4 §8.

### 7.3. Дублі фактів
**Пастка.** «≥2 факти» в графі «на підставі» тихо ламається, якщо той самий факт має два id
(лупа зі столу і лупа з рук), або якщо один id додається двічі й лічильник рахує два.
**Рішення.** `CaseState.add_fact()` — **єдине** місце народження факта, повертає `bool`.
Звук, спалах картки, репліка — тільки на `true`. `_can_drop_data` відсікає дубль у графі.
Правило дає факти лише через `add_fact`; `RuleEngine.apply()` збирає `Array` реально нових.
**Перевірка.** безголовий прогін: «дві дороги до `f.mark_hoffmann`» → `fact_order.size()`
не змінюється після другої.

### 7.4. Кеш імпорту й `BitMap`
**Пастка.** `texture.get_image()` повертає `null` або стиснене сміття, коли текстура
імпортована з VRAM-стисненням → `create_from_image_alpha` валить клік-маски силуетів.
**Рішення.** для всіх `ov_*.png` в `.import`: `compress/mode=0` (Lossless),
`detect_3d/compress_to=0`, `mipmaps/generate=false`. У `_load()` — `assert(im != null)`
з іменем файлу в повідомленні, щоб зламаний імпорт падав одразу, а не через годину.
Після зміни `.import` — видалити `.godot/imported/` і переімпортувати; інакше редактор
віддасть старий кеш і «нічого не змінилось».
Маска перевіряється в частках спрайта (`Surface.fixed(btn_rect, img_size)`), не екрана.

### 7.5. Локалізація
**Пастка.** `cvals` з англійськими рядками = перша ж локалізація ламає вироки, бо
`_outcome_text()` порівнює `begins_with("Vienna")`.
**Рішення.** `cvals` тримає **тільки id** (`&"o.vienna_hoffmann"`). На папір лягає
`tr("opt.o.vienna_hoffmann")`. OUTCOMES матчить id. Тексти — у `loc/en.csv`, `loc/uk.csv`,
підключені через `internationalization/locale/translations`.
На арті — **жодного напису**: усе шрифтом поверх мальованої поверхні (CLAUDE.md §1).
Шрифт V1 (Playfair+Marck merged) мусить мати кирилицю й пунктуацію — інакше UA-локаль
дасть квадрати; перевірка `font.has_char()` по алфавіту в `_ready()` під `OS.is_debug_build()`.
Ключі — `snake.case`, ніколи не англійський текст як ключ.

### 7.6. Ще п'ять, які коштують дешево зараз і дорого потім
- **`load()` ніколи в `_process` і ніколи на натискання.** Зараз `_toggle_raking()`
  вантажить PNG на кожен клік. Усе — в `tex` у `_load()`; свопи беруть із словника.
- **`Callable` не серіалізується.** Правила, гейти й виходи — тільки декларативні
  словники. `set_meta("mark", Callable)` (факт за відкриття екрана) викидається на кроці 3.
- **Dwell скидається на зміну екрана й інструмента**, інакше «недодивився, вийшов,
  зайшов — і факт з'явився».
- **`get_process_delta_time()` для dwell**, не `Time` — інакше пауза й фон вікна
  накручують секунди.
- **Порядок словника — не контракт.** Godot зберігає порядок вставки, але покладатись
  на нього в `ZONES`/`RULES` не можна: перекриття вирішує сила зони, вибір правила —
  явний `id`, порядок фактів — `fact_order`.

---

## 8. КРИТЕРІЙ ПРИЙМАННЯ РУШІЯ

1. `data/case_02.gd` пишеться без єдиного рядка в `core/*` і `main.gd`.
   Довелось торкнутись рушія — архітектура протекла (крок 9 PUZZLES_V4 §8).
2. Повний безголовий прогін `walk` справи 1 дає той самий набір фактів, що й до рефакторингу.
3. `_load_case(1)` двічі → знімки попіксельно ідентичні.
4. Збереження версії N−1 відкривається й дограється.
5. Свіжий агент-казуал формулює суперечність своїми словами (гейт якості §8 PUZZLES_V4).
