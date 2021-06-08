# Spatial Analytics: Shiny App - Finding Home :house:

[Description](#descripton) | [Data and Software](#data-and-software) | [Reproducability](#reproducability) | [Credits and References](#credits-and-references) | [License](#license) | [Contact](#contact)

---

## Description
This repository contains all scripts and data of the shiny app **Finding Home**, which can be reproduced online through the following link: https://cds-spatial.shinyapps.io/finding-home/ 

This app was developed by Orla Mallon and Nicole Dwenger as the final project for the course Cultural Data Science: Spatial Analytics, at Aarhus University. THe aim of this app is to provide a self-exploratory tool, to compare districts of a city (London or Berlin) based on a set of variables. Thus, it is intended to help people on the move to find the district in which they would feel most at home based on their personal needs and interests. Feel free to go and explore the app. More information is also provided on the **About** tab in the app. Note, that several chunks of code relating to the variable of Transit Travel Time are commented out as it was not possible to visualize them in line with license agreements of [Google Maps](https://cloud.google.com/maps-platform/terms/#3.-license).

## Data and Software
The data, which is contained in this repository and visualized on the app, was gathered from several sources and pre-processed in a separate [GitHub Repository](https://github.com/nicole-dwenger/cdsspatial-preprocessing). 
All sources, references and licenses of the **raw** data can be found in the `about.md` file. Here you can also find references to the software used in this project.

## Reproducability
The app is meant to be reproduced online. However, if you wish to run the app locally, you can clone the repository, and install necessary dependencies to run the app, by following these steps: 

#### Requirements 
This app was developed on macOS 11.4, using R 4.0.2 and R Studio 1.3.1073. More details and specifically the packages and their versions which were used to run the app locally can be seen in the `sessionInfo.txt` file. 

#### 1. Clone the Repository 
The following command can be used to clone the repository, from the terminal:

```bash
# Clone the repository
git clone https://github.com/nicole-dwenger/cdsspatial-findinghome.git
```

#### 2. Open Project and Install Dependencies
After you have cloned the repository, you can open the project in RStudio. Now you should make sure you have installed all necessary packages, which are loaded in the `global.R` script. The detailed versions of the packages can be found in the `sessionInfo.txt` file. To install packages, you can use the following code in R: 

```r
# Example of installing shiny
install.packages("shiny")
```

#### 4. Running the App 
If you have installed all requirements, you can run the app with the following code in R:

```r
# Running the app 
shiny::runApp()
```

Otherwise, if you have opened the `global.R`, `server.R` or `ui.R` file in R Studio, you can also run the app by clicking the small `Run` button in the Editor. You can stop the app, by clicking the small stop button in the console in R Studio. 

## License
<a rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/3.0/80x15.png" /></a> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/">Creative Commons Attribution-ShareAlike 3.0 Unported License</a>.

## Contact
If you have any questions, feel free to contact us at 
[orla.mallon95@gmail.com](orla.mallon95@gmail.com]) or [nicole.dwengr@gmail.com](nicole.dwengr@gmail.com)