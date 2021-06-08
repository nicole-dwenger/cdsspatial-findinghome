# SERVER SCRIPT OF THE SHINY APP 
# --------------------------------------
# This script contains the core functionality of the app
# Functions and data are defined in the global.R script
# Layout is defined the the ui.R script

function(input, output, session) {
  
# REACTIVE UI CHOICES ----
# Getting input options, which depend on other input, e.g. variables depend on city 
  
    ## Variable ----
    # List of choices for variables depending on chosen city
    variable_choices = reactive({get_variable_choices(input$city)})
    
    # Update options based on variable choices 
    observe({updateSelectInput(session, "variable",
                               choices = variable_choices(),
                               selected = "") 
    })
    
    ## Ethnicity ----
    # Get ethnicity choices
    ethnicity_choices = reactive({get_ethnicity_choices(input$city)})
    
    # Update ethnicity choices depending on city
    observe({updateCheckboxGroupButtons(session, "ethnicity_selected",
                                        choices = ethnicity_choices(),
                                        selected = "")
    })
    
    ## Origin ---
    # Get origin choices 
    origin_choices = reactive({get_origin_choices(input$city)})
    
    # Update origin choices 
    observe({updateCheckboxGroupButtons(session, "origin_selected",
                                        choices = origin_choices(),
                                        selected = "")
    })
    
    ## Religion ----
    # Get religion choices based on city
    religion_choices = reactive({get_religon_choices(input$city)})
    
    # Update input options for religion 
    observe({updateRadioGroupButtons(session, "religion_selected",
                                     choices = religion_choices(),
                                     selected = religion_choices()[1])
    })
    
    ## Culture ----
    # Get culture choices, same for both cities
    culture_choices = reactive({get_culture_choices()})
    
    # Update input options for culture
    observe({updateRadioGroupButtons(session, "culture_selected",
                                     choices = culture_choices(),
                                     selected = culture_choices()[1])
    })
    
    ## Point of Interest ----
    # Get POI options based on city
    # poi_choices = reactive({get_poi_choices(input$city)})
    
    # Update input options for POI
    # observe({updateSelectInput(session, "poi_selected",
    #                            choices = poi_choices(),
    #                            selected = poi_choices()[1])
    # })
    
    ## Rent ----
    # Get rent choices based on city
    rent_choices = reactive({get_rent_choices(input$city)})
    
    # Update rent input options 
    observe({updateSelectInput(session, "rent_selected",
                               choices = rent_choices(),
                               selected = rent_choices()[1])
    })
 
    
# SHAPE CLICK EVENT --------------------------------------------------------------------------
# When a shape (polygon) is clicked, this get the value of the polygon, draws a reset button 
    
    # Initialize empty click value, stored as reactive value, easier to handle
    rv = reactiveValues(click = NULL)
    
    # Store click values in reactive value
    observeEvent(input$map_shape_click, {
      req(input$variable != "")
      rv$click <- input$map_shape_click
    })
    
    # Output to ask to click on a shape to see more
    output$none_selected = renderText({paste("Click on a", assets()$shape_name, "to see it on the histogram!")})
    
    # Output of text of selected shape
    output$selected_shape <- renderText({
      req(!is.null(rv$click))
      paste0("<b>Chosen ", assets()$shape_name, ": </b>", rv$click$id)
    })
    
    # Output of button to remove selected shape
    output$clear_shape <- renderUI({
      req(!is.null(rv$click))
      actionButton("clear_shape", paste("Unselect", assets()$shape_name))
    })
    
    # Reset click value to NULL, when reset button is clicked
    observeEvent(input$clear_shape, {
      rv$click = NULL
    })
    
    # Putting it all together: conditional output, for click
    output$select_borough = renderUI({
      req(input$variable != "")
      # If no shape is clicked
      if (is.null(rv$click)){
        # Display text that it can be clicked
        textOutput("none_selected")
      # If a shape is clicked
      } else if (!is.null(rv$click)) {
        tags$table(stype = "width: 100%",
                   # Display the text of the selected shape
                   tags$tr(tags$td(style = "width: 70%",
                                   align = "left",
                                   htmlOutput("selected_shape")),
                           # Display the rest button
                           tags$td(uiOutput("clear_shape"))))
      }})
    
    
# PREPARE DATA -------------------------------------------------------------------------------
# Filtering and selecting data frame based on input
  
    # Get the main data frame depending onn the city
    city_data = reactive({
      get_city_data(input$city)
    })
    
    # Get the assets depending on the city and variable
    assets = reactive({
      get_assets(input$city, input$variable)
    })

    
# MAP OUTPUT  --------------------------------------------------------------------------------
# Defining how the map is rendered and updated based on the input 
# A base map is drawn, which is updated based on cities and variables chosen
# Each variable has a plot function defined in global.R script
    
    ## Base and Start Map ----
    # Draw base map 
    output$map = renderLeaflet({
      draw_base_map()
    })
    
    # If no city and no variable is selected, draw start map
    observe({
      req(input$city == "" & input$variable == "" & is.null(rv$click))
      draw_start_map()
    })
    
    # If reset all button is clicked, reset all variables, leads to start map
    observeEvent(input$reset_all, {
      reset("city")
      reset("variable")
      rv$click = NULL
    })
    
    ## City Map ----
    # Draw city map, if city is chosen or changed
    observeEvent(input$city, {
      req(input$city != "")
      reset("variable")
      rv$click <- NULL
      draw_city_map(input$city, city_data())
    })
    
    ## Variable Maps ----
    # Listen to these inputs to update the map
    toListen <- reactive({list(input$variable, 
                               input$ethnicity_selected, 
                               input$origin_selected,
                               input$religion_selected,
                               input$culture_selected,
                               # input$poi_selected, 
                               input$rent_selected)})
    
    # Observe above defined varaibles and plot corresponding map
    observeEvent(toListen(), {
      req(input$city != "" & input$variable != "")
      
      if (input$variable == "population_dens_km2"){
        draw_popdens_map(city_data(), assets())
        
      } else if (input$variable == "age_mean"){
        draw_age_map(city_data(), assets())
        
      } else if (input$variable == "ethnicity"){
        draw_ethnicity_map(city_data(), assets(), input$ethnicity_selected)
        
      } else if (input$variable == "origin"){
        draw_origin_map(city_data(), assets(), input$origin_selected)
        
      } else if (input$variable == "religion"){
        req(input$religion_selected != "")
        draw_religion_map(city_data(), assets(), input$religion_selected, input$city)
        
      } else if (input$variable == "culture"){
        req(input$culture_selected != "")
        draw_culture_map(city_data(), assets(), input$culture_selected, input$city)  
        
      # } else if (input$variable == "travel"){
      #   req(input$poi_selected != "")
      #   draw_travel_map(city_data(), assets(), input$poi_selected, poi_choices(), input$city)
    
      } else if (input$variable == "crime_rate"){
        draw_crime_map(city_data(), assets())
        
      } else if (input$variable == "rent"){
        req(input$rent_selected != "")
        draw_rent_map(city_data(), assets(), input$rent_selected)
        
      } else if (input$variable == "treecover"){
        draw_tree_map(city_data(), assets())
        
      }  else if (input$variable == "imperviousness"){
        draw_impervious_map(city_data(), assets())
      }
    })
  
  
# SIDEBAR OUTPUT -----------------------------------------------------------------------------
# Defining histogram and info outputs on the sidebar
    
    ## Histogram ----
    
    # Output for histogram
    output$histogram = renderPlot({
      req(input$variable != "")
      # If ethnicity or origin, the histogram can only be drawn if one is selected
      if (input$variable == "ethnicity"){req(length(input$ethnicity_selected) == 1)}
      if (input$variable == "origin"){req(length(input$origin_selected) == 1)}
      # Draw the histogram
      draw_histogram(input$variable, input$ethnicity_selected, input$origin_selected, input$religion_selected,
                     input$culture_selected, input$rent_selected, rv$click, city_data(), assets()) # input$poi_selected,
    })
    
    # Output of text for ethnicity (London)
    output$ethnicity_info = renderText({
      req(input$variable == "ethnicity")
      paste("Histogram can only be generated, if only one ethnicity is selected.")
    })
    
    # Output of text for place of origin (Berlin)
    output$origin_info = renderText({
      req(input$variable == "origin")
      paste("Histogram can only be generated, if only one place of origin is selected.")
    })
    
    # Putting it all together: creating a conditinal UI element
    output$conditional_histogram = renderUI({
      # Requires that a variable is selected
      req(input$variable != "")
      
      # Special case for ethnicity
      if (input$variable == "ethnicity"){
        # If it is only one, draw the histogram
        if (length(input$ethnicity_selected) == 1){
          plotOutput("histogram")
        # Otherwise write the text
        } else {
          textOutput("ethnicity_info")
        }
        
      # Special case for place of origin
      } else if (input$variable == "origin"){
        # If it is only one, draw the histogram
        if (length(input$origin_selected) == 1){
          plotOutput("histogram")
        # Otherwise write the text
        } else {
          textOutput("origin_info")
        }
        
      # In all other cases, draw the histogram
      } else {
        plotOutput("histogram")
      }
    })
    
    ## Info Text ----
    
    # Information about variable as info text
    output$variable_info = renderUI({
      req(input$variable != "")
      HTML(get_info_text(input$variable, input$city))})
}