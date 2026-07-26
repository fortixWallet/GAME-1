extends SceneTree
func _init() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(980, 552))
	await process_frame
	var w := Node3D.new(); root.add_child(w)
	var sun := DirectionalLight3D.new(); sun.rotation_degrees = Vector3(-40,-30,0); w.add_child(sun)
	var inst := (load("res://models/secretaire_body.glb") as PackedScene).instantiate() as Node3D
	w.add_child(inst)
	var cam := Camera3D.new(); w.add_child(cam); cam.current = true; cam.fov = 32
	cam.position = Vector3(1.35, 0.75, 2.3); cam.look_at(Vector3(0, 0.55, 0), Vector3.UP)
	for _i in 8: await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png("/tmp/probe_body.png")
	print("PROBE_DONE")
	quit()
