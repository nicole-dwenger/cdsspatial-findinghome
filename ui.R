# UI SCRIPT OF THE APP
# --------------------------------------
# This defines the main layout of the app

# Main navigation bar 
navbarPage("FINDING HOME IN THE CITY",
           
           # PANEL 1: MAP 
           tabPanel("Map", useShinyjs(), HTML(html_fix),
                    
                    # Necessary to display app, defining css class (see styles.css)
                    div(class="outer", tags$head(includeCSS("styles.css")),
                        
                        # Showing map output
                        leafletOutput("map", width="100%", height="100%"),
                        
                        # Adding control panel (copied from example map)
                        absolutePanel(id="controls", fixed=T, draggable=T, top = "60", right = "auto", left = "5", bottom="auto", width=475, height="auto",
                                      
                                      # Adding css style, and avoid displaying red error messages
                                      tags$style(type="text/css",
                                                 ".shiny-output-error { visibility: hidden; }",
                                                 ".shiny-output-error:before { visibility: hidden; }"),
                                      
                                      # Adding city input option 
                                      h4("Where will be your new home?"),
                                      selectInput("city", NULL, cities, selected= "", width = "100%"),
                                    
                                      # Adding attribute input option
                                      h4("What is important to you?"),
                                      fluidRow(
                                        # Input option for variable
                                        column(width = 10, 
                                               selectInput("variable", label=NULL,choices=c("Please choose a city first" = ""), selected = "", width = "100%")),
                                        # Info box button for varaible
                                        column(width = 1,
                                               dropdownButton(circle=F, icon=icon("info"), margin = "30px", width = "300px", br(), uiOutput("variable_info"), br()))),
                                      
                                      # Adding optional input for ethnicity to come up 
                                      conditionalPanel(
                                        condition = "input.variable == 'ethnicity'",
                                        h4("Which ethnicities would you like to visualise?"), 
                                        p("Plotting dots will take some time due to the amount of data!"),
                                        checkboxGroupButtons("ethnicity_selected", NULL, choices = "", selected = "", width = "100%")),
                                      
                                      # Adding optional input for origin to come up 
                                      conditionalPanel(
                                        condition = "input.variable == 'origin'",
                                        h4("Which places of origin would you like to visualise?"),
                                        p("Plotting dots will take some time due to the amount of data!"),
                                        checkboxGroupButtons("origin_selected", NULL, choices = "", selected = "", width = "100%")),
                                      
                                      # Adding optional panel for religion to come up
                                      conditionalPanel(
                                        condition = "input.variable == 'religion'",
                                        h4("Which religion are you interested in?"),
                                        radioGroupButtons("religion_selected", NULL, choices = "", selected = "", width = "100%")),
                                      
                                      # Adding optional panel for culture to come up
                                      conditionalPanel(
                                        condition = "input.variable == 'culture'",
                                        h4("What type of place are you interested in?"),
                                        radioGroupButtons("culture_selected", NULL, choices = "", selected = "", width = "100%")),
                                      
                                      # Adding optional input for POI to come up 
                                      conditionalPanel(
                                        condition = "input.variable == 'travel'",
                                        h4("What point of interest (PoI) are you interested in?"),
                                        selectInput("poi_selected", NULL, choices = "", selected = "", width = "100%"),
                                        htmlOutput("travel_info")),
                                      
                                      # Adding optional input for rent to come up
                                      conditionalPanel(
                                        condition = "input.variable == 'rent'",
                                        h4("What type of measure are you interested in?"),
                                        selectInput("rent_selected", NULL, choices = "", selected = "", width = "100%")),
                                      
                                      br(),
                                      # If borough is selected, display which one, and allow option to clear the shape
                                      uiOutput("select_borough"),
                                      hr(),
                                      # Display conditional histogram
                                      uiOutput("conditional_histogram", height = 400), 
                                      hr(),
                                      # Display reset all button to go back to start map
                                      actionButton("reset_all", "Reset to Start")))),
           
           # PANEL2: ABOUT
           tabPanel("About",
                    includeMarkdown("about.md"))
)