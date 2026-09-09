#!/bin/bash
# ЗАПУСК ГРИ ЛИШЕ НА СЛОВО ВІКТОРА «перевір» (закон 46, 09.09: «МІНЯЙ ЦЕ»).
# Блокує Bash-команди, що піднімають гру з вікном або мостом (godot без --headless/--import/
# --export, bridge, тестові прогони), якщо нема прапорця .claude/allow_play. Прапорець ставиться
# ТІЛЬКИ після прямого прохання Віктора і знімається після одного прогону.
cmd=$(jq -r '.tool_input.command // empty' 2>/dev/null)
[ -z "$cmd" ] && exit 0
FLAG=/Users/skydrows/Documents/Game/Game3/.claude/allow_play
if echo "$cmd" | grep -Eq 'godot[^|&;]*--headless[^|&;]*(--import|--export|--check|--script)|--export-release|build_demo\.py|build_installers|subset_cjk|check_fit\.py|check_loc_live|check_bubfit'; then
  exit 0   # імпорт, експорт, аудити без вікна — не гра
fi
if echo "$cmd" | grep -Eq '(^|[ /;&|(])godot([ ]|$)|bridge_boot|bridge\.sh|test_[a-z_]+\.py|check_combos\.py|run_day\.sh|-- (bridge|test|pilot|snap|probe)'; then
  if [ -f "$FLAG" ]; then
    rm -f "$FLAG"   # один прогін на дозвіл
    exit 0
  fi
  echo "ЗАПУСК ГРИ ЗАБЛОКОВАНО (закон 46): гру ганяє Віктор. Дозвіл — лише на його слово «перевір»: touch $FLAG на один прогін." >&2
  exit 2
fi
exit 0
