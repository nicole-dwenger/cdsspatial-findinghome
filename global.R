# GLOBAL SCRIPT OF SHINY APP  
# ------------------------------
# This scripts loads libraries, data, defines functions to retrieve input options, draw and update maps and histograms.
# The functions defined in this script are sourced throughout the server.R and ui.R script. 

# LIBRARIES ----------------------------------------------------------

library(tidyverse)
library(leaflet)
library(leaflet.extras)
library(leafem)
library(shiny)
library(shinyWidgets)
library(shinyjs)
library(shinyBS)
library(sf)
library(stringr)
library(htmltools)
library(htmlwidgets)
library(ggplot2)
library(fontawesome)

# LOAD DATA ----------------------------------------------------------
# All data was preprocessed in the GitHub repository cds-spatial-preprocessing

# Global Data: coordinates for cities
city_info = data.frame(name = c("berlin", "london"), 
                       lat = c(52.52055, 51.50986),
                       lng = c(13.402067, -0.118092))

# London Data
# Main data with borough geometries and attribute data
london = readRDS("data/london/london.rds")
# Spatial point data for ethnicity, dot density plot
london_ethnicity_dots = readRDS("data/london/london_dot_coortinates.rds")
# Spatial point data of places of worship
london_religion_loc = readRDS("data/london/london_religion_locations.rds")
# Spatial point data of museums, theaters and nightlife
london_culture_loc = readRDS("data/london/london_culture_locations.rds")
# Spatial point data of points of interest, for transit travel time
london_poi = read.csv("data/london/london_poi.csv")

# Berlin Data
# Main data with Bezirk geometries and attribute data
berlin = readRDS("data/berlin/berlin.rds")
# Spatial point data for ethnicity, dot density plot
berlin_origin_dots = readRDS("data/berlin/berlin_dot_coordinates.rds")
# Spatial point data of places of worship
berlin_religion_loc = readRDS("data/berlin/berlin_religion_locations.rds")
# Spatial point data of museums, theaters and nightlife
berlin_culture_loc = readRDS("data/berlin/berlin_culture_locations.rds")
# Spatial point data of points of interest, for transit travel time
berlin_poi = read.csv("data/berlin/berlin_poi.csv")


# SELECT DATA --------------------------------------------------------

# Select the relevant main data frame based on the city
get_city_data = function(city){
  switch(city,
         "london" = london,
         "berlin" = berlin)
}

# INPUT VARIABLE OPTIONS ------------------------------------------------
# Functions to retrieve input options in the app, depending on the city.

# City options
cities = c("Choose a city" = "",
            "London" = "london",
            "Berlin" = "berlin")

# Variable options, dependent on city
get_variable_choices = function(city){
  
  if (city == "london"){
    c("Chooose a variable" = "",
      "Demography: Population Density" = "population_dens_km2",
      "Demography: Age Distribution" = "age_mean",
      "Diversity: Ethnicities" = "ethnicity",
      "Places of Culture: Places of Worship (PoW)" = "religion",
      "Places of Culture: Museums, Theatres & Nightlife" = "culture",
      "Infrastructure: Transit Traveltime" = "travel",
      "Psychological Security: Crime" = "crime_rate",
      "Psychological Security: Rent" = "rent",
      "Nature: Tree Cover Density" = "treecover",
      "Nature: Imperviousness" = "imperviousness")} 
  
  else if (city == "berlin"){
    c("Chooose a variable" = "",
      "Demography: Population Density" = "population_dens_km2",
      "Demography: Age Distribution" = "age_mean",
      "Diversity: Places of Origin" = "origin",
      "Places of Culture: Places of Worhsip (PoW)" = "religion",
      "Places of Culture: Museums, Theatres & Nightlife" = "culture",
      "Infrastructure: Transit Traveltime" = "travel",
      "Psychological Security: Crime" = "crime_rate",
      "Psychological Security: Rent" = "rent",
      "Nature: Tree Cover Density" = "treecover",
      "Nature: Imperviousness" = "imperviousness")}
}

# Ethnicity options, only for London
get_ethnicity_choices = function(city){
  
  if (city == "london"){
    c("Asian",
      "Arab",
      "Black",
      "Mixed",
      "White",
      "Other")}
}

# Country of origin options, only for Berlin
get_origin_choices = function(city){
  
  if (city == "berlin"){
    c("Africa" = "africa",
      "Asia" = "asia",
      "Europe" = "europe",
      "North America" = "north_america",
      "South America" = "south_america",
      "Oceanica" = "oceania",
      "Unknown" = "unknown")}
}

# Place of worship options
get_religon_choices = function(city){
  
  if (city == "london"){
    c("Buddist" = "buddhist", 
      "Hindu" = "hindu",
      "Jewish" = "jewish",
      "Muslim" = "muslim",
      "Sikh" = "sikh",
      "Protestant" = "protestant",
      "Catholic" = "catholic")}
  
  else if (city == "berlin"){
    c("Buddist" = "buddhist", 
      "Hindu" = "hindu",
      "Jewish" = "jewish",
      "Muslim" = "muslim",
      "Protestant" = "protestant",
      "Catholic" = "catholic")}
}

