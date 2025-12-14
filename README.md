# Titanic Survival Predictor 🚢✨ (Cinematic Deluxe Edition)

An interactive **R Shiny** app that predicts a Titanic passenger’s **probability of survival** using a **logistic regression** model trained on the built-in `Titanic` dataset. The app combines a clean prediction workflow with a cinematic UI: a welcome screen transition, animated sidebar, and a live probability gauge.

Live app: https://markchweya.shinyapps.io/Titanic-Survival-Rate-Predictor/

---

## What it does
Users select:
- **Passenger Class**: 1st / 2nd / 3rd / Crew
- **Gender**: Male / Female
- **Age Group**: Child / Adult

Then the app returns:
- A **predicted survival probability (%)**
- A short **interpretation** (high vs lower likelihood)
- A visual **gauge bar** that animates to the predicted percentage

---

## How the model works (high level)
- Uses the built-in `Titanic` contingency table dataset.
- Expands counts (`Freq`) into a full row-level dataset.
- Trains a **logistic regression (GLM, binomial)**:

`Survived ~ Class + Sex + Age`

- Predictions are produced using `type = "response"` to return probabilities.

---

## UI / UX highlights
- **Welcome screen** with fade-out transition into the app
- **Animated sidebar** (slide + glow) containing About/How it works/Credits
- **Animated input card** that shifts left when results appear
- **Probability gauge** with smooth fill + pulsing label
- Smart constraint: if **Class = Crew**, **Age** is forced to **Adult** and disabled

---

## Tech stack
- **R**
- **shiny**
- **tidyverse**
- **bslib**
- **shinyjs**
- Model: **glm()** (logistic regression)

---

## Run locally

### 1) Install dependencies
```r
install.packages(c("shiny", "tidyverse", "bslib", "shinyjs"))
