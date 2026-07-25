extends Control
# Збірка перевіряється автоматично після кожної правки цього файлу
# (хук PostToolUse → .claude/verify_build.sh: імпорт Godot + walk c + chapters).
# ============================================================
#  БЮРО АТРИБУЦІЇ — Справа 1 «Срібний келих»
#  Справжня взаємодія: наводиш на річ — світиться; клікаєш річ — діє.
#  Порожній клік нічого не робить. Атестат замкнено, поки не дослідив.
#  Увесь видимий піксель — арт; код лише рухає готові картинки.
# ============================================================

const ART := "res://art/"
const AUD := "res://audio/"
var tex := {}
var aud := {}
var fr: FontFile
var fb: FontFile
var fh: FontFile
var amb: AudioStreamPlayer
var W := 1280.0
var H := 720.0

# положення речей на столі (частками екрана): x, y, w, h
# СЦЕНА ШАРАМИ ЗА КАРТОЮ РОЗШАРУВАННЯ: порожній стіл (фон) + КОЖЕН предмет
# окремим мальованим спрайтом зі своєю тінню, покладеним на стіл. Просто.
var OBJ := {
	"goblet": [0.4229, 0.1559, 0.1705, 0.5160],
	"mag":    [0.5420, 0.5140, 0.2120, 0.2980],
	"folder": [0.0774, 0.4450, 0.3400, 0.4460],
}
# РЕДАКТОР РОЗКЛАДКИ (F2 на столі): тягни предмети мишкою, колесо = розмір,
# F2 ще раз = зберегти у res://layout.cfg — гра завжди вантажить його при старті.
const LAYOUT_PATH := "res://layout.cfg"
var obj_btns := {}
var edit_mode := false
var edit_key := ""
var edit_off := Vector2.ZERO

# --- стан розслідування ---
var found_marks := false     # роздивився клеймо майстра під лупою
var matched_maker := false   # знайшов збіг у довіднику (Відень)
var read_news := false       # прочитав газету (пограбування ризниці)
var read_docs := false       # прочитав справу (лист клієнтки / свідчення)
var found_wear := false      # справа 2: знос заводної голівки (ліва рука)
var found_chain := false     # справа 2: свіжі подряпини на вушку (ланцюжок перечіпляли)
var raking := false          # косе світло увімкнене (в руках)
var found_church := false    # під косим світлом побачив стерту церковну монограму
var sealed := false
var tod := "day"             # день / вечір / ніч
var lamp_on := true          # лампа на столі
var saw_figure := false      # гравець уже помітив постать у вікні
var client_seen := false     # клієнтка вже віддала річ
var case_done := false       # справу запечатано
var seals_set := 0           # скільки печаток гравець поставив (мета-лічильник із DESIGN)

var screens := {}
var goblet_pivot: Node3D
var hint_label: Label

# --- клеймо на нозі чаші (виміряно з моделі) ---
const MARK_P := Vector3(-0.0573, -0.6053, 0.4636)
const MARK_N := Vector3(0.1588, -0.2086, 0.965)
const MARK_SIZE := 0.235
const MARK_OFF := 0.006
const LOUPE_MAG := 4.3          # у скільки разів лупа збільшує (чесний множник)
const PLATE_UV := 0.60          # частка пластини, що лягає на дно (менше = марки крупніші)
# тримальна лупа (фронтальна, ПОВНА ручка): скло — коло; CX,R — частки ШИРИНИ, CY — частка ВИСОТИ
const GLASS_CX := 0.3127
const GLASS_CY := 0.3343
const GLASS_R := 0.3073
const LOUPE_ZOOM := 3.4
# ЛУПА НА СТОЛІ: семплить ОРИГІНАЛ картини столу (5504x3072), НЕ екран (720p) —
# екранна текстура не може дати більше деталей, ніж екран; оригінал дає 4.3x запас → різко.
const DESK_LOUPE_SHADER := "shader_type canvas_item;\nuniform sampler2D src : filter_linear;\nuniform vec2 center = vec2(0.5);\nuniform vec2 span = vec2(0.1);\nvoid fragment(){ vec2 uv = clamp(center + (UV-vec2(0.5))*span, vec2(0.001), vec2(0.999)); vec4 c = texture(src, uv); float d = length(UV-vec2(0.5)); c.rgb *= mix(1.0, 0.80, smoothstep(0.30, 0.50, d)); c.rgb = mix(c.rgb, c.rgb*vec3(0.95,1.02,0.97), 0.24); float sheen = smoothstep(0.42, 0.0, length(UV-vec2(0.35,0.29)))*0.13; c.rgb += vec3(sheen); c.a *= smoothstep(0.5,0.452,d); COLOR = c; }"
const DETAIL_MASK_SHADER := "shader_type canvas_item;\nvoid fragment(){ vec4 c = texture(TEXTURE, UV); float d = length(UV-vec2(0.5)); c.rgb *= mix(1.0, 0.86, smoothstep(0.34, 0.50, d)); float sheen = smoothstep(0.42, 0.0, length(UV-vec2(0.35,0.29)))*0.10; c.rgb += vec3(sheen); c.a *= smoothstep(0.5,0.452,d); COLOR = c; }"
# лежача лупа тепер ВРЕНДЕРЕНА в сцену (ov_mag = вирізка з тінню, у перспективі столу),
# тому «жива лінза» більше не потрібна — вона й давала ефект «втопленого в стіл» кільця.
# зона огляду: лупа над нею → у склі чітка деталь (клеймо)
const FOOT_ZONE := Rect2(0.43, 0.55, 0.14, 0.18)   # частками екрана (нога чаші в HANDS)

# --- лупа: на столі — екранне збільшення; у руках — СПРАВЖНЄ 3D-збільшення клейма ---
var main_cam3: Camera3D
var hallmark_node: Node3D
var loupe_ui: Control
var loupe_glass: ColorRect       # екранне збільшення (стіл)
var loupe_vp: SubViewport        # 3D-в'юпорт зі спільним світом чаші
var loupe_cam: Camera3D          # зум-камера на реальне клеймо
var loupe_vp_tex: TextureRect    # показує 3D-в'юпорт у склі
var key_light: DirectionalLight3D    # основне тепле світло (косе світло змінює його кут)
var maker_mat: StandardMaterial3D    # матеріал клейма майстра (під косим світлом приглушується)
var rake_btn: Button                 # кнопка «косе світло» в руках
var hands_glass_btn: Button          # «взяти скло» просто в руках
var set_down_btn: Button
var loupe_held := false
var loupe_lw := 0.0
var loupe_lh := 0.0
var tex_comp: Texture2D    # композит стола З предметами — джерело скла лупи
var cup_dragging := false
var tex_loupe: Texture2D
var found_time := 0.0
var mag_btn: Button           # хотспот лупи на столі — ховаємо, коли взяли в руки
var gob_btn: TextureButton
var folder_btn: TextureButton
var desk_bg: TextureRect      # тло столу (свопимо: з лупою ↔ без лупи)
var cat_screen: Control
var cat_m := Vector2.ZERO
var cat_mr := 0.0

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE   # щоб рух миші доходив до _unhandled_input (оберт 3D)
	var vp := get_viewport_rect().size
	W = vp.x; H = vp.y
	_load()
	_load_layout()
	_build_desk()
	_build_hands()
	_build_docs()
	_build_news()
	_build_catalog()
	_build_cert()
	_build_ledger()
	_build_case2()
	CSLOTS = (CASES[1] as Dictionary)["slots"]
	# верхня підказка (діегетична — на мальованій стрічці нема, тож тонкий текст)
	hint_label = Label.new()
	hint_label.label_settings = _ls(fr, int(H*0.028), Color(0.95,0.91,0.80))
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.size = Vector2(W, H*0.05); hint_label.position = Vector2(0, H*0.02)
	hint_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hint_label)
	_build_loupe()
	_build_menu(); _build_hub(); _build_client(); _build_chapters()
	move_child(hint_label, get_child_count()-1)   # підказки завжди поверх сцен
	_show("MENU")
	amb.play()
	if "loupeshot" in OS.get_cmdline_user_args():
		_dbg_loupe()
	if "autosolve" in OS.get_cmdline_user_args():
		_dbg_autosolve()
	if "walk" in OS.get_cmdline_user_args():
		_dbg_walk()
	if "chapters" in OS.get_cmdline_user_args():
		_dbg_chapters()
	if "day1" in OS.get_cmdline_user_args():
		_dbg_day1()
	if "case2" in OS.get_cmdline_user_args():
		_dbg_case2()
	if "clicktest" in OS.get_cmdline_user_args():
		_dbg_clicktest()
	if "outcomes" in OS.get_cmdline_user_args():
		_dbg_outcomes()

var dbg_mode := false

# СПРАВЖНІ кліки через справжній input-конвеєр (маски, перекриття) — не синтетичні сигнали
func _click_at(p: Vector2) -> void:
	for pressed in [true, false]:
		var e := InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT; e.pressed = pressed
		e.position = p; e.global_position = p
		get_viewport().push_input(e, true)
		await get_tree().process_frame
	await get_tree().process_frame

func _shown() -> String:
	for k in screens:
		if screens[k].visible: return k
	return "?"

func _center(key: String) -> Vector2:
	var r: Array = OBJ[key]
	return Vector2((r[0]+r[2]*0.5)*W, (r[1]+r[3]*0.5)*H)

func _dbg_outcomes() -> void:
	var cases := [
		["Vienna — Hoffmann workshop","struck over an older, effaced mark","taken from a church","the effaced church mark beneath","ПРАВИЛЬНО+доказ"],
		["Vienna — Hoffmann workshop","struck over an older, effaced mark","taken from a church","the client's own word","крадена БЕЗ доказу"],
		["Vienna — Hoffmann workshop","struck but once, and clean","honestly, by inheritance","the client's own word","пропустив крадене"],
		["Prague — court silver","struck but once, and clean","by a path I cannot vouch for","the client's own word","дрібні хиби"],
	]
	print("OUTCOMES")
	for c in cases:
		cvals = [c[0],c[1],c[2],c[3]]
		print("[", c[4], "] -> ", _outcome_text().substr(0, 60), "...")
	get_tree().quit()

# ПОВНИЙ ДЕНЬ 1 очима гравця: меню → кабінет → клієнтка → стіл → атестат → вечір
func _dbg_chapters() -> void:
	dbg_mode = true
	var dir := _shotdir()
	await get_tree().process_frame
	_show("CHAPTERS"); await _shot(dir+"ch_00_menu.png")
	var ok := true
	for chp in CHAPTERS:
		var key: String = chp[1]
		_goto(key)
		for _i in 3: await RenderingServer.frame_post_draw
		var sh := _shown()
		if sh == "?" or sh == "MENU": ok = false
		print("CH ", key, " -> ", sh)
		await _shot(dir+"ch_"+key+".png", 2)
	print("CHAPTERS_OK all_reachable=", ok)
	get_tree().quit()

func _dbg_day1() -> void:
	dbg_mode = true
	var dir := _shotdir()
	await get_tree().process_frame
	_show("MENU"); await _shot(dir+"d1_01_menu.png")
	_enter_hub(); await _shot(dir+"d1_02_hub_day.png")
	_hub_window(); await _shot(dir+"d1_03_window.png")
	_hub_lamp(); await _shot(dir+"d1_04_lamp_off_day.png")
	_hub_lamp()
	_show("CLIENT"); await _shot(dir+"d1_05_client.png")
	_client_next(); await _shot(dir+"d1_06_client2.png")
	_client_next(); _client_next(); _client_next()   # → клієнтка йде, кабінет
	await _shot(dir+"d1_07_hub_case.png")
	_hub_desk(); await _shot(dir+"d1_08_desk.png")
	# справа вже перевірена окремо — беремо зачіпки й пишемо вирок
	found_marks = true; matched_maker = true; read_news = true; found_church = true; read_docs = true
	_show("CERT"); await _shot(dir+"d1_09_cert.png")
	_choose(0, "Vienna — Hoffmann workshop"); _choose(1, "struck over an older, effaced mark")
	_choose(2, "taken from a church"); _choose(3, "the effaced church mark beneath")
	await _do_verdict()
	for _i in 20: await RenderingServer.frame_post_draw
	_show_morning(); await _shot(dir+"d1_10_morning.png", 5)
	_evening(); await _shot(dir+"d1_11_hub_evening.png")
	_hub_window(); await _shot(dir+"d1_12_window_figure.png")
	_hub_lamp(); await _shot(dir+"d1_13_darkness.png")
	_hub_lamp()
	_hub_desk(); await _shot(dir+"d1_14_ledger.png", 4)
	print("DAY1_OK seals=", seals_set, " tod=", tod, " screen=", _shown())
	get_tree().quit()

func _dbg_case2() -> void:
	dbg_mode = true
	var dir := _shotdir()
	await get_tree().process_frame
	_start_case(2)
	_show("DESK2"); await _shot(dir+"c2_01_desk.png")
	_show("TESTIMONY"); await _shot(dir+"c2_02_statements.png")
	_show("WATCH_WEAR"); await _shot(dir+"c2_03_crown.png")
	_show("WATCH_CHAIN"); await _shot(dir+"c2_04_bow.png")
	_show("CERT"); await _shot(dir+"c2_05_cert.png")
	_choose(0, "a left-handed man"); _choose(1, "lately taken off and put back")
	_choose(2, "the widow"); _choose(3, "the crown worn on its left side")
	await _shot(dir+"c2_06_cert_full.png")
	await _do_verdict()
	for _i in 20: await RenderingServer.frame_post_draw
	_show_morning()
	await _shot(dir+"c2_07_morning.png", 6)
	_show("LEDGER"); await _shot(dir+"c2_08_ledger.png", 4)
	print("CASE2_OK wear=", found_wear, " chain=", found_chain, " docs=", read_docs, " sealed=", sealed, " seals=", seals_set)
	get_tree().quit()