# Culture options, not dependent on city
get_culture_choices = function(){
  
  c("Museums" = "museum",
    "Theatres" = "theatre",
    "Nightlife" = "nightlife")
}

# Point of interest options for travel time, dependent on city
get_poi_choices = function(city){
  
  if (city == "london"){
    c("Train Station Liverpool Street" = "train_liverpoolstreet",
      "Train Station London Bridge" = "train_londonbridge",
      "Train Station Kings Cross" = "train_kingscross",
      "Train Station Paddington" = "train_paddington",
      "Train Station Victoria" = "train_victoria",
      "Train Station Waterloo" = "train_waterloo",
      "Airport Gatwick" = "air_gatwick",
      "Airport Heathrow" = "air_heathrow",
      "Airport London City" = "air_londonca",
      "Airport Luton" = "air_luton",
      "Airport Stansted" = "air_stansted",
      "Airport Southend" = "air_southend")}
  
  else if (city == "berlin"){
    c("Train Station Central" = "train_central",
      "Train Station Westkreuz" = "train_westkreuz",
      "Train Station Ostkreuz" = "train_ostkreuz",
      "Train Station Südkreuz" = "train_südkreuz", 
      "Airport Berlin/Brandenburg" = "air_berlin_brandenburg")}
}

# Rent options, dependent on city
get_rent_choices = function(city){
  
  if (city == "london"){
    c("1-Bedroom Apartment" = "median_rent1b",
      "2-Bedroom Apartment" = "median_rent2b")}
  
  else if (city == "berlin"){
    c("Euro/m2" = "median_rent")
  }
}

# FUNCTIONS TO DRAW MAPS --------------------------------------
# Here functions are defined to create a base map with leaflet
# Following are functions to update the map for each variable

# Fixing the position of NA in the legend to be inline
css_fix <- "div.info.legend.leaflet-control br {clear: both;}" # CSS to correct spacing
html_fix <- as.character(htmltools::tags$style(type = "text/css", css_fix))  # Convert CSS to HTML

# Base map with tiles and controls
draw_base_map = function(){
  
    # Initialise leaflet map
    leaflet(options = leafletOptions(zoomControl = FALSE)) %>%
      # Moving zoom control to the bottom right corner
      htmlwidgets::onRender("function(el, x) {L.control.zoom({ position: 'bottomright' }).addTo(this)}") %>%
      # Adding provider tiles
      addProviderTiles(providers$CartoDB.DarkMatter, group = "Black") %>%
      addProviderTiles(providers$CartoDB.Positron, group = "Grey") %>%
      addProviderTiles(providers$OpenStreetMap, group = "OSM") %>%
      addProviderTiles(providers$Esri.WorldImagery, group = "Aerial") %>%
      # Adding control for provider tiles
      addLayersControl(baseGroups = c("Black", "Grey", "OSM", "Aerial"), position = "bottomright",
                       options = layersControlOptions(collapsed = T)) %>%
      # Adding a scale bar
      addScaleBar(position="bottomleft")
}

# Start map with city markers
draw_start_map = function(){
  
  # Defining the icons for markers of the two cities 
  city_icon = makeAwesomeIcon(text = fa("home"), iconColor = "white", markerColor = "orange")

  # Update map with cluster markers
  leafletProxy("map") %>%
    # Clear all existing elements
    clearMarkers() %>%
    clearControls() %>%
    clearShapes() %>%
    clearImages() %>%
    clearMarkerClusters() %>%
    # Set the view to Europe
    setView(lat=52, lng=0, zoom = 5) %>%
    # Add markers for London and Berlin
    addAwesomeMarkers(lng = city_info$lng, lat = city_info$lat, 
                      label = str_to_title(city_info$name),
                      labelOptions = labelOptions(noHide = T, direction = "bottom"),
                      icon = city_icon)
}

# City map with polygons of chosen city
draw_city_map = function(city, city_data){
  
  # Get coordinates of the chosen city to zoom in 
  city_coordinates = city_info[city_info$name == city,]
  
  # Update Map with polygons
  leafletProxy("map") %>%
    # Clear all existing elements
    clearMarkers() %>%
    clearMarkerClusters() %>%
    clearShapes() %>%
    clearControls() %>%
    clearImages() %>%
    # Fly to the city
    flyTo(lat = city_coordinates$lat, lng = (city_coordinates$lng-0.3), zoom = 10) %>%
    # Add polygons for the districs
    addPolygons(layerId = ~name,
                data = city_data,
                label =  "name",
                color = "lightgrey", 
                weight = 1) 
}

# Population Density Map: Choropleth Map
draw_popdens_map = function(city_data, assets){
  
  # Make values numeric, to avoid problems later
  city_data$population_dens_km2 = as.numeric(city_data$population_dens_km2)
  
  # Define color palette, sequential
  pal = colorBin(
    palette = "YlOrRd",
    pretty = T,
    domain = city_data$population_dens_km2)
  
  # Define labels of polygons 
  label = lapply(seq(nrow(city_data)), function(i) {
    paste0("<b>", assets$shape_name,": </b>", city_data$name[i], "</br>", 
           "<b>", assets$variable_name, ": </b>", round(city_data$population_dens_km2[i], 3))})
  
  # Update map to add colored polygons
  leafletProxy("map") %>%
    # Clear all existing elements
    clearControls() %>%
    clearMarkers() %>%
    clearMarkerClusters() %>%
    clearImages() %>%
    # Add colored polygons for the boroughs, with labels
    addPolygons(data = city_data,
                layerId = ~name,
                color = "black",
                opacity = 0.8, 
                weight = 1,
                fillColor = ~pal(population_dens_km2),
                fillOpacity = 0.9,
                highlightOptions = highlightOptions(color = "black", weight = 3, bringToFront = TRUE),
                label = lapply(label, htmltools::HTML)) %>%
    # Add legend 
    addLegend(pal = pal,
              values = city_data$population_dens_km2,
              title = assets$legend_title,
              position = "topright", 
              opacity = 0.9)

}

