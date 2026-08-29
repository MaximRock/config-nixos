# План: Заглушки для блока «Наши проекты»

> Контекст: лендинг студии/конструктора сайтов. Блока «Наши проекты» пока пустой. Нужно временное превью, честное (не выдавать за реальные кейсы).

## Рекомендованный вариант: A — Lazy-заглушки (5 минут)

**Идея:** не генерить картинки, а использовать плейсхолдеры + градиенты с подписью «Концепт».

**Почему:** 1 строка кода, 0 зависимостей, не вводит клиента в заблуждение, легко заменить на реальные проекты.

**Реализация:**
- Сетка 6 карточек (3x2 на десктопе, 1 колонка на мобиле)
- `src="https://picsum.photos/seed/project1/600/400"` или `https://placehold.co/600x400/EDE9FE/4C1D95?text=Concept`
- Поверх: градиент + бейдж `Концепт` + категория
- При ховере: `Хочу так же →` (CTA на форму)

**Пример (Tailwind):**
```html
<div class="grid grid-cols-1 md:grid-cols-3 gap-6">
  <div class="relative rounded-2xl overflow-hidden aspect-[3/2] bg-gradient-to-br from-violet-100 to-indigo-200">
    <img src="https://picsum.photos/seed/p1/600/400" alt="" class="w-full h-full object-cover mix-blend-overlay opacity-60">
    <div class="absolute inset-0 p-4 flex flex-col justify-end bg-gradient-to-t from-black/50 to-transparent">
      <span class="text-xs bg-white/90 px-2 py-1 rounded-full w-fit">Концепт • Лендинг</span>
      <h3 class="text-white font-semibold mt-2">Кофейня — Minimal Landing</h3>
    </div>
  </div>
  <!-- x6: seed p1..p6, меняй категорию -->
</div>
```

**6 категорий для заглушек:**
1. Лендинг — кофейня/кафе
2. E-commerce — магазин одежды
3. SaaS — дашборд/аналитика
4. Ресторан — доставка/меню
5. Блог/Портфолио — персональный сайт
6. Недвижимость — каталог/поиск

**Замена на реал:** просто меняешь `src` и убираешь бейдж `Концепт`.

---

## Вариант B — AI-мокапы (если нужен вау-эффект)

**Когда:** нужен премиум-вид для презентации.

**Где генерить:**
- Бесплатно локально: FLUX.1 [schnell] через ComfyUI (у тебя ROCm уже настроен)
- Облако: Ideogram 3.0 (лучше всего пишет текст на картинке) / FLUX 1.1 Pro / Midjourney v7

**Промпты (копируй как есть, соотношение 3:2, browser mockup):**
1. `clean browser mockup of minimalist coffee shop landing page, hero with latte art, white and beige, modern typography, on light gray background --ar 3:2`
2. `browser mockup of fashion e-commerce homepage, grid of clothing products, minimal, black and white --ar 3:2`
3. `browser mockup of saas analytics dashboard, dark mode, charts and graphs, modern --ar 3:2`
4. `browser mockup of restaurant website, large food photography, warm orange tones, menu section --ar 3:2`
5. `browser mockup of personal blog portfolio, large serif typography, whitespace, editorial --ar 3:2`
6. `browser mockup of real estate listing site, hero search bar, property cards, clean blue --ar 3:2`

**Для Ideogram добавь:** `text "DEMO" small badge top left`

---

## Вариант C — Скриншоты шаблонов (компромисс)

Взять 6 бесплатных шаблонов с html5up.net / dribbble (free), сделать скрин, заблюрить лого. Подписать `Шаблон из каталога`. Честно и красиво.

---

## План переноса в другой проект

1. Скопируй этот файл в корень нового проекта
2. Выбери вариант (рекомендую A)
3. Дай агенту команду: `реализуй блок "Наши проекты" по site-img.md, вариант A`
4. Когда появятся реальные кейсы — замени `picsum` на `src="/projects/p1.jpg"`

## Что спросить у агента в новом проекте

> Реализуй блок «Наши проекты» по site-img.md, вариант A. Сетка 6 карточек, Tailwind, плейсхолдеры picsum.photos, бейдж «Концепт». Добавь hover-эффект и CTA.

## Чек-лист

- [ ] Выбран вариант A/B/C
- [ ] Определено кол-во карточек (3 или 6)
- [ ] Подобрана палитра под стиль сайта
- [ ] Добавлен дисклеймер «Концепт» (чтобы не вводить в заблуждение)
- [ ] Прописан TODO: заменить на реальные проекты
