# ---------------------------------------------------
# Titanic Survival Predictor — Vision Pro Edition v6
# ---------------------------------------------------
packages <- c("shiny", "tidyverse", "bslib", "shinyjs")
new_pkgs <- packages[!(packages %in% installed.packages()[, "Package"])]
if (length(new_pkgs)) install.packages(new_pkgs)
library(shiny); library(tidyverse); library(bslib); library(shinyjs)

# --- Model setup ---
titanic <- as.data.frame(Titanic)
titanic_full <- titanic[rep(1:nrow(titanic), titanic$Freq), 1:4]
titanic_full$Survived_bin <- ifelse(titanic_full$Survived == "Yes", 1, 0)
titanic_full$Class <- factor(titanic_full$Class, levels = c("1st", "2nd", "3rd", "Crew"))
titanic_full$Sex <- factor(titanic_full$Sex, levels = c("Male", "Female"))
titanic_full$Age <- factor(titanic_full$Age, levels = c("Child", "Adult"))
model <- glm(Survived_bin ~ Class + Sex + Age, data = titanic_full, family = binomial)

# ---------------------------------------------------
# UI
# ---------------------------------------------------
ui <- fluidPage(
  useShinyjs(),
  theme = bs_theme(base_font = font_google("Poppins")),
  tags$head(tags$style(HTML("
html, body {
  margin:0; padding:0; height:100%;
  background:linear-gradient(160deg,#edf3ff 0%,#f9fbff 100%);
  font-family:'Poppins',sans-serif;
  overflow-y:auto;
}

/* Floating background */
body::before {
  content:''; position:fixed; inset:0;
  background:radial-gradient(circle at 40% 40%,#cde5ff,#f1f7ff 80%);
  animation:aurora 18s ease-in-out infinite alternate;
  z-index:-1;
}
@keyframes aurora {
  0%{background-position:0% 50%;}
  50%{background-position:100% 50%;}
  100%{background-position:0% 50%;}
}

/* Hover-activated glowing arrow */
#menuBtn {
  position: fixed;
  top: 28px;
  left: 28px;
  width: 54px;
  height: 54px;
  border-radius: 50%;
  border: none;
  background: radial-gradient(circle at 30% 30%, #4da8ff, #0056d8 70%);
  display: flex;
  align-items: center;
  justify-content: center;
  color: transparent;
  cursor: pointer;
  z-index: 300;
  display: none;
  box-shadow: 0 0 15px rgba(77,168,255,0.5), 0 0 30px rgba(0,86,216,0.4);
  animation: floaty 3.5s ease-in-out infinite;
  transition: all 0.5s ease;
}
@keyframes floaty {
  0%,100%{transform:translateY(0) scale(0.9);}
  50%{transform:translateY(-4px) scale(1);}
}
#menuBtn::after {
  content: '➜';
  color: #fff;
  font-size: 26px;
  font-weight: 800;
  transition: transform 0.6s ease;
}
#menuBtn::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(0,162,255,0.3) 0%, transparent 70%);
  animation: rippleGlow 3.5s infinite ease-in-out;
  z-index: -1;
}
@keyframes rippleGlow {
  0% { transform: scale(1); opacity: 0.7; }
  50% { transform: scale(1.3); opacity: 0.2; }
  100% { transform: scale(1); opacity: 0.7; }
}

/* hover animation */
#menuBtn:hover {
  transform: scale(1.15) rotate(360deg);
  box-shadow: 0 0 25px rgba(100,200,255,0.8), 0 0 45px rgba(0,86,216,0.6);
}

/* Sidebar */
#sideBar {
  position: fixed;
  top: 0;
  left: -280px;
  width: 260px;
  height: 100vh;
  background: rgba(255,255,255,0.25);
  backdrop-filter: blur(25px) saturate(150%);
  box-shadow: 6px 0 30px rgba(0,0,0,0.15);
  border-right: 1px solid rgba(255,255,255,0.25);
  transition: all 0.8s cubic-bezier(.25,.8,.25,1);
  z-index: 200;
  padding: 60px 25px;
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  opacity: 0;
}
#sideBar.show {
  left: 0;
  opacity: 1;
  pointer-events: auto;
}
.sidebar-header {
  color: #0b2545;
  font-weight: 800;
  font-size: 26px;
  margin-bottom: 40px;
  text-shadow: 0 2px 8px rgba(0,0,0,0.15);
}
.sidebar-list { list-style: none; padding: 0; }
.sidebar-item {
  display: block; font-size: 18px; font-weight: 600;
  color: #0b2545; text-decoration: none; margin: 18px 0;
  transition: all 0.3s ease; cursor: pointer; padding: 8px 0;
}
.sidebar-item:hover { color: #1E88E5; transform: translateX(8px); }

/* Predictor Layout */
#predictPage {
  display:flex; align-items:center; justify-content:center;
  height:100vh; width:100vw; overflow:hidden; position:relative;
}
#inputCard {
  width:440px; padding:50px; border-radius:35px;
  background:rgba(255,255,255,0.92);
  backdrop-filter:blur(20px);
  box-shadow:0 10px 40px rgba(0,0,0,0.12);
  text-align:center;
  position:absolute; left:50%; top:50%;
  transform:translate(-50%,-50%);
  transition:all 1s cubic-bezier(.25,.8,.25,1);
  z-index:10;
}
#inputCard.slide-left { transform:translate(-115%,-50%); }
#resultCard {
  width:500px; padding:50px; border-radius:35px;
  background:rgba(255,255,255,0.97);
  backdrop-filter:blur(25px);
  box-shadow:0 10px 45px rgba(0,0,0,0.12);
  text-align:center;
  position:absolute; left:100%; top:50%;
  transform:translateY(-50%) translateX(30%);
  opacity:0; transition:all 1s cubic-bezier(.25,.8,.25,1);
}
#resultCard.show { left:58%; opacity:1; transform:translateY(-50%) translateX(0); }