# Age Distribution Map: Choropleth Map
draw_age_map = function(city_data, assets){
  
  # Turn variable to be numeric, to avoid problems later
  city_data$age_mean = as.numeric(city_data$age_mean)
  
  # Define color palette
  pal = colorBin(
    palette = c("#5ab4ac", "#f5f5f5", "#d8b365"),
    bins = 4,
    pretty = T,
    domain = city_data$age_mean)
  
  # Define labels for polygons
  label = lapply(seq(nrow(city_data)), function(i) {
    paste0("<b>", assets$shape_name,": </b>", city_data$name[i], "</br>", 
           "<b>", assets$variable_name, ": </b>", round(city_data$age_mean[i], 3))})
  
  # Update map with colored polygons
  leafletProxy("map") %>%
    # Clear all existing elements
    clearControls() %>%
    clearMarkers() %>%
    clearMarkerClusters() %>%
    clearImages() %>%
    # Add coloured poylgons with labels
    addPolygons(data = city_data, 
                layerId = ~name,
                color = "black",
                weight = 1,
                opacity = 0.8, 
                fillColor = ~pal(age_mean),
                fillOpacity = 0.9,
                highlightOptions = highlightOptions(color = "black", weight = 3, bringToFront = TRUE),
                label = lapply(label, htmltools::HTML)) %>%
    # Add legend
    addLegend(pal = pal,
              values = city_data$age_mean,
              title = assets$legend_title,
              position = "topright",
              opacity = 0.9)
  
}

# Ethnicity Map (London): Dot Density Map
draw_ethnicity_map = function(city_data, assets, ethnicity_selected){
  
  # Get the coordinates for the chosen ethnicities
  london_ethnicity_coords = london_ethnicity_dots %>% filter(ethnicity %in% ethnicity_selected)
  # Turn ethnicity into factor
  london_ethnicity_coords$ethnicity = as.factor(london_ethnicity_coords$ethnicity)
  
  # Defining color palette
  pal = colorFactor(
    palette = c("coral1","deepskyblue", "chartreuse2", "darkorange", "lightsteelblue1", "#df94ff"),
    levels = c("Asian", "Arab", "Black",  "Mixed", "White",  "Other"))
  
  # Update the map
  leafletProxy("map") %>%
    # Clear all existing elements
    clearControls() %>%
    clearMarkers() %>%
    clearMarkerClusters() %>%
    clearImages() %>%
    # Add grey polygons for the districts
    addPolygons(data = city_data,
                layerId = ~name,
                color = "lightgrey", 
                weight = 1,
                label = str_to_title(city_data$name)) %>%
    # Add points as dots to visualise dot density, coloured by ethnicity
    addCircleMarkers(data = london_ethnicity_coords,
                     radius = 1., 
                     fillColor = ~pal(ethnicity), 
                     fillOpacity = 0.9,
                     stroke = FALSE) %>%
    # Add a legend
    addLegend(data = london_ethnicity_coords,
              pal = pal,
              title = assets$legend_title,
              values = ~ethnicity,
              position = "topright",
              opacity = 0.9)
}

# Place of Origin Map (Berlin): Dot Density Map
draw_origin_map = function(city_data, assets, origin_selected){

  # Filer out the coordinates for points of the chosen origin
  berlin_origin_coords = berlin_origin_dots %>% filter(country_of_orig %in% origin_selected)
  # Turn the name of the place of origin into a pretty label
  berlin_origin_coords = berlin_origin_coords %>% 
    mutate("country_of_orig" = pretty_name(country_of_orig))
  
  # Turn into factor
  berlin_origin_coords$country_of_orig = as.factor(berlin_origin_coords$country_of_orig)

  # Defining color palette
  pal = colorFactor(
    palette = c("deepskyblue", "coral1", "lightsteelblue1", "chartreuse2", "#df94ff", "darkorange", "yellow"),
    levels = c("Africa", "Asia", "Europe", "North America", "South America", "Oceania", "Unknown"))
  
  # Updating Map
  leafletProxy("map") %>%
    # Clear all existing elements
    clearControls() %>%
    clearMarkers() %>%
    clearMarkerClusters() %>%
    clearImages() %>%
    # Add grey polygons for the districs
    addPolygons(data = city_data,
                layerId = ~name,
                color = "lightgrey", 
                weight = 1,
                label = str_to_title(city_data$name)) %>%
    # Add points for the dot density map
    addCircleMarkers(data = berlin_origin_coords,
                     radius = 1., 
                     fillColor = ~pal(country_of_orig), 
                     fillOpacity = 0.7,
                     stroke = FALSE) %>%
    # Add a legend
    addLegend(data = berlin_origin_coords,
              pal = pal,
              title = assets$country_of_orig,
              values = ~country_of_orig,
              position = "topright",
              opacity = 0.9)
}

