# Тест рушія зон. Запуск:
#   godot --headless --path . --script res://tools/test_zones.gd
# Перший рядок звіту — СКІЛЬКИ перевірок виконано (правило 17 CLAUDE.md):
# нуль падінь при нулі перевірок — це поломка тесту, а не чистий результат.
extends SceneTree

const Z := preload("res://core/zones.gd")

var checks := 0
var fails: Array[String] = []

func ok(cond: bool, name: String) -> void:
	checks += 1
	if not cond: fails.append(name)

func _init() -> void:
	_test_reachable()
	_test_image_rect()
	_test_inside_2d()
	_test_pick_priority()
	_test_instances()

	print("ZONES_TEST перевірок=", checks, " падінь=", fails.size())
	for f in fails: print("  ✗ ", f)
	if fails.is_empty(): print("ZONES_TEST_OK")
	quit(1 if fails.size() > 0 else 0)


# ── 2.2: зона під закритою кришкою недосяжна (через це справа 3 не проходилась) ──
func _test_reachable() -> void:
	var lid_inside := {"screen": &"HANDS", "requires_state": {&"z.watch.lid": &"open"}}
	ok(not Z.reachable(lid_inside, {&"z.watch.lid": &"default"}, {}),
		"закрита кришка мусить ховати зону під собою")
	ok(Z.reachable(lid_inside, {&"z.watch.lid": &"open"}, {}),
		"відкрита кришка мусить відкривати зону")
	ok(not Z.reachable(lid_inside, {}, {}),
		"зона без запису про стан кришки — недосяжна, а не досяжна за замовчуванням")

	# 2.1: гейт по стану світу
	var night := {"needs_flag": {&"tod": &"night"}}
	ok(not Z.reachable(night, {}, {&"tod": &"day"}), "денна кімната ховає нічну зону")
	ok(Z.reachable(night, {}, {&"tod": &"night"}), "нічна зона відкривається вночі")
	ok(Z.reachable({}, {}, {}), "зона без умов досяжна завжди")


# ── кадр зображення: COVER і CONTAIN дають РІЗНІ рамки ──────────────────────
func _test_image_rect() -> void:
	var scr := Vector2(1920, 1080)          # 16:9
	var tex := Vector2(1000, 1000)          # квадрат

	var cov := Z.image_rect(tex, scr, true)
	ok(is_equal_approx(cov.size.x, 1920.0) and is_equal_approx(cov.size.y, 1920.0),
		"COVER мусить накрити екран цілком")
	ok(cov.position.y < 0.0, "COVER квадрата в широкому екрані вилазить угору й униз")

	var con := Z.image_rect(tex, scr, false)
	ok(is_equal_approx(con.size.y, 1080.0), "CONTAIN мусить вписатися по висоті")
	ok(con.position.x > 0.0, "CONTAIN лишає поля з боків")

	# вироджений випадок не має ділити на нуль
	var bad := Z.image_rect(Vector2.ZERO, scr, true)
	ok(bad.size == scr, "нульова текстура не валить рушій")


# ── коло мусить лишатися колом: радіус — частка ШИРИНИ ─────────────────────
func _test_inside_2d() -> void:
	var z := {"u": Vector2(0.5, 0.5), "r": 0.1}
	var aspect := 0.5      # зображення вдвічі ширше, ніж вище

	ok(Z.inside_2d(Vector2(0.5, 0.5), z, aspect), "центр зони — влучання")
	ok(Z.inside_2d(Vector2(0.59, 0.5), z, aspect), "по горизонталі 0.09 < 0.10 — влучання")
	ok(not Z.inside_2d(Vector2(0.61, 0.5), z, aspect), "по горизонталі 0.11 > 0.10 — промах")
	# по вертикалі радіус у частках висоти = r*aspect = 0.05
	ok(Z.inside_2d(Vector2(0.5, 0.54), z, aspect), "по вертикалі 0.04 < 0.05 — влучання")
	ok(not Z.inside_2d(Vector2(0.5, 0.56), z, aspect),
		"по вертикалі 0.06 > 0.05 — промах. Якщо тут влучання — коло стало еліпсом")

	var r := {"u": Vector2(0.5, 0.5), "shape": &"rect", "half": Vector2(0.3, 0.05)}
	ok(Z.inside_2d(Vector2(0.79, 0.54), r, aspect), "прямокутник: кут усередині")
	ok(not Z.inside_2d(Vector2(0.81, 0.5), r, aspect), "прямокутник: за краєм по x")


