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
var lang := "uk"                 # мова показу; "en" = база (правило 10)
var loc_uk := {}                 # словник en→uk
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
# ---- ФАКТИ: єдине сховище. Порядок вставки Dictionary = хронологія нотатника ----
# Старі буліни лишились іменами, але тепер це ГЕТТЕРИ над facts.
# Присвоєння геттеру = помилка компіляції → компілятор сам ловить забуті місця.
var facts := {}

func add_fact(id: String) -> bool:
	if facts.has(id): return false      # ЄДИНЕ місце в грі, де гинуть дублі
	facts[id] = true
	return true

func drop_fact(id: String) -> void:
	facts.erase(id)

# ── 5a (крок 5): канонічні id фактів — ті самі, що в data/case_01.gd. ─────────
# Геттери — ФАСАД для старого коду; мапа НЕ 1:1 (аудит 26.07, знахідка 14):
# «побачив клейма» — це ДВА факти (f.mark_maker + f.mark_diana), тому add ставить
# обидва, а геттер питає другий. Розблоковує підключення core/rules.gd.
var found_marks: bool:
	get: return facts.has("f.mark_diana")    # обидва клейма під лупою (ставляться разом)
var matched_maker: bool:
	get: return facts.has("f.reg_hoffmann")   # збіг у каталозі → Hoffmann, Wien
var read_news: bool:
	get: return facts.has("f.news_robbery")       # газета: пограбування ризниці
var read_docs: bool:
	# справа 1 — лист клієнтки; справа 2 — свідчення. Різні папери, різні факти;
	# факти скидаються _load_case, тож геттер питає обидва
	get: return facts.has("f.letter_read") or facts.has("f.testimony_read")       # справа: лист клієнтки / свідчення
var found_wear: bool:
	get: return facts.has("f.crown_wear")    # справа 2: знос голівки
var found_chain: bool:
	get: return facts.has("f.bow_scratches") # справа 2: свіжі подряпини на вушку
var raking := false          # косе світло увімкнене (в руках)
var found_church: bool:
	get: return facts.has("f.church_mark")   # стерта церковна монограма під косим світлом
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
var hint_band: TextureRect

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
var goblet_sv: SubViewport       # головний вьюпорт чаші (для звірки світів)
var loupe_cam: Camera3D          # зум-камера на реальне клеймо
var loupe_vp_tex: TextureRect    # показує 3D-в'юпорт у склі
var key_light: DirectionalLight3D    # основне тепле світло (косе світло змінює його кут)
var maker_mat: StandardMaterial3D    # матеріал клейма майстра (під косим світлом приглушується)
var rake_btn: Button                 # кнопка «косе світло» в руках
var hand_tool_ui: TextureRect        # активний інструмент «у руці» — йде за курсором
var notebook_page := -1              # аркуш записника; -1 = найсвіжіший
var desk_intro: Label                # інтро столу — гасне при першому ховері
var dust_quad: MeshInstance3D        # пил на дні ніші (справа 2)
var c2_intro1: Label                 # вступ справи 2 — гасне з першим банером
var c2_intro2: Label
var goblet_world: World3D            # світ чаші (справа 1) для лупи
var sec_world: World3D               # світ секретера (справа 2) для лупи
var c2_loupe := false                # скло активне на екранах справи 2
var sec_cam_live: Camera3D           # ОДНА камера справи 2 — дольчить між кадрами
var sec_cam_targets := {}            # FURN/WELL/DRAWER → Transform3D кадру
var sec_pivot: Node3D                # обертання всього секретера (turntable)
var sec_cam_tw: Tween                # активний дольчик (щоб не накладались)
var sec_yaw := 0.0                   # накопичений оберт від перетягування
var _c2_seen := false                # чи вже показували предмет (перший кадр — без дольчика)
var c2_press_pos := Vector2.ZERO
var c2_drag_travel := 0.0
var c2_dragging := false
var c2_mouse_down := false
var hands_glass_btn: Button          # «взяти скло» просто в руках
var set_down_btn: Button
var loupe_held := false
var loupe_lw := 0.0
var loupe_lh := 0.0
var tex_comp: Texture2D    # композит стола З предметами — джерело скла лупи
var cup_dragging := false
var drag_travel := 0.0       # накопичений рух миші: <70 px = жест пальця, не оберт
var drag_press_pos := Vector2.ZERO
var drag_press_basis := Basis()   # для відкату мікро-оберту при жесті
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
	_build_marks_macro()
	_build_receipt()
	_build_books()
	_build_cert()
	_build_ledger()
	_build_case2()
	_load_case(1)          # один вхід у стан замість ручного присвоєння CSLOTS
	# верхня підказка (діегетична — на мальованій стрічці нема, тож тонкий текст)
	# мальована стрічка під верхнім рядком: текст на строкатому кадрі без підложки
	# нечитабельний (Віктор, 27.07). Та сама стрічка, що в субтитрів клієнтки.
	hint_band = TextureRect.new()
	if tex.has("subtitle_band"): hint_band.texture = tex["subtitle_band"]
	hint_band.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hint_band.stretch_mode = TextureRect.STRETCH_SCALE
	hint_band.size = Vector2(W, H*0.115); hint_band.position = Vector2(0, 0)
	hint_band.modulate = Color(1, 1, 1, 0.88)
	hint_band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint_band.visible = false
	add_child(hint_band)
	hint_label = Label.new()
	hint_label.label_settings = _ls(fr, int(H*0.028), Color(0.95,0.91,0.80))
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.size = Vector2(W*0.86, H*0.10); hint_label.position = Vector2(W*0.07, H*0.02)
	# запобіжник: задовгий рядок мусить переноситись, а не зрізатися по краях екрана.
	# Спіймано на кроці 3 — репліка про крадіжку вилазила за обидва краї кадру.
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# тінь: читабельність на будь-якому кадрі
	hint_label.label_settings.shadow_color = Color(0, 0, 0, 0.85)
	hint_label.label_settings.shadow_offset = Vector2(1.5, 1.5)
	hint_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hint_label)
	_build_loupe()
	_build_menu(); _build_hub(); _build_client(); _build_client2(); _build_chapters()
	move_child(hint_label, get_child_count()-1)   # підказки завжди поверх сцен
	_show("MENU")
	amb.play()
	# ЗНІМКИ МУСЯТЬ БУТИ ОДНОГО РОЗМІРУ. Вікно стоїть у режимі 2 (розгорнуте), тому кадр
	# має розмір вікна ОС — а він між сесіями плаває на два-три пікселі. Через це еталон
	# кроку 0 вийшов неоднорідним (9 кадрів 2965×1668 і 39 кадрів 2968×1670), і будь-яке
	# попіксельне порівняння давало 39 фальшивих «змін», у яких коду не було взагалі.
	if OS.get_cmdline_user_args().size() > 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(1920, 1080))

	if "layoutcheck" in OS.get_cmdline_user_args():
		_dbg_layoutcheck()
	if "pilot" in OS.get_cmdline_user_args():
		_dbg_pilot()
	if "furnprobe" in OS.get_cmdline_user_args():
		_dbg_furnprobe()
	if "savetest" in OS.get_cmdline_user_args():
		_dbg_savetest()
	if "zonemap" in OS.get_cmdline_user_args():
		_dbg_zonemap()
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
	# П'ять гілок ранку справи 1 (нова система: id-слоти, число, факти-підстава).
	# Перевірка та сама: різні гілки МУСЯТЬ давати різні тексти (мовчазна злипка
	# двох гілок виглядає як покриття — аудит уже ловив таке).
	var cases := [
		[[&"o.vienna_hoffmann", 800, 1872, &"o.after_the_fact", &"o.made_to_look_stolen",
		  [&"f.domes_alike", &"f.marks_alone"]], "ПРАВИЛЬНО+доказ"],
		[[&"o.vienna_hoffmann", 800, 1867, &"o.by_office_later", &"o.made_to_look_stolen",
		  [&"f.letter_read", &"f.news_robbery"]], "підробка без доказу"],
		[[&"o.vienna_hoffmann", 800, 1867, &"o.by_office_later", &"o.taken_from_church",
		  [&"f.letter_read", &"f.news_robbery"]], "повірив у крадене"],
		[[&"o.vienna_hoffmann", 800, 1867, &"o.on_the_flat", &"o.honest_inheritance",
		  [&"f.letter_read", &"f.news_robbery"]], "продав як чисте"],
		[[&"o.vienna_unrecorded", 750, 1850, &"o.on_the_flat", &"o.legally_remarked",
		  [&"f.letter_read", &"f.news_robbery"]], "переклеймоване законно"],
	]
	print("OUTCOMES")
	var seen := {}
	var ids := {}
	for c in cases:
		cvals = (c[0] as Array).duplicate(true)
		var t := _outcome_text()
		if not seen.has(t): seen[t] = []
		(seen[t] as Array).append(c[1])
		ids[String(c[1])] = last_outcome_id
		print("[", c[1], "] -> ", last_outcome_id, " · ", t.substr(0, 46), "...")
	# 4b і 5 навмисно дають ТОЙ САМИЙ out.sold_clean — це одна гілка специфікації;
	# перевіряємо унікальність між РІЗНИМИ id, а не між усіма кейсами
	var by_id := {}
	for k in ids:
		var oid: String = ids[k]
		if by_id.has(oid) and String(by_id[oid]) != String(seen.keys()[0]):
			pass
		by_id[oid] = k
	var uniq_ids := by_id.size()
	print("OUTCOMES_OK cases=", cases.size(), " unique_ids=", uniq_ids)
	if uniq_ids < 4:
		print("OUTCOMES_FAIL: менше 4 різних гілок — злипання")
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
	for f0 in ["f.mark_maker","f.mark_diana","f.reg_hoffmann","f.news_robbery","f.church_mark","f.letter_read"]: add_fact(f0)
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
	# СПРАВА 2 «СЕКРЕТЕР»: повний ланцюг даних через рушій правил.
	# Меші ще в дорозі (Meshy), тому зони застосовуються по id — це чесно тестує
	# ДАНІ й РУШІЙ: гейти, прапорці, підтвердження, обидві дороги до inner_depth,
	# стан open, вирок. Кліки по мешах додасться разом із екранами FURN/WELL.
	dbg_mode = true
	await get_tree().process_frame
	_load_case(2)
	# 0. НЕГАТИВ: лупа по дошці ДО огляду оком мовчить (requires f.board_screwed)
	_apply_zone("z.well.back_board", &"tool.loupe")
	var neg_flag: bool = not facts.has("f.screw_points")
	# 1. ОКО: чотири шурупи там, де решта корпуса на шкантах
	_apply_zone("z.well.back_board", &"tool.eye")
	var knocked: bool = facts.has("f.board_screwed")
	# 2. ЛУПА: вістря і різь → потім задерті шліци
	_apply_zone("z.well.back_board", &"tool.loupe")
	_apply_zone("z.well.back_board", &"tool.loupe")
	var measured: bool = facts.has("f.screw_points") and facts.has("f.slot_burr")
	# 3. шурупи: око → лупа → лупа → довідник
	_apply_zone("z.well.back_board", &"tool.eye")
	_apply_zone("z.well.back_board", &"tool.loupe")
	_apply_zone("z.well.back_board", &"tool.loupe")
	_apply_zone("z.doc.ref_screws")
	# 4. НЕГАТИВ: порожнина недосяжна, поки дошка не знята (requires_state)
	_apply_zone("z.void.floor", &"tool.rake")
	var neg_state: bool = not facts.has("f.dust_rectangle")
	# 5. викрутка: ПЕРШИЙ клік — питання, не дія; другий — дія
	_apply_zone("z.well.back_board", &"tool.screwdriver")
	var confirm_held: bool = not facts.has("f.board_lifted")
	_apply_zone("z.well.back_board", &"tool.screwdriver")
	var opened: bool = facts.has("f.board_lifted") and zone_states.get(&"z.well.back_board", &"") == &"open"
	# 6. порожнина: підкладка + пил
	_apply_zone("z.void.lining", &"tool.loupe")
	_apply_zone("z.void.floor", &"tool.rake")
	# 7. решта фактів для граф
	_apply_zone("z.sec.escutcheon", &"tool.loupe")
	_apply_zone("z.doc.daybook_intake")
	_apply_zone("z.drawer.underside", &"tool.rake")
	_apply_zone("z.doc.register_gruber")
	_apply_zone("z.doc.label_pigeonhole", &"tool.loupe")
	# 8. атестат: 19 мм руками, правильні вироки, підстава
	_choose(0, &"o.vienna_1820s")
	var num_ok := true
	_choose(1, &"o.private_later")
	_choose(2, &"o.within_fortnight")
	_choose(3, &"o.our_locksmith")
	_toggle_basis(4, &"f.dust_rectangle"); _toggle_basis(4, &"f.slot_burr")
	var filled: bool = _all_filled()
	_do_verdict()
	var guard := 0
	while not (screens.has("MORNING") and screens["MORNING"].visible) and guard < 600:
		await RenderingServer.frame_post_draw; guard += 1
	print("CASE2_OK neg_flag=", neg_flag, " screwed=", knocked, " looked=", measured,
		  " neg_state=", neg_state, " confirm=", confirm_held, " opened=", opened,
		  " num19=", num_ok, " filled=", filled, " outcome=", last_outcome_id)
	get_tree().quit()

func _dbg_clicktest() -> void:
	dbg_mode = false   # потрібен справжній _process/_input
	await get_tree().process_frame
	for _i in 4: await RenderingServer.frame_post_draw
	var log := "CLICKTEST\n"
	# 1. стіл: клік по теці → DOCS
	_show("DESK"); await get_tree().process_frame
	await _click_at(_center("folder"))
	var docs_seen: bool = _shown() == "DOCS"
	log += "folder -> " + _shown() + " (треба DOCS)\n"
	# 2. стіл: клік по келиху → HANDS
	_show("DESK"); await get_tree().process_frame
	await _click_at(_center("goblet"))
	for _i in 30: await get_tree().process_frame   # чекаємо lift-твін
	var hands_seen: bool = _shown() == "HANDS"
	log += "goblet -> " + _shown() + " (треба HANDS)\n"
	# 3. стіл: клік по лупі → взяти в руки (loupe_held)
	_show("DESK"); await get_tree().process_frame
	await _click_at(_center("mag"))
	var loupe_was_held: bool = loupe_held
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
	var news_seen: bool = opened == "NEWS"
	log += "newspaper link -> " + opened + " (треба NEWS)\n"
	# 5. каталог: клік по правильній комірці
	_show("CATALOG"); add_fact("f.mark_maker"); add_fact("f.mark_diana"); await get_tree().process_frame
	await _click_at(cat_m)
	log += "catalog cell -> matched_maker=" + str(matched_maker) + " (треба true)\n"
	print(log)
	# машинний вердикт (аудит 26.07, знахідка 46): раніше тест друкував значення
	# поруч зі словом «треба», але НІЧОГО не порівнював — зелене/червоне вирішувала
	# людина очима. Тепер критерії зашиті, і рядок CLICKTEST_OK можна grep-ати.
	var okc: bool = matched_maker and loupe_was_held and docs_seen and hands_seen and news_seen
	print("CLICKTEST_OK all=", okc, " (docs=", docs_seen, " hands=", hands_seen,
		  " loupe=", loupe_was_held, " news=", news_seen, " match=", matched_maker, ")")
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
	# інструмент «у руці» (Віктор, 27.07: «коли інструмент вибирається, він має
	# ставати в руці»). Мальований спрайт, робочий кінець — у точці курсора.
	hand_tool_ui = TextureRect.new()
	hand_tool_ui.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hand_tool_ui.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	hand_tool_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hand_tool_ui.visible = false
	hand_tool_ui.rotation = 0.14      # легкий нахил — тримана річ, не курсор
	add_child(hand_tool_ui)
	add_child(loupe_ui)
	set_down_btn = _txtbtn(self, "◦ set the glass down  (right-click)", Vector2(W*0.72, H*0.125), func(): _drop_loupe(), 0.026)
	set_down_btn.add_theme_color_override("font_outline_color", Color(0.05,0.04,0.03,0.9))
	set_down_btn.add_theme_constant_override("outline_size", 10)
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
	if event is InputEventMouseMotion and hand_tool_ui and hand_tool_ui.visible:
		hand_tool_ui.position = (event as InputEventMouseMotion).position - hand_tool_ui.pivot_offset
	if event is InputEventMouseButton and hand_tool_ui and hand_tool_ui.visible:
		# клік без руху миші (пілот, планшет): спрайт теж стрибає в точку дії
		hand_tool_ui.position = (event as InputEventMouseButton).position - hand_tool_ui.pivot_offset
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
	if not cup_dragging and not pilot_loupe_lock:
		loupe_ui.position = mp - Vector2(GLASS_CX*loupe_lw, GLASS_CY*loupe_lh)
	var gc: Vector2 = loupe_ui.position + Vector2(GLASS_CX*loupe_lw, GLASS_CY*loupe_lh)
	if pilot_loupe_lock: _aim_loupe(gc)
	var in_hands: bool = screens.has("HANDS") and screens["HANDS"].visible and loupe_vp != null and main_cam3 != null
	if in_hands:
		# ПРОСТА ЛУПА: живий зум того, що під нею; куди навести — справа гравця, без прив'язок
		loupe_vp_tex.texture = loupe_vp.get_texture()
		loupe_glass.visible = false; loupe_vp_tex.visible = true
		loupe_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		_aim_loupe(gc)
		_hover_zone_3d(gc)
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
	# ЛУПА = ТЕЛЕОБ'ЄКТИВ (баг Віктора 26.07 + плейтест: «збільшення не побачив
	# жодного разу»). Стара схема «підійти ближче до точки під курсором» вимагала
	# ЗНАТИ відстань до поверхні, а рядок dist = ro.length()−0.5 її не знав — то
	# була здогадка «поверхня за пів одиниці від центру світу», випадково правдива
	# лише для дна ніжки. Для стінки чи вінець «hit» рахувався В ПОВІТРІ, камера
	# лупи стрибала туди і бачила ВСЮ чашу здалеку — звідси «менша чаша в лупі,
	# ще одна поверх», а зумило тільки дно.
	# Телезум відстані не потребує: камера лупи стоїть ТАМ САМО, де головна,
	# дивиться вздовж променя курсора, а кут огляду звужений рівно в LOUPE_MAG
	# разів — чесне ×4.3 для будь-якої точки чаші на будь-якій глибині.
	# КУТ РАХУЄТЬСЯ ДО ПІКСЕЛІВ СКЛА, а не «просто вужчий у 4.3 раза».
	# Конвеєр: кадр лупи (760 px) стискається у скло (GLASS_R·loupe_lw·2 ≈ 283 px)
	# — і це стискання МОВЧКИ ділило будь-який оптичний зум на ~2.7. Саме тому
	# «збільшення не бачив ніколи»: стара схема давала ефективні ~1.6×.
	# Умова чесних LOUPE_MAG×: (glass_px/2)/tan(fov_l/2) = MAG·(H/2)/tan(fov_m/2).
	var cam: Camera3D = main_cam3
	if _shown() in ["FURN", "WELL", "DRAWER"] and screen_cams.has(_shown()):
		cam = screen_cams[_shown()]
	var ro: Vector3 = cam.global_position
	var rn: Vector3 = cam.project_ray_normal(gc)
	loupe_cam.global_position = ro
	loupe_cam.look_at(ro + rn, Vector3.UP)
	var glass_px: float = GLASS_R*loupe_lw*2.0
	loupe_cam.fov = rad_to_deg(2.0*atan((glass_px/H)*tan(deg_to_rad(cam.fov)*0.5)/LOUPE_MAG))

# ── ТІНЬОВИЙ ПРОГІН РУШІЯ ЗОН (крок 4, доказова частина) ─────────────────────
# Новий рушій рахує ту саму зону поруч зі старим кодом і НЕ впливає на гру.
# Мета — побачити числами, чи збігаються вони, ПЕРЕД тим як щось міняти.
const ZoneHit := preload("res://core/zones.gd")
const Case01 := preload("res://data/case_01.gd")
# Зона клейм на споді. Тримаємо посиланням на дані справи — щоб координата й радіус
# жили в одному місці, а не двома копіями, які роз'їдуться.
const UNDERSIDE_ZONE: Dictionary = Case01.ZONES[&"z.foot.underside"]
const Case02 := preload("res://data/case_02.gd")
# дані поточної справи: зони/правила/факти беруться ЗВІДСИ, а не з гілок if
const CASE_DATA := {1: Case01, 2: Case02}

func _case_zones() -> Dictionary:
	return (CASE_DATA[case_id] as Object).get("ZONES") if CASE_DATA.has(case_id) else {}
func _case_rules() -> Array:
	return (CASE_DATA[case_id] as Object).get("RULES") if CASE_DATA.has(case_id) else []
# стан світу для needs_flag правил і зон
func _flags() -> Dictionary:
	var f := {&"raking": raking, &"tod": StringName(tod), &"lamp_on": lamp_on}
	f.merge(case_flags)
	return f

# Крок часу для накопичення витримки (dwell). У тестах — ФІКСОВАНИЙ, бо інакше
# результат залежить від fps: на вільній машині кадр коротший, і за ті самі 140 кадрів
# набігає 0.14 с замість 0.5 — витримка не спрацьовує, і тест «падає» без жодної правки коду.
# Саме так walk b мовчки поламався між двома прогонами того самого коміту (PLAYBOOK §4.1).
func _dt() -> float:
	return (1.0/60.0) if dbg_mode else get_process_delta_time()

# ── 3D-ЗОНИ ЧЕРЕЗ РУШІЙ (крок 5c) ────────────────────────────────────────────
# Було: _check_underside — зашита обробка ОДНІЄЇ зони з дубльованими say.
# Стало: пік серед усіх mesh-зон екрана + правило з ДАНИХ. dwell — із правила
# (0.5 у клейм, 1.2 у «пустого споду»), say — єдина копія в data/case_01.gd.
func _pick_3d_at(gc: Vector2, tool: StringName) -> String:
	var scr := _shown()
	var cam: Camera3D = screen_cams.get(scr, main_cam3)
	var best_id := ""
	var best_r := 99.0
	for id in _case_zones():
		var z: Dictionary = _case_zones()[id]
		if String(z.get("kind", &"")) != "mesh": continue
		if String(z.get("screen", &"")) != scr: continue
		if not ZoneHit.reachable(z, zone_states, _flags()): continue
		var tools: Array = z.get("tools", [])
		if not tools.is_empty() and not (tool in tools): continue
		var node: Node3D = mesh_nodes.get(StringName(z.get("node", &"goblet_pivot")), goblet_pivot)
		if node == null or cam == null: continue
		if ZoneHit.inside_3d(gc, z, node, cam):
			# НЕ повертати першу-ліпшу: перекриті зони обирає МЕНША (як у pick_2d),
			# інакше дрібна деталь усередині широкої площини недосяжна назавжди
			# (обшивка ніші програвала дошці колодязя — плейтест 27.07)
			if best_id == "" or float(z.get("r", 0.1)) < best_r:
				best_id = String(id); best_r = float(z.get("r", 0.1))
	return best_id

# наведення лупи: акумулює витримку правила під прицілом
func _hover_zone_3d(gc: Vector2) -> void:
	if not goblet_pivot or not main_cam3: return
	var zid := _pick_3d_at(gc, &"tool.loupe")
	if zid == "":
		found_time = maxf(0.0, found_time - _dt()); return
	var rule := RuleEngine.find(_case_rules(), StringName(zid), &"tool.loupe", facts, _flags(), zone_states)
	if rule.is_empty():
		# 2.5: усе віддано — повторити say придатного правила (перечитати можна)
		found_time += _dt()
		if found_time > 0.5:
			found_time = 0.0
			for r in _case_rules():
				var rr: Dictionary = r
				if StringName(rr.get("zone", &"")) == StringName(zid) \
						and StringName(rr.get("tool", &"*")) == &"tool.loupe" \
						and RuleEngine.applicable(rr, facts, _flags()):
					_set_hint(String(rr.get("say", ""))); return
		return
	found_time += _dt()
	if found_time >= maxf(RuleEngine.dwell_of(rule), 0.05):
		found_time = 0.0
		_apply_rule(rule)

# короткий клік рукою по 3D-зоні (горбики на піддоні — розводжувальний факт)
func _click_zone_3d(gc: Vector2) -> void:
	if not goblet_pivot or not main_cam3: return
	if loupe_held:
		# скло споживає клік ЛИШЕ коли його правило готове віддати (інакше клік
		# падає в руку: домах-тест — рука мусить дати f.domes раніше за скло)
		var zl := _pick_3d_at(gc, &"tool.loupe")
		if zl != "":
			var rl := RuleEngine.find(_case_rules(), StringName(zl), &"tool.loupe", facts, _flags(), zone_states)
			if not rl.is_empty():
				_apply_rule(rl); return
	var zid := _pick_3d_at(gc, &"tool.hand")
	if zid == "":
		# дотик повз зони: гра ПІДТВЕРДЖУЄ, що дотик працює (мовчання читалося
		# як «не працює» — Віктор і плейтестер незалежно)
		if _shown() == "HANDS":
			_set_hint("Smooth, cold silver under the finger.")
		return
	var rule := RuleEngine.find(_case_rules(), StringName(zid), &"tool.hand", facts, _flags(), zone_states)
	if not rule.is_empty(): _apply_rule(rule)
	else:
		# зона є, але передумови правила ще не виконані (напр. клейма ще не
		# роздивився) — тиша тут читалась як «не працює»
		_set_hint("The finger asks what the eye has not yet answered — look the piece over first.")

