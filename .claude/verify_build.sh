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

# 1б) юніт-тести рушія зон: headless, швидкі; ловлять регресію core/zones.gd,
#     яку жоден візуальний прогін не бачить (аудит 26.07, знахідка 45)
ZOUT=$(godot --headless --path . --script res://tools/test_zones.gd 2>&1)
echo "--- test_zones ---" >>"$LOG"; echo "$ZOUT" >>"$LOG"
if ! echo "$ZOUT" | grep -q "ZONES_TEST_OK"; then
  echo "ТЕСТИ РУШІЯ ЗОН УПАЛИ:"; echo "$ZOUT" | grep -E "✗|падінь" | head -5
  exit 2
fi

# 2) автотести: справа 1 і точки входу сцен
export G3_SHOTDIR="/tmp/g3_verify/"
rm -rf "$G3_SHOTDIR"; mkdir -p "$G3_SHOTDIR"
FAIL=""
for t in "walk a" "walk b" "walk c" "walk e" "chapters" "outcomes" "layoutcheck" "case2"; do
  OUT=$(godot --path . --rendering-driver opengl3 -- $t 2>&1 | grep -v specular)
  echo "--- $t ---" >>"$LOG"; echo "$OUT" >>"$LOG"
  case "$t" in
    # walk b перевіряє ВИТРИМКУ (dwell) під лупою — і саме він мовчки падав, поки
    # його тут не було: результат залежав від fps, а не від коду (див. _dt()).
    # walk a — єдиний тест, що клікає зони паперів ЯК ГРАВЕЦЬ (walk c сідає факти напряму)
    "walk a")   echo "$OUT" | grep -q "WALK_A_OK read_news=true" || FAIL="$FAIL walk-a" ;;
    # case2: аудит 26.07 знайшов її повністю зламаною при зеленому гейті — факти
    # жили на видаленому механізмі meta("mark"), і жоден тест цього не бачив
    "case2")    echo "$OUT" | grep -q "CASE2_OK wear=true chain=true docs=true" || FAIL="$FAIL case2" ;;
    # walk e — інформаційний ланцюг кроку 6: квитанція → інструменти → заміри →
    # реєстр/довідник → «пустий спід», з НЕГАТИВОМ (довідник до клейма мовчить)
    "walk e")   echo "$OUT" | grep -q "WALK_E_OK neg=true unlocked=true measured=true books=true alone=true" || FAIL="$FAIL walk-e"
                # нотатник: рядків рівно стільки, скільки здобуто фактів справи
                echo "$OUT" | grep -q "NOTEBOOK_OK.*match=true" || FAIL="$FAIL notebook" ;;
    "walk b")   echo "$OUT" | grep -q "WALK_B_OK found_marks=true found_church=true" || FAIL="$FAIL walk-b"
                # горбики (5c): рука → f.domes, лупа → f.domes_alike, стан зони raised
                echo "$OUT" | grep -q "WALK_B_DOMES hand=true alike=true state=raised" || FAIL="$FAIL domes"
                # зона мусить лишатися СТРОГОЮ: точка за 200 px від клейм не дає факту
                echo "$OUT" | grep -q "WALK_B_STRICT far_rejected=true" || FAIL="$FAIL walk-b-strict" ;;
    "walk c")   echo "$OUT" | grep -q "WALK_C_OK sealed=true"        || FAIL="$FAIL walk-c"
                # крок 7: числа поза полем відкинуто; всі 6 граф заповнено; ранок = out.forgery_named
                echo "$OUT" | grep -q "CERT_NUM_REJECT low=true long=true" || FAIL="$FAIL cert-num"
                echo "$OUT" | grep -q "CERT_FILLED all=true" || FAIL="$FAIL cert-fill"
                echo "$OUT" | grep -q "outcome=out.forgery_named" || FAIL="$FAIL cert-outcome" ;;
    "chapters") echo "$OUT" | grep -q "CHAPTERS_OK all_reachable=true" || FAIL="$FAIL chapters" ;;
    # чотири наслідки мусять давати чотири РІЗНИХ тексти: дві однакові гілки
    # виглядають як покриття, а насправді одна з них не перевіряється ніколи
    "outcomes") echo "$OUT" | grep -q "OUTCOMES_OK cases=5 unique_ids=4" || FAIL="$FAIL outcomes" ;;
    # жоден текст не має налазити на інший (вимога Віктора, 26.07)
    "layoutcheck") echo "$OUT" | grep -q "накладань= 0" || echo "$OUT" | grep -q "накладань=0" || FAIL="$FAIL layout" ;;
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
