# Population Density Map

This repo contains the code for the analysis of the population density in Europe and in Spain. It covers the entire data ETL pipeline: data extraction from european and spanish public institutions, data transformation and analysis, and a visualization stage. Please, notice that the used datasets are quite large in size, and thus the project has been concieved from an educational point of view, always looking for the maximum efficiency in the entire pipeline. 

## What I wanted to do

- **Visualize the least populated regions in Europe**

I was very much inspired by [this article](https://www.citymetric.com/fabric/nine-things-we-learned-population-density-map-europe-3775) where John Elledge introduces the visualization of [Dan Cookson](https://twitter.com/danc00ks0n), a map with the EU Population at 2011 onto a 1km grid. This great visualization is available [here](https://dancooksonresearch.carto.com/u/dancookson/viz/49ca276c-adf9-454a-8f64-0ccf0e46eed0/embed_map).

- **Learn how to approach the visualization of large spatial datasets**

Prior to this project, I had some experience working with small spatial datasets. Therefore, a large dataset presented a nice challenge! The european 1km per 1km square grid dataset comprises over 2.000.000 features that need to be processed and rendered onto the map.

## Data Sources

- **Europe Grid**: GEOSTAT-grid-POP-1K-2011-V2-0-1

   Detailed grid (1km resolution) available at [eurostat](https://ec.europa.eu/eurostat/web/gisco/geodata/reference-data/population-distribution-demography/geostat). Download [link](https://ec.europa.eu/eurostat/cache/GISCO/geodatafiles/GEOSTAT-grid-POP-1K-2011-V2-0-1.zip) (.zip file)

- **Spain Grid**: ETRS89_LAEA_ES_1K

   Digitalized cartography (1km resolution grid) of the Spanish territory, available at [INE](http://www.ine.es/censos2011_datos/cen11_datos_resultados_rejillas.htm). Download [link](http://www.ine.es/censos2011_datos/RJ_CPV_20111101_TT_02_R_INE.zip) (.zip file)

- **European countries contour**
   
   Vector maps in GeoJSON format are downloaded from [this online service](https://geojson-maps.ash.ms/)

  An online geodata [converter](https://mygeodata.cloud/converter/geojson-to-latlong) is used to transform the contour coordinate system from **WGS 84 (EPSG:4326)** to **ETRS89 / LAEA Europe (EPSG:3035)**. This is a necessary conversion due to the fact that the grid coordinates are represented with the latter system.

## Project Structure

## What it does



Interactive

- Generate GEOJSON

https://geovation.github.io/build-your-own-static-vector-tile-pipeline

- MBTiles generation with tippecanoe
tippecanoe -o tile*.mbtiles -zg --coalesce-densest-as-needed --extend-zooms-if-still-dropping test_*.geojson

tippecanoe --no-tile-compression --no-feature-limit --no-tile-size-limit --drop-densest-as-needed --minimum-zoom=0 --maximum-zoom=11 --output-to-directory "tiles" ./data/complete.geojson

live-server --port=8000 --middleware="${PWD}/www/gzip.js" --host=localhost --browser=chromium-browser www

tippecanoe --cluster-densest-as-needed --minimum-zoom=0 --maximum-zoom=9 --output-to-directory "tiles_tmp1" ./data/complete.geojson

tippecanoe --drop-densest-as-needed --minimum-zoom=0 --maximum-zoom=9 --output-to-directory "tiles_tmp2" ./data/complete.geojson

tippecanoe --no-tile-size-limit --minimum-zoom=0 --maximum-zoom=9 --output-to-directory "tiles_tmp2" ./data/complete.geojson



- Upload to Mapbox


- Countries Covered

- Color Scale
10-50-100-1000-5000-10000->10000
#d2fbd4,#a5dbc2,#7bbcb0,#559c9e,#3a7c89,#235d72,#123f5a
https://carto.com/carto-colors/

## Challenges I run into

## Accomplishments that I'm proud of

## What I learned

## What's next


## How I built it

- [R](https://www.r-project.org/) - Programming Language / 3.5.2
- [RStudio](https://www.rstudio.com/) - IDE for R / 1.1.463 
- [dplyr](https://dplyr.tidyverse.org/) - A grammar of data manipulation / 0.7.8 
- [data.table](https://cran.r-project.org/web/packages/data.table/vignettes/datatable-intro.html) - Data manipulation operations / 1.12.1
- [sf](http://r-spatial.github.io/sf/) - Simple features access for R / 0.7-3
- [stringr](https://stringr.tidyverse.org/index.html) - Library for string manipulations / 1.4.0
- [sp](https://github.com/edzer/sp/) - Classes and methods for spatial data / 1.3.1
- [jsonlite](https://github.com/jeroen/jsonlite) - A Robust, High Performance JSON Parser and Generator for R / 1.6
- [ggplot2](https://ggplot2.tidyverse.org/) - Grammar of Graphics for R / 3.1.0