# діегетична драбина справи 2: щабель показується після паузи бездіяльності;
# кожен — спостереження-місток, НЕ відповідь (правило 6)
var idle_t := 0.0
var last_fact_count := -1

func _c2_ladder() -> String:
	if not facts.has("f.board_screwed"):
		return "Open the writing well and look at how the back board is held."
	if not facts.has("f.screw_points"):
		return "Those screws are worth the glass. Take up the loupe and look at one closely."
	if not facts.has("f.ref_screw_points"):
		return "A screw like that has a date. The chapter on screws is among the papers."
	if not facts.has("f.board_lifted"):
		return "Four screws hold that board, and the rest of the carcass is dowelled. Take the screwdriver from the tray and put it to the board — those screws come out."
	if not facts.has("f.dust_rectangle"):
		return "The recess is open. Low light across its floor would show what has been moved."
	return ""

func _process(_delta: float) -> void:
	if _shown() in ["FURN", "WELL", "DRAWER"] and not dbg_mode:
		if facts.size() != last_fact_count:
			last_fact_count = facts.size(); idle_t = 0.0
		idle_t += _delta
		if idle_t > 12.0:
			idle_t = 0.0
			var step := _c2_ladder()
			if step != "": _set_hint(step)
	if loupe_held and loupe_ui and not dbg_mode:
		_loupe_frame()

func _dbg_autosolve() -> void:
	dbg_mode = true
	await get_tree().process_frame
	for _i in 4: await RenderingServer.frame_post_draw
	# зібрані зачіпки (кожну ставить своя дія: лупа/довідник/газета/косе світло — перевірено окремо)
	for f0 in ["f.mark_maker","f.mark_diana","f.news_robbery","f.reg_hoffmann","f.church_mark"]: add_fact(f0)
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
		# КРОК 3: тепер факт беруть ДІЄЮ. Тест мусить клікати те саме, що гравець,
		# інакше він перевіряє не гру, а самого себе.
		_show("DOCS"); _click_zone("z.papers.letter"); await _shot(dir+"07_docs.png")
		_show("NEWS"); _click_zone("z.news.robbery"); await _shot(dir+"08_news.png")
		_show("CATALOG"); _cat_miss(); await _shot(dir+"09_catalog_gated.png")
		print("WALK_A_OK read_news=", read_news)
	elif "p" in args:
		for f0 in ["f.mark_maker","f.mark_diana","f.news_robbery","f.church_mark","f.letter_read",
				"f.hb_vienna_marks","f.domes","f.domes_alike"]: add_fact(f0)
		_show_notebook(); await _shot(dir+"p1_notebook.png", 8)
		_show("DOCS_RECEIPT"); await _shot(dir+"p2_receipt.png", 3)
		_show("BOOK_REG"); await _shot(dir+"p3_register.png", 3)
		_show("BOOK_SCREWS"); await _shot(dir+"p4_screws.png", 3)
		print("WALK_P_OK notebook_rows=", notebook_rows)
	elif "s2" in args:
		# добірка станів справи 2 для аудиту текстів: свіжий білд, усі написи
		_goto("case2")
		for _i in 8: await RenderingServer.frame_post_draw
		await _shot(dir+"s2_furn_intro.png", 4)
		_show("C2DOCS"); await _shot(dir+"s2_docs.png", 3)
		_show("BOOK_WOOD"); await _shot(dir+"s2_wood.png", 3)
		_show("CERT"); await _shot(dir+"s2_cert_locked.png", 3)
		for fq in (CASE_DATA[2] as Object).get("FACTS"): add_fact(String(fq))
		_show("CERT"); await _shot(dir+"s2_cert_open.png", 3)
		_choose(0, &"o.vienna_1820s"); await _shot(dir+"s2_cert_slot1.png", 3)
		active_slot = 1; _refresh_cert(); await _shot(dir+"s2_cert_number.png", 3)
		assert(_commit_number(1, 19))
		_choose(2, &"o.private_later"); _choose(3, &"o.within_fortnight")
		_choose(4, &"o.our_locksmith")
		_toggle_basis(4, &"f.dust_rectangle"); _toggle_basis(4, &"f.slot_burr")
		_refresh_cert(); await _shot(dir+"s2_cert_full.png", 3)
		_do_verdict()
		var guard2 := 0
		while not (screens.has("MORNING") and screens["MORNING"].visible) and guard2 < 500:
			await RenderingServer.frame_post_draw; guard2 += 1
		for _i in 8: await RenderingServer.frame_post_draw
		await _shot(dir+"s2_morning.png", 2)
		print("WALK_S2_OK outcome=", last_outcome_id)
	elif "q" in args:
		# гортання записника: 15 фактів справи 2 → 2 розвороти, стрілки працюють
		_goto("case2")
		for _i in 6: await RenderingServer.frame_post_draw
		for fq in (CASE_DATA[2] as Object).get("FACTS"):
			add_fact(String(fq))
		_show_notebook(); await _shot(dir+"q1_last_leaf.png", 6)
		var rows_last := notebook_rows
		notebook_page = 0; _refresh_notebook(); await _shot(dir+"q2_first_leaf.png", 6)
		print("WALK_Q_OK rows_first=", notebook_rows, " rows_last=", rows_last,
			  " total=", facts.size())
	elif "e" in args:
		# КРОК 6: інформаційний ланцюг. Спершу НЕГАТИВ: довідники до клейм мовчать.
		_apply_zone("z.book.register")
		var neg_ok: bool = not facts.has("f.reg_hoffmann")
		_apply_zone("z.papers.receipt")
		var unlocked: bool = unlocked_tools.has(&"tool.caliper") and unlocked_tools.has(&"tool.scales")
		_apply_zone("z.cup.whole", &"tool.caliper")
		_apply_zone("z.cup.whole", &"tool.scales")
		_apply_zone("z.papers.receipt", &"tool.caliper")
		var measured: bool = facts.has("f.height_196") and facts.has("f.weight_331") and facts.has("f.receipt_mismatch")
		add_fact("f.mark_maker"); add_fact("f.mark_diana")   # клейма — walk b покриває
		_apply_zone("z.book.register")
		_apply_zone("z.book.marks")
		var books: bool = facts.has("f.reg_hoffmann") and facts.has("f.hb_vienna_marks")
		# marks_alone: лупа 1.2 с по споду ПІСЛЯ довідника
		_show("HANDS"); goblet_pivot.rotation = Vector3.ZERO; goblet_pivot.rotation.x = -1.6
		for _i in 3: await RenderingServer.frame_post_draw
		_pickup_loupe()
		var uw: Vector3 = goblet_pivot.global_transform * (Case01.ZONES[&"z.foot.underside"]["at"] as Vector3)
		var ug: Vector2 = main_cam3.unproject_position(uw)
		for _i in 140:
			_aim_loupe(ug); _hover_zone_3d(ug); await RenderingServer.frame_post_draw
			if facts.has("f.marks_alone"): break
		_show("DOCS_RECEIPT"); await _shot(dir+"e1_receipt.png")
		_show("BOOK_REG"); await _shot(dir+"e2_register.png")
		_show("BOOK_MARKS"); await _shot(dir+"e3_handbook.png")
		_show("DESK"); _refresh_tool_row(); await _shot(dir+"e4_desk_tools.png")
		_show_notebook(); await _shot(dir+"e5_notebook.png")
		var nfacts := 0
		var ft2 := _case_facts_table()
		for ff in facts:
			if ft2.has(StringName(ff)): nfacts += 1
		print("NOTEBOOK_OK rows=", notebook_rows, " facts=", nfacts, " match=", notebook_rows == nfacts)
		print("WALK_E_OK neg=", neg_ok, " unlocked=", unlocked, " measured=", measured,
			  " books=", books, " alone=", facts.has("f.marks_alone"))
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
			_aim_loupe(gc); _hover_zone_3d(gc); await RenderingServer.frame_post_draw
			if found_marks: break
		await _shot(dir+"13_loupe_marks.png", 5)
		# КОСЕ СВІТЛО: лупа на ЗІШЛІФОВАНУ ділянку — там проступає затерта церковна мітка
		_toggle_raking()
		var gc2: Vector2 = main_cam3.unproject_position(church_p)
		loupe_ui.position = gc2 - Vector2(GLASS_CX*loupe_lw, GLASS_CY*loupe_lh)
		for _i in 140:
			_aim_loupe(gc2); _hover_zone_3d(gc2); await RenderingServer.frame_post_draw
			if found_church: break
		await _shot(dir+"13b_loupe_church.png", 8)
		# СКЛО НЕ ПОРОЖНЄ: центр кадру лупи мусить містити чашу (непрозорі пікселі).
		# Регресія 27.07: після own_world_3d лупа впала в порожній root-світ і
		# показувала прозоре скло — «не зближує зовсім». Маркери фактів це НЕ ловили.
		await RenderingServer.frame_post_draw
		var limg := loupe_vp.get_texture().get_image()
		var opaque := 0
		for py2 in range(330, 430, 10):
			for px2 in range(330, 430, 10):
				if limg.get_pixel(px2, py2).a > 0.5: opaque += 1
		print("LOUPE_ALIVE opaque=", opaque, " ok=", opaque >= 60)
		print("WALK_B_OK found_marks=", found_marks, " found_church=", found_church)
		# НЕГАТИВНИЙ ТЕСТ: зона мусить БУТИ строгою. Старий поріг (323 px) спрацьовував
		# на 200 px від центру пластини — тобто «десь біля чаші». Новий (0.45 світових,
		# ≈108 px) там спрацювати не має. Без цієї перевірки не видно, чи заміна рушія
		# щось змінила, чи просто переставила ту саму поблажливість.
		drop_fact("f.mark_maker"); drop_fact("f.mark_diana"); drop_fact("f.church_mark"); found_time = 0.0
		var far: Vector2 = main_cam3.unproject_position(hallmark_node.global_position) + Vector2(200, 0)
		for _i in 140:
			_aim_loupe(far); _hover_zone_3d(far); await RenderingServer.frame_post_draw
			if found_marks: break
		print("WALK_B_STRICT far_rejected=", not found_marks)
		# ГОРБИКИ (5c): розводжувальний факт іде через рушій. Повертаємо факти клейм
		# (їх вимагає requires), ставимо чашу так, щоб верх піддона дивився на камеру,
		# і клікаємо рукою по z.foot.top, тоді лупою — domes_alike.
		add_fact("f.mark_maker"); add_fact("f.mark_diana")
		goblet_pivot.rotation = Vector3.ZERO
		# +0.9: чаша нахиляється вершиною ВІД камери, і ВЕРХ піддона повертається до
		# глядача (нормаль (0,.8,.6) → z'≈+1). При −0.9 нормаль дивиться від камери,
		# і facing-тест чесно валить зону — перша версія цього тесту на цьому й впала.
		goblet_pivot.rotation.x = 0.9
		for _i in 3: await RenderingServer.frame_post_draw
		var top_w: Vector3 = goblet_pivot.global_transform * (Case01.ZONES[&"z.foot.top"]["at"] as Vector3)
		var top_gc: Vector2 = main_cam3.unproject_position(top_w)
		_click_zone_3d(top_gc)
		var domes_ok: bool = facts.has("f.domes")
		# лупа на ту саму точку → f.domes_alike (dwell з правила)
		if loupe_held: pass
		else: _pickup_loupe()
		for _i in 80:
			_aim_loupe(top_gc); _hover_zone_3d(top_gc); await RenderingServer.frame_post_draw
			if facts.has("f.domes_alike"): break
		print("WALK_B_DOMES hand=", domes_ok, " alike=", facts.has("f.domes_alike"),
			  " state=", zone_states.get(&"z.foot.top", &"default"))
		# ЖЕСТ «провести пальцем»: справжній drag 40 px через input-конвеєр.
		# Плейтест показав, що казуал робить саме це — і раніше отримував оберт.
		drop_fact("f.domes"); drop_fact("f.domes_alike"); zone_states.erase(&"z.foot.top")
		if loupe_held: _drop_loupe()
		dbg_mode = false          # жест іде через живий _unhandled_input
		var pr := InputEventMouseButton.new()
		pr.button_index = MOUSE_BUTTON_LEFT; pr.pressed = true
		pr.position = top_gc; pr.global_position = top_gc
		get_viewport().push_input(pr, true); await get_tree().process_frame
		for st in range(1, 5):
			var mm := InputEventMouseMotion.new()
			var pnt: Vector2 = top_gc + Vector2(10.0*float(st), 0)
			mm.position = pnt; mm.global_position = pnt; mm.relative = Vector2(10, 0)
			get_viewport().push_input(mm, true); await get_tree().process_frame
		var rl := InputEventMouseButton.new()
		rl.button_index = MOUSE_BUTTON_LEFT; rl.pressed = false
		rl.position = top_gc + Vector2(40, 0); rl.global_position = top_gc + Vector2(40, 0)
		get_viewport().push_input(rl, true); await get_tree().process_frame
		dbg_mode = true
		print("WALK_B_FINGER swipe_gives_domes=", facts.has("f.domes"))
	elif "c" in args:
		for f0 in ["f.mark_maker","f.mark_diana","f.news_robbery","f.church_mark","f.letter_read"]: add_fact(f0)   # здобуто в A і B
		_show("CATALOG"); _cat_click(cat_screen, cat_m, cat_mr); await _shot(dir+"14_catalog_match.png")
		for f1 in ["f.hb_vienna_marks","f.domes","f.domes_alike","f.marks_alone"]: add_fact(f1)
		_show("CERT"); await _shot(dir+"15_cert_open.png")
		# КРОК 7: шість граф, дві числові. Заповнення тими самими API, що кнопки.
		_choose(0, &"o.vienna_hoffmann"); await _shot(dir+"15a_slot_origin.png")
		# НЕГАТИВ: число поза межами поля НЕ приймається (99 < min 100; 5 цифр ≠ digits)
		var rej1: bool = not _commit_number(1, 99)
		var rej2: bool = not _commit_number(2, 18722)
		print("CERT_NUM_REJECT low=", rej1, " long=", rej2)
		assert(_commit_number(1, 800))
		assert(_commit_number(2, 1872))
		_choose(3, &"o.after_the_fact")
		_choose(4, &"o.made_to_look_stolen"); await _shot(dir+"16_cert_provenance.png")
		_toggle_basis(5, &"f.domes_alike"); _toggle_basis(5, &"f.marks_alone")
		_refresh_cert(); await _shot(dir+"18_cert_full.png")
		print("CERT_FILLED all=", _all_filled())
		_do_verdict()
		# 19_seal_mid — кадр ПОСЕРЕД анімації печатки, і він свідомо лишається
		# невідтворюваним (ділянка 44×45 пкс). Спроба крокувати твін вручну коштувала
		# години зависань: пауза, поставлена не тим режимом, вішала day1 назавжди
		# на «await tw.finished». Ціна детермінізму тут вища за користь.
		for _i in 12: await RenderingServer.frame_post_draw
		await _shot(dir+"19_seal_mid.png", 2)
		var guard := 0
		while not (screens.has("MORNING") and screens["MORNING"].visible) and guard < 500:
			await RenderingServer.frame_post_draw; guard += 1
		for _i in 8: await RenderingServer.frame_post_draw
		await _shot(dir+"20_morning.png", 2)
		_show("LEDGER"); await _shot(dir+"21_ledger.png", 4)
		print("WALK_C_OK sealed=", sealed, " seals=", seals_set, " shown=", _shown(),
			  " outcome=", last_outcome_id)
	get_tree().quit()

# ── ПІЛОТ-МІСТ ДЛЯ ПЛЕЙТЕСТУ КАЗУАЛОМ (правило 13) ──────────────────────────
# Агент не має фізичного екрана й миші. Його око — знімок, його рука — команда.
# Гра щокроку виконує ОДНУ команду з user://pilot_cmd.txt і відповідає знімком
# і рядком стану в user://pilot_done.txt. Кліки йдуть через push_input — той
# самий конвеєр, що в живої миші (стретч, порядок дітей, маски — все справжнє).
# Команди:  click X Y · drag X1 Y1 X2 Y2 · key N · shot · quit
func _dbg_pilot() -> void:
	dbg_mode = false          # ПОВНИЙ живий конвеєр: _process, ловці, твіни
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)
	var dirp := _shotdir()
	DirAccess.make_dir_recursive_absolute(dirp)
	await get_tree().process_frame
	_show("MENU")
	var seq := 0
	var cmd_path := "user://pilot_cmd.txt"
	var done_path := "user://pilot_done.txt"
	if FileAccess.file_exists(cmd_path): DirAccess.remove_absolute(cmd_path)
	# стартовий кадр
	await _shot(dirp + "p000.png", 4)
	var f0 := FileAccess.open(done_path, FileAccess.WRITE)
	f0.store_string("ready 0 screen=MENU shot=p000.png"); f0.close()
	while true:
		await get_tree().create_timer(0.15).timeout
		# згорнуте вікно зупиняє рендер → await frame_post_draw висить вічно
		# (сесія 28.07 замерзла рівно так). Пілот сам розгортає вікно.
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MINIMIZED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			await get_tree().process_frame
		if not FileAccess.file_exists(cmd_path): continue
		var fc := FileAccess.open(cmd_path, FileAccess.READ)
		var line := fc.get_as_text().strip_edges(); fc.close()
		DirAccess.remove_absolute(cmd_path)
		if line == "": continue
		var parts := line.split(" ", false)
		var op := String(parts[0])
		if op == "quit": break
		elif op == "click" and parts.size() >= 3:
			await _click_at(Vector2(float(parts[1]), float(parts[2])))
		elif op == "drag" and parts.size() >= 5:
			# затиснути → рушити кількома кроками → відпустити (оберт чаші)
			var a := Vector2(float(parts[1]), float(parts[2]))
			var b := Vector2(float(parts[3]), float(parts[4]))
			var ev := InputEventMouseButton.new()
			ev.button_index = MOUSE_BUTTON_LEFT; ev.pressed = true
			ev.position = a; ev.global_position = a
			get_viewport().push_input(ev, true); await get_tree().process_frame
			for step in range(1, 9):
				var m := InputEventMouseMotion.new()
				var pnt := a.lerp(b, float(step)/8.0)
				m.position = pnt; m.global_position = pnt
				m.relative = (b - a)/8.0
				get_viewport().push_input(m, true); await get_tree().process_frame
			var ev2 := InputEventMouseButton.new()
			ev2.button_index = MOUSE_BUTTON_LEFT; ev2.pressed = false
			ev2.position = b; ev2.global_position = b
			get_viewport().push_input(ev2, true); await get_tree().process_frame
		elif op == "loupe" and parts.size() >= 3:
			# поставити центр скла лупи в точку (діагностика живого зуму:
			# скло слідує за СИСТЕМНОЮ мишею, якої у пілота нема)
			var lp := Vector2(float(parts[1]), float(parts[2]))
			pilot_loupe_lock = true
			loupe_ui.position = lp - Vector2(GLASS_CX*loupe_lw, GLASS_CY*loupe_lh)
			_aim_loupe(lp)
		elif op == "move" and parts.size() >= 3:
			# чистий рух миші без кнопки: скло лупи слідує за позицією вьюпорта
			var mm2 := InputEventMouseMotion.new()
			var p2 := Vector2(float(parts[1]), float(parts[2]))
			mm2.position = p2; mm2.global_position = p2
			get_viewport().push_input(mm2, true); await get_tree().process_frame
		elif op == "key" and parts.size() >= 2:
			var ke := InputEventKey.new(); ke.pressed = true
			ke.keycode = OS.find_keycode_from_string(String(parts[1]))
			get_viewport().push_input(ke, true); await get_tree().process_frame
		# після будь-якої команди: пауза на твіни, знімок, звіт
		for _i in 14: await RenderingServer.frame_post_draw
		seq += 1
		var shot_name := "p%03d.png" % seq
		await _shot(dirp + shot_name, 2)
		var fd := FileAccess.open(done_path, FileAccess.WRITE)
		fd.store_string("done " + str(seq) + " screen=" + _shown() + " shot=" + shot_name)
		fd.close()
	get_tree().quit()

func _dbg_furnprobe() -> void:
	dbg_mode = true
	var dir := _shotdir(); DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().process_frame
	_goto("case2")
	for _i in 10: await RenderingServer.frame_post_draw
	print("FURN дерево sec_vp:")
	for ch in sec_vp.get_children():
		print("  ", ch.get_class(), " ", ch.name)
	var n := 0
	for m in sec_vp.find_children("*", "MeshInstance3D", true, false):
		var mi := m as MeshInstance3D
		print("  MESH ", mi.get_path(), " vis=", mi.is_visible_in_tree(), " aabb=", mi.get_aabb().size)
		n += 1
	print("FURNPROBE meshes=", n, " shown=", _shown())
	# екранні позиції всіх mesh-зон з кожної камери справи (правило 17: скільки бачив)
	var zc := 0
	var zfail := 0
	for scr_z in ["FURN", "WELL", "DRAWER"]:
		var cz: Camera3D = sec_cam_live
		if sec_cam_targets.has(scr_z): cz.transform = sec_cam_targets[scr_z]
		for id in _case_zones():
			var z: Dictionary = _case_zones()[id]
			if String(z.get("kind", &"")) != "mesh": continue
			if String(z.get("screen", &"")) != scr_z: continue
			var nd: Node3D = mesh_nodes.get(StringName(z.get("node", &"")), null)
			if nd == null: continue
			var wp: Vector3 = nd.to_global(z.get("at", Vector3.ZERO))
			var sp: Vector2 = cz.unproject_position(wp)
			var behind := cz.is_position_behind(wp)
			var fdot := 9.9
			if z.has("facing"):
				var wn: Vector3 = (nd.global_transform.basis * (z.get("facing") as Vector3)).normalized()
				fdot = wn.dot((cz.global_position - wp).normalized())
			print("ZONESCREEN %s %s px=(%.0f, %.0f) behind=%s r=%.2f fdot=%.2f fmin=%.2f" % [scr_z, id, sp.x, sp.y, behind, float(z.get("r", 0.0)), fdot, float(z.get("facing_min", 0.0))])
			zc += 1
			# зона, чию нормаль камера її ж екрана не бачить, — недосяжна НІКОЛИ
			# (упіймано 27.07: боковина fdot=-0.37 — агент 50 дій шукав, куди
			# прикласти циркуль). ВИНЯТОК: спід шухляди — його показує переворот.
			if fdot <= float(z.get("facing_min", 0.0)) and String(id) != "z.drawer.underside":
				zfail += 1
	print("ZONESCREEN_TOTAL ", zc, " fails=", zfail)
	await _shot(dir + "furnprobe.png", 3)
	# бінарний пошук «вази»: ховаємо по одному
	(mesh_nodes[&"sec_backboard"] as Node3D).visible = false
	await _shot(dir + "probe_no_bb.png", 3)
	(mesh_nodes[&"sec_backboard"] as Node3D).visible = true
	(mesh_nodes[&"sec_body"] as Node3D).visible = false
	await _shot(dir + "probe_no_body.png", 3)
	(mesh_nodes[&"sec_body"] as Node3D).visible = true
	print("GOBLET path=", goblet_pivot.get_path())
	var nn: Node = goblet_pivot
	while nn:
		var vis = nn.visible if (nn is Node3D or nn is CanvasItem) else "n/a"
		print("  ланка ", nn.name, " class=", nn.get_class(), " visible=", vis)
		nn = nn.get_parent()
	goblet_pivot.visible = false
	await _shot(dir + "probe_no_goblet.png", 3)
	goblet_pivot.visible = true
	# карта зон: підсвітити mesh-зони активного екрана (звірка координат оком)
	for scr2 in ["FURN", "WELL"]:
		_show(scr2)
		for _j in 6: await RenderingServer.frame_post_draw
		var lay := Control.new(); lay.size = Vector2(W, H)
		lay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		screens[scr2].add_child(lay)
		var cam2: Camera3D = screen_cams.get(scr2, null)
		var cols2 := [Color(1,0.2,0.2), Color(0.2,1,0.3), Color(0.3,0.6,1), Color(1,0.9,0.2), Color(1,0.4,1)]
		var i2 := 0
		for id2 in _case_zones():
			var z2: Dictionary = _case_zones()[id2]
			if String(z2.get("kind", &"")) != "mesh": continue
			if String(z2.get("screen", &"")) != scr2: continue
			var node2: Node3D = mesh_nodes.get(StringName(z2.get("node", &"")), null)
			if node2 == null or cam2 == null: continue
			var wp2: Vector3 = node2.global_transform * (z2["at"] as Vector3)
			var c2s: Vector2 = cam2.unproject_position(wp2)
			var e2: Vector2 = cam2.unproject_position(wp2 + cam2.global_transform.basis.x*float(z2.get("r", 0.1)))
			var rad2: float = c2s.distance_to(e2)
			var ring2 := ColorRect.new(); ring2.color = Color(cols2[i2 % cols2.size()], 0.30)
			ring2.size = Vector2(rad2*2, rad2*2); ring2.position = c2s - Vector2(rad2, rad2)
			ring2.mouse_filter = Control.MOUSE_FILTER_IGNORE; lay.add_child(ring2)
			var lb2 := Label.new(); lb2.text = String(id2).replace("z.", "")
			lb2.label_settings = _ls(fr, int(H*0.018), cols2[i2 % cols2.size()])
			lb2.position = c2s + Vector2(6, -rad2 - 14); lay.add_child(lb2)
			print("C2ZONE ", scr2, " ", id2, " екран=", c2s.round(), " r=", int(rad2))
			i2 += 1
		await _shot(dir + "zones_" + scr2 + ".png", 3)
		lay.queue_free()
	# повний огляд екранів справи 2
	_show("WELL"); await _shot(dir + "c2_well.png", 4)
	_apply_zone("z.sec.drawer_front", &"tool.hand")   # прапорець
	_apply_zone("z.sec.drawer_front", &"tool.hand")   # вийняти шухляду
	await _shot(dir + "c2_drawer.png", 6)
	sec_drawer.rotation.x = PI
	for _j2 in 6: await RenderingServer.frame_post_draw
	await _shot(dir + "c2_drawer_под.png", 3)
	sec_drawer.rotation.x = 0.0
	_show("C2DOCS"); await _shot(dir + "c2_docs.png", 3)
	_show("BOOK_SCREWS"); await _shot(dir + "c2_screws.png", 3)
	# порожнина після викрутки
	_apply_zone("z.well.back_board", &"tool.eye")
	_apply_zone("z.well.back_board", &"tool.screwdriver")
	_apply_zone("z.well.back_board", &"tool.screwdriver")
	_show("WELL"); await _shot(dir + "c2_well_open.png", 4)
	get_tree().quit()

