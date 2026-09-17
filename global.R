library(shiny)
library(plotly)

aq <- stats::na.omit(datasets::airquality)
aq$MonthName <- factor(
  month.abb[aq$Month],
  levels = month.abb[5:9]
)
aq$DateLabel <- sprintf("%s %d, 1973", aq$MonthName, aq$Day)

additive_model <- stats::lm(
  Ozone ~ Temp + Wind + MonthName,
  data = aq
)

interaction_model <- stats::lm(
  Ozone ~ Temp * Wind + MonthName,
  data = aq
)

cross_validated_rmse <- function(formula, data, folds = 5L, seed = 2026L) {
  set.seed(seed)
  fold_id <- sample(rep(seq_len(folds), length.out = nrow(data)))
  predictions <- rep(NA_real_, nrow(data))

  for (fold in seq_len(folds)) {
    training <- data[fold_id != fold, , drop = FALSE]
    validation <- data[fold_id == fold, , drop = FALSE]
    fitted_model <- stats::lm(formula, data = training)
    predictions[fold_id == fold] <- stats::predict(fitted_model, validation)
  }

  sqrt(mean((data$Ozone - predictions)^2))
}

model_comparison <- data.frame(
  Model = c("Additive", "Temperature x wind interaction"),
  Formula = c(
    "Ozone ~ Temp + Wind + Month",
    "Ozone ~ Temp * Wind + Month"
  ),
  CV_RMSE = c(
    cross_validated_rmse(Ozone ~ Temp + Wind + MonthName, aq),
    cross_validated_rmse(Ozone ~ Temp * Wind + MonthName, aq)
  ),
  stringsAsFactors = FALSE
)

selected_model <- if (model_comparison$CV_RMSE[2] <= model_comparison$CV_RMSE[1]) {
  interaction_model
} else {
  additive_model
}

selected_model_name <- model_comparison$Model[
  which.min(model_comparison$CV_RMSE)
]
