library(data.table)
library(lubridate)
library(stringi)
library(lgr)


# List fedstat indicators
get_indicators0 <- function(){
  html <- xml2::read_html("https://www.fedstat.ru/organizations/")
  items <- xml2::xml_find_all(html, xpath = '//*[@id="orgsTree"]/div')
  
  list_dt <- lapply(items, \(x){
    
    children <- xml2::xml_child(x, 'div[@class="ved_child"]') |> 
      xml2::xml_find_all('div//*[@class="ved_item group i_actual"]')
    
    data.table( 
      id = xml2::xml_find_all(children, 'a') |> xml2::xml_attr("href") |> sub(x = _, "/indicator/", ""),
      title = xml2::xml_find_all(children, 'a//*[@class="i_name"]') |> xml2::xml_text(),
      department =  xml2::xml_child(x, 'div//*[@class="i_name org"]') |> xml2::xml_text())
    
  })
  
  rbindlist(list_dt, use.names = TRUE)[!is.na(id), ][
    ,`:=`(hidden = fifelse(id == "#", TRUE, FALSE), indx =1)][
      , indx := cumsum(indx), by = "id"][
        , `:=`(id = fifelse(id == "#", paste0(id, indx), id), indx = NULL)] |>
    unique(by = "id")
  
}

# List fedstat indicators - slower but more accurate and informative
get_indicators1 <- function(){
  html <- xml2::read_html("https://www.fedstat.ru/organizations/")
  items <- xml2::xml_find_all(html, xpath = '//*[@id="orgsTree"]/div')
  
  list_dt <- lapply(items, \(x){
    # x <- items[[1]]
    
    children <- xml2::xml_child(x, 'div[@class="ved_child"]') |> xml2::xml_children()
    
    sublist_dt <- lapply(children, function(y){
      # y <- children[[1]]
      
      sub_children <- xml2::xml_child(y, 'div[@class="ved_child"]') |> 
        xml2::xml_find_all('div//*[@class="ved_item group i_actual"]')
      
      data.table( 
        department =  xml2::xml_child(x, 'div//*[@class="i_name org"]') |> xml2::xml_text(),
        group = xml2::xml_child(y, 'div[@class="ved_pl dtable group"]//*[@class="i_name org" or @class="i_name ci"]') |> xml2::xml_text(),
        id = xml2::xml_find_all(sub_children, 'a') |> xml2::xml_attr("href") |> sub(x = _, "/indicator/", ""),
        title = xml2::xml_find_all(sub_children, 'a//*[@class="i_name"]') |> xml2::xml_text()#,
        #active = xml_attr(sub_children, "class") == "ved_item group i_actual"
      )
    })
    
    rbindlist(sublist_dt, use.names = TRUE)
  })
  
  rbindlist(list_dt, use.names = TRUE)[!is.na(id), ][
    ,`:=`(hidden = fifelse(id == "#", TRUE, FALSE), indx =1)][
      , indx := cumsum(indx), by = "id"][
        , `:=`(id = fifelse(id == "#", paste0(id, indx), id), indx = NULL)] |>
    unique(by = c("department", "group", "id"))
}

# Helping function to parse javascipt text to json representing filters
parse_js1 <- function(script){
  
  script_indexed <- script[seq(grep("filters: \\{", script) + 1, grep("left_columns: \\[", script) - 2)]
  
  gsub("\\b(?=([^']*'[^']*')*[^']*$)", "'", script_indexed, perl = TRUE) |>
    gsub("'", "\"", x = _) |> 
    paste(collapse = "\n") |>
    paste0("{", ... = _, "}") |>
    jsonlite::fromJSON(simplifyVector = FALSE)
}

# Helping function to parse javascipt text to json representing headings
parse_js2 <- function(script){
  # script <- js_script
  
  script_indexed <- script[seq(grep("left_columns: \\[", script), grep("grid\\.init\\(\\);", script) - 2)]
  
  js_prep <- gsub("\\b(?=([^']*'[^']*')*[^']*$)", "'", script_indexed, perl = TRUE) |>
    gsub("'", "\"", x = _) |> 
    paste(collapse = "\n") |>
    paste0("{", ... = _, "}") |>
    jsonlite::fromJSON(simplifyVector = FALSE)
  
  new_names <- c("left_columns" = "lineObjectIds", 
                 "top_columns" = "columnObjectIds", 
                 "groups" = "lineObjectIds", 
                 "filterObjectIds" = "lineObjectIds")
  
  names(js_prep) <- new_names[names(js_prep)]
  
  return(js_prep)
}

