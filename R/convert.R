#' Convert DFM to Other State Space Model Formats
#'
#' @description
#' Converts a \code{dfm} object to the state space representation used by
#' the \pkg{dlm} or \pkg{KFAS} packages, enabling their forecasting, smoothing,
#' and prediction-interval functionality.
#'
#' @param x an object of class 'dfm'.
#' @param to character. Target package format: \code{"dlm"} or \code{"KFAS"}.
#' @param \dots not used.
#'
#' @details
#' The DFM is defined by the state space model:
#' \itemize{
#'   \item \emph{Observation equation}: \eqn{X_t = C F_t + e_t},
#'         \eqn{e_t \sim N(0, R)}
#'   \item \emph{Transition equation}: \eqn{F_t = A F_{t-1} + u_t},
#'         \eqn{u_t \sim N(0, Q)}
#' }
#' where \eqn{F_t} is the companion-form state vector of length \eqn{r \times p}
#' and \eqn{A} is the companion transition matrix.
#'
#' For \strong{dlm}: The system matrices map directly — \code{FF = C},
#' \code{GG = A}, \code{V = R}, \code{W = Q} — with a diffuse initial state
#' covariance (\code{C0 = 1e7 * I}). The user should pass standardized (scaled
#' and centered) data to \code{\link[dlm]{dlmFilter}}.
#'
#' For \strong{KFAS}: An \code{SSModel} is built via \code{SSMcustom} with
#' \code{Z = C}, \code{T = A}, \code{R = I}, \code{Q = Q}, \code{H = R} and
#' diffuse initialization. The standardized data with original missing values
#' restored is embedded in the model object.
#'
#' @return For \code{to = "dlm"}: a \code{dlm} object (see
#'   \code{\link[dlm]{dlm}}).
#'   For \code{to = "KFAS"}: an \code{SSModel} object (see
#'   \code{\link[KFAS]{SSModel}}).
#'
#' @seealso \link{DFM}, \link{predict.dfm}
#'
#' @examples \dontrun{
#' mod <- DFM(diff(BM14_Q), r = 2, p = 3)
#'
#' # Convert to dlm and run Kalman filter/smoother
#' if (requireNamespace("dlm", quietly = TRUE)) {
#'   dlm_mod <- convert(mod, to = "dlm")
#'   # Pass standardized data (scale each column) to dlmFilter
#'   filt <- dlm::dlmFilter(scale(diff(BM14_Q)), dlm_mod)
#'   sm   <- dlm::dlmSmooth(filt)
#' }
#'
#' # Convert to KFAS and compute prediction intervals
#' if (requireNamespace("KFAS", quietly = TRUE)) {
#'   kfas_mod <- convert(mod, to = "KFAS")
#'   sm   <- KFAS::KFS(kfas_mod)
#'   pred <- predict(kfas_mod, n.ahead = 10, interval = "prediction",
#'                   level = 0.95)
#' }
#' }
#'
#' @export
convert <- function(x, ...) UseMethod("convert")

#' @rdname convert
#' @export
convert.dfm <- function(x, to = c("dlm", "KFAS"), ...) {
  to <- match.arg(to)
  A <- x$A
  C <- x$C
  Q <- x$Q
  R <- x$R
  m <- nrow(A)   # state dimension (r * p)
  n <- nrow(C)   # number of observed series

  switch(to,
    dlm = {
      if(!requireNamespace("dlm", quietly = TRUE))
        stop("Package 'dlm' is required. Install with: install.packages(\"dlm\")")
      dlm::dlm(FF = C, V = R, GG = A, W = Q,
               m0 = rep(0, m), C0 = diag(m) * 1e7)
    },
    KFAS = {
      if(!requireNamespace("KFAS", quietly = TRUE))
        stop("Package 'KFAS' is required. Install with: install.packages(\"KFAS\")")
      X <- x$X_imp
      if(x$anyNA) X[attr(X, "missing")] <- NA
      # Strip dfms-specific attributes, keep only dim/dimnames
      attributes(X) <- list(dim = dim(X), dimnames = dimnames(X))
      KFAS::SSModel(
        X ~ -1 + KFAS::SSMcustom(
          Z     = array(C, c(n, m, 1)),
          T     = array(A, c(m, m, 1)),
          R     = array(diag(m), c(m, m, 1)),
          Q     = array(Q, c(m, m, 1)),
          a1    = rep(0, m),
          P1    = matrix(0, m, m),
          P1inf = diag(m)
        ),
        H = array(R, c(n, n, 1))
      )
    }
  )
}