func _dbg_clicktest() -> void:
	dbg_mode = false   # потрібен справжній _process/_input
	await get_tree().process_frame
	for _i in 4: await RenderingServer.frame_post_draw
	var log := "CLICKTEST\n"
	# 1. стіл: клік по теці → DOCS
	_show("DESK"); await get_tree().process_frame
	await _click_at(_center("folder"))
	log += "folder -> " + _shown() + " (треба DOCS)\n"
	# 2. стіл: клік по келиху → HANDS
	_show("DESK"); await get_tree().process_frame
	await _click_at(_center("goblet"))
	for _i in 30: await get_tree().process_frame   # чекаємо lift-твін
	log += "goblet -> " + _shown() + " (треба HANDS)\n"
	# 3. стіл: клік по лупі → взяти в руки (loupe_held)
	_show("DESK"); await get_tree().process_frame
	await _click_at(_center("mag"))
	log += "mag -> loupe_held=" + str(loupe_held) + " (треба true)\n"
	if loupe_held: _drop_loupe()
	# 4. з DOCS → газета
	_show("DOCS"); await get_tree().process_frame
	# знайти txtbtn «Open the newspaper»
	var opened := "?"
	for c in screens["DOCS"].get_children():
		if c is Button and (c as Button).text.contains("newspaper"):
			await _click_at((c as Button).position + (c as Button).size*0.5)
			opened = _shown()
	log += "newspaper link -> " + opened + " (треба NEWS)\n"
	# 5. каталог: клік по правильній комірці
	_show("CATALOG"); found_marks = true; await get_tree().process_frame
	await _click_at(cat_m)
	log += "catalog cell -> matched_maker=" + str(matched_maker) + " (треба true)\n"
	print(log)
	get_tree().quit()
# каталог знімків для верифікації: env G3_SHOTDIR (абсолютний шлях) або user://
func _shotdir() -> String:
	var d := OS.get_environment("G3_SHOTDIR")
	if d == "": d = OS.get_user_data_dir()
	if not d.ends_with("/"): d += "/"
	DirAccess.make_dir_recursive_absolute(d)
	return d

func _build_loupe() -> void:
	tex_loupe = load("res://art/loupe.png")
	tex_comp = load("res://art/desk_composite.jpg")
	loupe_lw = W*0.24
	loupe_lh = loupe_lw*float(tex_loupe.get_height())/float(tex_loupe.get_width())
	loupe_ui = Control.new(); loupe_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	loupe_ui.size = Vector2(loupe_lw, loupe_lh); loupe_ui.visible = false
	var gr: float = GLASS_R*loupe_lw*2.0
	var gpos := Vector2(GLASS_CX*loupe_lw-gr*0.5, GLASS_CY*loupe_lh-gr*0.5)
	loupe_glass = ColorRect.new()
	loupe_glass.size = Vector2(gr, gr); loupe_glass.position = gpos
	var sh := Shader.new(); sh.code = DESK_LOUPE_SHADER
	var mat := ShaderMaterial.new(); mat.shader = sh
	mat.set_shader_parameter("src", tex_comp)
	loupe_glass.material = mat; loupe_glass.mouse_filter = Control.MOUSE_FILTER_IGNORE
	loupe_ui.add_child(loupe_glass)
	loupe_vp_tex = TextureRect.new(); loupe_vp_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	loupe_vp_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	loupe_vp_tex.size = Vector2(gr, gr); loupe_vp_tex.position = gpos
	var sh2 := Shader.new(); sh2.code = DETAIL_MASK_SHADER
	var mat2 := ShaderMaterial.new(); mat2.shader = sh2
	loupe_vp_tex.material = mat2; loupe_vp_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE; loupe_vp_tex.visible = false
	loupe_ui.add_child(loupe_vp_tex)
	var spr := TextureRect.new(); spr.texture = tex_loupe; spr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	spr.size = Vector2(loupe_lw, loupe_lh); spr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	loupe_ui.add_child(spr)
	add_child(loupe_ui)
	set_down_btn = _txtbtn(self, "◦ set the glass down  (right-click)", Vector2(W*0.655, H*0.045), func(): _drop_loupe(), 0.026)
	set_down_btn.visible = false

func _pickup_loupe() -> void:
	loupe_held = true; loupe_ui.visible = true; set_down_btn.visible = true
	if mag_btn: mag_btn.visible = false          # лупу взяли в руки — зі столу вона зникає
	if hands_glass_btn: hands_glass_btn.visible = false
	if desk_bg: desk_bg.texture = tex["case_desk"]   # той самий стіл, але без лупи
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN   # ховаємо курсор — лупа сама вказівник, не затуляє клеймо
	_play("ui_soft"); _set_hint("")

# F2 = редактор розкладки · правий клік = «покласти назад»
func _input(event: InputEvent) -> void:
	if dbg_mode: return
	if event is InputEventKey and (event as InputEventKey).pressed and (event as InputEventKey).keycode == KEY_F1:
		if loupe_held: _drop_loupe()
		_show("CHAPTERS"); get_viewport().set_input_as_handled(); return
	if event is InputEventKey and (event as InputEventKey).pressed and (event as InputEventKey).keycode == KEY_F2:
		_edit_toggle(); get_viewport().set_input_as_handled(); return
	if edit_mode:
		_edit_input(event); return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed:
			if loupe_held:
				_drop_loupe(); get_viewport().set_input_as_handled()
			elif screens.has("HANDS") and screens["HANDS"].visible:
				_play("goblet_set"); _show("DESK"); get_viewport().set_input_as_handled()

# ---------- РЕДАКТОР РОЗКЛАДКИ ----------
func _edit_toggle() -> void:
	if not edit_mode:
		if loupe_held: _drop_loupe()
		_show("DESK")
		edit_mode = true
		_set_hint("EDIT · drag an item, wheel = size, F2 = save")
	else:
		edit_mode = false; edit_key = ""
		_save_layout()
		_set_hint("Layout saved to layout.cfg")

func _edit_pick(p: Vector2) -> String:
	for k in ["folder", "mag", "goblet"]:
		var b: TextureButton = obj_btns[k]
		if Rect2(b.position, b.size).has_point(p): return k
	return ""

func _edit_sync(k: String) -> void:
	var b: TextureButton = obj_btns[k]
	OBJ[k] = [b.position.x/W, b.position.y/H, b.size.x/W, b.size.y/H]

func _edit_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				edit_key = _edit_pick(mb.position)
				if edit_key != "": edit_off = mb.position - (obj_btns[edit_key] as TextureButton).position
			else:
				edit_key = ""
			get_viewport().set_input_as_handled()
		elif mb.pressed and (mb.button_index == MOUSE_BUTTON_WHEEL_UP or mb.button_index == MOUSE_BUTTON_WHEEL_DOWN):
			var k := _edit_pick(mb.position)
			if k != "":
				var f := 1.04 if mb.button_index == MOUSE_BUTTON_WHEEL_UP else 0.9615
				var b: TextureButton = obj_btns[k]
				var c := b.position + b.size*0.5
				b.size *= f; b.position = c - b.size*0.5; b.pivot_offset = b.size*0.5
				_edit_sync(k)
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and edit_key != "":
		(obj_btns[edit_key] as TextureButton).position = (event as InputEventMouseMotion).position - edit_off
		_edit_sync(edit_key)
		get_viewport().set_input_as_handled()

func _load_layout() -> void:
	var cf := ConfigFile.new()
	if cf.load(LAYOUT_PATH) != OK: return
	for k in OBJ.keys():
		if cf.has_section_key("layout", k):
			OBJ[k] = cf.get_value("layout", k)

func _save_layout() -> void:
	var cf := ConfigFile.new()
	for k in OBJ.keys():
		cf.set_value("layout", k, OBJ[k])
	cf.save(LAYOUT_PATH)

func _drop_loupe() -> void:
	loupe_held = false; loupe_ui.visible = false; set_down_btn.visible = false
	loupe_vp_tex.visible = false; loupe_glass.visible = true
	if mag_btn: mag_btn.visible = true           # поклали лупу — вона знову на столі
	if hands_glass_btn: hands_glass_btn.visible = true
	if desk_bg: desk_bg.texture = tex["case_desk_loupe"]
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE; _play("ui_soft"); _set_hint("")
	if loupe_vp: loupe_vp.render_target_update_mode = SubViewport.UPDATE_DISABLED

func _loupe_frame() -> void:
	var mp: Vector2 = get_viewport().get_mouse_position()
	if not cup_dragging:
		loupe_ui.position = mp - Vector2(GLASS_CX*loupe_lw, GLASS_CY*loupe_lh)
	var gc: Vector2 = loupe_ui.position + Vector2(GLASS_CX*loupe_lw, GLASS_CY*loupe_lh)
	var in_hands: bool = screens.has("HANDS") and screens["HANDS"].visible and loupe_vp != null and main_cam3 != null
	if in_hands:
		# ПРОСТА ЛУПА: живий зум того, що під нею; куди навести — справа гравця, без прив'язок
		loupe_vp_tex.texture = loupe_vp.get_texture()
		loupe_glass.visible = false; loupe_vp_tex.visible = true
		loupe_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		_aim_loupe(gc)
		_check_underside(gc)
	else:
		# НА СТОЛІ: різке збільшення з ОРИГІНАЛУ картини (не з екрана)
		loupe_vp_tex.visible = false; loupe_glass.visible = true
		if loupe_vp: loupe_vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
		_glass_desk(gc)

# скло над столом: екранна точка gc → uv в ОРИГІНАЛІ case_desk (інверсія COVERED-мапінгу)
func _glass_desk(gc: Vector2) -> void:
	var iw: float = float(tex["case_desk"].get_width()); var ih: float = float(tex["case_desk"].get_height())
	var sc: float = maxf(W/iw, H/ih)
	var dw: float = iw*sc; var dh: float = ih*sc
	var off := Vector2((W-dw)*0.5, (H-dh)*0.5)
	var gr: float = GLASS_R*loupe_lw*2.0
	var mat: ShaderMaterial = loupe_glass.material
	mat.set_shader_parameter("center", Vector2((gc.x-off.x)/dw, (gc.y-off.y)/dh))
	mat.set_shader_parameter("span", Vector2(gr/(dw*LOUPE_ZOOM), gr/(dh*LOUPE_ZOOM)))

func _aim_loupe(gc: Vector2) -> void:
	# ЛУПА = РІВНО LOUPE_MAG× збільшення того, що під курсором.
	# Той самий fov, що в головної камери, але вдвічі ближче → чесний, передбачуваний зум.
	var ro: Vector3 = main_cam3.project_ray_origin(gc)
	var rn: Vector3 = main_cam3.project_ray_normal(gc)
	var dist: float = maxf(ro.length() - 0.5, 0.2)     # відстань до поверхні під курсором
	var hit: Vector3 = ro + rn*dist
	loupe_cam.fov = main_cam3.fov
	loupe_cam.global_position = hit - rn*(dist/LOUPE_MAG)
	loupe_cam.look_at(hit, Vector3.UP)

func _underside_facing() -> bool:
	if not hallmark_node or not main_cam3: return false
	var wpos: Vector3 = hallmark_node.global_position
	var wn: Vector3 = (-hallmark_node.global_transform.basis.y).normalized()   # спід дивиться в -Y
	return wn.dot((main_cam3.global_position - wpos).normalized()) > 0.12

func _check_underside(gc: Vector2) -> void:
	if not hallmark_node or not main_cam3: return
	if found_marks and found_church: return
	# лупа над дном (щедрий радіус — марки все одно на пластині перед очима)
	var over: bool = _underside_facing() and main_cam3.unproject_position(hallmark_node.global_position).distance_to(gc) < loupe_lw*0.7
	if over:
		found_time += get_process_delta_time()
		if found_time > 0.5:
			if not found_marks:
				found_marks = true; found_time = 0.0; _play("page_turn")
				_set_hint("A struck maker's mark — a Vienna shield. But the silver beside it is scored, as if an older mark were ground away.")
			elif raking and not found_church:
				found_church = true; _play("page_turn")
				_set_hint("Where the silver was ground smooth, the raking light finds it: an engraved chalice — a church's mark.")
	else:
		found_time = maxf(0.0, found_time - get_process_delta_time())

func _process(_delta: float) -> void:
	if loupe_held and loupe_ui and not dbg_mode:
		_loupe_frame()

func _dbg_autosolve() -> void:
	dbg_mode = true
	await get_tree().process_frame
	for _i in 4: await RenderingServer.frame_post_draw
	# зібрані зачіпки (кожну ставить своя дія: лупа/довідник/газета/косе світло — перевірено окремо)
	found_marks = true; read_news = true; matched_maker = true; found_church = true
	_show("CERT")
	for _i in 6: await RenderingServer.frame_post_draw
	_choose(0, "Vienna — Hoffmann workshop")
	_choose(1, "struck over an older, effaced mark")
	_choose(2, "taken from a church")
	_choose(3, "the effaced church mark beneath")
	for _i in 4: await RenderingServer.frame_post_draw
	await _do_verdict()
	for _i in 12: await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(_shotdir()+"dbg_verdict.png")
	get_tree().quit()

