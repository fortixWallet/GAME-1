# PIPELINE — API-рецепти і ключі. ⚠️ ПРИВАТНИЙ ФАЙЛ: не публікувати, не комітити в публічний репозиторій.

## Ключі і середовище

> **Ключі живуть у `.keys.env`** (у `.gitignore`). Підключити: `source .keys.env`.
> Шаблон — `.keys.env.example`. У документах ключів немає й бути не має.
```bash
pip install requests google-genai pillow elevenlabs --break-system-packages
export MESHY_API_KEY=«У .keys.env — НЕ в git»            # баланс ~319 кр; топ-ап перед Ф5
export GEMINI_API_KEY=«У .keys.env — НЕ в git»  # проєкт 712289968005 З білінгом
export ELEVENLABS_API_KEY=«У .keys.env — НЕ в git» # план Creator (комерційно ок)
npx -y @gltf-transform/cli --version
```
Перший Gemini-ключ (AQ.Ab8RN6JWkUnm…) — проєкт БЕЗ білінгу, не працює. Ключ засвітився → перевипустити.
Скрипти: `pipeline/` — style.py (єдине джерело стилю) · nbp.py · meshy.py · sfx.py · item_pipeline.py.

## 2D — Nano Banana Pro (`gemini-3-pro-image`, nbp.py)
- ≤14 зображень/запит; 2K ≈ $0.134; чернетки `gemini-2.5-flash-image` $0.039. SynthID-вотермарк — ок, у Steam декларуємо ШІ.
- **EDIT, don't re-roll:** стани, емоції, шари, кадри частин — правкою канону (99% пікселів успадковуються, стиль не пливе).
- Промпти: матеріали і сліди часу, не оцінки. Скрізь «no text».
- JPEG-під-.png: `_gen()` нормалізує PIL; руками — те саме, інакше Godot мовчки не імпортує.
- Персонажі: `character()` (Image1=identity, далі style-refs) → `emotion()` правками. Trait-lock: риси дослівно однакові в кожному промпті. Рука Продавця — один опис у всіх обличчях.
- Сцени: повний кадр → правками шари/стани; окремі елементи на нейтральному тлі → виріз PIL/rembg (обробка — дозволена, малювання кодом — ні).
- IP-чек кожного обличчя/концепту ДО продакшну.

## 3D — Meshy image-to-3d (meshy.py; міст NBP→Meshy)
Meshy ліпить УСЕ, що бачить у кадрі, і не вміє «предмет з кришкою» одним мешем. Тому:
1. NBP: концепт → правками кадри частин: тіло без кришки з видимим нутром; кришка ОКРЕМО, трохи ЗГОРИ, «completely alone, no box, nothing underneath». Привид під кришкою → обрізати PIL, не переганяти.
2. Фурнітура через стик — розділити на кадрах: REMOVE верхню половину з тіла / ADD її на край кришки.
3. Параметри: `ai_model:"meshy-6"` (пін) · `should_texture:true` · `enable_pbr:true` · `remove_lighting:true` (обов'язково) · polycount 8000 тіло / 4000 кришка (hero 15000) · `origin_at:"bottom"` · texture_prompt (+10 кр). Промпт ≤600 симв.; негативів НЕ існує; без glow/smoke/magic. URL тимчасові — качати одразу.
4. Оптимізація: `npx -y @gltf-transform/cli optimize in.glb out.glb --compress false --texture-compress auto --texture-size 2048`. **`--compress false` свято:** meshopt Godot не підтримує — мовчки чорний екран.
5. Складання — математика (TECH.md), ніколи «на око». Перевірка — скріншот у кадрі гри, не прев'ю Meshy.
Ціна hero: ~$0.40 NBP + ~80 кр Meshy; 15 хв — година з ітераціями.

## Звук — ElevenLabs (sfx.py)
SFX: 40 кр/сек, ≤30 с; ambience `loop:true`; сідів нема — варіювати `prompt_influence` 0.3–0.7. Голоси: Voice Design `ttv_v3` (українська є); мовлення `eleven_v3` з тегами `[whispers]` `[exhales]`. Музика: ElevenLabs Music. Free-tier не комерціалізується — у нас Creator, стежити за підпискою.

## Шрифти
Google Fonts, ліцензія OFL, повна укр. кирилиця (кандидати в ASSETS.md). Завантажити .ttf у проєкт, ліцензію — поруч.
