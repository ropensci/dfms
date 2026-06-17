
#' Convert DFM to Other State Space Model Formats
#' @description
#' Converts a \code{dfm} object to the state space representation used by
#' the \pkg{dlm} or \pkg{KFAS} packages, enabling their forecasting, smoothing,
#' and prediction-interval functionality.
#' @param object an object of class 'dfm'.
#' @param to character, target package format: \code{"dlm"} or \code{"KFAS"}.
#' @param ... other arguments
#' @details
#' The DFM is defined by the state space model:
#' \itemize{
#'   \item Observation equation: \eqn{X_t = C F_t + e_t},
#'         \eqn{e_t \sim N(0, R)}
#'   \item Transition equation: \eqn{F_t = A F_{t-1} + u_t},
#'         \eqn{u_t \sim N(0, Q)}
#' }
#' where \eqn{F_t} is the companion-form state vector of length \eqn{r \cdot p}
#' and \eqn{A} is the companion transition matrix \eqn{[r \cdot p \times r \cdot p]}.
#'
#' For \strong{dlm}: The system matrices map directly — \code{FF = C},
#' \code{GG = A}, \code{V = R}, \code{W = Q}, with initial state \code{m0 = F[1,]}
#' and covariance \code{C0 = P[,,1]}. The user should pass standardized (scaled and centered)
#' data when using further dlm functions.
#'
#' For \strong{KFAS}: An \code{SSModel} is built via \code{SSMcustom} with
#' \code{Z = C}, \code{T = A}, \code{R = I}, \code{Q = Q}, \code{H = R} with initial state
#' \code{a1 = F[1,]} and covariance \code{P1 = P[,,1]}.  The standardized data with
#' original missing values restored is embedded in the model object \code{y = X}.
#'
#' @return
#' For \code{to = "dlm"}: a \code{dlm} object (see
#'   \code{\link[dlm]{dlm}}).
#'
#' For \code{to = "KFAS"}: an \code{SSModel} object (see
#'   \code{\link[KFAS]{SSModel}}).
#'
#' @examples  \dontrun{
#'
#' mod <- DFM(BM14_Q, r=2, p=3)
#'  # Convert to dlm and run filter extract prediction variance
#'  if (requireNamespace("dlm", quietly = TRUE)) {
#'    dlm_mod <- convert(mod, to = "dlm")
#'    # Pass standardized data (scale each column) to dlmFilter
#'    fitf <- dlm::dlmFilter(scale(BM14_Q), dlm_mod)
#'    dlm::dlmSvd2var(fitf$U.R, fitf$D.R)
#'  }
#'  # Convert to KFAS and compute prediction intervals
#'  if (requireNamespace("KFAS", quietly = TRUE)) {
#'    kfas_mod <- convert(mod, to = "KFAS")
#'    predict(kfas_mod, n.ahead = 10, interval = "prediction",
#'            level = 0.95)
#'  }
#' }
#'
#' @export
convert <- function(object, ...) {
  UseMethod("convert")
}

#' @rdname convert
#' @export
convert.dfm <- function(object, to=c("KFAS", "dlm"), ...) {
  to <- match.arg(to)
  stopifnot(inherits(object, "dfm"))
  nl <- dim(object$A)[1]
  n <- dim(object$A)[2]
  ni <- dim(object$C)[1]
  nar <- n/nl
  P1inf <- P1t <- Tt <- Qt <- matrix(0, n, n)
  P1t[1:nl, 1:nl] <- object$P_qml[,, 1]
  Qt[1:nl, 1:nl] <- object$Q
  Tt[1:nl, 1:n] <- object$A
  if (nar > 1) {
    Tt[(nl + 1):n, 1:(nl * (nar - 1))] <- diag(1, nl * (nar - 1), nl*(nar - 1))
  }
  a1 <- matrix(rep(object$F_qml[1,], nar), nrow=n)
  Zt <-  matrix(c(object$C, rep(0, ni * (nar - 1) * nl)), ncol = n)
  Rt <- diag(1, n, n)
  Ht <- object$R
  y <- as.data.frame(object$X_imp)
  if (is.null(colnames(y))) colnames(y) <- paste0("y", seq_len(ni))
  nobs <- nrow(y)
  if (to == "KFAS") {
    SSMcustom <- KFAS::SSMcustom
    form <- stats::as.formula(paste0(
      "cbind(", paste(colnames(y), collapse = ", "), ") ~ -1 + ",
      "SSMcustom(Z = Zt, T = Tt, R = Rt, Q = Qt, a1 = a1, ",
      "P1 = P1t, P1inf = P1inf, index = seq_len(", ni, "), n = ", nobs, ")"
    ))
    KFAS::SSModel(form, data = y, H = Ht)
  } else {
    dlm::dlm(list(m0 = a1, C0 = P1t, FF = Zt, V = Ht, GG = Tt, W = Qt))
  }
  }