# ПОКАДРОВИЙ ПРОХІД: граємо справу РЕАЛЬНИМИ обробниками, кадр після кожного кроку.
# 3 запуски (стан між ними не тягнеться): walk a (стіл/2D) · walk b (руки/3D) · walk c (папери/вердикт)
func _shot(path: String, pre := 6) -> void:
	for _i in pre: await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(path)

func _walk_glass(gc: Vector2) -> void:
	loupe_ui.position = gc - Vector2(GLASS_CX*loupe_lw, GLASS_CY*loupe_lh)
	_glass_desk(gc)

func _dbg_walk() -> void:
	dbg_mode = true
	var args := OS.get_cmdline_user_args()
	var dir := _shotdir()
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().process_frame
	if "a" in args:
		_show("DESK"); await _shot(dir+"01_desk.png")
		_hover_in(gob_btn, "The silver goblet — take it in hand"); await _shot(dir+"02_hover_goblet.png")
		_hover_out(gob_btn); _set_hint("The glass — take it up and look closer"); await _shot(dir+"03_hover_glass.png")
		_set_hint(""); _pickup_loupe()
		_walk_glass(Vector2(W*0.30, H*0.63)); await _shot(dir+"04_loupe_papers.png")
		_walk_glass(Vector2(W*0.50, H*0.42)); await _shot(dir+"05_loupe_goblet.png")
		_drop_loupe(); await _shot(dir+"06_loupe_down.png")
		_show("DOCS"); await _shot(dir+"07_docs.png")
		_show("NEWS"); await _shot(dir+"08_news.png")
		_show("CATALOG"); _cat_miss(); await _shot(dir+"09_catalog_gated.png")
		print("WALK_A_OK read_news=", read_news)
	elif "b" in args:
		_show("HANDS"); await _shot(dir+"10_hands_upright.png", 5)
		goblet_pivot.rotation.x = -0.9; await _shot(dir+"11_hands_midturn.png", 5)
		goblet_pivot.rotation.x = -1.6; await _shot(dir+"12_hands_flipped.png", 5)
		_pickup_loupe()
		loupe_vp_tex.texture = loupe_vp.get_texture()
		loupe_glass.visible = false; loupe_vp_tex.visible = true
		loupe_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		# позиції марок рахуємо з UV пластини: (u-0.5)/(0.5*PLATE_UV) * rad → локальні координати дна
		var RAD := 0.34
		var maker_p: Vector3 = hallmark_node.global_transform * Vector3(-0.85*RAD, 0.0, 0.10*RAD)
		var church_p: Vector3 = hallmark_node.global_transform * Vector3(0.667*RAD, 0.0, 0.067*RAD)
		var gc: Vector2 = main_cam3.unproject_position(maker_p)
		loupe_ui.position = gc - Vector2(GLASS_CX*loupe_lw, GLASS_CY*loupe_lh)
		for _i in 100:
			_aim_loupe(gc); _check_underside(gc); await RenderingServer.frame_post_draw
			if found_marks: break
		await _shot(dir+"13_loupe_marks.png", 5)
		# КОСЕ СВІТЛО: лупа на ЗІШЛІФОВАНУ ділянку — там проступає затерта церковна мітка
		_toggle_raking()
		var gc2: Vector2 = main_cam3.unproject_position(church_p)
		loupe_ui.position = gc2 - Vector2(GLASS_CX*loupe_lw, GLASS_CY*loupe_lh)
		for _i in 140:
			_aim_loupe(gc2); _check_underside(gc2); await RenderingServer.frame_post_draw
			if found_church: break
		await _shot(dir+"13b_loupe_church.png", 8)
		print("WALK_B_OK found_marks=", found_marks, " found_church=", found_church)
	elif "c" in args:
		found_marks = true; read_news = true; found_church = true; read_docs = true   # здобуто в A і B
		_show("CATALOG"); _cat_click(cat_screen, cat_m, cat_mr); await _shot(dir+"14_catalog_match.png")
		_show("CERT"); await _shot(dir+"15_cert_open.png")
		# бланк-речення: заповнюємо всі 4 слоти, останній — доказ проти невинної версії
		_choose(0, "Vienna — Hoffmann workshop"); await _shot(dir+"15a_slot_origin.png")
		_choose(1, "struck over an older, effaced mark")
		_choose(2, "taken from a church"); await _shot(dir+"16_cert_provenance.png")
		_choose(3, "the effaced church mark beneath"); await _shot(dir+"18_cert_full.png")
		_do_verdict()
		for _i in 12: await RenderingServer.frame_post_draw
		await _shot(dir+"19_seal_mid.png", 2)
		var guard := 0
		while not (screens.has("MORNING") and screens["MORNING"].visible) and guard < 500:
			await RenderingServer.frame_post_draw; guard += 1
		for _i in 8: await RenderingServer.frame_post_draw
		await _shot(dir+"20_morning.png", 2)
		_show("LEDGER"); await _shot(dir+"21_ledger.png", 4)
		print("WALK_C_OK sealed=", sealed, " seals=", seals_set, " shown=", _shown())
	get_tree().quit()

func _dbg_loupe() -> void:
	dbg_mode = true
	await get_tree().process_frame
	var args := OS.get_cmdline_user_args()
	if "gobshot" in args:
		# спрайт чаші з 3D: той самий обʼєкт, що в руках; прозорий фон = ідеальна альфа
		var svp: SubViewport = goblet_pivot.get_parent()
		var shot := SubViewport.new(); shot.size = Vector2i(1500, 2000)
		shot.world_3d = svp.world_3d; shot.transparent_bg = true; shot.msaa_3d = Viewport.MSAA_4X
		shot.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		add_child(shot)
		var cam := Camera3D.new(); shot.add_child(cam); cam.fov = 30.0
		# кут як у сцени столу (~33° згори) — чаша СТОЇТЬ, а не лежить
		cam.global_position = Vector3(0.03, 2.20, 3.60)
		cam.look_at(Vector3(0.0, 0.02, 0.0), Vector3.UP)
		_show("HANDS")
		for _i in 10: await RenderingServer.frame_post_draw
		shot.get_texture().get_image().save_png(_shotdir()+"goblet_3d.png")
		get_tree().quit(); return
	if "measure" in args:
		# де насправді спід ніжки: глобальні верти чаші, найнижчі та центральна колонка
		var inst := goblet_pivot.get_child(0)
		var lowest := 999.0; var cy := 999.0; var chi := -999.0
		for m in inst.find_children("*","MeshInstance3D",true,false):
			var mi := m as MeshInstance3D
			if mi.mesh == null: continue
			var t := mi.global_transform
			for si in mi.mesh.get_surface_count():
				var arr: Array = mi.mesh.surface_get_arrays(si)
				var vs: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
				for v in vs:
					var wv: Vector3 = t * v
					if wv.y < lowest: lowest = wv.y
					if Vector2(wv.x, wv.z).length() < 0.08:
						if wv.y < cy: cy = wv.y
						if wv.y > chi: chi = wv.y
		print("MEASURE lowest_y=", lowest, " center_col_min_y=", cy, " center_col_max_y=", chi)
		# ПРОФІЛЬ споду: найнижчий Y у кільцях за радіусом (де площинка, де вже схил)
		var nb := 12; var rmin := PackedFloat32Array(); var rmax := PackedFloat32Array()
		for i in nb: rmin.append(999.0); rmax.append(-999.0)
		for m in inst.find_children("*","MeshInstance3D",true,false):
			var mi := m as MeshInstance3D
			if mi.mesh == null: continue
			var t := mi.global_transform
			for si in mi.mesh.get_surface_count():
				var arr: Array = mi.mesh.surface_get_arrays(si)
				var vs: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
				for v in vs:
					var wv: Vector3 = t * v
					var rr: float = Vector2(wv.x, wv.z).length()
					var bi: int = int(rr/0.04)
					if bi < nb and wv.y < 0.0:
						if wv.y < rmin[bi]: rmin[bi] = wv.y
		for i in nb:
			print("MEASURE r[", i*0.04, "-", (i+1)*0.04, "] underside_y=", rmin[i])
		get_tree().quit(); return
	# --- перевірка столу: лупа має зникнути зі столу, коли взята в руки ---
	if "desk" in args or "picked" in args:
		_show("DESK")
		if "picked" in args:
			_pickup_loupe()
			_walk_glass(Vector2(W*0.505, H*0.40))   # скло над чашею — видно збільшення з композита
		for _i in 8: await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(_shotdir()+"dbg_loupe.png")
		get_tree().quit(); return
	_show("HANDS")
	# РЕАЛІСТИЧНИЙ кут перевороту (як гравець рукою), не ідеально рівний спід
	var flip := -1.6
	if "deepflip" in args: flip = -1.95
	if not ("upright" in args):
		goblet_pivot.rotation.x = flip
	for _i in 8: await RenderingServer.frame_post_draw
	if not ("flip" in args) and not ("upright" in args):
		# лупу «беремо» і ставимо НЕТОЧНО над клеймом (імітація мишки), далі — РЕАЛЬНА логіка кадру
		loupe_held = true; loupe_ui.visible = true
		loupe_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		var mp: Vector2 = main_cam3.unproject_position(hallmark_node.global_position) + Vector2(38, 30)
		loupe_ui.position = mp - Vector2(GLASS_CX*loupe_lw, GLASS_CY*loupe_lh)
		if loupe_vp_tex.texture == null: loupe_vp_tex.texture = loupe_vp.get_texture()
		loupe_glass.visible = false; loupe_vp_tex.visible = true
		var gc: Vector2 = loupe_ui.position + Vector2(GLASS_CX*loupe_lw, GLASS_CY*loupe_lh)
		_aim_loupe(gc)
		for _i in 10: await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(_shotdir()+"dbg_loupe.png")
	get_tree().quit()

func _load() -> void:
	for n in ["case_desk","case_desk_loupe","atestat_flat_blank","newspaper_final","catalog_final","stamp_top_cut","wax_stick","seal_cut","ov_goblet","ov_goblet_click","ov_folder","ov_folder_click"]:
		tex[n] = load(ART + n + ".png")
	tex["mark_maker"] = load(ART + "mark_ref_v3.png")   # еталон клейма майстра = той самий щит, що комірка r3c8 каталогу
	# детальні кадри дна для лупи: звичайне світло (клеймо+зішліфована ділянка) і косе світло (церковна мітка)
	tex["foot_plate_maker"] = load(ART + "foot_plate_maker.png")
	tex["foot_plate_church"] = load(ART + "foot_plate_church.png")
	# справа 2 «Спадок удови»
	for n3 in ["hub_day","hub_day_case","hub_lamp_off","hub_evening","hub_evening_figure","hub_night","hub_darkness","menu_door","client_woman","client_in_room","subtitle_band"]:
		if ResourceLoader.exists(ART + n3 + ".png"): tex[n3] = load(ART + n3 + ".png")
	for n2 in ["case2_desk","watch_wear","watch_chain"]:
		if ResourceLoader.exists(ART + n2 + ".png"): tex[n2] = load(ART + n2 + ".png")
	# опційний арт (додано 24.07): чистий лист клієнтки
	if ResourceLoader.exists(ART + "letter_client.png"):
		tex["letter_client"] = load(ART + "letter_client.png")
	fr = load("res://fonts/PlayfairDisplay.ttf")
	fb = load("res://fonts/PlayfairDisplay-Bold.ttf")
	fh = load("res://fonts/MarckScript.ttf")
	for n in ["stamp_seal","door_bell","page_turn","goblet_set","pen_write","ui_soft"]:
		var p := AudioStreamPlayer.new(); p.stream = load(AUD + n + ".mp3"); add_child(p); aud[n] = p
	amb = AudioStreamPlayer.new()
	var a: AudioStreamMP3 = load(AUD + "ambient_bureau.mp3")
	a.loop = true; amb.stream = a; amb.volume_db = -13.0; add_child(amb)

func _play(n: String) -> void:
	if aud.has(n): aud[n].play()

# ---------- helpers ----------
func _ls(font: FontFile, sz: int, col: Color) -> LabelSettings:
	var s := LabelSettings.new(); s.font = font; s.font_size = sz; s.font_color = col; return s

func _bg(parent: Control, t: Texture2D, cover := true) -> TextureRect:
	var tr := TextureRect.new(); tr.texture = t
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED if cover else TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.set_anchors_preset(Control.PRESET_FULL_RECT); tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(tr); return tr

func _veil(parent: Control, c := Color(0.04,0.03,0.03,1)) -> void:
	var r := ColorRect.new(); r.color = c; r.set_anchors_preset(Control.PRESET_FULL_RECT)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE; parent.add_child(r)

# папір лежить на СТОЛІ, а не в чорній порожнечі: притемнений стіл як тло (код лише дімить готовий арт)
func _paper_backdrop(parent: Control, dim := 0.26) -> void:
	var b := _bg(parent, tex["case_desk"], true)
	b.modulate = Color(dim, dim*0.94, dim*1.08)

func _screen(name: String) -> Control:
	var c := Control.new(); c.set_anchors_preset(Control.PRESET_FULL_RECT); c.visible = false
	add_child(c); screens[name] = c; return c

