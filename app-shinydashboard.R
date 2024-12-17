# Shiny Dashboard App with Authentication

# Load required libraries
library(shiny)
library(shinydashboard)
library(shinyauthr)
library(tidyverse)

# Create user database
user_base <- tibble(
  user = c("admin", "user"),
  password = c("adminpass", "userpass"),
  permissions = c("admin", "standard"),
  name = c("Administrator", "Regular User")
)

# UI Definition
ui <- dashboardPage(
  # Dashboard header
  dashboardHeader(
    title = "Secure Dashboard",
    # Placeholder for login UI
    tags$li(class = "dropdown", style = "padding: 10px;",
            uiOutput("login_status"))
  ),
  
  # Dashboard sidebar
  dashboardSidebar(
    # Sidebar menu will be rendered conditionally
    uiOutput("sidebar_menu")
  ),
  
  # Dashboard body
  dashboardBody(
    # Authentication UI
    shinyauthr::loginUI(id = "login"),
    
    # Main dashboard content
    uiOutput("dashboard_content")
  )
)

# Server Logic
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
  
  # Render login status in header
  output$login_status <- renderUI({
    req(user_auth())
    
    # Logout button for authenticated users
    tags$li(
      shinyauthr::logoutUI(id = "logout"),
      style = "display: inline-block; vertical-align: middle;"
    )
  })
  
  # Render sidebar menu only when authenticated
  output$sidebar_menu <- renderUI({
    req(user_auth())
    
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Profile", tabName = "profile", icon = icon("user")),
      menuItem("Settings", tabName = "settings", icon = icon("cogs")),
      # Conditional menu item for admin
      if(user_info()$permissions == "admin") {
        menuItem("Admin Panel", tabName = "admin", icon = icon("lock"))
      }
    )
  })
  
  # Render dashboard content
  output$dashboard_content <- renderUI({
    req(user_auth())
    
    tabItems(
      # Dashboard Tab
      tabItem(tabName = "dashboard",
        fluidRow(
          box(title = paste("Welcome,", user_info()$name), 
              status = "primary", 
              solidHeader = TRUE,
              width = 12,
              p("You are logged in as a", user_info()$permissions, "user.")
          )
        ),
        fluidRow(
          # Example info boxes
          infoBox("User Type", user_info()$permissions, icon = icon("user"), color = "purple"),
          infoBox("Login Time", format(Sys.time(), "%H:%M:%S"), icon = icon("clock"), color = "green")
        )
      ),
      
      # Profile Tab
      tabItem(tabName = "profile",
        fluidRow(
          box(title = "User Profile", status = "primary", solidHeader = TRUE,
              width = 12,
              p("Username: ", user_info()$user),
              p("Name: ", user_info()$name),
              p("Permissions: ", user_info()$permissions)
          )
        )
      ),
      
      # Settings Tab
      tabItem(tabName = "settings",
        fluidRow(
          box(title = "Application Settings", status = "warning", solidHeader = TRUE,
              width = 12,
              p("Manage your application settings here.")
          )
        )
      ),
      
      # Admin Panel Tab (only visible to admin)
      if(user_info()$permissions == "admin") {
        tabItem(tabName = "admin",
          fluidRow(
            box(title = "Admin Control Panel", status = "danger", solidHeader = TRUE,
                width = 12,
                p("Administrative functions and user management.")
            )
          )
        )
        }
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