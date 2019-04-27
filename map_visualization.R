
source('data_preprocessing.R')

canary.lines <- function(g){
  list(
    # ggplot2::geom_segment(x=3500, y=1680, xend=4050, yend=1680, size=0.3, linetype="dotted", alpha=0.8, colour="#404F4D"),
    ggplot2::geom_segment(x=3500, y=1450, xend=3500, yend=1680, size=0.3, linetype="dotted", alpha=0.8, colour="#404F4D")
  )
}
contour_spain <- data.table::fread('contour_spain_processed.csv') %>% canary.translation
'population_2011_spain.csv.gz' %>% 
  data.table::fread(stringsAsFactors = F) %>%
  canary.translation %>% 
  dplyr::slice(1:20000) %>%
  dplyr::mutate(empty = t1_1 == 0) %>% 
  ggplot2::ggplot()+
  ggplot2::geom_tile(ggplot2::aes(x=E,y=N, fill=empty), width=1, height=1)+
  ggplot2::geom_path(data=contour_spain, ggplot2::aes(x=E,y=N,group=group), color="#404F4D", size=0.3) +
  canary.lines() +
  ggplot2::scale_fill_manual(guide=F,values=c('white','#35D68D'))+
  ggplot2::coord_equal() +
  ggplot2::theme_void()

contour_eu <- data.table::fread('contour_eu_processed.csv')
contour_eu %>% 
  ggplot2::ggplot()+
  ggplot2::geom_path(ggplot2::aes(x=E,y=N,group=1e4*country+group))

'population_2011_eu.csv' %>% 
  data.table::fread(stringsAsFactors = F) %>% 
  # dplyr::slice(sample(1:nrow(.),100000)) %>% 
  dplyr::slice(1:30) %>%
  dplyr::mutate(empty = TOT_P == 0) %>% 
  ggplot2::ggplot()+
  ggplot2::geom_tile(ggplot2::aes(x=E,y=N, fill=empty), width=1, height=1, na.rm=T)+
  ggplot2::geom_path(data=contour_eu, ggplot2::aes(x=E,y=N,group=1e4*country+group), color="#404F4D", size=0.3, na.rm=T) +
  ggplot2::scale_fill_manual(guide=F,values=c('white','#35D68D'))+
  ggplot2::xlim(c(2500,6500)) + ggplot2::ylim(c(1400,5500))#+
  # ggplot2::coord_map(projection = )
  # ggplot2::coord_equal() +
  # ggplot2::theme_void()


'population_2011_eu.csv.gz' %>% 
  data.table::fread(stringsAsFactors = F) %>% 
  dplyr::mutate(w = 1/110.574, w=round(w*1e4)/1e4,
                h=1/(111.320*cos(lat*pi/180)), h=round(h*1e4)/1e4) %>% 
  # dplyr::slice(sample(1:nrow(.),100000)) %>% 
  dplyr::slice(1:2000) %>% 
  dplyr::mutate(empty = TOT_P == 0) %>% 
  ggplot2::ggplot()+
  ggplot2::geom_polygon(data=contour_eu, ggplot2::aes(x=long,y=lat,group=1e4*country+group),
                        fill="#35D68D", na.rm=T) +
  ggplot2::geom_tile(ggplot2::aes(x=long,y=lat, fill=empty, width=w, height=h), na.rm=T)+
  ggplot2::geom_path(data=contour_eu, ggplot2::aes(x=long,y=lat,group=1e4*country+group), color="#404F4D", na.rm=T) +
  ggplot2::scale_fill_manual(guide=F,values=c('white','#35D68D'))+
  ggplot2::coord_equal(xlim=c(-18,-13),ylim=c(27,29))
  # ggplot2::xlim(c(-40,40))+
  # ggplot2::ylim(c(32,70))+
  # ggplot2::coord_map(projection = 'ortho', orientation = c(40, 0, 0))
# ggplot2::theme_void()
