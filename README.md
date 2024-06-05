
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dsm2utils

<!-- badges: start -->

[![R-CMD-check](https://github.com/dougjack/dsm2utils/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/dougjack/dsm2utils/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of dsm2utils is to provide a variety of utilities for working
with DSM2 tidefiles. This ranges from reading basic metadata (e.g.,
start and end datetimes) to extracting flows for a particular (external)
channel number.

## Installation

You can install the development version of dsm2utils from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("dougjack/dsm2utils")
```

## Example

This example shows how to obtain the basic metadata stored in a file,
hist_v82.h5. Note: system.file() is used here to obtain the full path to
an example tidefile. In your usage, you’ll just provide the path to the
tidefile on your local machine.

``` r
library(dsm2utils)
out <- summarizeTidefile(system.file("extdata", "hist_v82.h5", package="dsm2utils", mustWork=TRUE))
```
