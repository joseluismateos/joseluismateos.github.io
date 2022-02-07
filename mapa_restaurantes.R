##install.packages(c("httr", "jsonlite")) 
library(httr)
library(jsonlite)
library(leaflet)
library(tidyverse)
library(leaflet.extras)


res <- GET("http://dadesobertes.seu-e.cat/api/aoc/action/odata/c78ef5ed-761f-4f6a-b121-20ac6067950b?$format=json")

data <- fromJSON(rawToChar(res$content))

names(data)[which(names(data)=="LONGITUD")] <- "lng"
names(data)[which(names(data)=="LATITUD")] <- "lat"

data$lat <- as.numeric(data$lat)
data$lng <- as.numeric(data$lng)

## Test same coordinates

data$coord <- paste(data$lat, data$lng)
test <- data
test <- test[test$CODI_SUBSECTOR==902,]
test <- test[test$DESC_POLIGON!="Aeroport" & test$DESC_POLIGON != "SPlau",]


test <- test[!duplicated(test$coord),]

test <- test[test$NOM_COMERCIAL!="",]

table(data$CODI_SUBSECTOR)

pep <- read.csv("/Users/joseluismateos-gonzalez/Desktop/Mapa Bares/Pep.csv")

test <- left_join(test, pep, by="NUMEMPRE")

leaflet(test) %>% 
  addProviderTiles("CartoDB.Positron") %>%
  addCircleMarkers(
    data = test[test$Pep=="No he estado",],
    label = test$NOM_COMERCIAL.x[test$Pep=="No he estado"],
    fillColor =  "#2BC9AF",
    fillOpacity = 0.8,
    group = "No he estado",
    color = "black",
    radius = 7,
    stroke = TRUE,
    weight = 1) %>%
  addCircleMarkers(
    data = test[test$Pep=="He estado",],
    label = test$NOM_COMERCIAL.x[test$Pep=="He estado"],
    group = "He estado",
    fillColor =  "#FF2A00",
    fillOpacity = 0.8,
    color = "black",
    radius = 7,
    stroke = TRUE,
    weight = 1) %>%
  addMarkers(
    data = test,
    group = 'sitios', # this is the group to use in addSearchFeatures()
    # make custom icon that is so small you can't see it:
    icon = makeIcon( 
      iconUrl = "http://leafletjs.com/examples/custom-icons/leaf-green.png",
      iconWidth = 1, iconHeight = 1
    )) %>%
  addSearchFeatures(
    targetGroups = 'sitios', # group should match addMarkers() group
    options = searchFeaturesOptions(
      zoom=80, openPopup = TRUE, firstTipSubmit = TRUE,
      autoCollapse = FALSE, hideMarkerOnCollapse = TRUE
    )) %>%
  addLegend(labels = c("He estado", "No he estado"), 
            position = "topright", colors= c("#FF2A00","#2BC9AF"),
            title = "¿Ha estado Pep?") %>%
addResetMapButton()