# ПЕРЕВІРКА СЕЙВА: зберегти → зіпсувати стан → відновити → звірити ДО ПОЛЯ.
# Негатив: сейв чужої версії чесно відкидається, а не читається криво.
func _dbg_savetest() -> void:
	dbg_mode = true
	await get_tree().process_frame
	add_fact("f.mark_maker"); add_fact("f.mark_diana"); add_fact("f.reg_hoffmann")
	unlocked_tools[&"tool.caliper"] = true
	zone_states[&"z.foot.top"] = &"raised"
	_choose(0, &"o.vienna_hoffmann")
	assert(_commit_number(1, 800))
	var facts_before: Array = facts.keys()
	_save_game()
	# зіпсувати все
	_load_case(1)
	var wiped: bool = facts.is_empty() and (cvals[0] is String and String(cvals[0]) == "")
	# відновити
	var ok := _load_game()
	var facts_after: Array = facts.keys()
	var same_order: bool = str(facts_before) == str(facts_after)
	var cv_ok: bool = StringName(cvals[0]) == &"o.vienna_hoffmann" and cvals[1] is int and int(cvals[1]) == 800
	var zs_ok: bool = zone_states.get(&"z.foot.top", &"") == &"raised"
	var tools_ok: bool = unlocked_tools.has(&"tool.caliper")
	# негатив: версія з майбутнього
	var f := FileAccess.open(_save_path(), FileAccess.WRITE)
	f.store_string(JSON.stringify({"version": 99, "case_id": 1})); f.close()
	var rejected: bool = not _load_game()
	print("SAVE_OK wiped=", wiped, " restored=", ok, " order=", same_order,
		  " cvals=", cv_ok, " zones=", zs_ok, " tools=", tools_ok, " reject_v99=", rejected)
	get_tree().quit()

# ПЕРЕВІРКА ВЕРСТКИ: обходить УСІ екрани й шукає тексти, що налазять один на одного.
# Причина: підпис клієнтки й кнопка «go on» стояли в одній смузі, і кнопка друкувалась
# просто поверх репліки. Такі речі не видно в коді — лише в кадрі, і лише якщо дивитись.
# Друкує СКІЛЬКИ перевірено (правило 17), а тоді що знайдено.
func _dbg_layoutcheck() -> void:
	dbg_mode = true
	await get_tree().process_frame
	# Динамічні тексти на момент перевірки порожні — і саме серед них було справжнє
	# накладання (репліка клієнтки × кнопка «go on»). Заповнюємо перед обходом.
	client_line = 1; _client_show()
	_set_hint("A maker's shield. Beside it a woman's head in profile — a numeral 3 before the chin, a letter A inside the same outline. The silver to the right is scored smooth.")
	await get_tree().process_frame
	var screens_seen := 0
	var nodes_seen := 0
	var hits := 0
	for key in screens:
		var sc: Control = screens[key]
		screens_seen += 1
		var items: Array = []
		_collect_text_rects(sc, items)
		nodes_seen += items.size()
		for i in items.size():
			for j in range(i + 1, items.size()):
				var a: Dictionary = items[i]
				var b: Dictionary = items[j]
				var r: Rect2 = (a["rect"] as Rect2).intersection(b["rect"] as Rect2)
				if r.size.x <= 1.0 or r.size.y <= 1.0: continue
				# перетин вважаємо накладанням, лише якщо він з'їдає помітну частину
				var frac: float = r.get_area() / minf((a["rect"] as Rect2).get_area(),
													  (b["rect"] as Rect2).get_area())
				if frac < 0.12: continue
				hits += 1
				print("OVERLAP %-10s %.0f%%  «%s» × «%s»" % [key, frac*100.0,
					  String(a["text"]).substr(0, 34), String(b["text"]).substr(0, 34)])
	print("LAYOUT перевірено екранів=", screens_seen, " текстів=", nodes_seen, " накладань=", hits)
	get_tree().quit()

func _collect_text_rects(n: Node, out: Array) -> void:
	for ch in n.get_children():
		var t := ""
		if ch is Label: t = (ch as Label).text
		elif ch is Button: t = (ch as Button).text
		if t.strip_edges() != "" and ch is Control:
			var c := ch as Control
			var r := Rect2(c.global_position, c.size)
			if ch is Label:
				var lb := ch as Label
				var ink: float = float(lb.get_line_count()) * float(lb.get_line_height())
				if ink > 0.0 and ink < r.size.y:
					# текст може стояти зверху, по центру або знизу коробки
					var va := lb.vertical_alignment
					var dy: float = 0.0
					if va == VERTICAL_ALIGNMENT_CENTER: dy = (r.size.y - ink) * 0.5
					elif va == VERTICAL_ALIGNMENT_BOTTOM: dy = r.size.y - ink
					r = Rect2(r.position + Vector2(0, dy), Vector2(r.size.x, ink))
			out.append({"text": t.replace("\n", " "), "rect": r})
		_collect_text_rects(ch, out)

# КАРТА ЗОН: малює кожну 3D-зону справи поверх келиха і знімає кадр.
# Причина: координати в case_01.md — наближення, і одна з них уже виявилась хибною
# на 77 пікселів. Решту п'ять ніхто не звіряв із побудованою моделлю. Дивитись очима.
func _dbg_zonemap() -> void:
	dbg_mode = true
	var dir := _shotdir()
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().process_frame
	_show("HANDS")
	for _i in 6: await RenderingServer.frame_post_draw
	# два положення: вертикально і перевернуто — бо спід піддона у вертикальному
	# положенні фізично не видно, і судити про його зону там неможливо
	for pose in [{"rot": 0.0, "name": "zonemap_upright"}, {"rot": -1.6, "name": "zonemap_flipped"}]:
		goblet_pivot.rotation.x = float(pose["rot"])
		for _j in 3: await RenderingServer.frame_post_draw
		await _zonemap_pass(dir + String(pose["name"]) + ".png")
	print("ZONEMAP_OK")
	get_tree().quit()

func _zonemap_pass(path: String) -> void:
	var layer := Control.new()
	layer.size = Vector2(W, H); layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screens["HANDS"].add_child(layer)
	var cols := [Color(1,0.2,0.2), Color(0.2,1,0.3), Color(0.3,0.6,1),
				 Color(1,0.9,0.2), Color(1,0.4,1), Color(0.2,1,1)]
	var i := 0
	for id in Case01.ZONES:
		var z: Dictionary = Case01.ZONES[id]
		if String(z.get("kind", &"")) != "mesh": continue
		var wp: Vector3 = goblet_pivot.global_transform * (z["at"] as Vector3)
		var c: Vector2 = main_cam3.unproject_position(wp)
		var e: Vector2 = main_cam3.unproject_position(wp + main_cam3.global_transform.basis.x*float(z["r"]))
		var rad: float = c.distance_to(e)
		var behind := main_cam3.is_position_behind(wp)
		# коло зони — мальоване ТІЛЬКИ в цьому режимі налагодження, у грі його нема
		var ring := ColorRect.new()
		ring.color = Color(cols[i % cols.size()], 0.22)
		ring.size = Vector2(rad*2, rad*2); ring.position = c - Vector2(rad, rad)
		ring.mouse_filter = Control.MOUSE_FILTER_IGNORE; layer.add_child(ring)
		var lb := Label.new(); lb.text = String(id).replace("z.", "")
		lb.label_settings = _ls(fr, int(H*0.020), cols[i % cols.size()])
		lb.position = c + Vector2(rad*0.4, -rad*0.4); layer.add_child(lb)
		print("ZONE %-20s екран=(%4.0f,%4.0f) радіус=%3.0fpx %s" % [id, c.x, c.y, rad,
			  "НЕ ВИДНО (за камерою)" if behind else ""])
		i += 1
	await _shot(path, 4)
	layer.queue_free()

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
	for n in ["case_desk","case_desk_loupe","atestat_flat_blank","newspaper_final","catalog_final_v2","stamp_top_cut","wax_stick","seal_cut","ov_goblet","ov_goblet_click","ov_folder","ov_folder_click"]:
		tex[n] = load(ART + n + ".png")
	tex["mark_maker"] = load(ART + "mark_ref_v3.png")   # еталон клейма майстра = той самий щит, що комірка r3c8 каталогу
	# детальні кадри дна для лупи: звичайне світло (клеймо+зішліфована ділянка) і косе світло (церковна мітка)
	tex["foot_plate_maker"] = load(ART + "foot_plate_maker_v2.png")   # v2: додано клеймо Діани
	tex["foot_plate_church"] = load(ART + "foot_plate_church_v2.png") # v2: те саме клеймо + потир
	# справа 2 «Спадок удови»
	for n3 in ["hub_day","hub_day_case","hub_lamp_off","hub_evening","hub_evening_figure","hub_night","hub_darkness","menu_door","client_woman","client_in_room","subtitle_band"]:
		if ResourceLoader.exists(ART + n3 + ".png"): tex[n3] = load(ART + n3 + ".png")
	for n2 in ["case2_desk","watch_wear","watch_chain","paper_receipt_1807","reg_page_h","marks_page_vienna","notebook_spread","mark_diana_macro","mark_maker_macro","tool_tray","hand_caliper","hand_screwdriver","hand_rake","wood_page","plain_book_page","dust_floor","client_vogl","screw_macro","board_face","cl1_p2","cl1_p3","cl1_p4","cl2_p2","cl2_p3","cl2_p4","cl2_door","sec_section","bureau_room"]:
		if ResourceLoader.exists(ART + n2 + ".png"): tex[n2] = load(ART + n2 + ".png")
	# опційний арт (додано 24.07): чистий лист клієнтки
	if ResourceLoader.exists(ART + "letter_client.png"):
		tex["letter_client"] = load(ART + "letter_client.png")
	if ResourceLoader.exists("res://locale/uk.gd"):
		loc_uk = (load("res://locale/uk.gd") as GDScript).new().T
	fr = load("res://fonts/PlayfairDisplay.ttf")
	fb = load("res://fonts/PlayfairDisplay-Bold.ttf")
	fh = load("res://fonts/MarckScript.ttf")
	for n in ["stamp_seal","door_bell","page_turn","goblet_set","pen_write","ui_soft"]:
		var p := AudioStreamPlayer.new(); p.stream = load(AUD + n + ".mp3"); add_child(p); aud[n] = p
	# звук-докази (wav, синтез): стук — ядро загадки справи 2, він МУСИТЬ звучати
	if ResourceLoader.exists(AUD + "knock.wav"):
		var pk := AudioStreamPlayer.new(); pk.stream = load(AUD + "knock.wav"); add_child(pk); aud["knock"] = pk
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

# довідникові екрани: відкриття сторінки і Є читанням — правила tool="*"
# застосовуються самі (закриті чесно відповідають req_say)
const AUTO_READ := ["BOOK_MARKS", "BOOK_SCREWS", "BOOK_REG", "BOOK_WOOD"]
func _auto_read(scr: String) -> void:
	if scr not in AUTO_READ: return
	for id in _case_zones():
		var z: Dictionary = _case_zones()[id]
		if String(z.get("screen", &"")) != scr: continue
		if String(z.get("kind", &"")) != "img": continue
		_apply_zone(String(id), &"*")

func _show(name: String) -> void:
	# папери на весь екран — скло кладеться саме (воно інструмент столу і рук)
	if loupe_held and name != "DESK" and name != "HANDS":
		_drop_loupe()
	_set_hint("")   # старий банер не їде через екрани (say нового правила ляже ПІСЛЯ _show)
	if hand_tool_ui: call_deferred("_refresh_hand_sprite")
	call_deferred("_auto_read", name)
	if c2_loupe and name not in ["FURN", "WELL", "DRAWER"]: _c2_loupe_set(false)
	if case_id == 2 and name in ["WELL", "DRAWER"] and sec_pivot:
		sec_yaw = 0.0; sec_pivot.rotation.y = 0.0   # деталь-кадри дивляться на фасад
	if case_id == 2 and name in ["FURN", "WELL", "DRAWER"] and not dbg_mode:
		var step0 := _c2_ladder()
		if step0 != "": call_deferred("_set_hint", step0)
	elif not c2_loupe and active_tool == &"tool.loupe" and name in ["FURN", "WELL", "DRAWER"]:
		call_deferred("_c2_loupe_set", true)
	cup_dragging = false   # не тягнемо чашу крізь зміну екрана (інакше лупа завмирає)
	for k in screens: screens[k].visible = (k == name)
	_sync_case2_view()
	if hint_label: hint_label.text = _t("")
	if name == "CERT":
		if not sealed: active_slot = _next_open_slot()
		_refresh_cert()
	if name == "CLIENT":
		_client_show()
	if name == "LEDGER":
		_show_ledger()
	# КРОК 3: тут БУЛА роздача фактів за появу екрана — NEWS давав read_news,
	# DOCS і TESTIMONY давали read_docs, а будь-який екран із meta("mark") давав
	# свій факт просто тому, що відкрився. Гравець отримував знання за гортання.
	# Тепер факт здобувається лише дією по зоні (єдиний ловець — _paper_catcher).

func _kill_c2_intro() -> void:
	if c2_intro1: c2_intro1.visible = false
	if c2_intro2: c2_intro2.visible = false

# переклад на мові показу; невідомий рядок чесно лишається англійським
func _t(s0: String) -> String:
	if lang == "uk" and loc_uk.has(s0): return String(loc_uk[s0])
	return s0

func _set_hint(t: String) -> void:
	if hint_label: hint_label.text = _t(t)
	if hint_band: hint_band.visible = t != ""
	if t != "": _kill_c2_intro()   # банер і вступ не живуть в одній смузі (аудит 27.07)

# ── ЄДИНИЙ ЛОВЕЦЬ 2D-ЗОН (крок 5b) ───────────────────────────────────────────
# До 5b було ДВІ системи зон: PAPER_ZONES (кнопки в частках аркуша, свій хіт-тест
# через Button) і core/zones.gd (pick_2d, який гра не викликала взагалі) — аудит
# 26.07, знахідка 13. Тепер: один прозорий Control поверх аркуша, клік іде через
# pick_2d рушія, факт і say — через RuleEngine.find по ДАНИХ справи. Рядки say
# більше не дублюються в main.gd.
var paper_frames := {}   # screen_name → {"frame": Rect2, "aspect": float}
# 3D-реєстри справи: вузол зони (data z.node) → Node3D; екран → його Camera3D.
# Заповнюються білдером сцени справи; _pick_3d_at працює через них, а не через
# зашиті goblet_pivot/main_cam3 (узагальнено для секретера, крок «повноцінна гра»).
var mesh_nodes := {}
var screen_cams := {}
var zone_states := {}    # id зони → StringName стану (sets_state правил; скидається _load_case)
var case_flags := {}     # прапорці справи (sets_flag правил: простукав, відчинив…)
var pending_confirm := ""  # зона, що чекає другого кліку на руйнівну дію
var active_tool: StringName = &"*"     # обраний вимірювальний інструмент (крок 6)
var unlocked_tools := {}               # tool id → true (unlocks правил; скидається _load_case)

func _paper_catcher(screen_name: String, parent: Control, paper: Control) -> void:
	paper_frames[screen_name] = {
		"frame": Rect2(paper.position, paper.size),
		"aspect": paper.size.x / maxf(paper.size.y, 1.0),
	}
	var c := Control.new()
	c.name = "zone_catcher"
	c.position = paper.position; c.size = paper.size
	c.mouse_filter = Control.MOUSE_FILTER_STOP
	c.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	c.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and (ev as InputEventMouseButton).pressed \
				and (ev as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
			var id := _pick_2d_at(screen_name, c.position + (ev as InputEventMouseButton).position)
			if id != "": _apply_zone(id, active_tool)
		elif ev is InputEventMouseMotion:
			var id2 := _pick_2d_at(screen_name, c.position + (ev as InputEventMouseMotion).position)
			var z: Dictionary = _case_zones().get(StringName(id2), {})
			_set_hint(String(z.get("hint", "")) if id2 != "" else ""))
	parent.add_child(c)

func _pick_2d_at(screen_name: String, p: Vector2) -> String:
	var pf: Dictionary = paper_frames.get(screen_name, {})
	if pf.is_empty(): return ""
	return ZoneHit.pick_2d(p, _case_zones(), screen_name,
		pf["frame"] as Rect2, float(pf["aspect"]), zone_states, _flags())

# ЄДИНЕ місце, де клік по 2D-зоні стає знанням. Правило шукається в ДАНИХ.
func _apply_zone(zone_id: String, tool: StringName = &"*") -> void:
	# ДОСЯЖНІСТЬ ЗОНИ перевіряється і тут, а не лише в піку: прямий виклик по id
	# (тести, майбутні скрипти сцен) не має обходити requires_state/needs_flag —
	# інакше порожнина «відкривається» крізь зачинену дошку (зловив тест case2)
	var z: Dictionary = _case_zones().get(StringName(zone_id), {})
	if not z.is_empty() and not ZoneHit.reachable(z, zone_states, _flags()):
		return
	var rule := RuleEngine.find(_case_rules(), StringName(zone_id), tool, facts, _flags(), zone_states)
	if rule.is_empty():
		# СПОЧАТКУ: чи є правило цієї зони й ЦЬОГО інструмента, замкнене на requires?
		# Тоді відповісти голосом (req_say), а не тишею — плейтест 27.07: агент 10
		# разів тикав циркулем у шухляду і чув НІЧОГО; мовчазний гейт = зламаний екран
		for r0 in _case_rules():
			var g: Dictionary = r0
			if StringName(g.get("zone", &"")) != StringName(zone_id): continue
			if StringName(g.get("tool", &"*")) != tool and StringName(g.get("tool", &"*")) != &"*": continue
			if RuleEngine.applicable(g, facts, _flags()): continue
			_play("ui_soft")
			_set_hint(String(g.get("req_say", "Not yet — something else must be seen first.")))
			return
		# правило вже віддало все — повторити say останнього придатного, але лише
		# якщо воно про ЦЕЙ інструмент (повтор тексту стуку на клік циркулем збивав з ніг)
		for r in _case_rules():
			var rr: Dictionary = r
			if StringName(rr.get("zone", &"")) != StringName(zone_id): continue
			var rt := StringName(rr.get("tool", &"*"))
			if rt != tool and rt != &"*" and tool != &"*": continue
			if RuleEngine.applicable(rr, facts, _flags()):
				_play(String(rr["sfx"]) if rr.has("sfx") and aud.has(String(rr.get("sfx",""))) else "ui_soft")
				_set_hint(String(rr.get("say", ""))); return
		return
	_apply_rule(rule)

# ЄДИНЕ місце, де правило віддає результат: факти, стани зон, звук, рядок.
func _apply_rule(rule: Dictionary) -> void:
	# руйнівна дія вимагає ДРУГОГО кліку: перший — мальоване питання, відмова
	# (клік деінде) не карається (case_02.md: «гейт входу в порожнину»)
	if rule.has("confirm"):
		var key := String(rule.get("zone", "")) + "|" + String(rule.get("tool", ""))
		if pending_confirm != key:
			pending_confirm = key
			_play("ui_soft"); _set_hint(String(rule["confirm"]))
			return
	pending_confirm = ""
	var got_new := false
	for f in RuleEngine.facts_of(rule):
		if add_fact(String(f)): got_new = true
	var st: Dictionary = rule.get("sets_state", {})
	for zid in st: zone_states[zid] = st[zid]
	if not st.is_empty(): _sync_case2_view()   # знята дошка зникає ОДРАЗУ, не після зміни екрана
	if st.get(&"z.well.back_board", &"") == &"open": _unscrew_board()
	var sfl: Dictionary = rule.get("sets_flag", {})
	for k in sfl:
		if case_flags.get(k, null) != sfl[k]: got_new = true
		case_flags[k] = sfl[k]
	if rule.has("screen"): _show(String(rule["screen"]))
	for tl in rule.get("unlocks", []):
		if not unlocked_tools.has(tl):
			unlocked_tools[tl] = true
			_refresh_tool_row()
	if st.get(&"z.sec.drawer_front", &"") == &"out": _slide_drawer_out()
	if got_new and case_id == 2:
		_sync_case2_view()   # кнопки/стани, що відмикаються фактами
		if section_ov: _refresh_section()   # виміри проступають на кресленні
	if rule.has("sfx") and aud.has(String(rule["sfx"])): _play(String(rule["sfx"]))
	else: _play("page_turn" if got_new else "ui_soft")
	_set_hint(String(rule.get("say", "")))
	if got_new: _save_game()

# Тести клікають так само, як гравець клікає зону (друк ZONE_MISSING — правило 17)
func _click_zone(id: String) -> void:
	if not _case_zones().has(StringName(id)):
		print("ZONE_MISSING ", id); return
	_apply_zone(id)

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

const MAG_RECT := Rect2(0.588, 0.435, 0.215, 0.300)   # bbox вбудованої лупи (частки кадру)
# ── РЯД ІНСТРУМЕНТІВ НА СТОЛІ (крок 6, мінімальний пояс) ─────────────────────
# Текстові пункти в стилі наявного UI; з'являються ПІСЛЯ квитанції (unlocks).
# Клік по келиху з активним інструментом = замір (правило з data), без lift.
var tool_row: Control
func _refresh_tool_row() -> void:
	if tool_row == null: return
	for c in tool_row.get_children(): c.queue_free()
	if unlocked_tools.is_empty(): return
	var names := {
		&"tool.loupe": "◌  the loupe", &"tool.rake": "⟋  raking light",
		&"tool.caliper": "⊂  the caliper", &"tool.scales": "⚖  the scales",
		&"tool.screwdriver": "⌁  the screwdriver",
	}
	var x := 0.0
	for tl in [&"tool.loupe", &"tool.rake", &"tool.caliper", &"tool.scales", &"tool.screwdriver"]:
		if not unlocked_tools.has(tl): continue
		var b := Button.new(); b.flat = true
		b.text = ("● " if active_tool == tl else "") + String(names[tl])
		b.add_theme_font_override("font", fr)
		b.add_theme_font_size_override("font_size", int(H*0.026))
		b.add_theme_color_override("font_color", Color(0.93,0.87,0.72) if active_tool == tl else Color(0.72,0.66,0.54))
		b.position = Vector2(x, 0); b.pressed.connect(_pick_tool.bind(tl))
		tool_row.add_child(b); x += b.get_minimum_size().x + W*0.03

func _pick_tool(tl: StringName) -> void:
	active_tool = (&"*" if active_tool == tl else tl)   # повторний клік — відкласти
	_play("ui_soft"); _refresh_tool_row(); _refresh_tray_marks()
	if active_tool == &"*": _set_hint("Set down. The bare hand again.")
	else:
		match tl:
			&"tool.caliper": _set_hint("The caliper in hand — touch it to an edge worth measuring.")
			&"tool.screwdriver": _set_hint("The screwdriver in hand — for screws, if you dare.")
			&"tool.loupe": _set_hint("The loupe in hand — hold it to a detail.")
			&"tool.rake": _set_hint("The lamp in hand — low light finds what polish hides.")
			&"tool.screwdriver": _set_hint("The screwdriver in hand — four screws hold that board.")
			&"tool.scales": _set_hint("The scales stand ready — set the cup on them.")
	_refresh_hand_sprite()
	_c2_loupe_set(active_tool == &"tool.loupe" and _shown() in ["FURN", "WELL", "DRAWER"])

