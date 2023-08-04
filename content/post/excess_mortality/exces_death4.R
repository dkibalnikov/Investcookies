library(tidyverse)



vozr <- c("10-14 лет", "15-19 лет", "20-24 лет", "25-29 лет", "30-34 лет", "35-39 лет", "40-44 лет", "45-49 лет", "50-54 лет", "55-59 лет", "60-64 лет", "65-69 лет", "70-74 лет", "75-79 лет")

dth1 <- as.tibble(dth) %>% 
  mutate(s_vozr = recode(s_vozr, "20-24" = "20-24 лет"),
         year=as.integer(Time), 
         value = as.double(ObsValue)) %>% 
  filter(s_vozr %in%  vozr & 
           S_GRUP_2!="Оба пола" & 
           s_mest !="все население" & 
           s_OKATO_code=="643") %>% 
  select(year, s_vozr, S_GRUP_2, s_mest, dth=value) %>% 
  distinct(s_vozr, S_GRUP_2, s_mest, year, .keep_all = TRUE)

pop1 <- rbind(as.tibble(male) %>% mutate(S_GRUP_2="Мужчины"), 
              as.tibble(female) %>% mutate(S_GRUP_2="Женщины")) %>% 
  mutate(s_vozr = recode(s_vozr, "20-24" = "20-24 лет", "5-9 лет"="05-9 лет"),
         year=as.integer(Time) - 1,
         year=as.integer(Time), 
         value = as.double(ObsValue)) %>% 
  filter(s_vozr %in% vozr & 
           s_mest !="все население" & 
           s_OKATO_code=="643") %>% 
  select(year, s_vozr, S_GRUP_2, s_mest, pop=value) %>% 
  distinct(s_vozr, S_GRUP_2, s_mest, year, .keep_all = TRUE)

dth1 |> 
  ggplot(aes(year, dth, col=s_vozr, group=s_vozr)) + 
  geom_line() +
  scale_x_continuous(n.breaks = 10) + 
  scale_y_continuous(labels = scales::label_comma(accuracy = 1, suffix = "‰"), n.breaks = 8) +
  facet_grid(S_GRUP_2~s_mest, scales = "free") + 
  scale_color_viridis_d() + 
  labs(title = "Смертность от всех причин для разных возрастных групп", y = "Смертность, промилле", x = "Год")


dth_ratio <- dth1 |> 
  pivot_wider(id_cols = c("year", "s_vozr", "s_mest"), names_from = "S_GRUP_2", values_from = "dth") %>% 
  mutate(ratio=Мужчины/Женщины)

dth_ratio %>% 
  ggplot(aes(year, ratio, col=s_vozr, group=s_vozr)) + 
  geom_line() +
  stat_smooth(data=~filter(., year<2022), method = "gam", fullrange = TRUE, lty = 5, size = .5, formula = y ~ s(x, bs = "cs", k=2)) + 
  scale_x_continuous(n.breaks = 20) + 
  annotate(geom = "rect", xmin = 2019, xmax = 2023, ymin= -Inf, ymax = Inf, fill = "firebrick", alpha = .1) +
  scale_y_continuous(labels = scales::label_comma(accuracy = .1), n.breaks = 8) +
  facet_grid(s_vozr~s_mest, scales = "free")

library(mgcv)
pred_period <- 1990:2023

mdl <- dth_ratio %>% 
  filter(year < 2022) %>% 
  nest_by(s_vozr, s_mest) %>% 
  mutate(mdl = list(gam(ratio ~ s(year, bs = "cs"), data=data) |> predict.gam(tibble(year=pred_period), se.fit = T)),
         fit = list(mdl$fit),
         upr = list(mdl$fit + 2*mdl$se.fit),
         lwr = list(mdl$fit - 2*mdl$se.fit)) %>% 
  reframe(year = pred_period, fit, upr, lwr)
  
