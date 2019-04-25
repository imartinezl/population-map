
library(dplyr)

data <- read.csv('C2011_RejillaEU_Indicadores.csv', stringsAsFactors = F)

map <- rgdal::readOGR('Grid_ETRS89_LAEA_ES_1K/Grid_ETRS89_LAEA_ES_1K.shp', stringsAsFactors = F) %>% 
  subset(data$GRD_NEWID %in% GRD_NEWID)


d <- merge(data, map@data, by.x="GRD_NEWID", by.y="GRD_NEWID", all.x = T)
