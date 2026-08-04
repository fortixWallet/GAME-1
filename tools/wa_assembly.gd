# Замір правила 30-біс: ОДНА модель годинника, що ВІДКРИВАЄТЬСЯ.
# Корпус (wa_body) + кришка (wa_lid) — дві image-to-3D деталі одного предмета,
# кришка сідає на завіс і повертається. Друкує AABB обох (правило 17),
# знімає closed / half / open у /tmp/wa_asm/.
# Запуск: godot --path . --rendering-driver opengl3 --script res://tools/wa_assembly.gd
extends SceneTree

func _init() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1280, 960))
	var dir := "/tmp/wa_asm/"
	DirAccess.make_dir_recursive_absolute(dir)
	await process_frame

	var world := Node3D.new()
	root.add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-38, -25, 0); sun.light_energy = 3.0
	world.add_child(sun)
	var fill := OmniLight3D.new()
	fill.position = Vector3(-2.0, 1.5, 3.0); fill.light_energy = 1.1; fill.omni_range = 30
	world.add_child(fill)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.13, 0.12, 0.11)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.65, 0.62, 0.58); e.ambient_light_energy = 1.0
	env.environment = e
	world.add_child(env)

	var body: Node3D = (load("res://models/wa_body.glb") as PackedScene).instantiate()
	var lid: Node3D = (load("res://models/wa_lid.glb") as PackedScene).instantiate()
	world.add_child(body)
	# ЧИСЛА З ОРТОВИМІРУ (wa_measure, 04.08, px/unit=234.2):
	# корпус: коло Ø1.21 з центром (0, ~0, +0.35); відкрита спина дивиться +Y,
	# обід на y≈+0.176; завісне вушко на ободі при z=-0.255.
	# кришка: ОВАЛ 1.899×1.476 (Meshy запік перспективу) → нерівномірний масштаб
	# повертає коло; вушко при +X → доворот Y на 90° ставить його до завіси.
	const CASE_D := 1.21
	const CASE_CZ := 0.35
	const RIM_Y := 0.176
	var hinge := Node3D.new(); world.add_child(hinge)
	hinge.add_child(lid)
	lid.scale = Vector3(CASE_D / 1.899, 0.85, CASE_D / 1.476)
	lid.rotation_degrees = Vector3(180, 90, 0)
	hinge.position = Vector3(0, RIM_Y, CASE_CZ - CASE_D * 0.5 - 0.045)
	# центр кришки має накрити центр кола корпусу
	lid.position = Vector3(0, 0.10, CASE_D * 0.5 + 0.045)
	var cam := Camera3D.new()
	var c := Vector3(0, 0, CASE_CZ)
	var d := CASE_D
	cam.position = c + Vector3(d * 0.7, d * 1.0, d * 1.9)
	world.add_child(cam)
	cam.look_at(c)
	cam.current = true
	await process_frame

	for shot in [["closed", 0.0], ["half", 55.0], ["open", 105.0]]:
		hinge.rotation_degrees = Vector3(float(shot[1]), 0, 0)
		for _i in 6: await RenderingServer.frame_post_draw
		get_root().get_texture().get_image().save_png(dir + "wa_" + String(shot[0]) + ".png")
		print("WA_ASM shot ", shot[0], " lid_angle=", shot[1])
	print("WA_ASM_OK shots=3")
	quit()

func _aabb(n: Node3D) -> AABB:
	var boxes: Array[AABB] = []
	_collect(n, boxes)
	var r: AABB = boxes[0]
	for b in boxes: r = r.merge(b)
	return r

func _collect(n: Node, out: Array[AABB]) -> void:
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		out.append(mi.global_transform * mi.get_aabb())
	for ch in n.get_children(): _collect(ch, out)

func _disc(ab: AABB) -> Dictionary:
	var s := ab.size
	var axis := 0
	if s.y < s[axis]: axis = 1
	if s.z < s[axis]: axis = 2
	var diam: float = maxf(s.x, maxf(s.y, s.z))
	var normal := Vector3.ZERO; normal[axis] = 1.0
	return {"axis": axis, "diam": diam, "normal": normal}