full_join(dth_ratio, mdl, by = c("s_vozr", "s_mest", "year")) %>% 
  ggplot(aes(year, ratio, col=s_vozr)) +
  geom_line() +
  geom_line(aes(y = fit), lty = 5, size = .5) +
  geom_ribbon(aes(ymin = lwr, ymax = upr, fill=s_vozr), alpha = .2, col = NA) +
  scale_x_continuous(n.breaks = 20) + 
  annotate(geom = "rect", xmin = 2019, xmax = 2023, ymin= -Inf, ymax = Inf, fill = "firebrick", alpha = .1) +
  scale_y_continuous(labels = scales::label_comma(accuracy = .1), n.breaks = 8) +
  facet_grid(s_vozr~s_mest, scales = "free")



          
res <- full_join(dth_ratio, mdl, by = c("s_vozr", "s_mest", "year")) %>% 
  left_join(filter(pop1, S_GRUP_2 =="Мужчины"), by = c("s_vozr", "s_mest", "year"), suffix = c("", "")) %>% 
  filter(year==2022) %>% 
  mutate(delta = ratio-fit,
         exces_dth=delta*Женщины*pop/1000,
         exces_dth_upr=(ratio-lwr)*Женщины*pop/1000,
         exces_dth_lwr=(ratio-upr)*Женщины*pop/1000)

select(res, s_vozr, s_mest, exces_dth, exces_dth_upr, exces_dth_lwr) %>% 
  ggplot(aes(s_vozr, exces_dth, fill = s_mest)) + 
  geom_col()

select(res, s_vozr, s_mest, exces_dth, exces_dth_upr, exces_dth_lwr) %>% 
  filter(s_vozr %in% military_age) %>% 
  summarise(exces_dth = sum(exces_dth), exces_dth_upr=sum(exces_dth_upr), exces_dth_lwr=sum(exces_dth_lwr))

unmilitary_age <- c("05-9 лет", "10-14 лет", "45-49 лет", "50-54 лет", "55-59 лет", "60-64 лет", "65-69 лет", "70-74 лет", "75-79 лет")
military_age <- c("15-19 лет", "20-24 лет", "25-29 лет", "30-34 лет", "35-39 лет", "40-44 лет")

res1 %>% 
  ggplot(aes(s_vozr, delta, col = s_mest, group=s_mest)) + 
  geom_line() + 
  geom_point(data=~filter(., s_vozr%in% unmilitary_age)) + 
  stat_smooth(data=~filter(., s_vozr%in% unmilitary_age),  
              method = "gam", fullrange = TRUE, lty = 5, size = .5, formula = y ~ splines::ns(x, 4))


mdl_fix <- res %>% 
  mutate(age_lvl = factor(s_vozr)) %>% 
  filter(s_vozr%in% unmilitary_age) %>% 
  nest_by(s_mest) %>% 
  mutate(mdl = list(gam(delta ~ splines::ns(as.integer(age_lvl), 4), data=data) |> predict.gam(tibble(age_lvl=1:14), se.fit = T)),
         fix_fit = list(mdl$fit),
         fix_upr = list(mdl$fit + 2*mdl$se.fit),
         fix_lwr = list(mdl$fit - 2*mdl$se.fit)) %>% 
  reframe(age_lvl = 1:14, fix_fit, fix_upr, fix_lwr) %>% 
  mutate(s_vozr = factor(age_lvl, labels = vozr) %>% as.character()) %>% 
  select(-age_lvl)



res2 <- left_join(res, mdl_fix, by = c("s_mest", "s_vozr")) %>% 
  mutate(delta = ratio-fit-fix_fit,
         exces_dth=delta*Женщины*pop/1000,
         exces_dth_upr=(ratio-lwr-fix_lwr)*Женщины*pop/1000,
         exces_dth_lwr=(ratio-upr-fix_upr)*Женщины*pop/1000)
  

select(res2, s_vozr, s_mest, exces_dth, exces_dth_upr, exces_dth_lwr) %>% 
  filter(s_vozr %in% military_age) %>% 
  ggplot(aes(s_vozr, exces_dth, fill = s_mest)) + 
  geom_col()


select(res2, s_vozr, s_mest, exces_dth, exces_dth_upr, exces_dth_lwr) %>% 
  filter(s_vozr %in% military_age) %>% 
  summarise(exces_dth = sum(exces_dth), exces_dth_upr=sum(exces_dth_upr), exces_dth_lwr=sum(exces_dth_lwr))

