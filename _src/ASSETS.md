# ASSETS — маніфест, паспорт кадру, промпти
Джерела: 2D — Nano Banana Pro · 3D — Meshy · звук/музика — ElevenLabs · шрифти — Google Fonts (OFL). Все інше не використовуємо.

## Паспорт кадру
- Аспект 16:9. Майстер-арт 4K (3840×2160), гра 1920×1080; зум «У РУКАХ» — з 4K без мила.
- На згенерованих артах ТЕКСТУ НЕМАЄ («no text» у кожному промпті) — NBP псує кирилицю. Всі написи шрифтом.
- Шрифти (кандидати, вибір Віктора на живому бланку): рукописний — Marck Script / Neucha / Caveat; антиква — PT Serif / Literata / Playfair Display. Обидва з повною укр. кирилицею, ліцензія OFL.
- Палітра dark academia (кандидат, фіксується еталоном): темне дерево, латунь, старий папір, глибокі тіні, тепла лампа; акцент — сургучево-червоний (єдиний «гарячий» колір — печатка і критичне).

## Екрани (11) — кожен: фон + шари + стани
1. **Кабінет (хаб):** стіл, картотека, полиці(+річ №6 з дня 1!), годинник(стрілки окремо), портрет(рівно/криво/знятий+щілина), лампа, вікно(3 стани), двері, кіт. Час доби: день/вечір/ніч/ТЕМРЯВА (мальований шар мороку).
2. **Стіл-справа (зум):** сукно, тека, річ, інструменти (лупа/косе світло/олійниця/пензлик), квитанції.
3. **Річ «У РУКАХ»:** 3D у SubViewport на мальованій віньєтці.
4. **Атестат:** бланк крупно, перо, варіанти-картки, печатка+сургуч (анімація-герой).
5. **Довідники:** розворот-шаблон ×5 книг.
6. **Газетна підшивка.**
7. **Картотека-зум** (шухляди, теки, замкнена нижня).
8. **Розворот семи тек** (сцена-підпис).
9. **Вечірній підсумок** (гросбух).
10. **Меню/титул** (двері бюро знадвору), налаштування.
11. **Кінцівки:** 6 фінальних кадрів + титри.

## UI-кіт (усе картинками, стани: звичайний/hover/натиснутий)
Кнопки-ярлики, рамки-картуші, закладки книг, варіанти-картки атестата, курсор-рука ×4, шкала-борг (латунна каса), лічильник печаток (диптих на стіні — діегетичний!), іконки інструментів. Hover = домальований теплий відблиск.

## Промпт-шаблони (EN; стиль-блок і референси — з style.py, після еталона)

**Еталон-кадр кабінету:**
"Interior of a turn-of-the-century attribution bureau, seen from behind the expert's desk toward the room: heavy oak desk with green cloth, brass lamp, card cabinet, floor-to-ceiling bookshelves, wall clock stopped at 4:07, slightly crooked founder's portrait, tall window with night fog, sleeping cat. Dark academia, oil painting, visible brushwork, warm lamplight, deep brown shadows, muted greens and umbers. No people, no text. 16:9."

**Портрет персонажа:** "Half-length portrait of {десь 25 слів: вік, риси trait-lock, одяг, характер}, seated at the bureau counter, facing viewer, {emotion}. Same painted style as the style references. Plain dark background, no text." → емоції правкою (emotion()).

**Річ 2D-картка:** "A single object on plain dark background: {матеріали і сліди часу, не оцінки}. Museum lighting, three-quarter view, fully in frame, painted style per references, no text."

**Кадри частин для 3D:** тіло — "…lid completely removed, open body only, visible hollow interior, clean rim edges…"; кришка — "…ONLY its detached lid, seen slightly from ABOVE, completely alone, no box, nothing underneath…". Фурнітура через стик — REMOVE з тіла / ADD на кришку. Привид → обрізати PIL.

**Шар/стан сцени (edit):** "Using the provided image, keep everything identical. Change only: {the desk drawer is pulled open / the clock has no hands / the lamp is extinguished, near-total darkness, faint object outlines}. Same style, same angle."

**Папір:** "Blank {certificate form/newspaper page/ledger spread} on aged laid paper, ornate engraved border, empty ruled lines and empty column blocks, {wax seal spot}, top-down view, painted style, no text, no letters."

**SFX (приклади):** печатка — "heavy brass seal pressed into hot sealing wax, close-up: firm thud then soft wax squelch, 1900s office, high quality"; темрява — "faint ringing silence with a slow wooden creak, something small opening by itself, unsettling, close".

## Обсяг генерацій (з браком ×1.5)
Еталон+екрани ~70 · шари/стани кабінету ~45 · портрети+емоції ~45 · речі 2D ~35 · папери ~45 · UI-кіт ~30 → **~270 генерацій NBP ≈ $40** (чернетки — flash-моделлю, дешевше). Meshy: 3 hero × 2 частини × 40 кр + ітерації ≈ **400–500 кр** (баланс 319 → докупити ~$20). ElevenLabs: у межах Creator.
