context("tds_ncss_download")

test_that("THREDDS NetCDF Subset download works", {
  out.dir <- tempfile()
  dir.create(out.dir,
             showWarnings = FALSE,
             recursive = TRUE)

  thredds.dl <- tds_ncss_download(ncss_url = "https://cida.usgs.gov/thredds/ncss/macav2metdata_monthly_historical/dataset.html",
                                  bbox = sf::st_bbox(c(xmin = -116, xmax = -115, ymin = 44, ymax = 45)),
                                  vars = c("huss_BNU-ESM_r1i1p1_historical","huss_CCSM4_r6i1p1_historical"),
                                  out_file = paste0(out.dir,"/macav2metdata_monthly_historical.nc"))

  expect_type(thredds.dl,"character")
  # expect_s4_class(suppressMessages(suppressWarnings(raster::brick(thredds.dl))), "RasterBrick")
  # expect_warning(suppressMessages(raster::brick(thredds.dl)))

})
