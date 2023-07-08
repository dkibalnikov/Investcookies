library(data.table)
library(quantmod)
library(rusquant)
library(TTR)
library(stringi)
library(ggplot2)
library(patchwork)


tickers <- c("PLZL", "POLY", "SBER", "GAZP")

getSymbols(tickers, src = "Finam", from = "2020-01-01")

get_divs <- function(ticker){
  # ticker <- "POLY"
  link <- paste0("https://smart-lab.ru/q/", ticker, "/dividend/")
  
  divs <- rvest::read_html(link) |> 
    rvest::html_table(header = FALSE) 
  
  res <- divs[[1]][-c(1:2),] |> 
    as.data.table()
  
  names(res) <- divs[[1]][2,] |> t() |> 
    as.vector() |> 
    janitor::make_clean_names() 
  
  num_cols <- c("dividend_rub", "cena_akcii", "div_dohodnost")
  res[, date:=as.Date(res$data_otsecki, "%d.%m.%Y")][
    , (num_cols):=lapply(.SD, \(x)stri_replace(x, fixed=",", ".") |> stri_replace(fixed="%", "") |> as.double()), .SDcols=num_cols][
      , div_dohodnost:=div_dohodnost/100][
        , c("date", num_cols), with=FALSE] |> 
    as.xts()
}get_max
est_inertia <- function(ticker, short_cost=5e-04, trans_cost=0.003){ 
  # ticker <- "SBER"
  # short_cost <- 5e-04
  # trans_cost <- 0.003
  
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
  trade <- merge(trade, get_divs(ticker)[,"dividend_rub"], join='left')
  trade$dividend_rub <- lag(trade$dividend_rub, k = -1)
  trade$dividend_rub <- replace(trade$dividend_rub, is.na(trade$dividend_rub), 0)
  
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


strategies <- c("base", "buy", "sell", "two_way")

est_inertia("POLY")[, strategies] |> 
  PerformanceAnalytics::charts.PerformanceSummary(main=strategies)

est_inertia("PLZL")[, strategies] |> 
  PerformanceAnalytics::charts.PerformanceSummary(main=strategies)

est_inertia("SBER")[, strategies] |> 
  PerformanceAnalytics::charts.PerformanceSummary(main=strategies)

plot_trades <- function(ticker){
  chart_Series(ticker, subset = c("2020-02-26::"), name = substitute(ticker))
  add_Vo()
  add_MACD() 
  add_EVWMA(n = 26, col = "firebrick") 
}
plot_inertia <- function(est){
  # est <- est_inertia("GAZP")
  est_dt <- as.data.table(est)[
    , (strategies):=lapply(.SD, \(x)cumprod(1+x)-1), .SDcols=strategies][
      , div:=fifelse(dividend_rub > 0, dividend_rub/Open, NA) ]
  
  profit <- est_dt[, c("index", strategies), with=FALSE] |> 
    melt("index") |>
    ggplot(aes(index, value, col = variable)) + 
    geom_vline(data = est_dt, aes(xintercept = fifelse(dividend_rub > 0, index, NA)), lty=5, color = "gray20")+
    geom_line() +
    geom_label(data = \(x)x[, .(index=last(index), value = last(value)), by=variable], aes(index, value, label = scales::percent(value, .1), col = variable), alpha=.5) + 
    geom_label(data = est_dt, aes(index, Inf, label=scales::percent(div, .1)), color = "gray20", vjust = 1, alpha=.5) +
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
    ggplot(aes(index, value, col = variable)) +
    geom_line() +
    geom_label(data = \(x)x[value%in%collapse::fmin(value, x$variable)] |> unique(by = "variable"), aes(index, value, label = scales::percent(value, .1), col = variable), alpha=.5) + 
    scale_y_continuous(labels = scales::label_percent(), n.breaks = 6) + 
    labs(x="Дни", y = "Просадка", col = "Стратегия")
  
  profit/drawdown + plot_layout(nrow = 2, heights = c(2, 1), guides = 'collect')
}

est_inertia("SBER") |>
  plot_inertia()

est_inertia("POLY") |> 
  plot_inertia()

est_inertia("PLZL") |>
  plot_inertia()

est_inertia("GAZP") |>
  plot_inertia() 


