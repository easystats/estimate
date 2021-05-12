#' Generates predictions from models
#'
#' \code{estimate_link} is a shortcut to \code{estimate_response} with \code{data = "grid"}. \code{estimate_response} would be used in the context of generating actual predictions for the existing or new data, whereas \code{estimate_link} is more relevant in the context of visualisation and plotting. There are many control parameters that are not listed here but can be used, such as the arguments from  \code{\link{visualisation_matrix}} (used when \code{data = "grid"}) and from \code{\link[insight:get_predicted]{insight::get_predicted()}} (the function to compute predictions used internally).
#'
#' @inheritParams estimate_contrasts
#' @param data A data frame with model's predictors to estimate the response. If NULL, the model's data is used. If "grid", the model matrix is obtained (through \code{\link{visualisation_matrix}}).
#' @param ci The interval level (default \code{0.95}, i.e., 95\% CI).
#' @param keep_iterations Only relevant for Bayesian models or simulated models. If \code{TRUE}, will keep all prediction iterations (draws). You can reshape them by running \code{\link[bayestestR:reshape_iterations]{bayestestR::reshape_iterations()}}.
#' @param ... You can add all the additional control arguments from \code{\link{visualisation_matrix}} (used when \code{data = "grid"}) and \code{\link[insight:get_predicted]{insight::get_predicted()}}.
#'
#' @examples
#' library(modelbased)
#'
#' # Linear Models
#' model <- lm(mpg ~ wt, data = mtcars)
#' estimate_response(model)
#' estimate_relation(model)
#'
#' # Logistic Models
#' model <- glm(vs ~ wt, data = mtcars, family = "binomial")
#' estimate_response(model)
#' estimate_relation(model)
#'
#' # Mixed models
#' if (require("lme4")) {
#'   model <- lmer(mpg ~ wt + (1 | gear), data = mtcars)
#'   estimate_response(model)
#'   estimate_relation(model)
#' }
#'
#' # Bayesian models
#' if (require("rstanarm")) {
#'   model <- rstanarm::stan_glm(mpg ~ wt, data = mtcars, refresh = 0, iter = 200)
#'   estimate_response(model)
#'   estimate_relation(model)
#' }
#' @return A dataframe of predicted values.
#' @export
estimate_relation <- function(model, data = "grid", ci = 0.95, keep_iterations = FALSE, ...) {
  .estimate_predicted(model, data = data, ci = ci, keep_iterations = keep_iterations, predict = "relation", ...)
}

#' @rdname estimate_relation
#' @export
estimate_link <- function(model, data = "grid", ci = 0.95, keep_iterations = FALSE, ...) {
  .estimate_predicted(model, data = data, ci = ci, keep_iterations = keep_iterations, predict = "link", ...)
}


#' @rdname estimate_relation
#' @export
estimate_prediction <- function(model, data = NULL, ci = 0.95, keep_iterations = FALSE, ...) {
  .estimate_predicted(model, data = data, ci = ci, keep_iterations = keep_iterations, predict = "prediction", ...)
}

#' @rdname estimate_relation
#' @export
estimate_response <- estimate_prediction




# Internal ----------------------------------------------------------------

#' @keywords internal
.estimate_predicted <- function(model, data = "grid", predict = "relation", ci = 0.95, keep_iterations = FALSE, ...) {

  # Get data ----------------
  if (is.null(data)) {
    data <- insight::get_data(model)
  } else if (!is.data.frame(data)) {
    if (data == "grid") {
      data <- visualisation_matrix(model, reference = insight::get_data(model), ...)
    } else {
      stop('The `data` argument must either NULL, "grid" or another data.frame.')
    }
  }
  data <- data[names(data) %in% insight::find_predictors(model, effects = "all", flatten = TRUE)]

  # Restore factor levels
  data <- insight::data_restoretype(data, insight::get_data(model))

  # Get predicted ----------------
  predictions <- insight::get_predicted(model,
    data = data,
    predict = predict,
    ci = ci,
    dispersion_function = "mad",
    interval_function = "hdi",
    ...
  )
  out <- as.data.frame(predictions, keep_iterations = keep_iterations)
  out <- cbind(data, out)

  # Store relevant information
  attr(out, "ci") <- ci
  attr(out, "response") <- insight::find_response(model)

  # Class
  if(predict %in% c("link", "relation")) {
    class(out) <- c("estimate_relation", "see_estimate_relation", class(out))
  } else {
    class(out) <- c("estimate_response", "see_estimate_response", class(out))
  }

  out
}