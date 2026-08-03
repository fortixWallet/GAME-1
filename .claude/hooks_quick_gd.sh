#!/bin/bash
# швидка перевірка ТІЛЬКИ після правки .gd-файлів; без вікон (verify --quick)
f=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)
case "$f" in
  *.gd) bash .claude/verify_build.sh --quick >/dev/null 2>&1 \
        || { echo "ЗБІРКА ЗЛАМАНА: bash .claude/verify_build.sh --quick покаже деталі" >&2; exit 2; } ;;
esac
exit 0
