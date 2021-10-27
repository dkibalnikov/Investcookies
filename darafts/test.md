---
title: "Crosstalk test"
author: "🍪🍪🪙"
date: 2021-10-23
categories: ["экономика"]
tags: ["кризис", "для всех", "COVID"]
math: true
ShowToc: true
cover:
    image: "virus_fear.png"
    # can also paste direct link from external site
    # ex. https://i.ibb.co/K0HVPBd/paper-mod-profilemode.png
    alt: "<alt text>"
    caption: "<text>"
    relative: true # To use relative path for cover image, used in hugo Page-bundles
---

<script src="/rmarkdown-libs/jquery/jquery.min.js"></script>
<link href="/rmarkdown-libs/crosstalk/css/crosstalk.min.css" rel="stylesheet" />
<script src="/rmarkdown-libs/crosstalk/js/crosstalk.min.js"></script>
<script src="/rmarkdown-libs/ionrangeslider-javascript/js/ion.rangeSlider.min.js"></script>
<script src="/rmarkdown-libs/strftime/strftime-min.js"></script>
<link href="/rmarkdown-libs/ionrangeslider-css/css/ion.rangeSlider.css" rel="stylesheet" />
<link href="/rmarkdown-libs/selectize/css/selectize.bootstrap3.css" rel="stylesheet" />
<script src="/rmarkdown-libs/selectize/js/selectize.min.js"></script>
<script src="/rmarkdown-libs/htmlwidgets/htmlwidgets.js"></script>
<script src="/rmarkdown-libs/plotly-binding/plotly.js"></script>
<script src="/rmarkdown-libs/typedarray/typedarray.min.js"></script>
<link href="/rmarkdown-libs/plotly-htmlwidgets-css/plotly-htmlwidgets.css" rel="stylesheet" />
<script src="/rmarkdown-libs/plotly-main/plotly-latest.min.js"></script>
<meta name="viewport" content="width=device-width, initial-scale=1" />

<link href="/rmarkdown-libs/bootstrap-grid/bootstrap-grid.min.css" rel="stylesheet" />

``` r
library(ggplot2)
library(thematic)
library(crosstalk)
library(plotly)
```

    ## 
    ## Attaching package: 'plotly'

    ## The following object is masked from 'package:ggplot2':
    ## 
    ##     last_plot

    ## The following object is masked from 'package:stats':
    ## 
    ##     filter

    ## The following object is masked from 'package:graphics':
    ## 
    ##     layout

``` r
thematic_rmd(bg = "#1D1E20", accent = "cyan", fg = "grey90", font = font_spec("Roboto"), sequential = firatheme::firaPalette(100), qualitative = firatheme::firaPalette(50))


get_plot <- function(df){
  p <- ggplot(df, aes(wt, mpg)) + 
    geom_point() + 
    annotate(y = 20, x = 20, geom = "text", label = "InvestCookies")

ggplotly(p)
}

bslib::bs_theme_dependencies(bslib::bs_theme(version = 3))
```

    ## [[1]]
    ## List of 9
    ##  $ name      : chr "jquery"
    ##  $ version   : chr "3.6.0"
    ##  $ src       :List of 1
    ##   ..$ file: chr "/Library/Frameworks/R.framework/Versions/4.1-arm64/Resources/library/jquerylib/lib/3.6.0"
    ##  $ meta      : NULL
    ##  $ script    : chr "jquery-3.6.0.min.js"
    ##  $ stylesheet: NULL
    ##  $ head      : NULL
    ##  $ attachment: NULL
    ##  $ all_files : logi TRUE
    ##  - attr(*, "class")= chr "html_dependency"
    ## 
    ## [[2]]
    ## List of 10
    ##  $ name      : chr "bootstrap"
    ##  $ version   : chr "3.4.1"
    ##  $ src       :List of 1
    ##   ..$ file: chr "/var/folders/sn/r9jht2fn49s5rgc9c066k4p80000gn/T//Rtmp3cYvvp/bslib-1f2869506c3528c3f2f262a99ddafb40"
    ##  $ meta      :List of 1
    ##   ..$ viewport: chr "width=device-width, initial-scale=1, shrink-to-fit=no"
    ##  $ script    : chr "bootstrap.min.js"
    ##  $ stylesheet: chr "bootstrap.min.css"
    ##  $ head      : NULL
    ##  $ attachment: NULL
    ##  $ package   : NULL
    ##  $ all_files : logi TRUE
    ##  - attr(*, "class")= chr "html_dependency"
    ## 
    ## [[3]]
    ## List of 9
    ##  $ name      : chr "bootstrap-accessibility"
    ##  $ version   : chr "1.0.6"
    ##  $ src       :List of 1
    ##   ..$ file: chr "/Library/Frameworks/R.framework/Versions/4.1-arm64/Resources/library/bslib/lib/bs-a11y-p"
    ##  $ meta      : NULL
    ##  $ script    : chr "plugins/js/bootstrap-accessibility.min.js"
    ##  $ stylesheet: NULL
    ##  $ head      : NULL
    ##  $ attachment: NULL
    ##  $ all_files : logi FALSE
    ##  - attr(*, "class")= chr "html_dependency"

