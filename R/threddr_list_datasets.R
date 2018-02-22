utils::globalVariables(c('html',
                            'path',
                            'html',
                            'ol',
                            'path'))
#' Get a list of available datasets on a THREDDS data server.
#'
#' @param thredds_url A string providing the URL of a THREDDS server,
#' usually ending with '/thredds/'.
#' @param recursive Should the function recurse into nested THREDDS catalogs.
#' Defaults to 'FALSE'.
#' @param datasets_only Should the function only return datasets
#' (and exclude, for example, nested THREDDS catalogs).
#' Defaults to 'FALSE'.
#'
#' @return A data_frame containing dataset names and paths.
#'
#' @export
#' @importFrom magrittr %>% %$% %<>%
#' @examples
#' threddr_list_datasets(thredds_url = "https://cida.usgs.gov/thredds/")
#' threddr_list_datasets(thredds_url = "http://thredds.northwestknowledge.net:8080/thredds/")
threddr_list_datasets <- function(thredds_url,
                                  recursive = FALSE,
                                  datasets_only = FALSE){

  thredds_url_base <- if(thredds_url %>%
                 endsWith(".html")){
    thredds_url %>%
      stringr::str_remove("([^/]+$)")
  } else thredds_url


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
    dplyr::mutate(path = ifelse(startsWith(path,"/thredds/"),
                                stringr::str_remove(path,
                                                    stringr::coll("/thredds/",TRUE)),
                                path),
                  path = stringr::str_c(thredds_url_base,path))

  if(recursive){
    out %<>%
      dplyr::filter(!stringr::str_detect(path,
                                        stringr::coll("dataset=",TRUE))) %$%
      path %>%
      purrr::map_dfr(threddr_list_datasets,
                     recursive = TRUE,
                     datasets_only = FALSE) %>%
      dplyr::bind_rows(out)

  }

  if(datasets_only){
    out %<>%
      dplyr::filter(stringr::str_detect(path,
                                         stringr::coll("dataset=",TRUE)))
  }

  return(out)
}
