---
title: "R data.table and Apple M1"
author: "🍪🍪🪙"
date: 2021-05-31
categories: ["data science"]
tags: ["R", "advanced"]
ShowToc: true
---



R data.table and Apple M1 installation on Big Sur supporting openmp multithreading

## Introduction

Official release of R4.1.0 has bring long awaiting native support of Apple M1 to R/Mac users. Of course Rosetta engine provided by Apple do its job very well. Nevertheless we always eager for more performance and less time doing our data wrangling job. Unfortunately there are still lack of information regarding working in new environment. Basic installation of data.table to any macos causes a notification:

    **********
    This installation of data.table has not detected OpenMP support. 
    It should still work but in single-threaded mode. 
    If this is a Mac, please ensure you are using R>=3.4.0 and have followed our Mac instructions here:
    https://github.com/Rdatatable/data.table/wiki/Installation. 
    This warning message should not occur on Windows or Linux. If it does, please file a GitHub issue.
    **********

Notification leads to [data.table installation guide](https://github.com/Rdatatable/data.table/wiki/Installation#openmp-enabled-compiler-for-mac) describing several steps necessary for obtaining multithreading mode. Actually there is no openmp support by Apple. This obligates to compile data.table on device from source using command:


```r
install.packages("data.table", type = "source",
    repos = "https://Rdatatable.gitlab.io/data.table")
```

Guidance provides several options of macos preparing for installation from source. For my Rosetta installation I prefer to use compiler: **GCC (Official GNU fortran) ver** basicaly because of lesser HD space. Unfortunately this option turns to be absolutely useless in case of native aarch64 installation. After several attempts using different options provided by guidance I came to decision all described options are useless regarding aarch64 case. Moreover searching solution across internet shows nothing regarding the case.

## Solution

Solution below provided on your own responsibility and considered to be as experiential. I highly recommend to keep previous R installation nearby with new one for unpredictable issues cased by compiling another packages like [stringi issue](https://github.com/Rdatatable/data.table/issues/4907) or rcpp or whatever.

There will be used option using llvm. Steps are correspond to data.table guidance except 0 one.

### Step 0 (prepare RStudio)

First of all you need to install preview release of [RStudio](https://www.rstudio.com/products/rstudio/download/preview/) which supports **Apple Silicon** (aarch64).

### Step 1 (100% according guidance)

First, ensure that you have command line tools installed. **Do NOT skip** this step. It is essential. See <https://github.com/Rdatatable/data.table/issues/1692>. From the terminal, type:


```bash
xcode-select --install
```

If you get an error message: `xcode-select: error: command line tools are already installed, use "Software Update" to install updates`, then you already have command line tools and can proceed to the next step. Else please follow the onscreen instructions and install it first.

### Step 2 (100% according guidance)

Then, install [homebrew](http://brew.sh/) if you have not already. After that, we can install the OpenMP enabled `clang` from the terminal by typing:


```bash
# update: seems like this installs clang with openmp support, 
# as pointed out by @botanize in #1817
brew update && brew install llvm
```

Note that homebrew have separate location for installing arm version of packages: `opt/homebrew`, check [details](https://brew.sh/2020/12/01/homebrew-2.6.0/). So we need to reconfigure our building enviroment accordingly.

### Step 3 (modified guidance)

Add the following lines to the file `~/.R/Makevars` using your favourite text editor. It's likely you need to create the `.R`directory and the file `Makevars` in it if it doesn't already exist.


```bash
# if you downloaded llvm manually above, replace with your chosen NEW_PATH/clang
LLVM_LOC = /opt/homebrew/opt/llvm
CC=$(LLVM_LOC)/bin/clang -fopenmp
CXX=$(LLVM_LOC)/bin/clang++ -fopenmp
# -O3 should be faster than -O2 (default) level optimisation ..
CFLAGS=-g -O3 -Wall -pedantic -std=gnu99 -mtune=native -pipe
CXXFLAGS=-g -O3 -Wall -pedantic -std=c++11 -mtune=native -pipe
LDFLAGS=-L/opt/homebrew/opt/gettext/lib -L$(LLVM_LOC)/lib -Wl,-rpath,$(LLVM_LOC)/lib
CPPFLAGS=-I/opt/homebrew/opt/gettext/include -I$(LLVM_LOC)/include
```

The only difference of configuration above with original one is substitution of compiler links to `/opt/homebrew/...`. After that all necessary configurations are done and package ready to be installed from source.

### Perfomance tests

Is it worth to migrate from Rosetta to native support? Difficulties with installation and supporting several lib directories considered to be as cons but outcome seems to be valuable. There are some benchmark results below.

#### Hardware

1.  MacBook Air (M1, 2020) \| Memory 16 Gb \| Big Sur 11.4

2.  Core(TM) i7-7700 CPU \| Memory 44 Gb \| Ubuntu 20.04.2 LTS

Ubuntu running as virtualized instance on remote server. Both systems uses pretty fast SSD and were tested with 4-way multithreading option activated. All tests were made on refreshed session (also see [SessionInfo()](#sessioninfo)).

#### Data generation

I guess some simple math calculation for base R would be appropriate profile for emulating real tasks. I also choose the most usefull functions for me from data.table package. Such approach could not be named comprehensive and objective but as for me it is better than nothing.


```r
library(bench)
library(data.table) 

smpl0 <- rexp(3, n = 5e6) # for R base iteration 
smpl1 <- data.table(fctr = sample(letters, n, replace = TRUE), num1 = rnorm(n, 3, 4), num2 = sample(1:100, n, replace = TRUE), num3 = runif(n, 0, 100)) 
smpl2 <- data.table(fctr = sample(letters, 26), num1 = rnorm(26, 3, 4), num2 = sample(1:100, 26, replace = TRUE), num3 = runif(26, 0, 100))

# base R simple benchmarking 
mark(min_time = .1, min_iterations = 50,
  lapply(smpl0, log),
  purrr::map(smpl0, log), # some additional time needed to attach function
  as.list(log(smpl0)))

# data.table common dunction usage
mark(min_time = .1, min_iterations = 50, check = FALSE, 
             smpl1[, lapply(.SD, mean), .SDcols = is.numeric],
             smpl1[smpl2, on = "fctr"], 
             uniqueN(smpl1, by = c("fctr", "num2")))
```

#### Iteration with base R and purrr package

##### Intel comparible hardware running Ubuntu


```r
  expression                 min   median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time
  <bch:expr>            <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl> <int> <dbl>   <bch:tm>
1 lapply(smpl, log)         1.2s    1.44s     0.554    38.1MB    0.853    50    77       1.5m
2 purrr::map(smpl, log)    4.89s    6.72s     0.141    38.1MB    0.761    50   270      5.92m
3 as.list(log(smpl))    124.93ms  215.6ms     2.78     76.3MB    1.06     50    19        18s
```

##### Rosseta emulation mode


```r
  expression                  min   median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time
  <bch:expr>             <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl> <int> <dbl>   <bch:tm>
1 lapply(smpl0, log)     978.31ms    1.33s     0.569    38.1MB    0.762    50    67      1.47m
2 purrr::map(smpl0, log)    3.84s    5.23s     0.169    38.1MB    0.790    50   234      4.94m
3 as.list(log(smpl0))     95.75ms 132.74ms     3.23     76.3MB    0.968    50    15      15.5s
```

It seems Rosetta emulation does it's work very well showing **5-10%** advantage over intel comparable platform.

##### Native arm mode


```r
# A tibble: 3 x 9
  expression                  min   median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time
  <bch:expr>             <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl> <int> <dbl>   <bch:tm>
1 lapply(smpl0, log)     699.88ms 763.53ms     1.15     38.1MB     1.15    50    50     43.44s
2 purrr::map(smpl0, log)    2.56s    3.68s     0.239    38.4MB     1.08    50   226      3.49m
3 as.list(log(smpl0))     67.98ms  76.13ms     6.23     76.3MB     2.24    50    18      8.02s
```

Native support shows more solid results. It seems to be **twice faster** than Rosetta mode. Very promising!

#### Some wrangling with data.table

##### Intel comparible hardware running Ubuntu


```r
# A tibble: 3 x 9
  expression                                            min   median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time
  <bch:expr>                                       <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl> <int> <dbl>   <bch:tm>
1 smpl1[, lapply(.SD, mean), .SDcols = is.numeric] 485.05ms  487.4ms     2.02      1.8MB   0         50     0     24.74s
2 smpl1[smpl2, on = "fctr"]                           4.58s    5.46s     0.181    5.96GB   0.184     50    51      4.61m
3 uniqueN(smpl1, by = c("fctr", "num2"))           720.81ms    1.33s     0.779   381.5MB   0.0623    50     4      1.07m
```

##### Rosseta emulation mode


```r
# A tibble: 3 x 9
  expression                                            min   median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time
  <bch:expr>                                       <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl> <int> <dbl>   <bch:tm>
1 smpl1[, lapply(.SD, mean), .SDcols = is.numeric]   25.29s   25.85s    0.0365   81.02KB    0        50     0     22.86m
2 smpl1[smpl2, on = "fctr"]                           4.57s    4.96s    0.199     5.96GB    0.199    50    50      4.18m
3 uniqueN(smpl1, by = c("fctr", "num2"))           570.96ms 596.29ms    1.49    381.48MB    0.119    50     4     33.62s
```

data.table functions shows contrudictionary results:

1.  Aggregation function shows huge gap between intel-base system and Rosetta mode. Rosetta is slower for \~50 times!!! Its interesting result and hardly could be easily explained. For proving case I reset R session and repeat test several times but results were pretty much the same.

2.  Left join seems to be faster for Rosetta like it is for base-r level **5-10%**

3.  Calculating unique observation is more than **two time** faster on Rosetta than intel-based

##### Native arm mode


```r
# A tibble: 3 x 9
  expression                                           min   median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time
  <bch:expr>                                      <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl> <int> <dbl>   <bch:tm>
1 smpl[, lapply(.SD, mean), .SDcols = is.numeric] 462.24ms    464ms     2.12    81.02KB    0        50     0     23.63s
2 smpl1[smpl2, on = "fctr"]                          4.61s     4.9s     0.205    5.96GB    0.410    50   100      4.07m
3 uniqueN(smpl1, by = c("fctr", "num2"))          518.12ms  577.3ms     1.51   381.48MB    0.121    50     4     33.19s
```

Interestingly native mode shows slight advantage over Rosetta mode for left join and unique calculation. However performance for aggregation grows dramatically and shows small advantage over intel-based system (about **5%**).

#### SessionInfo() {#sessioninfo}

##### Intel comparible hardware running Ubuntu


```r
R version 4.0.4 (2021-02-15)
Platform: x86_64-pc-linux-gnu (64-bit)
Running under: Ubuntu 20.04.2 LTS

Matrix products: default
BLAS:   /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.9.0
LAPACK: /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.9.0

locale:
 [1] LC_CTYPE=ru_RU.UTF-8       LC_NUMERIC=C               LC_TIME=ru_RU.UTF-8        LC_COLLATE=ru_RU.UTF-8     LC_MONETARY=ru_RU.UTF-8    LC_MESSAGES=ru_RU.UTF-8   
 [7] LC_PAPER=ru_RU.UTF-8       LC_NAME=C                  LC_ADDRESS=C               LC_TELEPHONE=C             LC_MEASUREMENT=ru_RU.UTF-8 LC_IDENTIFICATION=C       

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] forcats_0.5.1     stringr_1.4.0     dplyr_1.0.6       purrr_0.3.4       readr_1.4.0       tidyr_1.1.3       tibble_3.1.2      ggplot2_3.3.3     tidyverse_1.3.1  
[10] data.table_1.14.0 bench_1.1.1   
```

##### Rosseta emulation mode


```r
R version 4.0.5 (2021-03-31)
Platform: x86_64-apple-darwin17.0 (64-bit)
Running under: macOS Big Sur 11.4

Matrix products: default
LAPACK: /Library/Frameworks/R.framework/Versions/4.0/Resources/lib/libRlapack.dylib

locale:
[1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] data.table_1.14.1 bench_1.1.1       forcats_0.5.1     stringr_1.4.0     dplyr_1.0.5       purrr_0.3.4       readr_1.4.0       tidyr_1.1.3       tibble_3.1.1     
[10] ggplot2_3.3.3     tidyverse_1.3.1 
```

##### Native arm mode


```r
R version 4.1.0 (2021-05-18)
Platform: aarch64-apple-darwin20 (64-bit)
Running under: macOS Big Sur 11.4

Matrix products: default
LAPACK: /Library/Frameworks/R.framework/Versions/4.1-aarch64/Resources/lib/libRlapack.dylib

locale:
[1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] forcats_0.5.1     stringr_1.4.0     dplyr_1.0.6       purrr_0.3.4       readr_1.4.0       tidyr_1.1.3       tibble_3.1.2      ggplot2_3.3.3     tidyverse_1.3.1  
[10] data.table_1.14.1 bench_1.1.1      
```

#### Conclusions

1.  Running R and data.table native mode is experimental so far and practitioners come across lack of information for meeting their macos environment to new requirements.

2.  However native mode brings solid performance upgrade over Rosetta mode for base R. Calculations are twice faster.

3.  Drastic perfomance downgrade of aggregation function looks surprising for data.table calculations running Rosetta mode. However running native mode fixes it out.

#### Some recommendations

1.  Be ready that something might goes wrong

2.  Keep old R version as an backup plan

3.  Use Rswitch for switching between old and new R versions [RSwitch](https://rud.is/rswitch/)