# спрайт інструмента в руці: видимий, коли взято НЕ лупу (лупа має власне скло)
func _refresh_hand_sprite() -> void:
	if hand_tool_ui == null: return
	var names := {&"tool.caliper": "hand_caliper", &"tool.screwdriver": "hand_screwdriver",
		&"tool.rake": "hand_rake"}
	if not names.has(active_tool) or not tex.has(names[active_tool]) \
			or _shown() not in ["FURN", "WELL", "DRAWER", "DESK", "HANDS"]:
		# поза предметними екранами інструмент лишається в руці ЛОГІЧНО, але спрайт
		# не висить привидом над паперами і атестатом (плейтест 27.07)
		hand_tool_ui.visible = false
		return
	move_child(hand_tool_ui, get_child_count()-1)
	move_child(loupe_ui, get_child_count()-1)
	if hint_band: move_child(hint_band, get_child_count()-1)
	if hint_label: move_child(hint_label, get_child_count()-1)
	var t2: Texture2D = tex[names[active_tool]]
	var hh: float = H * (0.26 if active_tool == &"tool.rake" else 0.30)
	var hw: float = hh * float(t2.get_width()) / float(t2.get_height())
	hand_tool_ui.texture = t2
	hand_tool_ui.size = Vector2(hw, hh)
	hand_tool_ui.pivot_offset = Vector2(hw*0.5, hh*0.04)   # робочий кінець угорі
	hand_tool_ui.position = get_viewport().get_mouse_position() - hand_tool_ui.pivot_offset
	hand_tool_ui.visible = true

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
	if desk_intro and desk_intro.modulate.a < 1.0: desk_intro.visible = false
	create_tween().tween_property(b, "modulate", Color(1.7,1.7,1.7,1), 0.12)
	_set_hint(hint)

func _hover_out(b: TextureButton) -> void:
	create_tween().tween_property(b, "modulate", Color(1,1,1,1), 0.12)
	_set_hint("")

func _obj_press(b: TextureButton, key: String, action: Callable, lift: bool) -> void:
	if edit_mode: return
	# КРОК 6: з інструментом у руці клік по келиху — ЗАМІР (правило з data), не lift.
	# Так штангенциркуль і ваги працюють на столі, як вимагає специфікація §3.
	if key == "goblet" and active_tool != &"*":
		_apply_zone("z.cup.whole", active_tool); return
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
	var b := Button.new(); b.flat = true; b.text = _t(txt)
	b.add_theme_font_override("font", fr); b.add_theme_font_size_override("font_size", int(H*sz))
	b.add_theme_color_override("font_color", col)
	b.add_theme_color_override("font_hover_color", Color(0.98,0.83,0.4))
	b.add_theme_color_override("font_focus_color", col)
	# ЧИТАБЕЛЬНІСТЬ НА БУДЬ-ЯКОМУ КАДРІ (Віктор, 27.07): глибока тінь тексту —
	# кнопки лежать просто на фото/3D без плашок, і без тіні тонули
	b.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	b.add_theme_constant_override("shadow_offset_x", 2)
	b.add_theme_constant_override("shadow_offset_y", 2)
	b.add_theme_constant_override("shadow_outline_size", 4)
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
	["12 · Case 2 — the secretaire", "case2"],
]

# ── СТАН → ВИГЛЯД: рівно три входи, і четвертого нема ────────────────────────
# _load_case(n)     — ЄДИНЕ місце, де стан справи стає початковим.
# _clear_run_nodes()— викидає вузли, що лишились від попереднього проходу.
# _sync_view()      — ЄДИНЕ місце, де вигляд ВИВОДИТЬСЯ зі стану.
#
# Закон: обробник міняє СТАН і кличе _sync_view(). Обробник сам нічого не малює.
# До кроку 2 скид жив у двох функціях із різними наборами полів (_reset_run і
# _start_case), і саме через розбіжність між ними raking, кільце каталогу й діти
# cert_layer переживали перехід між справами. Гірше: _reset_run не переставляв
# CSLOTS, тож після справи 2 атестат справи 1 показував чужі графи.

func _load_case(n: int) -> void:
	case_id = n
	CSLOTS = (CASE_DATA[n] as Object).get("SLOTS") if CASE_DATA.has(n) else []
	facts.clear()                       # одне речення замість чотирнадцяти drop_fact
	zone_states.clear()
	case_flags.clear()
	pending_confirm = ""
	active_tool = &"*"
	unlocked_tools.clear()
	if CASE_DATA.has(n):
		var st0 = (CASE_DATA[n] as Object).get("START_TOOLS")
		if st0 is Array:
			for tl0 in st0: unlocked_tools[tl0] = true
	num_buf = ""
	cvals = []
	for sl in CSLOTS:
		cvals.append([] if String((sl as Dictionary)["kind"]) == "FACTS" else "")
	active_slot = 0
	sealed = false
	case_done = false
	found_time = 0.0
	client_line = 0
	client_seen = false
	saw_figure = false
	raking = false
	lamp_on = true
	tod = "day"
	if sec_drawer: sec_drawer.rotation = Vector3.ZERO   # не перевернута з минулого разу
	_clear_run_nodes()
	_sync_view()

func _clear_run_nodes() -> void:
	# сліди попереднього проходу: віск, «CASE CLOSED», позначки каталогу, лупа в руці
	if loupe_held: _drop_loupe()
	if goblet_pivot: goblet_pivot.rotation = Vector3.ZERO
	if cert_layer:
		for n in ["stamp_hs", "cert_msg"]:
			if cert_layer.has_node(n): cert_layer.get_node(n).queue_free()
		for ch in cert_layer.get_children():
			if ch is TextureRect and ch != cert_layer.get_child(0): ch.queue_free()
			elif ch is Label and (ch as Label).text == "CASE CLOSED": ch.queue_free()
	if cat_screen:
		for n2 in ["matchring", "matchlbl"]:
			if cat_screen.has_node(n2): cat_screen.get_node(n2).queue_free()

# Безпечна до повторного виклику: нічого не перемикає, лише приводить вигляд
# у відповідність до стану. animate=true — коли зміну має бачити гравець.
func _sync_view(animate: bool = false) -> void:
	# косе світло міняє САМУ поверхню дна (пластину) — тож без лупи й під лупою знову однаково
	# _load_case може викликатись до того, як заповнено кеш текстур (_ready)
	if maker_mat and tex.has("foot_plate_maker"):
		maker_mat.albedo_texture = tex["foot_plate_church"] if raking else tex["foot_plate_maker"]
		# без пересвіту: гравюра має ЧИТАТИСЬ, а не тонути в білому
		maker_mat.albedo_color = Color(1.38, 1.35, 1.30) if raking else Color(1.30, 1.28, 1.22)
	var rot := Vector3(-4, -84, 0) if raking else Vector3(-9, -62, 0)
	var energy := 1.15 if raking else 1.9
	if key_light:
		# У тестах анімації нема: знімок, зроблений посеред твіна, не відтворюється
		# між прогонами. Спіймано на 13b_loupe_church.png — кадр знімався через 8 кадрів,
		# а світло переїжджає 0.5 с, тобто щоразу в іншій фазі.
		if animate and not dbg_mode:
			var lt := create_tween(); lt.set_parallel(true)
			lt.tween_property(key_light, "rotation_degrees", rot, 0.5)
			lt.tween_property(key_light, "light_energy", energy, 0.5)
		else:
			key_light.rotation_degrees = rot
			key_light.light_energy = energy
	if rake_btn:
		rake_btn.text = _t("⟋  raking light — on") if raking else "⟋  rake the light across the silver"

func _found_all() -> void:
	for f0 in ["f.mark_maker","f.mark_diana","f.reg_hoffmann","f.news_robbery","f.church_mark",
			   "f.letter_read","f.hb_vienna_marks","f.domes","f.domes_alike","f.marks_alone",
			   "f.receipt_1807","f.height_196","f.weight_331","f.receipt_mismatch"]:
		add_fact(f0)

func _goto(key: String) -> void:
	_load_case(1)
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
			client_seen = true; add_fact("f.mark_maker"); add_fact("f.mark_diana"); _show("CATALOG")
		"cert":
			client_seen = true; _found_all()
			cvals = [&"o.vienna_hoffmann", 800, 1872, &"o.after_the_fact", &"o.made_to_look_stolen", [&"f.domes_alike", &"f.marks_alone"] as Array]
			_show("CERT")
		"morning":
			client_seen = true; _found_all(); sealed = true; seals_set = maxi(seals_set, 1)
			cvals = [&"o.vienna_hoffmann", 800, 1872, &"o.after_the_fact", &"o.made_to_look_stolen", [&"f.domes_alike", &"f.marks_alone"] as Array]
			_show_morning()
		"evening":
			client_seen = true; case_done = true; tod = "evening"; _enter_hub()
		"dark":
			client_seen = true; case_done = true; tod = "evening"; lamp_on = false
			_enter_hub(); _hub_say("Darkness. And on the shelf, something takes the little light there is — a black casket you do not remember shelving.")
		"ledger":
			client_seen = true; case_done = true; tod = "evening"
			seals_set = maxi(seals_set, 1); _show("LEDGER")
		"case2":
			_load_case(2); client_seen = true; _show("FURN")
		"client2":
			_start_case2()
		_:
			_show("MENU")

func _build_chapters() -> void:
	# ТИМЧАСОВИЙ режим вибору сцен (F1) — але за правилом 9 і тимчасове робимо
	# охайно: групи по справах, чисті колонки, жорсткий bind ключа (жодних
	# сюрпризів замикань — Віктор упіймав вибір «12», що вів у справу 1).
	var sc := _screen("CHAPTERS")
	if tex.has("hub_darkness"):
		var b := _bg(sc, tex["hub_darkness"]); b.modulate = Color(0.42, 0.42, 0.46)
	var h := Label.new(); h.label_settings = _ls(fb, int(H*0.042), Color(0.92,0.86,0.72))
	h.text = _t("Where would you like to begin?")
	h.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	h.size = Vector2(W, H*0.07); h.position = Vector2(0, H*0.05)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE; sc.add_child(h)
	var groups := [
		["CASE 1 · THE SILVER GOBLET", 0.075, [
			["Morning — the door", "door"], ["The client at the counter", "client"],
			["The desk — fresh case", "desk"], ["The goblet in your hands", "hands"],
			["The papers and the press", "docs"], ["The mark register", "catalog"],
			["The certificate — filled", "cert"], ["The next morning", "morning"],
			["Evening — the room", "evening"], ["Darkness", "dark"], ["The ledger", "ledger"],
		]],
		["CASE 2 · THE SECRETAIRE", 0.565, [
			["Frau Vogl at the counter", "client2"],
			["The piece, floor to cornice", "case2"],
		]],
	]
	for g in groups:
		var gx := W*float(g[1])
		var cap := Label.new(); cap.label_settings = _ls(fb, int(H*0.026), Color(0.66,0.55,0.38))
		cap.text = String(g[0]); cap.position = Vector2(gx, H*0.155)
		cap.mouse_filter = Control.MOUSE_FILTER_IGNORE; sc.add_child(cap)
		var rule := ColorRect.new(); rule.color = Color(0.66, 0.55, 0.38, 0.45)
		rule.size = Vector2(W*0.36, 1.0); rule.position = Vector2(gx, H*0.198)
		rule.mouse_filter = Control.MOUSE_FILTER_IGNORE; sc.add_child(rule)
		var i := 0
		for it in (g[2] as Array):
			var col := 0 if i < 6 else 1
			var bx := gx + float(col)*W*0.235
			var by := H*0.235 + float(i % 6)*H*0.088
			var num := str(i + 1) + " · " if String(g[0]).begins_with("CASE 1") else "· "
			_txtbtn(sc, num + String((it as Array)[0]), Vector2(bx, by),
					Callable(self, "_goto").bind(String((it as Array)[1])), 0.027)
			i += 1
	var foot := Label.new(); foot.label_settings = _ls(fr, int(H*0.019), Color(0.55,0.52,0.46))
	foot.text = _t("A workbench shortcut — it will not ship.  F1 opens it anywhere.")
	foot.position = Vector2(W*0.075, H*0.845)
	foot.mouse_filter = Control.MOUSE_FILTER_IGNORE; sc.add_child(foot)
	_txtbtn(sc, "←  back", Vector2(W*0.075, H*0.90), func(): _show("MENU"), 0.028)

func _build_menu() -> void:
	var s0 := _screen("MENU")
	if tex.has("menu_door"): _bg(s0, tex["menu_door"])
	var t := Label.new(); t.label_settings = _ls(fb, int(H*0.075), Color(0.93,0.87,0.74))
	t.text = _t("BUREAU OF\nATTRIBUTION")
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	t.size = Vector2(W*0.46, H*0.12); t.position = Vector2(W*0.06, H*0.30); t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	s0.add_child(t)
	var sub := Label.new(); sub.label_settings = _ls(fr, int(H*0.026), Color(0.80,0.72,0.58))
	sub.text = _t("your judgement is what makes a thing real")
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	sub.size = Vector2(W*0.46, H*0.05); sub.position = Vector2(W*0.065, H*0.50); sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	s0.add_child(sub)
	_txtbtn(s0, "unlock the door  →", Vector2(W*0.065, H*0.60), func(): _play("door_bell"); _load_case(1); _enter_hub(), 0.034)
	# продовжити з сейва — тільки якщо він є, читається і має поступ
	if FileAccess.file_exists(_save_path()):
		_txtbtn(s0, "return to the desk  →", Vector2(W*0.065, H*0.655),
			func():
				if _load_game(): _play("ui_soft"); _show("DESK" if not sealed else "LEDGER")
				else: _play("ui_soft"); _set_hint("The ledger of that day cannot be read."), 0.030)
	_txtbtn(s0, "choose a scene  →", Vector2(W*0.065, H*0.71), func(): _show("CHAPTERS"), 0.028)

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
	elif case_id == 1:
		_hub_say("The day is done. Sleep would be wise \u2014 the bell rings early in this trade. (the door)")
	else:
		_hub_say("The day is done. The ledger lies open on your desk.")

func _hub_say(t: String) -> void:
	if hub_note: hub_note.text = _t(t)

func _hub_door() -> void:
	if not client_seen:
		_play("door_bell"); client_line = 0; _client_show(); _show("CLIENT")
	elif case_done and case_id == 1:
		# ранок наступного дня: друга клієнтка (міст справ 1→2)
		tod = "day"; lamp_on = true
		_start_case2()
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
	_paper_backdrop(s2, 0.06)
	client_panels = [
		_comic_panel(s2, "client_woman" if tex.has("client_woman") else "client_in_room",
			Rect2(W*0.055, H*0.07, W*0.315, H*0.68)),
		_comic_panel(s2, "cl1_p2", Rect2(W*0.415, H*0.07, W*0.255, H*0.315)),
		_comic_panel(s2, "cl1_p3", Rect2(W*0.695, H*0.07, W*0.255, H*0.315)),
		_comic_panel(s2, "cl1_p4", Rect2(W*0.415, H*0.435, W*0.535, H*0.315)),
	]
	_band(s2)
	var l := Label.new(); l.name = "ctext"; l.label_settings = _ls(fr, int(H*0.030), Color(0.95,0.91,0.82))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; l.size = Vector2(W*0.62, H*0.13); l.position = Vector2(W*0.19, H*0.815)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE; s2.add_child(l)
	# клік БУДЬ-ДЕ гортає репліку (плейтест 28.07: гравець цілився в «go on»
	# на 70 px вище і вирішив, що діалог зламаний). Ловець ПІД рештою контролів.
	var adv := Button.new(); adv.flat = true; adv.modulate.a = 0
	adv.size = Vector2(W, H); adv.position = Vector2.ZERO
	adv.pressed.connect(func(): _client_next())
	s2.add_child(adv); s2.move_child(adv, 0)
	_txtbtn(s2, "go on  →", Vector2(W*0.845, H*0.905), func(): _client_next(), 0.030)

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
	var li := clampi(client_line, 0, CLIENT_LINES.size()-1)
	l.text = _t(CLIENT_LINES[li])
	_comic_show(client_panels, li)

# ---------- DESK (стіл-справа) ----------
func _build_desk() -> void:
	var s := _screen("DESK")
	desk_bg = _bg(s, tex["case_desk_loupe"])   # стіл із ВБУДОВАНОЮ лупою (перспектива+тінь у сцені)
	gob_btn = _object(s, "goblet", tex["ov_goblet"], "The silver goblet — take it in hand", func(): _show("HANDS"), true, tex["ov_goblet_click"])
	var nb_btn := _txtbtn(s, "✎  the notebook", Vector2(W*0.855, H*0.185), func(): _show_notebook(), 0.026)
	nb_btn.add_theme_color_override("font_outline_color", Color(0.05,0.04,0.03,0.9))
	nb_btn.add_theme_constant_override("outline_size", 8)
	tool_row = Control.new(); tool_row.position = Vector2(W*0.04, H*0.055)
	tool_row.size = Vector2(W*0.5, H*0.05); s.add_child(tool_row)
	_refresh_tool_row()
	# лупа — НЕВИДИМИЙ хотспот над вбудованою лупою (жодних плоских вирізок)
	mag_btn = _mag_hotspot(s)
	folder_btn = _object(s, "folder", tex["ov_folder"], "The case papers — read them", func(): _show("DOCS"), false, tex["ov_folder_click"])
	_txtbtn(s, "Write the certificate  →", Vector2(W*0.72, H*0.9), func(): _show("CERT"))
	# рамка задачі (діегетична, без відповіді): три графи атестата = твоя мета
	var intro := Label.new(); intro.label_settings = _ls(fr, int(H*0.028), Color(0.92,0.88,0.78))
	desk_intro = intro
	intro.text = _t("A goblet, and a story that does not sit right.\nExamine it, then write the attribution — and set your name to it.")
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
	# ВЛАСНИЙ СВІТ — обов'язково. Без own_world_3d SubViewport УСПАДКОВУЄ світ
	# root-в'юпорта, і всі 3D-сцени гри зливаються в одну: камера секретера
	# чесно бачила чашу в нулі координат — «ваза в шафі» (Віктор, 27.07).
	sv.own_world_3d = true
	svc.add_child(sv); _build_goblet_world(sv)
	goblet_sv = sv
	# 3D-в'юпорт лупи: СПІЛЬНИЙ світ чаші → зум-камера показує РЕАЛЬНЕ клеймо (не картинку)
	loupe_vp = SubViewport.new(); loupe_vp.size = Vector2i(760,760)
	# ФАКТИЧНИЙ світ чаші, не властивість: при own_world_3d=true властивість
	# world_3d == null, і копіювання її в лупу кидало лупу в порожній root-світ —
	# «скло прозоре, не зближує зовсім» (Віктор, 27.07; регресія фіксу «вази в шафі»)
	loupe_vp.world_3d = sv.find_world_3d(); loupe_vp.transparent_bg = true; loupe_vp.msaa_3d = Viewport.MSAA_4X
	goblet_world = loupe_vp.world_3d
	loupe_vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(loupe_vp)
	loupe_cam = Camera3D.new(); loupe_vp.add_child(loupe_cam); loupe_cam.fov = 30.0
	loupe_cam.global_position = Vector3(0,-0.75,0.6); loupe_cam.look_at(Vector3(0,-0.75,0), Vector3.UP)
	# діегетична вказівка (не відповідь): перевернути чашу
	var tip := Label.new(); tip.label_settings = _ls(fr, int(H*0.026), Color(0.82,0.78,0.68))
	tip.text = _t("Drag to turn it — silver is marked underneath.  Rake the light to read a worn mark.")
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; tip.size = Vector2(W, H*0.05)
	tip.position = Vector2(0, H*0.945)   # під рядом кнопок 0.9 — не лягати на «✋» (0.835)
	tip.mouse_filter = Control.MOUSE_FILTER_IGNORE; s.add_child(tip)
	var tw := create_tween(); tw.tween_interval(6.0); tw.tween_property(tip, "modulate:a", 0.0, 1.5)
	_txtbtn(s, "←  set it down", Vector2(W*0.04, H*0.9), func(): _show("DESK"))
	# КОСЕ СВІТЛО (інструмент з опису): нахиляє світло майже врівень → проступає стерта монограма
	rake_btn = _txtbtn(s, "⟋  rake the light across the silver", Vector2(W*0.60, H*0.9), func(): _toggle_raking())
	# скло можна взяти ПРЯМО В РУКАХ — не треба вертатись на стіл по нього
	hands_glass_btn = _txtbtn(s, "◦  take up the glass", Vector2(W*0.29, H*0.9), func(): _pickup_loupe())
	# ДІЯ ЯК КНОПКА (Віктор, 27.07: «це не працює, незрозуміло» — жест-у-точку
	# провалився і в плейтестера, і в нього; кнопка чесніша для миші, як rake)
	_txtbtn(s, "✋  run a finger over the foot", Vector2(W*0.55, H*0.835),
		func(): _apply_zone("z.foot.top", &"tool.hand"), 0.026)
	# макро доступне, щойно клейма знайдені (дрібні гліфи — тільки тут)
	var macro_btn := _txtbtn(s, "◉  study the marks up close", Vector2(W*0.55, H*0.78),
		func():
			if found_marks: _show("MARKS_MACRO")
			else: _set_hint("Nothing under the strong glass yet. Turn the piece over and CLICK the punches under the foot through the lens."), 0.026)

func _toggle_raking() -> void:
	raking = not raking          # СТАН
	_play("ui_soft")
	_sync_view(true)             # вигляд виводиться зі стану, тут — з анімацією
	_set_hint("The light lies almost flat across the silver now. Bring the glass close." if raking else "")

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
	t.text = _t("From the client:\n\n\"This goblet came to me\nfrom an aunt in the monastery.\nI am told it is Viennese.\nI should like to know its worth —\nand whether it is mine to sell.\"\n\nShe would not meet my eye\nas she said it.")
	t.position = paper.position + Vector2(lw*0.13, lh*0.15); t.mouse_filter = Control.MOUSE_FILTER_IGNORE; s.add_child(t)
	_paper_catcher("DOCS", s, paper)
	# навігація — нижній ряд на притемненому столі (геть з паперу), тепла і читабельна
	_txtbtn(s, "←  put the pen down", Vector2(W*0.04, H*0.92), func(): _show("FURN" if case_id == 2 else "DESK"))
	_txtbtn(s, "✎", Vector2(W*0.945, H*0.055), func(): _show_notebook(), 0.030)
	_txtbtn(s, "Open the newspaper  →", Vector2(W*0.34, H*0.92), func(): _show("NEWS"))
	_txtbtn(s, "The paper with the cup  →", Vector2(W*0.60, H*0.92), func(): _show("DOCS_RECEIPT"))
	_txtbtn(s, "Mark catalogue  →", Vector2(W*0.84, H*0.92), func(): _show("CATALOG"))

# ---------- NEWS ----------
func _build_news() -> void:
	var s := _screen("NEWS")
	_paper_backdrop(s)
	var nt: Texture2D = tex["newspaper_final"]
	var nh := H*0.94; var nw := nh*float(nt.get_width())/float(nt.get_height())
	var np := TextureRect.new(); np.texture = nt; np.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	np.stretch_mode = TextureRect.STRETCH_SCALE; np.size = Vector2(nw, nh)
	np.position = Vector2((W-nw)*0.5, (H-nh)*0.5); np.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# газетний папір 1900-х не білий: теплий пожовклий тон (Віктор: «білий фон — тупо»)
	np.modulate = Color(0.86, 0.80, 0.68)
	s.add_child(np)
	_paper_catcher("NEWS", s, np)
	_txtbtn(s, "←  back", Vector2(W*0.04, H*0.92), func(): _show("DOCS"))

# ---------- CATALOG (клік по гербу) ----------
# ── КРОК 6: квитанція 1807 + реєстр + довідник знаків ────────────────────────
# Поверхні ЧИСТІ (генерація без тексту), увесь текст — шрифтом (правило 10).
# Факти йдуть через єдиний ловець і правила в data/case_01.gd.
func _paper_screen(scr: String, texname: String, back_to: String, back_lbl: String) -> Dictionary:
	var s := _screen(scr)
	_paper_backdrop(s, 0.18)
	var t: Texture2D = tex[texname]
	var ph2 := H*0.92; var pw2 := ph2*float(t.get_width())/float(t.get_height())
	var pg := TextureRect.new(); pg.texture = t; pg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pg.stretch_mode = TextureRect.STRETCH_SCALE; pg.size = Vector2(pw2, ph2)
	pg.position = Vector2((W-pw2)*0.5, (H-ph2)*0.5)
	pg.mouse_filter = Control.MOUSE_FILTER_IGNORE; s.add_child(pg)
	_txtbtn(s, back_lbl, Vector2(W*0.04, H*0.92), func(): _show(back_to))
	return {"s": s, "pg": pg}

