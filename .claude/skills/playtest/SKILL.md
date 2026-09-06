---
name: playtest
description: Прогнати Genuine Article кліками через міст /tmp/bureau_bridge — перевірити сцену, зняти кадри, здобути факти. Вживати ПЕРЕД показом будь-чого Вікторові (правило 13).
argument-hint: [сцена і сценарій кліків]
---

# Плейтест мостом (правило 13: не пройдено кліками — не здано)

Гра: `/Users/skydrows/Documents/Game/Bureau` (Genuine Article). Міст живе
в `/tmp/bureau_bridge/` (cmd.txt · done.txt · view.png), НЕ в userdata.

## Запуск
```bash
cd /Users/skydrows/Documents/Game/Bureau
pkill -9 -f "godot.*bridge"; rm -rf /tmp/bureau_bridge; mkdir -p /tmp/bureau_bridge
godot --resolution 1512x982 -- bridge <сцена> [стан1 стан2 …] >/tmp/bridge_log.txt 2>&1 &
# чекати "0 ready scene=…" у /tmp/bureau_bridge/done.txt (~8 с)
```
- 1512x982 ЗАВЖДИ — формат екрана Віктора 16:10; інших розмірів не знімати.
- НІКОЛИ `pkill -9 -f godot` без "bridge" — уб'є гру Віктора.

## Дії — клієнтом tools/play.py (сам чекає done і друкує стан)
`tools/play.py look|where|click X Y|drag X Y|turn X Y|key d|next|quit`
Або сирим протоколом: `echo "N click X Y" > /tmp/bureau_bridge/cmd.txt`
(N = лічильник +1; ще: glide/hover/shot/zones/state/go/kasa/player/rclick).

## Координати — ДВІ системи (граблі, оплачені годинами)
- зони в scenes/*.gd — частки ФОНУ; міст клікає частками ВІКНА:
  `x_вікна = (x_фону − 0.067) / 0.866`, y без зміни.
- зона поза x_вікна [0.067..0.933] — мертва (за краєм).
- done.txt відстає, поки busy (у verify пауза 0.22с) — sleep 3–4 після.

## Закони
- Кадр дивитись ОКОМ: Read /tmp/bureau_bridge/view.png (числа не ловлять зміст).
- Тест чужого шляху в КОЖНІЙ копії механіки, не лише в еталоні (урок 22.08).
- Скарга Віктора = дослівний тест-кейс (правило 35): відтворити ЙОГО кліки.
- Свіжий гравець: субагент casual-player (.claude/agents/) НА OPUS — чистий
  контекст, переказує своїми словами, де застряг. Це і є здача екрана.
- «Стоп» від Віктора = спершу TaskStop агента-гравця, потім pkill моста
  (інакше агент перезапустить гру — сталося 03.08).
- Після прогону: `pkill -9 -f "godot.*bridge"`.