# Function for getting filter ids (analytic measures) available for indicator (multidimensional dataset)
get_ids <- function(indicator_id, ..., timeout_seconds = 180, retry_max_times = 3, 
                    httr_verbose = httr::verbose(data_out = FALSE)){
  # indicator_id <- "37426"
  # ... <- NULL
  
  indicator_URL <- paste("https://www.fedstat.ru/indicator", indicator_id, sep = "/")
  GET_res <- httr::RETRY("GET", indicator_URL, httr_verbose, httr::timeout(timeout_seconds), times = retry_max_times, ...) 
  if(httr::http_error(GET_res)){httr::http_condition(GET_res, type = "error")}
  
  GET_html <- xml2::read_html(GET_res, encoding = "UTF-8")
  
  js_script <- xml2::xml_find_all(GET_html, ".//script")[[12]] |> # 12 - Empirically determined value
    xml2::xml_text() |>
    strsplit("\n") |>
    unlist()
  
  filter_list <- parse_js1(js_script) 
  object_list <- parse_js2(js_script) |> unlist()
  
  if(all(object_list != "0")){object_list[["filterObjectIds"]] <- "0"} # Add special filterObjectIds (indicator id)
  
  object_df <- data.frame(
    object_id = unname(object_list),
    object = names(object_list) |> gsub(x = _, "\\d", ""),
    #id_order = seq_len(length(object_list)),
    stringsAsFactors = FALSE
  )
  
  filter_id_list <- lapply(filter_list, function(x){
    #x <- filter_list[[3]]
    
    filter_values <- x[["values"]]
    
    if(!length(names(filter_values))){
      stop("fedstat returned erroneous data_ids. It's probably lagging. There are no filter values in the \"",
           x[["title"]], "\" filter ")}
    
    data.frame(
      object_title = x[["title"]],
      filter_id = names(filter_values),
      filter_title = unlist(lapply(filter_values, function(x)x[["title"]])),
      stringsAsFactors = FALSE, row.names = NULL)
  })
  
  filter_dt <- rbindlist(filter_id_list, idcol = "object_id", use.names = TRUE)[
    , filter_title := gsub("&quot;", "\"", x = filter_title)] |>
    merge.data.table(object_df, by = "object_id", all.x = TRUE) 
  
  filter_dt[, object := fifelse(is.na(object), "lineObjectIds", object)] 
  
  if(uniqueN(filter_dt) != nrow(filter_dt)){stop("data_ids table with non unique filter_field_id and filter_value_ids pairs")}
  
  return(filter_dt[])
}

# Function for getting indicator values (multidimensional dataset) based on filters
get_data <- function(data_ids, ..., data_format = c("sdmx", "excel"), 
                     timeout_seconds = 180, retry_max_times = 3,
                     httr_verbose = httr::verbose(data_out = FALSE)) {
  # ... <- NULL
  # data_format <- "sdmx"
  # data_ids <- tst4
  # timeout_seconds = 180
  # retry_max_times = 3
  # httr_verbose = httr::verbose(data_out = FALSE)
  #browser()
  
  data_format <- match.arg(data_format)
  POST_URL <- paste0("https://www.fedstat.ru/indicator/data.do?format=", data_format)
  
  indicator <- data_ids[object_id == "0", c("filter_id", "filter_title")]
  
  # filters <- unique(data_ids, by = "object_id")[order(id_order)][, c("object_id", "object")] 
  filters <- unique(data_ids, by = "object_id")[, c("object_id", "object")] 
  
  filters_list <- as.list(filters[["object_id"]]) |>
    `names<-`(filters[["object"]])
  
  filter_values <- data_ids[, .(filter_string = paste0(object_id, "_", filter_id))][["filter_string"]] |>
    as.list() 
  
  names(filter_values) <- (rep("selectedFilterIds", length(filter_values)))
  
  POST_body <- c(
    list("format" = data_format, 
         "id" = indicator[["filter_id"]], 
         "indicator_title" = indicator[["filter_title"]]),
    filters_list,
    filter_values)
  
  POST_res <- httr::RETRY("POST", POST_URL, httr_verbose, httr::timeout(timeout_seconds),
                          times = retry_max_times, body = POST_body, ...)
  
  if(httr::http_error(POST_res)){httr::http_condition(POST_res, type = "error")} else 
    if(!(POST_res[["headers"]][["content-type"]] %in% c("text/xml", "application/vnd.ms-excel"))){
      stop("No data found with specified filters or the fedstat is lagging")}
  
  return(POST_res[["content"]])
}