func _ptext(sc: Dictionary, txt: String, ux: float, uy: float, size_f: float,
			col := Color(0.24,0.17,0.10), italic := false) -> void:
	var pg := sc["pg"] as TextureRect
	var l := Label.new(); l.label_settings = _ls(fb if italic else fr, int(pg.size.y*size_f), col)
	l.text = _t(txt); l.position = pg.position + Vector2(pg.size.x*ux, pg.size.y*uy)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE; (sc["s"] as Control).add_child(l)

# ── НОТАТНИК (крок 6 плану) ──────────────────────────────────────────────────
# Розворот записника; кожен здобутий факт — рядок рукописом У ПОРЯДКУ ВІДКРИТТЯ
# (порядок вставки Dictionary = хронологія), при деяких — вклейка-вирізка арту
# (AtlasTexture з region у пікселях текстури). Відкривається з будь-якого екрана
# розслідування кнопкою або клавішею N; повертає туди, звідки відкрили.
var notebook_prev := "DESK"
var pilot_loupe_lock := false   # пілот зафіксував скло: не слідувати за мишею ОС
var notebook_rows := 0

# ── СЕЙВ (крок 9). Формат із version З ПЕРШОГО ДНЯ (пастка §8: id фактів ще
# перейменуються — невідома версія чесно відкидається, а не читається криво).
# Тести пишуть в ОКРЕМИЙ файл, щоб не затирати сейв гравця.
const SAVE_VERSION := 1

func _save_path() -> String:
	return "user://save_test.json" if dbg_mode else "user://save_v1.json"

func _save_game() -> void:
	var d := {
		"version": SAVE_VERSION,
		"case_id": case_id,
		"facts": facts.keys(),          # порядок = хронологія нотатника
		"zone_states": zone_states,
		"case_flags": case_flags,
		"unlocked_tools": unlocked_tools.keys(),
		"active_tool": String(active_tool),
		"cvals": cvals,
		"active_slot": active_slot,
		"sealed": sealed,
		"seals_set": seals_set,
		"tod": tod, "lamp_on": lamp_on,
		"case_done": case_done, "client_seen": client_seen, "client_line": client_line,
	}
	var f := FileAccess.open(_save_path(), FileAccess.WRITE)
	if f: f.store_string(JSON.stringify(d)); f.close()

# → true, якщо стан відновлено. Невідома версія/битий файл — чесна відмова.
func _load_game() -> bool:
	if not FileAccess.file_exists(_save_path()): return false
	var f := FileAccess.open(_save_path(), FileAccess.READ)
	if f == null: return false
	var parsed = JSON.parse_string(f.get_as_text()); f.close()
	if not (parsed is Dictionary): return false
	var d: Dictionary = parsed
	if int(d.get("version", -1)) != SAVE_VERSION:
		print("SAVE: невідома версія ", d.get("version"), " — починаємо заново")
		return false
	_load_case(int(d.get("case_id", 1)))
	for k in d.get("facts", []): facts[String(k)] = true
	var zs: Dictionary = d.get("zone_states", {})
	for k2 in zs: zone_states[StringName(k2)] = StringName(zs[k2])
	var cf: Dictionary = d.get("case_flags", {})
	for k3 in cf: case_flags[StringName(k3)] = cf[k3]
	for tl in d.get("unlocked_tools", []): unlocked_tools[StringName(tl)] = true
	active_tool = StringName(d.get("active_tool", "*"))
	var cv: Array = d.get("cvals", [])
	for i in mini(cv.size(), cvals.size()):
		# JSON числа приходять float; NUMBER-графи тримають int
		cvals[i] = int(cv[i]) if cv[i] is float else cv[i]
	active_slot = int(d.get("active_slot", 0))
	sealed = bool(d.get("sealed", false))
	seals_set = int(d.get("seals_set", 0))
	tod = String(d.get("tod", "day")); lamp_on = bool(d.get("lamp_on", true))
	case_done = bool(d.get("case_done", false))
	client_seen = bool(d.get("client_seen", false)); client_line = int(d.get("client_line", 0))
	_refresh_tool_row(); _sync_view()
	return true

func _show_notebook() -> void:
	if _shown() != "NOTEBOOK": notebook_prev = _shown()
	_refresh_notebook()
	_show("NOTEBOOK")

func _refresh_notebook() -> void:
	if not screens.has("NOTEBOOK"):
		var s0 := _screen("NOTEBOOK")
		_paper_backdrop(s0, 0.18)   # та сама підкладка-стіл, що в паперів (аудит: «сіра пустка»)
		s0.set_meta("built", true)
	var s: Control = screens["NOTEBOOK"]
	for c in s.get_children():
		if c is TextureRect or c is Label or c is Button: c.queue_free()
	var t: Texture2D = tex["notebook_spread"]
	var nh := H*0.96; var nw := nh*float(t.get_width())/float(t.get_height())
	var pg := TextureRect.new(); pg.texture = t; pg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pg.stretch_mode = TextureRect.STRETCH_SCALE; pg.size = Vector2(nw, nh)
	pg.position = Vector2((W-nw)*0.5, (H-nh)*0.5); pg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pg.modulate = Color(0.88, 0.83, 0.72)   # той самий закон: папір теплий, не білий
	s.add_child(pg)
	var ft := _case_facts_table()
	# сітка виміряна з текстури; пишемо ЧЕРЕЗ лінію (крок 2×0.0169), інакше кегль
	# нечитабельний. Колонки — дві сторінки розвороту.
	const NB_FIRST := 0.140
	const NB_STEP := 0.0338
	const NB_LINES := 21          # рядків «через лінію» на сторінці
	var cols := [0.075, 0.560]
	var col_w := 0.315
	notebook_rows = 0
	# ── аркуші: розкласти факти по розворотах ТИМ САМИМ переносом, що малює
	# (правило 17: не вгадуємо висоту — міряємо; 15 фактів справи 2 в один
	# розворот не влазили і мовчки зникали — плейтест 27.07)
	var fids: Array = []
	for fid_s in facts:
		if ft.has(StringName(fid_s)): fids.append(StringName(fid_s))
	# «ЩО БЮРО МУСИТЬ СКАЗАТИ» — шість граф атестата як живий список завдань
	# (Віктор 28.07: «не розумію, як пройти» — гра не показувала, до чого йдеш)
	var q_lines := 0
	if CSLOTS.size() > 0:
		q_lines = 2   # заголовок + відступ
		for sl0 in CSLOTS:
			q_lines += _lined_text(null, pg, NB_FIRST, NB_STEP, 0, 0.0, col_w - 0.05,
				"x " + _t(String((sl0 as Dictionary).get("pre", ""))), fh, 0.56)
	var pages: Array = [[]]
	var mcol := 0
	var mli := q_lines
	for fid in fids:
		var fd0: Dictionary = ft[fid]
		var tw0 := col_w - (0.085 if fd0.has("crop") else 0.0)
		if mli > NB_LINES - 5 and mcol == 0: mcol = 1; mli = 0
		if mcol == 1 and mli > NB_LINES - 5:
			pages.append([]); mcol = 0; mli = 0
		var st0 := mli
		mli = _lined_text(null, pg, NB_FIRST, NB_STEP, mli, cols[mcol],
						  tw0, "— " + String(fd0.get("text", fd0.get("cite", String(fid)))),
						  fh, 0.60)
		if fd0.has("crop"): mli = maxi(mli, st0 + 3)
		mli += 1
		(pages[pages.size()-1] as Array).append(fid)
	var pcount := pages.size()
	var pcur: int = (pcount - 1) if notebook_page < 0 else clampi(notebook_page, 0, pcount - 1)
	notebook_page = pcur if pcur < pcount - 1 else -1   # -1 = «слідкуй за свіжим»
	var col := 0
	var li := 0
	if pcur == 0 and CSLOTS.size() > 0:
		var lih := _lined_text(s, pg, NB_FIRST, NB_STEP, 0, cols[0], col_w,
			_t("What the bureau must say:"), fb, 0.60, Color(0.34,0.20,0.12))
		li = lih
		for qi in CSLOTS.size():
			var sl1: Dictionary = CSLOTS[qi]
			var done := _slot_filled(qi)
			var openq := _slot_open(sl1)
			var mark := "\u2713  " if done else ("\u25d0  " if openq else "\u25cb  ")
			var qcol := Color(0.30,0.42,0.22) if done else (Color(0.21,0.15,0.10) if openq else Color(0.52,0.46,0.38))
			li = _lined_text(s, pg, NB_FIRST, NB_STEP, li, cols[0], col_w - 0.05,
				mark + _t(String(sl1.get("pre", ""))), fh, 0.56, qcol)
		li += 1
	for fid in (pages[pcur] as Array):
		var fd: Dictionary = ft[fid]
		var has_crop: bool = fd.has("crop")
		var tw := col_w - (0.085 if has_crop else 0.0)
		if li > NB_LINES - 5 and col == 0:
			col = 1; li = 0
		var start_li := li
		li = _lined_text(s, pg, NB_FIRST, NB_STEP, li, cols[col],
						 tw, "— " + _t(String(fd.get("text", fd.get("cite", String(fid))))),
						 fh, 0.60, Color(0.21,0.15,0.10))
		if has_crop:
			var cr: Dictionary = fd["crop"]
			var at := AtlasTexture.new(); at.atlas = tex[String(cr["tex"])]; at.region = cr["region"]
			var imv := TextureRect.new(); imv.texture = at; imv.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			imv.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			var crop_h: float = pg.size.y * NB_STEP * 3.0
			imv.size = Vector2(pg.size.x*0.078, crop_h)
			imv.position = pg.position + Vector2(pg.size.x*(cols[col] + col_w - 0.078),
				pg.size.y*(NB_FIRST + NB_STEP*float(start_li)) - pg.size.y*NB_STEP*0.7)
			imv.mouse_filter = Control.MOUSE_FILTER_IGNORE; s.add_child(imv)
			li = maxi(li, start_li + 3)
		li += 1
		notebook_rows += 1
	# гортання: кути розвороту (діегетично — «ранні аркуші» / «пізні аркуші»)
	if pcur > 0:
		_txtbtn(s, "⟨  the earlier leaves", Vector2(W*0.16, H*0.92), func():
			notebook_page = pcur - 1; _refresh_notebook(), 0.024)
	if pcur < pcount - 1:
		_txtbtn(s, "the later leaves  ⟩", Vector2(W*0.68, H*0.92), func():
			notebook_page = pcur + 1; _refresh_notebook(), 0.024)
	if notebook_rows == 0:
		var e := Label.new(); e.label_settings = _ls(fh, int(nh*0.024), Color(0.44,0.36,0.28))
		e.text = _t("Nothing set down yet.")
		e.position = pg.position + Vector2(nw*0.10, nh*0.10)
		e.mouse_filter = Control.MOUSE_FILTER_IGNORE; s.add_child(e)
	_txtbtn(s, "←  put it away", Vector2(W*0.04, H*0.92), func(): _show(notebook_prev))

# МАКРО-ПЛАН КЛЕЙМ (Віктор, 27.07: «на клеймі Діани не видно букви — в цьому і
# складність»). Правило 14: загальний · середній · деталь · МАКРО. Лупа — середній;
# для «літери всередині контуру» детектив перемальовує клеймо під сильним склом.
# Картки — з ОРИГІНАЛУ арту (не з пластини), там гліфи читаються ідеально.
func _build_marks_macro() -> void:
	var s := _screen("MARKS_MACRO")
	_paper_backdrop(s, 0.10)
	var head := Label.new(); head.label_settings = _ls(fr, int(H*0.032), Color(0.90,0.86,0.77))
	head.text = _t("Under the strong glass, drawn into the notebook.")
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	head.size = Vector2(W, H*0.06); head.position = Vector2(0, H*0.045)
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE; s.add_child(head)
	var cards := [
		["mark_maker_macro", "the maker's shield", 0.235],
		["mark_diana_macro", "the assay head — a numeral before the chin,\na letter INSIDE the outline", 0.625],
	]
	for c in cards:
		var t: Texture2D = tex[String(c[0])]
		var chh := H*0.62; var cw := chh*float(t.get_width())/float(t.get_height())
		var im := TextureRect.new(); im.texture = t
		im.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; im.stretch_mode = TextureRect.STRETCH_SCALE
		im.size = Vector2(cw, chh); im.position = Vector2(W*float(c[2]) - cw*0.5, H*0.14)
		im.mouse_filter = Control.MOUSE_FILTER_IGNORE; s.add_child(im)
		var lb := Label.new(); lb.label_settings = _ls(fr, int(H*0.024), Color(0.86,0.80,0.66))
		lb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lb.text = String(c[1]); lb.size = Vector2(W*0.36, H*0.09)
		lb.position = Vector2(W*float(c[2]) - W*0.18, H*0.785)
		lb.mouse_filter = Control.MOUSE_FILTER_IGNORE; s.add_child(lb)
	_txtbtn(s, "←  back to the piece", Vector2(W*0.04, H*0.92), func(): _show("HANDS"))
	_txtbtn(s, "Mark catalogue  →", Vector2(W*0.70, H*0.92), func(): _show("CATALOG"))

# ТЕКСТ НА ЛІНІЙОВАНОМУ ПАПЕРІ — ЄДИНИЙ дозволений спосіб (закон 27.07,
# Віктор: «текст не в лінійках... лінії ріжуть текст»). Кожен рядок — окремий
# Label, посаджений БАЗОВОЮ ЛІНІЄЮ (ascent з métrик шрифту) на лінію сітки
# аркуша; перенос — фактичною шириною рядка, не на око. Сітки виміряні з
# текстур: notebook 0.140+0.0169·h · reg_page 0.1025+0.0183·h · receipt
# 0.3113+0.0158·h. Пишемо «через лінію» — дрібний крок дає нечитабельний кегль.
func _lined_text(sc: Control, pg: Control, grid_first: float, grid_step: float,
				 line_idx: int, x_frac: float, w_frac: float, txt: String,
				 font: FontFile, size_ratio := 0.62, col := Color(0.24,0.17,0.10)) -> int:
	txt = _t(txt)
	var step_px: float = pg.size.y * grid_step
	var fsize: int = maxi(int(step_px * size_ratio), 8)
	var ascent: float = font.get_ascent(fsize)
	var max_w: float = pg.size.x * w_frac
	var lines: Array[String] = []
	var cur := ""
	for word in txt.split(" "):
		var trial := (cur + " " + word).strip_edges()
		if cur == "" or font.get_string_size(trial, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize).x <= max_w:
			cur = trial
		else:
			lines.append(cur); cur = word
	if cur != "": lines.append(cur)
	for l in lines:
		if sc != null:
			var y_line: float = pg.size.y * (grid_first + grid_step * float(line_idx))
			var lb := Label.new(); lb.label_settings = _ls(font, fsize, col)
			lb.text = l
			lb.position = pg.position + Vector2(pg.size.x * x_frac, y_line - ascent)
			lb.mouse_filter = Control.MOUSE_FILTER_IGNORE
			sc.add_child(lb)
		line_idx += 1
	return line_idx

func _build_receipt() -> void:
	var sc := _paper_screen("DOCS_RECEIPT", "paper_receipt_1807", "DOCS", "←  back to the papers")
	# текст квитанції — ДОСЛІВНО з case_01.md §3 (f.receipt_1807)
	_ptext(sc, "R E C E I P T", 0.385, 0.155, 0.030)
	_ptext(sc, "duty paid on the re-marking of plate", 0.300, 0.195, 0.019)
	# лінії бланка виміряні профілем темності: нерівномірні, тому кожен рядок —
	# на свою лінію поіменно (а не first+step·k)
	var q_lines := [0.4192, 0.4758, 0.5325, 0.5792]
	var q_rows := ["Vienna, the 12th of March 1807", "one becher, silver, 13 löthig",
			"weight 14 loth  ·  height 8 zoll 4 linien", "for Anna Reithofer"]
	var q_sizes := [0.55, 0.55, 0.42, 0.55]   # довгий рядок — дрібнішим письмом, без переносу
	for qi in q_rows.size():
		_lined_text(sc["s"], sc["pg"], q_lines[qi], 0.0566, 0, 0.290, 0.58,
			String(q_rows[qi]), fh, q_sizes[qi], Color(0.16,0.12,0.22))
	_paper_catcher("DOCS_RECEIPT", sc["s"], sc["pg"])

func _build_books() -> void:
	# реєстр майстерень: рядок Гоффманна серед сусідів — шрифтом у порожню таблицю
	var rg := _paper_screen("BOOK_REG", "reg_page_h", "CATALOG", "←  back to the catalogue")
	_ptext(rg, "REGISTER OF THE WORKSHOPS OF VIENNA — H", 0.16, 0.055, 0.020)
	var rows := [
		["HABERMANN, Karl", "goldsmith", "1841", "1856"],
		["HELLER & SON", "silversmiths", "1852", "—"],
		["HOFFMANN, Leopold", "silversmith", "1859", "1871"],
		["HUBER, Anton", "silversmith", "1863", "—"],
		["HORVATH, Emmerich", "goldsmith", "1866", "1870"],
	]
	# кожен запис — у СВОЮ графу, базовою лінією на її нижню лінію; всі колонки разом
	for i in rows.size():
		var r: Array = rows[i]
		var li_r := 1 + i
		_lined_text(rg["s"], rg["pg"], 0.1246, 0.0446, li_r, 0.205, 0.30, String(r[0]), fh, 0.50, Color(0.20,0.15,0.20))
		_lined_text(rg["s"], rg["pg"], 0.1246, 0.0446, li_r, 0.520, 0.17, String(r[1]), fh, 0.46, Color(0.24,0.19,0.24))
		_lined_text(rg["s"], rg["pg"], 0.1246, 0.0446, li_r, 0.705, 0.09, String(r[2]), fh, 0.50, Color(0.20,0.15,0.20))
		_lined_text(rg["s"], rg["pg"], 0.1246, 0.0446, li_r, 0.800, 0.09, String(r[3]), fh, 0.50, Color(0.20,0.15,0.20))
	_paper_catcher("BOOK_REG", rg["s"], rg["pg"])

	# довідник знаків: гравюри вже на аркуші, підписи — шрифтом
	var mk := _paper_screen("BOOK_MARKS", "marks_page_vienna", "CATALOG", "←  back to the catalogue")
	_ptext(mk, "THE MARKS OF THE VIENNA ASSAY OFFICE", 0.20, 0.048, 0.020)
	_ptext(mk, "1807 — 1866", 0.56, 0.130, 0.021)
	_ptext(mk, "a punch bearing the last two figures", 0.50, 0.165, 0.0165)
	_ptext(mk, "of the year, the fineness in loth,", 0.50, 0.192, 0.0165)
	_ptext(mk, "and the office letter struck BESIDE.", 0.50, 0.219, 0.0165)
	_ptext(mk, "FROM 1867", 0.60, 0.560, 0.021)
	_ptext(mk, "Diana's head; the numeral gives the", 0.52, 0.598, 0.0165)
	_ptext(mk, "fineness: 1=950  2=900  3=800  4=750.", 0.52, 0.625, 0.0165)
	_ptext(mk, "No year is struck at all.", 0.52, 0.652, 0.0165)
	_ptext(mk, "FROM 1872 the office letter is cut", 0.52, 0.700, 0.0165)
	_ptext(mk, "INSIDE the head's outline; before,", 0.52, 0.727, 0.0165)
	_ptext(mk, "it stood as a separate punch beside.", 0.52, 0.754, 0.0165)
	_paper_catcher("BOOK_MARKS", mk["s"], mk["pg"])

func _build_catalog() -> void:
	var s := _screen("CATALOG")
	_paper_backdrop(s, 0.22)
	# СТОРІНКА КАТАЛОГУ ліворуч; праворуч — темна панель столу з еталоном і навігацією
	# v2: у вихідного файла була ЗАПЕЧЕНА біла рамка (полотно генерації) — на темному
	# столі вона читалась як біла облямівка навколо сторінки. Обрізано, кути в альфу.
	var ct: Texture2D = tex["catalog_final_v2"]
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
	rl.text = _t("This mark is struck on the goblet's foot.\nFind the SAME shield among the marks —\nsome look alike; match it exactly.")
	rl.position = Vector2(panx, H*0.12 + refm.size.y + H*0.015)
	rl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; rl.size = Vector2(W-panx-W*0.02, H*0.2)
	rl.mouse_filter = Control.MOUSE_FILTER_IGNORE; s.add_child(rl)
	# хотспот саме на щиті r3c8 (крилата Хі-Ро — точний двійник клейма чаші)
	var hs := Button.new(); hs.flat = true; hs.modulate.a = 0
	# частки перераховані під ОБРІЗАНУ текстуру v2 (знято поля 39 злів / 40 згори з
	# кадру 1792×1128 → 1716×1088). Стара пара (0.867, 0.612) вказувала б повз комірку.
	var mx: float = px + pw*0.8827; var my: float = py + ph*0.5977; var mr: float = pw*0.0439
	hs.position = Vector2(mx-mr, my-mr); hs.size = Vector2(mr*2, mr*2)
	hs.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	hs.mouse_entered.connect(_cat_hover)
	hs.mouse_exited.connect(_set_hint.bind(""))
	hs.pressed.connect(_cat_click.bind(s, Vector2(mx, my), mr))
	s.add_child(hs)
	cat_screen = s; cat_m = Vector2(mx, my); cat_mr = mr; s.set_meta("panx", panx)
	_txtbtn(s, "The register  →", Vector2(panx, H*0.66), func(): _show("BOOK_REG"))
	_txtbtn(s, "The handbook of marks  →", Vector2(panx, H*0.73), func(): _show("BOOK_MARKS"))
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
	add_fact("f.reg_hoffmann"); _play("page_turn")
	_set_hint("")
	if not s.has_node("matchlbl"):
		# кільце-обвід навколо знайденої комірки (мальованого немає — тонка діегетична позначка на сторінці)
		var ring := Label.new(); ring.name = "matchring"; ring.label_settings = _ls(fb, int(mr*1.7), Color(0.62,0.11,0.10))
		ring.text = _t("◯"); ring.position = Vector2(m.x-mr*0.95, m.y-mr*1.15); ring.mouse_filter = Control.MOUSE_FILTER_IGNORE; s.add_child(ring)
		# підтвердження — у правій панелі, не над сторінкою
		var lbl := Label.new(); lbl.name = "matchlbl"; lbl.label_settings = _ls(fb, int(H*0.028), Color(0.72,0.14,0.12))
		lbl.text = _t("✓ the same mark —\n   Hoffmann, Wien\n   (register: 1859–1871)"); lbl.position = Vector2(cat_screen.get_meta("panx"), H*0.46)
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
	var cpos := Vector2(W*0.055, (H-chh)/2)
	# ТІНЬ ПІД АРКУШЕМ ПРОБУВАЛИ — НЕ ПРАЦЮЄ, і це не помилка виконання.
	# Стіл на цьому екрані майже чорний (яскравість ≈6 із 255), і тінь на ньому
	# не читається взагалі: заміряно до і після — 5.7 проти 5.8.
	# Аркуш виглядає наклейкою НЕ через брак тіні, а через різкий світлий
	# прямокутний край на майже чорному тлі. Справжнє лікування — рваний край
	# самого аркуша (як у листа клієнтки), а це правка текстури, що зсуває
	# верстку рядків. Робити разом із кроком 7, коли атестат перейде на таблиці.
	# Спрайт art/cert_shadow.png лишається в репозиторії — знадобиться, щойно
	# під аркушем з'явиться світліша поверхня.
	var root := Control.new(); root.size = Vector2(cwd, chh); root.position = cpos
	s.add_child(root); cert_layer = root
	var paper := TextureRect.new(); paper.texture = at; paper.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	paper.stretch_mode = TextureRect.STRETCH_SCALE; paper.set_anchors_preset(Control.PRESET_FULL_RECT)
	paper.mouse_filter = Control.MOUSE_FILTER_IGNORE; root.add_child(paper)
	var pw := root.size.x; var ph := root.size.y
	_ctext(root, _t("CERTIFICATE"), fb, int(ph*0.042), Color(0.15,0.10,0.07), Vector2(pw*0.5, ph*0.145))
	_ctext(root, _t("b u r e a u   o f   a t t r i b u t i o n"), fr, int(ph*0.017), Color(0.36,0.27,0.17), Vector2(pw*0.5, ph*0.192))
	_ctext(root, _t("This bureau attributes the piece as follows —"), fr, int(ph*0.016), Color(0.42,0.33,0.22), Vector2(pw*0.5, ph*0.232))
	opt_layer = Control.new(); opt_layer.set_anchors_preset(Control.PRESET_FULL_RECT); root.add_child(opt_layer)
	root.set_meta("medallion", Vector2(pw*0.492, ph*0.895))
	# ПРАВА ПАНЕЛЬ вибору (на екрані, не на папері)
	var panx := root.position.x + cwd + W*0.03
	cert_panel = Control.new(); cert_panel.position = Vector2(panx, H*0.16)
	cert_panel.size = Vector2(W - panx - W*0.03, H*0.7); cert_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	s.add_child(cert_panel)
	_txtbtn(s, "←  back to the desk", Vector2(W*0.04, H*0.94), func(): _show("HUB" if case_done else ("FURN" if case_id == 2 else "DESK")))

