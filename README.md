# Developing Data Products: Shiny Course Project

**Author:** Sonja Sahebzad

This repository contains the Shiny application and reproducible pitch for the Johns Hopkins University / Coursera Developing Data Products course project. The application explores relationships among weather, season, and ozone measurements in the built-in R `airquality` dataset.

## Review the project

* [RStudio Presenter source](Urban_Air_Quality_Pitch.Rpres)
* [Compiled presentation preview](Urban_Air_Quality_Pitch-rpubs.html)
* [Shiny user interface](ui.R)
* [Shiny server logic](server.R)
* [Data preparation and model comparison](global.R)
* [Rubric compliance review](RUBRIC_COMPLIANCE.md)

## Published project

* [Live Shiny application](https://sonjasahebzad.shinyapps.io/urban-air-quality-explorer/)
* [GitHub Pages presentation](https://sonja242.github.io/developing-data-products-shiny-course-project/)
* [RPubs presentation](https://rpubs.com/Sonja_Janssen/1459845)

## Application features

* Interactive filters for month, temperature, and wind
* A reactive Plotly chart with hover details and zoom controls
* Reactive summary statistics and a monthly table
* An ozone prediction tool with a 95% prediction interval
* Five-fold cross-validation comparing additive and interaction models
* A How to use tab with documentation and limitations

## Files

* `ui.R`: user interface and documentation
* `server.R`: reactive filtering, plots, summaries, and predictions
* `global.R`: data preparation and model comparison
* `www/styles.css`: application styling
* `Urban_Air_Quality_Pitch.Rpres`: five-slide RStudio Presenter pitch
* `pitch.css`: presentation styling and visible navigation arrows
* `Urban_Air_Quality_Pitch-rpubs.html`: compiled presentation preview
* `Urban_Air_Quality_Pitch.md`: generated presentation content
* `Developing_Data_Products_Shiny.Rproj`: RStudio project file

## Run locally

Open `Developing_Data_Products_Shiny.Rproj` in RStudio. Install `shiny` and `plotly` if needed, then click **Run App** or run:

```r
shiny::runApp()
```

Open `Urban_Air_Quality_Pitch.Rpres` and click **Preview** to render the five-slide pitch. Use the visible left and right controls or the keyboard arrow keys to move between slides.

## Data and model

The app uses complete observations from the built-in `airquality` dataset. It compares an additive linear model with a model containing a temperature by wind interaction. Fixed five-fold cross-validation chooses the model with the lower root mean squared error. This comparison checks whether the predicted temperature relationship changes meaningfully with wind speed.

The data cover New York from May through September 1973. Results describe associations and are not current health guidance.

## Assignment requirements

The Shiny app includes multiple input widgets, reactive server calculations, reactive output, and novice-friendly documentation. The pitch contains exactly five slides, includes evaluated R code, and was created with RStudio Presenter.

## Course

This project was created for the Johns Hopkins University / Coursera Data Science Specialization course **Developing Data Products**.

Assignment: **Course Project: Shiny Application and Reproducible Pitch**.

Created on September 17, 2026.
