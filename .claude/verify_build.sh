#!/bin/bash
# Перевірка збірки після правки main.gd: імпорт Godot + автотести.
# Виходить з кодом 2 (блокуюча помилка), якщо збірка зламана — тоді Claude бачить це негайно.
# Ручний запуск: .claude/verify_build.sh
G3="/Users/skydrows/Documents/Game/Game3"
LOG="$G3/.claude/last_verify.log"
cd "$G3" || exit 0
command -v godot >/dev/null 2>&1 || exit 0          # нема Godot — мовчки пропускаємо

: > "$LOG"
# 0) специфікації справ: погана ФОРМА даних валить збірку так само, як поганий код.
#    Ловить: висновок у варіанті бланка · число, переписане з предмета · висячі id ·
#    відхід від канонічної схеми. Деталі — _src/ENGINE_SPEC_ADDENDUM.md.
if command -v python3 >/dev/null 2>&1; then
  SPEC=$(python3 tools/validate_cases.py 2>&1)
  echo "--- validate_cases ---" >>"$LOG"; echo "$SPEC" >>"$LOG"
  if ! echo "$SPEC" | grep -q "ERROR: 0"; then
    echo "СПЕЦИФІКАЦІЇ СПРАВ ЗЛАМАНІ:"
    echo "$SPEC" | grep "^  ERROR" | head -10
    echo "Повний звіт: python3 tools/validate_cases.py"
    exit 2
  fi
fi

# 1) імпорт: перший запуск може впасти на шрифті (баг 4.6.3) — тому дві спроби
godot --headless --path . --import >>"$LOG" 2>&1
godot --headless --path . --import >>"$LOG" 2>&1

ERRS=$(grep -iE "Parse Error|SCRIPT ERROR|Failed to load script" "$LOG" | grep -v "specular" | head -5)
if [ -n "$ERRS" ]; then
  echo "ЗБІРКА ЗЛАМАНА — main.gd не компілюється:"
  echo "$ERRS"
  exit 2
fi

# 2) автотести: справа 1 і точки входу сцен
export G3_SHOTDIR="/tmp/g3_verify/"
rm -rf "$G3_SHOTDIR"; mkdir -p "$G3_SHOTDIR"
FAIL=""
for t in "walk c" "chapters" "outcomes"; do
  OUT=$(godot --path . --rendering-driver opengl3 -- $t 2>&1 | grep -v specular)
  echo "--- $t ---" >>"$LOG"; echo "$OUT" >>"$LOG"
  case "$t" in
    "walk c")   echo "$OUT" | grep -q "WALK_C_OK sealed=true"        || FAIL="$FAIL walk-c" ;;
    "chapters") echo "$OUT" | grep -q "CHAPTERS_OK all_reachable=true" || FAIL="$FAIL chapters" ;;
    # чотири наслідки мусять давати чотири РІЗНИХ тексти: дві однакові гілки
    # виглядають як покриття, а насправді одна з них не перевіряється ніколи
    "outcomes") echo "$OUT" | grep -q "OUTCOMES_OK cases=4 unique=4" || FAIL="$FAIL outcomes" ;;
  esac
  echo "$OUT" | grep -q "OUTCOMES_FAIL" && FAIL="$FAIL outcomes-dup"
  echo "$OUT" | grep -qi "SCRIPT ERROR" && FAIL="$FAIL script-error($t)"
done

if [ -n "$FAIL" ]; then
  echo "АВТОТЕСТИ ВПАЛИ:$FAIL"
  echo "Деталі: $LOG"
  exit 2
fi

echo "OK: імпорт чистий, walk c і chapters проходять."
exit 0