func _show(name: String) -> void:
	# папери на весь екран — скло кладеться саме (воно інструмент столу і рук)
	if loupe_held and name != "DESK" and name != "HANDS":
		_drop_loupe()
	cup_dragging = false   # не тягнемо чашу крізь зміну екрана (інакше лупа завмирає)
	for k in screens: screens[k].visible = (k == name)
	if hint_label: hint_label.text = ""
	if name == "CERT":
		if not sealed: active_slot = _next_open_slot()
		_refresh_cert()
	if name == "NEWS" and not read_news:
		read_news = true
	if name == "CLIENT":
		_client_show()
	if name == "DOCS" and not read_docs:
		read_docs = true
	if name == "LEDGER":
		_show_ledger()
	if name == "TESTIMONY" and not read_docs:
		read_docs = true
	if screens.has(name) and screens[name].has_meta("mark"):
		var mk: Callable = screens[name].get_meta("mark")
		mk.call(); _play("page_turn")

func _set_hint(t: String) -> void:
	if hint_label: hint_label.text = t

# інтерактивна РІЧ: мальований оверлей, що світиться на наведення і діє на клік
func _object(parent: Control, key: String, ov: Texture2D, hint: String, action: Callable, lift := false, mask: Texture2D = null) -> TextureButton:
	var b := TextureButton.new()
	b.texture_normal = ov
	b.ignore_texture_size = true
	b.stretch_mode = TextureButton.STRETCH_SCALE
	var r: Array = OBJ[key]
	b.position = Vector2(W*r[0], H*r[1]); b.size = Vector2(W*r[2], H*r[3])
	b.pivot_offset = b.size*0.5
	# КЛІК-МАСКА ЗА ФОРМОЮ: річ обирається лише по своєму силуету, не по прямокутнику
	var mim: Image = (mask if mask != null else ov).get_image()
	if mim != null:
		var bmp := BitMap.new(); bmp.create_from_image_alpha(mim, 0.5)
		b.texture_click_mask = bmp
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.modulate = Color(1,1,1,1)
	b.mouse_entered.connect(_hover_in.bind(b, hint))
	b.mouse_exited.connect(_hover_out.bind(b))
	b.pressed.connect(_obj_press.bind(b, key, action, lift))
	obj_btns[key] = b
	parent.add_child(b); return b

# ХОТСПОТ ЛУПИ: сама лупа ВБУДОВАНА в кадр столу; тут лише невидима зона кліку.
# Наведення підсвічує НЕ спрайт (нема чого), а весь кадр столу з лупою — свопом на теплішу версію
# не робимо; просто курсор-рука + підказка. Жодних плоских вирізок і напівпрозорих країв.
const MAG_RECT := Rect2(0.588, 0.435, 0.215, 0.300)   # bbox вбудованої лупи (частки кадру)
func _mag_hotspot(parent: Control) -> Button:
	var b := Button.new(); b.flat = true; b.modulate.a = 0
	# кадр столу вписаний COVERED — переводимо частки зображення в екранні координати
	var t: Texture2D = tex["case_desk_loupe"]
	var iw: float = float(t.get_width()); var ih: float = float(t.get_height())
	var sc: float = maxf(W/iw, H/ih); var dw: float = iw*sc; var dh: float = ih*sc
	var off := Vector2((W-dw)*0.5, (H-dh)*0.5)
	b.position = off + Vector2(MAG_RECT.position.x*dw, MAG_RECT.position.y*dh)
	b.size = Vector2(MAG_RECT.size.x*dw, MAG_RECT.size.y*dh)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.mouse_entered.connect(_set_hint.bind("The glass — take it up and look closer"))
	b.mouse_exited.connect(_set_hint.bind(""))
	b.pressed.connect(func(): _play("ui_soft"); _pickup_loupe())
	parent.add_child(b); return b

func _hover_in(b: TextureButton, hint: String) -> void:
	create_tween().tween_property(b, "modulate", Color(1.7,1.7,1.7,1), 0.12)
	_set_hint(hint)

func _hover_out(b: TextureButton) -> void:
	create_tween().tween_property(b, "modulate", Color(1,1,1,1), 0.12)
	_set_hint("")

func _obj_press(b: TextureButton, key: String, action: Callable, lift: bool) -> void:
	if edit_mode: return
	_play("ui_soft")
	if not lift:
		action.call(); return
	_play("goblet_set")
	var r: Array = OBJ[key]
	var tw := create_tween()
	tw.tween_property(b, "scale", Vector2(1.18,1.18), 0.22)
	tw.parallel().tween_property(b, "position", b.position - Vector2(0, H*0.06), 0.22)
	tw.parallel().tween_property(b, "modulate", Color(2,2,2,0), 0.22)
	tw.tween_callback(_after_lift.bind(b, r, action))

func _after_lift(b: TextureButton, r: Array, action: Callable) -> void:
	b.scale = Vector2(1,1); b.position = Vector2(W*r[0], H*r[1]); b.modulate = Color(1,1,1,1)
	action.call()

# кнопка-текст (навігація) — плаский шрифт на мальованій поверхні
func _txtbtn(parent: Control, txt: String, pos: Vector2, action: Callable, sz := 0.03, col := Color(0.9,0.86,0.76)) -> Button:
	var b := Button.new(); b.flat = true; b.text = txt
	b.add_theme_font_override("font", fr); b.add_theme_font_size_override("font_size", int(H*sz))
	b.add_theme_color_override("font_color", col)
	b.add_theme_color_override("font_hover_color", Color(0.98,0.83,0.4))
	b.add_theme_color_override("font_focus_color", col)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.position = pos; b.pressed.connect(func(): _play("ui_soft"); action.call())
	parent.add_child(b); return b

# ================= МЕНЮ / КАБІНЕТ-ХАБ / КЛІЄНТ =================
var hub_bg: TextureRect
var hub_note: Label

func _band(parent: Control) -> void:
	if not tex.has("subtitle_band"): return
	var b := TextureRect.new(); b.texture = tex["subtitle_band"]
	b.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; b.stretch_mode = TextureRect.STRETCH_SCALE
	b.size = Vector2(W, H*0.165); b.position = Vector2(0, H*0.80)
	b.modulate = Color(1,1,1,0.82); b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(b)

# ================= ВИБІР СЦЕНИ (щоб не проходити з початку) =================
# Точки входу з підготованим станом. Виклик: кнопка в меню або F1 будь-де.
const CHAPTERS := [
	["1 · Morning — the door",        "door"],
	["2 · The client at the counter", "client"],
	["3 · The desk — fresh case",     "desk"],
	["4 · The goblet in your hands",  "hands"],
	["5 · The papers and the press",  "docs"],
	["6 · The mark register",         "catalog"],
	["7 · The certificate — filled",  "cert"],
	["8 · The next morning",          "morning"],
	["9 · Evening — the room",        "evening"],
	["10 · Darkness",                 "dark"],
	["11 · The ledger",               "ledger"],
]

func _reset_run() -> void:
	# чистий стан + прибрати сліди попереднього проходу (віск, «CASE CLOSED», позначки каталогу)
	sealed = false; cvals = ["","","",""]; active_slot = 0
	found_marks = false; matched_maker = false; read_news = false
	found_church = false; read_docs = false; raking = false
	found_wear = false; found_chain = false; found_time = 0.0
	client_line = 0; client_seen = false; case_done = false; saw_figure = false
	lamp_on = true; tod = "day"
	if loupe_held: _drop_loupe()
	if goblet_pivot: goblet_pivot.rotation = Vector3.ZERO
	if maker_mat:
		maker_mat.albedo_texture = load("res://art/foot_plate_maker.png")
		maker_mat.albedo_color = Color(1.30, 1.28, 1.22)
	if key_light: key_light.rotation_degrees = Vector3(-9,-62,0); key_light.light_energy = 1.9
	if rake_btn: rake_btn.text = "⟋  rake the light across the silver"
	if cert_layer:
		for n in ["stamp_hs","cert_msg"]:
			if cert_layer.has_node(n): cert_layer.get_node(n).queue_free()
		for ch in cert_layer.get_children():
			if ch is TextureRect and ch != cert_layer.get_child(0): ch.queue_free()
			elif ch is Label and (ch as Label).text == "CASE CLOSED": ch.queue_free()
	if cat_screen:
		for n2 in ["matchring","matchlbl"]:
			if cat_screen.has_node(n2): cat_screen.get_node(n2).queue_free()

func _found_all() -> void:
	found_marks = true; matched_maker = true; read_news = true
	found_church = true; read_docs = true

func _goto(key: String) -> void:
	_reset_run()
	match key:
		"door":
			_enter_hub()
		"client":
			_show("CLIENT")
		"desk":
			client_seen = true; _show("DESK")
		"hands":
			client_seen = true; _show("HANDS")
		"docs":
			client_seen = true; _show("DOCS")
		"catalog":
			client_seen = true; found_marks = true; _show("CATALOG")
		"cert":
			client_seen = true; _found_all()
			cvals = ["Vienna — Hoffmann workshop","struck over an older, effaced mark",
					 "taken from a church","the effaced church mark beneath"]
			_show("CERT")
		"morning":
			client_seen = true; _found_all(); sealed = true; seals_set = maxi(seals_set, 1)
			cvals = ["Vienna — Hoffmann workshop","struck over an older, effaced mark",
					 "taken from a church","the effaced church mark beneath"]
			_show_morning()
		"evening":
			client_seen = true; case_done = true; tod = "evening"; _enter_hub()
		"dark":
			client_seen = true; case_done = true; tod = "evening"; lamp_on = false
			_enter_hub(); _hub_say("Darkness. And on the shelf, something takes the little light there is — a black casket you do not remember shelving.")
		"ledger":
			client_seen = true; case_done = true; tod = "evening"
			seals_set = maxi(seals_set, 1); _show("LEDGER")
		_:
			_show("MENU")

func _build_chapters() -> void:
	var sc := _screen("CHAPTERS")
	if tex.has("hub_darkness"):
		var b := _bg(sc, tex["hub_darkness"]); b.modulate = Color(0.55,0.55,0.58)
	var h := Label.new(); h.label_settings = _ls(fb, int(H*0.040), Color(0.92,0.86,0.72))
	h.text = "Where would you like to begin?"; h.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	h.size = Vector2(W, H*0.07); h.position = Vector2(0, H*0.055)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE; sc.add_child(h)
	var col := 0; var row := 0
	for chp in CHAPTERS:
		var lbl: String = chp[0]; var key: String = chp[1]
		var bx := W*0.09 + col*W*0.45
		var by := H*0.16 + row*H*0.098
		_txtbtn(sc, lbl, Vector2(bx, by), func(): _goto(key), 0.029)
		row += 1
		if row >= 6: row = 0; col += 1
	_txtbtn(sc, "←  back", Vector2(W*0.09, H*0.90), func(): _show("MENU"), 0.028)

func _build_menu() -> void:
	var s0 := _screen("MENU")
	if tex.has("menu_door"): _bg(s0, tex["menu_door"])
	var t := Label.new(); t.label_settings = _ls(fb, int(H*0.075), Color(0.93,0.87,0.74))
	t.text = "BUREAU OF\nATTRIBUTION"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	t.size = Vector2(W*0.46, H*0.12); t.position = Vector2(W*0.06, H*0.30); t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	s0.add_child(t)
	var sub := Label.new(); sub.label_settings = _ls(fr, int(H*0.026), Color(0.80,0.72,0.58))
	sub.text = "your judgement is what makes a thing real"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	sub.size = Vector2(W*0.46, H*0.05); sub.position = Vector2(W*0.065, H*0.50); sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	s0.add_child(sub)
	_txtbtn(s0, "unlock the door  →", Vector2(W*0.065, H*0.60), func(): _play("door_bell"); _reset_run(); _enter_hub(), 0.034)
	_txtbtn(s0, "choose a scene  →", Vector2(W*0.065, H*0.68), func(): _show("CHAPTERS"), 0.028)

# --- КАБІНЕТ ---
func _hub_tex() -> Texture2D:
	if not lamp_on:
		if tod == "day" and tex.has("hub_lamp_off"): return tex["hub_lamp_off"]
		if tex.has("hub_darkness"): return tex["hub_darkness"]
	if tod == "evening":
		if saw_figure and tex.has("hub_evening_figure"): return tex["hub_evening_figure"]
		if tex.has("hub_evening"): return tex["hub_evening"]
	if tod == "night" and tex.has("hub_night"): return tex["hub_night"]
	if client_seen and not case_done and tex.has("hub_day_case"): return tex["hub_day_case"]
	return tex["hub_day"]

# зона кабінету: частка кадру → екран (кадр вписаний COVERED)
func _hub_rect(fx: float, fy: float, fw: float, fh: float) -> Rect2:
	var t: Texture2D = tex["hub_day"]
	var iw := float(t.get_width()); var ih := float(t.get_height())
	var sc: float = maxf(W/iw, H/ih); var dw := iw*sc; var dh := ih*sc
	var off := Vector2((W-dw)*0.5, (H-dh)*0.5)
	return Rect2(off + Vector2(fx*dw, fy*dh), Vector2(fw*dw, fh*dh))

func _hub_spot(parent: Control, r: Rect2, hint: String, action: Callable) -> void:
	var b := Button.new(); b.flat = true; b.modulate.a = 0
	b.position = r.position; b.size = r.size
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.mouse_entered.connect(func(): _set_hint(hint))
	b.mouse_exited.connect(func(): _set_hint(""))
	b.pressed.connect(func(): _play("ui_soft"); action.call())
	parent.add_child(b)

