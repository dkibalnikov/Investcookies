library(fedstatAPIr)
library(rvest)
library(tidyverse)


# Russia stat -------------------------------------------------------------
ru_injuries0 <- fedstat_data_load_with_filters("36234")
ru_deaths0 <- fedstat_data_load_with_filters("36233")
ru_population0 <- fedstat_data_load_with_filters("31557")

fst::write_fst(ru_injuries0, "content/post/traffic_safety/data/ru_injuries0.fst")
fst::write_fst(ru_deaths0, "content/post/traffic_safety/data/ru_deaths0.fst")
fst::write_fst(ru_population0, "content/post/traffic_safety/ru_data/population0.fst")




ru_population0 <- fst::read_fst("content/post/traffic_safety/data/ru_population0.fst")

ru_population <- mutate(ru_population0, rgn = str_replace(s_OKATO_code, "0$", "01")) %>% 
  filter(s_mest == "все население" & Time > 2009 &
           s_OKTMO == "Раздел 1. Муниципальные образования субъектов Российской Федерации") %>% 
  mutate(population = as.integer(ObsValue), year = as.integer(Time)) %>% 
  select(year, population, rgn)

months <- c("январь", "февраль", "март", "апрель", "май", "июнь", "июль", "август", "сентябрь", "октябрь", "ноябрь", "декабрь")
regs <- c("400000000001", "410000000001", "450000000001","460000000001", "030000000001", "643")

# Активируем тему для блога
thematic::thematic_rmd(bg = "#1D1E20", accent = "cyan", fg = "grey90", 
                       font = thematic::font_spec("Roboto"), sequential = firatheme::firaPalette(100), 
                       qualitative = palette.colors(palette = "Tableau")) 

# Сохраняем палитру в отдельную переменную
my_pal <- palette.colors(palette = "Tableau") %>% unname() 

my_ggplot <- function(dt, ...){
  ggplot(dt, ...) +
    ggpp::annotate("text_npc", npcx = .5, npcy = .5, alpha = .9, size = 10, label = "InvestCookies.ru", color = "#1D1E20")
}

ru_injuries0 <- fst::read_fst("content/post/traffic_safety/data/ru_injuries0.fst")

injuries <- ru_injuries0 %>% 
  mutate(year = as.integer(Time), 
         month = str_remove(PERIOD, "январь-") %>% factor(levels = months) %>% as.numeric()) %>% 
  group_by(Time, p3.1) %>% 
  mutate(injury = as.integer(ObsValue) - lag(as.numeric(ObsValue), default = 0)) %>% 
  left_join(ru_population, by = c("year", "p3.1_code" = "rgn")) %>% 
  mutate(injury_rate = injury*1e6/population) %>% 
  ungroup() %>% 
  select(year, month, injury, injury_rate, rgn = p3.1_code, rgn_name = p3.1)

injuries_fltrd <- filter(injuries, rgn %in% regs) 

my_ggplot(injuries_fltrd, aes(month, injury_rate)) + 
  geom_line(aes(color = year, group = year), size = 1, alpha = .5) + 
  scale_x_continuous(labels = months, breaks = 1:12) +
  facet_wrap(~rgn_name, scales = "free", ncol = 1) + 
  ggrepel::geom_label_repel(data = filter(injuries_fltrd, month == 11), max.overlaps = 10, alpha = .7,
                            aes(x = 11, group = year, label = year, color = year)) + 
  stat_summary(aes(linetype = "Среднее"), geom = "line", fun = "mean", size = 1, col = "firebrick") +
  scale_color_steps(breaks = 2010:2022, low = "orange", high = "cyan") + 
  scale_linetype_manual(values = c("Среднее" = 5)) + 
  theme(legend.key.width = unit(2.2, "cm"), legend.position = "bottom") + 
  labs(title = "Количество ДТП с пострадавшими на 1 млн. населения", caption = "Источник: РОССТАТ", linetype = "", color = "Год", x = "Месяц")


