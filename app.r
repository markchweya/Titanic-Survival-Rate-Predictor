# ---------------------------------------------------
# Titanic Survival Predictor — Cinematic Deluxe Edition (Animated Sidebar + Refined UI)
# ---------------------------------------------------

packages <- c("shiny", "tidyverse", "bslib", "shinyjs")
new_pkgs <- packages[!(packages %in% installed.packages()[, "Package"])]
if (length(new_pkgs)) install.packages(new_pkgs)

library(shiny)
library(tidyverse)
library(bslib)
library(shinyjs)

# --- Logistic model setup ---
titanic <- as.data.frame(Titanic)
titanic_full <- titanic[rep(1:nrow(titanic), titanic$Freq), 1:4]
titanic_full$Survived_bin <- ifelse(titanic_full$Survived == "Yes", 1, 0)
model <- glm(Survived_bin ~ Class + Sex + Age, data = titanic_full, family = binomial)

# ---------------------------------------------------
# UI
# ---------------------------------------------------
ui <- fluidPage(
  useShinyjs(),
  theme = bs_theme(
    bootswatch = "flatly",
    base_font = font_google("Open Sans"),
    heading_font = font_google("Roboto Slab"),
    primary = "#154360"
  ),
  
  tags$head(tags$style(HTML("
    html, body {
      height: 100%;
      margin: 0;
      overflow: hidden;
      background: linear-gradient(135deg, #e9f2ff 0%, #f9fbff 100%);
    }

    /* --- Key Animations --- */
    .fadeIn {animation: fadeIn 1.2s ease forwards;}
    @keyframes fadeIn {from {opacity: 0;} to {opacity: 1;}}
    .fadeOut {animation: fadeOut 0.8s ease forwards;}
    @keyframes fadeOut {from {opacity: 1;} to {opacity: 0; transform: translateY(-20px);}}
    @keyframes floatTitle {from {transform: translateY(0);} to {transform: translateY(-6px);}}
    @keyframes pulseGlow {
      0% {box-shadow: 0 0 0 rgba(26, 188, 156, 0.0);}
      50% {box-shadow: 0 0 12px rgba(26, 188, 156, 0.6);}
      100% {box-shadow: 0 0 0 rgba(26, 188, 156, 0.0);}
    }

    /* --- Welcome Screen --- */
    #welcomeScreen {
      position: absolute; top: 50%; left: 50%;
      transform: translate(-50%, -50%);
      text-align: center; z-index: 10;
      width: 100%; height: 100%;
      background: linear-gradient(180deg, #eef4ff, #f9fbff);
      display: flex; flex-direction: column;
      align-items: center; justify-content: center;
      transition: opacity 0.8s ease;
    }
    .welcomeTitle {
      font-size: 45px; color: #0e3e72;
      font-weight: 800; margin-bottom: 10px;
      animation: floatTitle 3s ease-in-out infinite alternate;
    }
    .welcomeSubtitle {
      color: #555; font-size: 18px; margin-bottom: 40px;
    }
    .launch-btn {
      background: linear-gradient(90deg, #154360, #2471A3);
      color: white; font-weight: bold; font-size: 18px;
      padding: 14px 40px; border-radius: 30px; border: none;
      cursor: pointer; box-shadow: 0 4px 15px rgba(0,0,0,0.2);
      transition: all 0.4s ease;
    }
    .launch-btn:hover {
      transform: scale(1.08);
      box-shadow: 0 8px 25px rgba(21,67,96,0.35);
      animation: pulseGlow 1.5s infinite;
    }

    /* --- Layout --- */
    .main-container {
      height: 100vh; width: 100vw; position: relative;
      display: none; opacity: 0; transition: opacity 1s ease;
    }
    .main-container.active {display: block; opacity: 1;}

    #inputCard {
      position: absolute; top: 50%; left: 50%;
      transform: translate(-50%, -50%);
      width: 400px; padding: 30px; border-radius: 12px;
      background: #fff; box-shadow: 0 8px 30px rgba(0,0,0,0.15);
      transition: all 1s ease-in-out; z-index: 2;
    }
    #inputCard.shrink {
      left: 28%; transform: translate(-50%, -50%) scale(0.9);
    }

    /* --- Result Panel --- */
    #resultPanel {
      opacity: 0; transform: translateX(120px);
      transition: all 1s ease-in-out;
      position: absolute; top: 50%; right: 8%;
      transform-origin: center; transform: translateY(-50%);
      width: 45%;
    }
    #resultPanel.show {opacity: 1; transform: translateY(-50%) translateX(0);}

    .gauge-wrapper {
      display: flex; align-items: center; gap: 20px; width: 80%;
    }
    .gauge-container {
      background: #ddd;
      border-radius: 30px;
      overflow: hidden;
      height: 22px;
      flex-grow: 1;
      box-shadow: inset 0 2px 6px rgba(0,0,0,0.2);
      position: relative;
    }
    .gauge-fill {
      height: 100%;
      border-radius: 30px;
      background: linear-gradient(90deg, #E74C3C, #1ABC9C);
      width: 0%;
      transition: width 1.2s ease-in-out;
    }
    .gauge-label {
      font-weight: 700; font-size: 22px;
      color: #154360; opacity: 0;
      transition: opacity 1s ease, transform 0.8s ease;
      transform: translateY(10px);
    }
    .gauge-label.show {
      opacity: 1; transform: translateY(0);
      animation: pulseGlow 2s infinite;
    }

    .interpretation {
      font-size: 18px; color: #154360;
      margin-top: 20px; opacity: 0;
      transform: translateY(20px);
      transition: opacity 1s ease, transform 1s ease;
    }
    .interpretation.show {
      opacity: 1; transform: translateY(0);
    }

    /* --- Sidebar --- */
   /* --- Sidebar with slide & glow animation --- */
#sidebar {
  position: fixed; 
  left: -280px; 
  top: 0; 
  width: 260px; 
  height: 100%;
  background: rgba(255,255,255,0.75);
  backdrop-filter: blur(14px);
  box-shadow: 4px 0 25px rgba(0,0,0,0.1);
  padding: 30px; 
  transition: left 0.6s cubic-bezier(0.77,0,0.175,1), 
              box-shadow 0.6s ease;
  z-index: 20;
}
#sidebar.show {
  left: 0;
  box-shadow: 8px 0 25px rgba(21,67,96,0.25);
}

   

    /* --- Animated Sidebar Button --- */
    .sidebar-btn {
      position: absolute; top: 20px; left: 20px;
      width: 44px; height: 44px;
      background: #154360;
      border: none; border-radius: 50%;
      cursor: pointer;
      display: flex; align-items: center; justify-content: center;
      z-index: 25;
      transition: background 0.3s ease, transform 0.4s ease;
      box-shadow: 0 3px 10px rgba(0,0,0,0.15);
    }
    .sidebar-btn:hover {
      background: #1A5276;
      animation: pulseGlow 1.5s infinite;
      transform: rotate(90deg);
    }
    .sidebar-btn span,
    .sidebar-btn span::before,
    .sidebar-btn span::after {
      content: '';
      display: block;
      width: 22px; height: 2.8px;
      background-color: #fff;
      border-radius: 2px;
      position: absolute;
      transition: all 0.4s ease;
    }
    .sidebar-btn span::before {transform: translateY(-7px);}
    .sidebar-btn span::after {transform: translateY(7px);}
    #sidebar.show ~ .sidebar-btn span {background-color: transparent;}
    #sidebar.show ~ .sidebar-btn span::before {
      transform: rotate(45deg);
      background-color: #fff;
    }
    #sidebar.show ~ .sidebar-btn span::after {
      transform: rotate(-45deg);
      background-color: #fff;
    }
  "))),
  
  # --- WELCOME SCREEN ---
  div(
    id = "welcomeScreen",
    h1("Titanic Survival Predictor", class="welcomeTitle"),
    p("Experience data, design, and destiny.", class="welcomeSubtitle"),
    actionButton("launchApp", "Launch Predictor", class="launch-btn")
  ),
  
  # --- MAIN APP ---
  div(
    id = "mainDiv", class="main-container",
    tags$button(id="toggleSidebar", class="sidebar-btn", span()),
    div(
      id = "sidebar",
      h5("About"), p("This predictor uses a logistic regression model trained on Titanic passenger data."),
      h5("How it Works"), p("The model estimates survival probability based on passenger class, gender, and age."),
      h5("Credits"), p("Built with R Shiny, styled with Bootstrap and custom CSS.")
    ),
    
    div(
      id = "inputCard",
      h3("Passenger Details", style="text-align:center; color:#154360; font-weight:bold;"),
      selectInput("class", "Passenger Class:", c("1st","2nd","3rd","Crew")),
      selectInput("sex", "Gender:", c("Male","Female")),
      selectInput("age", "Age Group:", c("Child","Adult")),
      br(),
      actionButton("predict_btn","Predict",class="btn btn-primary w-100"),
      br(),br(),
      p("Powered by a logistic regression model trained on Titanic passenger data.",
        style="font-size:13px; text-align:center; color:#777; margin:0;")
    ),
    
    div(
      id = "resultPanel",
      h3("Predicted Probability of Survival", style="color:#154360; font-weight:bold;"),
      div(class="gauge-wrapper",
          div(class="gauge-container", div(id="gaugeFill", class="gauge-fill")),
          div(id="gaugeLabel", class="gauge-label")
      ),
      h4("Interpretation", style="color:#154360; margin-top:25px;"),
      div(id="interpretationText", class="interpretation")
    )
  )
)

