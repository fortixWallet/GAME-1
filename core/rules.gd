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
	# requires_flag — прапорці СПРАВИ (простукав, відчинив сейф): живуть у тому
	# самому словнику flags, що й стан світу; окреме ім'я — щоб дані читались
	var rf: Dictionary = rule.get("requires_flag", {})
	for k2 in rf:
		if flags.get(k2, null) != rf[k2]: return false
	return true


# Чи дасть правило щось НОВЕ. Правило, все з якого вже здобуто/виконано, не має
# перехоплювати чергу в наступного — інакше друге клеймо не знайдеться ніколи.
static func yields_new(rule: Dictionary, facts: Dictionary,
					   flags: Dictionary = {}, zone_states: Dictionary = {}) -> bool:
	if bool(rule.get("repeat", false)): return true
	for f in rule.get("facts", []):
		if not facts.has(String(f)): return true
	# без нових фактів: дія (прапорець / стан зони / перехід екрана) вважається
	# новою, лише поки її результат ЩЕ НЕ настав — інакше спрацьовувала б вічно
	var sf: Dictionary = rule.get("sets_flag", {})
	for k in sf:
		if flags.get(k, null) != sf[k]: return true
	var st: Dictionary = rule.get("sets_state", {})
	for z2 in st:
		if zone_states.get(z2, &"default") != st[z2]: return true
	if rule.has("screen") and rule.get("facts", []).is_empty() \
			and sf.is_empty() and st.is_empty():
		return true    # чистий перехід (взяти в руки) — повторюваний за задумом
	return false


# Знайти правило для (зона × інструмент) у поточному стані.
# Порядок у таблиці має значення: перше придатне виграє. Тому в даних правило
# з довшою витримкою (dwell) стоїть ПІСЛЯ коротшого — коротке спрацює першим,
# і лише коли його факт уже здобутий, черга дійде до довгого.
static func find(rules: Array, zone: StringName, tool: StringName,
				 facts: Dictionary, flags: Dictionary,
				 zone_states: Dictionary = {}) -> Dictionary:
	for r in rules:
		var rr: Dictionary = r
		if StringName(rr.get("zone", &"")) != zone: continue
		var rt := StringName(rr.get("tool", &"*"))
		if rt != &"*" and rt != tool: continue
		if not applicable(rr, facts, flags): continue
		if not yields_new(rr, facts, flags, zone_states): continue
		return rr
	return {}


# Витримка, якої вимагає правило (0 — діє одразу, по кліку).
static func dwell_of(rule: Dictionary) -> float:
	return float(rule.get("dwell", 0.0))


# Застосувати: повертає список НОВИХ фактів (дублі відсіює викликач через add_fact).
static func facts_of(rule: Dictionary) -> Array:
	return rule.get("facts", [])
