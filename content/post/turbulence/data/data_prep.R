library(cbr)
library(tidyverse)
library(fst)
library(quantmod)
library(xts)
library(eurostat)
library(rvest)
library(janitor)
library(tidyxl)
library(unpivotr)
# Currency ----------------------------------------------------------------
cbr_currency(currency = 'R01235',  from = '1991-01-01', to = "2022-05-18") %>% 
  select(2:3) %>% 
  mutate(curr = if_else(date <= as.Date("1997-12-30"), R01235/1000, R01235)) %>% 
  select(curr, date) %>% 
  write_fst("content/post/turbulence/data/currency.fst")


# EU trade ----------------------------------------------------------------
EU_import <- getSymbols("XTIMVA01EZM664S", src = "FRED", from = "2006-01-01", to = "2022-05-18", auto.assign = FALSE)
EU_export <- getSymbols("XTEXVA01EZM667S", src = "FRED", from = "2006-01-01", to = "2022-05-18", auto.assign = FALSE)

bind_cols(month = index(EU_export), import= as.vector(EU_import)/1e9, export = as.vector(EU_export)/1e9) %>% 
  mutate(import = -import, balance = export + import) %>% 
  write_fst("content/post/turbulence/data/EU_trade.fst")

# country based
dic <- search_eurostat("import")
eu_trade <- get_eurostat("namq_10_exi", type = "label")
EU_zone <- read_html("https://en.wikipedia.org/wiki/Eurozone") %>% 
  html_table() %>% 
  .[[3]] %>% 
  pull(State)

eu_trade %>% 
  filter(unit == "Current prices, million euro") %>% 
  filter(str_detect(s_adj, "Unadjusted")) %>% 
  filter(na_item == "Exports of goods and services to the European Union" | 
           na_item == "Imports of goods and services from the European Union") %>% 
  pivot_wider(id_cols = c("geo", "time"), names_from = na_item, values_from = values) %>% 
  rename("export" = 3, "import" = 4) %>% 
  mutate(geo = if_else(str_detect(geo, "Germany"), "Germany", geo), 
         import = -import,
         balance = export + import,
         zone = case_when(geo %in% EU_zone ~ "Еврозона", 
                          geo == "United Kingdom" ~ "Великобритания",
                          TRUE ~ "Прочие")) %>% 
  write_fst("content/post/turbulence/data/EU_trade_detailed.fst")
  

# Reservs -----------------------------------------------------------------
read_html("https://www.cbr.ru/hd_base/mrrf/mrrf_7d/") %>% 
  html_table(fill = T) %>%
  .[[1]] %>%
  as_tibble(.name_repair = "unique") %>%
  mutate(Дата = as.Date(Дата, format = "%d.%m.%Y"),
             Объем = str_replace(Объем, "\\,", "\\.") %>% as.numeric()*1e3) %>% 
  write_fst("content/post/turbulence/data/reserve_week.fst")


# Capitalization ----------------------------------------------------------
cap_size <- read_html("https://www.moex.com/a8135") %>% 
  html_table(fill = T) %>%
  .[[2]] %>% 
  clean_names() %>% 
  mutate(kapitalizacia_rub = str_remove_all(kapitalizacia_rub, " ") %>% str_replace(",", ".") %>% as.numeric())

sum(cap_size$kapitalizacia_rub, na.rm = TRUE)/1e12


# Balance  ----------------------------------------------------------------
link_balance <- "https://www.cbr.ru/vfs/statistics/credit_statistics/bop/bal_of_payments_standart.xlsx"
download.file(link_balance, "content/post/turbulence/data/balance.xlsx")
link_balance <- "https://www.cbr.ru/vfs/statistics/credit_statistics/iip/53-iip.xlsx"
download.file(link_balance, "content/post/turbulence/data/position.xlsx")