# Convert binary dump to xml (data description available)
sdmx2xml <- function(sdmx){
  
  if(is.null(sdmx) | class(sdmx) == "character") return(NULL)
  
  tmp_file <- tempfile()
  writeLines(rawToChar(sdmx), tmp_file)
  
  res <- xml2::read_xml(tmp_file) 
  if(file.exists(tmp_file)) file.remove(tmp_file)
  
  return(res)
}

# Convert binary dump to table (attributes description included)
sdmx2dt <- function(sdmx){
  # sdmx <- tst_data4
  
  if(is.null(sdmx) | class(sdmx) == "character") return(NULL)
  
  tmp_file <- tempfile()
  writeLines(rawToChar(sdmx), tmp_file)
  
  xml <- xml2::read_xml(tmp_file)  
  data <- readsdmx::read_sdmx(tmp_file) |> as.data.table()
  
  names(data) <- sub(x = names(data), "X(\\d+)\\.", "\\1-") # fix readsdmx renaming like "X30.ОКАТО" -> "30-ОКАТО" 
  
  if(file.exists(tmp_file))file.remove(tmp_file)
  
  CodeList <- xml2::xml_find_all(xml, '/d1:GenericData/d1:CodeLists/structure:CodeList') 
  
  codelist_id <- CodeList |>
    xml2::xml_attr("id")
  
  codelist_title <- CodeList |>
    xml2::xml_find_all("structure:Name") |>
    xml2::xml_text()
  
  codelist_tbl <- mapply(CodeList = CodeList, title = codelist_title, id = codelist_id, SIMPLIFY = FALSE, 
                         function(CodeList, title, id){
                           
                           chldrn <- xml2::xml_find_all(CodeList, "structure:Code")
                           
                           data.table(field_id = id,
                                      field_title = title,
                                      value_id = xml2::xml_attr(chldrn, "value"),
                                      value_title = xml2::xml_text(chldrn))
                         }) |> rbindlist()
  
  if(any(complete.cases(codelist_tbl) == FALSE)){stop("NA in lookup sdmx table")}
  
  field_ids <- codelist_tbl[["field_id"]] |>
    unique() 
  
  lapply(field_ids, function(x){
    codelist_tbl[field_id == x][, c("value_title", "value_id")][data[, ..x], on = c(value_id = x)][["value_title"]]}) |>
    `names<-`(paste0(field_ids, "_title")) |>
    as.data.table() |>
    cbind(data)
}

