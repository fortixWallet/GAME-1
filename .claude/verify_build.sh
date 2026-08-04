#!/bin/bash

# Тестові вікна: БЕЗ App Nap (28.07: прикрите вікно морозило твіни печатки, і
# сторожа тестів вичерпувалась до ранку) і ЗА екраном (не миготіти Вікторові).
godot() { command caffeinate -dis godot --position 4000,100 "$@"; }

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
  SPEC=$(python3 tools/validate_cases.py || exit 2
python3 tools/check_gd_rules.py 2>&1)
  echo "--- validate_cases ---" >>"$LOG"; echo "$SPEC" >>"$LOG"
  if ! echo "$SPEC" | grep -q "ERROR: 0"; then
    echo "СПЕЦИФІКАЦІЇ СПРАВ ЗЛАМАНІ:"
    echo "$SPEC" | grep "^  ERROR" | head -10
    echo "Повний звіт: python3 tools/validate_cases.py"
    exit 2
  fi
fi

# 0б) КАДРИ ОДНОГО ПРЕДМЕТА ТРИМАЮТЬ ОДНУ КАМЕРУ (правило 19). Фазова кореляція по
#     нерухомій частині кадру. Ловить те, що бачить лише око гравця: стрибок ракурсу
#     між станами речі. Тиждень 24–31.07 пішов саме на це.
PY=$(command -v python3)
for c in /Users/skydrows/Documents/Trading/.venv/bin/python3 "$PY"; do
  [ -x "$c" ] && "$c" -c "import numpy, PIL" 2>/dev/null && PY="$c" && break
done
FOUT=$("$PY" tools/check_frames.py 2>&1); FRC=$?
echo "--- check_frames ---" >>"$LOG"; echo "$FOUT" >>"$LOG"
if [ $FRC -ne 0 ]; then
  echo "КАДРИ РОЗІЙШЛИСЬ — у грі це стрибок ракурсу:"
  echo "$FOUT" | grep -E "✗|FRAMES"
  exit 2
fi
echo "$FOUT" | grep "^FRAMES"

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
TESTS="walk a|walk b|walk c|walk e|walk p|walk q|chapters|outcomes|layoutcheck|case2|savetest|furnprobe"
if [ "$1" = "--c2" ]; then
  TESTS="case2|furnprobe|layoutcheck"
  echo "ШВИДКИЙ РЕЖИМ: лише справа 2 (повний гейт обов'язковий перед комітом)"
fi
# --quick: БЕЗ ЖОДНОГО ВІКНА. Тільки компіляція, дані і кадри — секунди.
# Саме цей режим вішається на хук після правки файлу: повний гейт відкривав
# 12 вікон Godot поверх роботи Віктора (31.07: «зупини це по колу відкриття
# гри!!!»), а два гейти одночасно ще й билися за GPU і валили тести.
if [ "$1" = "--quick" ]; then
  echo "ШВИДКА ПЕРЕВІРКА: компіляція, дані, кадри — без запуску гри"
  exit 0
fi
IFS='|'; set -- $TESTS; unset IFS
for t in "$@"; do
  OUT=$(godot --path . --rendering-driver opengl3 --position 4000,100 -- $t 2>&1 | grep -v specular)
  echo "--- $t ---" >>"$LOG"; echo "$OUT" >>"$LOG"
  case "$t" in
    # walk b перевіряє ВИТРИМКУ (dwell) під лупою — і саме він мовчки падав, поки
    # його тут не було: результат залежав від fps, а не від коду (див. _dt()).
    # walk a — єдиний тест, що клікає зони паперів ЯК ГРАВЕЦЬ (walk c сідає факти напряму)
    "walk a")   echo "$OUT" | grep -q "WALK_A_OK read_news=true" || FAIL="$FAIL walk-a" ;;
    # case2: аудит 26.07 знайшов її повністю зламаною при зеленому гейті — факти
    # жили на видаленому механізмі meta("mark"), і жоден тест цього не бачив
    "case2")    echo "$OUT" | grep -q "CASE2_OK neg_flag=true screwed=true looked=true neg_state=true confirm=true opened=true num19=true filled=true outcome=out.void_named" || FAIL="$FAIL case2" ;;
    # сейв: відновлення ДО ПОЛЯ (факти в порядку, cvals, стани зон, інструменти) + відмова чужій версії
    "savetest") echo "$OUT" | grep -q "SAVE_OK wiped=true restored=true order=true cvals=true zones=true tools=true reject_v99=true" || FAIL="$FAIL savetest" ;;
    # walk e — інформаційний ланцюг кроку 6: квитанція → інструменти → заміри →
    # реєстр/довідник → «пустий спід», з НЕГАТИВОМ (довідник до клейма мовчить)
    "walk e")   echo "$OUT" | grep -q "WALK_E_OK neg=true unlocked=true measured=true books=true alone=true" || FAIL="$FAIL walk-e"
                # нотатник: рядків рівно стільки, скільки здобуто фактів справи
                echo "$OUT" | grep -q "NOTEBOOK_OK.*match=true" || FAIL="$FAIL notebook" ;;
    "walk b")   echo "$OUT" | grep -q "WALK_B_OK found_marks=true found_church=true" || FAIL="$FAIL walk-b"
                # горбики (5c): рука → f.domes, лупа → f.domes_alike, стан зони raised
                echo "$OUT" | grep -q "WALK_B_DOMES hand=true alike=true state=raised" || FAIL="$FAIL domes"
                # «провести пальцем»(drag 40px) — це дія, а не оберт (плейтест 26.07)
                echo "$OUT" | grep -q "WALK_B_FINGER swipe_gives_domes=true" || FAIL="$FAIL finger"
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
    # furnprobe: 2D-шлях справи 2 — жодної зони без екрана чи поза плитою, жодного
    # екрана без виходу, і всі 12 фактів досяжні (стара проба 3D-мешів знята 30.07)
    "furnprobe") echo "$OUT" | grep -qE "C2PROBE_OK bad_screen=0 bad_frame=0 no_exit=0 facts=15/15" || FAIL="$FAIL c2probe" ;;
    # walk q: записник гортається; 15 фактів справи 2 розкладено по аркушах
    # 04.08: довший текст довідки про шурупи (1846) переніс один рядок на другий аркуш
    "walk q")   echo "$OUT" | grep -q "WALK_Q_OK rows_first=8 rows_last=7 total=15" || FAIL="$FAIL walk-q" ;;
    # walk p: усі лінійовані папери будуються з живими фактами без падінь
    "walk p")   echo "$OUT" | grep -q "WALK_P_OK notebook_rows=8" || FAIL="$FAIL walk-p" ;;
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
