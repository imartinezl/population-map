# Population Density Map

This repo contains the code for visualization of the population density in Europe and in Spain. It covers the entire data pipeline, starting from the importation, going through the transformation and analysis, and finishing on the visualization. Please, notice that the selected datasets are large in size, and thus the project is mainly concieved from the efficiency point of view. 


## What I wanted to do

The main objectives of this project can be summarized in the following two ideas:

- **Visualize the least populated regions in Europe**

This purpose is very simple to define. Here I was very much inspired by [this article](https://www.citymetric.com/fabric/nine-things-we-learned-population-density-map-europe-3775) where Jonn Elledge introduces the visualization of by [Dan Cookson](https://twitter.com/danc00ks0n). 
- **Learn how to approach the viz of large spatial datasets**


https://dancooksonresearch.carto.com/u/dancookson/viz/49ca276c-adf9-454a-8f64-0ccf0e46eed0/embed_map


## What it does



Interactive

- Generate GEOJSON

- MBTiles generation with tippecanoe
tippecanoe -o tile*.mbtiles -zg --coalesce-densest-as-needed --extend-zooms-if-still-dropping test_*.geojson

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
- [sp]() - 
- [jsonlite]() - 
- [ggplot2]() - 
