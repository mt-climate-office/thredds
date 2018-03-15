utils::globalVariables(c('html',
                            'path',
                            'html',
                            'ol',
                            'path',
                         'type'))
#' Get a list of available datasets on a THREDDS data server.
#'
#' @param thredds_url A string providing the URL of a THREDDS server,
#' usually ending with '/thredds/'.
#' @param recursive Should the function recurse into nested THREDDS catalogs.
#' Defaults to 'FALSE'.
#'
#' @return A data_frame containing dataset names and paths.
#'
#' @export
#' @importFrom magrittr %>% %$% %<>%
#' @examples
#' library(thredds)
#' tds_list_datasets(thredds_url = "https://cida.usgs.gov/thredds/")
#' tds_list_datasets(thredds_url = "http://thredds.northwestknowledge.net:8080/thredds/")
tds_list_datasets <- function(thredds_url,
                                  recursive = FALSE){

  thredds_url_base <- if(thredds_url %>%
                 endsWith(".html")){
    thredds_url %>%
      stringr::str_remove("([^/]+$)")
  } else thredds_url

  base_url_parsed <- httr::parse_url(thredds_url)
  base_url_parsed$query <- NULL
  # base_url_parsed$path <- NULL

  out <- thredds_url %>%
    # stringr::str_c("catalog.xml") %>%
    xml2::read_html() %>%
    xml2::as_list() %$%
    html %$%
    body %$%
    table %>%
    purrr::map_dfr(function(x){if(is.null(x$td$a$tt[[1]])) return(NULL)
      tibble::tibble(dataset = x$td$a$tt[[1]],
                     path = x$td$a %>% attr("href"))}) %>%
    dplyr::mutate(path = purrr::map_chr(path,
                                        function(p){
                                          base_url_parsed$path <- paste0(base_url_parsed$path,p)
                                          httr::build_url(base_url_parsed) %>%
                                            utils::URLdecode()
                                        }
    ),
    type = ifelse(stringr::str_detect(path,
                                      stringr::coll("dataset=",TRUE)),"dataset","catalog"))

  if(recursive){
    out %<>%
      dplyr::filter(type != "dataset") %$%
      path %>%
      purrr::map_dfr(tds_list_datasets,
                     recursive = TRUE,
                     datasets_only = FALSE) %>%
      dplyr::bind_rows(out)
  }

  return(out)
}