# ---- БЛАНК-РЕЧЕННЯ: гравець реконструює історію; графа «на підставі чого» вимагає доказу ----
# ---- КОЛОДА СПРАВ: нова справа = НОВИЙ ЗАПИС, не новий код ----
# ── АТЕСТАТ ІЗ ТАБЛИЦЬ (крок 7) ──────────────────────────────────────────────
# Графи описані в data/case_NN.gd SLOTS: CHOICE (id варіантів, на папір лягає текст),
# NUMBER (цифри вписуються вручну; меж і — формат поля, НЕ валідація відповіді:
# гра ніколи не каже «правильно»), FACTS (2..4 зібрані факти як підстава).
# Істину рушій не знає — її знають лише OUTCOMES у даних.
var case_id := 1
var CSLOTS: Array = []
var cvals: Array = []
var active_slot := 0   # варіанти показуються ЛИШЕ для активного слота
var num_buf := ""      # набрані цифри активної NUMBER-графи

func _slot_index(sid: StringName) -> int:
	for j in CSLOTS.size():
		if StringName((CSLOTS[j] as Dictionary)["id"]) == sid: return j
	return -1

func _slot_filled(i: int) -> bool:
	var sl: Dictionary = CSLOTS[i]
	if String(sl["kind"]) == "FACTS":
		return cvals[i] is Array and (cvals[i] as Array).size() >= int(sl.get("min_count", 1))
	return not (cvals[i] is String and String(cvals[i]) == "")

func _slot_open(sl: Dictionary) -> bool:
	for f in sl.get("needs", []):
		if not facts.has(String(f)): return false
	var any: Array = sl.get("needs_any", [])
	if not any.is_empty():
		var hit := false
		for f in any:
			if facts.has(String(f)): hit = true
		if not hit: return false
	for sid in sl.get("needs_slot", []):
		var j := _slot_index(StringName(sid))
		if j < 0 or not _slot_filled(j): return false
	return true

func _opt_text(sl: Dictionary, oid: StringName) -> String:
	for o in sl.get("opts", []):
		if StringName((o as Array)[0]) == oid: return String((o as Array)[1])
	return String(oid)

func _case_facts_table() -> Dictionary:
	return (CASE_DATA[case_id] as Object).get("FACTS") if CASE_DATA.has(case_id) else {}

# що лягає на папір у графі i
func _slot_display(i: int) -> String:
	var sl: Dictionary = CSLOTS[i]
	match String(sl["kind"]):
		"NUMBER":
			if cvals[i] is int:
				return str(cvals[i]) + (" " + String(sl.get("suf", "")) if String(sl.get("suf", "")) != "" else "")
			return ""
		"FACTS":
			if cvals[i] is Array:
				var cites: Array = []
				var ft := _case_facts_table()
				for fid in cvals[i]:
					cites.append(String((ft.get(StringName(fid), {}) as Dictionary).get("cite", fid)))
				return "; ".join(cites)
			return ""
		_:
			if cvals[i] is String and String(cvals[i]) == "": return ""
			return _opt_text(sl, StringName(cvals[i]))

# діегетична підказка закритої графи — чого БРАКУЄ, не що вписати
func _slot_hint(sl: Dictionary) -> String:
	if sl.has("hint"): return String(sl["hint"])   # підказка живе в ДАНИХ справи
	match StringName(sl["id"]):
		&"s.origin": return "( match the mark, then the register )"
		&"s.fineness", &"s.not_before": return "( the handbook of marks will speak to this )"
		&"s.marks": return "( run a finger over the top of the foot )"
		&"s.provenance": return "( set down how the marks were struck, first )"
		&"s.basis": return "( name the ruling above, first )"
	return "( … )"

func _clear_dependents(changed: StringName) -> void:
	for j in CSLOTS.size():
		var sl: Dictionary = CSLOTS[j]
		if changed in sl.get("clears_on", []):
			cvals[j] = "" if String(sl["kind"]) != "FACTS" else []

func _choose(i: int, oid: StringName) -> void:
	if sealed: return
	cvals[i] = oid
	_clear_dependents(StringName((CSLOTS[i] as Dictionary)["id"]))
	_play("pen_write")
	active_slot = _next_open_slot()
	_refresh_cert()
	_save_game()

# ЄДИНИЙ вхід числа у графу (кнопка ✓ і тести йдуть сюди). Межі digits/min/max —
# формат поля; про ПРАВИЛЬНІСТЬ гра мовчить (правило 6).
func _commit_number(i: int, v: int) -> bool:
	if sealed: return false
	var sl: Dictionary = CSLOTS[i]
	if v < int(sl.get("min", 0)) or v > int(sl.get("max", 9999)): return false
	if str(v).length() != int(sl.get("digits", str(v).length())): return false
	cvals[i] = v
	_clear_dependents(StringName(sl["id"]))
	_play("pen_write"); num_buf = ""
	active_slot = _next_open_slot()
	_refresh_cert(); _save_game(); return true

func _toggle_basis(i: int, fid: StringName) -> void:
	if sealed: return
	if not (cvals[i] is Array): cvals[i] = []
	var a: Array = cvals[i]
	if fid in a: a.erase(fid)
	elif a.size() < int((CSLOTS[i] as Dictionary).get("max_count", 4)): a.append(fid)
	_play("pen_write"); _refresh_cert(); _save_game()

func _next_open_slot() -> int:
	for j in CSLOTS.size():
		if _slot_open(CSLOTS[j]) and not _slot_filled(j): return j
	return -1

func _all_filled() -> bool:
	for j in CSLOTS.size():
		if not _slot_filled(j): return false
	return true

func _refresh_cert() -> void:
	for c in opt_layer.get_children(): c.queue_free()
	for c in cert_panel.get_children(): c.queue_free()
	var pw := cert_layer.size.x; var ph := cert_layer.size.y
	var n := CSLOTS.size()
	# рядки рівномірно між шапкою і медальйоном; 6 граф уміщаються з кроком 0.088
	var y0 := 0.235; var step := 0.088 if n >= 6 else 0.118
	for i in n:
		var sl: Dictionary = CSLOTS[i]
		var yyi := y0 + step*float(i)
		var gate_open := _slot_open(sl)
		var pre := Label.new(); pre.label_settings = _ls(fr, int(ph*0.018), Color(0.34,0.25,0.16))
		pre.text = _t(String(sl["pre"])); pre.position = Vector2(pw*0.17, ph*yyi); pre.mouse_filter = Control.MOUSE_FILTER_IGNORE; opt_layer.add_child(pre)
		var line := ColorRect.new(); line.color = Color(0.44,0.34,0.22) if (gate_open and not sealed) else Color(0.60,0.52,0.40)
		line.size = Vector2(pw*0.66, 1.5); line.position = Vector2(pw*0.17, ph*(yyi+0.052)); line.mouse_filter = Control.MOUSE_FILTER_IGNORE; opt_layer.add_child(line)
		var val := Label.new()
		var small: bool = String(sl["kind"]) == "FACTS"
		val.label_settings = _ls(fh, int(ph*(0.019 if small else 0.024)), Color(0.16,0.11,0.08))
		val.position = Vector2(pw*0.195, ph*(yyi+0.016))
		val.size = Vector2(pw*0.62, ph*0.05); val.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		val.text = _slot_display(i); val.mouse_filter = Control.MOUSE_FILTER_IGNORE; opt_layer.add_child(val)
		if sealed: continue
		if gate_open:
			if active_slot == i:
				var hl := ColorRect.new(); hl.color = Color(0.62,0.11,0.10,0.12); hl.size = Vector2(pw*0.68, ph*0.068)
				hl.position = Vector2(pw*0.16, ph*(yyi-0.006)); hl.mouse_filter = Control.MOUSE_FILTER_IGNORE; opt_layer.add_child(hl)
			var pick := Button.new(); pick.flat = true; pick.modulate.a = 0
			pick.position = Vector2(pw*0.16, ph*(yyi-0.006)); pick.size = Vector2(pw*0.68, ph*0.068)
			pick.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			var si := i; pick.pressed.connect(func(): active_slot = si; num_buf = ""; _refresh_cert())
			opt_layer.add_child(pick)
		elif not _slot_filled(i):
			var hnt := Label.new(); hnt.label_settings = _ls(fr, int(ph*0.015), Color(0.56,0.49,0.40))
			hnt.text = _t(_slot_hint(sl))
			hnt.position = Vector2(pw*0.195, ph*(yyi+0.018)); hnt.mouse_filter = Control.MOUSE_FILTER_IGNORE; opt_layer.add_child(hnt)
			# клік по зачиненій графі — підказка СПАЛАХУЄ (тиша = «зламано», плейтест 27.07)
			var poke := Button.new(); poke.flat = true; poke.modulate.a = 0
			poke.position = Vector2(pw*0.16, ph*(yyi-0.006)); poke.size = Vector2(pw*0.68, ph*0.068)
			poke.pressed.connect(func():
				_play("ui_soft")
				hnt.modulate = Color(2.2, 1.6, 1.0)
				create_tween().tween_property(hnt, "modulate", Color(1,1,1), 0.7))
			opt_layer.add_child(poke)
	if not sealed:
		_build_cert_panel()
	if not sealed and not _all_filled() and cert_layer.has_node("stamp_hs"):
		cert_layer.get_node("stamp_hs").queue_free()
	if not sealed and _all_filled():
		if not cert_layer.has_node("stamp_hs"):
			var med: Vector2 = cert_layer.get_meta("medallion")
			var hs := Button.new(); hs.name = "stamp_hs"; hs.flat = true; hs.modulate.a = 0
			hs.position = Vector2(med.x-pw*0.11, med.y-pw*0.11); hs.size = Vector2(pw*0.22, pw*0.22)
			hs.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			hs.mouse_entered.connect(_set_hint.bind("Press the seal — once set, it cannot be lifted."))
			hs.pressed.connect(func(): _do_verdict())
			cert_layer.add_child(hs)
		var seal_note := Label.new(); seal_note.label_settings = _ls(fr, int(H*0.024), Color(0.86,0.66,0.42))
		seal_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; seal_note.size = Vector2(cert_panel.size.x, H*0.2)
		# заклик стоїть ПІД вмістом панелі: коли графа ще редагується (список фактів —
		# до 8 рядків, ~0.5H), фіксовані 0.42H друкувались ПОВЕРХ списку — спіймано
		# оком на кадрі 18_cert_full і підтверджено думкою про layoutcheck у гейті
		seal_note.position = Vector2(0, H*0.72 if active_slot >= 0 else H*0.30)
		seal_note.text = _t("The attribution is written.\nPress the wax seal to close the case — once set, it cannot be lifted.")
		cert_panel.add_child(seal_note)

# права панель: вміст залежить від ТИПУ активної графи
func _build_cert_panel() -> void:
	var i := active_slot
	if i < 0 or i >= CSLOTS.size() or not _slot_open(CSLOTS[i]):
		var d := Label.new(); d.label_settings = _ls(fr, int(H*0.024), Color(0.82,0.77,0.67))
		d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; d.size = Vector2(cert_panel.size.x, H*0.3)
		d.text = _t("Set down each line of the attribution.\nClick any line on the left to fill or change it.")
		cert_panel.add_child(d); return
	var sl: Dictionary = CSLOTS[i]
	var head := Label.new(); head.label_settings = _ls(fr, int(H*0.03), Color(0.72,0.61,0.43))
	head.text = String(sl["pre"]) + " …"; head.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	head.size = Vector2(cert_panel.size.x, H*0.1); cert_panel.add_child(head)
	match String(sl["kind"]):
		"CHOICE": _panel_choice(i, sl)
		"NUMBER": _panel_number(i, sl)
		"FACTS": _panel_facts(i, sl)

func _panel_choice(i: int, sl: Dictionary) -> void:
	var y := H*0.11
	for o in sl.get("opts", []):
		var oid := StringName((o as Array)[0]); var txt := String((o as Array)[1])
		var chosen: bool = (cvals[i] is StringName or cvals[i] is String) and StringName(cvals[i]) == oid
		var bo := Button.new(); bo.flat = true; bo.text = ("●   " if chosen else "○   ") + _t(txt)
		bo.add_theme_font_override("font", fr); bo.add_theme_font_size_override("font_size", int(H*0.026))
		bo.add_theme_color_override("font_color", Color(0.92,0.44,0.36) if chosen else Color(0.90,0.85,0.74))
		bo.add_theme_color_override("font_hover_color", Color(0.99,0.72,0.42))
		bo.alignment = HORIZONTAL_ALIGNMENT_LEFT; bo.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		bo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART   # довга опція переноситься, не тікає за екран
		bo.position = Vector2(0, y); bo.size = Vector2(cert_panel.size.x, H*0.075)
		var ii := i; bo.pressed.connect(func(): _choose(ii, oid))
		cert_panel.add_child(bo)
		y += H*0.082   # крок під двохрядкові опції (autowrap)

# цифри вписуються рукою: клавіатура з мальованого стилю UI (текстові пункти)
func _panel_number(i: int, sl: Dictionary) -> void:
	var digits := int(sl.get("digits", 3))
	var shown := num_buf
	var slotline := Label.new(); slotline.label_settings = _ls(fh, int(H*0.05), Color(0.93,0.87,0.72))
	var pad := ""
	for _k in range(digits - shown.length()): pad += "_"
	slotline.text = shown + pad + ("  " + String(sl.get("suf","")) if String(sl.get("suf","")) != "" else "")
	slotline.position = Vector2(0, H*0.11); cert_panel.add_child(slotline)
	var rows := [["1","2","3","4","5"], ["6","7","8","9","0"]]
	var y := H*0.20
	for row in rows:
		var x := 0.0
		for dch in row:
			var b := Button.new(); b.flat = true; b.text = String(dch)
			b.add_theme_font_override("font", fr); b.add_theme_font_size_override("font_size", int(H*0.034))
			b.add_theme_color_override("font_color", Color(0.90,0.85,0.74))
			b.add_theme_color_override("font_hover_color", Color(0.99,0.72,0.42))
			b.position = Vector2(x, y); b.size = Vector2(H*0.06, H*0.05)
			b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			var dc := String(dch)
			b.pressed.connect(func():
				if num_buf.length() < digits: num_buf += dc; _play("ui_soft"); _refresh_cert())
			cert_panel.add_child(b)
			x += H*0.07
		y += H*0.06
	var back := Button.new(); back.flat = true; back.text = _t("⌫  strike it out")
	back.add_theme_font_override("font", fr); back.add_theme_font_size_override("font_size", int(H*0.024))
	back.add_theme_color_override("font_color", Color(0.72,0.66,0.54))
	back.position = Vector2(0, y + H*0.01); back.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	back.pressed.connect(func():
		if num_buf.length() > 0: num_buf = num_buf.substr(0, num_buf.length()-1); _refresh_cert())
	cert_panel.add_child(back)
	# ДОРЕЧНІ НОТАТКИ ПІД ПОЛЕМ (Віктор: «не розумію що вписувати від handbook»):
	# графа показує ТІ записи нотатника, яких сама вимагає (needs) — зіставлення
	# клейма з таблицею перед очима, а число гравець виводить сам (правило 6:
	# це його ж нотатки, не відповідь)
	var ny := y + H*0.16
	var ft2 := _case_facts_table()
	for nf in sl.get("needs", []):
		if not facts.has(String(nf)): continue
		var fd2: Dictionary = ft2.get(StringName(nf), {})
		if not fd2.has("text"): continue
		var note2 := Label.new(); note2.label_settings = _ls(fh, int(H*0.019), Color(0.80,0.75,0.64))
		note2.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		note2.size = Vector2(cert_panel.size.x, H*0.11)
		note2.text = _t("— ") + String(fd2["text"])
		note2.position = Vector2(0, ny); cert_panel.add_child(note2)
		ny += H*0.115
	if num_buf.length() == digits:
		var v := int(num_buf)
		if v >= int(sl.get("min", 0)) and v <= int(sl.get("max", 9999)):
			var okb := Button.new(); okb.flat = true; okb.text = _t("✒  set it down")
			okb.add_theme_font_override("font", fr); okb.add_theme_font_size_override("font_size", int(H*0.028))
			okb.add_theme_color_override("font_color", Color(0.99,0.72,0.42))
			okb.position = Vector2(0, y + H*0.07); okb.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			var ii := i
			okb.pressed.connect(func(): _commit_number(ii, v))
			cert_panel.add_child(okb)

# підстава: 2..4 факти з нотатника, у порядку відкриття
func _panel_facts(i: int, sl: Dictionary) -> void:
	var picked: Array = cvals[i] if cvals[i] is Array else []
	var ft := _case_facts_table()
	# дві колонки по 8: 15 фактів однією колонкою тікали за низ екрана і
	# билися з закликом печатки (аудит 27.07, s2_cert_full)
	var idx := 0
	for fid_s in facts:
		var fid := StringName(fid_s)
		if not ft.has(fid): continue
		var cite := String((ft[fid] as Dictionary).get("cite", fid_s))
		var chosen: bool = fid in picked
		var bo := Button.new(); bo.flat = true; bo.text = ("☑ " if chosen else "☐ ") + _t(cite)
		bo.add_theme_font_override("font", fr); bo.add_theme_font_size_override("font_size", int(H*0.019))
		bo.add_theme_color_override("font_color", Color(0.92,0.44,0.36) if chosen else Color(0.90,0.85,0.74))
		bo.add_theme_color_override("font_hover_color", Color(0.99,0.72,0.42))
		bo.alignment = HORIZONTAL_ALIGNMENT_LEFT; bo.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		bo.clip_text = true
		bo.position = Vector2(cert_panel.size.x*0.52*float(idx / 8), H*(0.11 + 0.052*float(idx % 8)))
		bo.size = Vector2(cert_panel.size.x*0.50, H*0.046)
		var ii := i
		bo.pressed.connect(func(): _toggle_basis(ii, fid))
		cert_panel.add_child(bo)
		idx += 1
	var note := Label.new(); note.label_settings = _ls(fr, int(H*0.017), Color(0.64,0.57,0.47))
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; note.size = Vector2(cert_panel.size.x, H*0.10)
	note.text = _t("Two to four citations. Name the proof that would still stand if the client's story did not.")
	note.position = Vector2(0, H*0.56); cert_panel.add_child(note)

# наслідок вироку — ПОДІЯ наступного ранку. Матчер по OUTCOMES даних: перший збіг.
func _outcome_text() -> String:
	var outs: Array = (CASE_DATA[case_id] as Object).get("OUTCOMES") if CASE_DATA.has(case_id) else []
	var ft := _case_facts_table()
	var basis: Array = []
	for j in CSLOTS.size():
		if String((CSLOTS[j] as Dictionary)["kind"]) == "FACTS" and cvals[j] is Array:
			basis = cvals[j]
	for o in outs:
		var oo: Dictionary = o
		var when: Dictionary = oo.get("when", {})
		var hit := true
		for sid in when:
			var j2 := _slot_index(StringName(sid))
			if j2 < 0: hit = false; break
			var want = when[sid]
			var have = cvals[j2]
			if want is Dictionary:
				# діапазон для NUMBER-графи: {"min": 18, "max": 20}
				if not (have is int and int(have) >= int(want.get("min", -2147483648)) \
						and int(have) <= int(want.get("max", 2147483647))): hit = false; break
			elif want is int:
				if not (have is int and int(have) == int(want)): hit = false; break
			else:
				if not ((have is StringName or have is String) and StringName(have) == StringName(want)): hit = false; break
		if not hit: continue
		var need_any: Array = oo.get("basis_any", [])
		if not need_any.is_empty():
			var got := false
			for f in need_any:
				if StringName(f) in basis: got = true
			if not got: continue
		var forbid: Array = oo.get("basis_forbids", [])
		var bad := false
		for f in forbid:
			if StringName(f) in basis: bad = true
		if bad: continue
		var wmin := int(oo.get("basis_weight", 0))
		if wmin > 0:
			var wsum := 0
			for fid in basis:
				wsum += int((ft.get(StringName(fid), {}) as Dictionary).get("weight", 0))
			if wsum < wmin: continue
		last_outcome_id = String(oo.get("id", ""))
		return _t(String(oo.get("text", "")))
	# правило 17: промах усіх наслідків — це ПОДІЯ, її видно в логу з даними
	print("OUTCOME_MISS case=", case_id, " cvals=", cvals, " basis=", basis)
	return _t("The morning brought nothing that could be set down in the ledger.")

var last_outcome_id := ""   # для тестів: який запис ранку зіграв

func _do_verdict() -> void:
	if sealed: return
	sealed = true; seals_set += 1
	_save_game()
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
		head.text = _t("The next morning."); head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		head.size = Vector2(W, H*0.05); head.position = Vector2(0, H*0.15); head.mouse_filter = Control.MOUSE_FILTER_IGNORE; s.add_child(head)
		_txtbtn(s, "close the ledger  →", Vector2(W*0.62, H*0.8), func(): _evening())
	var mt: Label = screens["MORNING"].get_node("mtext")
	mt.text = _outcome_text()
	_show("MORNING")
	_play("page_turn")

# ---------- ГРОСБУХ: кінець справи + ЛІЧИЛЬНИК ПЕЧАТОК (гачок мета-сюжету) ----------
# ================= СПРАВА 2 «СПАДОК УДОВИ» (два свідчення) =================
# Річ сама викриває брехуна: знос голівки під ліву руку + свіжі подряпини на вушку.
const CLIENT2_LINES := [
	"The bell. A woman in a dark shawl comes in alone; what she brings stands on a cart outside, wrapped in blankets.\n\n\u00abFrau Vogl. I kept house for Herr F. Twenty-two years.\u00bb",
	"\u00abThe secretaire is mine, by his will. I mean to sell it, and the bureau is to say what it is worth.\u00bb",
	"\u00abMy son sails on Thursday. The ticket is forty-one gulden and I have nineteen. I am not asking you for a good price. I am asking you for a quick one.\u00bb",
	"She holds the door wide. The porters walk the wrapped bulk through on its corner \u2014 a hand's breadth clear of either jamb.",
	"The porters carry it in and set it by the window. She watches the way one watches a room being emptied \u2014 and keeps her right hand inside the shawl.",
]
var client2_line := 0
var client_panels: Array = []        # комікс-панелі сцени клієнтки 1
var client2_panels: Array = []       # комікс-панелі сцени клієнтки 2

# КОМІКС-СЦЕНА (Віктор 28.07: «історія на одному кадрі — погано, роби коміксом»):
# кожна репліка — своя гравюрна панель; панелі проявляються по черзі,
# попередні пригасають. Кадри мальовані, рамка — тонке паспарту.
func _comic_panel(parent: Control, texname: String, r: Rect2) -> Control:
	var holder := Control.new(); holder.position = r.position; holder.size = r.size
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat2 := ColorRect.new(); mat2.color = Color(0.82, 0.76, 0.62, 0.92)
	mat2.position = Vector2(-4, -4); mat2.size = r.size + Vector2(8, 8)
	mat2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(mat2)
	if tex.has(texname):
		var im := TextureRect.new(); im.texture = tex[texname]
		im.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		im.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		im.clip_contents = true
		im.size = r.size; im.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.add_child(im)
	holder.visible = false
	parent.add_child(holder)
	return holder

func _comic_show(panels: Array, upto: int) -> void:
	for i in panels.size():
		var pn: Control = panels[i]
		if i > upto:
			pn.visible = false
			continue
		var want := 1.0 if i == upto else 0.62
		if not pn.visible:
			pn.visible = true
			pn.modulate = Color(1, 1, 1, 0)
			create_tween().tween_property(pn, "modulate", Color(want, want, want, 1), 0.4)
		else:
			create_tween().tween_property(pn, "modulate", Color(want, want, want, 1), 0.3)

func _build_client2() -> void:
	var s2 := _screen("CLIENT2")
	_paper_backdrop(s2, 0.06)
	client2_panels = [
		_comic_panel(s2, "client_vogl", Rect2(W*0.055, H*0.07, W*0.315, H*0.68)),
		_comic_panel(s2, "cl2_p2",     Rect2(W*0.415, H*0.07, W*0.255, H*0.315)),
		_comic_panel(s2, "cl2_p3",     Rect2(W*0.695, H*0.07, W*0.255, H*0.315)),
		_comic_panel(s2, "cl2_door",   Rect2(W*0.415, H*0.435, W*0.255, H*0.315)),
		_comic_panel(s2, "cl2_p4",     Rect2(W*0.695, H*0.435, W*0.255, H*0.315)),
	]
	_band(s2)
	var l := Label.new(); l.name = "c2text"; l.label_settings = _ls(fr, int(H*0.028), Color(0.95,0.91,0.82))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; l.size = Vector2(W*0.62, H*0.175); l.position = Vector2(W*0.19, H*0.80)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE; s2.add_child(l)
	var adv2 := Button.new(); adv2.flat = true; adv2.modulate.a = 0
	adv2.size = Vector2(W, H); adv2.position = Vector2.ZERO
	adv2.pressed.connect(func(): _client2_next())
	s2.add_child(adv2); s2.move_child(adv2, 0)
	_txtbtn(s2, "go on  →", Vector2(W*0.845, H*0.905), func(): _client2_next(), 0.030)

