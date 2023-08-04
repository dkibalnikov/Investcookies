library(janitor)
library(quantmod)
library(rusquant)
library(xml2)
library(furrr)

plan(multisession, workers = 6)

# Функция для извлечение информации по тикеру 
get_tickers_info <- function(){
  ticker_xml <- read_html("https://smart-lab.ru/q/shares")
  sector_xml <- xml_find_all(ticker_xml, xpath = "//*[@id='sector_id']")|> 
    xml_children() 
  
  sectors_tbl <- data.table(id = xml_attr(sector_xml, "value"), name=xml_text(sector_xml))[1:26]
  
  get_info <- function(pos, sectors=sectors_tbl){
    # pos <- 1
    # browser()
    link <- paste0("https://smart-lab.ru/q/shares/?sector_id%5B%5D=", sectors[pos][["id"]]) 
    xml <-  read_html(link)
    
    dt <- rvest::html_table(xml, convert = "")[[1]] |>
      clean_names() |>
      as.data.table() |>
      _[no!="Какие акции стоит купить?"] 
    
    x_cols <- stri_subset(names(dt),  regex ="x_[1-9]?|x$")
    perc_cols <- stri_subset(str = names(dt), regex ="percent|izm_ob_ema")
    num_cols <- names(dt)[which(!names(dt) %in% c(x_cols, "nazvanie", "tiker"))]
    dt[, -x_cols, with = FALSE][ 
      , (perc_cols):=lapply(.SD, \(x)(stri_replace_all(x, regex = "%", replacement = "") |> as.double())/100), .SDcols=perc_cols][
        , (num_cols):=lapply(.SD, \(x)stri_replace_all(x, fixed = " ", "")|> as.double()), .SDcols=num_cols][
          , industry:=sectors[pos][["name"]]][]
  }
  
  
  furrr::future_map(seq_along(sectors_tbl$id), get_info, .progress = T) |>
    rbindlist(use.names = TRUE, fill = TRUE)
}
ticks_info <- get_tickers_info()

# Функция для извлечение полезной информации по тикеру
get_stats <- function(ticker){
  # ticker <- "YAKG"
  # ticker <- "LKOH"
  # browser()
  link <- paste0("https://smart-lab.ru/q/", ticker, "/f/y/")
  stat_tbls <- try(rvest::read_html(link) |> rvest::html_table(header = FALSE, na.strings = ""), silent = T)
  
  if(length(stat_tbls) < 1) return(NULL)
  else if(stat_tbls[1] == "Error in open.connection(x, \"rb\") : HTTP error 404.\n") return(NULL)
  else{
    stat1 <- as.data.table(stat_tbls[[1]]) |>
      _[-(1:2), lapply(.SD, \(x)stri_replace_all(x, regex = "\\t|\\n", ""))] |>
      remove_empty(which="rows") 
    
    nms <- stat1[1] |> unlist() |>  as.vector() 
    nms[1] <- "key"
    
    setnames(stat1, new = nms)
    
    stat2 <- stat1[2:51, .SD, .SDcols = stri_subset(nms, regex = "key|\\d{4}") |> na.omit()][
      !is.na(key) & !key%in%c("Финансовый отчет", "Годовой отчет", "Презентация") & !key%like%"структура и состав акционеров"] |> 
      melt(id.vars = "key", variable.name = "year") |> 
      dcast(year~key) |>
      clean_names()
    
    perc_cols <- stri_subset(names(stat2), fixed = "percent")  
    num_cols <- stri_subset(names(stat2), regex = "percent|valuta_otceta|data_otceta", negate=T)
    
    stat2[, (perc_cols):=lapply(.SD, \(x)(stri_replace_all(x, regex = "%| ", "") |> as.double())/100), .SDcols = perc_cols][
      , (num_cols):=lapply(.SD, \(x)stri_replace_all(x, regex = " ", "") |> as.double()), .SDcols = num_cols][
        , ticker:= ticker][]
  }
}
stats <- ticks_info[stri_detect(nazvanie, regex  = "п$", negate=T)][["tiker"]] |> 
  furrr::future_map(get_stats, .progress = T) |>
  rbindlist(use.names = TRUE, fill = TRUE)

# Функция получения дивидендов
get_divs <- function(ticker){
  # ticker <- "WTCM"
  # browser()
  link <- paste0("https://smart-lab.ru/q/", ticker, "/dividend/")
  divs <- try(rvest::read_html(link) |> rvest::html_table(header = FALSE), silent = T)
  
  if(length(divs)<2){
    res <- NULL
    res[[ticker]] <- data.table(date = as.Date(paste0(2014:2023, "-01-01")), dividend = 0) |> as.xts()
    return(res)
  }
  else{
    res <- divs[[1]][-c(1:2),] |> 
      as.data.table()
    
    names(res) <- divs[[1]][2,] |> t() |> 
      as.vector() |> 
      janitor::make_clean_names() 
    
    num_cols <- c("dividend", "cena_akcii", "div_dohodnost")
    res[, date:=as.Date(res$data_otsecki, "%d.%m.%Y")][
      , (num_cols):=lapply(.SD, \(x)stri_replace(x, fixed=",", ".") |> stri_replace(regex="%|₽", "") |> as.double()), .SDcols=num_cols][
        , div_dohodnost:=div_dohodnost/100][
          , c("date", "tiker", num_cols), with=FALSE] |> 
      split(by="tiker", keep.by = FALSE) |>
      lapply(as.xts) 
  }
}
divs <- ticks_info[stri_detect(nazvanie, regex  = "п$", negate=T)][["tiker"]] |> 
  furrr::future_map(get_divs, .progress = T) |>
  purrr::flatten()

trades <- ticks |> 
  purrr::map(\(x)try(getSymbols.Finam(x, from = "2019-01-01"), silent=T), .progress = T) |> 
  `names<-`(ticks)

trades1 <- purrr::keep(trades, ~is.xts(.)) |> 
  lapply(xts) |>
  purrr::keep(\(x)nrow(x) > 1e3)

# Сохранение данных 
list(stats=stats, ticks_info=ticks_info, divs=divs, trades=trades1) |> 
  qs::qsave("content/post/trendets2/data.qs")


