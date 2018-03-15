context("tds_list_datasets")

test_that("THREDDS dataset listing works", {

  expect_s3_class(tds_list_datasets(thredds_url = "https://cida.usgs.gov/thredds/"),"data.frame")

})

test_that("function returns an error when pointed at a fake URL", {

  expect_error(tds_list_datasets(thredds_url = "https://cida.usgs.gov/blah/"))
  closeAllConnections()
})
