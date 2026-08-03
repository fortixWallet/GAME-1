---
name: playtest
description: Прогнати гру кліками через пілот-міст за краєм екрана — перевірити сцену, зняти скріншоти, здобути факти. Вживати ПЕРЕД показом будь-чого Вікторові (правило 13).
argument-hint: [сценарій кліків або "справа 2"]
---

# Плейтест пілотом (правило 13: не пройдено кліками — не здано)

## Запуск (точно так, інакше граблі)
```bash
UD=~/Library/Application\ Support/Godot/app_userdata/"Bureau of Attribution — Case 1"
pkill -f godot; sleep 2                    # ДВІ копії б'ються за pilot_cmd.txt
export G3_SHOTDIR="/tmp/g3_X/"; rm -rf /tmp/g3_X; mkdir -p /tmp/g3_X
rm -f "$UD/pilot_cmd.txt" "$UD/pilot_done.txt"
(exec caffeinate -dis godot --position 4000,100 --path . --rendering-driver opengl3 -- pilot >/tmp/pilot.log 2>&1 &)
until grep -q 'ready 0' "$UD/pilot_done.txt" 2>/dev/null; do sleep 2; done
q(){ echo "$1" > "$UD/pilot_cmd.txt"; sleep 2.5; }
r(){ echo "  $1 → $(cat "$UD/pilot_done.txt")"; }
```
Команди: `click X Y` · `move X Y` · `loupe X Y` (зафіксувати скло) · `key N` · `shot`.

## Закони
- `--position 4000,100` ЗАВЖДИ — вікна на екрані Віктора заборонені.
- Звіт містить `facts=N/M tool=… loupe=…` — правило 17: віриш числу, не оку.
- Звіт може відставати від анімації: пілот чекає box_busy і 0.4 c, але після
  довгих твінів давай `shot` окремо.
- Скріншоти читати Read-ом; серію — контактним листом (PIL, 6 кадрів на лист).
- Після прогону: `pkill -f godot`. Скарга «зависло» = дві копії гри або хук.
- Координати зон НЕ вгадуй: сітка часток → скіл zones.

## Свіжий гравець
Субагент casual-player (.claude/agents/) — чистий контекст, грає без знання
дизайну, переказує своїми словами, де застряг. Це і є здача екрана.

## СТОП означає СТОП
«Стоп/зупини» від Віктора = зупинити СПОЧАТКУ агента-гравця (TaskStop за його
task_id), і лише потім pkill godot. Убити тільки гру — агент перезапустить її
за власною інструкцією (сталося 03.08). Кожен запущений агент-гравець
занотовується з його task_id одразу при старті.
