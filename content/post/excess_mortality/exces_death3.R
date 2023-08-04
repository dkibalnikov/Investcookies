pop <- fst::read_fst("samples/stage/RST_43219.fst", as.data.table = TRUE)
male <- fst::read_fst("samples/stage/RST_31548.fst", as.data.table = TRUE)
female <- fst::read_fst("samples/stage/RST_33459.fst", as.data.table = TRUE)
dth <- fst::read_fst("samples/stage/RST_30974.fst", as.data.table = TRUE)

debug(fedstat_data_load_with_filters)
male <- fedstatAPIr::fedstat_data_load_with_filters("31548")
female <- fedstatAPIr::fedstat_data_load_with_filters("33459")
dth <- fedstatAPIr::fedstat_data_load_with_filters("30974")


dth1 <- as.data.table(dth)[.(s_vozr = "20-24", to = "20-24 лет"), on = "s_vozr", s_vozr := i.to][
  s_vozr %in% c("15-19 лет", "20-24 лет", "25-29 лет", "30-34 лет", "35-39 лет", "40-44 лет", "45-49 лет") & S_GRUP_2!="Оба пола" & s_mest !="все население" & s_OKATO_code=="643"][
    , .(year=as.integer(Time), s_vozr, S_GRUP_2, s_mest, value = as.double(ObsValue))] |>
  unique(by = c("s_vozr", "S_GRUP_2", "s_mest", "year"))

dth1 |> 
  ggplot(aes(year , value, col=s_vozr, group=s_vozr)) + 
  geom_line() +
  scale_x_continuous(n.breaks = 20) + 
  scale_y_continuous(labels = scales::label_comma(accuracy = 1, suffix = "‰"), n.breaks = 10) +
  facet_grid(S_GRUP_2~s_mest, scales = "free") + 
  scale_color_viridis_c()


dth1 |> 
  dcast(year+s_mest+s_vozr ~ S_GRUP_2) %>% 
  .[, ratio:=Мужчины/Женщины] %>% 
  ggplot(aes(year , ratio, col=s_vozr, group=s_vozr)) + 
  geom_line() +
  stat_smooth(data=~.[year<2020], method = "gam", fullrange = TRUE, lty = 5, size = .5) + 
  scale_x_continuous(n.breaks = 20) + 
  annotate(geom = "rect", xmin = 2019, xmax = 2023, ymin= -Inf, ymax = Inf, fill = "firebrick", alpha = .1) +
  scale_y_continuous(labels = scales::label_comma(accuracy = 1, suffix = "‰"), n.breaks = 10) +
  facet_grid(s_vozr~s_mest, scales = "free")


dth1 |> 
  dcast(year+s_mest+s_vozr ~ S_GRUP_2) %>% 
  .[, ratio:=Мужчины/Женщины] %>% 
  .[year<2020] |> 
  split(by=c("s_mest", "s_vozr"), drop = T, flatten=F, keep.by=F) |> 
  lapply(\(x)mgcv::gam(ratio ~ s(year, bs = "cs"), data = x[[1]][[1]]))



dth1 |> 
  dcast(year+s_mest+s_vozr ~ S_GRUP_2) %>% 
  .[, ratio:=Мужчины/Женщины] %>% 
  .[, ratio:=Мужчины/Женщины]



pop1 <- rbindlist(list(as.data.table(male)[,S_GRUP_2:="Мужчины"], 
                       as.data.table(female)[,S_GRUP_2:="Женщины"]))[, year:=as.integer(Time) - 1]  %>%  
  .[.(s_vozr = "20-24", to = "20-24 лет"), on = "s_vozr", s_vozr := i.to] %>% 
  .[s_vozr %in% c("15-19 лет", "20-24 лет", "25-29 лет", "30-34 лет", "35-39 лет", "40-44 лет", "45-49 лет") & S_GRUP_2!="Всего" & s_OKATO_code=="643"
    , .(year=as.integer(Time), s_vozr, S_GRUP_2, s_mest, value = as.double(ObsValue))] |>
  unique(by = c("s_vozr", "S_GRUP_2", "s_mest", "year"))


pop1 |>
  ggplot(aes(year, value, col=s_vozr, group=s_vozr)) + 
  geom_line() +
  facet_grid(S_GRUP_2~s_mest, scales = "free")



