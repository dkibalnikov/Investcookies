
# Function to create new post 
# title - actual name of a post 
# summary - short spoiler 
# date - post date 
# categories - which categories does post fall 
# tags - which tags is post attributes 
# math - TRUE/FALSE math formula usage 
# ShowToc - TRUE/FALS show content table 
# image - the path to cover image 
create_post <- function(title, summary, image, date = Sys.Date(), math = TRUE, ShowToc = TRUE){
  
  # title <- "Атаки на НПЗ 🥰"
  # date <- "2024-05-01"
  # categories <- "data science" 
  # tags <- c("analysis", "R", "stock market", "advanced")
  # math <- TRUE
  # ShowToc <- TRUE 
  # image <- "~/Downloads/1.png"
  # summary <- "bla bla bla"
  
  title_clean <- janitor::make_clean_names(title)
  post_dir <- paste0("content/post/", title_clean)
  
  
  dir.create(post_dir)
  file.copy(image, to = post_dir)
  image_name <- list.files(post_dir)
  file.create(paste0(post_dir, "/index.Rmd"))
  
  
  writeLines(con = paste0(post_dir, "/index.Rmd"), 
             glue::glue('
    ---
    title: "{title}"
    author: "🍪🍪🪙"
    date: {date}
    categories: ["data science"]                # NEEDs TO BE UPDATED 
    tags: ["analysis", "R"]                     # NEEDs TO BE UPDATED 
    math: {if(math)"true" else "false"}
    ShowToc: {if(ShowToc)"true" else "false"}
    summary: "{summary}"
    cover:
     image: "{image_name}"
     alt: ""
     caption: ""
     relative: true # To use relative path for cover image, used in hugo Page-bundles
    ---
     
    ```{{r setup, include=FALSE, echo=FALSE, warning=FALSE, message=FALSE}}
    knitr::opts_chunk$set(echo = FALSE, message = FALSE, warning = FALSE, error = FALSE, fig.width=7.5)
    
    # Активируем тему для блога
    thematic::thematic_rmd(bg = "#1D1E20", accent = "black", fg = "grey90", 
                          font = thematic::font_spec("Roboto"), #sequential = firatheme::firaPalette(100), 
                          qualitative = palette.colors(palette = "Tableau")) 
    
    # Сохраняем палитру в отдельную переменную
    my_pal <- palette.colors(palette = "Tableau") |> unname() 
    
    my_ggplot <- function(dt, ...){{
     ggplot(dt, ...) +
       ggpp::annotate("text_npc", npcx = .5, npcy = .5, alpha = .9, size = 10, label = "InvestCookies.ru", color = "#1D1E20")
    }}
    ```
    
    ## Заголовок 

    !!!Текст тут!!!
    
    
    ---
    
    <details>
    <summary>Исходный код заметки</summary>
    
    ```{{r, eval=FALSE, echo = TRUE}}
    # Необходимые библиотеки
    
    ```
    
    </details>
    
    ---
    
    Простой способ узнать о новых публикациях – подписаться на Telegram-канал:
    <div class="telegram-icon" align="left">
    <a href="https://t.me/investcookies" target="_blank" rel="noopener noreferrer me">
    🍪🍪🪙 InvestCookies 
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
        stroke-linecap="round" stroke-linejoin="round">
        <path
            d="M21.198 2.433a2.242 2.242 0 0 0-1.022.215l-8.609 3.33c-2.068.8-4.133 1.598-5.724 2.21a405.15 405.15 0 0 1-2.849 1.09c-.42.147-.99.332-1.473.901-.728.968.193 1.798.919 2.286 1.61.516 3.275 1.009 4.654 1.472.509 1.793.997 3.592 1.48 5.388.16.36.506.494.864.498l-.002.018s.281.028.555-.038a2.1 2.1 0 0 0 .933-.517c.345-.324 1.28-1.244 1.811-1.764l3.999 2.952.032.018s.442.311 1.09.355c.324.022.75-.04 1.116-.308.37-.27.613-.702.728-1.196.342-1.492 2.61-12.285 2.997-14.072l-.01.042c.27-1.006.17-1.928-.455-2.474a1.654 1.654 0 0 0-1.034-.407z" />
    </svg>
    </a>
    </div>
    '))
  
  rstudioapi::documentOpen(paste0(post_dir, "/index.Rmd"))
}


create_post(title = "Внимание - это все, что нужно коммивояжеру", 
            summary = "Первое относительно успешное решение на база механизма внимания", 
            image = "~/Downloads/vermeer2.jpg")

