ui <- navbarPage(
  title = div(class = "brand-title", "Urban Air Quality Explorer"),
  id = "main_navigation",
  header = tags$head(
    tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"),
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),

  tabPanel(
    "Explore",
    div(
      class = "page-shell",
      div(
        class = "hero-panel",
        div(
          class = "hero-copy",
          tags$span(class = "eyebrow", "NEW YORK CITY, MAY TO SEPTEMBER 1973"),
          tags$h1("Explore how weather relates to ozone"),
          tags$p(
            "Filter daily observations and inspect patterns in temperature, wind, season, and ozone concentration."
          )
        ),
        div(
          class = "hero-note",
          tags$strong("Interactive tip"),
          tags$span("Hover over points, drag to zoom, and double-click to reset the chart.")
        )
      ),

      fluidRow(
        column(
          width = 3,
          div(
            class = "control-card",
            tags$h2("Choose observations"),
            checkboxGroupInput(
              "months",
              "Months",
              choices = setNames(month.abb[5:9], month.name[5:9]),
              selected = month.abb[5:9]
            ),
            sliderInput(
              "temperature",
              "Temperature range (degrees F)",
              min = min(aq$Temp),
              max = max(aq$Temp),
              value = range(aq$Temp),
              step = 1
            ),
            sliderInput(
              "wind",
              "Wind range (mph)",
              min = floor(min(aq$Wind)),
              max = ceiling(max(aq$Wind)),
              value = range(aq$Wind),
              step = 0.1
            ),
            radioButtons(
              "point_size",
              "Point size represents",
              choices = c("Wind speed" = "Wind", "Solar radiation" = "Solar.R"),
              selected = "Wind"
            ),
            actionButton("reset_filters", "Reset filters", class = "btn-reset")
          )
        ),
        column(
          width = 9,
          uiOutput("summary_cards"),
          div(
            class = "chart-card",
            tags$div(
              class = "card-heading",
              tags$h2("Daily ozone and temperature"),
              tags$p("Colour identifies the month. Use the toolbar to zoom or save the chart.")
            ),
            plotlyOutput("ozone_scatter", height = "500px"),
            uiOutput("filter_message")
          )
        )
      )
    )
  ),

  tabPanel(
    "Predict",
    div(
      class = "page-shell narrow-shell",
      div(
        class = "section-intro",
        tags$span(class = "eyebrow", "MODEL-BASED ESTIMATE"),
        tags$h1("Estimate ozone for a weather scenario"),
        tags$p(
          "The prediction uses the model with the lowest five-fold cross-validated error. It is intended for exploration, not health advice."
        )
      ),
      fluidRow(
        column(
          width = 5,
          div(
            class = "control-card prediction-controls",
            sliderInput("predict_temp", "Temperature (degrees F)", 57, 97, 82, step = 1),
            sliderInput("predict_wind", "Wind speed (mph)", 2.3, 20.7, 8, step = 0.1),
            selectInput("predict_month", "Month", choices = month.abb[5:9], selected = "Jul"),
            tags$p(class = "input-help", "Change any value to update the estimate immediately.")
          )
        ),
        column(
          width = 7,
          div(
            class = "prediction-card",
            tags$span(class = "metric-label", "Predicted ozone concentration"),
            div(class = "prediction-value", textOutput("predicted_ozone", container = tags$span)),
            p(class = "prediction-interval", textOutput("prediction_interval", container = tags$span)),
            tags$hr(),
            uiOutput("prediction_context")
          )
        )
      ),
      div(
        class = "method-card",
        tags$h2("Why this model?"),
        uiOutput("model_choice_text"),
        tableOutput("model_table")
      )
    )
  ),

  tabPanel(
    "Monthly summary",
    div(
      class = "page-shell narrow-shell",
      div(
        class = "section-intro",
        tags$span(class = "eyebrow", "SEASONAL VIEW"),
        tags$h1("Compare the summer months"),
        tags$p("The table responds to the filters selected on the Explore tab.")
      ),
      div(class = "table-card", tableOutput("monthly_table"))
    )
  ),

  tabPanel(
    "How to use",
    div(
      class = "page-shell narrow-shell",
      div(
        class = "section-intro",
        tags$span(class = "eyebrow", "DOCUMENTATION"),
        tags$h1("A short guide for first-time users"),
        tags$p("No R knowledge is required to use the application.")
      ),
      div(
        class = "guide-grid",
        div(class = "guide-card", tags$span(class = "step-number", "1"), tags$h2("Filter"), tags$p("Choose one or more months and move the temperature or wind sliders. The chart and summaries update automatically.")),
        div(class = "guide-card", tags$span(class = "step-number", "2"), tags$h2("Explore"), tags$p("Hover over a point to view its date and measurements. Drag across the plot to zoom; double-click to return to the full view.")),
        div(class = "guide-card", tags$span(class = "step-number", "3"), tags$h2("Predict"), tags$p("Open the Predict tab and create a weather scenario. The app shows a model estimate and a 95% prediction interval.")),
        div(class = "guide-card", tags$span(class = "step-number", "4"), tags$h2("Interpret carefully"), tags$p("Patterns are associations in one historical summer. They do not establish causation and should not be treated as current air-quality guidance."))
      ),
      div(
        class = "about-card",
        tags$h2("Data and reproducibility"),
        tags$p("The application uses the built-in R airquality dataset with complete observations from May through September 1973."),
        tags$p("Created by Sonja Sahebzad on September 17, 2026 for the Johns Hopkins University / Coursera Developing Data Products course."),
        tags$p("The complete ui.R, server.R, global.R, presentation source, and documentation are included in the project repository.")
      )
    )
  )
)
