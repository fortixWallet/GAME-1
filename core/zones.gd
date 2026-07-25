# core/zones.gd — ПІКІНГ ЗОН. Єдине місце, де «куди тицьнув гравець» стає «яка це зона».
#
# Крок 3½ плану: сюди одразу закладено всі п'ять прогалин із ENGINE_SPEC_ADDENDUM §2,
# без яких п'ять справ неімплементовні:
#   2.1 needs_flag        — гейт по стану світу («настав вечір»), а не по факту
#   2.2 requires_state    — зона під кришкою недосяжна, поки кришка закрита (справа 3!)
#   2.3 instances         — сім оголошень у газеті як сім екземплярів однієї зони
#   2.4 (пошук у теці — віджет, живе не тут)
#   2.5 семантика dwell   — після видачі факту витримка скидається, зона стає `read`
#
# Клас нічого не малює і нічого не знає про справу. Він відповідає рівно на одне
# питання: яка зона під цією точкою екрана, і чи вона зараз узагалі досяжна.
class_name ZoneHit
extends RefCounted

# ── ФОРМАТ ЗОНИ (спільний для 2D і 3D) ───────────────────────────────────────
# Спільні поля:
#   "screen":  &"HANDS"            — на якому екрані зона живе
#   "tools":   [&"tool.loupe", …]  — які інструменти її беруть (порожньо = будь-який)
#   "requires_state": {&"z.watch.lid": &"open"}   — стан ІНШИХ зон (прогалина 2.2)
#   "needs_flag":     {&"tod": &"night"}          — стан світу (прогалина 2.1)
#   "instances": 7                 — скільки екземплярів (прогалина 2.3)
#
# 2D (kind = &"img") — координати у частках САМОГО ЗОБРАЖЕННЯ, не екрана:
#   "u": Vector2(0.50, 0.42)       — центр
#   "r": 0.09                      — радіус у частках ШИРИНИ зображення
#   "shape": &"rect", "half": Vector2(0.30, 0.21)   — або прямокутник
#
# 3D (kind = &"mesh"):
#   "at": Vector3, "facing": Vector3, "r": float, "facing_min": float

const EPS := 0.0001


# ── ДОСЯЖНІСТЬ ────────────────────────────────────────────────────────────────
# Зона може існувати й бути невидимою. Найдорожча помилка тут — мовчання:
# гравець тицяє в місце, де за даними зона є, і не отримує нічого.
static func reachable(z: Dictionary, zone_states: Dictionary, flags: Dictionary) -> bool:
	# 2.2 — стан інших зон. Без цього годинник у справі 3 фізично не відкривається:
	# зона всередині кришки існує, але поки кришка закрита, її якір недосяжний.
	var rs: Dictionary = z.get("requires_state", {})
	for other in rs:
		if zone_states.get(other, &"default") != rs[other]:
			return false
	# 2.1 — стан світу: вечір, згасла лампа, відчинений сейф
	var nf: Dictionary = z.get("needs_flag", {})
	for k in nf:
		if flags.get(k, null) != nf[k]:
			return false
	return true


# ── 2D: КАДР ЗОБРАЖЕННЯ ──────────────────────────────────────────────────────
# Повертає прямокутник, у який реально вписане зображення на екрані.
# COVER (кадр столу) і CONTAIN (аркуш) дають різні рамки, і зона, порахована
# в частках ЕКРАНА, поїде при іншому співвідношенні сторін. Тому — від рамки.
static func image_rect(tex_size: Vector2, screen: Vector2, cover: bool) -> Rect2:
	if tex_size.x <= EPS or tex_size.y <= EPS:
		return Rect2(Vector2.ZERO, screen)
	var s: float = (maxf(screen.x/tex_size.x, screen.y/tex_size.y) if cover
					else minf(screen.x/tex_size.x, screen.y/tex_size.y))
	var d := tex_size*s
	return Rect2((screen - d)*0.5, d)


# Точка екрана → частки зображення. Поза кадром — теж повертає, викликач вирішує.
static func to_image_uv(p: Vector2, frame: Rect2) -> Vector2:
	if frame.size.x <= EPS or frame.size.y <= EPS:
		return Vector2(-1, -1)
	return (p - frame.position)/frame.size


