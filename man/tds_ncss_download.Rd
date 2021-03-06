% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tds_ncss_download.R
\name{tds_ncss_download}
\alias{tds_ncss_download}
\title{Download a THREDDS dataset via a NetcdfSubset service}
\usage{
tds_ncss_download(ncss_url, out_file, bbox, vars = NULL, ncss_args = NULL,
  overwrite = TRUE, ...)
}
\arguments{
\item{ncss_url}{The url of a THREDDS NetcdfSubset service,
perhaps retrieved using tds_list_services.}

\item{out_file}{A file in which to download the dataset.}

\item{bbox}{An optional object of class 'bbox' from which to construct a bounding box.
Must be in EPSG:4326.
Defaults to NULL, which will download the entire NetCDF dataset.}

\item{vars}{A character vector of variable names,
perhaps retrieved using tds_ncss_list_vars.
Defaults to all available variables.}

\item{ncss_args}{A named list of additional NetcdfSubset arguments for the URL.}

\item{overwrite}{A logical; whether to overwrite the downloaded file if it exists.
Defaults to 'TRUE'.}

\item{...}{Other arguments passed on to \code{\link[httr:GET]{httr::GET()}}.}
}
\value{
The path to the downloaded dataset.
}
\description{
Download a THREDDS dataset via a NetcdfSubset service
}
\examples{
library(thredds)
  out.dir <- tempfile()
  dir.create(out.dir,
    showWarnings = FALSE,
    recursive = TRUE)

ncss <- "https://cida.usgs.gov/thredds/ncss/macav2metdata_monthly_historical/dataset.html"
tds_ncss_download(ncss_url = ncss,
                  bbox = sf::st_bbox(c(xmin = -116, xmax = -115, ymin = 44, ymax = 45)),
                  vars = c("huss_BNU-ESM_r1i1p1_historical","huss_CCSM4_r6i1p1_historical"),
                  out_file = paste0(out.dir,"/macav2metdata_monthly_historical.nc"))
}
