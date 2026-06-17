# dfms 1.0.1

* New function `convert()` to export `dfm` objects to `dlm` or `KFAS` state-space formats, enabling their forecasting, smoothing, and prediction-interval functionality. Thanks @kletts (#106).
* Fixed `convert(..., to = "KFAS")` for multivariate models.

# dfms 1.0.0

* *dfms* is now part of [rOpenSci](https://ropensci.org/) – following completion of a scientific review by @eeholmes and @santikka. This means the repo shifted to [ropensci/dfms](https://github.com/ropensci/dfms) and the docs (now in rOpenSci style) to [docs.ropensci.org/dfms](https://docs.ropensci.org/dfms/). 

* Added a `news()` function for news decomposition identifying the contribution of new data releases to DFM predictions/nowcasts following research codes by Banbura and Modugno (2014). It supports efficient multi-target news estimation, has been tested with MQ/AR(1) model versions, and is suitable for mixed-frequency nowcasting applications.

* Added arguments `save.full.state` to `DFM()` and `use.full.state` to `predict()`, `fitted()`, and `residuals()` - default `TRUE`. Full-state output includes idiosyncratic components (when modeled with `idio.ar1 = TRUE`). This generally improves the accuracy of DFM forecasts, but changes the interpretation for residuals/fitted values, 
which are then no longer a function of the factors alone. 

* Marked 1.0.0 as the package is now peer-reviewed and feature-complete within the intended scope: the full and efficient implementation of Banbura and Modugno (2014) in R.

# dfms 0.4.0

* Added support for mixed-frequency estimation with AR(1) idiosyncratic errors (`quarterly.vars` combined with `idio.ar1 = TRUE`). This implements the full model of Banbura and Modugno (2014), allowing observation errors to follow AR(1) processes while handling mixed monthly-quarterly data with temporal aggregation constraints.

* New internal functions `init_cond_MQ_idio()` and `EMstepBMMQidio()` implement the EM algorithm for the combined MQ + idio.ar1 case, with state vector structure `[factors, monthly_errors, quarterly_error_lags]`.

* Updated `plot.dfm()` with `type = "residual"` to properly handle mixed-frequency and AR(1) error models by using the `residuals()` method internally.

* Added examples and documentation for the new MQ + idio.ar1 functionality in both the `DFM()` help page and the introductory vignette.

# dfms 0.3.2

* Minor internal C++ changes to ensure compatibility with *RcppArmadillo* 15.0.2.

# dfms 0.3.1

* Fixed bug which occurred with only one quarterly variable (#73). Thanks @SantiagoD999 for reporting.

# dfms 0.3.0

* Added argument `quarterly.vars`, enabling mixed-frequency estimation with monthly and quarterly data following Banbura and Modugno (2014). The data matrix should contain the quarterly variables at the end (after the monthly ones).

# dfms 0.2.2

* Replace Armadillo `inv_sympd()` by Armadillo `inv()` in C++ Kalman Filter to improve numerical robustness at a minor performance cost.

# dfms 0.2.1

* Fixed print bug in `summary.dfm`: print method showed that model had AR(1) errors even though `idio.ar1 = FALSE` by default. 

# dfms 0.2.0

* Added argument `idio.ar1 = TRUE` allowing estimation of approximate DFM's with AR(1) observation errors. 

* Added a small theoretical vignette entitled 'Dynamic Factor Models: A Very Short Introduction'. This vignette lays a foundation for the present and future functionality of *dfms*. I plan to implement all features described in this vignette until summer 2023. 

# dfms 0.1.5

* Added argument `na.keep = TRUE` to `fitted.dfm`. Setting `na.keep = FALSE` allows interpolation of data based on the DFM. Thanks @apoorvalal (#45).

# dfms 0.1.4

* Fixed minor bug in `summary.dfm` occurring if only one factor was estimated (basically an issue with dropping matrix dimensions which lead the factor summary statistics to be displayed without names).

# dfms 0.1.3

* Implemented some minor CRAN comments, no changes to functionality. 

# dfms 0.1.2

* New default `em.method = "auto"`, which uses `"BM"` if the data has any missing values and `"DGR"` otherwise. 

* Added vignette providing a walkthrough of the main features. 

# dfms 0.1.1

* Renamed package from *DFM* to *dfms*. Lowercase names are preferred by [rOpenSci](<https://devguide.ropensci.org/building.html?q=package%20name#package-name-and-metadata>), and this also helps distinguish the package name from the main function `DFM()`. The new name was inspired by the *vars* package. 
