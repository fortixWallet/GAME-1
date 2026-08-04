# Ортогональні види зверху wa_body і wa_lid ОДНИМ масштабом (ortho size 2.4):
# з кадрів міряються справжні діаметри кола корпусу/кришки і точка завіси.
# Правило 17: друкує AABB і центр кожного. Знімки: /tmp/wa_asm/measure_*.png
extends SceneTree

func _init() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1000, 1000))
	var dir := "/tmp/wa_asm/"
	DirAccess.make_dir_recursive_absolute(dir)
	await process_frame
	var world := Node3D.new(); root.add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-90, 0, 0); sun.light_energy = 2.0
	world.add_child(sun)
	var env := WorldEnvironment.new(); var e := Environment.new()
	e.background_mode = Environment.BG_COLOR; e.background_color = Color(0.05, 0.3, 0.05)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.8, 0.8, 0.8); e.ambient_light_energy = 1.2
	env.environment = e; world.add_child(env)
	for nm in ["wa_body", "wa_lid"]:
		var inst: Node3D = (load("res://models/" + nm + ".glb") as PackedScene).instantiate()
		world.add_child(inst)
		await process_frame
		var boxes: Array[AABB] = []; _collect(inst, boxes)
		var ab: AABB = boxes[0]
		for b in boxes: ab = ab.merge(b)
		print("WA_MEAS ", nm, " aabb=", ab.size, " center=", ab.get_center())
		var cam := Camera3D.new()
		cam.projection = Camera3D.PROJECTION_ORTHOGONAL
		cam.size = 2.4
		cam.position = ab.get_center() + Vector3(0, 3, 0)
		world.add_child(cam)
		cam.look_at(ab.get_center(), Vector3(0, 0, -1))
		cam.current = true
		for _i in 6: await RenderingServer.frame_post_draw
		get_root().get_texture().get_image().save_png(dir + "measure_" + nm + ".png")
		cam.queue_free(); inst.queue_free()
		await process_frame
	print("WA_MEAS_OK ortho=2.4 px_per_unit=", 1000.0 / 2.4)
	quit()

func _collect(n: Node, out: Array[AABB]) -> void:
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		out.append(mi.global_transform * mi.get_aabb())
	for ch in n.get_children(): _collect(ch, out)