all <- merge(dth1, pop1, by = c("s_vozr", "S_GRUP_2", "s_mest", "year"), suffixes = c("_dth", "_pop"), all.x = TRUE)[
  , `:=`(chng = value_dth - shift(value_dth, 1)), by = c("s_vozr", "S_GRUP_2", "s_mest")]#[
    #, exces_rate:=chng*value_pop/1000]#[year == 2022& s_vozr %in% c("20-24 лет", "25-29 лет") & S_GRUP_2 == "Мужчины"]


all$exces_rate |> sum()

all[year>2010] |>
  ggplot(aes(year, deaths, col=s_vozr, group=s_vozr)) + 
  geom_line() +
  scale_x_continuous(n.breaks = 10) + 
  scale_y_continuous(labels = scales::label_comma(accuracy = 1, scale = 1e-3), n.breaks = 10) + 
  facet_grid(S_GRUP_2~s_mest, scales = "free") 
  
all[year > 2010 & s_vozr %in% c("20-24 лет", "25-29 лет", "30-34 лет", "35-39 лет")] |> 
  ggplot(aes(year, chng, col=s_vozr, group=s_vozr)) + 
  geom_line() +
  geom_point() +
  annotate(geom = "rect", xmin = 2019, xmax = 2021.5, ymin= -Inf, ymax = Inf, fill = "firebrick", alpha = .3) +
  annotate(geom = "rect", xmin = 2021.5, xmax = 2023, ymin= -Inf, ymax = Inf, fill = "firebrick", alpha = .5) +
  annotate(geom = "text", x = 2020.5, y = Inf, label = "COVID-19", col = "white", vjust = 1) +
  annotate(geom = "text", x = 2022.5, y = Inf, label = "СВО", col = "white", vjust = 1) +
  scale_y_continuous(labels = scales::label_comma(accuracy = .1), n.breaks = 10) + 
  scale_x_continuous(n.breaks = 10) + 
  facet_grid(S_GRUP_2~s_mest) 



library(xts)
help_xts <- xts(x = 1:20, order.by = seq(as.Date("2000-01-01"),length=20,by="years"))

dth_mdl <- dth1[year <2022 & year >1999, c( "year", "s_vozr", "S_GRUP_2", "s_mest", "value")][
  , year := as.Date(paste0(year, "-01-01"))][] |>
  split(by = c("s_vozr", "S_GRUP_2", "s_mest"), keep.by = FALSE) |> 
  lapply(\(x)as.xts(x) |> merge(help_xts) |> na.approx() %>% .[,1]|> coredata() |> ts(start=2000) |> HoltWinters(beta=FALSE, gamma=FALSE) |> predict(1) %>% as.data.table(.[1,])) |>
  rbindlist(idcol = "name") 

chng_mdl <- all[year < 2020 & year >1999, c( "year", "s_vozr", "S_GRUP_2", "s_mest", "chng")][
  , year := as.Date(paste0(year, "-01-01"))][] |>
  split(by = c("s_vozr", "S_GRUP_2", "s_mest"), keep.by = FALSE) |> 
  lapply(\(x)as.xts(x) |> merge(help_xts) |> na.approx() %>% .[,1]|> coredata() |> ts(start=2000) |> HoltWinters(beta=FALSE, gamma=FALSE) |> predict(4) %>% as.data.table(.[1,])) |>
  rbindlist(idcol = "name") 


dth_mdl[,c("s_vozr", "S_GRUP_2", "s_mest"):=tstrsplit(name, ".", fixed =TRUE)][,.(year = 2022, fit, s_vozr, S_GRUP_2, s_mest)] |>
  merge(all, all.y = TRUE, by = c("s_vozr", "S_GRUP_2", "s_mest", "year")) |> 
  ggplot(aes(year, y = value_dth/1000, col=s_vozr)) + 
  geom_line() +
  geom_point(aes(y = fit/1000)) +
  scale_x_continuous(n.breaks = 20) + 
  scale_y_continuous(labels = scales::label_percent(accuracy = .01), n.breaks = 10) +
  facet_grid(S_GRUP_2~s_mest, scales = "free") + 
  labs(title = "Избыточная смертность", subtitle = "Точкой показана инерционная смертность", col = "Возрастные\nгруппы", x = "Год", y = "Смертность (вероятность двинуть кони)")


