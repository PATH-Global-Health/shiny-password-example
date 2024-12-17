# Shiny App with Authentication and bslib Theming

# Load required libraries
library(shiny)
library(shinyauthr)
library(bslib)
library(tidyverse)

# Create user database
user_base <- tibble(
  user = c("admin", "user"),
  password = c("adminpass", "userpass"),
  permissions = c("admin", "standard"),
  name = c("Administrator", "Regular User")
)

# Define custom theme
custom_theme <- bs_theme(
  version = 5,
  # Choose a primary color scheme
  primary = "#0073e6",  # A professional blue
  secondary = "#6c757d",
  
  # Customize other theme elements
  bg = "#f4f6f9",  # Light background
  fg = "#333333",  # Dark text
  
  # Advanced theming options
  base_font = font_google("Inter"),  # Google Font
  heading_font = font_google("Montserrat")
)

# UI with bslib page layout
ui <- page_fluid(
  # Set the theme
  theme = custom_theme,
  
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
    
    page_fluid(
      # Navbar with logout
      nav(
        title = "Dashboard",
        nav_spacer(),
        nav_item(
          shinyauthr::logoutUI(id = "logout")
        )
      ),
      
      # Page layout with cards
      layout_column_wrap(
        width = 1/2,
        card(
          card_header(
            paste("Welcome,", user_info()$name)
          ),
          card_body(
            p("You are logged in with", user_info()$permissions, "permissions.")
          )
        ),
        card(
          card_header("Quick Stats"),
          card_body(
            value_box(
              title = "User Type",
              value = user_info()$permissions,
              showcase = bsicons::bs_icon("person-badge")
            )
          )
        )
      ),
      
      # Tabset panels
      navset_card_pill(
        nav_panel(
          title = "Home",
          p("Welcome to the dashboard. This is the main content area.")
        ),
        nav_panel(
          title = "Profile",
          layout_column_wrap(
            width = 1,
            card(
              card_header("User Details"),
              card_body(
                p("Username: ", user_info()$user),
                p("Name: ", user_info()$name)
              )
            )
          )
        ),
        nav_panel(
          title = "Settings",
          p("User settings can be configured here.")
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