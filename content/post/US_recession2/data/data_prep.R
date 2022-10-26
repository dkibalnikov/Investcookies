
library(quantmod)
library(stringi)

getSymbols(c('USREC', 'UNRATE', 'T10Y3M', 'DFF'), src = "FRED")

indctrs_xts <- cbind(T10Y3M, DFF) |> 
  apply.monthly(fmean) |>
  as.data.table(keep.rownames = "date") |>
  tfm(date = stri_replace(date, replacement = "-01", regex = "-\\d\\d$") |> as.Date()) |> 
  as.xts()

cbind(USREC, UNRATE, indctrs_xts) |> 
  as.data.table(keep.rownames = "date") |> 
  fsubset(date > as.Date("1982-01-01")) |>
  fst::write_fst("content/post/US_recession2/data/indctrs.fst")
