library(dplyr)

data <- data.table::fread('../data/grid/GEOSTAT-grid-POP-1K-2011-V2-0-1/GEOSTAT_grid_POP_1K_2011_V2_0_1.csv', 
                          stringsAsFactors = F) %>% 
  dplyr::filter(!is.na(CNTR_CODE)) %>% 
  dplyr::arrange(CNTR_CODE)

en2longlat <- function(d, x, y, n, proj4string='+proj=laea +lat_0=52 +lon_0=10 +x_0=4321000 +y_0=3210000 +ellps=GRS80 +units=m +no_defs'){
  long_lat <- cbind(d[[x]]*1e3, d[[y]]*1e3) %>% 
    sp::SpatialPoints(proj4string=sp::CRS( proj4string)) %>% 
    sp::spTransform(sp::CRS("+proj=longlat")) %>% 
    as.data.frame() %>% 
    apply(2,function(x){round(x*1e4)/1e4})
  colnames(long_lat) <- paste0(c("long","lat"),n)
  return(cbind(d,long_lat))
}

b <- data %>% 
  dplyr::filter(!is.na(CNTR_CODE)) %>% 
  # dplyr::slice(1:1000000) %>% 
  dplyr::mutate(TOT_P = ifelse(is.na(TOT_P),0,TOT_P),
                empty = TOT_P==0)  %>% 
  dplyr::mutate(N = stringr::str_extract(GRD_ID, '(?<=N)\\d+') %>% as.numeric,
                E = stringr::str_extract(GRD_ID, '(?<=E)\\d+') %>% as.numeric) %>%
  dplyr::mutate(N1 = N+0.5, N2 = N-0.5, E1 = E+0.5, E2 = E-0.5) %>% 
  en2longlat("E1","N1","A") %>% 
  en2longlat("E1","N2","B") %>% 
  en2longlat("E2","N2","C") %>% 
  en2longlat("E2","N1","D") %>% 
  en2longlat("E1","N1","E") #%>% 
tidyr::unite(col = 'pA', c(longA,latA), sep=',', remove=F) %>% 
  tidyr::unite(col = 'pB', c(longB,latB), sep=',', remove=T) %>% 
  tidyr::unite(col = 'pC', c(longC,latC), sep=',', remove=T) %>% 
  tidyr::unite(col = 'pD', c(longD,latD), sep=',', remove=T) %>% 
  tidyr::unite(col = 'pE', c(longA,latA), sep=',', remove=T) %>% 
  tidyr::unite(col = 'co', c(pA,pB,pC,pD,pE), sep='],[', remove=T) %>%
  dplyr::mutate(co = paste0('[[',co,']]')) #%>%
dplyr::select(TOT_P,co,empty) %>% 
  write.csv(file='test.csv',row.names=F)

a <- lapply(1:nrow(b), function(i){ 
  list(type="Feature", 
       geometry=list(type="Polygon",
                     coordinates=list(list(c(b$longA[i],b$latA[i]),
                                           c(b$longB[i],b$latB[i]),
                                           c(b$longC[i],b$latC[i]),
                                           c(b$longD[i],b$latD[i]),
                                           c(b$longE[i],b$latE[i])))
       ),
       properties=list(p=b$TOT_P[i],
                       e=b$empty[i]))
})
jsonlite::toJSON(list(type="FeatureCollection", features=a), auto_unbox = T) %>% 
  write("test3.geojson")



# SPLIT GEOJSON ---------------------------------------------------------------------

jump <- 175000
g <- 0
for(i in seq(1,nrow(data), by=jump)){
  a <- i
  b <- min(i+jump-1,nrow(data))
  g <- g+1
  
  file_name <- paste0('test_', g, '.geojson')
  b <- data %>% 
    dplyr::slice(a:b) %>%
    dplyr::mutate(TOT_P = ifelse(is.na(TOT_P),0,TOT_P),
                  empty = TOT_P==0)  %>% 
    dplyr::mutate(N = stringr::str_extract(GRD_ID, '(?<=N)\\d+') %>% as.numeric,
    E = stringr::str_extract(GRD_ID, '(?<=E)\\d+') %>% as.numeric) %>%
    dplyr::mutate(N1 = N+0.5, N2 = N-0.5, E1 = E+0.5, E2 = E-0.5) %>% 
    en2longlat("E1","N1","A") %>% 
    en2longlat("E1","N2","B") %>% 
    en2longlat("E2","N2","C") %>% 
    en2longlat("E2","N1","D") %>% 
    en2longlat("E1","N1","E") 
  
  jsonlite::toJSON(list(type="FeatureCollection", 
                        features=lapply(1:nrow(b), function(i){ 
                          list(type="Feature", 
                               geometry=list(type="Polygon",
                                             coordinates=list(list(c(b$longA[i],b$latA[i]),
                                                                   c(b$longB[i],b$latB[i]),
                                                                   c(b$longC[i],b$latC[i]),
                                                                   c(b$longD[i],b$latD[i]),
                                                                   c(b$longE[i],b$latE[i])))
                               ),
                               properties=list(p=b$TOT_P[i],
                                               e=b$empty[i]))
                        })), auto_unbox = T) %>% 
    write(file_name)
}