func _build_hub() -> void:
	var s1 := _screen("HUB")
	hub_bg = _bg(s1, tex["hub_day"])
	# двері · портрет · картотека · годинник · вікно · лампа · стіл
	_hub_spot(s1, _hub_rect(0.00, 0.00, 0.16, 1.00), "The street door", func(): _hub_door())
	_hub_spot(s1, _hub_rect(0.21, 0.02, 0.14, 0.36), "His portrait — it never hangs straight", func(): _hub_say("You straighten it. By evening it is crooked again."))
	_hub_spot(s1, _hub_rect(0.17, 0.40, 0.26, 0.50), "The card index", func(): _hub_say("Row upon row of little drawers, and every one of them opens. Every one but the bottom, which is locked, and no key in this house fits it."))
	_hub_spot(s1, _hub_rect(0.55, 0.00, 0.11, 0.26), "The wall clock", func(): _hub_say("Stopped, and stopped long ago. Nobody in this house has wound it since he left."))
	_hub_spot(s1, _hub_rect(0.66, 0.00, 0.18, 0.62), "The window", func(): _hub_window())
	_hub_spot(s1, _hub_rect(0.78, 0.42, 0.16, 0.40), "The lamp", func(): _hub_lamp())
	_hub_spot(s1, _hub_rect(0.33, 0.68, 0.45, 0.32), "The desk", func(): _hub_desk())
	_band(s1)
	var acts := [
		["the door", func(): _hub_door()],
		["the desk", func(): _hub_desk()],
		["the window", func(): _hub_window()],
		["the card index", func(): _hub_say("Row upon row of little drawers, and every one of them opens. Every one but the bottom, which is locked, and no key in this house fits it.")],
		["his portrait", func(): _hub_say("You straighten it. By evening it is crooked again.")],
		["the clock", func(): _hub_say("Stopped, and stopped long ago. Nobody has wound it since he left.")],
		["the lamp", func(): _hub_lamp()],
	]
	var ax := W*0.045
	for a in acts:
		var lbl: String = a[0]; var cb: Callable = a[1]
		_txtbtn(s1, lbl, Vector2(ax, H*0.925), func(): cb.call(), 0.026)
		ax += lbl.length()*W*0.0088 + W*0.028
	hub_note = Label.new(); hub_note.label_settings = _ls(fr, int(H*0.028), Color(0.92,0.88,0.78))
	hub_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; hub_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hub_note.size = Vector2(W*0.66, H*0.10); hub_note.position = Vector2(W*0.17, H*0.822)
	hub_note.mouse_filter = Control.MOUSE_FILTER_IGNORE; s1.add_child(hub_note)

func _enter_hub() -> void:
	if hub_bg: hub_bg.texture = _hub_tex()
	_show("HUB")
	if not client_seen:
		_hub_say("Someone is waiting at the door.")
	elif not case_done:
		_hub_say("The goblet is on your desk.")
	else:
		_hub_say("The day is done. The ledger lies open on your desk.")

func _hub_say(t: String) -> void:
	if hub_note: hub_note.text = t

func _hub_door() -> void:
	if not client_seen: _play("door_bell"); _show("CLIENT")
	else: _hub_say("The street is empty. The bell will ring again tomorrow.")

func _hub_window() -> void:
	if tod == "day": _hub_say("Fog, and the wet roofs opposite. Nothing else.")
	else:
		saw_figure = true
		if hub_bg: hub_bg.texture = _hub_tex()
		_hub_say("Someone is standing across the street, under the lamp. Watching the bureau. When you look again, they have not moved.")

func _hub_lamp() -> void:
	lamp_on = not lamp_on
	hub_bg.texture = _hub_tex()
	_play("ui_soft")
	if lamp_on: _hub_say("The lamp is lit.")
	elif tod == "day": _hub_say("You put out the lamp. Grey daylight only.")
	else: _hub_say("Darkness. And on the shelf, something takes the little light there is — a black casket you do not remember shelving.")

func _hub_desk() -> void:
	if not client_seen: _hub_say("Nothing on the desk yet. Someone is waiting at the door.")
	elif not case_done: _show("DESK")
	else: _show("LEDGER")

# --- КЛІЄНТКА ---
func _build_client() -> void:
	var s2 := _screen("CLIENT")
	if tex.has("client_in_room"): _bg(s2, tex["client_in_room"])
	elif tex.has("hub_day"): _bg(s2, tex["hub_day"])
	else: _paper_backdrop(s2, 0.16)
	_band(s2)
	var l := Label.new(); l.name = "ctext"; l.label_settings = _ls(fr, int(H*0.030), Color(0.95,0.91,0.82))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; l.size = Vector2(W*0.62, H*0.13); l.position = Vector2(W*0.19, H*0.815)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE; s2.add_child(l)
	_txtbtn(s2, "go on  →", Vector2(W*0.46, H*0.915), func(): _client_next(), 0.030)

var client_line := 0
const CLIENT_LINES := [
	"She sets a cloth bundle on the counter and unwraps it without looking at you.\n\n\"It came to me from an aunt. In the monastery.\"",
	"\"I am told it is Viennese. I should like to know its worth.\"\n\nHer hands go back to the shawl, and stay there.",
	"\"And whether it is mine to sell.\"\n\nShe says this to the desk, not to you.",
	"She leaves the goblet and goes. The bell over the door is still moving when the street has swallowed her.",
]

func _client_next() -> void:
	client_line += 1
	if client_line >= CLIENT_LINES.size():
		client_seen = true
		_play("goblet_set")
		_enter_hub()
		return
	_client_show()

func _client_show() -> void:
	var l: Label = screens["CLIENT"].get_node("ctext")
	l.text = CLIENT_LINES[clampi(client_line, 0, CLIENT_LINES.size()-1)]

# ---------- DESK (стіл-справа) ----------
func _build_desk() -> void:
	var s := _screen("DESK")
	desk_bg = _bg(s, tex["case_desk_loupe"])   # стіл із ВБУДОВАНОЮ лупою (перспектива+тінь у сцені)
	gob_btn = _object(s, "goblet", tex["ov_goblet"], "The silver goblet — take it in hand", func(): _show("HANDS"), true, tex["ov_goblet_click"])
	# лупа — НЕВИДИМИЙ хотспот над вбудованою лупою (жодних плоских вирізок)
	mag_btn = _mag_hotspot(s)
	folder_btn = _object(s, "folder", tex["ov_folder"], "The case papers — read them", func(): _show("DOCS"), false, tex["ov_folder_click"])
	_txtbtn(s, "Write the certificate  →", Vector2(W*0.72, H*0.9), func(): _show("CERT"))
	# рамка задачі (діегетична, без відповіді): три графи атестата = твоя мета
	var intro := Label.new(); intro.label_settings = _ls(fr, int(H*0.028), Color(0.92,0.88,0.78))
	intro.text = "A goblet, and a story that does not sit right.\nExamine it, then write the attribution — and set your name to it."
	intro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.size = Vector2(W*0.64, H*0.12); intro.position = Vector2(W*0.18, H*0.06)
	intro.mouse_filter = Control.MOUSE_FILTER_IGNORE; s.add_child(intro)
	var itw := create_tween(); itw.tween_interval(6.0); itw.tween_property(intro, "modulate:a", 0.0, 2.0)

# ---------- HANDS (чаша в руках — обертати; екранна лупа працює й тут) ----------
func _build_hands() -> void:
	var s := _screen("HANDS")
	s.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var back := _bg(s, tex["case_desk"]); back.modulate = Color(0.20,0.20,0.24)
	var svc := SubViewportContainer.new(); svc.stretch = true
	svc.set_anchors_preset(Control.PRESET_FULL_RECT); svc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	s.add_child(svc)
	var sv := SubViewport.new(); sv.size = Vector2i(int(W), int(H)); sv.transparent_bg = true; sv.msaa_3d = Viewport.MSAA_4X
	svc.add_child(sv); _build_goblet_world(sv)
	# 3D-в'юпорт лупи: СПІЛЬНИЙ світ чаші → зум-камера показує РЕАЛЬНЕ клеймо (не картинку)
	loupe_vp = SubViewport.new(); loupe_vp.size = Vector2i(760,760)
	loupe_vp.world_3d = sv.world_3d; loupe_vp.transparent_bg = true; loupe_vp.msaa_3d = Viewport.MSAA_4X
	loupe_vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(loupe_vp)
	loupe_cam = Camera3D.new(); loupe_vp.add_child(loupe_cam); loupe_cam.fov = 30.0
	loupe_cam.global_position = Vector3(0,-0.75,0.6); loupe_cam.look_at(Vector3(0,-0.75,0), Vector3.UP)
	# діегетична вказівка (не відповідь): перевернути чашу
	var tip := Label.new(); tip.label_settings = _ls(fr, int(H*0.026), Color(0.82,0.78,0.68))
	tip.text = "Drag to turn it — silver is marked underneath.  Rake the light to read a worn mark."
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; tip.size = Vector2(W, H*0.05); tip.position = Vector2(0, H*0.88)
	tip.mouse_filter = Control.MOUSE_FILTER_IGNORE; s.add_child(tip)
	var tw := create_tween(); tw.tween_interval(6.0); tw.tween_property(tip, "modulate:a", 0.0, 1.5)
	_txtbtn(s, "←  set it down", Vector2(W*0.04, H*0.9), func(): _show("DESK"))
	# КОСЕ СВІТЛО (інструмент з опису): нахиляє світло майже врівень → проступає стерта монограма
	rake_btn = _txtbtn(s, "⟋  rake the light across the silver", Vector2(W*0.60, H*0.9), func(): _toggle_raking())
	# скло можна взяти ПРЯМО В РУКАХ — не треба вертатись на стіл по нього
	hands_glass_btn = _txtbtn(s, "◦  take up the glass", Vector2(W*0.29, H*0.9), func(): _pickup_loupe())

func _toggle_raking() -> void:
	raking = not raking
	_play("ui_soft")
	if not key_light: return
	# косе світло міняє САМУ поверхню дна (пластину) — тож без лупи й під лупою знову однаково
	if maker_mat:
		maker_mat.albedo_texture = load("res://art/foot_plate_church.png" if raking else "res://art/foot_plate_maker.png")
		# без пересвіту: гравюра має ЧИТАТИСЬ, а не тонути в білому
		maker_mat.albedo_color = Color(1.38, 1.35, 1.30) if raking else Color(1.30, 1.28, 1.22)
	var lt := create_tween(); lt.set_parallel(true)
	if raking:
		lt.tween_property(key_light, "rotation_degrees", Vector3(-4, -84, 0), 0.5)
		lt.tween_property(key_light, "light_energy", 1.15, 0.5)
		rake_btn.text = "⟋  raking light — on"
		_set_hint("The light lies almost flat across the silver now. Bring the glass close.")
	else:
		lt.tween_property(key_light, "rotation_degrees", Vector3(-9, -62, 0), 0.5)
		lt.tween_property(key_light, "light_energy", 1.9, 0.5)
		rake_btn.text = "⟋  rake the light across the silver"
		_set_hint("")

# ---------- DOCS (тека: лист) ----------
func _build_docs() -> void:
	var s := _screen("DOCS")
	_paper_backdrop(s)
	# лист клієнтки — окремий аркуш (letter_client), без гравюрної рамки й медальйона; висота 0.82, лежить на столі
	var lt: Texture2D = tex["letter_client"] if tex.has("letter_client") else tex["atestat_flat_blank"]
	var lh := H*0.82; var lw := lh*float(lt.get_width())/float(lt.get_height())
	var paper := TextureRect.new(); paper.texture = lt; paper.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	paper.stretch_mode = TextureRect.STRETCH_SCALE; paper.size = Vector2(lw, lh)
	paper.position = Vector2((W-lw)*0.5, (H-lh)*0.5 - H*0.03); paper.mouse_filter = Control.MOUSE_FILTER_IGNORE; s.add_child(paper)
	var t := Label.new(); t.label_settings = _ls(fr, int(lh*0.033), Color(0.20,0.14,0.09))
	t.text = "From the client:\n\n\"This goblet came to me\nfrom an aunt in the monastery.\nI am told it is Viennese.\nI should like to know its worth —\nand whether it is mine to sell.\"\n\nShe would not meet my eye\nas she said it."
	t.position = paper.position + Vector2(lw*0.13, lh*0.15); t.mouse_filter = Control.MOUSE_FILTER_IGNORE; s.add_child(t)
	# навігація — нижній ряд на притемненому столі (геть з паперу), тепла і читабельна
	_txtbtn(s, "←  back to the desk", Vector2(W*0.04, H*0.92), func(): _show("DESK"))
	_txtbtn(s, "Open the newspaper  →", Vector2(W*0.40, H*0.92), func(): _show("NEWS"))
	_txtbtn(s, "Mark catalogue  →", Vector2(W*0.72, H*0.92), func(): _show("CATALOG"))

# ---------- NEWS ----------
func _build_news() -> void:
	var s := _screen("NEWS")
	_paper_backdrop(s)
	var nt: Texture2D = tex["newspaper_final"]
	var nh := H*0.94; var nw := nh*float(nt.get_width())/float(nt.get_height())
	var np := TextureRect.new(); np.texture = nt; np.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	np.stretch_mode = TextureRect.STRETCH_SCALE; np.size = Vector2(nw, nh)
	np.position = Vector2((W-nw)*0.5, (H-nh)*0.5); np.mouse_filter = Control.MOUSE_FILTER_IGNORE; s.add_child(np)
	_txtbtn(s, "←  back", Vector2(W*0.04, H*0.92), func(): _show("DOCS"))

