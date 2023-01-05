---
title: "Трюки ggplot2 - подписи 🤹🤹🤹"
author: "🍪🍪🪙"
date: 2023-01-02
# draft: true # mark as draft
categories: ["data science"]
tags: ["анализ", "R", "для новичков", "статистика", "инфляция"]
math: false # when math activated -> don't use brackets:( and )
ShowToc: true
cover:
    image: "olivie_herring.jpeg"
    alt: "<Трюки ggplot2>"
    caption: "<text>"
    relative: true # To use relative path for cover image, used in hugo Page-bundles
---

<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>
<link href="{{< blogdown/postref >}}index_files/datatables-css/datatables-crosstalk.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/datatables-binding/datatables.js"></script>
<script src="{{< blogdown/postref >}}index_files/jquery/jquery-3.6.0.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/dt-core-bootstrap4/css/dataTables.bootstrap4.min.css" rel="stylesheet" />
<link href="{{< blogdown/postref >}}index_files/dt-core-bootstrap4/css/dataTables.bootstrap4.extra.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/dt-core-bootstrap4/js/jquery.dataTables.min.js"></script>
<script src="{{< blogdown/postref >}}index_files/dt-core-bootstrap4/js/dataTables.bootstrap4.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/dt-ext-responsive-bootstrap4/css/responsive.bootstrap4.min.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/dt-ext-responsive-bootstrap4/js/dataTables.responsive.min.js"></script>
<script src="{{< blogdown/postref >}}index_files/dt-ext-responsive-bootstrap4/js/responsive.bootstrap4.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/crosstalk/css/crosstalk.min.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/crosstalk/js/crosstalk.min.js"></script>
<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>
<link href="{{< blogdown/postref >}}index_files/datatables-css/datatables-crosstalk.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/datatables-binding/datatables.js"></script>
<script src="{{< blogdown/postref >}}index_files/jquery/jquery-3.6.0.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/dt-core-bootstrap4/css/dataTables.bootstrap4.min.css" rel="stylesheet" />
<link href="{{< blogdown/postref >}}index_files/dt-core-bootstrap4/css/dataTables.bootstrap4.extra.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/dt-core-bootstrap4/js/jquery.dataTables.min.js"></script>
<script src="{{< blogdown/postref >}}index_files/dt-core-bootstrap4/js/dataTables.bootstrap4.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/dt-ext-responsive-bootstrap4/css/responsive.bootstrap4.min.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/dt-ext-responsive-bootstrap4/js/dataTables.responsive.min.js"></script>
<script src="{{< blogdown/postref >}}index_files/dt-ext-responsive-bootstrap4/js/responsive.bootstrap4.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/crosstalk/css/crosstalk.min.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/crosstalk/js/crosstalk.min.js"></script>
<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>
<link href="{{< blogdown/postref >}}index_files/datatables-css/datatables-crosstalk.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/datatables-binding/datatables.js"></script>
<script src="{{< blogdown/postref >}}index_files/jquery/jquery-3.6.0.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/dt-core-bootstrap4/css/dataTables.bootstrap4.min.css" rel="stylesheet" />
<link href="{{< blogdown/postref >}}index_files/dt-core-bootstrap4/css/dataTables.bootstrap4.extra.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/dt-core-bootstrap4/js/jquery.dataTables.min.js"></script>
<script src="{{< blogdown/postref >}}index_files/dt-core-bootstrap4/js/dataTables.bootstrap4.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/dt-ext-responsive-bootstrap4/css/responsive.bootstrap4.min.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/dt-ext-responsive-bootstrap4/js/dataTables.responsive.min.js"></script>
<script src="{{< blogdown/postref >}}index_files/dt-ext-responsive-bootstrap4/js/responsive.bootstrap4.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/crosstalk/css/crosstalk.min.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/crosstalk/js/crosstalk.min.js"></script>
<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>
<link href="{{< blogdown/postref >}}index_files/datatables-css/datatables-crosstalk.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/datatables-binding/datatables.js"></script>
<script src="{{< blogdown/postref >}}index_files/jquery/jquery-3.6.0.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/dt-core-bootstrap4/css/dataTables.bootstrap4.min.css" rel="stylesheet" />
<link href="{{< blogdown/postref >}}index_files/dt-core-bootstrap4/css/dataTables.bootstrap4.extra.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/dt-core-bootstrap4/js/jquery.dataTables.min.js"></script>
<script src="{{< blogdown/postref >}}index_files/dt-core-bootstrap4/js/dataTables.bootstrap4.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/dt-ext-responsive-bootstrap4/css/responsive.bootstrap4.min.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/dt-ext-responsive-bootstrap4/js/dataTables.responsive.min.js"></script>
<script src="{{< blogdown/postref >}}index_files/dt-ext-responsive-bootstrap4/js/responsive.bootstrap4.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/crosstalk/css/crosstalk.min.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/crosstalk/js/crosstalk.min.js"></script>

Продолжаю свою серию заметок про хитрости работы с `ggplot2`, предыдущие заметки серии:

- [Трюки ggplot2 - легенда](/post/ggplot_legend/)
- [Неопределенность и бизнес](/post/business_uncertainty/)
- [Трюки ggplot2 - распределения️](/post/ggplot_distribution/)
- [Трюки ggplot2 - агрегирование](/post/ggplot_stack/)

## С новым 2023 годом 🎄

Встреча нового года традиционно подразумевает праздничный стол, на котором практически всегда будут присутствовать салат оливье и селедка под шубой (далее по тексту просто Оливье и Шуба). Относительная доступность ингредиентов и простота приготовления сделали эти салаты настолько популярными, что без них сложно представить новогодний стол семьи любого уровня достатка.

Популярность салатов стала настолько высокой, что даже экономисты обратили на это внимание и начали использовать их в качестве бенчмарка для оценки продовольственной инфляции. Действительно, продовольственная корзина, используемая в качестве ориентира для оценка пропорций потребления продукции для большинства людей носит абстрактный характер, но вот рецепты популярных салатов знает практически каждый. Поэтому инфляция посчитанная через салаты вызывает больший интерес и доверие со стороны населения чем индекс CPI.