func _client2_next() -> void:
	client2_line += 1
	if client2_line >= CLIENT2_LINES.size():
		_play("goblet_set")
		_show("FURN")
		return
	_client2_show()

func _client2_show() -> void:
	if not screens.has("CLIENT2"): _build_client2()
	var l: Label = screens["CLIENT2"].get_node("c2text")
	var li := clampi(client2_line, 0, CLIENT2_LINES.size()-1)
	l.text = _t(CLIENT2_LINES[li])
	_comic_show(client2_panels, li)

func _start_case2() -> void:
	_load_case(2)
	_c2_seen = false; sec_yaw = 0.0
	if sec_pivot: sec_pivot.rotation.y = 0.0
	client2_line = 0
	_client2_show()
	_play("door_bell")
	_show("CLIENT2")

# РОЗРІЗ СЕКРЕТЕРА (Віктор 28.07: «не бачу ні числа, ні що міряю; клікання в
# тупу»). Кожен вимір ЛЯГАЄ виносною лінією з числом на бічне креслення, а
# порожнина проступає як зазор між внутрішньою і зовнішньою глибиною. Клік по
# самій лінії і Є вимірюванням — не треба полювати на схований торець.
const SEC_FRONT := 0.435      # частка ширини креслення: перед корпусу (звідки міряють)
const SEC_INNER := 0.635      # задня дощечка колодязя
const SEC_OUTER := 0.868      # зовнішня задня стінка
var section_img: TextureRect
var section_ov: Control

func _build_section() -> void:
	var s := _screen("SECTION")
	_paper_backdrop(s, 0.10)
	var head := Label.new(); head.label_settings = _ls(fr, int(H*0.030), Color(0.90,0.86,0.77))
	head.label_settings.shadow_color = Color(0,0,0,0.8); head.label_settings.shadow_offset = Vector2(1.5,1.5)
	head.text = _t("The piece in section — take its depths, and see what they leave.")
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	head.size = Vector2(W*0.78, H*0.05); head.position = Vector2(W*0.11, H*0.03); head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	s.add_child(head)
	var t: Texture2D = tex.get("sec_section", null)
	if t:
		var ih := H*0.72; var iw := ih*float(t.get_width())/float(t.get_height())
		section_img = TextureRect.new(); section_img.texture = t
		section_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; section_img.stretch_mode = TextureRect.STRETCH_SCALE
		section_img.size = Vector2(iw, ih); section_img.position = Vector2((W-iw)*0.5, H*0.13)
		section_img.mouse_filter = Control.MOUSE_FILTER_IGNORE
		s.add_child(section_img)
	section_ov = Control.new(); section_ov.mouse_filter = Control.MOUSE_FILTER_IGNORE
	section_ov.set_anchors_preset(Control.PRESET_FULL_RECT); s.add_child(section_ov)
	_txtbtn(s, "←  step back", Vector2(W*0.04, H*0.92), func(): _show("FURN"))
	_txtbtn(s, "✎", Vector2(W*0.945, H*0.055), func(): _show_notebook(), 0.030)
	_refresh_section()

# виносна лінія: горизонтальна планка з засічками + число; або пунктир-кнопка,
# якщо вимір ще не взято (клік = взяти цей вимір саме тут)
func _dim_line(y_frac: float, x0f: float, x1f: float, taken: bool, val: String,
			   zone: String, label: String) -> void:
	if section_img == null or section_ov == null: return
	var r := Rect2(section_img.position, section_img.size)
	var y := r.position.y + r.size.y * y_frac
	var x0 := r.position.x + r.size.x * x0f
	var x1 := r.position.x + r.size.x * x1f
	var col := Color(0.62,0.11,0.10) if taken else Color(0.46,0.40,0.32)
	var bar := ColorRect.new(); bar.color = Color(col.r, col.g, col.b, 1.0 if taken else 0.55)
	bar.size = Vector2(x1-x0, maxf(2.0, H*0.004 if taken else H*0.002)); bar.position = Vector2(x0, y)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE; section_ov.add_child(bar)
	for xx in [x0, x1]:   # засічки
		var tick := ColorRect.new(); tick.color = col
		tick.size = Vector2(maxf(2.0,H*0.003), H*0.028); tick.position = Vector2(xx-1, y-H*0.014)
		tick.mouse_filter = Control.MOUSE_FILTER_IGNORE; section_ov.add_child(tick)
	var lb := Label.new()
	lb.label_settings = _ls(fb, int(H*0.030), col)
	lb.label_settings.shadow_color = Color(0.97,0.94,0.86,0.95); lb.label_settings.shadow_offset = Vector2(1.5,1.5)
	lb.text = (val if taken else "?")   # інструкція — у смузі підказки, не на кресленні
	lb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lb.size = Vector2(x1-x0, H*0.04); lb.position = Vector2(x0, y - H*0.05)
	lb.mouse_filter = Control.MOUSE_FILTER_IGNORE; section_ov.add_child(lb)
	if not taken and zone != "":
		var b := Button.new(); b.flat = true; b.modulate.a = 0
		b.position = Vector2(x0, y - H*0.055); b.size = Vector2(x1-x0, H*0.075)
		b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		b.mouse_entered.connect(_set_hint.bind(_t(label)))
		b.mouse_exited.connect(_set_hint.bind(""))
		b.pressed.connect(func(): _apply_zone(zone, &"tool.caliper"); _refresh_section())
		section_ov.add_child(b)

func _refresh_section() -> void:
	if section_ov == null: return
	for c in section_ov.get_children(): c.queue_free()
	var out_done: bool = facts.has("f.outer_depth")
	var in_done: bool = facts.has("f.inner_depth")
	var th_done: bool = facts.has("f.back_thickness")
	# 1) зовнішня глибина — від переду до зовнішньої стінки
	_dim_line(0.20, SEC_FRONT, SEC_OUTER, out_done, "486 mm",
		"z.sec.carcass_side", "measure the whole depth, front to the outer back — click here")
	# 2) внутрішня глибина — від переду до дощечки колодязя (лише після зовнішньої)
	if out_done:
		_dim_line(0.40, SEC_FRONT, SEC_INNER, in_done, "455 mm",
			"z.well.back_board", "now the inside depth, front to the well's board — click here")
	# 3) товщина дощечки — маленька, при внутрішній стінці
	if out_done:
		_dim_line(0.58, SEC_INNER, SEC_INNER+0.035, th_done, "12 mm",
			"z.sec.back_edge", "and the board's own thickness — click here")
	# 4) ЗАЗОР — проступає, коли відомі обидві глибини: зафарбована порожнина + число
	if out_done and in_done and th_done:
		var r := Rect2(section_img.position, section_img.size)
		var gx0 := r.position.x + r.size.x * (SEC_INNER + 0.035)
		var gx1 := r.position.x + r.size.x * SEC_OUTER
		var gy := r.position.y + r.size.y * 0.20
		var gh := r.size.y * 0.42
		var shade := ColorRect.new(); shade.color = Color(0.62,0.11,0.10,0.22)
		shade.position = Vector2(gx0, gy); shade.size = Vector2(gx1-gx0, gh)
		shade.mouse_filter = Control.MOUSE_FILTER_IGNORE; section_ov.add_child(shade)
		var gl := Label.new(); gl.label_settings = _ls(fb, int(H*0.026), Color(0.62,0.11,0.10))
		gl.label_settings.shadow_color = Color(0.97,0.94,0.86,0.9); gl.label_settings.shadow_offset = Vector2(1,1)
		gl.text = "486 − 12 − 455 = 19 mm\n" + _t("a hollow that should not be here")
		gl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; gl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		gl.size = Vector2(r.size.x*0.34, H*0.14); gl.position = Vector2(gx1 + W*0.01, gy + gh*0.2)
		gl.mouse_filter = Control.MOUSE_FILTER_IGNORE; section_ov.add_child(gl)

# ТОН ДЕРЕВА: Meshy запікає нутро надто помаранчевим і лакованим — приглушуємо
# альбедо в теплий горіх і збиваємо дзеркальність, щоб нутро було рівня фасаду
# Масштабує модель так, щоб її ШИРИНА дорівнювала заданій у міліметрах, і
# ставить її початок координат у центр (0,0,0) власного габариту.
func _fit_mm(node: Node3D, width_mm: float) -> AABB:
	var a := _aabb(node)
	if a.size.x <= 0.0: return a
	var k: float = (width_mm * 0.001) / a.size.x
	node.scale = Vector3(k, k, k)
	var a2 := _aabb(node)
	node.position -= a2.get_center() - node.position
	return _aabb(node)

func _tone_wood(root: Node) -> void:
	for m in root.find_children("*", "MeshInstance3D", true, false):
		var mi := m as MeshInstance3D
		var base := mi.get_active_material(0)
		var mat: StandardMaterial3D
		if base is StandardMaterial3D:
			mat = (base as StandardMaterial3D).duplicate()
		else:
			mat = StandardMaterial3D.new()
		# помаранч гасимо холоднішим множником, лак — нулем блиску (Віктор 29.07:
		# «дуже яскраво, лак ніби щойно залитий»)
		# КАРТИ БЛИСКУ З МЕША — ГЕТЬ: roughness/metallic у Godot МНОЖАТЬСЯ на свої
		# текстури, тому число 1.0 не гасило запечений лак, і він спалахував при
		# обертанні (скарга Віктора 29.07 зі скріна)
		mat.roughness_texture = null
		mat.metallic_texture = null
		mat.albedo_color = Color(0.40, 0.45, 0.47)
		mat.roughness = 0.96
		mat.metallic = 0.0
		mat.specular = 0.06
		mat.metallic_specular = 0.0
		mi.material_override = mat

func _build_case2() -> void:
	# СПРАВА 2 «СЕКРЕТЕР» (27.07): три меші Meshy в одному світі; три екрани —
	# три камери на той самий предмет (FURN загальний 3/4 · WELL писальний відділ
	# · DRAWER шухляда в руках). Правило РЕЖИСУРИ 14: план загальний → середній →
	# деталь, географія предмета не ламається.
	var sv := SubViewport.new(); sv.size = Vector2i(int(W), int(H))
	sv.msaa_3d = Viewport.MSAA_4X; add_child(sv)
	sv.own_world_3d = true    # свій світ: див. урок «ваза в шафі» вище
	# фон НЕ прозорий: небо-градієнт бюро з env і є кімнатою за предметом
	_build_bureau_light(sv, false, Color(0.055, 0.048, 0.042))   # прапорець «меблі» для світла
	sec_world = sv.find_world_3d()
	# КІМНАТА ПОЗАДУ (Віктор 29.07: «темрява ззаду — пусто»): мальований кабінет
	# як задник У СВІТІ — предмет стоїть у кімнаті, а не висить у чорноті
	if tex.has("bureau_room"):
		var room := MeshInstance3D.new()
		var rq := QuadMesh.new(); rq.size = Vector2(27.0, 15.2)
		room.mesh = rq
		var rmat := StandardMaterial3D.new()
		rmat.albedo_texture = tex["bureau_room"]
		rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED   # мальоване світло, не наше
		rmat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
		room.material_override = rmat
		room.position = Vector3(-0.35, 1.1, -6.6)
		room.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		sv.add_child(room)
	# ПІВОТ: усі частини секретера — діти одного вузла, щоб оберт від
	# перетягування крутив ЦІЛУ річ як предмет у руках (правило 18)
	sec_pivot = Node3D.new(); sv.add_child(sec_pivot)
	var body_s: PackedScene = load("res://models/secretaire_body.glb")
	var body := body_s.instantiate() as Node3D
	sec_pivot.add_child(body); mesh_nodes[&"sec_body"] = body
	_tone_wood(body)
	_fit_mm(body, 1100.0)
	# ДВА СТАНИ КОРПУСА (як день/ніч кабінету, лише в 3D): FURN — дошка зачинена,
	# WELL — відкинута, з нутром і задньою стінкою відділу. Своп у _sync_case2_view.
	var open_s: PackedScene = load("res://models/sec_carcass_v3.glb")
	var body_open := open_s.instantiate() as Node3D
	_tone_wood(body_open)
	_fit_mm(body_open, 1100.0)   # той самий габарит, що в зачиненої
	body_open.visible = false
	sec_pivot.add_child(body_open); mesh_nodes[&"sec_open"] = body_open
	sec_body_closed = body; sec_body_open = body_open
	# нормування: корпус ~1.9 h у метрах моделі — ставимо в нуль, камери від нього
	var drawer_s: PackedScene = load("res://models/secretaire_drawer.glb")
	var drawer := drawer_s.instantiate() as Node3D
	drawer.scale = Vector3(0.55, 0.55, 0.55)
	drawer.position = Vector3(0.0, -0.35, 0.55)   # висунута з нижньої секції
	drawer.visible = false
	sec_pivot.add_child(drawer); mesh_nodes[&"sec_drawer"] = drawer
	# ЗАДНЯ ДОЩЕЧКА — ОКРЕМА МОДЕЛЬ (правило 18): дошка з товщиною і об'ємними
	# латунними шурупами, підігнана по ширині 400 мм і посаджена в СПРАВЖНІЙ
	# отвір корпуса. Знімається викруткою — за нею порожнина самого корпуса.
	var pan_s: PackedScene = load("res://models/sec_panel_v3.glb")
	var bb := pan_s.instantiate() as Node3D
	sec_pivot.add_child(bb)
	_fit_mm(bb, 365.0)
	bb.rotation_degrees = Vector3(-90, 0, 0)
	bb.position = Vector3(0.0, 0.350, -0.195)
	for pm in bb.find_children("*", "MeshInstance3D", true, false):
		var pmi := pm as MeshInstance3D
		var pmat := StandardMaterial3D.new()
		var pbase := pmi.get_active_material(0)
		if pbase is StandardMaterial3D: pmat = (pbase as StandardMaterial3D).duplicate()
		pmat.roughness_texture = null; pmat.metallic_texture = null
		pmat.albedo_color = Color(0.60, 0.54, 0.46)   # бук, не білий
		pmat.roughness = 0.95; pmat.metallic = 0.0; pmat.specular = 0.05
		pmi.material_override = pmat
	mesh_nodes[&"sec_backboard"] = bb
	dust_quad = null
	sec_backboard = bb; sec_drawer = drawer
	# дно ніші: пил і ЧИСТИЙ прямокутник — головний доказ віддано оку, не тексту
	if tex.has("dust_floor"):
		var dq := MeshInstance3D.new()
		var qm := QuadMesh.new(); qm.size = Vector2(0.21, 0.16)
		dq.mesh = qm
		var dm2 := StandardMaterial3D.new()
		dm2.albedo_texture = tex["dust_floor"]
		dm2.roughness = 1.0
		dq.material_override = dm2
		# ніша дивиться на камеру: квад майже вертикальний, на місці знятої дошки,
		# трохи глибше — власна рамка текстури грає глибину
		dq.position = Vector3(0.0, 0.192, -0.068)
		dq.rotation_degrees = Vector3(-14, 0, 0)
		dq.visible = false
		sec_pivot.add_child(dq); dust_quad = dq
	# тавро столярні на споді шухляди: випалений штамп текстом (шрифт — виняток
	# правила 1) + крейдяний номер. ЛОКАЛЬНИЙ AABB меша: глобальний тут брехав би
	# (batьків scale/зсув), і перша посадка полетіла геть із геометрії.
	var dmesh: MeshInstance3D = null
	for dm in drawer.find_children("*", "MeshInstance3D", true, false):
		dmesh = dm as MeshInstance3D; break
	var dla: AABB = dmesh.get_aabb() if dmesh else AABB(Vector3(-1,-0.3,-0.5), Vector3(2,0.6,1))
	var brand := Label3D.new()
	brand.text = _t("M·GRUBER · WIEN")
	brand.font = fb; brand.font_size = 48; brand.pixel_size = 0.0011
	brand.modulate = Color(0.23, 0.13, 0.07, 0.95)
	brand.position = Vector3(dla.get_center().x - dla.size.x*0.22,
							 dla.position.y + 0.003,
							 dla.get_center().z + dla.size.z*0.18)
	brand.rotation_degrees = Vector3(90, 0, 0)
	brand.outline_size = 0
	drawer.add_child(brand)
	var chalk := Label3D.new()
	chalk.text = _t("367")
	chalk.font = fh; chalk.font_size = 66; chalk.pixel_size = 0.0011
	chalk.modulate = Color(0.92, 0.90, 0.84, 0.85)
	chalk.position = brand.position + Vector3(dla.size.x*0.30, 0, -dla.size.z*0.04)
	chalk.rotation_degrees = Vector3(90, 0, 0)
	chalk.outline_size = 0
	drawer.add_child(chalk)
	# три камери — ВІД ФАКТИЧНОГО ГАБАРИТУ моделі, не з голови (низ різало)
	var bb3 := _aabb(body)
	var c3 := bb3.get_center()
	var rr3 := bb3.size.length()
	var cf := Camera3D.new(); sv.add_child(cf); cf.fov = 36
	cf.position = c3 + Vector3(0.62, 0.18, 1.0).normalized()*rr3*1.38
	cf.look_at(c3, Vector3.UP)
	var cw := Camera3D.new(); sv.add_child(cw); cw.fov = 30
	var well_c := c3 + Vector3(0, bb3.size.y*0.155, 0)
	cw.position = well_c + Vector3(0.0, 0.30, 1.0).normalized()*rr3*0.95
	cw.look_at(well_c, Vector3.UP)
	var cd := Camera3D.new(); sv.add_child(cd); cd.fov = 30
	cd.position = drawer.position + Vector3(0.25, 0.55, 1.0).normalized()*rr3*0.5
	cd.look_at(drawer.position, Vector3.UP)
	sec_cams = {"FURN": cf, "WELL": cw, "DRAWER": cd}
	sec_cam_targets = {"FURN": cf.transform, "WELL": cw.transform, "DRAWER": cd.transform}
	# ОДНА жива камера: не ріже, а дольчить між кадрами (правило 14/18)
	sec_cam_live = Camera3D.new(); sv.add_child(sec_cam_live); sec_cam_live.fov = 34
	sec_cam_live.transform = cf.transform
	cf.queue_free(); cw.queue_free(); cd.queue_free()
	for scr in ["FURN", "WELL", "DRAWER"]:
		var sc := _screen(scr)
		var cont := SubViewportContainer.new()
		# ОДИН вьюпорт на три екрани: контейнер лише в активному (інакше Godot
		# лається на подвійне батьківство) — перемикає _sync_case2_view()
		sc.set_meta("wants_sv", true)
		var catcher := Control.new(); catcher.name = "catch3d"
		catcher.size = Vector2(W, H); catcher.mouse_filter = Control.MOUSE_FILTER_STOP
		catcher.mouse_default_cursor_shape = Control.CURSOR_ARROW
		catcher.gui_input.connect(_case2_input)
		sc.add_child(catcher)
		screen_cams[scr] = sec_cam_live
	sec_vp = sv
	for scr3 in ["FURN", "WELL", "DRAWER"]:
		_build_tool_tray(scr3)
	# ВСТУП: хто прийшов, чого хоче, з чого почати. Без цього гравець стоїть
	# перед шафою з шістьма інструментами і нулем контексту (Віктор, 27.07).
	var i1 := Label.new(); i1.name = "c2_intro"
	i1.label_settings = _ls(fr, int(H*0.028), Color(0.92,0.88,0.78))
	i1.label_settings.shadow_color = Color(0,0,0,0.85); i1.label_settings.shadow_offset = Vector2(1.5,1.5)
	i1.text = _t("Frau Vogl, housekeeper twenty-two years to the late Herr F.\nThe secretaire is hers by his will, and she means to sell it.\n«My son sails on Thursday. I am not asking a good price — I am asking a quick one.»")
	i1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	i1.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	i1.size = Vector2(W*0.72, H*0.15); i1.position = Vector2(W*0.14, H*0.055)
	i1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screens["FURN"].add_child(i1)
	c2_intro1 = i1
	var i2 := Label.new()
	i2.label_settings = _ls(fh, int(H*0.026), Color(0.85,0.72,0.48))
	i2.label_settings.shadow_color = Color(0,0,0,0.85); i2.label_settings.shadow_offset = Vector2(1.5,1.5)
	i2.text = _t("Value the piece before it sells. Begin as the trade begins — rap the long drawer, and listen.")
	i2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	i2.size = Vector2(W, H*0.05); i2.position = Vector2(0, H*0.205)
	i2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screens["FURN"].add_child(i2)
	c2_intro2 = i2
	var itw2 := create_tween(); itw2.tween_interval(14.0)
	itw2.tween_property(i1, "modulate:a", 0.0, 2.0)
	itw2.parallel().tween_property(i2, "modulate:a", 0.0, 2.0)
	# навігація: план → деталь і назад (режисура: без стрибків повз середній план)
	# ряд інструментів — на всіх трьох планах предмета; ОДИН вузол tool_row
	# переїжджає між екранами при _sync_case2_view (як контейнер вьюпорта)
	_txtbtn(screens["FURN"], "the writing well  →", Vector2(W*0.40, H*0.92), func(): _show("WELL"))
	_txtbtn(screens["FURN"], "take the drawer out  →", Vector2(W*0.64, H*0.92), func():
		# шухляда вже висунута (стан out) — кнопка ВЕДЕ до неї, а не мовчить
		# (плейтест 27.07: після «slide it back» правило вже віддане, і клік
		# повторював текст стуку — агент 6 команд вважав навігацію мертвою)
		if zone_states.get(&"z.sec.drawer_front", &"default") == &"out": _show("DRAWER")
		else: _apply_zone("z.sec.drawer_front", &"tool.hand"))
	_txtbtn(screens["FURN"], "the papers  →", Vector2(W*0.05, H*0.92), func(): _show("C2DOCS"))
	_txtbtn(screens["FURN"], "Write the certificate  →", Vector2(W*0.05, H*0.862), func(): _show("CERT"))
	_txtbtn(screens["WELL"], "←  step back", Vector2(W*0.04, H*0.92), func(): _show("FURN"))
	_txtbtn(screens["WELL"], "✎", Vector2(W*0.945, H*0.055), func(): _show_notebook(), 0.030)

	var sb_btn := _txtbtn(screens["DRAWER"], "←  slide it back", Vector2(W*0.04, H*0.92), func(): _show("FURN"))
	sb_btn.add_theme_color_override("font_outline_color", Color(0.05,0.04,0.03,0.9))
	sb_btn.add_theme_constant_override("outline_size", 8)
	var to_btn := _txtbtn(screens["DRAWER"], "⟲  turn it over", Vector2(W*0.42, H*0.92), func():
		# перевернути шухляду: спід (тавро столярні) — догори
		var tw2 := create_tween()
		var target: float = 0.0 if absf(sec_drawer.rotation.x) > 1.5 else PI
		tw2.tween_property(sec_drawer, "rotation:x", target, 0.55).set_trans(Tween.TRANS_QUAD)
		_play("goblet_set"))
	to_btn.add_theme_color_override("font_outline_color", Color(0.05,0.04,0.03,0.9))
	to_btn.add_theme_constant_override("outline_size", 8)
	# папери справи 2 (гросбух + реєстр на одному аркуші) і довідник шурупів
	var d2 := _screen("C2DOCS")
	_paper_backdrop(d2)
	var lt: Texture2D = tex["letter_client"]
	var lh := H*0.84; var lw := lh*float(lt.get_width())/float(lt.get_height())
	var paper := TextureRect.new(); paper.texture = lt; paper.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	paper.stretch_mode = TextureRect.STRETCH_SCALE; paper.size = Vector2(lw, lh)
	paper.position = Vector2((W-lw)*0.5, (H-lh)*0.5 - H*0.02); paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	d2.add_child(paper)
	var t2 := Label.new(); t2.label_settings = _ls(fr, int(lh*0.026), Color(0.20,0.14,0.09))
	t2.text = _t("THE CLIENT — Frau Anna Vogl\n«He willed it to me. My son sails on Thursday;\nthe ticket is forty-one gulden and I have nineteen.\nI am not asking a good price — a quick one.»\n\nDAY-BOOK — the 3rd\nSecretaire, walnut, estate of Herr F.\nOpened on arrival by Krenn, our locksmith\n— lock seized. House keys surrendered with the piece.\n\nREGISTER OF WORKSHOPS (Möbeltischler, Wien)\nDANHAUSER, Josef — Wien — stamp 1804–1838\nGRUBER, Michael — Wien-Gumpendorf — stamp 1822–1841\nSCHMIDT & SOHN — Leopoldstadt — stamp 1835–1867\nHALBERT, J. — Wien I — dealer, no stamp, from 1861")
	t2.position = paper.position + Vector2(lw*0.12, lh*0.10); t2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	d2.add_child(t2)
	_paper_catcher("C2DOCS", d2, paper)
	_txtbtn(d2, "←  back", Vector2(W*0.04, H*0.92), func(): _show("FURN"))
	_txtbtn(d2, "the chapter on screws  →", Vector2(W*0.60, H*0.92), func(): _show("BOOK_SCREWS"))
	_txtbtn(d2, "the timber page  →", Vector2(W*0.38, H*0.92), func(): _show("BOOK_WOOD"))
	# записка попередника (case_02.md §11, двері 2): смужка його почерком, без пояснень
	var slip := Label.new(); slip.label_settings = _ls(fh, int(lh*0.030), Color(0.30,0.22,0.30))
	slip.text = _t("A joiner is paid for wood, and hides air.")
	slip.rotation = -0.02
	slip.position = paper.position + Vector2(lw*0.14, lh*0.88)
	slip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	d2.add_child(slip)
	var bw := _paper_screen("BOOK_WOOD", "wood_page", "C2DOCS", "←  back to the papers")
	_ptext(bw, "OF TIMBER, BY THE END GRAIN", 0.28, 0.030, 0.020)
	_ptext(bw, "SPRUCE — the carcass wood", 0.635, 0.115, 0.017)
	_ptext(bw, "abrupt rings, resin channels;", 0.635, 0.155, 0.014)
	_ptext(bw, "no rays across the grain.", 0.635, 0.185, 0.014)
	_ptext(bw, "Coarse, resinous. The stock", 0.635, 0.215, 0.014)
	_ptext(bw, "of every Vienna carcass.", 0.635, 0.245, 0.014)
	_ptext(bw, "BEECH", 0.635, 0.585, 0.017)
	_ptext(bw, "fine even pores, crossed by", 0.635, 0.625, 0.014)
	_ptext(bw, "broad bright rays — the", 0.635, 0.655, 0.014)
	_ptext(bw, "joiner\u2019s \u00abfleck\u00bb. Close, pale.", 0.635, 0.685, 0.014)
	_ptext(bw, "Cheap, strong; a wood for", 0.635, 0.715, 0.014)
	_ptext(bw, "work that is not meant to show.", 0.635, 0.745, 0.014)
	# аудит 27.07: проза на бухгалтерській сітці = «перекреслений текст»; сторінка
	# довідника — ЧИСТИЙ аркуш (plain_book_page), верстка вільна
	var bs := _paper_screen("BOOK_SCREWS", "plain_book_page", "C2DOCS", "←  back to the papers")
	_ptext(bs, "OF SCREWS AND THEIR MAKING", 0.24, 0.085, 0.022)
	_ptext(bs, "Before 1846: blunt end, hand-filed thread,", 0.16, 0.20, 0.021)
	_ptext(bs, "uneven pitch, the slot off centre;", 0.16, 0.245, 0.021)
	_ptext(bs, "a hole must first be bored.", 0.16, 0.29, 0.021)
	_ptext(bs, "Patented 1846: the pointed screw", 0.16, 0.40, 0.021)
	_ptext(bs, "that cuts its own way; made in quantity", 0.16, 0.445, 0.021)
	_ptext(bs, "at Birmingham from 1854.", 0.16, 0.49, 0.021)
	_ptext(bs, "Old blunt stock lived on for decades:", 0.16, 0.60, 0.019, Color(0.38,0.30,0.22))
	_ptext(bs, "a pointed screw says \u00abnot before\u00bb \u2014 never \u00abthen\u00bb.", 0.16, 0.64, 0.019, Color(0.38,0.30,0.22))
	_paper_catcher("BOOK_SCREWS", bs["s"], bs["pg"])

