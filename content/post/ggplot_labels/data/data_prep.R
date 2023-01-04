source("content/post/ggplot_labels/data/functions.R")


price_ids <- get_ids("31448")
CPI_ids <- get_ids("31074")


price_res <- price_ids[filter_id == "1688487" | object_id != "57831"] |> 
  get_data() |> sdmx2dt()

CPI_res <- CPI_ids[filter_id %chin% c("1707675", "1744145") | object_id != "58273"][
  filter_id == "1688487" | object_id != "57831"][
    filter_id == "1704140" | object_id != "57937"] |> 
  get_data() |> sdmx2dt()


fst::write_fst(price_res, "content/post/ggplot_labels/data/price.fst")
fst::write_fst(CPI_res, "content/post/ggplot_labels/data/CPI.fst")