# ---------------------------------------------------
# Server
# ---------------------------------------------------
server <- function(input, output, session) {
  
  predict_survival <- function(class, sex, age){
    new_data <- data.frame(
      Class = factor(class, levels = levels(titanic_full$Class)),
      Sex   = factor(sex, levels = levels(titanic_full$Sex)),
      Age   = factor(age, levels = levels(titanic_full$Age))
    )
    prob <- predict(model, newdata=new_data, type="response")
    return(prob)
  }
  
  # --- Welcome transition ---
  observeEvent(input$launchApp,{
    runjs("
      $('#welcomeScreen').addClass('fadeOut');
      setTimeout(function(){
        $('#welcomeScreen').hide();
        $('#mainDiv').addClass('active fadeIn');
      },800);
    ")
  })
  
  # --- Sidebar toggle ---
  runjs("
    $(document).on('click', '#toggleSidebar', function() {
      $('#sidebar').toggleClass('show');
    });
  ")
  
  # --- Disable 'Child' when 'Crew' selected ---
  observeEvent(input$class, {
    if (input$class == 'Crew') {
      updateSelectInput(session, 'age', selected = 'Adult')
      shinyjs::disable('age')
    } else {
      shinyjs::enable('age')
    }
  })
  
  # --- Prediction ---
  observeEvent(input$predict_btn,{
    runjs("
      if (!$('#resultPanel').hasClass('show')) {
        $('#inputCard').addClass('shrink');
        setTimeout(function(){$('#resultPanel').addClass('show');},600);
      }
    ")
    
    prob <- predict_survival(input$class, input$sex, input$age)
    percent <- round(prob * 100, 1)
    
    runjs(sprintf("
      $('#gaugeFill').css('width', '0%%');
      $('#gaugeLabel').removeClass('show');
      $('#interpretationText').removeClass('show');

      setTimeout(function(){
        $('#gaugeFill').css('width', '%s%%');
      }, 200);

      setTimeout(function(){
        $('#gaugeLabel').text('%s%%');
        $('#gaugeLabel').addClass('show');
      }, 900);

      setTimeout(function(){
        $('#interpretationText').text('%s');
        $('#interpretationText').addClass('show');
      }, 1200);
    ",
                  percent,
                  percent,
                  if (prob > 0.5)
                    "This passenger has a high likelihood of surviving based on the selected characteristics."
                  else
                    "This passenger has a lower likelihood of survival based on the selected characteristics."
    ))
  })
}

# ---------------------------------------------------
# Run App
# ---------------------------------------------------
shinyApp(ui=ui, server=server)
