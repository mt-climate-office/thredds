#' List THREDDS dataset service endpoints
#'
#' @param dataset_url The url of a THREDDS dataset,
#' perhaps retrieved using tds_list_datasets.
#'
#' @return A data_frame containing dataset service endpoints and paths.
#' @importFrom magrittr %>% %$%
#' @export
#'
#' @examples
#' library(thredds)
#' thredds_data <- "https://cida.usgs.gov/thredds/catalog.html?dataset=cida.usgs.gov/prism_v2"
#' tds_list_services(dataset_url = thredds_data)
tds_list_services <- function(dataset_url){

  base_url_parsed <- httr::parse_url(dataset_url)
  base_url_parsed$query <- NULL
  base_url_parsed$path <- NULL

  dataset_url %>%
    xml2::read_html() %>%
    xml2::as_list() %$%
    html %$%
    body %$%
    ol %>%
    purrr::map_dfr(
      function(x){
        if(is.null(names(x))) return(NULL)
        tibble::tibble(service = x$b[[1]] %>%
                         stringr::str_remove(stringr::coll(":",TRUE)),
                       path = x$a %>% attr("href"))
      }
    ) %>%
    dplyr::mutate(path = purrr::map_chr(path,
                                        function(p){
                                          base_url_parsed$path <- p
                                          httr::build_url(base_url_parsed) %>%
                                            utils::URLdecode()
                                        }
    ))

}