# Places of Worship Map: Place Map
draw_religion_map = function(city_data, assets, religion_selected, city){
  
  # Select the relevant data frame and religion based on the input
  if (city == "london"){
    religious_coords = london_religion_loc %>% filter(religion == religion_selected)
  } else if (city == "berlin"){
    religious_coords = berlin_religion_loc %>% filter(religion == religion_selected)
  }
  
  # Define icon for locations
  icon = makeAwesomeIcon(text = fa("place-of-worship"), iconColor = "black", markerColor = "white")
  
  # Get column name of religion
  colname = eval(paste0("n_", religion_selected))
  # Define the label
  label = lapply(seq(nrow(city_data)), function(i) {
    paste0("<b>", assets$shape_name,": </b>", city_data$name[i], "</br>", 
           "<b>", assets$variable_name, ": </b>", city_data[[colname]][i])})
    
  # Update the map
  leafletProxy("map") %>%
    # Clear all existing elements
    clearMarkers() %>%
    clearMarkerClusters() %>%
    clearImages() %>%
    clearMarkerClusters() %>%
    clearControls() %>%
    # Add polygons of the districts
    addPolygons(layerId = ~name,
                data = city_data,
                color = "lightgrey", 
                weight = 1,
                label = lapply(label, htmltools::HTML)) %>%
    # Add markers for the places
    addAwesomeMarkers(data = religious_coords,
                      clusterOptions = markerClusterOptions(),
                      icon = icon,
                      label = ~name) %>%
    # Add a legend
    addLegend(labels = "Place of Worship (PoW)", colors = c("white"))
}

# Museums, Theatres & Nightlife Map: Place Map
draw_culture_map = function(city_data, assets, culture_selected, city){
  
  # Get coordinates based on city
  if (city == "london"){
    culture_coords = london_culture_loc
  } else if (city == "berlin"){
    culture_coords = berlin_culture_loc
  }
  
  # Get coordinates, icons and label depend on type of place
  if (culture_selected == "museum"){
    culture_coords = culture_coords %>% filter(type == "museum")
    icon = makeAwesomeIcon(text = fa("landmark"), iconColor = "black", markerColor = "white")
    label = lapply(seq(nrow(city_data)), function(i) {
      paste0("<b>", assets$shape_name,": </b>", city_data$name[i], "</br>", 
             "<b>", assets$variable_name, ": </b>", city_data$n_museum[i])})
    
  } else if (culture_selected == "theatre"){
    culture_coords = culture_coords %>% filter(type == "theatre")
    icon = makeAwesomeIcon(text = fa("theater-masks"), iconColor = "black", markerColor = "white")
    label = lapply(seq(nrow(city_data)), function(i) {
      paste0("<b>", assets$shape_name,": </b>", city_data$name[i], "</br>", 
             "<b>", assets$variable_name, ": </b>", city_data$n_theatre[i])})
    
  } else if (culture_selected == "nightlife"){
    culture_coords = culture_coords %>% filter(type == "nightlife")
    icon = makeAwesomeIcon(text = fa("glass-cheers"), iconColor = "black", markerColor = "white")
    label = lapply(seq(nrow(city_data)), function(i) {
      paste0("<b>", assets$shape_name,": </b>", city_data$name[i], "</br>", 
             "<b>", assets$variable_name, ": </b>", city_data$n_nightlife[i])})
  }
  
  # Update map 
  leafletProxy("map") %>%
    # Clear all existing elements
    clearControls() %>%
    clearMarkers() %>%
    clearMarkerClusters() %>%
    clearImages() %>%
    clearMarkerClusters() %>%
    # Add polygons in grey for th districts
    addPolygons(layerId = ~name,
                data = city_data,
                color = "lightgrey", 
                weight = 1,
                label = lapply(label, htmltools::HTML)) %>%
    # Add markers for the places
    addAwesomeMarkers(data = culture_coords,
                      clusterOptions = markerClusterOptions(),
                      icon = icon,
                      label = ~name) %>%
    # Add a legend
    addLegend(labels = str_to_title(culture_selected), colors = c("white"))
}

