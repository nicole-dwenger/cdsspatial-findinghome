### 1. About this App
This shiny app was developed by Orla Mallon and Nicole Dwenger as the Final Project of the course Cultural Data Science: Spatial Analytics at Aarhus University.  
The app aims to provide a tool which will help people that are moving to a new city find areas which are the best fit for their needs.

All code, scripts and data of this app can be found on [Github](https://github.com/nicole-dwenger/cdsspatial-findinghome).  
The data, which is displayed on this app was prepared and preprocessed in several separate scripts, which can also be found on [Github](https://github.com/nicole-dwenger/cdsspatial-preprocessing).  
Sources can be found below (3.).  

If you have any questions, feel free to contact us at [orla.mallon95@gmail.com](orla.mallon95@gmail.com]) or [nicole.dwengr@gmail.com](nicole.dwengr@gmail.com).

### 2. Things to Keep in Mind when Using the App
Firstly, it should be noted that for best visualization, the app should be used with the default tiles. Feel free to also explore the other tiles, we just cannot guarantee that it will look great. Second, the app is intended to be used for comparison of districts within each city. If you are exploring variables across cities, keep in mind that scales and coloring schemes differ between cities. Thus, make sure to carefully take into consideration the legend. 
It should also be noted, that this app mainly visualizes data on the level of boroughs in London and Bezirke in Berlin. Consequently, it cannot display more fine-grained and local features. In other words, you might still find a green neighborhood in a district with a low mean % of tree cover density. 
Lastly, please make use of the *information* button for more detailed information of the variable. Take into consideration, that cities are ever-changing, and the data might not correspond to the current state. 

### 3. References, Licenses and Credit
Thanks to all the great people and organizations who share their data, software and ideas!

#### 3.1. Data
The references below refer to the raw data sources, which were pre-processed to be used on this app. 

##### 3.1.1. London 
This project contains Ordnance Survey data © Crown copyright and database right 2011.  
This project contains National Statistics data © Crown copyright and database right 2011.  

- Greater London Authority (2011a) London Borough Profiles and Atlas [Data Set, Web app]. Retrieved May 2021 from https://data.london.gov.uk/dataset/london-borough-profiles. Licensed under UK Open Government License.
- **Borough and Output Shapefiles**: Greater London Authority (2011b). Statistical GIS Boundary Files for London [Data Set]. Retrieved May 2021 from https://data.london.gov.uk/dataset/statistical-gis-boundary-files-london. Licensed under UK Open Government License.
- **Population and Age**: Greater London Authority. (2020). 2019-based trend projections, Central Range (upperbound) [Data Set]. Retrieved May, 2021 from https://data.london.gov.uk/dataset/gla-population-projections-custom-age-tables?q=ae%20demographics. Licensed under UK Open Government License.
- **Crime Data**: Metropolitan Police Service. (2021). MPS Borough Level Crime (most recent 24 months) [Data Set]. Retrieved May 2021 from https://data.london.gov.uk/dataset/recorded_crime_summary. Licensed under UK Open Government Licence.
- **Ethnicity Data**: Office for National Statistics (2011). Census Data 2011 - Workday Population - Ethnic Group. [Data	Set]. Retrieved May 2021, from https://www.nomisweb.co.uk/census/2011/wd201ew.  
Licensed under UK Open Government License.
- **Rent Data**: Office for National Statistics (2021). Private rental market in London: January to December 2020 [Data Set]. Retrieved May 2021 from  
https://www.ons.gov.uk/peoplepopulationandcommunity/housing/adhocs/12871privaerentalmarketinlondonjanuarytodecember2020. Licensed under UK Open Government License.
- **Output Area Classification**: UCL (on behalf of Greater London Authority), 2014. London Output Area Classification [Data Set]. Retrieved May 2021, from https://data.london.gov.uk/dataset/london-area-classification. Licensed under CC.
 
##### 3.1.2. Berlin

- **Planungsräume Shapefiles**: Amt für Statistik Berlin-Brandenburg (2015a). Lebensweltlich orientierte Räume (LOR)-Planungsräume [Data Set]. Retrieved May 2021, through FIS-Broker, from https://fbinter.stadt-berlin.de/fb/index.jsp. Licensed under CC BY 3.0 DE
- **Prognoseräume Shapefiles**: Amt für Statistik Berlin-Brandenburg (2015b). Lebensweltlich orientierte Räume (LOR)-Prognoseräume. [Data Set]. Retrieved May 2021, through FIS-Broker, from https://fbinter.stadt-berlin.de/fb/index.jsp. Licensed under CC BY 3.0 DE.
- **Population, Age and Place of Orign Data**: Amt für Statistik Berlin-Brandenburg (2019). Einwohnerregisterstatistik Berlin [Data Set]. Retrieved May 2021, from Statistisches Informationssystem Berlin Brandenburg, https://www.statistik-berlin-brandenburg.de/webapi/jsf/tableView/tableView.xhtml. Licensed under CC BY 3.0 DE. 
- **Bezirk Shapefiles**: Geoportal Berlin (2017). Bezirksgrenzen, ESRI Shapefile [Data Set]. Retrieved May 2021, from https://daten.odis-berlin.de/de/dataset/bezirksgrenzen/. Licensed under https://www.stadtentwicklung.berlin.de/geoinformation/download/nutzIII.pdf.
- **Rent Data**: Geoportal Berlin (2019). Wohnatlas Berlin - Angebotsmieten 2018 (in EUR/m² monatlich, netto kalt). [Data Set]. Retrieved May 2021, through FIS-Broker, https://www.stadtentwicklung.berlin.de/wohnen/wohnatlas/index.shtml. Licensed under Data licence Germany – attribution – Version 2.0 
- **Crime Data**: Polizei Berlin (2020). Polizeiliche Kriminalstatistik [Data Set]. Retrieved May 2021 from https://daten.berlin.de/datensaetze/kriminalitätsatlas-berlin. Licensed under CC BY-SA 3.0 DE.

##### 3.1.3. Global

- **Tree Cover Density**: © European Union, Copernicus Land Monitoring Service, European Environment Agency (EEA) (2018a). High Resolution Layer: Imperviousness Density (IMD) 2018 [Data Set]. Retrieved May 2021, from https://land.copernicus.eu/pan-european/high-resolution-layers/imperviousness/statusmaps/imperviousness-density-2018?tab=metadata. Licensed under Copernicus data and information policy Regulation (EU).
- **Imperviousness**: © European Union, Copernicus Land Monitoring Service, European Environment Agency (EEA) (2018b). High Resolution Layer: Tree Cover Density (TCD) 2018 [Data Set]. Retrieved from May 2021, from https://land.copernicus.eu/pan-european/high-resolution-layers/forests/tree-cover-denity/status-maps/tree-cover-density-2018?tab=mapview. Licensed under Copernicus data and information policy Regulation (EU)
- **Coordinates**: Google (n.d.). [Google Maps coordinates for defined PoI]. Retrieved 1 June 2021 from https://www.google.de/maps.
- **OSM Data**: OpenStreetMap contributors. (2021) Data of Places of Worship, Museums, Theaters and Nightlife
[Data Sets from 2021]. Retrieved May 2021. Licensed under Open Data Commons Open Database License. 

#### 3.2. Software
- Appelhans, T. (2020). leafem: 'leaflet' Extensions for 'mapview'. R package version 0.1.3. https://CRAN.R-project.org/package=leafem
- Attali, D. (2020). shinyjs: Easily Improve the User Experience of Your Shiny Apps in Seconds. R package version 2.0.0. https://CRAN.R-project.org/package=shinyjs
- Bailey, E. (2015). shinyBS: Twitter Bootstrap Components for Shiny. R package version 0.61. https://CRAN.R-project.org/package=shinyBS
- Chang, W., Cheng, J., Allaire, JJ., Xie, Y. & McPherson, J. (2020). shiny: Web Application Framework for R. R package version 1.5.0. https://CRAN.R-project.org/package=shiny
- Cheng, J., Karambelkar, B., & Xie, Y. (2021). leaflet: Create Interactive Web Maps with the JavaScript 'Leaflet' Library. R package version 2.0.4.1. https://CRAN.R-project.org/package=leaflet
- Cheng, J., Sievert, C., Chang, W., Xie, Y. & Allen, J. (2021). htmltools: Tools for HTML. R package version 0.5.1.1. https://CRAN.R-project.org/package=htmltools
- Huang, L. (2019). leaflet.providers: Leaflet Providers. R package version 1.9.0. https://CRAN.R-project.org/package=leaflet.providers
- Iannone, R. (2021). fontawesome: Easily Work with 'Font Awesome' Icons. R package version 0.2.1. https://CRAN.R-project.org/package=fontawesome
- Karambelkar, B. & Schloerke, B. (2018). leaflet.extras: Extra Functionality for 'leaflet' Package. R package version 1.0.0. https://CRAN.R-project.org/package=leaflet.extras
- Pebesma, E., 2018. Simple Features for R: Standardized Support for Spatial Vector Data. The R Journal 10 (1), 439-446, https://doi.org/10.32614/RJ-2018-009
- Perrier, V., Meyer, F. & Granjon, D. (2021). shinyWidgets: Custom Inputs Widgets for Shiny. R package version 0.6.0. https://CRAN.R-project.org/package=shinyWidgets
- R Core Team (2020). R: A language and environment for statistical computing. R Foundation for Statistical Computing, Vienna, Austria. URL https://www.R-project.org/.
- RStudio Team (2020). RStudio: Integrated Development for R. RStudio, PBC, Boston, MA, http://www.rstudio.com/.
- Vaidyanathan, R., Xie, Y.,  Allaire, JJ, Cheng, J., Sievert, C, and Russell, K. (2020). htmlwidgets: HTML Widgets for R. R package version 1.5.3. https://CRAN.R-project.org/package=htmlwidgets
- Wickham, H. (2016) ggplot2: Elegant Graphics for Data Analysis. Springer-Verlag New York.
- Wickham, H. (2019). stringr: Simple, Consistent Wrappers for Common String Operations. R package version 1.4.0. https://CRAN.R-project.org/package=stringr
- Wickham et al., (2019). Welcome to the tidyverse. Journal of Open Source Software, 4(43), 1686, https://doi.org/10.21105/joss.01686

#### 3.3. Ideas, Inspiration and Knowledge
- Angiolillo, S. (2019). Using Shiny to Explore Electricity, Latrine & Water Access in India. Atlan |
Humans of Data. Retrieved 6 June 2021, from https://humansofdata.atlan.com/2019/01/shiny-electricity-latrine-water-india.
- Brewer, C. (2021). Color Brewer 2.0. Retrieved 6 June 2021, from http://www.ColorBrewer.org. 
- Gimond, M. (2021). Intro to GIS and Spatial Analysis. Retrieved 6 June 2021, from https://mgimond.github.io/Spatial/index.html. Licensed under Creative Commons Attribution-NonCommercial 4.0 International License.
</br>

### 4. License
<a rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/3.0/80x15.png" /></a> Unless otherwise stated, this work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/">Creative Commons Attribution-ShareAlike 3.0 Unported License</a>.