get_report <- function(set_report, path){
  #set_report <- "balance"
  if(set_report == "position"){
    set_col_num <- 1
    set_skip <- 3
  }else{
    if(set_report == "balance"){
      set_col_num <- 2
      set_skip <- 8 
    }else{
      stop("Choose one option: 'position' or 'balance'")
    }
  }
  
  report_xlsx <- list.files(str_c(path, "data/")) %>% 
    str_subset(set_report) %>% 
    str_subset("\\.xlsx")
  
  report_formats <- xlsx_formats(str_c(path, "data", "/", report_xlsx))
  report_cells <- xlsx_cells(str_c(path, "data", "/", report_xlsx), include_blank_cells = FALSE)
  
  report_indent <- report_cells %>% 
    slice(-c(1:set_skip)) %>%
    filter(!str_detect(character, "Остаток") | is.na(character)) %>% 
    filter(col == set_col_num) %>% 
    select(row, local_format_id) %>% 
    mutate(indent = report_formats$local$alignment$indent[local_format_id]) %>% 
    select(indent) 
  
  report_cells %>% 
    slice(-c(1:set_skip)) %>% 
    filter(!str_detect(character, "Остаток") | is.na(character)) %>% 
    behead(direction = "up", name = header) %>% 
    select(row, data_type, header, character, numeric) %>% 
    spatter(key = header) %>% 
    bind_cols(report_indent) %>%
    select(-row, name = `<NA>`, indent) %>% 
    mutate(name = str_trim(name))
}

#get section hirarhy
get_lvl_value <- function(set_df){
  lvls <- unique(set_df$indent) %>% 
    sort() 
  
  lvl_names <- str_c(lvls, "lvl")
  
  df <- matrix(NA_character_, nrow = nrow(set_df), ncol = length(lvl_names)) %>% 
    as_tibble() %>% 
    set_names(lvl_names) %>% 
    bind_cols(set_df)
  
  for(j in seq_along(lvls)){
    if(df$indent[1] == lvls[j]){df[1, j] <- df$name[1]} else{df[1, j] <- NA}
    for(i in 2:nrow(df)){
      if(df$indent[i] == lvls[j]){df[i, j] <- df$name[i]}
      else{
        if(df$indent[i] > lvls[j]){
          df[i, j] <- df[i-1, j]}
        else{df[i, j] <- NA}
      }
    }
  }
  df
}

clean_report <- . %>% 
  mutate(across(!c(matches("lvl"), "name", "indent"), ~replace(., is.na(.) | . == "..." , "0") %>% as.numeric())) %>% 
  rowwise() %>% 
  mutate(total = sum(c_across(!c(matches("lvl"), "name", "indent")))) %>% 
  filter(abs(total) > 0.2) %>% 
  ungroup() %>% 
  select(-total)

balance_lbls <- tibble(name = c("Чистые ошибки и пропуски", "Cальдо финансового счета", "Cальдо счета текущих операций", "Резервные активы", "Остаток"),
                       tech_name = c("err_saldo", "fin_saldo", "op_saldo", "reserve_saldo",  "residual"))

get_report("balance", "content/post/turbulence/") %>% 
  get_lvl_value() %>% 
  clean_report() %>% 
  janitor::remove_empty(which = "cols") %>% 
  select(matches("lvl"), name, indent, matches("квартал")) %>% 
  pivot_longer(-c(name, indent, matches("lvl")), names_to = "period") %>% 
  mutate(date_qtr = zoo::as.yearqtr(period, format = "%q квартал %Y г."), 
         tech_name = case_when(str_detect(name, "сальдо счета текущих операций") ~ "op_saldo",
                               str_detect(name, "сальдо финансового счета") ~ "fin_saldo",
                               str_detect(name, "Чистые ошибки и пропуски") ~ "err_saldo",
                               name == "Резервные активы" ~ "reserve_saldo",
                               TRUE ~ name)) %>% 
  arrange(date_qtr) %>% 
  group_by(across(matches("lvl")), name) %>% 
  mutate(value_csum = cumsum(value)) %>% 
  ungroup()  %>% 
  write_fst("content/post/turbulence/data/balance.fst")

position_lbls <- tibble(name = c("Активы", "Обязательства", "Чистая международная инвестиционная позиция", "Резервы"),
                        tech_name = c("assets", "liability", "position", "reserve"))

get_report("position","content/post/turbulence/") %>% 
  get_lvl_value() %>% 
  clean_report() %>% 
  pivot_longer(-c(name, indent, matches("lvl")), names_to = "period") %>% 
  mutate(period = as.Date(period, format = "%Y-%m-%d"),
         date_qtr = zoo::as.yearqtr(period)) %>% 
  mutate(tech_name = recode(name, !!!deframe(position_lbls)), .before = everything()) %>%
  group_by(name) %>% 
  mutate(chng = value - lag(value, default = 0)) %>% 
  ungroup() %>% 
  write_fst("content/post/turbulence/data/position.fst")





