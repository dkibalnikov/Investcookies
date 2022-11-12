library(fedstatAPIr) # пакет для загрузки данных с сайта Росстата
library(collapse)
library(data.table)
library(stringi)


house_new <- fedstat_data_load_with_filters(indicator_id = "61781")
house_old <- fedstat_data_load_with_filters(indicator_id = "31452")

setdiff(names(house_new), names(house_old))  

house <- rbindlist(list(house_new, house_old), fill = TRUE) |> 
  fsubset(s_mestdom == "Все территории - итого"| is.na(s_mestdom)) |>
  fsubset(s_OKATO_code %chin% c("45000000000", "40000000000")) |> 
  tfm(month = fcase(PERIOD == "I квартал", "03", 
                    PERIOD == "II квартал", "06", 
                    PERIOD == "III квартал", "09", 
                    PERIOD == "IV квартал", "12")) |>
  tfm(date = as.Date(stri_c(Time, "-",month, "-30")), 
      ObsValue = stri_replace_all_regex(ObsValue, "\\,", "\\.") %>% as.numeric()) 

fst::write_fst(house, "content/post/ggplot_stack/data/house.fst")
