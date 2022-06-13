link <- "https://www.cbr.ru/vfs/analytics/finflows/stat_finflows.xlsx"
#tmp <- tempfile(pattern = "flows", fileext = ".xlsx")
download.file(url = link, destfile = "content/post/money_flows1/data/stat_finflows.xlsx")
