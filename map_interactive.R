library(dplyr)

data <- data.table::fread('GEOSTAT-grid-POP-1K-2011-V2-0-1/GEOSTAT_grid_POP_1K_2011_V2_0_1.csv', stringsAsFactors = F)

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



