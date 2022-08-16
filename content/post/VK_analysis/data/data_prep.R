library(moexer)
library(fst)

VK <- get_candles('VKCO', from = '2021-10-01', debug = TRUE, interval = "daily")

write_fst(VK, "content/post/VK_analysis/data/VK.fst")