# ---------- CATALOG (клік по гербу) ----------
func _build_catalog() -> void:
	var s := _screen("CATALOG")
	_paper_backdrop(s, 0.22)
	# СТОРІНКА КАТАЛОГУ ліворуч; праворуч — темна панель столу з еталоном і навігацією
	var ct: Texture2D = tex["catalog_final"]
	var pw: float = W*0.70; var ph: float = pw*float(ct.get_height())/float(ct.get_width())
	var px: float = W*0.015; var py: float = (H-ph)*0.5
	var cat := TextureRect.new(); cat.texture = ct; cat.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cat.stretch_mode = TextureRect.STRETCH_SCALE; cat.size = Vector2(pw, ph); cat.position = Vector2(px, py)
	cat.mouse_filter = Control.MOUSE_FILTER_IGNORE; s.add_child(cat)
	# ловець хибних кліків — тільки на площі сторінки
	var miss := Button.new(); miss.flat = true; miss.modulate.a = 0
	miss.position = Vector2(px, py); miss.size = Vector2(pw, ph)
	miss.pressed.connect(_cat_miss); s.add_child(miss)
	# еталон клейма чаші — у правій панелі, у мальованій рамці-інсеті
	var panx: float = px + pw + W*0.02
	var refm := TextureRect.new(); refm.texture = tex["mark_maker"]; refm.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	var rd := H*0.19; refm.size = Vector2(rd, rd*float(tex["mark_maker"].get_height())/float(tex["mark_maker"].get_width()))
	refm.position = Vector2(panx, H*0.12); refm.mouse_filter = Control.MOUSE_FILTER_IGNORE; s.add_child(refm)
	var rl := Label.new(); rl.label_settings = _ls(fr, int(H*0.022), Color(0.92,0.88,0.78))
	rl.text = "This mark is struck on the goblet's foot.\nFind the SAME shield among the marks —\nsome look alike; match it exactly."
	rl.position = Vector2(panx, H*0.12 + refm.size.y + H*0.015)
	rl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; rl.size = Vector2(W-panx-W*0.02, H*0.2)
	rl.mouse_filter = Control.MOUSE_FILTER_IGNORE; s.add_child(rl)
	# хотспот саме на щиті r3c8 (крилата Хі-Ро — точний двійник клейма чаші)
	var hs := Button.new(); hs.flat = true; hs.modulate.a = 0
	var mx: float = px + pw*0.867; var my: float = py + ph*0.612; var mr: float = pw*0.042
	hs.position = Vector2(mx-mr, my-mr); hs.size = Vector2(mr*2, mr*2)
	hs.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	hs.mouse_entered.connect(_cat_hover)
	hs.mouse_exited.connect(_set_hint.bind(""))
	hs.pressed.connect(_cat_click.bind(s, Vector2(mx, my), mr))
	s.add_child(hs)
	cat_screen = s; cat_m = Vector2(mx, my); cat_mr = mr; s.set_meta("panx", panx)
	_txtbtn(s, "Write the certificate  →", Vector2(panx, H*0.80), func(): _show("CERT"))
	_txtbtn(s, "←  back", Vector2(panx, H*0.87), func(): _show("DOCS"))

func _cat_hover() -> void:
	_set_hint("Hold it against the goblet's shield — wings, monogram, letters." if found_marks else "First look at the goblet's own mark under the glass.")

func _cat_miss() -> void:
	if matched_maker: return
	_set_hint("A monogram, but not the same shield — check the wings and letters against the goblet's." if found_marks else "Examine the goblet's mark under the glass first.")

func _cat_click(s: Control, m: Vector2, mr: float) -> void:
	if not found_marks:
		_set_hint("You have not examined the goblet yet."); return
	matched_maker = true; _play("page_turn")
	_set_hint("")
	if not s.has_node("matchlbl"):
		# кільце-обвід навколо знайденої комірки (мальованого немає — тонка діегетична позначка на сторінці)
		var ring := Label.new(); ring.name = "matchring"; ring.label_settings = _ls(fb, int(mr*1.7), Color(0.62,0.11,0.10))
		ring.text = "◯"; ring.position = Vector2(m.x-mr*0.95, m.y-mr*1.15); ring.mouse_filter = Control.MOUSE_FILTER_IGNORE; s.add_child(ring)
		# підтвердження — у правій панелі, не над сторінкою
		var lbl := Label.new(); lbl.name = "matchlbl"; lbl.label_settings = _ls(fb, int(H*0.028), Color(0.72,0.14,0.12))
		lbl.text = "✓ the same mark —\n   Hoffmann, Wien"; lbl.position = Vector2(cat_screen.get_meta("panx"), H*0.46)
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE; s.add_child(lbl)

# ---------- CERTIFICATE ----------
var cert_layer: Control
var opt_layer: Control
var cert_panel: Control    # права панель — читабельний вибір варіантів
func _build_cert() -> void:
	var s := _screen("CERT")
	_paper_backdrop(s, 0.16)
	var at: Texture2D = tex["atestat_flat_blank"]
	var chh: float = H*0.88
	var cwd: float = chh*float(at.get_width())/float(at.get_height())
	# папір ЛІВОРУЧ; праворуч — панель вибору на притемненому столі
	var root := Control.new(); root.size = Vector2(cwd, chh); root.position = Vector2(W*0.055, (H-chh)/2)
	s.add_child(root); cert_layer = root
	var paper := TextureRect.new(); paper.texture = at; paper.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	paper.stretch_mode = TextureRect.STRETCH_SCALE; paper.set_anchors_preset(Control.PRESET_FULL_RECT)
	paper.mouse_filter = Control.MOUSE_FILTER_IGNORE; root.add_child(paper)
	var pw := root.size.x; var ph := root.size.y
	_ctext(root, "CERTIFICATE", fb, int(ph*0.042), Color(0.15,0.10,0.07), Vector2(pw*0.5, ph*0.145))
	_ctext(root, "b u r e a u   o f   a t t r i b u t i o n", fr, int(ph*0.017), Color(0.36,0.27,0.17), Vector2(pw*0.5, ph*0.192))
	_ctext(root, "This bureau attributes the piece as follows —", fr, int(ph*0.016), Color(0.42,0.33,0.22), Vector2(pw*0.5, ph*0.232))
	opt_layer = Control.new(); opt_layer.set_anchors_preset(Control.PRESET_FULL_RECT); root.add_child(opt_layer)
	root.set_meta("medallion", Vector2(pw*0.492, ph*0.895))
	# ПРАВА ПАНЕЛЬ вибору (на екрані, не на папері)
	var panx := root.position.x + cwd + W*0.03
	cert_panel = Control.new(); cert_panel.position = Vector2(panx, H*0.16)
	cert_panel.size = Vector2(W - panx - W*0.03, H*0.7); cert_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	s.add_child(cert_panel)
	_txtbtn(s, "←  back to the desk", Vector2(W*0.04, H*0.94), func(): _show("HUB" if case_done else "DESK"))

# ---- БЛАНК-РЕЧЕННЯ: гравець реконструює історію; графа «на підставі чого» вимагає доказу ----
# ---- КОЛОДА СПРАВ: нова справа = НОВИЙ ЗАПИС, не новий код ----
var CASES := {
	1: {
		"slots": [
			{"pre":"Made in", "gate":"origin",
			 "opts":["Vienna — Hoffmann workshop","Prague — court silver","Augsburg guild-mark"]},
			{"pre":"Its maker's mark was", "gate":"marks",
			 "opts":["struck but once, and clean","struck over an older, effaced mark"]},
			{"pre":"The piece came into these hands", "gate":"papers",
			 "opts":["honestly, by inheritance","by a path I cannot vouch for","taken from a church"]},
			{"pre":"On this I set my name — I rely upon", "gate":"basis", "opts":[]},
		],
	},
	2: {
		# «Спадок удови» — два свідчення: річ сама викриває того, хто підганяв її під свою версію
		"slots": [
			{"pre":"The watch was carried by", "gate":"wear",
			 "opts":["a right-handed man","a left-handed man"]},
			{"pre":"Its chain was", "gate":"chain",
			 "opts":["never disturbed","lately taken off and put back"]},
			{"pre":"The piece belongs to", "gate":"papers",
			 "opts":["the widow","the nephew","neither — it cannot be told"]},
			{"pre":"On this I set my name — I rely upon", "gate":"basis", "opts":[]},
		],
	},
}
var case_id := 1
var CSLOTS: Array = []
var cvals := ["","","",""]
var active_slot := 0   # варіанти показуються ЛИШЕ для активного слота (клік по рядку активує)

func _slot_gate(g: String) -> bool:
	match g:
		"origin": return matched_maker      # збіг клейма в довіднику
		"marks": return found_marks         # роздивився клеймо під лупою
		"wear": return found_wear           # справа 2: оглянув заводну голівку
		"chain": return found_chain         # справа 2: оглянув вушко ланцюжка
		"papers": return read_docs          # прочитав справу: не судиш походження, не знаючи заяви клієнтки
		"basis": return cvals[2] != ""      # спершу назви походження, тоді підставу
	return false

# графа «на підставі» пропонує ЛИШЕ те, що гравець справді знайшов
func _basis_opts() -> Array:
	if case_id == 2:
		var o2 := ["what the claimants told me"]
		if found_wear: o2.append("the crown worn on its left side")
		if found_chain: o2.append("the fresh scratches at the bow")
		return o2
	var o := ["the client's own word"]
	if found_church: o.append("the effaced church mark beneath")
	if read_news: o.append("the notice of the sacristy theft")
	return o

func _refresh_cert() -> void:
	for c in opt_layer.get_children(): c.queue_free()
	for c in cert_panel.get_children(): c.queue_free()
	var pw := cert_layer.size.x; var ph := cert_layer.size.y
	var yy := [0.305, 0.425, 0.545, 0.665]
	# --- РЕЧЕННЯ НА ПАПЕРІ: префікс + вписане значення; рядок клікабельний (активує слот) ---
	for i in CSLOTS.size():
		var slot: Dictionary = CSLOTS[i]
		var gate_open: bool = _slot_gate(String(slot["gate"]))
		var pre := Label.new(); pre.label_settings = _ls(fr, int(ph*0.020), Color(0.34,0.25,0.16))
		pre.text = String(slot["pre"]); pre.position = Vector2(pw*0.19, ph*yy[i]); pre.mouse_filter = Control.MOUSE_FILTER_IGNORE; opt_layer.add_child(pre)
		var line := ColorRect.new(); line.color = Color(0.44,0.34,0.22) if (gate_open and not sealed) else Color(0.60,0.52,0.40)
		line.size = Vector2(pw*0.62, 1.5); line.position = Vector2(pw*0.19, ph*(yy[i]+0.058)); line.mouse_filter = Control.MOUSE_FILTER_IGNORE; opt_layer.add_child(line)
		var is_stolen: bool = (i == 2 and cvals[i] == "taken from a church")
		var val := Label.new(); val.label_settings = _ls(fh, int(ph*0.032), Color(0.58,0.11,0.11) if is_stolen else Color(0.16,0.11,0.08))
		val.position = Vector2(pw*0.215, ph*(yy[i]+0.020)); val.text = cvals[i]; val.mouse_filter = Control.MOUSE_FILTER_IGNORE; opt_layer.add_child(val)
		if sealed: continue
		if gate_open:
			# підсвітка активного рядка + клік-зона
			if active_slot == i:
				var hl := ColorRect.new(); hl.color = Color(0.62,0.11,0.10,0.12); hl.size = Vector2(pw*0.64, ph*0.075)
				hl.position = Vector2(pw*0.18, ph*(yy[i]-0.005)); hl.mouse_filter = Control.MOUSE_FILTER_IGNORE; opt_layer.add_child(hl)
			var pick := Button.new(); pick.flat = true; pick.modulate.a = 0
			pick.position = Vector2(pw*0.18, ph*(yy[i]-0.005)); pick.size = Vector2(pw*0.64, ph*0.075)
			pick.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			var si := i; pick.pressed.connect(func(): active_slot = si; _refresh_cert())
			opt_layer.add_child(pick)
		elif cvals[i] == "":
			var h := Label.new(); h.label_settings = _ls(fr, int(ph*0.016), Color(0.56,0.49,0.40))
			# діегетична підказка — КОНКРЕТНО, чого бракує саме для цього рядка
			var g := String(slot["gate"])
			var htxt := "( … )"
			if g == "origin": htxt = "( match the mark in the register first )"
			elif g == "marks": htxt = "( look at the foot under the glass )"
			elif g == "papers": htxt = "( read the case papers first )"
			elif g == "basis": htxt = "( name the provenance above first )"
			h.text = htxt
			h.position = Vector2(pw*0.215, ph*(yy[i]+0.022)); h.mouse_filter = Control.MOUSE_FILTER_IGNORE; opt_layer.add_child(h)
	# --- ВАРІАНТИ АКТИВНОГО СЛОТА — у ПРАВІЙ ПАНЕЛІ, великим читабельним шрифтом ---
	if not sealed:
		_build_cert_panel()
	var filled: bool = cvals[0] != "" and cvals[1] != "" and cvals[2] != "" and cvals[3] != ""
	if not sealed and not filled and cert_layer.has_node("stamp_hs"):
		cert_layer.get_node("stamp_hs").queue_free()   # графу очистили → печатку прибрати
	if not sealed and filled:
		if not cert_layer.has_node("stamp_hs"):
			var med: Vector2 = cert_layer.get_meta("medallion")
			var hs := Button.new(); hs.name = "stamp_hs"; hs.flat = true; hs.modulate.a = 0
			hs.position = Vector2(med.x-pw*0.11, med.y-pw*0.11); hs.size = Vector2(pw*0.22, pw*0.22)
			hs.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			hs.mouse_entered.connect(_set_hint.bind("Press the seal — once set, it cannot be lifted."))
			hs.pressed.connect(func(): _do_verdict())
			cert_layer.add_child(hs)
		# у панелі — заклик поставити печатку
		var seal_note := Label.new(); seal_note.label_settings = _ls(fr, int(H*0.024), Color(0.86,0.66,0.42))
		seal_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; seal_note.size = Vector2(cert_panel.size.x, H*0.2)
		seal_note.position = Vector2(0, H*0.42)
		seal_note.text = "The attribution is written.\nPress the wax seal to close the case — once set, it cannot be lifted."
		cert_panel.add_child(seal_note)

