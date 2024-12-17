# Minimal Shiny App with Authentication Template

# Load required libraries
library(shiny)
library(shinyauthr)
library(tidyverse)

# Create user database
# Replace these credentials with your own
user_base <- tibble(
  user = c("admin", "user"),
  password = c("adminpass", "userpass"),
  permissions = c("admin", "standard"),
  name = c("Administrator", "Regular User")
)

# UI 
ui <- fluidPage(
  # Authentication UI
  shinyauthr::loginUI(id = "login"),
  
  # Main app UI will be rendered conditionally
  uiOutput("app_content")
)

# Server logic
server <- function(input, output, session) {
  # Authentication server
  credentials <- shinyauthr::loginServer(
    id = "login",
    data = user_base,
    user_col = user,
    pwd_col = password,
    log_out = reactive(logout_init())
  )
  
  # Logout trigger
  logout_init <- reactiveVal(FALSE)
  
  # Check authentication status
  user_auth <- reactive({
    credentials()$user_auth
  })
  
  # User info reactive
  user_info <- reactive({
    credentials()$info
  })
  
  # Render main app UI only when authenticated
  output$app_content <- renderUI({
    req(user_auth())
    
    fluidPage(
      # Logout button
      div(
        style = "text-align: right; padding: 10px;",
        shinyauthr::logoutUI(id = "logout")
      ),
      
      # Welcome message with username
      h2(paste("Welcome,", user_info()$name)),
      
      # Main app content goes here
      tabsetPanel(
        tabPanel("Home", 
          h3("Dashboard"),
          p("This is a sample dashboard for authenticated users.")
        ),
        tabPanel("Profile", 
          h3("User Profile"),
          p("User: ", user_info()$user),
          p("Permissions: ", user_info()$permissions)
        )
      )
    )
  })
  
  # Logout server
  logout <- shinyauthr::logoutServer(
    id = "logout",
    active = reactive(credentials()$user_auth)
  )
}

# Run the application 
shinyApp(ui = ui, server = server)