ru_deaths0 <- fst::read_fst("content/post/traffic_safety/data/ru_deaths0.fst")

deaths <- ru_deaths0 %>% 
  mutate(year = as.integer(Time), 
         month = str_remove(PERIOD, "январь-") %>% factor(levels = months) %>% as.numeric()) %>% 
  group_by(Time, p3.1) %>% 
  mutate(death = as.integer(ObsValue) - lag(as.numeric(ObsValue), default = 0)) %>% 
  left_join(ru_population, by = c("year", "p3.1_code" = "rgn")) %>% 
  mutate(death_rate = death*1e6/population) %>% 
  ungroup() %>% 
  select(year, month, death, death_rate, rgn = p3.1_code, rgn_name = p3.1)


deaths_fltrd <- filter(deaths, rgn %in% regs)

my_ggplot(deaths_fltrd, aes(month, death_rate)) + 
  geom_line(aes(color = year, group = year), size = 1, alpha = .5) + 
  scale_x_continuous(labels = months, breaks = 1:12) +
  ggrepel::geom_label_repel(data = filter(deaths_fltrd, month == 11), max.overlaps = 10, alpha = .7,
                            aes(x = 11, group = year, label = year, color = year)) + 
  stat_summary(aes(linetype = "Среднее"), geom = "line", fun = "mean", size = 1, col = "firebrick") +
  facet_wrap(~rgn_name, scales = "free", ncol = 1) + 
  scale_color_steps(breaks = 2010:2022, low = "orange", high = "cyan") + 
  scale_linetype_manual(values = c("Среднее" = 5)) + 
  theme(legend.key.width = unit(2.2, "cm"), legend.position = "bottom") + 
  labs(title = "Число лиц, погибших в ДТП", caption = "Источник: РОССТАТ", linetype = "", color = "Год", x = "Месяц")


# Turk stat ---------------------------------------------------------------

trk_population_wiki0 <- rvest::read_html("https://en.wikipedia.org/wiki/Demographics_of_Turkey") %>% 
  rvest::html_table() %>% .[[7]] %>% 
  select(year = 1, population = 2) %>% 
  filter(year > 2009) %>% 
  mutate(population = str_remove_all(population, ",|\\(e\\)") %>%  as.integer())

fst::write_fst(trk_population_wiki0, "content/post/traffic_safety/data/trk_population_wiki0.fst")

trk_population_rgn <- readxl::read_excel("content/post/traffic_safety/data/trk_population_stat0.xls", sheet = "t1", skip = 3) %>% 
  select(rgn = 1, `2020` = 2, `2021` = 3) %>% 
  drop_na() %>% 
  pivot_longer(cols = 2:3, names_to = "year", values_to = "population") 

trk_population_rgn <- readxl::read_excel("content/post/traffic_safety/data/trk_population_stat0.xls", sheet = "t1", skip = 3) %>% 
  select(rgn = 1, `2020` = 2, `2021` = 3) %>% 
  drop_na() %>% 
  pivot_longer(cols = 2:3, names_to = "year", values_to = "population") %>% 
  mutate(year = as.integer(year))

trk_traffic_year <- readxl::read_excel("content/post/traffic_safety/data/trk_traffik_stat0.xls", sheet = "t1", skip = 9) %>% 
  select(year = 1, 4, death = 6) %>% 
  mutate(year = as.integer(year)) %>% 
  drop_na()

trk_traffic_rgn1 <- readxl::read_excel("content/post/traffic_safety/data/trk_traffik_stat0.xls", sheet = "t3", skip = 5) %>% 
  select(rgn = 1, injury = 4, death = 5) %>% 
  drop_na()

trk_traffic_rgn2 <- readxl::read_excel("content/post/traffic_safety/data/trk_traffik_stat0.xls", sheet = "t3", skip = 3) %>% 
  select(rgn = 11, injury = 14, death = 15) %>% 
  drop_na()

