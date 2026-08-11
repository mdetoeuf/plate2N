
<!-- README.md is generated from README.Rmd. Please edit that file -->

# plate2N

<!-- badges: start -->

<!-- badges: end -->

An R package for processing 96-well microplate absorbance data end to
end — from raw plate-reader exports through blank correction,
concentration inference, and study-specific downstream analysis
(currently: soil nitrogen dosage and MicroResp respiration data).

## Installation

plate2N isn’t on CRAN. Install the development version of plate2N from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("mdetoeuf/plate2N")
```

## What it does

The package is organized around a core pipeline, documented in a set of
vignettes:

- **`import-tidy`** — import raw plate-reader output (several formats
  supported) and tidy it into a consistent long format
- **`blank-correction`** — subtract blank absorbance from standard
  curves and samples
- **`abs-to-conc`** — fit a linear or polynomial standard curve and
  infer sample concentration
- **`model-choice`** — a toolkit for deciding between linear and
  polynomial models, one curve at a time or across many at once
- **`handling-outliers`** — identifying and removing outlier wells
  throughout the pipeline
- **`microresp`** — a full worked pipeline for MicroResp community-level
  respiration data
- **`prepare_plates`** — generating plate layouts programmatically

Full documentation, including all vignettes and the function reference,
is on the [pkgdown site](https://mdetoeuf.github.io/plate2N/).

## Quick example

This is a basic example which shows you how to solve a common problem:

``` r
library(plate2N)
raw <- csv_to_tibble("my_plate_data.csv")
```

## What’s new

- **MicroResp pipeline** — a complete, documented workflow for MicroResp
  respiration data, from import through Shannon diversity and MBC/qCO2
  indices
- **Per-sample outlier tools** (`plot_qc_sample_pair()`,
  `plot_list_qc_samples()`) — paired boxplot + ridgeline views for
  spotting and identifying outlier wells at the sample level, reusable
  across pipelines
- **Model-choice toolkit** (`fit_curve_model()`,
  `plot_model_comparison()`, `plot_residual_comparison()`,
  `review_model_choice()`) — fit, visually compare, and review linear
  vs. polynomial standard curve models, for one curve or many at once

See the [pkgdown site](https://mdetoeuf.github.io/plate2N/) for full
details on any of the above.

## License

MIT + file LICENSE
