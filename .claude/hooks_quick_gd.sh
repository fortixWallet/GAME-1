#!/bin/bash
# Швидка перевірка ТІЛЬКИ після правки .gd-файлів: парсер сцен справжнього проєкту (Bureau), без вікон.
# 07.09: раніше ганяв стару гру з Game3 (verify_build.sh); стару збірку прибрано з робочого дерева.
f=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)
case "$f" in
  */Bureau/*.gd)
    cd /Users/skydrows/Documents/Game/Bureau || exit 0
    OUT=$(.venv/bin/python3 tools/check_scenes.py 2>&1) || { echo "СЦЕНИ НЕ ПАРСЯТЬСЯ: $(echo "$OUT" | tail -3)" >&2; exit 2; }
    echo "$OUT" | grep -q "SCENES_OK" || { echo "check_scenes без SCENES_OK: $(echo "$OUT" | tail -2)" >&2; exit 2; } ;;
esac
exit 0