# For getting description object in form of SDMX data model ready to be converted into JSON
get_description <- function(xml){
  Indicator <- xml2::xml_child(xml, "d1:Description/d1:Indicator") 
  
  indicator <- NULL
  indicator$id <-xml2::xml_attr(Indicator, "id")
  indicator$name <-xml2::xml_attr(Indicator, "name")
  indicator$units <-xml2::xml_find_all(Indicator, "d1:Units/d1:Unit") |>xml2::xml_attr("value")
  
  indicator$periodicities <- data.frame(value =xml2::xml_find_all(Indicator, "d1:Periodicities/d1:Periodicity") |>xml2::xml_attr("value"),
                                        release =xml2::xml_find_all(Indicator, "d1:Periodicities/d1:Periodicity") |>xml2::xml_attr("releases"),
                                        next_release =xml2::xml_find_all(Indicator, "d1:Periodicities/d1:Periodicity") |>xml2::xml_attr("next-release"))
  
  indicator$dimensions <- data.frame(name =xml2::xml_find_all(Indicator, "d1:Dimensions/d1:Dimension/d1:Name") |>xml2::xml_text(),
                                     vaue =xml2::xml_find_all(Indicator, "d1:Dimensions/d1:Dimension") |>xml2::xml_attr("value"))
  
  indicator$methodology <-xml2::xml_child(Indicator, "d1:Methodology") |>xml2::xml_attr("value")
  indicator$comment <-xml2::xml_child(Indicator, "d1:Comment") |>xml2::xml_attr("value")
  indicator$responsible$name <-xml2::xml_child(Indicator, "d1:Responsible/d1:Name") |>xml2::xml_text()
  indicator$responsible$contact <-xml2::xml_child(Indicator, "d1:Responsible/d1:Contacts") |>xml2::xml_text()
  indicator$forms <-  data.frame(name = xml2::xml_find_all(Indicator, "d1:Forms/d1:Form/d1:Name") |>xml2::xml_text(),
                                 value = xml2::xml_find_all(Indicator, "d1:Forms/d1:Form") |>xml2::xml_attr("value"))
  
  return(indicator)
}

# Faster multithread version of get_data() capable to download large datasets
get_data_split <- function(data_ids, split_key = NULL, cores = 1, explicit_log = TRUE, ...,
                           httr_verbose = httr::verbose(data_out = FALSE)){
  # data_ids <- tst_ids
  # split_key <- "Территории"
  
  if(is.null(split_key)){
    n_ids <- data_ids[, .(n = .N), by = "object_title"][order(-n)]
    if(n_ids$n[1] > 50){split_key <- n_ids$object_title[2]}
  }
  
  if(is.null(split_key)){
    message("split_key is not needed, data is downloading as single bunch")
    get_data(data_ids, httr_verbose = httr_verbose, retry_max_times = retry_max_times) |> list() # for structure unification with split key
  }
  else{
    if(!split_key %in% data_ids$object_title)stop("split_key should be present to object_title")
    message("'", split_key, "'", " has been chosen as split_key")
    key_values <- data_ids[object_title == split_key][["filter_title"]]
    pb <- progress::progress_bar$new(total = length(key_values))
    
    parallel::mclapply(key_values, mc.cores = cores, function(x){
      res <- tryCatch(error = function(cnd)if(!explicit_log) NULL else warning(paste0("Data is not avalable for ", x), call. = FALSE, immediate. = TRUE), 
                      expr = data_ids[(object_title == split_key & filter_title == x) | object_title != split_key] |> 
                        get_data(httr_verbose = httr_verbose, httr_verbose = httr_verbose, retry_max_times = retry_max_times, ...))
      pb$tick()
      return(res)
    }) |> `names<-`(key_values)}
}

# Log version of previous function
get_data_split_log <- function(data_ids, split_key = NULL, cores = 1, path2log, indicator_id, retry_max_times = 5, 
                               httr_verbose = httr::verbose(data_out = FALSE)){
  # data_ids <- tst_ids
  # split_key <- "Территории"
  # browser()
  
  if(is.null(split_key)){
    n_ids <- data_ids[, .(n = .N), by = "object_title"][order(-n)]
    if(n_ids$n[1] > 50){split_key <- n_ids$object_title[2]}
  }
  
  if(is.null(split_key)){
    lgr::lgr$info("Data is downloading as single request i.e. split_key is not needed", indicator_id = indicator_id)
    get_data(data_ids, httr_verbose = httr_verbose, retry_max_times = retry_max_times) |> 
      list() # for structure unification with split key
  }
  else{
    if(!split_key %in% data_ids$object_title)lgr::lgr$error("split_key %s should be present to object_title", split_key, indicator_id = indicator_id)
    lgr::lgr$info("'%s' has been chosen as split_key", split_key, indicator_id = indicator_id)
    key_values <- data_ids[object_title == split_key][["filter_title"]]
    
    parallel::mclapply(key_values, mc.cores = cores, function(x){
      tryCatch(error = function(cnd){
        lgr::lgr$error("Data is not avalable", split_key = split_key, key_value = x, indicator_id = indicator_id)
        NULL # NULL value as error handler result
      }, expr = {
        data <- data_ids[(object_title == split_key & filter_title == x) | object_title != split_key] |> 
          get_data(httr_verbose = httr_verbose, retry_max_times = retry_max_times)
        
        lgr::lgr$info("Data successfully loaded", split_key = split_key, key_value = x, indicator_id = indicator_id)
        data # data as expression result
      })
    }) |> `names<-`(key_values)
  }
}

