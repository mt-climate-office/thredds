
<!-- README.md is generated from README.Rmd. Please edit that file -->

# thredds

[![Travis build
status](https://travis-ci.org/bocinsky///thredds.svg?branch=master)](https://travis-ci.org/bocinsky///thredds)
[![Coverage
status](https://img.shields.io/codecov/c/github/bocinsky/thredds/master.svg)](https://codecov.io/github/bocinsky/thredds?branch=master)
[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/thredds)](https://cran.r-project.org/package=thredds)

[THREDDS data
servers](http://www.unidata.ucar.edu/software/thredds/current/tds/) are
webservers that provide access to gridded data—in the form of
[NetCDF](https://www.unidata.ucar.edu/software/netcdf/) files—via a
handy RESTful API (among other protocols). THREDDS servers not only
serve data, but provide tools for subsetting gridded data in space and
time on the server, reducing the amount of data the end user must
download. **thredds** is an R front end to THREDDS servers designed to
make exploration, subsetting, and download of THREDDS data into R as
simple as possible.

## Installation

You can install threddr from github with:

``` r
# install.packages("devtools")
devtools::install_github("bocinsky/thredds")
```

## Example

**thredds** enables exploration, subsetting, and downloading from
THREDDS servers through a series of R commands. To enable easy
tab-completion, all **thredds** functions have a “`tds_`” prefix. Here,
we first explore the structure of the CIDA THREDDS server hosted by
USGS. We do so using the `tds_list_datasets` function.

``` r
library(thredds)
library(tidyverse)
#> ── Attaching packages ────────────────────────────────────────────────────────────────────────────────────────── tidyverse 1.2.1 ──
#> ✔ ggplot2 2.2.1.9000     ✔ purrr   0.2.4     
#> ✔ tibble  1.4.2          ✔ dplyr   0.7.4     
#> ✔ tidyr   0.8.0          ✔ stringr 1.3.0     
#> ✔ readr   1.1.1          ✔ forcats 0.3.0
#> ── Conflicts ───────────────────────────────────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()
library(magrittr)
#> 
#> Attaching package: 'magrittr'
#> The following object is masked from 'package:purrr':
#> 
#>     set_names
#> The following object is masked from 'package:tidyr':
#> 
#>     extract

# The base url of the CIDA THREDDS server
cida <- "https://cida.usgs.gov/thredds/"

datasets <- tds_list_datasets(thredds_url = cida)
datasets
#> # A tibble: 110 x 3
#>    dataset                                 path                      type 
#>    <chr>                                   <chr>                     <chr>
#>  1 CIDA THREDDS Holdings                   https://cida.usgs.gov/th… data…
#>  2 Parameter-elevation Regressions on Ind… https://cida.usgs.gov/th… data…
#>  3 Parameter-elevation Regressions on Ind… https://cida.usgs.gov/th… data…
#>  4 Gridded Meteorological Observations 19… https://cida.usgs.gov/th… data…
#>  5 Gridded Meteorological Observations 19… https://cida.usgs.gov/th… data…
#>  6 University of Idaho Gridded Surface Me… https://cida.usgs.gov/th… data…
#>  7 National Stage IV Quantitative Precipi… https://cida.usgs.gov/th… data…
#>  8 Future LOCA                             https://cida.usgs.gov/th… data…
#>  9 Historical LOCA                         https://cida.usgs.gov/th… data…
#> 10 Daily Future MACAv2METDATA              https://cida.usgs.gov/th… data…
#> # ... with 100 more rows
```

This returns a data frame with dataset names and their paths. It also
will return nested catalogs, should there be any. We can then use the
`tds_list_services` function to list all of the THREDDS services
available for a particular datasets. Lets list the services for “Future
LOCA” dataset:

``` r
loca_url <- datasets[datasets$dataset == "Future LOCA",]$path
loca_url
#> [1] "https://cida.usgs.gov/thredds/catalog.html?dataset=cida.usgs.gov/loca_future"

loca_services <- tds_list_services(loca_url)
loca_services
#> # A tibble: 5 x 2
#>   service      path                                                       
#>   <chr>        <chr>                                                      
#> 1 OPENDAP      https://cida.usgs.gov/thredds/dodsC/loca_future.html       
#> 2 NetcdfSubset https://cida.usgs.gov/thredds/ncss/loca_future/dataset.html
#> 3 NCML         https://cida.usgs.gov/thredds/ncml/loca_future?catalog=htt…
#> 4 UDDC         https://cida.usgs.gov/thredds/uddc/loca_future?catalog=htt…
#> 5 ISO          https://cida.usgs.gov/thredds/iso/loca_future?catalog=http…
```

Similarly to `tds_list_datasets`, `tds_list_services` returns a data
frame with service names and URLs.

### Accessing data through the NetCDF Subset service

The first service functions to be developed in **thredds** are for the
NetCDF Subset service (“ncss”). Here, we first query the variables
available in the dataset, which in the case of the LOCA dataset
represent combinations of [CMIP5
models](https://pcmdi.llnl.gov/mips/cmip5/), [representative climate
pathways](https://en.wikipedia.org/wiki/Representative_Concentration_Pathways)
(RCPs, or emissions scenarios), and climate variables. The other fields
in the table will vary based on the
dataset.

``` r
loca_ncss <- loca_services[loca_services$service == "NetcdfSubset",]$path
loca_ncss
#> [1] "https://cida.usgs.gov/thredds/ncss/loca_future/dataset.html"

loca_vars <- tds_ncss_list_vars(ncss_url = loca_ncss)
loca_vars
#> # A tibble: 180 x 11
#>    name     desc  shape  type  units  `_FillValue` long_name missing_value
#>    <chr>    <chr> <chr>  <chr> <chr>  <chr>        <chr>     <chr>        
#>  1 pr_ACCE… pr    time … float kg m-… 1.0E30       pr        1.0000000150…
#>  2 pr_ACCE… pr    time … float kg m-… 1.0E30       pr        1.0000000150…
#>  3 pr_ACCE… pr    time … float kg m-… 1.0E30       pr        1.0000000150…
#>  4 pr_ACCE… pr    time … float kg m-… 1.0E30       pr        1.0000000150…
#>  5 pr_CCSM… pr    time … short mm     -9999        pr        -9999        
#>  6 pr_CCSM… pr    time … short mm     -9999        pr        -9999        
#>  7 pr_CESM… pr    time … short mm     -9999        pr        -9999        
#>  8 pr_CESM… pr    time … short mm     -9999        pr        -9999        
#>  9 pr_CESM… pr    time … short mm     -9999        pr        -9999        
#> 10 pr_CESM… pr    time … short mm     -9999        pr        -9999        
#> # ... with 170 more rows, and 3 more variables: history <chr>,
#> #   `_ChunkSizes` <chr>, scale_factor <chr>
```

Finally, we can download some data. Lets download the maximum daily
temperature data from the Community Climate System Model (CCSM4), for
both RCPs so we can compare them. We use the `tds_ncss_download`
function; we have to provide the URL of the NetCDF Subset service (the
same we used for `tds_ncss_list_vars` above), a character vector of
variable names, and a file name and location for the output. We’ll
create a temporary location to put the file for now.

``` r
CCSM4 <- tds_ncss_download(ncss_url = loca_ncss,
                           out_file = paste0(tempdir(),"/CCSM4.nc"),
                           bbox = sf::st_bbox(c(xmin = -116, xmax = -115, ymin = 44, ymax = 45)),
                           vars = c("tasmax_CCSM4_r6i1p1_rcp45","tasmax_CCSM4_r6i1p1_rcp85"))

CCSM4
#> [1] "/var/folders/jt/hhw0gdbj08bdxsbw15rcx_j40000gn/T//Rtmp6JULYC/CCSM4.nc"
```

The `tds_ncss_download` function outputs the path to the downloaded
data. In R, we can load a NetCDF using the `brick()` function from the
*raster* package. Here, we do so, and then aggregate and plot the data
in a couple of ways. Note that we have to import each variable
separately when using *raster*; the forthcoming package
[*stars*](https://r-spatial.github.io/stars/) will be able to load many
variables simultaneously.

``` r

CCSM4_rcp45 <- raster::brick(CCSM4, varname = "tasmax_CCSM4_r6i1p1_rcp45")
#> Loading required namespace: ncdf4
CCSM4_rcp85 <- raster::brick(CCSM4, varname = "tasmax_CCSM4_r6i1p1_rcp85")

# Calculate the average precipitation across space, and plot the time series
CCSM4_rcp45 %<>%
  raster::cellStats(mean)

CCSM4_rcp85 %<>%
  raster::cellStats(mean)

# Create a data frame
CCSM4_timeseries <- tibble::tibble(Date = names(CCSM4_rcp45) %>%
                                     stringr::str_remove("X") %>%
                                     lubridate::as_date(),
                                   `RCP 4.5` = CCSM4_rcp45,
                                   `RCP 8.5` = CCSM4_rcp85)

# Let's extract the average temperature for June for each year, and plot
CCSM4_timeseries %>%
  filter(lubridate::month(Date) == 6) %>%
  mutate(Year = lubridate::year(Date) %>%
                  as.integer()) %>%
  group_by(Year) %>%
  summarise_at(.vars = dplyr::vars(`RCP 4.5`,
                                          `RCP 8.5`),
                      .funs = mean) %>%
  gather(`Emissions\nScenario`, Value, -Year) %>%
  ggplot(aes(x = Year,
             y = Value,
             color = `Emissions\nScenario`)) +
  geom_line() +
  geom_smooth() +
  ylab("Average June Daytime\nMaximum Temperature (C)") 
#> `geom_smooth()` using method = 'loess' and formula 'y ~ x'
```

![](README-ncss-plot-1.png)<!-- -->

## Contributing

I welcome contributors to the development of the **thredds** package.
Please note that this project is released with a [Contributor Code of
Conduct](CONDUCT.md). By participating in this project you agree to
abide by its terms.