# права панель: варіанти активного слота, ВЕЛИКИМ читабельним шрифтом
func _build_cert_panel() -> void:
	var i := active_slot
	if i < 0 or i >= CSLOTS.size() or not _slot_gate(String(CSLOTS[i]["gate"])):
		var d := Label.new(); d.label_settings = _ls(fr, int(H*0.024), Color(0.82,0.77,0.67))
		d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; d.size = Vector2(cert_panel.size.x, H*0.3)
		d.text = "Set down each line of the attribution.\nClick any line on the left to fill or change it."
		cert_panel.add_child(d); return
	var slot: Dictionary = CSLOTS[i]
	var head := Label.new(); head.label_settings = _ls(fr, int(H*0.03), Color(0.72,0.61,0.43))
	head.text = String(slot["pre"]) + " …"; head.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	head.size = Vector2(cert_panel.size.x, H*0.1); cert_panel.add_child(head)
	var opts: Array = _basis_opts() if String(slot["gate"]) == "basis" else (slot["opts"] as Array)
	var y := H*0.11
	for opt in opts:
		var chosen: bool = (cvals[i] == opt)
		var bo := Button.new(); bo.flat = true; bo.text = ("●   " + opt) if chosen else ("○   " + opt)
		bo.add_theme_font_override("font", fr); bo.add_theme_font_size_override("font_size", int(H*0.027))
		bo.add_theme_color_override("font_color", Color(0.92,0.44,0.36) if chosen else Color(0.90,0.85,0.74))
		bo.add_theme_color_override("font_hover_color", Color(0.99,0.72,0.42))
		bo.alignment = HORIZONTAL_ALIGNMENT_LEFT; bo.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		bo.position = Vector2(0, y); bo.size = Vector2(cert_panel.size.x, H*0.05)
		bo.clip_text = false; bo.autowrap_mode = TextServer.AUTOWRAP_OFF
		var ii: int = i; var oo: String = String(opt)
		bo.pressed.connect(func(): _choose(ii, oo))
		cert_panel.add_child(bo)
		y += H*0.062
	if String(slot["gate"]) == "basis":
		var note := Label.new(); note.label_settings = _ls(fr, int(H*0.018), Color(0.64,0.57,0.47))
		note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; note.size = Vector2(cert_panel.size.x, H*0.14)
		note.text = "Name the proof that would still stand if the client's story did not. You may cite only what you have found."
		note.position = Vector2(0, y + H*0.03); cert_panel.add_child(note)

func _choose(i: int, opt: String) -> void:
	if sealed: return
	cvals[i] = opt
	if i == 2: cvals[3] = ""   # змінив походження → підстава скидається (перепривʼязка доказу)
	_play("pen_write")
	active_slot = _next_open_slot()   # авто-перехід до наступного незаповненого відкритого слота
	_refresh_cert()

func _start_case(n: int) -> void:
	case_id = n
	CSLOTS = (CASES[n] as Dictionary)["slots"]
	cvals = ["","","",""]
	sealed = false
	read_docs = false; read_news = false
	found_marks = false; matched_maker = false; found_church = false; raking = false
	found_wear = false; found_chain = false
	active_slot = 0

func _next_open_slot() -> int:
	for j in CSLOTS.size():
		if _slot_gate(String(CSLOTS[j]["gate"])) and cvals[j] == "": return j
	return -1

# наслідок вироку — ПОДІЯ наступного ранку, не «вірно/хибно». Гра мовчить про правильність.
func _outcome_text() -> String:
	if case_id == 2: return _outcome_case2()
	var origin_ok: bool = cvals[0].begins_with("Vienna")
	var mark_ok: bool = cvals[1].contains("over an older")
	var prov: String = cvals[2]
	var basis: String = cvals[3]
	var solid: bool = basis.contains("church mark") or basis.contains("sacristy")
	if prov == "taken from a church" and solid and origin_ok and mark_ok:
		return "Three days on, a deacon of St. Onuphrius climbs the bureau stair. He reads your hand, and his own begins to shake. The goblet goes back to the altar it was lifted from — and your name is on the paper that sent it home."
	if prov == "taken from a church" and not solid:
		return "A constable calls. The woman you named a thief wept before the magistrate — and you had set 'taken from a church' upon nothing but her own frightened word. The bureau's judgement is asked after in the street."
	if prov != "taken from a church":
		return "Weeks later the sacristy theft is printed in full. The silver you passed as clean was the altar's own — and your seal is upon the sale. The bureau does not speak of it."
	return "The paper holds well enough to sell. But a collector writes to quarrel the workshop, and the bureau's word carries a small blot it did not have the day before."

# СПРАВА 2: річ сама викриває того, хто підганяв її під свою версію
func _outcome_case2() -> String:
	var hand: String = cvals[0]
	var chain: String = cvals[1]
	var owner: String = cvals[2]
	var basis: String = cvals[3]
	var solid: bool = basis.contains("left side") or basis.contains("bow")
	if owner == "the widow" and hand == "a left-handed man" and chain.contains("taken off") and solid:
		return "The widow turns the watch over in her hands as if greeting it. Her husband wound it left-handed for thirty years, she says, and the chain was his father's. The nephew does not come back for the ruling — nor for anything else."
	if owner == "the widow" and not solid:
		return "You ruled for the widow and were right, though you could not have said why. The nephew's advocate asks upon what evidence, and the bureau has no answer to give him. The ruling stands; its authority does not."
	if owner == "the nephew":
		return "The nephew collects the watch and is gone by evening. A month on, a pawnbroker's list carries it — and beside it, the widow's wedding silver. She writes once, to ask how you came to your judgement. You do not answer."
	return "You declined to rule, and the matter went to the courts, where it will outlive both claimants. The widow's letters stop coming after the second winter."

func _do_verdict() -> void:
	if sealed: return
	sealed = true; seals_set += 1
	if cert_layer.has_node("stamp_hs"): cert_layer.get_node("stamp_hs").queue_free()
	_set_hint("")
	await _verdict_anim()
	_case_closed()
	var t := create_tween(); t.tween_interval(1.7); t.tween_callback(_show_morning)

# ---------- НАСТУПНИЙ РАНОК (наслідок) ----------
func _show_morning() -> void:
	if not screens.has("MORNING"):
		var s := _screen("MORNING")
		_paper_backdrop(s, 0.14)
		var card := Label.new(); card.name = "mtext"; card.label_settings = _ls(fr, int(H*0.032), Color(0.90,0.86,0.77))
		card.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card.size = Vector2(W*0.6, H*0.5); card.position = Vector2(W*0.2, H*0.24)
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE; s.add_child(card)
		var head := Label.new(); head.label_settings = _ls(fb, int(H*0.03), Color(0.72,0.60,0.40))
		head.text = "The next morning."; head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		head.size = Vector2(W, H*0.05); head.position = Vector2(0, H*0.15); head.mouse_filter = Control.MOUSE_FILTER_IGNORE; s.add_child(head)
		_txtbtn(s, "close the ledger  →", Vector2(W*0.62, H*0.8), func(): _evening())
	var mt: Label = screens["MORNING"].get_node("mtext")
	mt.text = _outcome_text()
	_show("MORNING")
	_play("page_turn")

# ---------- ГРОСБУХ: кінець справи + ЛІЧИЛЬНИК ПЕЧАТОК (гачок мета-сюжету) ----------
# ================= СПРАВА 2 «СПАДОК УДОВИ» (два свідчення) =================
# Річ сама викриває брехуна: знос голівки під ліву руку + свіжі подряпини на вушку.
func _build_case2() -> void:
	# --- стіл справи 2 ---
	var s := _screen("DESK2")
	if tex.has("case2_desk"): _bg(s, tex["case2_desk"])
	else: _bg(s, tex["case_desk"])
	var intro := Label.new(); intro.label_settings = _ls(fr, int(H*0.028), Color(0.92,0.88,0.78))
	intro.text = "A pocket watch, and two people who both call it theirs.\nThe watch was carried for thirty years. It remembers the hand."
	intro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.size = Vector2(W*0.64, H*0.12); intro.position = Vector2(W*0.18, H*0.05)
	intro.mouse_filter = Control.MOUSE_FILTER_IGNORE; s.add_child(intro)
	var itw := create_tween(); itw.tween_interval(7.0); itw.tween_property(intro, "modulate:a", 0.0, 2.0)
	# хотспот самого годинника → огляд
	var wb := Button.new(); wb.flat = true; wb.modulate.a = 0
	wb.position = Vector2(W*0.33, H*0.40); wb.size = Vector2(W*0.20, H*0.28)
	wb.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	wb.mouse_entered.connect(_set_hint.bind("The watch — take it up and look closer"))
	wb.mouse_exited.connect(_set_hint.bind(""))
	wb.pressed.connect(func(): _play("goblet_set"); _show("WATCH_WEAR"))
	s.add_child(wb)
	_txtbtn(s, "the statements  →", Vector2(W*0.05, H*0.92), func(): _show("TESTIMONY"))
	_txtbtn(s, "examine the watch  →", Vector2(W*0.40, H*0.92), func(): _show("WATCH_WEAR"))
	_txtbtn(s, "Write the certificate  →", Vector2(W*0.74, H*0.92), func(): _show("CERT"))
	# --- два свідчення на одному аркуші (їх треба ЗІСТАВИТИ) ---
	var t := _screen("TESTIMONY")
	_paper_backdrop(t)
	var lt: Texture2D = tex["letter_client"] if tex.has("letter_client") else tex["atestat_flat_blank"]
	var lh := H*0.84; var lw := lh*float(lt.get_width())/float(lt.get_height())
	var paper := TextureRect.new(); paper.texture = lt; paper.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	paper.stretch_mode = TextureRect.STRETCH_SCALE; paper.size = Vector2(lw, lh)
	paper.position = Vector2((W-lw)*0.5, (H-lh)*0.5 - H*0.02); paper.mouse_filter = Control.MOUSE_FILTER_IGNORE; t.add_child(paper)
	var tx := Label.new(); tx.label_settings = _ls(fr, int(lh*0.028), Color(0.20,0.14,0.09))
	tx.text = "THE WIDOW:\n\"He wound it every night before\nthe lamp. Thirty years. The chain\nwas his father's — it was never\noff the watch.\"\n\nTHE NEPHEW:\n\"My uncle gave it me in his last\nweek. I put the chain on myself,\nfresh, to carry it properly.\nHe was right-handed, as I am.\""
	tx.position = paper.position + Vector2(lw*0.11, lh*0.11); tx.mouse_filter = Control.MOUSE_FILTER_IGNORE; t.add_child(tx)
	_txtbtn(t, "←  back to the desk", Vector2(W*0.04, H*0.92), func(): _show("DESK2"))
	_txtbtn(t, "Write the certificate  →", Vector2(W*0.72, H*0.92), func(): _show("CERT"))
	# --- дві деталі під лупою: голівка (знос) і вушко (подряпини) ---
	_build_detail("WATCH_WEAR", "watch_wear",
		"The crown is worn flat on its LEFT side — wound for years by a left hand.",
		func(): found_wear = true, "WATCH_CHAIN", "the bow and chain  →")
	_build_detail("WATCH_CHAIN", "watch_chain",
		"The bow is scratched bright and raw — this chain was put on lately, not worn for thirty years.",
		func(): found_chain = true, "WATCH_WEAR", "←  the winding crown")

# екран-деталь: велике фото + напис, що саме видно (знахідка ставиться при відкритті)
func _build_detail(scr: String, texname: String, note: String, mark: Callable, other: String, other_lbl: String) -> void:
	var d := _screen(scr)
	_paper_backdrop(d, 0.12)
	if tex.has(texname):
		var t2: Texture2D = tex[texname]
		var dh := H*0.74; var dw := dh*float(t2.get_width())/float(t2.get_height())
		var im := TextureRect.new(); im.texture = t2; im.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		im.stretch_mode = TextureRect.STRETCH_SCALE; im.size = Vector2(dw, dh)
		im.position = Vector2((W-dw)*0.5, H*0.10); im.mouse_filter = Control.MOUSE_FILTER_IGNORE; d.add_child(im)
	var l := Label.new(); l.label_settings = _ls(fr, int(H*0.026), Color(0.92,0.88,0.78))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size = Vector2(W*0.7, H*0.08); l.position = Vector2(W*0.15, H*0.855)
	l.text = note; l.mouse_filter = Control.MOUSE_FILTER_IGNORE; d.add_child(l)
	_txtbtn(d, "←  set it down", Vector2(W*0.04, H*0.92), func(): _show("DESK2"))
	_txtbtn(d, other_lbl, Vector2(W*0.42, H*0.92), func(): _show(other))
	_txtbtn(d, "Write the certificate  →", Vector2(W*0.74, H*0.92), func(): _show("CERT"))
	d.set_meta("mark", mark)

func _evening() -> void:
	case_done = true
	tod = "evening"
	_enter_hub()
	_hub_say("Evening. Across the street someone has been standing a while. The ledger lies open on your desk.")