# Convert fedstat quarter format to date
quarter2date <- function(qtr, year){
  
  fcase(stringi::stri_detect_regex(qtr, "I\\s*квартал"), stringi::stri_c(year, "-03-31") |> lubridate::as_date(),
        stringi::stri_detect_regex(qtr, "II\\s*квартал"), stringi::stri_c(year, "-06-30") |> lubridate::as_date(),
        stringi::stri_detect_regex(qtr, "III\\s*квартал"), stringi::stri_c(year, "-09-30") |> lubridate::as_date(),
        stringi::stri_detect_regex(qtr, "IV\\s*квартал"), stringi::stri_c(year, "-12-31") |> lubridate::as_date())
  
}

# Convert fedstat week format to date
week2date <- function(week){
  
  # Sys.setlocale(locale = "en_US.UTF-8")
  # format(as.Date("2022-01-01") + (1:12)*28, format = "%b") |> dput()
  ru_month <- c("янв", "фев", "мар", "апр", "мая", "июн", 
                "июл", "авг", "сен", "окт", "ноя", "дек")
  date_pattrern <- stringi::stri_c("[0-3]?[0-9]\\s*", ru_month, "\\w*\\b\\.?\\s*20\\d{2}", sep = "") |> stringi::stri_c(collapse = "|")
  
  stringi::stri_extract_first_regex(week, date_pattrern) |> 
    lubridate::parse_date_time(orders = c("dbY", "dBY"), locale = "ru_RU.UTF-8") |>
    lubridate::as_date()
}

# Convert fedstat month format to date
month2date <- function(month, year, last_day = TRUE){
  
  date <- stringi::stri_c("01", month, year, sep = " ") |> 
    lubridate::parse_date_time(orders = c("dbY", "dBY"), locale = "ru_RU.UTF-8", train  = FALSE) 
  
  fifelse(rep(last_day, length(date)), 
          stringi::stri_c(year, lubridate::month(date), lubridate::days_in_month(date), sep = "-") |> lubridate::as_date(),
          date |> lubridate::as_date()) 
}

# Simple function to estimate size of data stored on disk
disk_size <- function(dt){
  tmp <- tempfile()
  
  fst::write_fst(dt, tmp)
  
  sz <- file.info(tmp)[["size"]] |> 
    as.numeric()
  
  class(sz) <- "object_size"
  
  format(sz, "Mb")
}

# Load and save to disk ids monitored 
load_ids <- function(indicator_id, httr_verbose = NULL){
  # browser()
  
  path2log <- paste0("samples/log/", Sys.Date(), ".json")
  lgr::lgr$add_appender(lgr::AppenderJson$new(path2log), name = "json")
  
  # Get filters
  lgr::lgr$info("Start ids loading", indicator_id = indicator_id)
  
  ids <- tryCatch(error = function(cond){
    lgr::lgr$error("Ids are not available", indicator_id = indicator_id)
    NULL # NULL value as error handler result
  }, expr = {
    ids_data <- get_ids(indicator_id, httr_verbose = httr_verbose)
    fst::write_fst(ids_data, sprintf("samples/filters/ids_%s.fst", indicator_id))
    lgr::lgr$info("Ids successfully loaded and saved", indicator_id = indicator_id)
    ids_data
  })
  
  lgr::lgr$remove_appender("json")
  
  return(ids)
}

