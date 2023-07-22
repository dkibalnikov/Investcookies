library(data.table) # быстрая обработка табличных данных 
library(quantmod) # загрузка сведений о котировках
library(rusquant) # расширение quantmod для работы с российскими провайдерами данных о котировках
library(TTR) # пакет, который делает расчет MACD 
library(stringi) # быстрые регулярные выражения 
library(ggplot2) # рисовалка графиков
library(patchwork) # для создания композиции из графиков

# Акции, которые будут тестироваться
tickers <- c("PLZL", "POLY", "SBER", "GAZP", "YNDX")

# Загрузка котировок 
getSymbols(tickers, src = "Finam", from = "2020-01-01")

# Функция котировки 
plot_trades <- function(ticker, subset = "2023-01-01::"){
  
  plt <- chart_Series(ticker, subset = subset, name = substitute(ticker), )
  add_Vo() # объем торговли
  add_MACD() # график MACD
  add_EVWMA(n = 26, col = my_pal[4]) # взвешенная средняя 
  add_BBands() # границы волатильности
  
# Корректировки темы графика  
  plt$Env$theme$bg <- "#1D1E20"
  plt$Env$theme$grid <- "grey20"
  plt$Env$theme$labels <- "grey90"
  plt$Env$theme$up.border<- "grey40"
  plt$Env$theme$dn.border<- "grey40"
  plt$Env$theme$up.col<- my_pal[5]
  plt$Env$theme$dn.col<- my_pal[3]
  plt$Env$theme$bbands$col$fill <- "black"
  plt$Env$theme$macd$up.col <- my_pal[5]
  plt$Env$theme$macd$dn.col <- my_pal[3]
  plt$Env$theme$macd$signal <- my_pal[2]
  plt$Env$theme$macd$macd <- my_pal[1]
  plt
}
# Функция получения дивидендов
get_divs <- function(ticker, exception = c("YNDX")){
  # ticker <- "POLY"
  # browser()
  
  if(ticker %in% exception) return(data.table(date = as.Date(paste0(2014:2023, "-01-01")), dividend = 0) |> as.xts())
  else{
    link <- paste0("https://smart-lab.ru/q/", ticker, "/dividend/")
    
    divs <- rvest::read_html(link) |> 
      rvest::html_table(header = FALSE) 
    
    res <- divs[[1]][-c(1:2),] |> 
      as.data.table()
    
    names(res) <- divs[[1]][2,] |> t() |> 
      as.vector() |> 
      janitor::make_clean_names() 
    
    num_cols <- c("dividend", "cena_akcii", "div_dohodnost")
    res[, date:=as.Date(res$data_otsecki, "%d.%m.%Y")][
      , (num_cols):=lapply(.SD, \(x)stri_replace(x, fixed=",", ".") |> stri_replace(regex="%|₽", "") |> as.double()), .SDcols=num_cols][
        , div_dohodnost:=div_dohodnost/100][
          , c("date", num_cols), with=FALSE] |> 
      as.xts()
  }
}
# Функция расчета доходности
est_inertia <- function(ticker, short_cost=5e-04, trans_cost=0.003){ 
  # ticker <- "SBER"
  # short_cost <- 5e-04
  # trans_cost <- 0.003
  # browser()
  trade <- eval(str2expression(ticker)) 
  names(trade) <- sub(paste0(ticker, "."), "", names(trade))
  
  # Расчет сигнала 
  sgnl <- TTR::MACD(trade$Close) |> lag() 
  # lag() - активирует стратегию на следующий день после получения сведений о закрытии предыдущего торгового дня 
  
  # Определение флагов включение/выключения стратегий
  sgnl$buy <- ifelse(sgnl$macd - sgnl$signal > 0, 1, 0) # покупаешь по сигналу 
  sgnl$sell <- ifelse(sgnl$macd -  sgnl$signal > 0, 0, -1) # продаешь по сигналу
  sgnl$two_way <- ifelse(sgnl$macd - sgnl$signal > 0, 1, -1) # покупаешь и продаешь по сигналу 
  
  # Определение момента покупки/продажи для расчета комиссии
  trade$switch <- fifelse(sgnl$two_way == lag(sgnl$two_way),  0, 1) 
  
  # Добавление дивидендов в модель
  trade <- merge(trade, get_divs(ticker)[,"dividend"], join='left')
  trade$dividend_rub <- lag(trade$dividend, k = -1)
  trade$dividend_rub <- replace(trade$dividend, is.na(trade$dividend), 0)
  
  # Расчет расходов на торговлю как сумму затрат на покупку/продажу и непокрытую позицию
  trade$buy_cost <- trade$Open*trade$switch*trans_cost
  trade$sell_cost <- trade$Open*trade$switch*trans_cost + ifelse(sgnl$sell == -1, 1, 0)*trade$Open*short_cost
  trade$two_way_cost <- 2*trade$Open*trade$switch*trans_cost + ifelse(sgnl$sell == -1, 1, 0)*trade$Open*short_cost
  
  # Расчет дневных прибылей/убытков
  res <- sgnl$two_way
  names(res) <- "signal"
  # Дивиденды дают кумулятивную прибавку к цене актива
  # Затраты вычитаются 
  res$base <- dailyReturn(trade$Close + cumsum(trade$dividend_rub)) 
  res$buy <- suppressWarnings(dailyReturn(trade$Close + cumsum(trade$dividend_rub))*sgnl$buy - trade$buy_cost/trade$Open)
  res$sell <- suppressWarnings(dailyReturn(trade$Close + cumsum(trade$dividend_rub))*sgnl$sell - trade$sell_cost/trade$Open)
  res$two_way <- suppressWarnings(dailyReturn(trade$Close + cumsum(trade$dividend_rub))*sgnl$two_way - trade$two_way_cost/trade$Open)
  
  merge(res[!is.na(res$two_way)], trade, join = "left") 
}
# Функция построения графика доходности
plot_inertia <- function(est){
  # est <- est_inertia("GAZP")
  
  strategies <- c("base", "buy", "sell", "two_way")
  est_dt <- as.data.table(est)[
    , (strategies):=lapply(.SD, \(x)cumprod(1+x)-1), .SDcols=strategies][
      , div:=fifelse(dividend_rub > 0, dividend_rub/Open, NA) ]
  
  profit <- est_dt[, c("index", strategies), with=FALSE] |> 
    melt("index") |>
    my_ggplot(aes(index, value, col = variable)) + 
    geom_vline(data = est_dt, aes(xintercept = fifelse(dividend_rub > 0, index, NA)), lty=5, color = "gray80")+
    geom_line() +
    geom_label(data = \(x)x[, .(index=last(index), value = last(value)), by=variable], aes(index, value, label = scales::percent(value, .1), col = variable), alpha=.2) + 
    geom_label(data = est_dt, aes(index, Inf, label=scales::percent(div, .1)), color = "gray80", vjust = 1, alpha=.5) +
    scale_y_continuous(labels = scales::label_percent(), n.breaks = 6) + 
    labs(x="Дни", y = "Доходность", col = "Стратегия")
  
  get_max <- function(out, input){if(out>input) out else input}
  
  drawdown <- est_dt[, (paste0(strategies, "_max")):=lapply(.SD, \(x)Reduce(get_max, x, accumulate = TRUE)), .SDcols=strategies][
    , `:=`(base = (base-base_max)/(1+base_max), 
           buy = (buy-buy_max)/(1+buy_max), 
           sell = (sell-sell_max)/(1+sell_max), 
           two_way=(two_way-two_way_max)/(1+two_way_max))][
             , c("index", strategies), with=FALSE] |> 
    melt("index") |>
    my_ggplot(aes(index, value, col = variable)) +
    geom_line() +
    geom_label(data = \(x)x[value%in%collapse::fmin(value, x$variable)] |> unique(by = "variable"), aes(index, value, label = scales::percent(value, .1), col = variable), alpha=.2) + 
    scale_y_continuous(labels = scales::label_percent(), n.breaks = 6) + 
    labs(x="Дни", y = "Просадка", col = "Стратегия")
  
  profit/drawdown + plot_layout(nrow = 2, heights = c(2, 1), guides = 'collect')
}

# Полюс
plot_trades(PLZL)

est_inertia("SBER") |>
  plot_inertia()

est_inertia("POLY") |> 
  plot_inertia()

est_inertia("PLZL") |>
  plot_inertia()

est_inertia("GAZP") |>
  plot_inertia() 

est_inertia("YNDX") |>
  plot_inertia() 


