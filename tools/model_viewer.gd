# ОГЛЯДАЧ МОДЕЛЕЙ — живий, не знімки. Тягнеш мишею — крутиш; колесо — наближення;
# ← → — попередня/наступна модель; Esc — вихід.
# Запуск: godot --path . --rendering-driver opengl3 res://tools/model_viewer.tscn
# Правило 17: на екрані завжди видно, СКІЛЬКИ моделей знайдено і який габарит у мм.
extends Node3D

var models: Array = []
var idx := 0
var pivot: Node3D
var cam: Camera3D
var label: Label
var cur: Node3D
var yaw := 0.7
var pitch := 0.30
var dist := 2.6
var dragging := false


func _ready() -> void:
	DisplayServer.window_set_size(Vector2i(1400, 900))
	DisplayServer.window_set_position(Vector2i(120, 90))

	var d := DirAccess.open("res://models")
	if d:
		for f in d.get_files():
			if f.ends_with(".glb"): models.append(f.get_basename())
	models.sort()
	print("ОГЛЯДАЧ: знайдено ", models.size(), " моделей у res://models")
	if models.is_empty():
		get_tree().quit(); return

	var env := WorldEnvironment.new(); var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.11, 0.10, 0.095)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.62, 0.60, 0.56); e.ambient_light_energy = 0.55
	env.environment = e; add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-40, -35, 0); sun.light_energy = 1.5
	sun.shadow_enabled = true; add_child(sun)
	var fill := OmniLight3D.new()
	fill.position = Vector3(-2.5, 1.8, 3.0); fill.light_energy = 0.6; fill.omni_range = 40
	add_child(fill)

	pivot = Node3D.new(); add_child(pivot)
	cam = Camera3D.new(); cam.fov = 38; add_child(cam); cam.current = true

	var ui := CanvasLayer.new(); add_child(ui)
	label = Label.new()
	label.position = Vector2(24, 18)
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(0.94, 0.90, 0.80))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	label.add_theme_constant_override("outline_size", 6)
	ui.add_child(label)
	_load(0)


func _load(i: int) -> void:
	idx = wrapi(i, 0, models.size())
	if cur: cur.queue_free(); cur = null
	var scn: PackedScene = load("res://models/%s.glb" % models[idx])
	if scn == null:
		label.text = "не читається: " + String(models[idx]); return
	cur = scn.instantiate()
	pivot.add_child(cur)
	await get_tree().process_frame          # AABB рахується лише в дереві
	var aabb := _aabb(cur)
	var big: float = maxf(aabb.size.x, maxf(aabb.size.y, aabb.size.z))
	if big > 0.0:
		cur.scale = Vector3.ONE * (1.0 / big)
		cur.position = -aabb.get_center() / big
	var n := cur.find_children("*", "MeshInstance3D", true, false).size()
	label.text = "[%d/%d]  %s\nмешів: %d    габарит у файлі: %.0f × %.0f × %.0f мм\n← →  інша модель · тягни мишею — оберт · колесо — наближення · Esc — вихід" % [
		idx + 1, models.size(), models[idx], n,
		aabb.size.x * 1000.0, aabb.size.y * 1000.0, aabb.size.z * 1000.0]
	print("  %-26s мешів=%d  AABB(мм)= %.0f × %.0f × %.0f" % [
		models[idx], n, aabb.size.x * 1000.0, aabb.size.y * 1000.0, aabb.size.z * 1000.0])


func _aabb(n: Node) -> AABB:
	var out := AABB()
	var first := true
	for m in n.find_children("*", "MeshInstance3D", true, false):
		var mi := m as MeshInstance3D
		var a: AABB = mi.global_transform * mi.get_aabb()
		if first: out = a; first = false
		else: out = out.merge(a)
	return out


func _process(_dt: float) -> void:
	if pivot == null: return
	pivot.rotation = Vector3(0, yaw, 0)
	var p := clampf(pitch, -1.35, 1.35)
	cam.position = Vector3(0, sin(p) * dist, cos(p) * dist)
	cam.look_at(Vector3.ZERO, Vector3.UP)


func _unhandled_input(ev: InputEvent) -> void:
	if ev is InputEventKey and (ev as InputEventKey).pressed:
		match (ev as InputEventKey).keycode:
			KEY_ESCAPE: get_tree().quit()
			KEY_RIGHT: _load(idx + 1)
			KEY_LEFT: _load(idx - 1)
	elif ev is InputEventMouseButton:
		var mb := ev as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT: dragging = mb.pressed
		elif mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed: dist = maxf(0.8, dist - 0.15)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed: dist = minf(8.0, dist + 0.15)
	elif ev is InputEventMouseMotion and dragging:
		var mm := ev as InputEventMouseMotion
		yaw -= mm.relative.x * 0.008
		pitch = clampf(pitch + mm.relative.y * 0.006, -1.35, 1.35)
