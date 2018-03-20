#' Download a THREDDS dataset via a NetcdfSubset service
#'
#' @param ncss_url The url of a THREDDS NetcdfSubset service,
#' perhaps retrieved using tds_list_services.
#' @param out_file A file in which to download the dataset.
#' @param bbox An optional object of class 'bbox' from which to construct a bounding box.
#' Must be in EPSG:4326.
#' Defaults to NULL, which will download the entire NetCDF dataset.
#' @param vars A character vector of variable names,
#' perhaps retrieved using tds_ncss_list_vars.
#' Defaults to all available variables.
#' @param overwrite A logical; whether to overwrite the downloaded file if it exists.
#' Defaults to 'TRUE'.
#' @param ncss_args A named list of additional NetcdfSubset arguments for the URL.
#' @param ... Other arguments passed on to [httr::GET()].
#'
#' @return The path to the downloaded dataset.
#'
#' @export
#' @importFrom magrittr %>% %<>%
#' @examples
#' library(thredds)
#'   out.dir <- tempfile()
#'   dir.create(out.dir,
#'     showWarnings = FALSE,
#'     recursive = TRUE)
#'
#' ncss <- "https://cida.usgs.gov/thredds/ncss/macav2metdata_monthly_historical/dataset.html"
#' tds_ncss_download(ncss_url = ncss,
#'                   bbox = sf::st_bbox(c(xmin = -116, xmax = -115, ymin = 44, ymax = 45)),
#'                   vars = c("huss_BNU-ESM_r1i1p1_historical","huss_CCSM4_r6i1p1_historical"),
#'                   out_file = paste0(out.dir,"/macav2metdata_monthly_historical.nc"))
tds_ncss_download <- function(ncss_url,
                                  out_file,
                                  bbox,
                                  vars = NULL,
                                  ncss_args = NULL,
                                  overwrite = TRUE,
                                  ...
){

  base_url <- ncss_url %>%
    stringr::str_remove("([^/]+$)") %>%
    stringr::str_remove("(\\/+$)")

  if(is.null(vars)){
    vars <- tds_ncss_list_vars(ncss_url)
  }

  query <- list(var = vars %>% stringr::str_c(collapse = ","),
                north = bbox[["ymax"]],
                west = bbox[["xmin"]],
                east = bbox[["xmax"]],
                south = bbox[["ymin"]])

  if(!is.null(ncss_args))
    query %<>% c(ncss_args)

  if(missing(out_file))
    out_file <- stringr::str_c("./",basename(base_url),".nc")

  dir.create(dirname(out_file),
             recursive = TRUE,
             showWarnings = FALSE)

  if(!overwrite & file.exists(out_file))
    return(out_file)

  httr::GET(base_url,
            query = query,
            httr::write_disk(out_file,
                             overwrite = overwrite),
            ...)

  return(out_file)
}
