
library(quantmod)
library(stringi)

getSymbols(c("PAYEMS", "INDPRO", "W875RX1", "CMRMTSPL", "USRECD", "RECPROUSM156N"), src = "FRED")


recession_xts <- cbind(USRECD, RECPROUSM156N) |> 
  apply.monthly(fmean) |>
  as.data.table(keep.rownames = "date") |>
  tfm(date = stri_replace(date, replacement = "-01", regex = "-\\d\\d$") |> as.Date()) |> 
  as.xts()

cbind(PAYEMS, INDPRO, W875RX1, CMRMTSPL, recession_xts) |> 
  as.data.table(keep.rownames = "date") |> 
  fsubset(date > as.Date("1970-01-01")) |>
  fst::write_fst("content/post/markov_switch_model/data/indctrs.fst")