func _build_ledger() -> void:
	var s := _screen("LEDGER")
	_paper_backdrop(s, 0.13)
	var head := Label.new(); head.label_settings = _ls(fb, int(H*0.032), Color(0.74,0.62,0.42))
	head.text = "The day's ledger"; head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	head.size = Vector2(W, H*0.06); head.position = Vector2(0, H*0.16)
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE; s.add_child(head)
	var body := Label.new(); body.name = "ltext"; body.label_settings = _ls(fr, int(H*0.030), Color(0.90,0.86,0.77))
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.size = Vector2(W*0.56, H*0.42); body.position = Vector2(W*0.22, H*0.28)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE; s.add_child(body)
	# діегетичний лічильник печаток — те, на чому тримається весь мета-сюжет
	var seal_lbl := Label.new(); seal_lbl.name = "sealcount"; seal_lbl.label_settings = _ls(fh, int(H*0.036), Color(0.72,0.16,0.13))
	seal_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	seal_lbl.size = Vector2(W, H*0.06); seal_lbl.position = Vector2(0, H*0.70)
	seal_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE; s.add_child(seal_lbl)

func _show_ledger() -> void:
	var b: Label = screens["LEDGER"].get_node("ltext")
	b.text = "Case the first — a silver goblet, brought in by a woman who would not meet your eye.\n\nThe attribution is written, the wax is set. It cannot be lifted.\n\nThe bureau's door will open again tomorrow."
	var sc: Label = screens["LEDGER"].get_node("sealcount")
	sc.text = "Seals set this week:  %d" % seals_set
	var nx: Button = screens["LEDGER"].get_node_or_null("nextcase")
	if nx: nx.queue_free()
	var nb := _txtbtn(screens["LEDGER"], "←  back to the room", Vector2(W*0.62, H*0.80), func(): _enter_hub())
	nb.name = "nextcase"
	_play("page_turn")

func _ctext(parent: Control, txt: String, font: FontFile, sz: int, col: Color, center: Vector2) -> void:
	var l := Label.new(); l.label_settings = _ls(font, sz, col); l.text = txt
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.size = Vector2(center.x*2, sz*1.4); l.position = Vector2(0, center.y - sz*0.7); parent.add_child(l)

# анімація печатки: віск ллється → штамп пласко згори → печатка в центр
func _verdict_anim() -> void:
	var med: Vector2 = cert_layer.get_meta("medallion")
	var wx: Texture2D = tex["wax_stick"]; var se: Texture2D = tex["seal_cut"]; var sp: Texture2D = tex["stamp_top_cut"]
	var seal := TextureRect.new(); seal.texture = se; seal.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; seal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sd: float = cert_layer.size.x*0.16; seal.size = Vector2(sd,sd); seal.pivot_offset = seal.size*0.5
	seal.position = med - seal.size*0.5; seal.scale = Vector2(0.2,0.2); seal.modulate = Color(1,1,1,0); cert_layer.add_child(seal)
	var stamp := TextureRect.new(); stamp.texture = sp; stamp.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; stamp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var st: float = cert_layer.size.x*0.30; stamp.size = Vector2(st, st*float(sp.get_height())/float(sp.get_width())); stamp.pivot_offset = stamp.size*0.5
	var s_down := med - stamp.size*0.5; var s_up := s_down + Vector2(0, -cert_layer.size.y*0.5)
	stamp.position = s_up; stamp.modulate.a = 0; cert_layer.add_child(stamp)
	var tw := create_tween()
	tw.tween_property(seal, "modulate", Color(1,1,1,1), 0.5)
	tw.parallel().tween_property(seal, "scale", Vector2(0.58,0.58), 0.5)
	tw.tween_property(stamp, "modulate:a", 1.0, 0.2)
	tw.tween_property(stamp, "position", s_down, 0.32).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(func(): _play("stamp_seal"))
	tw.tween_property(seal, "scale", Vector2(1.06,1.06), 0.12)
	tw.tween_property(seal, "scale", Vector2(1.0,1.0), 0.1)
	tw.tween_property(stamp, "position", s_up, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(stamp, "modulate:a", 0.0, 0.4)
	await tw.finished

func _case_closed() -> void:
	var lab := Label.new(); lab.label_settings = _ls(fb, int(cert_layer.size.y*0.05), Color(0.60,0.12,0.12))
	lab.text = "CASE CLOSED"; lab.rotation = deg_to_rad(-9); lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; lab.size = Vector2(cert_layer.size.x*0.6, cert_layer.size.y*0.08)
	lab.position = Vector2(cert_layer.size.x*0.2, cert_layer.size.y*0.71); lab.pivot_offset = lab.size*0.5; lab.scale = Vector2(0.4,0.4)
	cert_layer.add_child(lab)
	var t := create_tween()
	t.tween_property(lab, "scale", Vector2(1.05,1.05), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(lab, "scale", Vector2(1.0,1.0), 0.08)

# ---------- 3D ----------
func _build_goblet_world(sv: SubViewport) -> void:
	var we := WorldEnvironment.new(); var env := Environment.new()
	var sky := Sky.new(); var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color(0.17,0.16,0.17); sm.sky_horizon_color = Color(0.21,0.18,0.15)
	sm.ground_bottom_color = Color(0.03,0.03,0.04); sm.ground_horizon_color = Color(0.10,0.08,0.06)
	sm.sky_energy_multiplier = 1.5; sky.sky_material = sm
	env.background_mode = Environment.BG_SKY; env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY; env.ambient_light_energy = 1.35
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC; env.tonemap_exposure = 0.95
	we.environment = env; sv.add_child(we)
	# тепла лампа — світить НИЗЬКО і КОСО через ногу (щоб клеймо блисло при оберті)
	var key := DirectionalLight3D.new(); key.light_color = Color(1.0,0.92,0.82); key.light_energy = 1.9
	key.rotation_degrees = Vector3(-9,-62,0); sv.add_child(key); key_light = key
	var rim := DirectionalLight3D.new(); rim.light_color = Color(0.72,0.76,0.88); rim.light_energy = 0.8
	rim.rotation_degrees = Vector3(-12,-135,0); sv.add_child(rim)
	# фронтальний фIll — ТЕПЛИЙ і сильний: він освітлює перевернутий спід, тож клеймо срібне, не синє
	var fl := DirectionalLight3D.new(); fl.light_color = Color(1.0,0.93,0.82); fl.light_energy = 1.5
	fl.rotation_degrees = Vector3(-5,8,0); sv.add_child(fl)
	var cam := Camera3D.new(); sv.add_child(cam); main_cam3 = cam
	goblet_pivot = Node3D.new(); sv.add_child(goblet_pivot)
	var scn := load("res://models/goblet.glb") as PackedScene
	var inst := scn.instantiate(); goblet_pivot.add_child(inst)
	var aabb := _aabb(inst); inst.position = -aabb.get_center()
	# АНТИКВАРНЕ СРІБЛО — САТИН, НЕ ДЗЕРКАЛО: інакше метал ловить небо в білу пляму
	# рівно на споді і випалює клеймо. Сатин = мʼякий блиск, тавро читне при будь-якому куті.
	# Meshy дає один атлас на модель → один спільний матеріал (успадковує текстуру срібла).
	var satin := StandardMaterial3D.new()
	satin.albedo_color = Color(0.82, 0.82, 0.84); satin.metallic = 0.78; satin.roughness = 0.60
	for m in inst.find_children("*", "MeshInstance3D", true, false):
		var mi := m as MeshInstance3D
		if mi.mesh == null: continue
		for si in mi.mesh.get_surface_count():
			var mat: Material = mi.get_active_material(si)
			if mat is StandardMaterial3D and satin.albedo_texture == null:
				var om := mat as StandardMaterial3D
				satin.albedo_texture = om.albedo_texture
				satin.normal_enabled = om.normal_enabled
				satin.normal_texture = om.normal_texture
	for m2 in inst.find_children("*", "MeshInstance3D", true, false):
		var mi2 := m2 as MeshInstance3D
		if mi2.mesh == null: continue
		for si2 in mi2.mesh.get_surface_count():
			mi2.set_surface_override_material(si2, satin)
	# КЛЕЙМО ВИБИТЕ В СПІД НІЖКИ: плоска врізана латка обличчям ВНИЗ (-Y).
	# Спід плоский → латка врівень (не плаває). Нормаль-мапа = заглибина в металі.
	# Прямо стоїть — не видно (дивиться вниз). Перевернеш чашу — видно.
	# ВИМІРЯНО: спід — увігнутий конус (центр -0.672 → обід -0.95). Клеймо будуємо на
	# КОНФОРМНІЙ до цього конуса поверхні, тож тавро лежить на металі, видиме звідусіль, не сліпить.
	_build_hallmark(goblet_pivot)
	cam.position = Vector3(0,0, maxf(aabb.size.y, aabb.size.x)*1.9); cam.look_at(Vector3.ZERO, Vector3.UP)

# профіль споду ніжки (виміряно з моделі): радіус → Y
var UPR := PackedFloat32Array([0.00, 0.02, 0.06, 0.10, 0.14, 0.18, 0.22, 0.26, 0.30, 0.34])
var UPY := PackedFloat32Array([-0.672, -0.672, -0.703, -0.735, -0.760, -0.776, -0.788, -0.800, -0.815, -0.860])

func _under_y(r: float) -> float:
	for i in UPR.size() - 1:
		if r <= UPR[i + 1]:
			var t: float = (r - UPR[i]) / (UPR[i + 1] - UPR[i])
			return lerpf(UPY[i], UPY[i + 1], clampf(t, 0.0, 1.0))
	return UPY[UPY.size() - 1]

# Клеймо на поверхні, що ПОВТОРЮЄ увігнутий спід (surface of revolution по _under_y).
func _build_hallmark(parent: Node3D) -> void:
	var yc := -0.69                       # вузол-ціль для лупи = центр клейма
	var node := Node3D.new(); node.position = Vector3(0.0, yc, 0.0)
	parent.add_child(node); hallmark_node = node
	var rad := 0.34                       # на ВЕСЬ спід — пластина стає поверхнею дна (лупа лише зумить)
	var nr := 26; var ns := 64
	var verts := PackedVector3Array(); var norms := PackedVector3Array(); var uvs := PackedVector2Array()
	for ir in nr + 1:
		var rr: float = rad * float(ir) / float(nr)
		var yy: float = _under_y(rr) - yc - 0.004
		var slope: float = (_under_y(rr + 0.004) - _under_y(rr - 0.004)) / 0.008
		for iseg in ns + 1:
			var a: float = TAU * float(iseg) / float(ns)
			verts.append(Vector3(rr * cos(a), yy, rr * sin(a)))
			norms.append(Vector3(slope * cos(a), -1.0, slope * sin(a)).normalized())
			# PLATE_UV<1 → на дно лягає лише центральна частина пластини, тож МАРКИ БІЛЬШІ й читаються
			uvs.append(Vector2(0.5 + 0.5 * PLATE_UV * (rr / rad) * cos(a), 0.5 + 0.5 * PLATE_UV * (rr / rad) * sin(a)))
	var idx := PackedInt32Array(); var row := ns + 1
	for ir in nr:
		for iseg in ns:
			var a0: int = ir * row + iseg; var b0: int = a0 + row
			idx.append(a0); idx.append(b0); idx.append(a0 + 1)
			idx.append(a0 + 1); idx.append(b0); idx.append(b0 + 1)
	var arr := []; arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = verts; arr[Mesh.ARRAY_NORMAL] = norms
	arr[Mesh.ARRAY_TEX_UV] = uvs; arr[Mesh.ARRAY_INDEX] = idx
	var am := ArrayMesh.new(); am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	var st := SurfaceTool.new(); st.create_from(am, 0); st.generate_tangents()
	var shared_mesh: ArrayMesh = st.commit()
	# ДНО = САМА ПЛАСТИНА (самосвітна текстура на споді). Без лупи й під лупою — ОДНЕ Й ТЕ САМЕ;
	# лупа робить лише живий зум цього ж дна. Косе світло → інша пластина (церковна мітка).
	var mi := MeshInstance3D.new(); mi.mesh = shared_mesh
	var um := StandardMaterial3D.new()
	um.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED   # пластина ЯК Є, без залежності від кута світла
	um.albedo_texture = load("res://art/foot_plate_maker.png")
	um.albedo_color = Color(1.30, 1.28, 1.22)               # помірно: марки читаються, без пересвіту
	um.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	um.cull_mode = BaseMaterial3D.CULL_DISABLED
	mi.material_override = um; maker_mat = um
	node.add_child(mi)

func _aabb(n: Node) -> AABB:
	var a := AABB(); var first := true
	for m in n.find_children("*","MeshInstance3D",true,false):
		var wa: AABB = (m as MeshInstance3D).global_transform * (m as MeshInstance3D).get_aabb()
		if first: a = wa; first = false
		else: a = a.merge(wa)
	return a

func _unhandled_input(event: InputEvent) -> void:
	# у HANDS: тягнеш — ОБЕРТАЄШ чашу (можна перевернути й глянути спід). Лупа кладеться кнопкою.
	if not (screens.has("HANDS") and screens["HANDS"].visible and goblet_pivot): return
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		cup_dragging = (event as InputEventMouseButton).pressed
	elif event is InputEventMouseMotion and cup_dragging:
		var mm := event as InputEventMouseMotion
		goblet_pivot.rotation.y -= mm.relative.x * 0.012
		goblet_pivot.rotation.x = clampf(goblet_pivot.rotation.x - mm.relative.y*0.012, -2.7, 2.7)