fix_trk_rgn <- c("K.Maraş" = "Kahramanmaraş", "Ş.Urfa" = "Şanlıurfa")

trk_traffic_rgn <- bind_rows(trk_traffic_rgn1, trk_traffic_rgn2) %>% 
  mutate(rgn_name = recode(rgn, !!!fix_trk_rgn)) %>% 
  left_join(filter(trk_population_rgn, year == 2021), by = "rgn") %>% 
  mutate(across(c("injury", "death"), ~.*1e6/population, .names = "{.col}_rate"))


# Climate stats -----------------------------------------------------------

links <- c("https://meteoinfo.ru/categ-articles/15-climate-cat/klimaticheskie-normy/clim-towns",
           str_glue("https://meteoinfo.ru/categ-articles/15-climate-cat/klimaticheskie-normy/clim-towns?start={1:8}0"))


climate_htmls <- map(links, read_html)
climate_tbls <- map(climate_htmls, ~html_table(., header = TRUE))
climate_cities <- map(climate_htmls, ~html_elements(., css = "h2") %>% html_text() %>% str_trim())

climate_tbl <- climate_tbls %>% 
  flatten() %>% 
  keep(~any("Месяц" %in% names(.))) %>% 
  map(~janitor::remove_empty(., which = c("rows", "cols"))) %>% 
  map(~rename(., month = 1, night_temp = 2, day_temp = 3, mean_rain = `Средняя сумма осадков`)) %>% 
  map(~rename_with(., ~str_replace(., "Среднее число днейс осадками более 0.1 мм|Среднее число дней с осадками более 0.1 мм", "mean_rain_day"))) %>% 
  map(~select(., month, night_temp, day_temp, mean_rain, mean_rain_day)) %>% 
  set_names(unlist(climate_cities)[-1]) %>% 
  map_dfr(~., .id = "city") %>% 
  filter(month != "Месяц") %>% 
  mutate(across(3:6, as.double))

OKATO <- read_html("https://classifikators.ru/okato") %>% 
  html_table() %>% 
  .[[1]]

OKATO_code <- OKATO %>% 
  mutate(rgn = str_remove_all(Код, " "), 
         city = str_remove(`Административный центр`, "г ")) %>% 
  select(rgn, city) %>% 
  filter(city != "") #%>% 
  #add_row(rgn = "710000000001", city = "Салехард")

fix_cities <- c("Н.Новгород" = "Нижний Новгород", "С.-Петербург" = "Санкт-Петербург", 
                "Петропавловск- Камчатский" = "Петропавловск-Камчатский", 
                "Новгород" = "Великий Новгород")

climate <- climate_tbl %>% 
  mutate(city = recode(city, !!!fix_cities)) %>% 
  left_join(OKATO_code, by = "city") %>%
  filter(!is.na(city)) %>% 
  mutate(rgn = str_replace(rgn, "0$", "01")) %>% 
  group_by(rgn) %>% 
  summarise(across(-c("city", "month"), mean), .groups = "drop") %>% 
  drop_na()


# All together ------------------------------------------------------------


trk_stats <- trk_traffic_year %>% 
  left_join(trk_population_wiki0, by = "year") %>% 
  mutate(rgn_name = "Турция")


ru_stats <- deaths %>% 
  left_join(injuries, by = c("year", "month", "rgn", "rgn_name")) %>% 
  group_by(rgn, rgn_name, year) %>% 
  summarise(across(c("injury", "death"), sum), .groups = "drop") %>% 
  left_join(ru_population, by = c("year", "rgn"))


