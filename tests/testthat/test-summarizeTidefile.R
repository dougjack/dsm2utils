test_that("startDatetime works", {
    out <- summarizeTidefile(system.file("extdata", "hist_v82.h5", package="dsm2utils", mustWork=TRUE))
    expect_equal(out$startDatetime_PST, lubridate::ymd("2011-01-01", tz="Etc/GMT+8"))
})

test_that("endDatetime works", {
    out <- summarizeTidefile(system.file("extdata", "hist_v82.h5", package="dsm2utils", mustWork=TRUE))
    expect_equal(out$endDatetime_PST, lubridate::ymd("2011-01-11", tz="Etc/GMT+8"))
})

test_that("timestep_min works", {
    out <- summarizeTidefile(system.file("extdata", "hist_v82.h5", package="dsm2utils", mustWork=TRUE))
    expect_equal(out$timestep_min, 30)
})
