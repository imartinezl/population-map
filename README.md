# Population Density Map

This repo contains the code for the analysis of the population density in Europe and in Spain. It covers the entire data ETL pipeline: data extraction from european and spanish public institutions, data transformation and analysis, and a visualization stage. 

Please, notice that the used datasets are quite large in size, and thus the project has been concieved from an educational point of view, always looking for the maximum efficiency in the entire pipeline. 

---
#### Self hosted map on [Github Pages](https://imartinezl.github.io/population-map/)

![](docs/video_zoom.gif)

---
#### Nodoby Lives Here: <a href="R/images/europe_600ppi_16x8_crop.png?raw=true" >High resolution image</a>

<div align="center">
	<img width="650px" src="R/images/europe_600ppi_16x8_crop.png">
	<img width="150px" src="R/images/legend.png">
</div>


## What I wanted to do

1. **Visualize the least populated regions in Europe**

I was very much inspired by [this article](https://www.citymetric.com/fabric/nine-things-we-learned-population-density-map-europe-3775) where John Elledge introduces the visualization of [Dan Cookson](https://twitter.com/danc00ks0n), a map with the EU Population at 2011 onto a 1km grid. This great visualization is available [here](https://dancooksonresearch.carto.com/u/dancookson/viz/49ca276c-adf9-454a-8f64-0ccf0e46eed0/embed_map).

2. **Learn how to approach the visualization of large spatial datasets**

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

```
population-map
│   README.md
│   index.html 
│
└───data
│   └───grid
│   |   └───GEOSTAT-grid-POP-1K-2011-V2-0-1
│   |   └───Grid_ETRS89_LAEA_ES_1K
|   |	└───RJ_CPV_20111101_TT_02_R_INE
|   |
│   └───contour
|	|   contour_eu.geojson
|	|   contour_spain.geojson
|
└───R
│   │   data_preprocessing.R
│   │   map_exploration.R
│   │   map_interactive.R
│   │   map_visualization.R
```

## Project Stages

### 1. Data Preprocessing

Prior to the visualization stage, there is a data preprocessing stage in which some tasks are carried out: 

- **Coordinate system conversion function**: subsequently used function to transform coordinates in system from *ETRS89 / LAEA Europe (EPSG:3035)* to the universal *WGS 84 (EPSG:4326)* system. 

- **Contour dataset**: The polygon coordinates are extracted from the GeoJSON files and arranged in R's data.frame format to be exported to CSV. In the process, the coordinate system is converted as described above. Both for Spain and EU. 

- **Grid + Population dataset**: Instead of reading the huge shapefile containing all the geographical information, I imported a CSV file that just summarized the population of each cell from the grid. The cell ID string contained the ETRS89 coordinates (North-East), that were extracted and then converted to WGS 84 (latitude-longitude).

 
### 2. Data Export: GeoJSON vs Vector Tiles

Once the data was correctly processed, it had to be exported to the common formats to store spatial information. 

#### GeoJSON

Built from scratch using R and the library jsonlite, the data was shaped into a collection of features (simple polygons), like this:

```
{
   "type":"FeatureCollection",
   "features":[
      {
         "type":"Feature",
         "geometry":{  
            "type":"Polygon",
            "coordinates":[[
		[10.2181,47.3189],
		[10.218,47.3099],
		[10.2048,47.3099],
		[10.2049,47.3189],
		[10.2181,47.3189]
		]]
         },
         "properties":{  
            "p":8,
            "e":false
         }
      },
      {
         ...
      }, ...
   ]
}
```

#### MBTiles

The previous GeoJSON file was converted to the [MBTiles](https://github.com/mapbox/mbtiles-spec) format. MBTiles is a specification for storing arbitrary tiled map data in SQLite databases for immediate usage and for efficient transfer.
For the conversion process I used the tool [Tippecanoe](https://github.com/mapbox/tippecanoe), by Mapbox.

It is a highly configurable tool, with lots of different options for large datasets. After some exploration and learning of the implications of each option, this is my final recipe:
```
tippecanoe --coalesce-densest-as-needed --minimum-zoom=0 --maximum-zoom=g --output-to-directory "tiles" data.geojson
```


### 3. Map Visualization

#### Offline (static) visualization

The library ggplot2 for R is used to visualize the population density both in Europe and in Spain. Apart from the population quantity, I also included a map that highlighted the 1km sq cells with no population, which can lead to some interesting analysis.

<p align="center">
<img width="800px" src="R/images/spain_300ppi_32x16.png">
</p>

#### Online (interactive) visualization

Regarding interactive visualizations, two platforms were studied: [CARTO](https://carto.com/) and [Mapbox](https://www.mapbox.com/).

<p align="center">
   <img src="docs/carto.png">
   <img src="docs/mapbox.jpg">
</p>


On one side, the Student plan from CARTO just offered 350 MB of data storage, whereas the free tier plan from Mapbox offered much larger storage for tilesets (50 GB). Moreover, CARTO Import API does not support MBTiles, so the only remaining alternative was to upload the entire GeoJSON file to be imported and processed into a SQL-like table with the polygon coordinates. Check the CARTO supported formats on the [CARTO Documentation](https://carto.com/developers/import-api/guides/importing-geospatial-data/#supported-geospatial-data-formats).

Therefore, these two points (storage limit and supported formats), were the main reasons not to select CARTO as the visualization platform. Thus, the decision was inclined towards Mapbox. The following screenshots have been taken from the maps generated on Mapbox. To interact with the map by yourself, just click on the images:

[<img width="280px" src="/docs/Screenshot_EU Population Nobody.png">](https://api.mapbox.com/styles/v1/inigoml/cjv12gf3r387n1fjwpodk0fx9.html?fresh=true&title=true&access_token=pk.eyJ1IjoiaW5pZ29tbCIsImEiOiJjamcycndxcDAwcmlsMnFwaHk4eDdpanhnIn0.lOge1jvtZgNLhr6yUdz8qA#4.8/46.373476/8.118357/0)
[<img width="280px" src="/docs/Screenshot_EU Population density.png">](https://api.mapbox.com/styles/v1/inigoml/cjv1hdnqb03fy1fmlvg347n3c.html?fresh=true&title=true&access_token=pk.eyJ1IjoiaW5pZ29tbCIsImEiOiJjamcycndxcDAwcmlsMnFwaHk4eDdpanhnIn0.lOge1jvtZgNLhr6yUdz8qA#4.1/48.654013/18.622102/0
)
[<img width="280px" src="/docs/Screenshot_EU Population density - green.png">](https://api.mapbox.com/styles/v1/inigoml/cjv6d2pyk013v1fmqkzhw55rj.html?fresh=true&title=true&access_token=pk.eyJ1IjoiaW5pZ29tbCIsImEiOiJjamcycndxcDAwcmlsMnFwaHk4eDdpanhnIn0.lOge1jvtZgNLhr6yUdz8qA#4.1/48.654013/18.622102/0
)

In this sense, apart from using the online platform Mapbox Studio, I also explored the way of self-hosting the map and the tiles. This track will be further explained on the next section.

### 4. Self-Hosted Map Tiles

#### Deployment on Heroku

The reference I followed on this stage was this [article](https://geovation.github.io/build-your-own-static-vector-tile-pipeline) by [James Gardner](https://www.linkedin.com/in/james-gardner-47a66b2). In the article Mapbox vector tiles are introduced, with a very clear comparison (pros and cons) with GeoJSON or TopoJSON formats. 

There is also a section that covers the hosting of the tiles, where the [NodeJS](https://nodejs.org/) package [live-server](http://tapiov.net/live-server/) is used. The tiles are in gzipped format **".pbf"** and are hosted in a folder structure like this: **/{z}/{x}/{y}.pbf**. In this sense, it is necessary to unzip each requested tile, and *live-server* has an integrated a middleware, which does any processing the server performs between receiving a request and responding to it. In this case, it was necessary to set headers on outgoing requests that ended with the format **.pbf**.

```
var liveServer = require("live-server");
var params = {
    port: process.env.PORT || 8080, 
    open: false,
    file: "index.html", 
    middleware: [function(req, res, next) { 
		if (req.url.endsWith('.pbf')) {
			console.log(req.url);
			next();
			res.setHeader('Content-Encoding', 'gzip');
		} else {
			next();
		}
   }] 
};
liveServer.start(params);
```

You can check the deployed map on [Heroku](https://population-map.herokuapp.com/):

<p align="center">
	<img width="500px" src="docs/map_theme1.png">
</p>

|3|200|11000|30000|
|:---:|:---:|:---:|:---:|
|![#ffffff](https://placehold.it/15/ffffff/000000?text=+) #ffffff| ![#d3ba9c](https://placehold.it/15/d3ba9c/000000?text=+) #d3ba9c|![#dd0e18](https://placehold.it/15/dd0e18/000000?text=+) #dd0e18| ![#ddc10e](https://placehold.it/15/ddc10e/000000?text=+) #ddc10e|

#### Deployment on Github Pages

I also the checked this GitHub [repo](https://github.com/klokantech/vector-tiles-sample) by [Klokan Technologies GmbH](https://github.com/klokantech), where they display vector tiles with a local copy of MapBoxGL JS. This option does not require any running server, and it just requires a local copy of the tiles.

<p align="center">
	<img width="500px" src="docs/map_theme2.png">
</p>
The color scale was inspired from CARTO [colors](https://carto.com/carto-colors/):

|10|50|100|1000|5000|10000|>10000|
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
|![#d2fbd4](https://placehold.it/15/d2fbd4/000000?text=+) #d2fbd4| ![#a5dbc2](https://placehold.it/15/a5dbc2/000000?text=+) #a5dbc2|![#7bbcb0](https://placehold.it/15/7bbcb0/000000?text=+) #7bbcb0| ![#559c9e](https://placehold.it/15/559c9e/000000?text=+) #559c9e|![#3a7c89](https://placehold.it/15/3a7c89/000000?text=+) #3a7c89|![#235d72](https://placehold.it/15/235d72/000000?text=+) #235d72|![#123f5a](https://placehold.it/15/123f5a/000000?text=+) #123f5a|

## Challenges I run into


## Accomplishments that I'm proud of

## What I learned

First of all, I learned how to navigate public institutions open data services to find desired information. Sometimes this information is not prepared to be used right away, and in that sense, the preprocessing stage was crucial.

Overall, I learned how to handle large spatial datasets and the difference between vector tiles and raster tiles.
I spent a lot of time exploring lots of online and offline tools to convert data into vector and raster tiles. I found out that several services and libraries are benn recently deprecated or unmaintained. 


## What's next

I would like to improve the latency of the interactive visualizations. The dataset is large if we consider all the points, but since it is not necessary to show all the points at once, using a more robust tile server could help in this sense. Just reaching the level of smoothness and latency on [Dan Cookson](https://twitter.com/danc00ks0n) map -- available [here](https://dancooksonresearch.carto.com/u/dancookson/viz/49ca276c-adf9-454a-8f64-0ccf0e46eed0/embed_map) -- would be amazing.

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
