# Rubric compliance review

This document is for the local review before publication.

## Shiny application

| Requirement | Where it is demonstrated |
| --- | --- |
| Application is available online | Will be completed after local approval by deploying to shinyapps.io. |
| Source code is available | `ui.R`, `server.R`, and `global.R` are included and will be published in the GitHub repository. |
| At least one input widget | Month checkboxes, range sliders, radio buttons, a select menu, and a reset button are included. |
| Server uses the input | `filtered_data()` responds to month, temperature, and wind. `prediction()` responds to temperature, wind, and month. |
| Reactive output is visible | The Plotly chart, summary cards, prediction, prediction interval, model text, and monthly table update reactively. |
| Documentation is included | The How to use tab explains the controls, interpretation, data, and limitations for a novice user. |
| Application is substantive | It combines filtering, visualization, aggregation, prediction, model comparison, and documentation. |

## Reproducible pitch

| Requirement | Where it is demonstrated |
| --- | --- |
| Exactly five slides including title | `Urban_Air_Quality_Pitch.Rpres` contains five slide headings. |
| Created with RStudio Presenter | The source file uses the `.Rpres` RStudio Presenter format. |
| Embedded R code runs | Slide four performs a model comparison with fixed five-fold cross-validation. |
| No R errors | The code was parsed and executed locally before opening the project in RStudio. |
| Clear style and organization | The pitch uses a consistent blue theme, short sections, cards, and visible left and right navigation controls. |
| Hosted online | After approval, the pitch will be published to both GitHub Pages and RPubs. |

## Publication order after approval

1. Deploy the Shiny application to shinyapps.io.
2. Add the live application URL to the presentation and README.
3. Preview and verify the final presentation again.
4. Create the public GitHub repository and publish GitHub Pages.
5. Publish the presentation to RPubs.
6. Open every public link and compare the result with the rubric before submitting to Coursera.
