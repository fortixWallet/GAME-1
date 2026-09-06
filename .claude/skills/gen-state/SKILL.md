---
name: gen-state
description: Згенерувати кадр або стан предмета для Bureau (Gemini, tools/gen_img.py) зі збереженням камери і канону «чітка гуаш». Вживати для БУДЬ-ЯКОЇ генерації арту гри.
argument-hint: <вихід.png> "<що змінюється>" <референс.png>
---

# Генерація Bureau: tools/gen_img.py (ключі з .keys.env, не показувати)

```bash
cd /Users/skydrows/Documents/Game/Bureau
python3 tools/gen_img.py OUT.png "промпт" REF1.png [REF2.png …] [--ar W:H]
```
Без `--ar` буде квадрат 1024². Генерації Gemini без ліміту — але промпт
продумується ПОВНІСТЮ до першої спроби (пам'ять game3-think-before-acting).

## Стиль-суфікс — ДОСЛІВНО в КОЖЕН промпт
```
crisp gouache game illustration: flat opaque colour areas with hard clean edges,
a thin even dark outline around each element, at most three flat tones per object
(light / base / shadow) with sharp boundaries, shadows are hard-edged flat shapes.
No gradients, no blur, no brush texture, no glow. 1900s Vienna. No text anywhere.
```
Еталони стилю — кадри, які ВЖЕ в грі: `Bureau/art/_ETALON_client.png` ·
`spoon_close_bg.png` · `spoon_mark_hd.png` · `attest_blank.png`.

## Закони
1. **Канон «чітка гуаш»**: заборонені слова cinematic realism · oil-painted ·
   photographic · realism. Референсом класти КАДР ГРИ і казати «малюй ТОЧНО
   в тому ж стилі, що й референс».
2. **Правило 19 — камера:** стан речі (відкрити/зняти/перевернути) — генерацією
   з попереднього кадру референсом; слова closer/macro/zoom/move the camera/
   close-up ЗАБОРОНЕНІ — наближення тільки КРОПОМ. Новий кадр звіряти
   `tools/check_frames.py`: збіг < 0.3 = чужа зйомка, не ставимо.
3. **Правило 40 — порядок:** порожній стіл → кожен предмет СВОЄЮ генерацією
   на тому ж столі (спрайт = «стіл+річ» мінус «стіл», з рідною тінню) →
   сцена шарами → лише тоді анімація. Не вирізати з людної сцени.
4. **Правило 44:** предмет народжується ЦІЛИМ і в HD з усіма ознаками
   (клейма, знос) однією генерацією; далі лише зменшення/кроп. Ніяких вклейок
   поверх старого — кут вирізки видно оком.
5. **Правило 38 — світ один:** усі кадри однієї речі/кімнати зшиті (сукно,
   дерево, світло ті самі); перевірка `tools/check_world.py`, і ОКОМ поруч
   із сусіднім кадром тієї ж сцени.
6. **Кеш імпорту:** нові PNG → `godot --headless --import`, інакше без .ctex
   (ловило 4 рази). Потім точковий сенсор і кадр мостом.
7. «no text anywhere» у промпті — написи тільки шрифтом поверх (правило 1).