В этой заметке я разберу структуру и динамику инфляции цен на Оливье и Шубу, попутно рассказав как можно работать с подписями для графиков `ggplot2`, а именно:

- Способы избежать наползания подписей друг на друга
- Работа с подписями-формулами

Необходимая подготовка:

``` r
library(thematic) # пакет для автоматической установки стилей графиков 
library(tidyverse) # набор пакетов по принципу "все включено", в который включен ggplot2
library(ggpp) # расширение для ggplot2
library(DT) # пакет создания интерактивных таблиц
library(ggpattern) # пакет для использования текстур в графиках ggplot2
library(magick) # пакет для работы с изображениями
library(patchwork) # пакет для составления композиций графиков

# Активируем тему для блога
thematic_rmd(bg = "#1D1E20", accent = "cyan", fg = "grey90", 
             font = font_spec("Roboto"), sequential = firatheme::firaPalette(100), 
             qualitative = palette.colors(palette = "Tableau")) 

# Сохраняем палитру в отдельную переменную
my_pal <- palette.colors(palette = "Tableau") %>% unname() 
```

## Визуализация рецептов 📋

Первое с чего нужно начать – это рецепты салатов. Немного покопавшись в интернете я нашел ресурс с удобным указанием ингредиентов в различных единицах измерений (штуки, граммы, килограммы) для [Оливье](https://1000.menu/cooking/34797-salat-olive-s-molochnoi-kolbasoi) и [Шубы](https://1000.menu/cooking/27805-salat-ryba-pod-shuboi)

Я сделал выбор рецепта приготовления для 4 порций: в данном случае важны пропорции, а не количество порций. Не исключаю, что существуют различные вариации на тему рецептов и каждая хозяйка может похвастать своим собственным секретным ингредиентом, но в данном случае желательно определить канонический набор, который имеет наиболее распространенное применение. Пожалуй, запишу рецепты в виде именованных векторов, с которыми потому будет очень удобно работать при вычислениях:

``` r
# Оливье 
olivier_rec <- c(0.3, 0.15, 0.3, 0.45, 0.3, 0.08, 0.08) %>% 
  set_names(c("Колбаса вареная, кг", "Горох и фасоль, кг", 
              "Яйца куриные, 10 шт.", "Картофель, кг", 
              "Овощи натуральные консервированные, маринованные, кг", 
              "Морковь, кг", "Майонез, кг"))

# Шуба
fur_herring_rec <- c(0.2, 0.3, 0.27, 0.32, 0.05, 0.07) %>% 
  set_names(c("Яйца куриные, 10 шт.", "Картофель, кг", 
              "Сельдь соленая, кг", "Свёкла столовая, кг", 
              "Морковь, кг", "Майонез, кг"))
```

К сожалению, соленых огурцов в данных РОССТАТа найти не удалось и пришлось использовать категорию *Овощи натуральные консервированные, маринованные*, которые являются более общей группой. Альтернативной опцией могли стать свежие огурцы, но являясь сезонным товаром, такой продукт хуже отражает реальное положение дел.

Теперь можно сделать визуализацию рецептов чтобы составить впечатление из чего сделаны салаты. Для того чтобы такая визуализация выгладила тематически и празднично я буду использовать пакет `ggpattern`, о котором долго рассказывать, но очень легко понять идею работы, если посмотреть результат:

``` r
# Салатные текстуры в виде простых картинок
salad_patterns <- c("olivie.jpeg", "herring.jpeg")

# Преобразование рецептов в табличку
salad_recipes <- full_join(enframe(fur_herring_rec, value = "Шуба", name = "Ингредиент"), 
                           enframe(olivier_rec, value = "Оливье", name = "Ингредиент"), 
                           by = "Ингредиент") %>%  
  pivot_longer(cols = 2:3, names_to = "Салат", values_to = "Состав") 

# Непосредственно график
ggplot(salad_recipes, aes(x = Ингредиент, y = Состав)) + 
  annotate("text_npc", npcx = .5, npcy = .5, alpha = .9, size = 15, 
             label = "InvestCookies.ru", color = "#1D1E20") + 
  geom_col_pattern(aes(pattern_filename = Салат),
                   pattern         = 'image',
                   pattern_type    = 'tile',
                   colour          = 'black',
                   pattern_filter  = 'box',
                   pattern_scale   = .5,
                   position = "dodge") + 
  scale_pattern_filename_discrete(choices = salad_patterns) + 
  labs(title = "Пропорция ингридиентов салатов", y = "Состав, кг")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-3-1.png" width="720" />
Все хорошо за исключением подписей, которые предательски заползают друг на друга, делая их не читаемыми. Существует несколько способов борьбы с таким нежелательным эффектом.

### Перевернуть координаты ↩️

В таких ситуация первым, что я рекомендую делать – это поменять оси `x` и `y` местами с помощью функции `coord_flip()`:

``` r
ggplot(salad_recipes, aes(x = Ингредиент, y = Состав)) + 
  annotate("text_npc", npcx = .5, npcy = .5, alpha = .9, size = 15, 
             label = "InvestCookies.ru", color = "#1D1E20") + 
  geom_col_pattern(aes(pattern_filename = Салат),
                   pattern         = 'image',
                   pattern_type    = 'tile',
                   colour          = 'black',
                   pattern_filter  = 'box',
                   pattern_scale   = .5,
                   position = "dodge") + 
  scale_pattern_filename_discrete(choices = salad_patterns) + 
  labs(title = "Пропорция ингридиентов салатов", y = "Состав, кг") + 
  coord_flip() # Магия тут
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-4-1.png" width="720" />
Выглядит значительно лучше: во всяком случае теперь график читаемый.

### Добавить уровни 🔀

Второй вариант – разбить подписи на уровни (ярусы) с помощью функции `guide_axis()`:

``` r
ggplot(salad_recipes, aes(x = Ингредиент, y = Состав)) + 
  annotate("text_npc", npcx = .5, npcy = .5, alpha = .9, size = 15, 
             label = "InvestCookies.ru", color = "#1D1E20") + 
  geom_col_pattern(aes(pattern_filename = Салат),
                   pattern         = 'image',
                   pattern_type    = 'tile',
                   colour          = 'black',
                   pattern_filter  = 'box',
                   pattern_scale   = .5,
                   position = "dodge") + 
  scale_pattern_filename_discrete(choices = salad_patterns) + 
  labs(title = "Пропорция ингридиентов салатов", y = "Состав, кг") + 
  guides(x = guide_axis(n.dodge = 2)) # Магия тут
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-5-1.png" width="720" />
График также стал более читабельным по сравнению с исходным вариантом, хотя из-за категории *Овощи натуральные консервированные, маринованные* выглядит не вполне симпатично.

### Повернуть подпись 🔄

Другим очень популярным, но не совсем удачным, на мой взгляд, вариантом – является поворот подписей на 45° или 90°:

``` r
ggplot(salad_recipes, aes(x = Ингредиент, y = Состав)) + 
  annotate("text_npc", npcx = .5, npcy = .5, alpha = .9, size = 15, 
             label = "InvestCookies.ru", color = "#1D1E20") + 
  geom_col_pattern(aes(pattern_filename = Салат),
                   pattern         = 'image',
                   pattern_type    = 'tile',
                   colour          = 'black',
                   pattern_filter  = 'box',
                   pattern_scale   = .5,
                   position = "dodge") + 
  scale_pattern_filename_discrete(choices = salad_patterns) + 
  labs(title = "Пропорция ингридиентов салатов", y = "Состав, кг") + 
  theme(axis.text.x = element_text(angle = 45)) # Магия тут
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-6-1.png" width="720" />

В данном случае текст наползает на график и, кроме того, заставляя читателя поворачивать голову на угол поворота надписи, что очевидно снижает читаемость графика 🙃

### Автоматический перенос ⤵️

Данный вариант не связан с возможностями `ggplot2`, но задействует функцию `stringr::str_wrap()`, которая получая на вход строку и желаемую длину переноса, делает этот самый перенос:

``` r
ggplot(salad_recipes, aes(x = str_wrap(Ингредиент, 10), y = Состав)) + # Магия тут
  annotate("text_npc", npcx = .5, npcy = .5, alpha = .9, size = 15, 
             label = "InvestCookies.ru", color = "#1D1E20") + 
  geom_col_pattern(aes(pattern_filename = Салат),
                   pattern         = 'image',
                   pattern_type    = 'tile',
                   colour          = 'black',
                   pattern_filter  = 'box',
                   pattern_scale   = .5,
                   position = "dodge") + 
  scale_pattern_filename_discrete(choices = salad_patterns) + 
  labs(title = "Пропорция ингридиентов салатов", y = "Состав, кг",  x = "Ингредиент")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-7-1.png" width="720" />
Весьма неплохо с учетом того, что не пришлось делать переносы руками в каждом отдельном случае, но всего лишь навсего была добавлена простая функция.

Очевидно, что идеальный результат может быть получен комбинированием вышеописанных вариантов, поэтому рекомендую с ними поиграть самостоятельно и попробовать найти свой наилучший рецепт.

## Подготовка данных 💾

После некоторой разминки можно переходить непосредственно к статистическим данным. В [прошлый раз](/post/ggplot_stack/#цены-на-жилье-) я рассказывал о пакете `fedstatAPIr`, который позволяет загружать данные с сайта РОССТАТа. Воспользовавшись этим удобным инструментом еще раз, я получил данные по ценам на различные виды товаров для РФ:

``` r
prices_origin <- fst::read_fst("data/price.fst")

slice_sample(prices_origin, n = 30) %>% # 30 случайных наблюдений
  datatable(style = 'bootstrap4',  extensions = 'Responsive', 
            options = list(pageLength = 5),
            caption = "Цены на товары")
```

<div id="htmlwidget-1" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-1">{"x":{"style":"bootstrap4","filter":"none","vertical":false,"extensions":["Responsive"],"caption":"<caption>Цены на товары<\/caption>","data":[["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30"],["Авторучка шариковая, шт.","Сапоги, ботинки для детей школьного возраста зимние с верхом из натуральной кожи, пара","Перевод денежных средств для зачисления на счет другого физического лица, услуга","Пальто женское демисезонное из шерстяных или полушерстяных тканей, шт.","Мотоцикл без коляски, скутер, шт.","Чайник стальной эмалированный, шт.","Миксер, блендер, шт.","Тетрадь школьная, шт.","Брюки мужские из джинсовой ткани (джинсы), шт.","Полуботинки мужские с верхом из искусственной кожи, пара","Велосипед для дошкольников, шт.","Холодильник двухкамерный, емкостью 250-350 л, импортный, шт.","Костюм трикотажный для детей дошкольного возраста, комплект","Кольцо обручальное золотое, грамм","Компьютер персональный переносной (ноутбук), шт.","Мясо индейки,кг","Простыня из хлопчатобумажной ткани, шт.","Сыры плавленые, кг","Обои виниловые, 10 м","Электроэнергия в квартирах с электроплитами за минимальный объем потребления, в расчете за 100 кВт.ч","Мойка из нержавеющей стали для кухни, шт.","Бюстгальтер, шт.","Напитки газированные, л","Наволочка из хлопчатобумажной ткани, шт.","Ремонт холодильников всех марок, один вид работы","Спички, коробок","Костюм-двойка мужской из шерстяных, полушерстяных или смесовых  тканей, шт.","Овощи замороженные, кг","Перчатки из натуральной кожи, пара","Проезд в троллейбусе, поездка"],["Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация"],["рубль","рубль","рубль","рубль","рубль","рубль","рубль","рубль","рубль","рубль","рубль","рубль","рубль","рубль","рубль","рубль","рубль","рубль","рубль","рубль","рубль","рубль","рубль","рубль","рубль","рубль","рубль","рубль","рубль","рубль"],["3,94","3683,38","175,83","5767,26","71202,52","1382","2990,85","7,54","1163,59","1758,14","2839,2","18264,75","343,68","379,47","23692,28","338,84","135,76","101,18","357,87","280,42","1511,16","883,52","17,42","58,51","1226,73","0,39","2001,73","307,46","1900,35","25,88"],["февраль","июль","май","июль","июнь","апрель","январь","апрель","сентябрь","декабрь","май","август","январь","август","январь","август","май","декабрь","январь","ноябрь","декабрь","февраль","июль","октябрь","август","сентябрь","апрель","май","июнь","октябрь"],["2004","2022","2014","2010","2020","2022","2021","2021","2007","2016","2010","2003","2005","2000","2013","2018","2007","2004","2013","2018","2008","2019","2007","2008","2012","2004","2001","2022","2019","2018"],["643","643","643","643","643","643","643","643","643","643","643","643","643","643","643","643","643","643","643","643","643","643","643","643","643","643","643","643","643","643"],["6606","4731","9855","4132","6803","6008","6426","6501","4117","4753","6802","6409","4417","7503","7032","119","4197","1202","7425","9473","7423","5401","3305","4196","9107","5701","4121","2631","5412","9213"]],"container":"<table class=\"table table-striped table-hover row-border order-column display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>s_grtov_title<\/th>\n      <th>s_OKATO_title<\/th>\n      <th>EI<\/th>\n      <th>ObsValue<\/th>\n      <th>PERIOD<\/th>\n      <th>Time<\/th>\n      <th>s_OKATO<\/th>\n      <th>s_grtov<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":5,"columnDefs":[{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false,"responsive":true,"lengthMenu":[5,10,25,50,100]}},"evals":[],"jsHooks":[]}</script>

Таким же образом, можно получить индекс цен, который используется для определения уровня инфляции (он же CPI):

``` r
CPI_origin <- fst::read_fst("data/CPI.fst")

slice_sample(CPI_origin, n = 30) %>% # 30 случайных наблюдений
  datatable(style = 'bootstrap4',  extensions = 'Responsive', 
            options = list(pageLength = 5),
            caption = "Цены на товары")
```

<div id="htmlwidget-2" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-2">{"x":{"style":"bootstrap4","filter":"none","vertical":false,"extensions":["Responsive"],"caption":"<caption>Цены на товары<\/caption>","data":[["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30"],["К соответствующему периоду предыдущего года","К соответствующему периоду предыдущего года","К соответствующему периоду предыдущего года","К соответствующему периоду предыдущего года","К соответствующему периоду предыдущего года","К соответствующему периоду предыдущего года","К соответствующему периоду предыдущего года","К соответствующему периоду предыдущего года","К соответствующему периоду предыдущего года","К соответствующему периоду предыдущего года","К соответствующему периоду предыдущего года","К соответствующему периоду предыдущего года","К соответствующему периоду предыдущего года","К соответствующему периоду предыдущего года","К соответствующему периоду предыдущего года","К соответствующему периоду предыдущего года","К соответствующему периоду предыдущего года","К соответствующему периоду предыдущего года","К соответствующему периоду предыдущего года","К соответствующему периоду предыдущего года","К соответствующему периоду предыдущего года","К соответствующему периоду предыдущего года","К соответствующему периоду предыдущего года","К соответствующему периоду предыдущего года","К соответствующему периоду предыдущего года","К соответствующему периоду предыдущего года","К соответствующему периоду предыдущего года","К соответствующему периоду предыдущего года","К соответствующему периоду предыдущего года","К соответствующему периоду предыдущего года"],["Все товары и услуги","Продовольственные товары (без алкогольных напитков)","Продовольственные товары (без алкогольных напитков)","Все товары и услуги","Все товары и услуги","Продовольственные товары (без алкогольных напитков)","Продовольственные товары (без алкогольных напитков)","Все товары и услуги","Все товары и услуги","Продовольственные товары (без алкогольных напитков)","Продовольственные товары (без алкогольных напитков)","Продовольственные товары (без алкогольных напитков)","Все товары и услуги","Все товары и услуги","Все товары и услуги","Все товары и услуги","Все товары и услуги","Все товары и услуги","Продовольственные товары (без алкогольных напитков)","Продовольственные товары (без алкогольных напитков)","Все товары и услуги","Все товары и услуги","Все товары и услуги","Все товары и услуги","Все товары и услуги","Продовольственные товары (без алкогольных напитков)","Продовольственные товары (без алкогольных напитков)","Все товары и услуги","Все товары и услуги","Все товары и услуги"],["Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация","Российская Федерация"],["процент","процент","процент","процент","процент","процент","процент","процент","процент","процент","процент","процент","процент","процент","процент","процент","процент","процент","процент","процент","процент","процент","процент","процент","процент","процент","процент","процент","процент","процент"],["111,63","110,19","103,67","113,97","108,29","107,13","119,75","110,92","106,57","105,23","119,52","108,2","109,36","103,53","113,16","111,87","116,04","106,85","109,75","111,15","107,5","114,86","106,43","105,13","102,49","112,12","114,8","106,1","106,02","103,38"],["август","декабрь","май","март","октябрь","апрель","июль","декабрь","декабрь","май","февраль","август","сентябрь","ноябрь","июль","декабрь","апрель","август","сентябрь","ноябрь","октябрь","сентябрь","сентябрь","май","ноябрь","октябрь","сентябрь","октябрь","май","сентябрь"],["2009","2003","2017","2009","2014","2013","2015","2005","2012","2007","2008","2007","2007","2019","2005","2007","2002","2016","2009","2003","2010","2002","2016","2019","2017","2003","2022","2016","2021","2018"],["643","643","643","643","643","643","643","643","643","643","643","643","643","643","643","643","643","643","643","643","643","643","643","643","643","643","643","643","643","643"],["9","9","9","9","9","9","9","9","9","9","9","9","9","9","9","9","9","9","9","9","9","9","9","9","9","9","9","9","9","9"],["1","5","5","1","1","5","5","1","1","5","5","5","1","1","1","1","1","1","5","5","1","1","1","1","1","5","5","1","1","1"]],"container":"<table class=\"table table-striped table-hover row-border order-column display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>s_POK_title<\/th>\n      <th>s_grtov_title<\/th>\n      <th>s_OKATO_title<\/th>\n      <th>EI<\/th>\n      <th>ObsValue<\/th>\n      <th>PERIOD<\/th>\n      <th>Time<\/th>\n      <th>s_OKATO<\/th>\n      <th>s_POK<\/th>\n      <th>s_grtov<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":5,"columnDefs":[{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false,"responsive":true,"lengthMenu":[5,10,25,50,100]}},"evals":[],"jsHooks":[]}</script>

Естественно, сведения, предоставленные РОССТАТом, не могут быть использованы в исходном виде и необходимо сделать некоторые преобразования чтобы стало возможным построение графиков.

Непосредственный расчет структуры себестоимости салатов я буду делать с помощью матричных операций. Во-первых это очень удобно и не требует писать тупого кода. Во-вторых матричные вычисления гораздо более быстрые в сравнении со стандартными функциями умножения и сложения. В-третьих не пропадать же добру: я уже подготовил рецепты в виде именованы векторов, которые чрезвычайно удобно преобразовать в матрицу и быстренько сделать расчеты.

Сейчас и далее в качестве примера я буду выводить табличку для Шубы т.к. для обоих салатов структура одинаковая:

``` r
# Функция преобразования формата дат РОССТАТа в общепринятый формат
month2date <- function(month, year, last_day = TRUE){
  
  date <- stringi::stri_c("01", month, year, sep = " ") |> 
    lubridate::parse_date_time(orders = c("dbY", "dBY"), locale = "ru_RU.UTF-8", train  = FALSE) 
  
  if_else(rep(last_day, length(date)), 
          stringi::stri_c(year, lubridate::month(date), lubridate::days_in_month(date), sep = "-") |> lubridate::as_date(),
          date |> lubridate::as_date()) 
}

# Необходимые преобразования для цен
prices <- as_tibble(prices_origin) %>% 
  select(s_grtov_title, ObsValue, PERIOD, Time) %>% 
  filter(s_grtov_title %in% c(names(fur_herring_rec), names(olivier_rec))) %>% 
  mutate(ObsValue = str_replace(ObsValue, ",", ".") %>%  as.numeric(), 
         date = month2date(PERIOD, Time)) %>% 
  pivot_wider(names_from = s_grtov_title, values_from = ObsValue) %>% 
  arrange(date)

# Необходимые преобразования для индекса инфляции
CPI <- mutate(CPI_origin, value = str_replace(ObsValue, ",", ".") %>%  as.numeric(),
              date = month2date(PERIOD, Time),
              value = round(value/100 - 1, 2)) %>% 
  select(date, value, s_grtov_title) %>% 
  drop_na() %>% 
  pivot_wider(id_cols = date, names_from = s_grtov_title, values_from = value) %>% 
  rename("CPI" = 2, "food_CPI" = 3)

# Табличка с годовыми значениями для Оливье, полученная матричным умножением
olivier_total <- (as.matrix(prices[names(olivier_rec)]) %*% as.matrix(olivier_rec)) %>% 
  as_tibble() %>% 
  set_names("total") %>% 
  bind_cols(prices[,3]) %>% 
  mutate(change = round(total/lag(total, 12) - 1, 2)) %>% 
  left_join(CPI, by = "date") %>% 
  filter(date > as.Date("2013-11-01"))

# Табличка с годовыми значениями для Шубы, полученная матричным умножением
fur_herring_total <- (as.matrix(prices[names(fur_herring_rec)]) %*% as.matrix(fur_herring_rec)) %>% 
  as_tibble() %>% 
  set_names("total") %>% 
  bind_cols(prices[,3]) %>% 
  mutate(change = round(total/lag(total, 12) - 1, 2)) %>% 
  left_join(CPI, by = "date") %>% 
  filter(date > as.Date("2013-11-01"))

slice_sample(fur_herring_total, n = 30) %>% # 30 случайных наблюдений
  datatable(style = 'bootstrap4',  extensions = 'Responsive', 
            options = list(pageLength = 5),
            caption = "Затраты на шубу")
```

<div id="htmlwidget-3" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-3">{"x":{"style":"bootstrap4","filter":"none","vertical":false,"extensions":["Responsive"],"caption":"<caption>Затраты на шубу<\/caption>","data":[["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30"],[114.9709,97.7105,97.0263,90.9299,97.8485,67.0243,93.5783,103.0051,97.159,90.8679,94.7538,126.4079,94.4604,68.3154,95.286,93.2717,152.2947,95.2854,93.3363,101.2142,152.6437,93.2249,115.661,88.582,91.0704,64.9413,93.2368,66.2555,128.5611,102.3087],["2021-09-30","2018-05-31","2018-08-31","2017-10-31","2018-04-30","2014-02-28","2016-04-30","2020-12-31","2016-07-31","2015-12-31","2017-01-31","2022-09-30","2020-01-31","2014-11-30","2018-03-31","2016-02-29","2022-05-31","2019-03-31","2016-03-31","2019-06-30","2022-04-30","2017-08-31","2021-08-31","2015-04-30","2017-11-30","2014-08-31","2019-11-30","2014-01-31","2021-12-31","2020-06-30"],[0.19,-0.02,0.04,-0.02,0.01,0.11,0.06,0.09,0.09,0.24,0.02,0.1,-0.01,0.05,0,0.09,0.23,-0,0.06,0.01,0.3,-0.01,0.18,0.27,-0.03,0.01,0.02,0.11,0.25,0.01],[0.07,0.02,0.03,0.03,0.02,0.06,0.07,0.05,0.07,0.13,0.05,0.14,0.02,0.09,0.02,0.08,0.17,0.05,0.07,0.05,0.18,0.03,0.07,0.16,0.02,0.08,0.04,0.06,0.08,0.03],[0.1,0,0.02,0.01,0.01,0.06,0.05,0.07,0.06,0.15,0.04,0.15,0.02,0.13,0.01,0.06,0.21,0.06,0.05,0.06,0.22,0.02,0.08,0.23,0.01,0.1,0.04,0.06,0.12,0.04]],"container":"<table class=\"table table-striped table-hover row-border order-column display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>total<\/th>\n      <th>date<\/th>\n      <th>change<\/th>\n      <th>CPI<\/th>\n      <th>food_CPI<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":5,"columnDefs":[{"className":"dt-right","targets":[1,3,4,5]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false,"responsive":true,"lengthMenu":[5,10,25,50,100]}},"evals":[],"jsHooks":[]}</script>

И далее после некоторых манипуляций с матрицами можно также легко посчитать структуру затрат на приготовление салатов:

``` r
# Матрица с рецептами Оливье (копирование вектора на длину матрицы цен)
olivier_rec_mtrx <- matrix(olivier_rec, ncol = length(olivier_rec), nrow = nrow(prices), byrow = TRUE)

# Умножение матрицы цен на матрицу рецепта Оливье
olivier_cost <- (as.matrix(prices[names(olivier_rec)]) * olivier_rec_mtrx) %>% 
  as_tibble() %>% 
  bind_cols(prices[, "date"])  %>% 
  drop_na() %>% 
  pivot_longer(cols = -date)

# Матрица с рецептами Шубы (копирование вектора на длину матрицы цен)
fur_herring_rec_mtrx <- matrix(fur_herring_rec, ncol = length(fur_herring_rec), nrow = nrow(prices), byrow = TRUE)

# Умножение матрицы цен на матрицу рецепта Шубы
fur_herring_cost <- (as.matrix(prices[names(fur_herring_rec)]) * fur_herring_rec_mtrx) %>% 
  as_tibble() %>% 
  bind_cols(prices[, "date"])  %>% 
  drop_na() %>% 
  pivot_longer(cols = -date)

slice_sample(fur_herring_cost, n = 30) %>% # 30 случайных наблюдений
  datatable(style = 'bootstrap4',  extensions = 'Responsive', 
            options = list(pageLength = 5),
            caption = "Структура затрат на шубу")
```

<div id="htmlwidget-4" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-4">{"x":{"style":"bootstrap4","filter":"none","vertical":false,"extensions":["Responsive"],"caption":"<caption>Структура затрат на шубу<\/caption>","data":[["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30"],["2016-10-31","2007-08-31","2012-10-31","2014-09-30","2012-06-30","2007-12-31","2000-09-30","2011-08-31","2021-09-30","2006-04-30","2003-10-31","2014-11-30","2005-01-31","2022-09-30","2015-05-31","2013-02-28","2013-09-30","2000-10-31","2019-02-28","2002-07-31","2021-12-31","2017-04-30","2005-05-31","2018-04-30","2014-10-31","2022-03-31","2019-03-31","2021-10-31","2001-02-28","2011-03-31"],["Майонез, кг","Морковь, кг","Свёкла столовая, кг","Морковь, кг","Морковь, кг","Сельдь соленая, кг","Майонез, кг","Яйца куриные, 10 шт.","Яйца куриные, 10 шт.","Майонез, кг","Свёкла столовая, кг","Свёкла столовая, кг","Свёкла столовая, кг","Морковь, кг","Сельдь соленая, кг","Морковь, кг","Картофель, кг","Яйца куриные, 10 шт.","Яйца куриные, 10 шт.","Яйца куриные, 10 шт.","Майонез, кг","Майонез, кг","Яйца куриные, 10 шт.","Свёкла столовая, кг","Сельдь соленая, кг","Майонез, кг","Морковь, кг","Сельдь соленая, кг","Свёкла столовая, кг","Яйца куриные, 10 шт."],[11.3785,1.063,5.7184,1.2735,1.573,20.2905,2.5431,6.804,14.074,4.0299,3.1552,7.0976,3.3728,1.7055,43.8534,1.3615,5.952,2.966,13.242,3.002,17.1388,11.4576,5.06,10.4064,33.7176,18.0096,1.867,59.4081,2.0384,7.906]],"container":"<table class=\"table table-striped table-hover row-border order-column display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>date<\/th>\n      <th>name<\/th>\n      <th>value<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":5,"columnDefs":[{"className":"dt-right","targets":3},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false,"responsive":true,"lengthMenu":[5,10,25,50,100]}},"evals":[],"jsHooks":[]}</script>

## Графики салатов 🥗

Теперь можно собрать все вместе и визуализировать структуру и динамику стоимости Оливье. В силу того, что самым свежим месяцем наблюдения – является ноябрь 2022 года, а данные по докторской колбасе доступны с начала 2014 года, можно сказать, что временные рамки графика определились сами собой.

Напомню, что пакет `patchwork` позволяет строить композиции из нескольких графиков. Верхним графиком в композиции будет выведена структура затрат, нормированная на 100%, где также выводится процентная динамика индексов инфляции в т.ч. индекса салата. Нижним графиком будут выведен слоеный “пирог” структуры затрат на приготовление салата в абсолютных ценах:

``` r
# В качестве отметки годовых значений используется ноябрь
olivier_nov <- filter(olivier_total, lubridate::month(date) == 11 & date > as.Date("2014-01-01")) 

# График структуры затрат
p1 <- olivier_cost %>% 
  ggplot(aes(date, value)) + 
  annotate("text_npc", npcx = .5, npcy = .5, alpha = .9, size = 15, 
             label = "InvestCookies.ru", color = "#1D1E20") + 
  geom_area(aes(fill = str_wrap(name, 30)), alpha = .5, position = "fill") + 
  geom_line(data = olivier_total, aes(y = CPI, linetype = "Широкий индекс"), col = "white") + 
  geom_line(data = olivier_total, aes(y = food_CPI, linetype = "Продуктовый индекс"), col = "white") + 
  geom_line(data = olivier_total, aes(y = change, linetype = "Индекс Оливье"), col = "white") + 
  scale_linetype_manual(values = c("Широкий индекс" = 1, "Продуктовый индекс" = 3, "Индекс Оливье" = 5)) +
  scale_y_continuous(labels = scales::label_percent()) + 
  coord_cartesian(expand = TRUE, xlim = c(as.Date("2014-11-01"), as.Date("2023-01-01"))) + 
  labs(col = "", fill = "", y = "Процент", linetype = "", x = "") + 
  guides(fill = guide_legend(direction = "vertical"), 
         linetype = guide_legend(direction = "vertical"), 
         col = guide_legend(direction = "vertical")) + 
  annotate(x = as.Date("2018-01-01"), y = .6, geom = "label", size = 3, color = "white", alpha = .5,
           label = "'Индекс Оливье за 8 лет: '*sqrt(frac(289, 168), 8) - 1 == 7.02*'%'", parse = TRUE) + 
  annotate(x = as.Date("2018-01-01"), y = .4, geom = "label", size = 3, color = "white", alpha = .5,
           label = paste0("Широкий индекс за 8 лет: ", round(mean(olivier_nov$CPI)*100, 2), "%")) + 
  annotate(x = as.Date("2018-01-01"), y = .3, geom = "label", size = 3, color = "white", alpha = .5,
           label = paste0("Продуктовый индекс за 8 лет: ", round(mean(olivier_nov$food_CPI)*100, 2), "%"))

# Абсолютная динамика затрат 
p2 <- olivier_cost %>% 
  ggplot(aes(date, value)) + 
  annotate("text_npc", npcx = .5, npcy = .5, alpha = .9, size = 15, 
             label = "InvestCookies.ru", color = "#1D1E20") + 
  geom_area(aes(fill = str_wrap(name, 30)), alpha = .5) + 
  geom_point(data = olivier_nov, 
             aes(y = total), alpha = .1, size = 10, color = "white") +
  geom_point(data = olivier_nov, 
             aes(y = total, color = if_else(change < 0, "Падение", "Рост")), alpha = .9, size = 2) +
  geom_label(data = olivier_nov, 
             aes(y = total, label = str_c(round(total), "₽"), 
                 color = if_else(change < 0, "Падение", "Рост")), alpha = .7, nudge_y = 10) + 
  scale_color_manual(values = c("Падение" = "seagreen", "Рост" = "firebrick")) +
  scale_y_continuous(labels = scales::label_comma(prefix = "₽")) +
  coord_cartesian(expand = TRUE, xlim = c(as.Date("2014-11-01"), as.Date("2023-01-01"))) + 
  labs(col = "", fill = "", y = "Стоимость", x = "") + 
  guides(fill = guide_legend(direction = "vertical"), 
         linetype = guide_legend(direction = "vertical"), 
         col = guide_legend(direction = "vertical"))

p1/p2 + plot_layout(guides = 'collect') + plot_annotation("Индекс Оливье") & theme(legend.position = "bottom") 
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-12-1.png" width="720" />

В самом центре я решил вывести информацию о индексах: широкого индекса, который собственно и используют для определения инфляции, продовольственного(продуктового) индекса, который, очевидно, связан с продовольственной инфляцией и собственноручно рассчитанный индекс Оливье. Кроме того, мне захотелось вывести рассчитанный индекс Оливье вместе с формулой расчета чтобы ни у кого не возникло сомнений как такой индекс был получен. Для того чтобы вывод формулы стал возможным в функции `annotate()` я **использовал трюк** с параметром `parse = TRUE`, который активирует интерпретацию значения в параметре `label` как объект `plotmath`.

График для Шубы абсолютно в такой же структуре:

``` r
# В качестве отметки годовых значений используется ноябрь
fur_herring_nov <- filter(fur_herring_total, lubridate::month(date) == 11 & date > as.Date("2014-01-01"))

# График структуры затрат
p3 <- fur_herring_cost %>% 
  ggplot(aes(date, value)) + 
  annotate("text_npc", npcx = .5, npcy = .5, alpha = .9, size = 15, 
             label = "InvestCookies.ru", color = "#1D1E20") + 
  geom_area(aes(fill = str_wrap(name, 30)), alpha = .5, position = "fill") + 
  geom_line(data = fur_herring_total, aes(y = CPI, linetype = "Широкий индекс"), col = "white") + 
  geom_line(data = fur_herring_total, aes(y = food_CPI, linetype = "Продуктовый индекс"), col = "white") + 
  geom_line(data = fur_herring_total, aes(y = change, linetype = "Индекс Шубы"), col = "white") + 
  scale_linetype_manual(values = c("Широкий индекс" = 1, "Продуктовый индекс" = 3, "Индекс Шубы" = 5)) +
  scale_y_continuous(labels = scales::label_percent()) + 
  coord_cartesian(expand = TRUE, xlim = c(as.Date("2014-11-01"), as.Date("2023-01-01"))) + 
  labs(col = "", fill = "", y = "Процент", linetype = "", x = "") + 
  guides(fill = guide_legend(direction = "vertical"), 
         linetype = guide_legend(direction = "vertical"), 
         col = guide_legend(direction = "vertical")) + 
  annotate(x = as.Date("2018-01-01"), y = .6, geom = "label", size = 3, color = "white", alpha = .5,
           label = "'Индекс Шубы за 8 лет: '*sqrt(frac(128, 68), 8) - 1 == 8.23*'%'", parse = TRUE) + 
  annotate(x = as.Date("2018-01-01"), y = .4, geom = "label", size = 3, color = "white", alpha = .5,
           label = paste0("Широкий индекс за 8 лет: ", round(mean(fur_herring_nov$CPI)*100, 2), "%")) + 
  annotate(x = as.Date("2018-01-01"), y = .3, geom = "label", size = 3, color = "white", alpha = .5,
           label = paste0("Продуктовый индекс за 8 лет: ", round(mean(fur_herring_nov$food_CPI)*100, 2), "%"))

# Абсолютная динамика затрат
p4 <- fur_herring_cost %>% 
  ggplot(aes(date, value)) + 
  annotate("text_npc", npcx = .5, npcy = .5, alpha = .9, size = 15, 
             label = "InvestCookies.ru", color = "#1D1E20") + 
  geom_area(aes(fill = str_wrap(name, 30)), alpha = .5) + 
  geom_point(data = fur_herring_nov, 
             aes(y = total), alpha = .1, size = 10, color = "white") +
  geom_point(data = fur_herring_nov, 
             aes(y = total, color = if_else(change < 0, "Падение", "Рост")), alpha = .9, size = 2) +
  geom_label(data = fur_herring_nov, 
             aes(y = total, label = str_c(round(total), "₽"), 
                 color = if_else(change < 0, "Падение", "Рост")), alpha = .7, nudge_y = 6) + 
  scale_color_manual(values = c("Падение" = "seagreen", "Рост" = "firebrick")) +
  scale_y_continuous(labels = scales::label_comma(prefix = "₽")) +
  coord_cartesian(expand = TRUE, xlim = c(as.Date("2014-11-01"), as.Date("2023-01-01"))) + 
  labs(col = "", fill = "", y = "Стоимость", x = "") + 
  guides(fill = guide_legend(direction = "vertical"), 
         linetype = guide_legend(direction = "vertical"), 
         col = guide_legend(direction = "vertical"))

p3/p4 + plot_layout(guides = 'collect') + plot_annotation("Индекс Шубы") & theme(legend.position = "bottom")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-13-1.png" width="720" />

## Шпаргалка по подписям-формулам 👨🏻‍🏫

Формулы можно выводить в различные элементы `ggplot2`, но конструкции, используемые для этого всегда разные, поэтому я решил свести эти знания в небольшую шпаргалку чтобы она была всегда под рукой:

| Место             | Функции                            | Конструкция               |
|-------------------|------------------------------------|---------------------------|
| Текстовые подписи | `geom_text()`, `annotate()`        | `parse = TRUE`            |
| Подписи осей      | `lab`, `xlab`, `ylab`              | `expression(R^2)`         |
| Фасеты            | `facet_grid`, `faсet_wrap`         | `labeller = label_parsed` |
| Легенда           | `scale_x_color`, `scale_x_fill`, … | `bquote(R^2 == .(value))` |

Далее график, наглядно демонстрирующий каким образом работают подписи-формулы в различных элементах:

``` r
data <- data.frame(x=c(1, 1), y=c(2, 2), f = factor(c("italic(R^2==0.1)","italic(R^2==0.2)")))

value1 <- 0.7
value2 <- 0.9
my_labs <- list(bquote(R^2==.(value1)), bquote(R^2==.(value2)))

ggplot(data, aes(x, y, col = f)) +
  geom_point() +
  geom_text(aes(x, y, label=f), parse = TRUE, nudge_y = 1) + # Формула в подписи
  facet_grid(~f, labeller = label_parsed) + # Формула в фасете
  scale_colour_manual(values=1:2, labels = my_labs) + # Формула в легенде
  xlab(expression(italic(R^2==0.5))) + # Формула в подписи оси 
  scale_x_continuous(labels = ~paste0(., "\u2211"), limits = c(0, 2)) + # Использование UNICODE символов в подписях оси
  labs(title = "\u2211\u2211\u2211") # Использование UNICODE символов в заголовке
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-14-1.png" width="720" />

И некоторые советы по работе с подписями и формулами:

- Справку для формул можно вывести с помощью команды `?plotmath`
- Рендеринг формул и специальных символов может отличаться в зависимости от графического движка, который используется см. настройки в RStudio: `Options -> Graphics -> Backend`. Для рендеринга данной заметки использовался движок `AGG`
- Возможно использовать одновременно обычный текстовый символ и объект `plotmath`, для чего необходимо использовать знак `*` при стыковке фрагментов и одноразовые кавычки внутри двойных кавычек для фрагментов обычного текста
- Специальные математические знаки UNICODE в большинстве случаев должны работать
- В качестве альтернативы для формирования подписей сложного форматирования в т.ч. формул существует пакет `ggtext`

## Салатное заключение 🍪

Теперь можно вернутся к салатам и сделать заключения на базе построенных графиков:

- Овощные ингредиенты вносят ощутимую сезонную составляющую в себестоимость салатов т.е. стоимость приготовления осенью и весной может ощутимо отличаться
- Индексы салатов накопленным эффектом: Оливье за 8 лет в среднем дорожал на **7.02%** ежегодно, а Селедка под шубой за 8 лет в среднем дорожала на **8.23%**, что соответствует продовольственной инфляции в среднем за 8 лет – **8.11%**. Другими словами Шуба в большей степени соответствует инфляции чем Оливье
- Динамика индекса Шубы более нервная тогда как индекс Оливье ведет себя более спокойно и в целом повторяет траекторию индекса продовольственной инфляции
- Структура затрат на салат Оливье не сильно изменилась за 8 прошедших лет тогда как для Шубы сельдь приобрела большую значимость в затратах в последнее время
- Наверное главный вывод, который можно сделать – это **отсутствие выявленных значимых расхождений между официальным индексом продовольственной инфляции и индексами салатов**. Другими словами, официальная оценка инфляции – выглядит адекватно и может быть использована в качестве ориентира для инвестиционных решений

Простой способ узнать о новых публикациях – подписаться на Telegram-канал:

<div class="telegram-icon" align="left">

<a href="https://t.me/investcookies" target="_blank" rel="noopener noreferrer me">
🍪🍪🪙 InvestCookies
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
    stroke-linecap="round" stroke-linejoin="round">
<path
        d="M21.198 2.433a2.242 2.242 0 0 0-1.022.215l-8.609 3.33c-2.068.8-4.133 1.598-5.724 2.21a405.15 405.15 0 0 1-2.849 1.09c-.42.147-.99.332-1.473.901-.728.968.193 1.798.919 2.286 1.61.516 3.275 1.009 4.654 1.472.509 1.793.997 3.592 1.48 5.388.16.36.506.494.864.498l-.002.018s.281.028.555-.038a2.1 2.1 0 0 0 .933-.517c.345-.324 1.28-1.244 1.811-1.764l3.999 2.952.032.018s.442.311 1.09.355c.324.022.75-.04 1.116-.308.37-.27.613-.702.728-1.196.342-1.492 2.61-12.285 2.997-14.072l-.01.042c.27-1.006.17-1.928-.455-2.474a1.654 1.654 0 0 0-1.034-.407z" />
</svg>
</a>

</div>
