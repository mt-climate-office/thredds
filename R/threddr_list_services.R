#' List THREDDS dataset service endpoints
#'
#' @param dataset_url The url of a THREDDS dataset,
#' perhaps retrieved using threddr_list_datasets.
#'
#' @return A data_frame containing dataset service endpoints and paths.
#' @importFrom magrittr %>% %$%
#' @export
#'
#' @examples
#' threddr_list_services(dataset_url = "https://cida.usgs.gov/thredds/catalog.html?dataset=cida.usgs.gov/prism_v2")
threddr_list_services <- function(dataset_url){
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
                                        utils::URLdecode))
}