var sec_vp: SubViewport
var tray_marks := {}     # screen → {tool: ColorRect} підсвітки взятого предмета
var sec_cams := {}
var sec_backboard: Node3D
var sec_drawer: Node3D
var sec_body_closed: Node3D
var sec_body_open: Node3D

# вигляд сцени секретера ВИВОДИТЬСЯ зі стану (закон кроку 2)
# Лоток бюро: ОДНА мальована таця з чотирма предметами; хотспоти по місцях
# (як лупа, запечена в стіл справи 1). Взятий предмет — тепла підсвітка,
# як активний рядок атестата. Рука й око — це сам гравець, їх у лотку нема.
const TRAY_SPOTS := [
	[&"tool.caliper",     0.055, 0.290, "the caliper"],
	[&"tool.screwdriver", 0.320, 0.480, "the screwdriver"],
	[&"tool.loupe",       0.495, 0.705, "the loupe"],
	[&"tool.rake",        0.715, 0.960, "the inspection lamp"],
]

func _build_tool_tray(scr: String) -> void:
	var host: Control = screens[scr]
	var t: Texture2D = tex["tool_tray"]
	var th := H*0.205
	var twd := th*float(t.get_width())/float(t.get_height())
	var tray := TextureRect.new(); tray.texture = t
	tray.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; tray.stretch_mode = TextureRect.STRETCH_SCALE
	tray.size = Vector2(twd, th); tray.position = Vector2(W - twd - W*0.015, H - th - H*0.015)
	tray.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(tray)
	tray_marks[scr] = {}
	for spot in TRAY_SPOTS:
		var tl: StringName = spot[0]
		# у таці лише те, що справа справді дає (каліпер у справі 2 не потрібен)
		if not unlocked_tools.has(tl) and case_id == 2: continue
		var x0 := tray.position.x + twd*float(spot[1])
		var x1 := tray.position.x + twd*float(spot[2])
		var hl := ColorRect.new(); hl.color = Color(0.99, 0.78, 0.42, 0.16)
		hl.size = Vector2(x1 - x0, th*0.86); hl.position = Vector2(x0, tray.position.y + th*0.07)
		hl.mouse_filter = Control.MOUSE_FILTER_IGNORE; hl.visible = false
		host.add_child(hl)
		(tray_marks[scr] as Dictionary)[tl] = hl
		var b := Button.new(); b.flat = true; b.modulate.a = 0
		b.position = Vector2(x0, tray.position.y); b.size = Vector2(x1 - x0, th)
		b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		b.mouse_entered.connect(_set_hint.bind(String(spot[3])))
		b.mouse_exited.connect(_set_hint.bind(""))
		b.pressed.connect(_pick_tool.bind(tl))
		host.add_child(b)

func _refresh_tray_marks() -> void:
	for scr in tray_marks:
		for tl in (tray_marks[scr] as Dictionary):
			((tray_marks[scr] as Dictionary)[tl] as ColorRect).visible = (active_tool == tl)

# МОМЕНТ ВІДКРИТТЯ (правило 14): дошка знята — камера повільно входить у зазор,
# тримає подих на чистому прямокутнику в пилюці, відступає. Без жодного тексту.
# ВИКРУТКА ПРАЦЮЄ НА ОЧАХ (Віктор 29.07: «що відкручується — має реально
# працювати»): дошка здригається на кожному шурупі, тоді відходить уперед,
# опускається і зникає — і аж тоді камера входить у відкриту нішу.
# ШУХЛЯДА ВИЇЖДЖАЄ ЗІ СВОГО ГНІЗДА (правило 18) — видимий рух, не телепорт
func _slide_drawer_out() -> void:
	if sec_drawer == null: return
	sec_drawer.visible = true
	var p0: Vector3 = sec_drawer.position
	sec_drawer.position = p0 - Vector3(0, 0, 0.42)
	var tw := create_tween()
	tw.tween_property(sec_drawer, "position", p0, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func(): _play("goblet_set"))

func _unscrew_board() -> void:
	if sec_backboard == null:
		_reveal_recess(); return
	var b := sec_backboard
	var p0: Vector3 = b.position
	var tw := create_tween()
	for i in 4:                      # чотири шурупи — чотири здригання
		tw.tween_property(b, "position", p0 + Vector3(0.004, 0, 0.004), 0.07)
		tw.tween_property(b, "position", p0, 0.07)
		tw.tween_callback(func(): _play("ui_soft"))
	tw.tween_property(b, "position", p0 + Vector3(0, 0, 0.075), 0.35).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(b, "position", p0 + Vector3(0, -0.22, 0.10), 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(b, "rotation:x", -0.35, 0.45)
	tw.tween_callback(func():
		_play("goblet_set")
		b.visible = false
		b.position = p0; b.rotation.x = 0.0
		_sync_case2_view()
		_reveal_recess())

func _reveal_recess() -> void:
	if sec_cam_live == null: return
	var cw2: Camera3D = sec_cam_live
	var p0: Vector3 = cw2.position
	var fwd: Vector3 = -cw2.global_transform.basis.z
	if sec_cam_tw and sec_cam_tw.is_valid(): sec_cam_tw.kill()   # дольчик не бореться з наїздом
	var tw3 := create_tween(); sec_cam_tw = tw3
	tw3.tween_property(cw2, "position", p0 + fwd*0.34, 1.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tw3.tween_interval(1.3)
	tw3.tween_property(cw2, "position", p0, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

# СКЛО НА СЕКРЕТЕРІ (Віктор 28.07: «слайд шоу замість дослідження лупою») —
# та сама чесна оптика, що в справі 1: телеоб'єктив у ЖИВИЙ світ секретера.
func _c2_loupe_set(on: bool) -> void:
	if loupe_vp == null or loupe_ui == null: return
	c2_loupe = on
	if on:
		if sec_world: loupe_vp.world_3d = sec_world
		loupe_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		if loupe_vp_tex.texture == null: loupe_vp_tex.texture = loupe_vp.get_texture()
		loupe_glass.visible = false; loupe_vp_tex.visible = true
		loupe_ui.visible = true
		move_child(loupe_ui, get_child_count()-1)
		if hint_band: move_child(hint_band, get_child_count()-1)
		if hint_label: move_child(hint_label, get_child_count()-1)
		var mp := get_viewport().get_mouse_position()
		loupe_ui.position = mp - Vector2(GLASS_CX*loupe_lw, GLASS_CY*loupe_lh)
		_aim_loupe(mp)
	else:
		if goblet_world: loupe_vp.world_3d = goblet_world
		loupe_vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
		if not loupe_held: loupe_ui.visible = false

func _sync_case2_view() -> void:
	if sec_vp == null: return
	var scr := _shown()
	var on_c2: bool = scr in ["FURN", "WELL", "DRAWER"]
	# дольчик між кадрами замість різу (правило 14/18: одна жива річ, не 3 сцени)
	if on_c2 and sec_cam_live and sec_cam_targets.has(scr):
		sec_cam_live.current = true
		var tgt: Transform3D = sec_cam_targets[scr]
		if sec_cam_tw and sec_cam_tw.is_valid(): sec_cam_tw.kill()
		# перший показ — без анімації (щоб не летіти з нуля); далі — плавно
		if sec_cam_live.transform.origin.distance_to(tgt.origin) < 0.001 or not _c2_seen:
			sec_cam_live.transform = tgt
		else:
			var tw := create_tween(); sec_cam_tw = tw
			tw.tween_method(func(t: float):
				sec_cam_live.transform = sec_cam_live.transform.interpolate_with(tgt, t),
				0.0, 1.0, 0.65).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		_c2_seen = true
	# контейнер вьюпорта — лише на активному екрані
	for s2 in ["FURN", "WELL", "DRAWER"]:
		if not screens.has(s2): continue
		var host: Control = screens[s2]
		var have := host.get_node_or_null("svc")
		if s2 == scr and have == null:
			var cont := SubViewportContainer.new(); cont.name = "svc"
			cont.stretch = true; cont.size = Vector2(W, H)
			cont.mouse_filter = Control.MOUSE_FILTER_IGNORE
			if sec_vp.get_parent(): sec_vp.get_parent().remove_child(sec_vp)
			cont.add_child(sec_vp)
			host.add_child(cont); host.move_child(cont, 0)
		elif s2 != scr and have != null:
			(have as SubViewportContainer).remove_child(sec_vp)
			add_child(sec_vp)
			have.queue_free()
	# два стани корпуса: WELL бачить відкинуту дошку з нутром
	var in_well: bool = scr == "WELL"
	if sec_body_closed: sec_body_closed.visible = on_c2 and not in_well
	if sec_body_open: sec_body_open.visible = in_well
	# знімна дощечка живе в нутрі open-стану; відкручена — зникає, ніша відкрита
	var board_open: bool = zone_states.get(&"z.well.back_board", &"default") == &"open"
	if sec_backboard:
		sec_backboard.visible = in_well and not board_open
	if dust_quad:
		dust_quad.visible = in_well          # нутро видно завжди, дошка його затуляє

	if sec_drawer:
		# шухляда «в руках» існує лише на своєму плані; на FURN вона левітувала
		# поверх зачиненого корпусу (плейтест 27.07)
		sec_drawer.visible = scr == "DRAWER" and zone_states.get(&"z.sec.drawer_front", &"default") == &"out"

func _case2_input(ev: InputEvent) -> void:
	# РУКА Й ОКО — НЕ ІНСТРУМЕНТИ. Клік = торкнутись/роздивитись; ПЕРЕТЯГУВАННЯ =
	# ОБЕРНУТИ ЦІЛУ РІЧ (turntable, як чашу в руках — правило 18). Дію віддано на
	# ВІДПУСК і лише якщо це був клік, а не оберт (інакше клік по зоні на початку
	# перетягування спрацьовував би раптово).
	if ev is InputEventMouseButton and (ev as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		var mb := ev as InputEventMouseButton
		if mb.pressed:
			c2_press_pos = mb.position; c2_drag_travel = 0.0; c2_dragging = false; c2_mouse_down = true
		else:
			c2_mouse_down = false
			if c2_drag_travel < 12.0:
				_case2_click(c2_press_pos)   # це був клік
			c2_dragging = false
		return
	elif ev is InputEventMouseMotion:
		var mm := ev as InputEventMouseMotion
		var held := c2_mouse_down   # власний прапорець: пілот не шле button_mask
		if held:
			c2_drag_travel += mm.relative.length()
			if c2_drag_travel >= 12.0 and sec_pivot:
				c2_dragging = true
				sec_yaw -= mm.relative.x * 0.004
				sec_yaw = clampf(sec_yaw, -0.62, 0.62)   # ±35°: видно передні кути, не втрачаєш фасад
				sec_pivot.rotation.y = sec_yaw
				if c2_loupe:                          # скло їде за курсором і в оберті
					loupe_ui.position = mm.position - Vector2(GLASS_CX*loupe_lw, GLASS_CY*loupe_lh)
					_aim_loupe(mm.position)
			return
		if c2_loupe:
			loupe_ui.position = mm.position - Vector2(GLASS_CX*loupe_lw, GLASS_CY*loupe_lh)
			_aim_loupe(mm.position)
		var zid2 := _pick_3d_at(mm.position, &"tool.eye")
		if zid2 == "":
			zid2 = _pick_3d_at(mm.position, &"tool.hand")
		var z: Dictionary = _case_zones().get(StringName(zid2), {})
		_set_hint(String(z.get("hint", "")) if zid2 != "" else "")
		var sc2: Node = screens[_shown()].get_node_or_null("catch3d")
		if sc2: (sc2 as Control).mouse_default_cursor_shape = \
			Control.CURSOR_POINTING_HAND if zid2 != "" else Control.CURSOR_ARROW

# клік по 3D-предмету (винесено з _case2_input: спрацьовує на відпуск-без-оберту)
func _case2_click(pos: Vector2) -> void:
	if active_tool != &"*":
		var zt := _pick_3d_at(pos, active_tool)
		if zt != "": _apply_zone(zt, active_tool); return
		var zn := _pick_3d_at(pos, &"tool.hand")
		if zn == "": zn = _pick_3d_at(pos, &"tool.eye")
		if zn != "":
			_set_hint("Not the tool for this — set it down, or try it elsewhere.")
			return
	var zid := _pick_3d_at(pos, &"tool.hand")
	if zid != "": _apply_zone(zid, &"tool.hand"); return
	zid = _pick_3d_at(pos, &"tool.eye")
	if zid != "": _apply_zone(zid, &"tool.eye")


func _unhandled_input(event: InputEvent) -> void:
	# нотатник під рукою всюди: N відкриває, N/Esc з нотатника — назад
	if event is InputEventKey and (event as InputEventKey).pressed \
			and (event as InputEventKey).keycode == KEY_N and not dbg_mode:
		if _shown() == "NOTEBOOK": _show(notebook_prev)
		else: _show_notebook()
		return
	# у HANDS: тягнеш — ОБЕРТАЄШ чашу (можна перевернути й глянути спід). Лупа кладеться кнопкою.
	if not (screens.has("HANDS") and screens["HANDS"].visible and goblet_pivot): return
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		var mb := event as InputEventMouseButton
		if mb.pressed:
			cup_dragging = true; drag_travel = 0.0
			drag_press_pos = mb.position
			drag_press_basis = goblet_pivot.basis
		else:
			cup_dragging = false
			# «ПРОВЕСТИ ПАЛЬЦЕМ» = КОРОТКЕ ПРОВЕДЕННЯ, не лише клік (плейтест 26.07:
			# казуал 12 разів «проводив пальцем по стопі», бо так каже підказка, — і
			# гра щоразу КРУТИЛА чашу; до печатки він так і не дійшов). Тепер жест
			# до 70 px, що ПОЧАВСЯ над hand-зоною, — це дія пальця; випадковий
			# мікро-оберт від проведення відкочується до положення на момент
			# натискання. Довгий рух — як і був, оберт. Працює і з лупою в руці.
			if drag_travel < 70.0:
				if drag_travel >= 8.0 and _pick_3d_at(drag_press_pos, &"tool.hand") != "":
					goblet_pivot.basis = drag_press_basis
				_click_zone_3d(drag_press_pos)
			elif _pick_3d_at(drag_press_pos, &"tool.hand") != "":
				# почав на зоні, але потягнув — це оберт; палець — це ДОТИК
				_set_hint("Just press the finger there — no need to rub.")
	elif event is InputEventMouseMotion and not cup_dragging and not loupe_held:
		# діегетична підказка жесту: наведення на hand-зону чаші називає дію
		# (Віктор і плейтестер незалежно не зрозуміли «run a finger» без неї)
		var hz := _pick_3d_at((event as InputEventMouseMotion).position, &"tool.hand")
		if hz != "":
			var hzz: Dictionary = _case_zones().get(StringName(hz), {})
			if hzz.has("hint"): _set_hint(String(hzz["hint"]))
	elif event is InputEventMouseMotion and cup_dragging:
		var mm := event as InputEventMouseMotion
		# БУЛО: rotation.y — оберт навколо СВІТОВОЇ вертикалі. Коли чашу перевернуто
		# спідом до камери, ця вісь дивиться в об'єктив, і перетягування вбік уже не
		# крутить клейма в площині екрана, а хитає чашу. Через це гравець фізично не
		# міг поставити клейма рівно (скарга Віктора, 26.07).
		# СТАЛО: горизонталь крутить навколо ВЛАСНОЇ осі предмета (як чашку в руці),
		# вертикаль нахиляє навколо горизонталі ЕКРАНА. Це звичний «turntable».
		drag_travel += mm.relative.length()
		goblet_pivot.rotate_object_local(Vector3.UP, -mm.relative.x * 0.012)
		goblet_pivot.rotate(Vector3.RIGHT, -mm.relative.y * 0.012)

func _evening() -> void:
	case_done = true
	tod = "evening"
	_enter_hub()
	_hub_say("Evening. Across the street someone has been standing a while. The ledger lies open on your desk.")

func _build_ledger() -> void:
	var s := _screen("LEDGER")
	_paper_backdrop(s, 0.13)
	var head := Label.new(); head.label_settings = _ls(fb, int(H*0.032), Color(0.74,0.62,0.42))
	head.text = _t("The day's ledger"); head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
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
	b.text = _t("Case the first — a silver goblet, brought in by a woman who would not meet your eye.\n\nThe attribution is written, the wax is set. It cannot be lifted.\n\nThe bureau's door will open again tomorrow.")
	var sc: Label = screens["LEDGER"].get_node("sealcount")
	sc.text = _t("Seals set this week:  %d") % seals_set
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
	lab.text = _t("CASE CLOSED"); lab.rotation = deg_to_rad(-9); lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; lab.size = Vector2(cert_layer.size.x*0.6, cert_layer.size.y*0.08)
	lab.position = Vector2(cert_layer.size.x*0.2, cert_layer.size.y*0.71); lab.pivot_offset = lab.size*0.5; lab.scale = Vector2(0.4,0.4)
	cert_layer.add_child(lab)
	var t := create_tween()
	t.tween_property(lab, "scale", Vector2(1.05,1.05), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(lab, "scale", Vector2(1.0,1.0), 0.08)

# ---------- 3D ----------
# СВІТЛО Й НЕБО БЮРО — окремо від предмета. 27.07: _build_goblet_world будував
# І світло, І ЧАШУ; виклик його для сцени секретера виростив келих-гігант у шафі
# (Віктор: «що це за жах»). Тепер світло — своя функція; предмет — своя.
func _build_bureau_light(sv: SubViewport, take_key := false, room_color := Color(0,0,0,0)) -> DirectionalLight3D:
	var we := WorldEnvironment.new(); var env := Environment.new()
	var sky := Sky.new(); var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color(0.17,0.16,0.17); sm.sky_horizon_color = Color(0.21,0.18,0.15)
	sm.ground_bottom_color = Color(0.03,0.03,0.04); sm.ground_horizon_color = Color(0.10,0.08,0.06)
	sm.sky_energy_multiplier = 1.5; sky.sky_material = sm
	env.background_mode = Environment.BG_SKY; env.sky = sky
	if room_color.a > 0.0:
		env.background_mode = Environment.BG_COLOR
		env.background_color = room_color
	var furniture: bool = room_color.a > 0.0   # меблі: те саме тепле світло + ТІНІ
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY; env.ambient_light_energy = 1.9 if room_color.a > 0.0 else 1.35
	env.tonemap_mode = Environment.TONE_MAPPER_ACES if room_color.a > 0.0 else Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 1.0 if room_color.a > 0.0 else 0.95
	if furniture:
		# контактне затінення — предмет сідає в простір, ніші отримують глибину
		env.ssao_enabled = true; env.ssao_radius = 0.30; env.ssao_intensity = 0.55; env.ssao_power = 1.3
	we.environment = env; sv.add_child(we)
	if furniture:
		# ТІ САМІ теплі лампи, що працювали, але ключ КИДАЄ МʼЯКУ ТІНЬ
		var key2 := DirectionalLight3D.new(); key2.light_color = Color(1.0,0.94,0.86); key2.light_energy = 1.25
		key2.rotation_degrees = Vector3(-22,-40,0)
		key2.shadow_enabled = true; key2.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
		key2.shadow_blur = 2.0; key2.shadow_bias = 0.06
		sv.add_child(key2); if take_key: key_light = key2
		var rim2 := DirectionalLight3D.new(); rim2.light_color = Color(0.72,0.76,0.88); rim2.light_energy = 0.8
		rim2.rotation_degrees = Vector3(-12,-135,0); sv.add_child(rim2)
		var fl2 := DirectionalLight3D.new(); fl2.light_color = Color(0.98,0.93,0.86); fl2.light_energy = 0.55
		fl2.rotation_degrees = Vector3(-6,10,0); sv.add_child(fl2)
		return key2
	# тепла лампа — світить НИЗЬКО і КОСО через ногу (щоб клеймо блисло при оберті)
	var key := DirectionalLight3D.new(); key.light_color = Color(1.0,0.92,0.82); key.light_energy = 1.9
	key.rotation_degrees = Vector3(-9,-62,0); sv.add_child(key)
	if take_key: key_light = key
	var rim := DirectionalLight3D.new(); rim.light_color = Color(0.72,0.76,0.88); rim.light_energy = 0.8
	rim.rotation_degrees = Vector3(-12,-135,0); sv.add_child(rim)
	var fl := DirectionalLight3D.new(); fl.light_color = Color(1.0,0.93,0.82); fl.light_energy = 1.5
	fl.rotation_degrees = Vector3(-5,8,0); sv.add_child(fl)
	return key

func _build_goblet_world(sv: SubViewport) -> void:
	_build_bureau_light(sv, true)
	var cam := Camera3D.new(); sv.add_child(cam); main_cam3 = cam
	goblet_pivot = Node3D.new(); sv.add_child(goblet_pivot)
	mesh_nodes[&"goblet_pivot"] = goblet_pivot
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
			# МІНУС перед sin(a) — НЕ описка. Спід дивиться в −Y, тобто гравець бачить
			# пластину з ЗВОРОТНОГО боку, і без дзеркалення вся текстура лягала
			# перевернутою: голова Діани опинялась НАД щитом замість під ним, а самі
			# клейма стояли боком. Скарга Віктора 26.07: «всі мітки вверх ногами».
			uvs.append(Vector2(0.5 + 0.5 * PLATE_UV * (rr / rad) * cos(a), 0.5 - 0.5 * PLATE_UV * (rr / rad) * sin(a)))
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
	# ТРЕТЄ місце, де вантажилась пластина. Дві правки з трьох дали б розбіжність:
	# початковий матеріал зі старим клеймом, а _sync_view — з новим.
	um.albedo_texture = load("res://art/foot_plate_maker_v2.png")
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