# Transit Travel Time Map: Choropleth Map with additional Elements
draw_travel_map = function(city_data, assets, poi_selected, poi_choices, city){

  # Select data frame with poi based on city
  if (city == "london"){poi_data=london_poi}
  else if (city == "berlin"){poi_data=berlin_poi}
  
  # Getting coordinates and name of point of interest
  poi_lat = poi_data$lat[poi_data$id == poi_selected]
  poi_lng = poi_data$lng[poi_data$id == poi_selected]
  poi_name = names(poi_choices[poi_choices == poi_selected])
  
  # Get subset of only the travel times for the poi
  travel_df = city_data %>%
    dplyr::select("name" = name, "traveltime" = paste0("time_", poi_selected), "center_coords" = center_coords)
  
  # Define color palette
  # For trains
  if (grepl("train", poi_selected) == TRUE){
    pal = colorBin(
      palette =  c("#31a354", "#fee8c8", "#e34a33"),
      bins = c(0,15,30,45,60,75,90),
      domain = travel_df$traveltime,
      pretty = TRUE)
  # For airports
  } else {
    pal = colorBin(
      palette =  c("#31a354", "#fee8c8", "#e34a33"),
      bins = 6,
      domain = travel_df$traveltime,
      pretty = TRUE)
  }
  
  # Define icon, depending on train or airplane
  icon_label = ifelse(grepl("train", poi_selected) == TRUE, "train", "plane-departure")
  icon = makeAwesomeIcon(text = fa(icon_label), iconColor = "black", markerColor = "white")
  
  # Define label of polygons
  label <- lapply(seq(nrow(travel_df)), function(i) {
    paste0("<b>", assets$shape_name,": </b>", travel_df$name[i], "</br>", 
           "<b>", assets$variable_name, ": </b> ", round(as.numeric(travel_df$traveltime[i]), 2), " min")})
  
  # Update map with markers
  leafletProxy("map") %>%
    # Clear all existing elements
    clearControls() %>%
    clearMarkers() %>%
    clearMarkerClusters() %>%
    clearImages() %>%
    # Add colored pol<gons
    addPolygons(data = travel_df,
                layerId = ~name,
                color = "black",
                weight = 1,
                opacity = 0.8,
                fillColor = ~pal(traveltime),
                fillOpacity = 0.9,
                highlightOptions = highlightOptions(color = "black", weight = 3, bringToFront = TRUE),
                label = lapply(label, htmltools::HTML)) %>%
    # Add markers for the point of interest
    addAwesomeMarkers(lng = poi_lng,
                      lat = poi_lat,
                      label = poi_name,
                      icon = icon) %>%
    # Add markers for the centroids
    addCircleMarkers(data = travel_df$center_coords, 
                     radius = 1, 
                     color = "white") %>%
    # Add a legend
    addLegend(pal = pal,
              values = travel_df$traveltime,
              title = assets$legend_title,
              position = "topright", 
              opacity = 1)
}

# Crime Map. Choropleth Map
draw_crime_map = function(city_data, assets){
  
  # Define palette
  pal = colorBin(
    palette = "Reds",
    pretty = T,
    domain = city_data$crime_rate)
  
  # Define labels for markers
  label = lapply(seq(nrow(city_data)), function(i) {
    paste0("<b>", assets$shape_name,": </b>", city_data$name[i], "</br>", 
           "<b>", assets$variable_name, ": </b>", round(city_data$crime_rate[i], 3))})
  
  # Update map with colored polygons
  leafletProxy("map", data = city_data) %>%
    # Clear all existing elements
    clearControls() %>%
    clearMarkers() %>%
    clearMarkerClusters() %>%
    clearImages() %>%
    # Add colored polygons
    addPolygons(data = city_data,
                layerId = ~name,
                color = "black",
                weight = 1,
                opacity = 0.8, 
                fillColor = ~pal(crime_rate),
                fillOpacity = 0.9,
                highlightOptions = highlightOptions(color = "black", weight = 3, bringToFront = TRUE),
                label = lapply(label, htmltools::HTML)) %>%
    # Add a legend
    addLegend(pal = pal,
              values = city_data$crime_rate,
              title = assets$legend_title,
              position = "topright",
              opacity = 0.9)
}

# Rent Map: Choropleth Map
draw_rent_map = function(city_data, assets, rent_selected){
  
  # Select the relevant rent column
  rent_data = city_data[c("name", rent_selected, "geometry")]
  colnames(rent_data) = c("name", "rent", "geometry")
  rent_data$rent = round(as.numeric(rent_data$rent), 2)
  
  # Define color palette
  pal = colorBin(
    palette = c("#01665e", "#f7f7f7", "#762a83"),
    bins = 7,
    pretty=T,
    domain = rent_data$rent)
  
  # Define labels of polygons 
  label = lapply(seq(nrow(rent_data)), function(i) {
    paste0("<b>", assets$shape_name,": </b>", rent_data$name[i], "</br>", 
           "<b>", assets$variable_name, ": </b>", round(rent_data$rent[i], 3))})
  
  # Update map with polygons
  leafletProxy("map") %>%
    # Clear all existing elements
    clearControls() %>%
    clearMarkers() %>%
    clearMarkerClusters() %>%
    clearImages() %>%
    # Add coloured polygons
    addPolygons(layerId = ~name,
                data = rent_data,
                color = "black",
                weight = 1,
                opacity = 0.8, 
                fillColor = ~pal(rent),
                fillOpacity = 0.9,
                highlightOptions = highlightOptions(color = "black", weight = 3, bringToFront = TRUE),
                label = lapply(label, htmltools::HTML)) %>%
    # Add a legend
    addLegend(pal = pal,
              values = rent_data$rent,
              title = assets$legend_title,
              position = "topright",
              opacity = 0.9)
  
}

