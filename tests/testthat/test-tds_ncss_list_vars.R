context("tds_ncss_list_vars")

test_that("THREDDS NetCDF Subset variable listing works", {

  expect_type(tds_ncss_list_vars(ncss_url = "https://cida.usgs.gov/thredds/ncss/macav2metdata_monthly_historical/dataset.html"),"list")

})

test_that("function returns an error when pointed at a fake URL", {

  expect_error(tds_ncss_list_vars(ncss_url = "https://cida.usgs.gov/thredds/ncss/blah/dataset.html"))

})
