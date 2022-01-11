


# Download ----------------------------------------------------------------
# link_balance <- "https://www.cbr.ru/vfs/statistics/credit_statistics/bop/bal_of_payments_standart.xlsx"
# download.file(link_balance, "data/balance.xlsx")
# link_balance <- "https://www.cbr.ru/vfs/statistics/credit_statistics/iip/53-iip.xlsx"
# download.file(link_balance, "data/position.xlsx")
# reserve_week <- read_html("https://www.cbr.ru/hd_base/mrrf/mrrf_7d/") %>% 
#   html_table(fill = T) %>% 
#   .[[1]] %>% 
#   as_tibble(.name_repair = "unique") %>% 
#   mutate(Дата = as.Date(Дата, format = "%d.%m.%Y"),
#              Объем = str_replace(Объем, "\\,", "\\.") %>% as.numeric()*1e3)
# 
# write_rds(reserve_week, "content/post/ruble_truth/data/reserve_week.rds")


# Prepare -----------------------------------------------------------------
get_report <- function(set_report){
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
  
  report_xlsx <- list.files("data/") %>% 
    str_subset(set_report) %>% 
    str_subset("\\.xlsx")
  
  report_formats <- xlsx_formats(str_c("data", "/", report_xlsx))
  report_cells <- xlsx_cells(str_c("data", "/", report_xlsx), include_blank_cells = FALSE)
  
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

balance <- get_report("balance") %>% 
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
  ungroup()

position_lbls <- tibble(name = c("Активы", "Обязательства", "Чистая международная инвестиционная позиция", "Резервы"),
                        tech_name = c("assets", "liability", "position", "reserve"))

position <- get_report("position") %>% 
  get_lvl_value() %>% 
  clean_report() %>% 
  pivot_longer(-c(name, indent, matches("lvl")), names_to = "period") %>% 
  mutate(period = as.Date(period, format = "%Y-%m-%d"),
         date_qtr = zoo::as.yearqtr(period)) %>% 
  mutate(tech_name = recode(name, !!!deframe(position_lbls)), .before = everything()) %>%
  group_by(name) %>% 
  mutate(chng = value - lag(value, default = 0)) %>% 
  ungroup() 

reserve_week <- read_rds("data/reserve_week.rds")
