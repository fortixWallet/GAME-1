# Оглядач мешів: вантажить кожен GLB, ставить камеру по AABB, знімає два ракурси.
# Запуск: godot --path . --rendering-driver opengl3 --script res://tools/mesh_preview.gd
# Знімки: /tmp/mesh_prev/<name>_{a,b}.png. Друкує AABB і кількість поверхонь (правило 17).
extends SceneTree

const MODELS := ["wa_closed"]

func _init() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1280, 960))
	var dir := "/tmp/mesh_prev/"
	DirAccess.make_dir_recursive_absolute(dir)
	await process_frame

	var world := Node3D.new()
	root.add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42, -30, 0); sun.light_energy = 1.4
	world.add_child(sun)
	var fill := OmniLight3D.new()
	fill.position = Vector3(-2, 1.5, 3); fill.light_energy = 0.7; fill.omni_range = 30
	world.add_child(fill)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.13, 0.12, 0.11)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.6, 0.58, 0.55); e.ambient_light_energy = 0.5
	world.add_child(env); env.environment = e
	var cam := Camera3D.new(); world.add_child(cam); cam.current = true; cam.fov = 35

	var shots := 0
	for name in MODELS:
		var path := "res://models/%s.glb" % name
		if not ResourceLoader.exists(path):
			print("MESHPREV_MISSING ", name); continue
		var scn: PackedScene = load(path)
		var inst := scn.instantiate() as Node3D
		world.add_child(inst)
		await process_frame
		# AABB по всіх MeshInstance3D
		var aabb := AABB()
		var first := true
		var surfaces := 0
		for m in inst.find_children("*", "MeshInstance3D", true, false):
			var mi := m as MeshInstance3D
			if mi.mesh == null: continue
			surfaces += mi.mesh.get_surface_count()
			var b: AABB = mi.global_transform * mi.get_aabb()
			aabb = b if first else aabb.merge(b); first = false
		print("MESHPREV %s aabb=%s surfaces=%d" % [name, aabb.size, surfaces])
		var c: Vector3 = aabb.get_center()
		var r: float = aabb.size.length() * 1.15
		for pose in [{"dir": Vector3(0.8, 0.35, 1.0), "tag": "a"},
					 {"dir": Vector3(-0.9, 0.25, -0.8), "tag": "b"}]:
			cam.global_position = c + (pose["dir"] as Vector3).normalized() * r
			cam.look_at(c, Vector3.UP)
			for _i in 6: await RenderingServer.frame_post_draw
			var img := root.get_viewport().get_texture().get_image()
			img.save_png(dir + "%s_%s.png" % [name, pose["tag"]])
			shots += 1
		inst.queue_free()
		await process_frame
	print("MESHPREV_OK shots=", shots)
	quit()
