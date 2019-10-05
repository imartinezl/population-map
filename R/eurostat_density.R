
# Geographical Data -------------------------------------------------------

library(dplyr)

# download geospatial data for NUTS-3 regions
euro_nuts3_sf <-
  eurostat::get_eurostat_geospatial(output_class = 'sf', resolution = '60', nuts_level = 3) %>%
  sf::st_transform(crs = 3035)

# download geospatial data for European and Asian countries
eura <-
  rnaturalearth::ne_countries(continent = c('europe', 'asia', 'africa'), returnclass = 'sf') %>%
  sf::st_transform(crs = 3035)


# Density -----------------------------------------------------------------

# download data from eurostat
euro_density <-
  eurostat::get_eurostat('demo_r_d3dens', stringsAsFactors = FALSE) %>%
  dplyr::filter(
    stringr::str_length(geo) == 5, # NUTS-3
    lubridate::year(time) == 2017) # DATE FILTER


euro_nuts3_sf %>%
  left_join(y = euro_density, by = c('id' = 'geo')) %>% 
  ggplot2::ggplot() +
  ggplot2::geom_sf(data = eura, color = 'white', fill = 'grey95') +
  ggplot2::geom_sf(ggplot2::aes(fill = values), color = NA, lwd = 0.1) +
  ggplot2::coord_sf(xlim = c(2.5e6, 7e6), ylim = c(1.35e6, 5.55e6), datum = NA) +
  # ggplot2::scale_fill_gradientn( breaks=c(3,200,11100,21000), colors=c("#ffffff","#d3ba9c","#dd0e18","#ddc10e"))+
  ggplot2::scale_fill_gradientn( breaks=c(10,50,100,1000,5000,10000,20000), 
                                 colors=c("#d2fbd4","#a5dbc2","#7bbcb0","#559c9e","#3a7c89","#235d72","#123f5a"))+
  ggplot2::theme_void() +
  ggplot2::theme(legend.position = c(0.83, 0.7)) +
  ggplot2::labs(caption = 'Data: Eurostat')


# Fertility ---------------------------------------------------------------

subreplacement <- 2.1
euro_fertility <- 
  eurostat::get_eurostat('demo_r_find3', stringsAsFactors = FALSE) %>%
  dplyr::filter(
    indic_de == "TOTFERRT",
    stringr::str_length(geo) == 5, 
    lubridate::year(time) == 2017) %>% 
  dplyr::mutate(rel_fertility = 100*(values - subreplacement)/subreplacement) 

m <- min(euro_fertility$rel_fertility)
M <- max(euro_fertility$rel_fertility)
p_zero <- (0-m)/(M-m)

euro_nuts3_sf %>%
  left_join(y = euro_fertility, by = c('id' = 'geo')) %>% 
  ggplot2::ggplot() +
  ggplot2::geom_sf(data = eura, color = 'white', fill = 'grey95') +
  ggplot2::geom_sf(ggplot2::aes(fill = rel_fertility), color = NA, lwd = 0.1) +
  ggplot2::coord_sf(xlim = c(2.5e6, 7e6), ylim = c(1.35e6, 5.55e6), datum = NA) +
  ggplot2::scale_fill_gradientn(
    colours = c("#c10023","#FFFFFF","#003d70"), #RColorBrewer::brewer.pal(n = 7, name = "RdYlBu"),
    values = c(0,p_zero,1),
    name = "Percentage over \nsub-replacement limit",
    labels = c('-50%','0','50%','100%'),
    breaks = c(-50,0,50,100)
  ) +
  ggplot2::ggtitle("Fertility Rate Relative to Sub-replacement Limit")+
  ggplot2::labs(caption = 'Data Source: Eurostat')+
  ggplot2::theme_void() +
  ggplot2::theme(legend.position = c(0.83, 0.7),
                 text = ggplot2::element_text(family = "Roboto Condensed"),
                 plot.title = ggplot2::element_text(hjust=0.05, size=14, face="bold"),
                 ) 

ggplot2::ggsave('EUFertility.png', width=10, height=10)
