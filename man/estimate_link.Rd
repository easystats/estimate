% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/estimate_predicted.R
\name{estimate_link}
\alias{estimate_link}
\alias{estimate_relation}
\alias{estimate_expectation}
\alias{estimate_response}
\alias{estimate_prediction}
\title{Generate predictions from models}
\usage{
estimate_link(model, data = "grid", ci = 0.95, keep_iterations = FALSE, ...)

estimate_relation(
  model,
  data = "grid",
  ci = 0.95,
  keep_iterations = FALSE,
  ...
)

estimate_expectation(
  model,
  data = NULL,
  ci = 0.95,
  keep_iterations = FALSE,
  ...
)

estimate_response(model, data = NULL, ci = 0.95, keep_iterations = FALSE, ...)

estimate_prediction(
  model,
  data = NULL,
  ci = 0.95,
  keep_iterations = FALSE,
  ...
)
}
\arguments{
\item{model}{A statistical model.}

\item{data}{A data frame with model's predictors to estimate the response. If
NULL, the model's data is used. If "grid", the model matrix is obtained
(through \code{\link{visualisation_matrix}}).}

\item{ci}{Confidence Interval (CI) level. Default to 0.95 (95\%).}

\item{keep_iterations}{If \code{TRUE}, will keep all iterations (draws) of
bootstrapped or Bayesian models. They will be added as additional columns
named \code{iter_1, iter_2, ...}. You can reshape them to a long format by
running \code{\link[bayestestR:reshape_iterations]{bayestestR::reshape_iterations()}}.}

\item{...}{You can add all the additional control arguments from \code{\link{visualisation_matrix}} (used when \code{data = "grid"}) and \code{\link[insight:get_predicted]{insight::get_predicted()}}.}
}
\value{
A dataframe of predicted values.
}
\description{
Using models to generate "predictions" is useful for many reasons, from assessing the model's performance to visualizing the relationships estimated by the model. It is, however, a term covering a range of different statistical procedures.
\cr\cr
Making different types of predictions (usually for different goals) using \code{modelbased} can be achieved through 4 functions:
\itemize{
  \item{\strong{estimate_link}: Returns a \code{\link[=visualisation_matrix]{reference grid}} with predictions on the model's link-scale (with \emph{confidence} intervals)}.
  \item{\strong{estimate_relation}: Returns a \code{\link[=visualisation_matrix]{reference grid}} with predictions on the response scale (with \emph{confidence} intervals)}.
  \item{\strong{estimate_expectation}: Makes predictions on the data used for model fitting on the response scale (with \emph{confidence} intervals)}.
  \item{\strong{estimate_response}: Makes predictions on the data used for model fitting on the response (transformed for binomial models) scale (with \emph{prediction} intervals)}.
}
You can see these 4 functions as placed on a gradient ranging from predictions "close to the model" to "close to the actual response data". The first two are typically used for visualizing the effects and relationships estimated by the model, whereas the last two are more likely to be used to visualize the performance of your model.
\cr\cr
These functions are built on top of \code{\link[insight:get_predicted]{insight::get_predicted()}}, and correspond to different specifications of its parameters. It is very important to read its \href{https://easystats.github.io/insight/reference/get_predicted.html}{documentation}, and in particular the description of its \code{predict} argument to get a better sense of concepts such as "expectation", "link" and "prediction".
\cr\cr
The 4 modelbased functions mentioned above differ first and foremost by their default parameters. \code{estimate_link} and \code{estimate_relation} have the \code{data} argument set to \code{\link[=visualisation_matrix]{"grid"}} by default. Their expected usage is for visualisation of the model's effects. \code{estimate_expectation} and \code{estimate_response} have the \code{data} argument set to \code{NULL} by default (which retrieves the data used for model's fitting). These functions' are useful in the context of generating actual predictions for the existing or new data, to assess the model's performance or make actual future predictions.
\cr\cr
There are many control parameters that are not listed here but can
be used, such as the arguments from  \code{\link{visualisation_matrix}} (used
when \code{data = "grid"}) and from
\code{\link[insight:get_predicted]{insight::get_predicted()}} (the function
to compute predictions used internally). For plotting, check the examples in
\code{\link{visualisation_recipe}}. Don't forget to also check out the \href{https://easystats.github.io/modelbased/articles/}{Vignettes} and \href{https://easystats.github.io/modelbased/index.html#features}{README examples} for various examples, tutorials and usecases
}
\examples{
library(modelbased)

# Linear Models
model <- lm(mpg ~ wt, data = mtcars)

# Get predicted and prediction interval (see insight::get_predicted)
estimate_response(model)

# Get expected values with confidence interval
pred <- estimate_relation(model)
pred

# Visualisation (see visualisation_recipe())
plot(pred)

# Standardize predictions
pred <- estimate_relation(lm(mpg ~ wt + am, data = mtcars))
z <- effectsize::standardize(pred, include_response = FALSE)
z
effectsize::unstandardize(z, include_response = FALSE)

# Logistic Models
model <- glm(vs ~ wt, data = mtcars, family = "binomial")
estimate_response(model)
estimate_relation(model)

# Mixed models
if (require("lme4")) {
  model <- lmer(mpg ~ wt + (1 | gear), data = mtcars)
  estimate_response(model)
  estimate_relation(model)
}

# Bayesian models
\donttest{
if (require("rstanarm")) {
  model <- rstanarm::stan_glm(mpg ~ wt, data = mtcars, refresh = 0, iter = 200)
  estimate_response(model)
  estimate_relation(model)
}
}
}