# Load and save to disk data monitored 
load_data <- function(ids, indicator_id, httr_verbose = NULL, cores = 6){
  # browser()
  path2log <- paste0("samples/log/", Sys.Date(), ".json")
  lgr::lgr$add_appender(lgr::AppenderJson$new(path2log), name = "json")
  
  # Download data
  lgr::lgr$info("Start data loading", indicator_id = indicator_id)
  tryCatch(error = function(cond){
    lgr::lgr$error("Indicator data is not available", indicator_id = indicator_id)
    NULL # NULL value as error handler result
  }, expr = {
    
    # Download data
    raw_data_list <- get_data_split_log(ids, cores = cores, path2log = path2log, indicator_id = indicator_id, httr_verbose = httr_verbose)
    lgr::lgr$info("Indicator successfully loaded", indicator_id = indicator_id)
    
    # Process data 
    dt <- lapply(raw_data_list, sdmx2dt) |> rbindlist()
    descr_vec <- lapply(raw_data_list, \(x)!is.null(x)) |> unlist() |> which() |> unname() # find list members are not nulled
    xml <- sdmx2xml(raw_data_list[[descr_vec[1]]])
    
    # Save result
    fst::write_fst(dt, sprintf("samples/data/data_%s.fst", indicator_id))
    get_description(xml) |> 
      jsonlite::write_json(sprintf("samples/description/descr_%s.json", indicator_id), simplifyVector = TRUE, auto_unbox = TRUE, pretty = TRUE)
    lgr::lgr$info("Indicator successfully saved", indicator_id = indicator_id)
    
  }, warning = function(cnd){
    lgr::lgr$warn(cnd, indicator_id = indicator_id)
    NULL # NULL value as error handler result
  }) 
  
  lgr::lgr$remove_appender("json") 
}

# Load and save to disk ids and data monitored 
load_all <- function(indicator_id, httr_verbose = NULL, cores = 6){
  # browser()
  load_ids(indicator_id = indicator_id, httr_verbose = httr_verbose) |> 
    load_data(indicator_id = indicator_id, httr_verbose = httr_verbose, cores = cores)
}

# Function to unify data
unify_data <- function(dt){
  # browser()
  
  EI <- unique(dt$EI)
  mnth <- c("январь", "февраль", "март", "апрель", "май", "июнь", 
            "июль", "август", "сентябрь", "октябрь", "ноябрь", "декабрь")
  qtr <- c("I квартал", "II квартал", "III квартал", "IV квартал")
  yr <- c("на конец года", "значение показателя за год", "раз в год на определенную дату", "на начало учебного года")
  
  # transform to numeric
  dt[, value := stri_replace_first_fixed(ObsValue, ",", ".") |> as.numeric()][]
  
  # eliminate double EI 
  if("тысяча человек" %in% EI & "человек" %in% EI){
    dt[, value := fifelse(EI == "человек", value*1e3, value)][, EI := fifelse(EI == "человек", "тысяча человек", EI)]
  }
  
  dt[, period := fcase(stri_detect(PERIOD, regex = "на 1 \\w+$"), "мгновенный", 
                       stri_detect(PERIOD, fixed = "январь-"), "накопленный с начала года",
                       stri_detect(PERIOD, fixed = "неделя"), "неделя",
                       PERIOD == "I полугодие", "полугодие",
                       PERIOD %in% yr, "год",
                       PERIOD %in% mnth, "месяц",
                       PERIOD %in% qtr, "квартал",
                       default = NA)]
  
  dt[order(period)][, date := fcase( # sort for better dates guessing
    period == "накопленный с начала года", stri_extract(PERIOD, regex = "(?<=-)\\w+") |> month2date(Time, last_day = TRUE),
    period == "неделя", week2date(PERIOD),
    period == "полугодие", as_date(stri_c(Time, "-06-30")),
    PERIOD == "на начало учебного года", as_date(stri_c(Time, "-09-01")),
    period == "год", as_date(stri_c(Time, "-12-31")),
    period == "месяц", month2date(PERIOD, Time, last_day = TRUE),
    period == "квартал", quarter2date(PERIOD, Time),
    period == "мгновенный", stri_c(PERIOD, " ", Time) |> parse_date_time(orders = c("dbY", "dBY"), locale = "ru_RU.UTF-8") |> as_date(),
    default = NA)][]
}

