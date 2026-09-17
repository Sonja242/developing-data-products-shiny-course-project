server <- function(input, output, session) {
  filtered_data <- reactive({
    selected_months <- input$months
    if (is.null(selected_months)) {
      return(aq[0, , drop = FALSE])
    }

    aq[
      aq$MonthName %in% selected_months &
        aq$Temp >= input$temperature[1] &
        aq$Temp <= input$temperature[2] &
        aq$Wind >= input$wind[1] &
        aq$Wind <= input$wind[2],
      ,
      drop = FALSE
    ]
  })

  observeEvent(input$reset_filters, {
    updateCheckboxGroupInput(session, "months", selected = month.abb[5:9])
    updateSliderInput(session, "temperature", value = range(aq$Temp))
    updateSliderInput(session, "wind", value = range(aq$Wind))
    updateRadioButtons(session, "point_size", selected = "Wind")
  })

  output$summary_cards <- renderUI({
    dat <- filtered_data()
    mean_ozone <- if (nrow(dat)) sprintf("%.1f", mean(dat$Ozone)) else "No data"
    warmest <- if (nrow(dat)) sprintf("%d F", max(dat$Temp)) else "No data"

    div(
      class = "metric-grid",
      div(class = "metric-card", tags$span(class = "metric-value", format(nrow(dat), big.mark = ",")), tags$span(class = "metric-label", "observations")),
      div(class = "metric-card", tags$span(class = "metric-value", mean_ozone), tags$span(class = "metric-label", "mean ozone (ppb)")),
      div(class = "metric-card", tags$span(class = "metric-value", warmest), tags$span(class = "metric-label", "highest temperature"))
    )
  })

  output$ozone_scatter <- renderPlotly({
    dat <- filtered_data()
    validate(need(nrow(dat) > 0, "Choose a wider range or select at least one month."))

    dat$PointSize <- dat[[input$point_size]]
    size_label <- if (identical(input$point_size, "Wind")) "Wind" else "Solar radiation"
    size_range <- range(dat$PointSize)
    if (diff(size_range) == 0) {
      dat$MarkerSize <- 14
    } else {
      dat$MarkerSize <- 8 + 16 * (dat$PointSize - size_range[1]) / diff(size_range)
    }
    dat$HoverText <- paste0(
      "<b>", dat$DateLabel, "</b>",
      "<br>Ozone: ", dat$Ozone, " ppb",
      "<br>Temperature: ", dat$Temp, " F",
      "<br>Wind: ", dat$Wind, " mph",
      "<br>Solar radiation: ", dat$Solar.R
    )

    month_colours <- setNames(
      c("#c6dbef", "#9ecae1", "#6baed6", "#3182bd", "#08519c"),
      levels(aq$MonthName)
    )
    chart <- plot_ly()
    for (month_name in levels(aq$MonthName)) {
      month_data <- dat[dat$MonthName == month_name, , drop = FALSE]
      if (nrow(month_data) > 0) {
        chart <- add_markers(
          chart,
          data = month_data,
          x = ~Temp,
          y = ~Ozone,
          name = month_name,
          text = ~HoverText,
          hoverinfo = "text",
          marker = list(
            size = month_data$MarkerSize,
            color = unname(month_colours[month_name]),
            opacity = 0.82,
            line = list(width = 0)
          )
        )
      }
    }

    chart |>
      layout(
        xaxis = list(title = "Temperature (degrees F)", gridcolor = "#e5e7eb"),
        yaxis = list(title = "Ozone concentration (ppb)", gridcolor = "#e5e7eb", rangemode = "tozero"),
        legend = list(title = list(text = "Month"), orientation = "h", x = 0, y = 1.12),
        margin = list(l = 70, r = 20, b = 65, t = 45),
        paper_bgcolor = "white",
        plot_bgcolor = "white",
        annotations = list(list(
          text = paste("Point size:", size_label),
          x = 1,
          y = -0.18,
          xref = "paper",
          yref = "paper",
          xanchor = "right",
          showarrow = FALSE,
          font = list(size = 11, color = "#526173")
        ))
      ) |>
      config(displaylogo = FALSE, responsive = TRUE)
  })

  output$filter_message <- renderUI({
    if (nrow(filtered_data()) == 0) {
      div(class = "empty-message", "No observations match these filters. Widen a range or select a month.")
    }
  })

  prediction <- reactive({
    new_case <- data.frame(
      Temp = input$predict_temp,
      Wind = input$predict_wind,
      MonthName = factor(input$predict_month, levels = levels(aq$MonthName))
    )
    stats::predict(selected_model, newdata = new_case, interval = "prediction", level = 0.95)
  })

  output$predicted_ozone <- renderText({
    sprintf("%.1f ppb", max(0, prediction()[1, "fit"]))
  })

  output$prediction_interval <- renderText({
    bounds <- pmax(0, prediction()[1, c("lwr", "upr")])
    sprintf("95%% prediction interval: %.1f to %.1f ppb", bounds[1], bounds[2])
  })

  output$prediction_context <- renderUI({
    typical_ozone <- mean(aq$Ozone)
    estimate <- max(0, prediction()[1, "fit"])
    relation <- if (estimate >= typical_ozone) "above" else "below"
    tags$p(
      tags$strong("Context: "),
      sprintf(
        "This estimate is %s the dataset mean of %.1f ppb. The interval is wide because daily ozone also depends on factors that are not included in this small historical dataset.",
        relation,
        typical_ozone
      )
    )
  })

  output$model_choice_text <- renderUI({
    best_rmse <- min(model_comparison$CV_RMSE)
    tags$p(
      sprintf(
        "%s produced the lower five-fold cross-validated RMSE (%.1f ppb), so it drives the prediction shown above. Comparing the models checks whether allowing the temperature effect to vary with wind materially improves prediction.",
        selected_model_name,
        best_rmse
      )
    )
  })

  output$model_table <- renderTable({
    display_table <- model_comparison
    display_table$CV_RMSE <- round(display_table$CV_RMSE, 2)
    names(display_table)[3] <- "Five-fold CV RMSE (ppb)"
    display_table
  }, striped = TRUE, bordered = FALSE, spacing = "m", rownames = FALSE)

  output$monthly_table <- renderTable({
    dat <- filtered_data()
    validate(need(nrow(dat) > 0, "No observations match the current filters."))
    summary_table <- stats::aggregate(
      cbind(Ozone, Temp, Wind) ~ MonthName,
      data = dat,
      FUN = mean
    )
    counts <- stats::aggregate(Ozone ~ MonthName, data = dat, FUN = length)
    summary_table$Days <- counts$Ozone
    summary_table$Ozone <- round(summary_table$Ozone, 1)
    summary_table$Temp <- round(summary_table$Temp, 1)
    summary_table$Wind <- round(summary_table$Wind, 1)
    names(summary_table) <- c("Month", "Mean ozone (ppb)", "Mean temperature (F)", "Mean wind (mph)", "Days")
    summary_table[, c("Month", "Days", "Mean ozone (ppb)", "Mean temperature (F)", "Mean wind (mph)")]
  }, striped = TRUE, bordered = FALSE, spacing = "m", rownames = FALSE)
}
