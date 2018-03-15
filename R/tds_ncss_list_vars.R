#' List available variables of a THREDDS dataset via a NetcdfSubset service
#'
#' @param ncss_url The url of a THREDDS NetcdfSubset service,
#' perhaps retrieved using tds_list_services.
#'
#' @return A data frame of variables and their attributes
#'
#' @export
#' @importFrom magrittr %>%
#' @examples
#' library(thredds)
#' ncss <- "https://cida.usgs.gov/thredds/ncss/macav2metdata_monthly_historical/dataset.html"
#' tds_ncss_list_vars(ncss_url = ncss)
#'
tds_ncss_list_vars <- function(ncss_url){

  base_url <- ncss_url %>%
    stringr::str_remove("([^/]+$)") %>%
    stringr::str_remove("(\\/+$)")

  base_url %>%
    stringr::str_c("/dataset.xml") %>%
    xml2::read_xml() %>%
    xml2::xml_find_all(".//grid") %>%
    purrr::map_dfr(function(x){

      xml2::xml_attrs(x) %>%
        as.list() %>%
        tibble::as_tibble() %>%
        dplyr::bind_cols(x %>%
                           xml2::xml_find_all(".//attribute") %>%
                           xml2::xml_attrs() %>%
                           purrr::map(`[`,c("name","value")) %>%
                           purrr::map(function(i){
                             out <- i["value"]
                             names(out) <- i["name"]
                             out
                             }) %>%
                           unlist() %>%
                           as.matrix() %>%
                           t() %>%
                           tibble::as_tibble()
        )
    })

}
