
library(sf)
library(dplyr)

# Rejilla Grid_ETRS89_LAEA_ES_1K ------------------------------------------------------------------------

data_file <- "spain_population_2011.csv"
if(file.exists(data_file)){
  d <- data.table::fread(data_file, stringsAsFactors = F)
}else{
  
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


n <- nrow(d)
d %>% 
  dplyr::slice(1:15000) %>%
  ggplot2::ggplot()+
  # ggplot2::geom_point(ggplot2::aes(x=E,y=N, color=log(t1_1)), size=0.01)+
  ggplot2::geom_point(ggplot2::aes(x=long,y=lat, color=log(t1_1)), size=0.01)+
  ggplot2::coord_equal()


n <- nrow(map@data)
sapply(1:5000, function(i){
  c(map@polygons[[i]]@Polygons[[1]]@labpt, map@data$t1_1[i], map@polygons[[i]]@Polygons[[1]]@area, map@data$SHAPE_Area[i])
}) %>%
  t() %>%
  data.frame() %>% head
dplyr::filter(X4 > 500000) %>% 
  ggplot2::ggplot()+
  # ggplot2::geom_point(ggplot2::aes(x=X1,y=X2), size=0.2)+
  ggplot2::geom_tile(ggplot2::aes(x=X1,y=X2,fill=X3, width=1000, height=1000), alpha=1)+
  ggplot2::coord_equal()

sp::plot(map)

# Rejilla RJ_CPV_20111101_TT_02_R_INE -----------------------------------------------------------------------

data <- read.csv('C2011_RejillaEU_Indicadores.csv', stringsAsFactors = F)
map <- rgdal::readOGR('RJ_CPV_20111101_TT_02_R_INE/RJ_CPV_20111101_TT_02_R_INE.shp', stringsAsFactors = F)
map@data <- merge(map@data, data, by="GRD_NEWID", all.y = T)

n <- nrow(map@data)
sapply(1:n, function(i){
  c(map@polygons[[i]]@Polygons[[1]]@labpt, map@data$t1_1[i])
}) %>% 
  t() %>% 
  data.frame() %>% 
  ggplot2::ggplot()+
  ggplot2::geom_point(ggplot2::aes(x=X1,y=X2, color=X3==0), size=0.05)+
  ggplot2::coord_equal()


# Rejilla GEOSTAT-grid-POP-1K-2011-V2-0-1 ---------------------------------------------------------------------------

d <- read.csv('GEOSTAT-grid-POP-1K-2011-V2-0-1/GEOSTAT_grid_POP_1K_2011_V2_0_1.csv', stringsAsFactors = F)
d %>% 
  dplyr::filter(CNTR_CODE == "ES") %>% 
  dplyr::slice(1:2000) %>% 
  dplyr::mutate(N = stringr::str_extract(GRD_ID, '(?<=N)\\d+') %>% as.numeric,
                E = stringr::str_extract(GRD_ID, '(?<=E)\\d+') %>% as.numeric) %>%
  ggplot2::ggplot()+
  ggplot2::geom_point(ggplot2::aes(x=E,y=N), size=0.01)+
  ggplot2::coord_equal()


