# core/rules.gd — РУШІЙ ПРАВИЛ. Єдине місце, де «гравець торкнувся зони інструментом»
# перетворюється на «здобуто факт».
#
# До цього логіка жила гілками `if` у _check_underside: два факти, дві умови, одна
# перевірка косого світла — і все всередині функції про лупу. Додати третій факт
# означало дописати третю гілку. Тепер правила — це ДАНІ (data/case_01.gd), а тут
# лише їх добір.
#
# Закон: рушій НЕ вирішує, що факт означає. Він видає спостереження й мовчить.
class_name RuleEngine
extends RefCounted


# Чи виконані передумови правила.
#   requires   — факти, які вже мусять бути в нотатнику
#   forbids    — факти, після яких правило більше не діє
#   needs_flag — стан світу: косе світло, вечір, згасла лампа
static func applicable(rule: Dictionary, facts: Dictionary, flags: Dictionary) -> bool:
	for f in rule.get("requires", []):
		if not facts.has(String(f)): return false
	for f in rule.get("forbids", []):
		if facts.has(String(f)): return false
	var nf: Dictionary = rule.get("needs_flag", {})
	for k in nf:
		if flags.get(k, null) != nf[k]: return false
	return true


# Чи дасть правило щось НОВЕ. Правило, всі факти якого вже здобуті, не має
# перехоплювати чергу в наступного — інакше друге клеймо не знайдеться ніколи.
static func yields_new(rule: Dictionary, facts: Dictionary) -> bool:
	if bool(rule.get("repeat", false)): return true
	var fs: Array = rule.get("facts", [])
	if fs.is_empty(): return false          # say-only правила черги не займають
	for f in fs:
		if not facts.has(String(f)): return true
	return false


# Знайти правило для (зона × інструмент) у поточному стані.
# Порядок у таблиці має значення: перше придатне виграє. Тому в даних правило
# з довшою витримкою (dwell) стоїть ПІСЛЯ коротшого — коротке спрацює першим,
# і лише коли його факт уже здобутий, черга дійде до довгого.
static func find(rules: Array, zone: StringName, tool: StringName,
				 facts: Dictionary, flags: Dictionary) -> Dictionary:
	for r in rules:
		var rr: Dictionary = r
		if StringName(rr.get("zone", &"")) != zone: continue
		var rt := StringName(rr.get("tool", &"*"))
		if rt != &"*" and rt != tool: continue
		if not applicable(rr, facts, flags): continue
		if not yields_new(rr, facts): continue
		return rr
	return {}


# Витримка, якої вимагає правило (0 — діє одразу, по кліку).
static func dwell_of(rule: Dictionary) -> float:
	return float(rule.get("dwell", 0.0))


# Застосувати: повертає список НОВИХ фактів (дублі відсіює викликач через add_fact).
static func facts_of(rule: Dictionary) -> Array:
	return rule.get("facts", [])