``` r
shared_mtcars <- SharedData$new(mtcars)

bscols(widths = c(3,NA),
  list(
    filter_checkbox("cyl", "Cylinders", shared_mtcars, ~cyl, inline = TRUE),
    filter_slider("hp", "Horsepower", shared_mtcars, ~hp, width = "100%"),
    filter_select("auto", "Automatic", shared_mtcars, ~ifelse(am == 0, "Yes", "No"))
  ),
  get_plot(shared_mtcars)
  # plot_ly(shared_mtcars, x = ~wt, y = ~mpg) %>%  layout(paper_bgcolor  = "#1D1E20", plot_bgcolor  = "#1D1E20", annotations = list(text = "InvestCookies.ru", yanchor  = "auto", opacity = .5, font = list(size = 50)))
  
)
```

<div class="container-fluid crosstalk-bscols">
<div class="row">
<div class="col-xs-3">
<div id="cyl" class="form-group crosstalk-input-checkboxgroup crosstalk-input">
<label class="control-label" for="cyl">Cylinders</label>
<div class="crosstalk-options-group">
<label class="checkbox-inline">
<input type="checkbox" name="cyl" value="4"/>
<span>4</span>
</label>
<label class="checkbox-inline">
<input type="checkbox" name="cyl" value="6"/>
<span>6</span>
</label>
<label class="checkbox-inline">
<input type="checkbox" name="cyl" value="8"/>
<span>8</span>
</label>
</div>
<script type="application/json" data-for="cyl">{
  "map": {
    "4": ["Datsun 710", "Merc 240D", "Merc 230", "Fiat 128", "Honda Civic", "Toyota Corolla", "Toyota Corona", "Fiat X1-9", "Porsche 914-2", "Lotus Europa", "Volvo 142E"],
    "6": ["Mazda RX4", "Mazda RX4 Wag", "Hornet 4 Drive", "Valiant", "Merc 280", "Merc 280C", "Ferrari Dino"],
    "8": ["Hornet Sportabout", "Duster 360", "Merc 450SE", "Merc 450SL", "Merc 450SLC", "Cadillac Fleetwood", "Lincoln Continental", "Chrysler Imperial", "Dodge Challenger", "AMC Javelin", "Camaro Z28", "Pontiac Firebird", "Ford Pantera L", "Maserati Bora"]
  },
  "group": ["SharedDatacdd8864a"]
}</script>
</div>
<div class="form-group crosstalk-input crosstalk-input-slider js-range-slider" id="hp" style="width: 100%;">
<label class="control-label" for="hp">Horsepower</label>
<input data-skin="shiny" data-type="double" data-min="52" data-max="335" data-from="52" data-to="335" data-step="1" data-grid="true" data-grid-num="9.75862068965517" data-grid-snap="false" data-prettify-separator="," data-keyboard="true" data-keyboard-step="0.353356890459364" data-drag-interval="true" data-data-type="number"/>
<script type="application/json" data-for="hp">{
  "values": [52, 62, 65, 66, 66, 91, 93, 95, 97, 105, 109, 110, 110, 110, 113, 123, 123, 150, 150, 175, 175, 175, 180, 180, 180, 205, 215, 230, 245, 245, 264, 335],
  "keys": ["Honda Civic", "Merc 240D", "Toyota Corolla", "Fiat 128", "Fiat X1-9", "Porsche 914-2", "Datsun 710", "Merc 230", "Toyota Corona", "Valiant", "Volvo 142E", "Mazda RX4", "Mazda RX4 Wag", "Hornet 4 Drive", "Lotus Europa", "Merc 280", "Merc 280C", "Dodge Challenger", "AMC Javelin", "Hornet Sportabout", "Pontiac Firebird", "Ferrari Dino", "Merc 450SE", "Merc 450SL", "Merc 450SLC", "Cadillac Fleetwood", "Lincoln Continental", "Chrysler Imperial", "Duster 360", "Camaro Z28", "Ford Pantera L", "Maserati Bora"],
  "group": ["SharedDatacdd8864a"]
}</script>
</div>
<div id="auto" class="form-group crosstalk-input-select crosstalk-input">
<label class="control-label" for="auto">Automatic</label>
<div>
<select multiple></select>
<script type="application/json" data-for="auto">{
  "items": {
    "value": ["No", "Yes"],
    "label": ["No", "Yes"]
  },
  "map": {
    "No": ["Mazda RX4", "Mazda RX4 Wag", "Datsun 710", "Fiat 128", "Honda Civic", "Toyota Corolla", "Fiat X1-9", "Porsche 914-2", "Lotus Europa", "Ford Pantera L", "Ferrari Dino", "Maserati Bora", "Volvo 142E"],
    "Yes": ["Hornet 4 Drive", "Hornet Sportabout", "Valiant", "Duster 360", "Merc 240D", "Merc 230", "Merc 280", "Merc 280C", "Merc 450SE", "Merc 450SL", "Merc 450SLC", "Cadillac Fleetwood", "Lincoln Continental", "Chrysler Imperial", "Toyota Corona", "Dodge Challenger", "AMC Javelin", "Camaro Z28", "Pontiac Firebird"]
  },
  "group": ["SharedDatacdd8864a"]
}</script>
</div>
</div>
</div>
<div class="col-xs-9">
<div id="htmlwidget-1" style="width:100%;height:400px;" class="plotly html-widget"></div>
<script type="application/json" data-for="htmlwidget-1">{"x":{"data":[{"x":[2.62,2.875,2.32,3.215,3.44,3.46,3.57,3.19,3.15,3.44,3.44,4.07,3.73,3.78,5.25,5.424,5.345,2.2,1.615,1.835,2.465,3.52,3.435,3.84,3.845,1.935,2.14,1.513,3.17,2.77,3.57,2.78],"y":[21,21,22.8,21.4,18.7,18.1,14.3,24.4,22.8,19.2,17.8,16.4,17.3,15.2,10.4,10.4,14.7,32.4,30.4,33.9,21.5,15.5,15.2,13.3,19.2,27.3,26,30.4,15.8,19.7,15,21.4],"text":["wt: 2.620<br />mpg: 21.0","wt: 2.875<br />mpg: 21.0","wt: 2.320<br />mpg: 22.8","wt: 3.215<br />mpg: 21.4","wt: 3.440<br />mpg: 18.7","wt: 3.460<br />mpg: 18.1","wt: 3.570<br />mpg: 14.3","wt: 3.190<br />mpg: 24.4","wt: 3.150<br />mpg: 22.8","wt: 3.440<br />mpg: 19.2","wt: 3.440<br />mpg: 17.8","wt: 4.070<br />mpg: 16.4","wt: 3.730<br />mpg: 17.3","wt: 3.780<br />mpg: 15.2","wt: 5.250<br />mpg: 10.4","wt: 5.424<br />mpg: 10.4","wt: 5.345<br />mpg: 14.7","wt: 2.200<br />mpg: 32.4","wt: 1.615<br />mpg: 30.4","wt: 1.835<br />mpg: 33.9","wt: 2.465<br />mpg: 21.5","wt: 3.520<br />mpg: 15.5","wt: 3.435<br />mpg: 15.2","wt: 3.840<br />mpg: 13.3","wt: 3.845<br />mpg: 19.2","wt: 1.935<br />mpg: 27.3","wt: 2.140<br />mpg: 26.0","wt: 1.513<br />mpg: 30.4","wt: 3.170<br />mpg: 15.8","wt: 2.770<br />mpg: 19.7","wt: 3.570<br />mpg: 15.0","wt: 2.780<br />mpg: 21.4"],"key":["Mazda RX4","Mazda RX4 Wag","Datsun 710","Hornet 4 Drive","Hornet Sportabout","Valiant","Duster 360","Merc 240D","Merc 230","Merc 280","Merc 280C","Merc 450SE","Merc 450SL","Merc 450SLC","Cadillac Fleetwood","Lincoln Continental","Chrysler Imperial","Fiat 128","Honda Civic","Toyota Corolla","Toyota Corona","Dodge Challenger","AMC Javelin","Camaro Z28","Pontiac Firebird","Fiat X1-9","Porsche 914-2","Lotus Europa","Ford Pantera L","Ferrari Dino","Maserati Bora","Volvo 142E"],"type":"scatter","mode":"markers","marker":{"autocolorscale":false,"color":"rgba(229,229,229,1)","opacity":1,"size":5.66929133858268,"symbol":"circle","line":{"width":1.88976377952756,"color":"rgba(229,229,229,1)"}},"hoveron":"points","set":"SharedDatacdd8864a","showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","_isNestedKey":false,"frame":null},{"x":[20],"y":[20],"text":"InvestCookies","hovertext":"x: 20<br />y: 20","textfont":{"size":14.6645669291339,"color":"rgba(229,229,229,1)"},"type":"scatter","mode":"text","hoveron":"points","showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":26.2283105022831,"r":7.30593607305936,"b":40.1826484018265,"l":37.2602739726027},"plot_bgcolor":"rgba(40,41,43,1)","paper_bgcolor":"rgba(29,30,32,1)","font":{"color":"rgba(229,229,229,1)","family":"'Roboto'","size":14.6118721461187},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[0.58865,20.92435],"tickmode":"array","ticktext":["5","10","15","20"],"tickvals":[5,10,15,20],"categoryorder":"array","categoryarray":["5","10","15","20"],"nticks":null,"ticks":"outside","tickcolor":"rgba(182,182,182,1)","ticklen":3.65296803652968,"tickwidth":0.66417600664176,"showticklabels":true,"tickfont":{"color":"rgba(157,157,158,1)","family":"'Roboto'","size":11.689497716895},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(29,30,32,1)","gridwidth":0.66417600664176,"zeroline":false,"anchor":"y","title":{"text":"wt","font":{"color":"rgba(229,229,229,1)","family":"'Roboto'","size":14.6118721461187}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[9.225,35.075],"tickmode":"array","ticktext":["10","15","20","25","30","35"],"tickvals":[10,15,20,25,30,35],"categoryorder":"array","categoryarray":["10","15","20","25","30","35"],"nticks":null,"ticks":"outside","tickcolor":"rgba(182,182,182,1)","ticklen":3.65296803652968,"tickwidth":0.66417600664176,"showticklabels":true,"tickfont":{"color":"rgba(157,157,158,1)","family":"'Roboto'","size":11.689497716895},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(29,30,32,1)","gridwidth":0.66417600664176,"zeroline":false,"anchor":"x","title":{"text":"mpg","font":{"color":"rgba(229,229,229,1)","family":"'Roboto'","size":14.6118721461187}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":false,"legend":{"bgcolor":"rgba(29,30,32,1)","bordercolor":"transparent","borderwidth":1.88976377952756,"font":{"color":"rgba(229,229,229,1)","family":"'Roboto'","size":11.689497716895}},"hovermode":"closest","barmode":"relative","dragmode":"zoom"},"config":{"doubleClick":"reset","showSendToCloud":false},"source":"A","attrs":{"a0f16957fb7a":{"x":{},"y":{},"type":"scatter"},"a0f1f3f3c9e":{"x":{},"y":{}}},"cur_data":"a0f16957fb7a","visdat":{"a0f16957fb7a":["function (y) ","x"],"a0f1f3f3c9e":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.2,"selected":{"opacity":1},"debounce":0,"ctGroups":["SharedDatacdd8864a"]},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
</div>
</div>
</div>
script
<script async src="https://comments.app/js/widget.js?3" data-comments-app-website="WqvUgpX2" data-limit="5" data-color="343638"></script>