# ── дрібна зона всередині великої мусить вигравати ──────────────────────────
func _test_pick_priority() -> void:
	var zones := {
		&"z.page": {"screen": &"NEWS", "u": Vector2(0.5, 0.5), "shape": &"rect", "half": Vector2(0.5, 0.5)},
		&"z.notice": {"screen": &"NEWS", "u": Vector2(0.5, 0.5), "shape": &"rect", "half": Vector2(0.05, 0.05)},
		&"z.other": {"screen": &"DESK", "u": Vector2(0.5, 0.5), "r": 0.4},
	}
	var frame := Rect2(Vector2.ZERO, Vector2(1000, 1000))
	ok(Z.pick_2d(Vector2(500, 500), zones, "NEWS", frame, 1.0, {}, {}) == "z.notice",
		"вигравати мусить НАЙМЕНША зона, інакше до дрібної деталі не дотягнутись")
	ok(Z.pick_2d(Vector2(500, 500), zones, "DESK", frame, 1.0, {}, {}) == "z.other",
		"зони чужого екрана не беруться")
	ok(Z.pick_2d(Vector2(5000, 500), zones, "NEWS", frame, 1.0, {}, {}) == "",
		"клік поза кадром зображення — не зона")

	# недосяжна зона не має вигравати, навіть якщо вона найменша
	var gated := zones.duplicate(true)
	gated[&"z.notice"]["needs_flag"] = {&"tod": &"night"}
	ok(Z.pick_2d(Vector2(500, 500), gated, "NEWS", frame, 1.0, {}, {&"tod": &"day"}) == "z.page",
		"недосяжна дрібна зона мусить пропустити хід більшій, а не з'їсти клік")

	# площі кола і прямокутника мусять порівнюватись В ОДНИХ ОДИНИЦЯХ: при aspect 0.5
	# коло r=0.1 займає 0.1×0.2 частки зображення (площа ≈0.02) і ПРОГРАЄ прямокутнику
	# half=(0.09,0.09) (площа ≈0.008), хоч r*r < half.x*half.y казало б протилежне
	var mixed := {
		&"z.circle": {"screen": &"MIX", "u": Vector2(0.5, 0.5), "r": 0.1},
		&"z.rect": {"screen": &"MIX", "u": Vector2(0.5, 0.5), "shape": &"rect", "half": Vector2(0.09, 0.09)},
	}
	ok(Z.pick_2d(Vector2(500, 500), mixed, "MIX", frame, 0.5, {}, {}) == "z.rect",
		"коло r=0.1 при aspect 0.5 ШИРШЕ за прямокутник 0.09 — виграти мусить прямокутник")


# ── 2.3: сім оголошень із одного запису ─────────────────────────────────────
func _test_instances() -> void:
	var one := Z.expand_instances("z.news.notice",
		{"u": Vector2(0.2, 0.3), "step": Vector2(0.1, 0.0), "instances": 7, "r": 0.02})
	ok(one.size() == 7, "instances: 7 мусить дати сім зон")
	ok(one.has("z.news.notice_1") and one.has("z.news.notice_7"), "нумерація з 1 до 7")
	ok(is_equal_approx(one["z.news.notice_3"]["u"].x, 0.4), "третій екземпляр зсунуто на 2 кроки")
	ok(not one["z.news.notice_3"].has("instances"), "у розгорнутої зони поля instances бути не має")
	ok(Z.expand_instances("z.solo", {"u": Vector2.ZERO}).size() == 1,
		"зона без instances лишається однією")
