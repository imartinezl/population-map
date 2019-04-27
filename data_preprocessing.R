library(sf)
library(dplyr)


# LAEA to Lat Long ------------------------------------------------------------------
# Origin: WGS 84 (EPSG:4326) 
# Destiny: ETRS89 / LAEA Europe (EPSG:3035)

# proj4string <- sf::st_crs(map)$proj4string
en2longlat <- function(d, proj4string='+proj=laea +lat_0=52 +lon_0=10 +x_0=4321000 +y_0=3210000 +ellps=GRS80 +units=m +no_defs'){
  long_lat <- cbind(d$E*1e3, d$N*1e3) %>% 
    sp::SpatialPoints(proj4string=sp::CRS( proj4string)) %>% 
    sp::spTransform(sp::CRS("+proj=longlat")) %>% 
    as.data.frame()
  colnames(long_lat) <- c("long","lat")
  return(cbind(d,long_lat))
}

# Spain Border Contour ----------------------------------------------------------------------

canary.translation <- function(d){
  d %>% dplyr::mutate(E = ifelse(E<2200,E+2000,E), #1800
                      N = ifelse(N<1250,N+500,N))  #400
}
# Download geojson: https://geojson-maps.ash.ms/
# Convert from latlong to LAEA: https://mygeodata.cloud/converter/geojson-to-latlong
get.contour <- function(geojson_file){
  border <- jsonlite::read_json(geojson_file)
  border_coords <- border$features[[1]]$geometry$coordinates
  contour <- lapply(1:length(border_coords), function(i){
    (sapply(border_coords[[i]][[1]], unlist)/1000) %>% 
      t() %>% data.frame() %>% 
      dplyr::rename("E"="X1", "N"="X2") %>% 
      dplyr::mutate(group=i)
  }) %>% 
    dplyr::bind_rows()
}
contour_file <- 'contour_spain_processed.csv'
if(!file.exists(contour_file)){
  'contour_spain.geojson' %>% 
    get.contour %>% 
    en2longlat() %>%
    write.csv(contour_file)
}


# EU Border Contour -----------------------------------------------------------------

get.contour.bis <- function(geojson_file){
  border <- jsonlite::read_json(geojson_file)
  contour <- data.frame()
  p <- 0
  for (feature in border$features) {
    p <- p + 1
    g <- 0
    for(coordinate in feature$geometry$coordinates){
      g <- g+1
      tmp <- coordinate %>% unlist() %>% 
        matrix(ncol=2, byrow=T) %>% 
        data.frame() %>% 
        dplyr::rename("E"="X1","N"="X2") %>% 
        dplyr::mutate(E = as.integer(E/1000),
                      N = as.integer(N/1000),
                      group = g, country = p)
      contour <- rbind(contour,tmp)
    }
  }
  contour
}
contour_file <- 'contour_eu_processed.csv'
if(!file.exists(contour_file)){
  'contour_eu.geojson' %>% 
    get.contour.bis %>% 
    en2longlat() %>%
    write.csv(contour_file)
}



# Grid_ETRS89_LAEA_ES_1K ------------------------------------------------------------------------
# http://www.ine.es/censos2011_datos/cen11_datos_resultados_rejillas.htm

data_file <- "population_2011_spain.csv"
if(!file.exists(data_file)){
  data <- data.table::fread('C2011_RejillaEU_Indicadores.csv', stringsAsFactors = F)
  # map <- rgdal::readOGR('Grid_ETRS89_LAEA_ES_1K/', stringsAsFactors = F)
  map <- sf::st_read('Grid_ETRS89_LAEA_ES_1K/', stringsAsFactors = F)
  map_df <- map %>% sf::st_set_geometry(NULL)
  proj4string <- sf::st_crs(map)$proj4string
  
  merge(map_df %>% dplyr::select(GRD_NEWID), 
        data %>% dplyr::select(GRD_NEWID, t1_1),
        by="GRD_NEWID", all.x = T) %>% 
    dplyr::mutate(t1_1 = ifelse(is.na(t1_1),0,t1_1))  %>% 
    dplyr::mutate(N = stringr::str_extract(GRD_NEWID, '(?<=N)\\d+') %>% as.numeric,
                  E = stringr::str_extract(GRD_NEWID, '(?<=E)\\d+') %>% as.numeric) %>% 
    en2longlat(proj4string) %>%
    write.csv(file=data_file, row.names = F)
  rm(data, map, map_df)
}

# GEOSTAT 2011 grid dataset ------------------------------------------------------------------------
# https://ec.europa.eu/eurostat/web/gisco/geodata/reference-data/population-distribution-demography/geostat#geostat11

data_file <- "population_2011_eu.csv"
if(!file.exists(data_file)){
  data <- data.table::fread('GEOSTAT-grid-POP-1K-2011-V2-0-1/GEOSTAT_grid_POP_1K_2011_V2_0_1.csv', stringsAsFactors = F)
  map <- sf::st_read('GEOSTAT-grid-POP-1K-2011-V2-0-1/GEOSTATReferenceGrid/', stringsAsFactors = F)
  map_df <- map %>% sf::st_set_geometry(NULL)
  proj4string <- sf::st_crs(map)$proj4string
  
  merge(map_df %>% dplyr::select(GRD_ID), 
        data %>% dplyr::select(GRD_ID, TOT_P, CNTR_CODE),
        by="GRD_ID", all.x = T) %>%
    dplyr::mutate(TOT_P = ifelse(is.na(TOT_P),0,TOT_P))  %>% 
    dplyr::mutate(N = stringr::str_extract(GRD_ID, '(?<=N)\\d+') %>% as.numeric,
                  E = stringr::str_extract(GRD_ID, '(?<=E)\\d+') %>% as.numeric) %>% 
    en2longlat(proj4string) %>%
    write.csv(file=data_file, row.names = F)
  rm(data, map, map_df)
}