# Log version of previous
unify_data_log <- function(indicator_id){
  
  path2log <- paste0("samples/log/", Sys.Date(), ".json")
  lgr::lgr$add_appender(lgr::AppenderJson$new(path2log), name = "json")
  
  path <- paste0("samples/data/data_", indicator_id, ".fst")
  
  tryCatch(error = function(cond){
    lgr::lgr$error(cond, indicator_id = indicator_id)
    NULL # NULL value as error handler result
  }, expr = {
    withCallingHandlers( # only capture warnings to log without stopping the process
      warning = function(cnd) lgr::lgr$warn(cnd, indicator_id = indicator_id),
      expr = {
        fst::read_fst(path, as.data.table = TRUE) |> 
          unify_data() |> 
          fst::write_fst(path)
        
        lgr::lgr$info("Indicator successfully transformed", indicator_id = indicator_id)
      })
  })
  
  
  lgr::lgr$remove_appender("json") 
}

# Split data to pieces
split_data <- function(dt, indicator_id){
  # dt <- tst_data
  # indicator_id <- "58695"
  
  # Define location column
  if(any(stri_detect(names(dt), regex = "OKATO$|ОКАТО$|okato$"))){
    # The best option is to use OKATO
    location_id <- stri_subset(names(dt), regex = "OKATO$|ОКАТО$|okato$")
    location_title <- stri_subset(names(dt), regex = "OKATO_title|ОКАТО_title|okato_title")
    setnames(dt, old = c(location_id, location_title), new = c("location_id", "location_name"))
    
    skip_cols <- c("ObsValue", "EI", "PERIOD", "Time", "location_name")
  }else if(any(stri_detect(names(dt), regex = "OKSM$"))){
    # Otherwise OKSM could be used 
    location_id <- stri_subset(names(dt), regex = "OKSM$|oksm$")
    location_title <- stri_subset(names(dt), regex = "OKSM_title|oksm_title")
    setnames(dt, old = c(location_id, location_title), new = c("location_id", "location_name"))
    
    skip_cols <- c("ObsValue", "EI", "PERIOD", "Time", "location_name")
  }else{
    # Finally just 643 value could be used as a default one 
    dt[, location_id := "643"]
    
    skip_cols <- c("ObsValue", "EI", "PERIOD", "Time")
  }
  
  # Define column role for splitting
  indx <- stri_c("RST_", indicator_id)
  measure_titles <- stri_subset(names(dt), fixed = "_title") 
  measures <- stri_replace(measure_titles, fixed = "_title", replacement = "")
  
  # Make split
  msr_dt <- dt[, `:=`(indicator_id = indx, value_id = .I)][, !skip_cols, with = FALSE] |>
    melt(id.vars = c("indicator_id", "value_id"), measure.vars = measures, variable.name = "measure", value.name = "measure_id")
  
  msr_title_dt <- mapply(x = measures, y = measure_titles, FUN = \(x, y) dt[, c(x, y), with = FALSE] |> unique(by = x) |> setnames(c("measure_id", "title")), SIMPLIFY = FALSE) |> 
    rbindlist(idcol = "measure")
  
  values_dt <- dt[, -c(measures, measure_titles, skip_cols), with = FALSE]
  
  list(values = values_dt, measures = msr_dt, msr_dict = msr_title_dt)
}

# Log version of previous
split_data_log <- function(indicator_id){
  # browser()
  
  path2log <- paste0("samples/log/", Sys.Date(), ".json")
  lgr::lgr$add_appender(lgr::AppenderJson$new(path2log), name = "json")
  
  path_from <- paste0("samples/data/data_", indicator_id, ".fst")
  path_to <- paste0("samples/split_data/data_", indicator_id, ".qs")
  
  tryCatch(error = function(cond){
    lgr::lgr$error(cond, indicator_id = indicator_id)
    NULL # NULL value as error handler result
  }, expr = {
    withCallingHandlers( # only capture warnings to log without stopping the process
      warning = function(cnd) lgr::lgr$warn(cnd, indicator_id = indicator_id),
      expr = {
        fst::read_fst(path_from, as.data.table = TRUE) |> 
          split_data(indicator_id) |> 
          qs::qsave(path_to)
        
        lgr::lgr$info("Indicator successfully splitted", indicator_id = indicator_id)
      })
  })
  
  
  lgr::lgr$remove_appender("json") 
}