chng_mdl1 <- chng_mdl[,c("s_vozr", "S_GRUP_2", "s_mest"):=tstrsplit(name, ".", fixed =TRUE)][,.(year = as.integer(rn)+2019, fit, s_vozr, S_GRUP_2, s_mest)] |>
  merge(all[year > 2010&s_vozr %in% c("20-24 лет", "25-29 лет", "30-34 лет", "35-39 лет", "40-44 лет", "45-49 лет")], all.y = TRUE, by = c("s_vozr", "S_GRUP_2", "s_mest", "year"))  %>% #View()
  .[, fit := fifelse(is.na(fit) & year>2018, chng, fit)] %>% 
  .[, comp:=fcase(year == 2022&!s_vozr %in% c("20-24 лет", "25-29 лет"), fit+shift(fit)-shift(chng) + 0.5*(shift(fit, 2)-shift(chng, 2)),
                  year == 2022&s_vozr %in% c("20-24 лет", "25-29 лет"), fit-.1,
                  default = NA)]  %>% 
  .[, comp := fifelse(is.na(comp) & year>2018, fit, comp)] 
  

chng_mdl1[S_GRUP_2 == "Женщины"] |> 
  ggplot(aes(year, y = chng, col=s_vozr, lty = "Факт")) + 
  geom_line() +
  geom_line(aes(y = fit, lty = "Модель\nинерции")) +
  geom_line(aes(y = comp, lty = "Модель\nкомпенсации")) +
  geom_point()+
  scale_x_continuous(n.breaks = 5, labels = scales::label_comma(accuracy = 1, big.mark = "")) + 
  scale_y_continuous(labels = scales::label_comma(accuracy = .01), n.breaks = 10) +
  scale_linetype_manual(values = c("Факт"=1, "Модель\nинерции"=2,"Модель\nкомпенсации"=3)) + 
  facet_grid(s_mest~s_vozr) + 
  labs(title = "Избыточная женская смертность", subtitle = "Точкой показана инерционная смертность", col = "Возрастные\nгруппы", x = "Год", y = "Смертность (вероятность двинуть кони)")

chng_mdl1[S_GRUP_2 == "Женщины"&year>2021][, err:=fit-chng][] |> 
  ggplot(aes(err)) +
  geom_histogram(bins = 8)


chng_mdl1[S_GRUP_2 == "Мужчины"] |> 
  ggplot(aes(year, y = chng, col=s_vozr, lty = "Факт")) + 
  geom_line() +
  geom_line(aes(y = fit, lty = "Модель\nинерции")) +
  geom_line(aes(y = comp, lty = "Модель\nкомпенсации")) +
  geom_point()+
  scale_x_continuous(n.breaks = 5, labels = scales::label_comma(accuracy = 1, big.mark = "")) + 
  scale_y_continuous(labels = scales::label_comma(accuracy = .01), n.breaks = 10) +
  scale_linetype_manual(values = c("Факт"=1, "Модель\nинерции"=2,"Модель\nкомпенсации"=3)) + 
  facet_grid(s_mest~s_vozr) + 
  labs(title = "Избыточная мужская смертность", subtitle = "Точкой показана инерционная смертность", col = "Возрастные\nгруппы", x = "Год", y = "Смертность (вероятность двинуть кони)")

chng_mdl1[year == 2022 & S_GRUP_2 == "Мужчины"][, exces_dth:=value_pop*(fit-comp)/1000][["exces_dth"]] |> sum()




res <- dth_mdl[,c("s_vozr", "S_GRUP_2", "s_mest"):=tstrsplit(name, ".", fixed =TRUE)][
  ,.(year = 2022, fit, s_vozr, S_GRUP_2, s_mest)] |>
  merge(all, all.x = TRUE, by = c("s_vozr", "S_GRUP_2", "s_mest", "year")) %>% 
  .[, `:=`(chng2 = deaths - fit*value_pop/1000)] %>% 
  .[!is.na(chng2) & s_vozr %in% c("20-24 лет", "25-29 лет") & S_GRUP_2 == "Мужчины", .(s_vozr, S_GRUP_2, s_mest, chng2)]

res[]
sum(res$)

tstrsplit("20-24 лет.Женщины.городское население", ".", fixed =TRUE)


load_all_log("RST_31557")
unify_data_log("RST_31557")