library(readxl)

years <- as.character(7:21) %>% 
  if_else(str_count(.) == 1, str_c("0", .), .)

map(years, ~download.file(str_c("http://www.cbr.ru/vfs/statistics/credit_statistics/loans/43-loans_", . , ".xls")
                          , destfile = str_c("~/Downloads/loans_by_countries/", ., ".xls")))



loans0 <- years %>% 
  map(~read_excel(str_c("~/Downloads/loans_by_countries/", ., ".xls"), skip = 4, col_types = c(rep("text", 4)))) %>% 
  set_names(years) %>% 
  bind_rows(.id = "year") %>% 
  rename(country = `...1`) 

loans1 <- loans0 %>% 
  filter(!is.na(country)) %>% 
  filter(!(is.na(Сальдо) | is.na(Привлечено) | is.na(Погашено))) %>% 
  mutate(across(3:5, ~str_remove_all(., "\\s") %>% str_trim() %>% as.numeric())) %>% 
  filter(!country %in% c("ВСЕГО", "По странам", "МЕЖДУНАРОДНЫЕ ОРГАНИЗАЦИИ")) %>% 
  group_by(country) %>% 
  mutate(cs_balance = cumsum(Сальдо),
         cs_borrow = cumsum(Привлечено))

countries_fcs <- filter(loans1, year == "21" & abs(cs_balance) > 1000) %>% pull(country)
countries_fcs <- filter(loans1, year == "21" & abs(cs_borrow) > 10000) %>% pull(country)

filter(loans1, country %in% countries_fcs) %>% 
  ggplot() + 
  geom_col(aes(x = year, y = cs_borrow, fill = reorder(country, cs_borrow))) + 
  scale_fill_manual(values = palette.colors(palette = "Alphabet") %>% unname())

filter(loans1, country %in% countries_fcs) %>% 
  ggplot() + 
  geom_col(aes(x = year, y = cs_balance, fill = reorder(country, cs_borrow))) + 
  scale_fill_manual(values = palette.colors(palette = "Alphabet") %>% unname())

