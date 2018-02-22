#' Download a THREDDS dataset via a NetcdfSubset service
#'
#' @param ncss_url The url of a THREDDS NetcdfSubset service,
#' perhaps retrieved using threddr_list_services.
#' @param out_dir A directory in which to download the dataset.
#' Defaults to the current working directory.
#' @param bbox An optional object of class 'bbox' from which to construct a bounding box.
#' Must be in EPSG:4326.
#' Defaults to NULL, which will download the entire NetCDF dataset.
#' @param vars A character vector of variable names,
#' perhaps retrieved using threddr_dodsC_list_vars.
#' Defaults to all available variables.
#' @param overwrite A logical; whether to overwrite the downloaded file if it exists.
#' Defaults to 'TRUE'.
#' @param add_args A named list of additional NetcdfSubset arguments for the URL.
#' @param ... Additional arguments passed on to httr::GET.
#'
#' @return The path to the downloaded dataset.
#'
#' @export
#' @importFrom magrittr %>% %<>%
#' @examples
#' \dontrun{
#'   threddr_ncss_download(ncss_url = "https://cida.usgs.gov/thredds/ncss/macav2metdata_monthly_historical/dataset.html",
#'                         bbox = st_bbox(c(xmin = -116, xmax = -115, ymax = 44, ymin = 45)),
#'                         vars = c("huss_BNU-ESM_r1i1p1_historical","huss_CCSM4_r6i1p1_historical"))
#' }
threddr_ncss_download <- function(ncss_url,
                                  out_dir = "./",
                                  bbox = NULL,
                                  vars = NULL,
                                  add_args = NULL,
                                  overwrite = TRUE,
                                  ...
){

  base_url <- ncss_url %>%
    stringr::str_remove("([^/]+$)") %>%
    stringr::str_remove("(\\/+$)")

  if(!is.null(vars)){
    vars <- base_url %>%
      stringr::str_c("/dataset.xml") %>%
      xml2::read_xml() %>%
      xml2::xml_find_all(".//grid") %>%
      xml2::xml_attr("name")
  }

  query <- list(var = vars %>% stringr::str_c(collapse = ","),
                north = bbox[["ymax"]],
                west = bbox[["xmin"]],
                east = bbox[["xmax"]],
                south = bbox[["ymin"]],
                temporal = "all")

  if(!is.null(args))
    query %<>% c(args)

  out_file <- stringr::str_c(out_dir,"/",basename(base_url),".nc")

  httr::GET(base_url,
            query = query,
            httr::write_disk(out_file,
                             overwrite = overwrite),
            ...)

  return(out_file)
}
