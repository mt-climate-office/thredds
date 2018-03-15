context("tds_list_services")

test_that("THREDDS service listing works", {

  expect_s3_class(tds_list_services(dataset_url = "https://cida.usgs.gov/thredds/catalog.html?dataset=cida.usgs.gov/prism_v2"),"data.frame")

})

test_that("function returns an error when pointed at a fake URL", {

  expect_error(tds_list_services(dataset_url = "https://cida.usgs.gov/thredds/catalog.html?dataset=blah"))
  showConnections(all = T)
  closeAllConnections()
})
