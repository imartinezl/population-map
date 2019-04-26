library(sf)
library(dplyr)


# Spain Border ----------------------------------------------------------------------

canary.translation <- function(d){
  d %>% dplyr::mutate(E = ifelse(E<2200,E+1800,E),
                      N = ifelse(N<1250,N+400,N))
}
border <- jsonlite::read_json('spain_border.geojson')
border_coords <- border$features[[1]]$geometry$coordinates
contour <- lapply(1:length(border_coords), function(i){
  (sapply(border_coords[[i]][[1]], unlist)/1000) %>% 
    t() %>% data.frame() %>% 
    dplyr::rename("E"="X1", "N"="X2") %>% 
    dplyr::mutate(group=i)
}) %>% 
  dplyr::bind_rows() %>% 
  canary.translation

# Rejilla Grid_ETRS89_LAEA_ES_1K ------------------------------------------------------------------------
# https://ec.europa.eu/eurostat/web/gisco/geodata/reference-data/population-distribution-demography/geostat#geostat11
# http://www.ine.es/censos2011_datos/cen11_datos_resultados_rejillas.htm

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
d <- data.table::fread(data_file, stringsAsFactors = F) %>% canary.translation