h3 { font-size:28px; font-weight:800; color:#0b2545; margin-bottom:25px; }
select {
  width:100%; border:1px solid rgba(0,0,0,0.07);
  border-radius:18px; background:rgba(255,255,255,0.9);
  padding:12px 15px; font-size:16px; color:#2c3e50;
  margin-bottom:20px; transition:all 0.35s ease;
  box-shadow:0 3px 10px rgba(0,0,0,0.04);
  appearance:none;
}
select:hover { border-color:#42A5F5; box-shadow:0 5px 18px rgba(52,152,219,0.25); transform:translateY(-2px);}
select:focus { outline:none; border-color:#1E88E5; box-shadow:0 0 0 3px rgba(66,165,245,0.25); }

.btn-primary {
  background:linear-gradient(90deg,#1565C0,#42A5F5);
  border:none; font-weight:700; font-size:17px;
  padding:13px 0; border-radius:24px;
  color:white; letter-spacing:0.3px;
  transition:all 0.3s ease;
  box-shadow:0 6px 25px rgba(66,165,245,0.45);
}
.btn-primary:hover { transform:translateY(-2px); box-shadow:0 12px 35px rgba(66,165,245,0.6); }
.probBox {
  font-size:56px; font-weight:800; color:#fff;
  padding:25px; border-radius:22px; margin:20px auto 30px;
  animation:flipReveal 0.9s ease-in-out forwards, pulse 3.5s infinite ease-in-out;
  box-shadow:0 8px 28px rgba(0,0,0,0.15);
  display:inline-block; min-width:200px;
}
@keyframes flipReveal { from{transform:rotateY(90deg) scale(0.7); opacity:0;} to{transform:rotateY(0) scale(1); opacity:1;} }
@keyframes pulse { 0%,100%{transform:scale(1);} 50%{transform:scale(1.04);} }
.interpText { font-size:17px; color:#34495E; opacity:0; transform:translateY(15px); animation:slideUp 0.9s ease forwards; animation-delay:0.4s; line-height:1.6;}
@keyframes slideUp { to{opacity:1; transform:translateY(0);} }
.infoText { font-size:13px; color:#6c757d; margin-top:20px; letter-spacing:0.2px; }
"))),

  actionButton("menuBtn", label = "", class = "menuBtn"),

  div(id="sideBar",
      div(class="sidebar-header", h3("Menu")),
      tags$ul(class="sidebar-list",
              tags$li(actionLink("go_home", "🏠  Welcome", class="sidebar-item")),
              tags$li(actionLink("go_about", "💡  About", class="sidebar-item")),
              tags$li(actionLink("go_contact", "✉️  Contact", class="sidebar-item"))
      )
  ),

  div(id="predictPage",
      div(id="inputCard",
          h3("Passenger Details"),
          selectInput("class", "Passenger Class:", c("1st Class", "2nd Class", "3rd Class", "Crew")),
          selectInput("sex", "Gender:", c("Male", "Female")),
          selectInput("age", "Age Group:", c("Child", "Adult")),
          actionButton("predict_btn", "Predict", class="btn btn-primary w-100"),
          p("Powered by a logistic regression model trained on Titanic passenger data.", class="infoText")
      ),
      div(id="resultCard", uiOutput("resultUI"))
  )
)

# ---------------------------------------------------
# SERVER
# ---------------------------------------------------
server <- function(input, output, session) {

  predict_survival <- function(class, sex, age) {
    class <- dplyr::recode(class,
      "1st Class" = "1st", "2nd Class" = "2nd",
      "3rd Class" = "3rd", "Crew" = "Crew"
    )
    new_data <- data.frame(
      Class = factor(class, levels = c("1st", "2nd", "3rd", "Crew")),
      Sex = factor(sex, levels = c("Male", "Female")),
      Age = factor(age, levels = c("Child", "Adult"))
    )
    predict(model, newdata = new_data, type = "response")
  }

  runjs("
    const arrow = document.getElementById('menuBtn');
    const sidebar = document.getElementById('sideBar');
    let hoverTimeout;

    arrow.addEventListener('mouseenter', ()=>{
      arrow.style.transform = 'scale(1.15) rotate(360deg)';
      sidebar.classList.add('show');
      clearTimeout(hoverTimeout);
    });
    arrow.addEventListener('mouseleave', ()=>{
      hoverTimeout = setTimeout(()=>{
        if(!sidebar.matches(':hover')){
          sidebar.classList.remove('show');
          arrow.style.transform = 'scale(0.9) rotate(0deg)';
        }
      }, 600);
    });
    sidebar.addEventListener('mouseenter', ()=>{
      clearTimeout(hoverTimeout);
      sidebar.classList.add('show');
    });
    sidebar.addEventListener('mouseleave', ()=>{
      sidebar.classList.remove('show');
      arrow.style.transform = 'scale(0.9) rotate(0deg)';
    });
  ")

  observeEvent(input$predict_btn, {
    prob <- predict_survival(input$class, input$sex, input$age)
    percent <- round(prob * 100, 2)
    color <- ifelse(prob > 0.5, '#1ABC9C', '#E74C3C')
    interp <- if (prob > 0.5)
      'This passenger has a high likelihood of surviving based on the selected characteristics.'
    else
      'This passenger has a lower likelihood of surviving based on the selected characteristics.'

    runjs("$('#inputCard').addClass('slide-left'); $('#resultCard').addClass('show');")

    output$resultUI <- renderUI({
      tagList(
        h3('Predicted Probability of Survival'),
        tags$div(class='probBox', style=paste0('background-color:',color,';'),
                 paste0(percent,'%')),
        h3('Interpretation'),
        tags$p(interp, class='interpText')
      )
    })
  })
}

shinyApp(ui, server)
