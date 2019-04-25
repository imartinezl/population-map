library(sf)
library(dplyr)

# Rejilla Grid_ETRS89_LAEA_ES_1K ------------------------------------------------------------------------

data_file <- "spain_population_2011.csv"
if(!file.exists(data_file)){
  data <- data.table::fread('C2011_RejillaEU_Indicadores.csv', stringsAsFactors = F)
  # map <- rgdal::readOGR('Grid_ETRS89_LAEA_ES_1K/', stringsAsFactors = F)
  map <- sf::st_read('Grid_ETRS89_LAEA_ES_1K/', stringsAsFactors = F)
  map_df <- map %>% sf::st_set_geometry(NULL)
  
  en2longlat <- function(d, map){
    long_lat <- cbind(d$E*1e3, d$N*1e3) %>% 
      sp::SpatialPoints(proj4string=sp::CRS( sf::st_crs(map)$proj4string)) %>% 
      sp::spTransform(sp::CRS("+proj=longlat")) %>% 
      as.data.frame()
    colnames(long_lat) <- c("long","lat")
    return(cbind(d,long_lat))
  }
  merge(map_df %>% dplyr::select(GRD_NEWID), 
        data %>% dplyr::select(GRD_NEWID, t1_1),
        by="GRD_NEWID", all.x = T) %>% 
    dplyr::mutate(t1_1 = ifelse(is.na(t1_1),0,t1_1))  %>% 
    dplyr::mutate(N = stringr::str_extract(GRD_NEWID, '(?<=N)\\d+') %>% as.numeric,
                  E = stringr::str_extract(GRD_NEWID, '(?<=E)\\d+') %>% as.numeric) %>% 
    en2longlat(map) %>%
    write.csv(file=data_file, row.names = F)
  rm(data, map, map_df)
}
d <- data.table::fread(data_file, stringsAsFactors = F)