# Tree Cover Density Map: Choropleth Map
draw_tree_map = function(city_data, assets){
  
  # Define palette
  pal = colorNumeric(
    palette = "Greens",
    domain = city_data$treecover)
  
  # Define labels for markers
  label = lapply(seq(nrow(city_data)), function(i) {
    paste0("<b>", assets$shape_name,": </b>", city_data$name[i], "</br>", 
           "<b>", assets$variable_name, ": </b>", round(city_data$treecover[i], 3))})
  
  # Update map with polygons
  leafletProxy("map", data = city_data) %>%
    # Clear all existing elements
    clearControls() %>%
    clearMarkers() %>%
    clearMarkerClusters() %>%
    clearImages() %>%
    # Add colored polygons
    addPolygons(data = city_data,
                layerId = ~name,
                color = "black",
                weight = 1,
                opacity = 0.8, 
                fillColor = ~pal(treecover),
                fillOpacity = 0.9,
                highlightOptions = highlightOptions(color = "black", weight = 3, bringToFront = TRUE),
                label = lapply(label, htmltools::HTML)) %>%
    # Add a legend
    addLegend(pal = pal,
              values = city_data$treecover,
              title = assets$legend_title,
              position = "topright",
              opacity = 0.9)
}

# Imperviousness Map: Choropleth Map
draw_impervious_map = function(city_data, assets){
  
  # Define palette
  pal = colorNumeric(
    palette = c("#31a354", "#fee8c8", "#e34a33"),
    domain = city_data$imperviousness)
  
  # Define labels for markers
  label = lapply(seq(nrow(city_data)), function(i) {
    paste0("<b>", assets$shape_name,": </b>", city_data$name[i], "</br>", 
           "<b>", assets$variable_name, ": </b>", round(city_data$imperviousness[i], 3))})
  
  # Update map with polygons
  leafletProxy("map", data = city_data) %>%
    # Clear all existing elements
    clearControls() %>%
    clearMarkers() %>%
    clearMarkerClusters() %>%
    clearImages() %>%
    # Add colored polygons
    addPolygons(data = city_data,
                layerId = ~name,
                color = "black",
                weight = 1,
                opacity = 0.8, 
                fillColor = ~pal(imperviousness),
                fillOpacity = 0.9,
                highlightOptions = highlightOptions(color = "black", weight = 3, bringToFront = TRUE),
                label = lapply(label, htmltools::HTML)) %>%
    # Add a legend
    addLegend(pal = pal,
              values = city_data$imperviousness,
              title = assets$legend_title,
              position = "topright",
              opacity = 0.9)
}

# FUNCTIONS TO DRAW HISTOGRAMS --------------------------------------
# Functions to draw the histogram on the control panel are defined here. 

# Function to draw the histogram, for most variables
draw_histogram = function(input_variable, ethnicity_selected, origin_selected, religion_selected, 
                               culture_selected, poi_selected, rent_selected, click, city_data, assets){
  
  # Special cases, where the variable is specified with another input option
  variable = case_when(
    input_variable == "ethnicity" & length(ethnicity_selected) == 1  ~ paste0("ethnicity_perc_", tolower(ethnicity_selected)),
    input_variable == "origin" & length(origin_selected) == 1  ~ paste0("origin_perc_", origin_selected),
    input_variable == "culture" ~ paste0("n_", culture_selected),
    input_variable == "religion" ~ paste0("n_", religion_selected),
    input_variable == "rent" ~ rent_selected,
    input_variable == "travel" ~ paste0("time_", poi_selected),
    TRUE ~ input_variable # else just the same name
  )
  
  # Select the data for the histogram
  hist_data = st_as_sf(city_data) %>% st_drop_geometry() %>% .[,c("name", variable)] 
  # Rename the columns
  colnames(hist_data) = c("name", "variable")
  
  # Order columns for histogram
  hist_data$variable = as.numeric(hist_data$variable)
  # Order the data in descending order
  hist_data$name = fct_reorder(hist_data$name, hist_data$variable)
  
  # Plot if no shape is clicked
  if (is.null(click)){
    hist_data %>%
      ggplot(aes(x = name, y = variable)) +
      geom_bar(stat = "identity", show.legend = FALSE, fill = "darkgrey") +
      coord_flip() +
      labs(y = assets$variable_name, x = assets$shape_name, title = assets$plot_title) +
      theme_classic()
    
  # Plot if shape is clicked (and it is not age mean), highlight the bar
  } else if (!is.null(click) && variable != "age_mean"){
    hist_data %>%
      ggplot(aes(x = name, y = variable)) +
      geom_bar(stat = "identity", show.legend = FALSE, aes(fill = factor(ifelse(name == click$id, "highlight", "normal")))) + 
      scale_fill_manual(values = c("black", "darkgrey")) +
      coord_flip() +
      labs(y = assets$variable_name, x = assets$shape_name, title = assets$plot_title) +
      theme_classic()
  
  # Plot if shape is clicked and it is age mean, draw age histogram
  } else if (!is.null(click) && variable == "age_mean"){
    # Prepare data, turn age ranges into long format
    polygon_data = city_data %>% 
      # Drop geometry
      st_drop_geometry() %>%
      # Only get the borough that is clicked
      dplyr::filter(name == click$id) %>% 
      # Only select columns for ages
      dplyr::select(c("perc_age_0_9":"perc_age_90+")) %>%
      # Turn into long format
      gather("age", "perc") %>%
      # Turn into data frame
      as.data.frame()
    
    # Make pretty names for plot
    polygon_data$age = str_replace_all((str_remove_all(polygon_data$age, "perc_age_")), "_", "-")
    
    # Make ggplot histogram with age distribution for 
    ggplot(polygon_data, aes(x = age, y = perc)) +
      geom_bar(stat = "identity", width = 0.6, position = "dodge") +
      theme_classic() +
      theme(axis.text.x = element_text(angle = 45, vjust = 0.5)) +
      labs(x = "Age Range", y = paste("Percentage of", assets$shape, "Population"), 
           title = paste("Age distribution in", click$id))
  }
  
}

