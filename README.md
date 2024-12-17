# Add password authentication to a Shiny App

These are some example template scripts for adding user authentication via a password to a Shiny app using the 'shinyauthr' package.

This method requires the UI to be render dynamically, which can cause issues when using dashboard theming packages like 'bslib' and 'shinydashboard'. I have created versions for both of these examples, and I recommended copying this code and starting with the template from the beginning of the dashboard development. Adding a password at the end of the development may cause issue with UI elements not rendering properly.

User names and passwords are stored directly in the app.R file. This is NOT the most secure method for user authentication and protection. Anyone with access to the R script will have access to all user credentials, so be careful and deliberate about where you store your script and who can access it!

Also, it practice I have encountered issues when multiple people are using the same credentials simultaneously. Therefore it is better to sent up individual usernames and passwords if you think that multiple people will use the app at the same time, as well as an admin credential for yourself that you can use during development and demos.