# SMART SPLIT GEOJSON ---------------------------------------------------------------

data <- data.table::fread('../data/grid/GEOSTAT-grid-POP-1K-2011-V2-0-1/GEOSTAT_grid_POP_1K_2011_V2_0_1.csv', 
                          stringsAsFactors = F) %>% 
  dplyr::filter(!is.na(CNTR_CODE)) %>% 
  dplyr::arrange(CNTR_CODE) %>% 
  dplyr::mutate(N = stringr::str_extract(GRD_ID, '(?<=N)\\d+') %>% as.numeric,
                E = stringr::str_extract(GRD_ID, '(?<=E)\\d+') %>% as.numeric)

# data %>% group_by(CNTR_CODE) %>% dplyr::summarise(n()) %>% View
# data %>% 
#   dplyr::filter(CNTR_CODE == "DE") %>% 
#   dplyr::arrange(CNTR_CODE,E) %>% 
#   dplyr::slice(sample(1:nrow(.),10000)) %>%
#   # dplyr::slice(1:100000) %>%
#   ggplot2::ggplot()+
#   ggplot2::geom_point(ggplot2::aes(x=E,y=N), size=0.1)+
#   ggplot2::coord_equal()

groups <- list("CNTR_CODE %in% c('ES','PT') | (CNTR_CODE=='FR' & N<2400)",
               "CNTR_CODE=='FR' & N>=2400 & N<2800",
               "CNTR_CODE %in% c('BE','NL') | (CNTR_CODE=='FR' & N>=2800)",
               "CNTR_CODE %in% c('IE','UK')",
               "CNTR_CODE %in% c('IT')",
               "CNTR_CODE %in% c('AT','LI','CH','CZ','SL','SI','SK','HR') | (CNTR_CODE=='PL' & N<3050)",
               "CNTR_CODE=='PL' & N>=3050",
               "CNTR_CODE %in% c('AL','EL','BG','MT','XK*','RO','HU')",
               "CNTR_CODE %in% c('FI','LV','LT')",
               "CNTR_CODE %in% c('SE','NO','EE')",
               "CNTR_CODE %in% c('DK') | (CNTR_CODE=='DE' & N>=3300)",
               "CNTR_CODE=='DE' & N<3300")

for(i in 1:length(groups)){
  file_name <- paste0('test_', i, '.geojson')
  print(file_name)
  b <- data %>% 
    dplyr::filter_(groups[[i]]) %>% 
    dplyr::mutate(TOT_P = ifelse(is.na(TOT_P),0,TOT_P),
                  empty = TOT_P==0)  %>% 
    # dplyr::mutate(N = stringr::str_extract(GRD_ID, '(?<=N)\\d+') %>% as.numeric,
    # E = stringr::str_extract(GRD_ID, '(?<=E)\\d+') %>% as.numeric) %>%
    dplyr::mutate(N1 = N+0.5, N2 = N-0.5, E1 = E+0.5, E2 = E-0.5) %>% 
    en2longlat("E1","N1","A") %>% 
    en2longlat("E1","N2","B") %>% 
    en2longlat("E2","N2","C") %>% 
    en2longlat("E2","N1","D") %>% 
    en2longlat("E1","N1","E") 
  
  jsonlite::toJSON(list(type="FeatureCollection", 
                        features=lapply(1:nrow(b), function(i){ 
                          list(type="Feature", 
                               geometry=list(type="Polygon",
                                             coordinates=list(list(c(b$longA[i],b$latA[i]),
                                                                   c(b$longB[i],b$latB[i]),
                                                                   c(b$longC[i],b$latC[i]),
                                                                   c(b$longD[i],b$latD[i]),
                                                                   c(b$longE[i],b$latE[i])))
                               ),
                               properties=list(p=b$TOT_P[i],
                                               e=b$empty[i]))
                        })), auto_unbox = T) %>% 
    write(file_name)
  
  
}