# ASSETS --------------------------------------
# Functions to turn strings into pretty variables and get titles and names

# Function to turn names into pretty names
pretty_name = function(raw_name){
  name = str_replace_all(raw_name, "_", " ")
  name = str_to_title(name)
  name = as.character(name)
  name
}

# Function to get pretty names and titles
get_assets = function(city, variable){
  
  # Initialize empty list
  assets = list()
  
  # Name of the shape, depended on the city
  assets$shape_name = case_when(
    city == "london" ~ "Borough",
    city == "berlin" ~ "Bezirk"
  )
  
  # Name of the variable, for labels and plot
  assets$variable_name = case_when(
    variable == "population_dens_km2" ~ "Population per km2",
    variable == "age_mean" ~ "Mean Age in Years",
    variable == "ethnicity" ~ "% of Population of Ethnicity",
    variable == "origin" ~ "% of Population of Origin",
    variable == "religion" ~ "Number of PoW for Selected Religion",
    variable == "culture" ~ "Number of Places for Selected Type",
    variable == "travel" ~ paste("Transit Travel Time in Minutes"),
    variable == "crime_rate" ~ "Number of Crimes per 1000",
    variable == "rent" & city == "london" ~ "Median Rent in ₤",
    variable == "rent" & city == "berlin" ~ "Median Rent in €/m2",
    variable == "treecover" ~ paste("Mean % of Tree Cover Density"),
    variable == "imperviousness" ~ paste("Mean % of Imperviousness")
  )
  
  # Name of the legend title
  assets$legend_title = case_when(
    variable == "population_dens_km2" ~ "Population per km2",
    variable == "age_mean" ~ "Mean Age in Years",
    variable == "ethnicity" ~ "Ethnicity",
    variable == "origin" ~ "Place of Origin",
    variable == "religion" ~ "Number of Places",
    variable == "culture" ~ "Number of Places",
    variable == "travel" ~ paste("Transit Travel Time</br>to PoI in Minutes"),
    variable == "crime_rate" ~ "Number of Crimes per 1000",
    variable == "rent" & city == "london" ~ "Median Rent in ₤",
    variable == "rent" & city == "berlin" ~ "Median Rent in €/m2",
    variable == "treecover" ~ paste("Mean % of</br>Tree Cover Density"),
    variable == "imperviousness" ~ paste("Mean % of</br>Imperviousness")
  )
  
  # Name of the plot title
  assets$plot_title = case_when(
    variable == "population_dens_km2" ~ paste("Population per km2 for each", assets$shape),
    variable == "age_mean" ~ paste("Age Distribution in Selected", assets$shape),
    variable == "ethnicity" ~ paste("Ethnicity Population per", assets$shape),
    variable == "origin" ~ paste("Place of Origin Population per", assets$shape),
    variable == "religion" ~ paste("Number of PoW per", assets$shape),
    variable == "culture" ~ paste("Number of places per", assets$shape),
    variable == "travel" ~ paste("Transit Travel Time to PoI per", assets$shape),
    variable == "crime_rate" ~ paste("Crime Rate per", assets$shape),
    variable == "rent" & city == "london" ~ paste("Median Rent per", assets$shape),
    variable == "rent" & city == "berlin" ~ paste("Median Rent in €/m2 per", assets$shape),
    variable == "treecover" ~ paste("Mean % of Tree Cover Density per", assets$shape),
    variable == "imperviousness" ~ paste("Mean % of Imperviousness per", assets$shape)
    )
  
  # Return assets
  assets
}

# INFO TEXTS --------------------------------------
# Getting information about the variables