# Чи точка (у частках зображення) в зоні. Радіус — частка ШИРИНИ, тому по вертикалі
# його треба поділити на співвідношення сторін: інакше коло стає еліпсом.
static func inside_2d(uv: Vector2, z: Dictionary, aspect: float) -> bool:
	var c: Vector2 = z.get("u", Vector2(0.5, 0.5))
	if String(z.get("shape", &"circle")) == "rect":
		var h: Vector2 = z.get("half", Vector2(0.1, 0.1))
		return absf(uv.x - c.x) <= h.x and absf(uv.y - c.y) <= h.y
	var r: float = float(z.get("r", 0.05))
	var d := uv - c
	d.y /= maxf(aspect, EPS)          # ← корекція на аспект, інакше еліпс
	return d.length() <= r


# ── 3D: unproject + тест повернутості, БЕЗ колайдерів ───────────────────────
# Радіус ПРОЄКТУЄТЬСЯ на екран, тому зона сама росте, коли предмет наближають
# або дивляться крізь лупу. Це узагальнення наявного _check_underside.
static func inside_3d(p: Vector2, z: Dictionary, node: Node3D, cam: Camera3D) -> bool:
	if node == null or cam == null:
		return false
	var at: Vector3 = z.get("at", Vector3.ZERO)
	var wpos: Vector3 = node.global_transform * at
	if cam.is_position_behind(wpos):
		return false
	# повернутість: нормаль зони має дивитися в бік камери
	var fmin: float = float(z.get("facing_min", 0.0))
	if fmin > 0.0:
		var n: Vector3 = z.get("facing", Vector3.UP)
		var wn: Vector3 = (node.global_transform.basis * n).normalized()
		if wn.dot((cam.global_position - wpos).normalized()) <= fmin:
			return false
	# радіус: беремо точку на відстані r убік від центру і міряємо вже НА ЕКРАНІ
	var r: float = float(z.get("r", 0.1))
	var side: Vector3 = wpos + cam.global_transform.basis.x*r
	var c2: Vector2 = cam.unproject_position(wpos)
	var s2: Vector2 = cam.unproject_position(side)
	return p.distance_to(c2) <= c2.distance_to(s2)


# ── ВИБІР ЗОНИ ───────────────────────────────────────────────────────────────
# Повертає id зони під точкою або "" — і НІКОЛИ не повертає недосяжну зону.
# Якщо зон кілька, виграє найменша: дрібна деталь усередині великої площини
# мусить мати пріоритет, інакше до неї не дотягнутись ніколи.
static func pick_2d(p: Vector2, zones: Dictionary, screen_name: String,
					frame: Rect2, aspect: float,
					zone_states: Dictionary, flags: Dictionary) -> String:
	var uv := to_image_uv(p, frame)
	if uv.x < 0.0 or uv.y < 0.0 or uv.x > 1.0 or uv.y > 1.0:
		return ""
	var best := ""
	var best_area := INF
	for id in zones:
		var z: Dictionary = zones[id]
		if String(z.get("screen", &"")) != screen_name:
			continue
		if not reachable(z, zone_states, flags):
			continue
		if not inside_2d(uv, z, aspect):
			continue
		var area: float = (float(z.get("half", Vector2(0.1, 0.1)).x)*float(z.get("half", Vector2(0.1, 0.1)).y)
						   if String(z.get("shape", &"circle")) == "rect"
						   else float(z.get("r", 0.05))*float(z.get("r", 0.05)))
		if area < best_area:
			best_area = area; best = String(id)
	return best


# ── ЕКЗЕМПЛЯРИ (прогалина 2.3) ───────────────────────────────────────────────
# Сім оголошень у газеті — це не сім зон у таблиці, а одна зона з instances: 7.
# Розкладаються рядком по горизонталі від "u" з кроком "step".
static func expand_instances(id: String, z: Dictionary) -> Dictionary:
	var n: int = int(z.get("instances", 1))
	if n <= 1:
		return {id: z}
	var out := {}
	var step: Vector2 = z.get("step", Vector2(0.0, 0.0))
	var base: Vector2 = z.get("u", Vector2(0.5, 0.5))
	for i in n:
		var c := z.duplicate(true)
		c["u"] = base + step*float(i)
		c.erase("instances")
		c["instance"] = i + 1
		out["%s_%d" % [id, i + 1]] = c
	return out