filter(ru_stats, rgn %in% regs) %>% 
  bind_rows(trk_stats) %>% 
  mutate(across(c("injury", "death"), ~.*1e6/population, .names = "{.col}_rate")) %>% 
  pivot_longer(cols = c(injury_rate, death_rate), names_to = "rate_type", values_to = "rate_value") %>% 
  select(year, rgn_name, rate_type,  rate_value) %>% 
  filter(year < 2022) %>% 
  my_ggplot(aes(year, rate_value, fill = rgn_name)) + 
  geom_col(alpha = .5) + 
  facet_grid(rate_type ~ rgn_name, scales = "free", 
             labeller = labeller(rate_type = c("death_rate" = "Смертность", "injury_rate" = "Травматизм"),
                                 rgn_name = ~str_wrap(., 17, whitespace_only = FALSE))) + 
  labs(title = "Смертность - количество погибших в результате ДТП \nТравматизм - количество ДТП с пострадавшими ", 
       y = "Количество на 1 млн. населения", x = "Год", fill = "", caption = "Источники: РОССТАТ, TURKSTAT") + 
  scale_x_continuous(breaks = 2009+2*(1:6)) +
  theme(legend.position = "bottom", axis.text.x = element_text(angle = 45))



fix_rgn <- c("030000000001" = "Краснодарский край", "410000000001" = "СПб+ЛО", "400000000001" = "СПб+ЛО",
             "460000000001" = "Москва + МО", "450000000001" = "Москва + МО", 
             "643" = "Российская федерация")


ru_stats <- deaths %>% 
  left_join(injuries, by = c("year", "month", "rgn", "rgn_name")) %>% 
  group_by(rgn, rgn_name, year) %>% 
  summarise(across(c("injury", "death"), sum), .groups = "drop") %>% 
  left_join(ru_population, by = c("year", "rgn"))

ru_stats_fixed <- ru_stats %>% 
  mutate(rgn_name = recode(rgn, !!!fix_rgn)) %>% 
  filter(rgn_name %in% fix_rgn) %>% 
  group_by(rgn_name, year) %>% 
  summarise(across(c("injury", "death", "population"), sum), .groups = "drop") 

ru_stats_fixed %>% 
  bind_rows(trk_stats) %>% 
  mutate(across(c("injury", "death"), ~.*1e6/population, .names = "{.col}_rate")) %>% 
  pivot_longer(cols = c(injury_rate, death_rate), names_to = "rate_type", values_to = "rate_value") %>% 
  select(year, rgn_name, rate_type,  rate_value) %>% 
  filter(year < 2022) %>% 
  my_ggplot(aes(year, rate_value, fill = rgn_name)) + 
  geom_col(alpha = .5) + 
  facet_grid(rate_type ~ rgn_name, scales = "free", 
             labeller = labeller(rate_type = c("death_rate" = "Смертность", "injury_rate" = "Травматизм"),
                                 rgn_name = ~str_wrap(., 17, whitespace_only = FALSE))) + 
  labs(title = "Смертность - количество погибших в результате ДТП \nТравматизм - количество ДТП с пострадавшими ", 
       y = "Количество на 1 млн. населения", x = "Год", fill = "", caption = "Источники: РОССТАТ, TURKSTAT") + 
  scale_x_continuous(breaks = 2009+2*(1:6)) +
  theme(legend.position = "bottom", axis.text.x = element_text(angle = 45))



traffik_all <- trk_traffic_rgn %>% 
  mutate(country = "Турция") %>% 
  filter(rgn %in% c("Antalya", "İzmir", "İstanbul")) %>% 
  bind_rows(filter(ru_stats_fixed, year == 2021 & rgn_name != "Российская федерация")) %>% 
  mutate(across(c("injury", "death"), ~.*1e6/population, .names = "{.col}_rate")) %>% 
  replace_na(list(country = "Россия")) 


p1 <- my_ggplot(traffik_all, aes(reorder(rgn_name, death_rate), death_rate, fill = country)) + 
  geom_col() +
  coord_flip()

p2 <- my_ggplot(traffik_all, aes(reorder(rgn_name, injury_rate), injury_rate, fill = country)) + 
  geom_col() +
  coord_flip()

p1+p2