# Function to get info text for the variables
get_info_text = function(variable, city){
  
  text = case_when(
    variable == "population_dens_km2" & city == "london" ~ "<p>Total population are 2019-based projections for 2020, 
    extracted and processed from the <a href='https://data.london.gov.uk/dataset/gla-population-projections-custom-age-tables?q=age%20demographics'> 
    London Data Store</a>, where you can find the data and additional metadta. Area values for each borough were calculated from vector data of the boroughs.
    The total popualtion values were divided by the area to get a measure of population density.</p>",
    
    variable == "population_dens_km2" & city == "berlin" ~ "<p>Total population values were extracted for 31.12.2019, from the 
    <a href='https://www.statistik-berlin-brandenburg.de/webapi/jsf/dataCatalogueExplorer.xhtml'> 
    Einwohnerregisterstatistik Berlin</a>, where you can also find additional metadta. Area values for each Bezirk were calculated from the vector data of the Bezirke. 
    Total popualtion values were divided by the area to get a measure of population density.</p>",
    
    variable == "age_mean" & city == "london" ~ "<p>Values were extracted and calculated using 2019-based projected values 
    for 2020 from the <a href='https://data.london.gov.uk/dataset/gla-population-projections-custom-age-tables?q=age%20demographics'>
    London Data Store</a>, where you can also find metadata. Detailed calcualtions can be seen on <a href='https://github.com/nicole-dwenger/cdsspatial-preprocessing'>
    GitHub</a>.</p>",
    
    variable == "age_mean" & city == "berlin" ~ "<p>Values were extracted and calculated using statistics for 2019/12/31 from the 
    <a href='https://www.statistik-berlin-brandenburg.de/webapi/jsf/tableView/tableView.xhtml '> 
    Einwohnerregisterstatistik Berlin</a>, where you can also find metadata. Detailed calcualtions can be seen on <a href='https://github.com/nicole-dwenger/cdsspatial-preprocessing'>
    GitHub</a>.</p>",
    
    variable == "ethnicity" ~ "<p>Dots were sampled on the level of output areas in London, based on the 2011 census data, extracted
    from the <a href='LINK'> 
    NAME</a>. Percentages were calculated by matching output areas to the boroughs. See <a href='https://github.com/nicole-dwenger/cdsspatial-preprocessing'>
    GitHub</a> for sampling of dots.</p>",

    variable == "origin" ~ "<p>Dots were sampled on the level of Planungsräume in Berlin, based on data from 2019/12/31 from the 
    <a href='https://www.statistik-berlin-brandenburg.de/webapi/jsf/tableView/tableView.xhtml '> Einwohnerregisterstatistik Berlin</a>. 
    Percentages were calculated by matching output areas to the boroughs. See <a href='https://github.com/nicole-dwenger/cdsspatial-preprocessing'>
    GitHub</a> for sampling of dots.</p>",
    
    variable == "religion" ~ "<p>Data was extracted from Open Street Map. Details of the queries can be seen on 
    <a href='https://github.com/nicole-dwenger/cdsspatial-preprocessing'>GitHub</a>.</p>",
    
    variable == "culture" ~ "<p>Data was extracted from Open Street Map. Details of the queries can be seen on 
    <a href='https://github.com/nicole-dwenger/cdsspatial-preprocessing'>GitHub</a>. Note, that nightlife includes bars, pubs and nightclubs.</p>",
    
    variable == "travel" ~ "<p>Travel times were extracted from Google Maps. They indicate
    the times it takes to travel from the centroid of each borough or Bezirk to the PoI, using public transport on Monday (2021/06/07) at 8:00am. 
    Be aware that times may vary depending on the time and day, the values should rather be used for comparison. If you cannot see the location of an aiport 
    on the map, try zooming out.</p>",

    variable == "crime_rate" & city == "london" ~ "<p>Crime data of 2020 was extracted from the 
    <a href = https://data.london.gov.uk/dataset/recorded_crime_summary> London Data Store</a>, where you can also find further metadata. 
    All crimes were summarised for each borough and divided by the total popualtion data, which was calcualted using population data for 2020 from the 
    <a href='https://data.london.gov.uk/dataset/gla-population-projections-custom-age-tables?q=age%20demographics'>
    London Data Store</a> and multiplied by 1000 to get total number of crimes / 1000.</p>",
    
    variable == "crime_rate" & city == "berlin" ~ "<p>Crime data of 2020 was extracted from the 
    <a href='https://www.berlin.de/polizei/service/kriminalitaetsatlas/'> Polizei Berlin</a>, where you can also find metadata. If was
     divided by the total population of 2019-12-31, extracted from the <a href='https://www.statistik-berlin-brandenburg.de/webapi/jsf/tableView/tableView.xhtml '> 
    Einwohnerregisterstatistik Berlin</a>, and multiplied by 1000 to calculate the crime rate.</p>",
    
    variable == "rent" & city == "london" ~ "<p>Rent values refer to the median rent for an apartment 
    in the private rent market in 2020. These were extracted from the <a href='https://www.ons.gov.uk/peoplepopulationandcommunity/housing/adhocs/12871privaterentalmarketinlondonjanuarytodecember2020'>
    Office of National Statistiks</a>, where you can also find additional metadata.</p>",
    
    variable == "rent" & city == "berlin" ~ "<p>Rent values refer to the median net rent without utilities per m2, in 2018. Data and additional metadata
    can of the Wohnatlas can be found <a href='https://www.stadtentwicklung.berlin.de/wohnen/wohnatlas/index.shtml'> here</a>.<p>",
    
    variable == "treecover" ~ "<p>Mean percentages of treecover were extracted from high resolution raster data for 2018, provided by the 
    <a href='https://land.copernicus.eu/pan-european/high-resolution-layers/forests/tree-cover-density/status-maps/tree-cover-density-2018'>
    European Environment Agency</a>, where you can also find metadata.</p>",
    
    variable == "imperviousness" ~ "<p>Mean percentages of imperviousness were extracted from high resultion raster data for 2018, provided by the
    <a href='https://land.copernicus.eu/pan-european/high-resolution-layers/imperviousness/status-maps/imperviousness-density-2018'>
    European Environment Agency</a>, where you can also find metadata.</p>",
    
    TRUE ~ "no description available yet")
  
  # Return text
  text
}
