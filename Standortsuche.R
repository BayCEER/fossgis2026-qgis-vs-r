library(sf)
library(tidyverse)
library(osmdata)
library(mapview)
library(rstudioapi)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


#### 1. Positiv Fläche ####
# Manueller Download Geologische Karte Bayern + Verwaltungsgrenzen
# https://www.lfu.bayern.de/geologie/geo_karten_schriften/dgk25_uab/index.htm
# Verwaltungsgrenzen

border = st_read("Data/ALKIS-Vereinfacht/VerwaltungsEinheit.shp") %>%
  filter(art == "Gemeinde" & name == "Bayreuth")
mapview(border)

# Geologie
geology = st_read("Data/dGK25/dGK25/Vektordaten/GeolEinheit.shp") %>%
  st_intersection(border)
mapview(geology, zcol='LEGEINHEIT')

# Tonhaltige Flächen
positive_area = geology %>% select(LEGEINHEIT, L_TEXT_BAY, K_TEXT) %>%
  filter(grepl("^Ton", L_TEXT_BAY))
mapview(positive_area, zcol='LEGEINHEIT')


#### 2. Negativ Flächen ####
## OpenStreetMap data
bbox = border %>% st_buffer(1000) %>% st_bbox() %>% st_transform(4326)
st_crs(bbox) ## EPSG 4326
river = bbox %>% opq() %>%
  add_osm_feature(key = "waterway") %>%
  osmdata_sf()
river = river$osm_lines %>% st_crop(bbox) %>% st_transform(25832)



# Einlesen von zuvor heruntergeladenen Daten
road = st_read("Data/OSM/road.shp") # osm_lines, key='highway', value = c("motorway", "road", "primary", "primary_link","secondary", "secondary_link", "tertiary", "tertiary_link", "living_street", "residential","unclassified")
river = st_read("Data/OSM/river.shp") # osm_lines, key='waterway' 
lake = st_read("Data/OSM/lake.shp") # osm_polygons, key='water'
building = st_read("Data/OSM/building.shp") # osm_polygons+osm_multipolygons, key='building'

## Buffergrößen
buffer_building = 150
buffer_water = 50
buffer_road = 25

n_road = road %>% st_buffer(buffer_road) %>% st_union()
n_river = river %>% st_buffer(buffer_water) %>% st_union()
n_lake = lake %>% st_buffer(buffer_water) %>% st_union()
n_building = building %>% st_buffer(buffer_building) %>% st_union()

mapview(n_road)

negative_area = n_building %>% st_union(n_road) %>% st_union(n_river) %>% st_union(n_lake)

mapview(negative_area)

#### 3. Analysis I ####
pot_area = positive_area %>% st_union() %>% st_difference(negative_area)

pot_area = st_cast(pot_area, "POLYGON") %>% st_sf() %>%
  filter(as.numeric(st_area(geometry)) > 40000)

mapview(pot_area)


#### 4. Analysis II ####
geology_final = positive_area %>% st_intersection(pot_area)
mapview(geology_final, zcol='LEGEINHEIT')


# Statistik
geology_final = geology_final %>%
  group_by(LEGEINHEIT) %>%
  summarise(
    area = sum(st_area(geometry)),
    L_TEXT_BAY = first(L_TEXT_BAY),
    K_TEXT = first(K_TEXT)
  ) %>%
  mutate(Geologie = sprintf("%s (%.0f ha)", LEGEINHEIT, area / 10000))

mapview(geology_final, zcol='Geologie')

# Plot (ggplot) 
limits = border %>% st_bbox()

geology_final %>% ggplot() +
  geom_sf(aes(fill = Geologie)) +
  geom_sf(data = river, color = 'darkblue') +
  geom_sf(data = lake,
          color = 'blue',
          fill = 'blue') +
  geom_sf(data = road, color = 'darkgrey') +
  geom_sf(data = building,
          color = 'red',
          fill = 'red') +
  geom_sf(
    data = border,
    fill = NA,
    color = 'black',
    linewidth = 1.5
  ) +
  coord_sf(datum = 25832) +
  labs(caption = "Map data from OpenStreetMap, Bayerisches Landesamt für Umwelt, www.lfu.bayern.de", title = "Dump Site Search") +
  xlim(limits[c(1, 3)]) + ylim(limits[c(2, 4)]) +
  ggspatial::annotation_scale() +
  theme(axis.text = element_blank(), axis.ticks = element_blank())


#### 5. Analysis III ####

## https://geodaten.bayern.de/opengeodata/OpenDataDetail.html?pn=dgm1
## über Metadaten XML
## Alternativ über DownThemAll-Extension
## https://www.geodaten.bayern.de/odd/m/3/pdf/metalink_browser.pdf
library(terra)

dtm = NULL
for (file in Sys.glob("Data/DGM1/*.tif")) {
  cat(file)
  cat("\n")
  r = rast(file)
  r = aggregate(r, fact = 25) # aggregate to 25x25m
  if (is.null(dtm))
    dtm = r
  else
    dtm = merge(dtm, r)
}
mapview(dtm)

# Berechnung der Steigung
slope = terrain(dtm, v='slope', unit='degree')
slope$percent = tan(slope$slope/180*pi) * 100

mapview(slope$percent)
hist(slope$percent, breaks=80)
slope$kat = ceiling(slope$percent / 2)
slope$kat[as.numeric(slope$kat) > 6] = 6

# Statistik 
slope_final = as.polygons(slope$kat) %>% 
  st_as_sf() %>%
  st_intersection(geology_final) %>%
  mutate(kat = factor(
    as.integer(kat),
    levels = 1:6,
    labels = c("0-2%", "2-4%", "4-6%", "6-8%", "8-10%", ">10%")
  )) %>%
  group_by(kat) %>%
  summarize(area = sum(st_area(geometry))) %>%
  mutate(Slope = sprintf("%s (%.0f ha)", kat, area / 10000))

slope_final$Slope = factor(slope_final$Slope, levels = slope_final$Slope) ## Order!

mapview(slope_final, zcol='Slope')


# Plot 
# Slope colors
colfunc <- colorRampPalette(c('cyan', 'deeppink'))
slope_fill_col = colfunc(6)
slope_border_col = slope_fill_col
slope_border_col[2] = 'darkgreen' ## Highlight slope class 2 == 2-4%
slope_fill_col[2] = 'yellow'

library(ggspatial)
map = ggplot() +
  annotation_map_tile(data=border, zoomin = -1, alpha = 0.5) +
  geom_sf(data=slope_final, aes(fill = Slope, color = Slope)) +
  scale_fill_manual(values = slope_fill_col) +
  scale_color_manual(values = slope_border_col) +
  geom_sf(
    data = border,
    fill = NA,
    color = 'black',
    linewidth = 0.5
  )+ 
  labs(caption = "Map data from OpenStreetMap, Bayerisches Landesamt für Umwelt, www.lfu.bayern.de\nLandesamt für Digitalisierung, Breitband und Vermessung, geodaten.bayern.de") +
  ggspatial::annotation_scale() +
  coord_sf(datum = 25832) +
  xlim(limits[c(1, 3)]) + ylim(limits[c(2, 4)]) +
  theme_bw()+
  theme(axis.text = element_blank(), axis.ticks = element_blank(),
        plot.caption =  element_text(size=5),
        plot.margin = margin(),
        legend.position = "inside",
        legend.justification.inside = c(0.99, 0.01))

map

ggsave('map1.png', plot=map, height=12.3, width = 17, units = 'cm',dpi = 300, scale=1.5)



#### Zusätzlicher Code ####

## Direkter Download 
ex = bt %>% st_buffer(1000) %>% st_bbox()
rast("https://download1.bayernwolke.de/a/dgm/dgm1/691_5516.tif")

x = floor(ex['xmin']/1000)
y = floor(ex['ymin']/1000)


dtm = NULL
while (x < ex['xmax'] / 1000) {
  while (y < ex['ymax'] / 1000) {
    rect = data.frame(x = c(x, x + 1) * 1000, y = c(y, y + 1) * 1000) %>%
      st_as_sf(coords = c('x', 'y'), crs = 25832) %>%
      st_bbox() %>%
      st_as_sfc()
    
    if (st_intersects(bt, rect, sparse = F)[1, 1]) {
      file = sprintf("https://download1.bayernwolke.de/a/dgm/dgm1/%d_%d.tif",
                     x,
                     y)
      cat(file)
      cat("\n")
      r = rast(file)
      r = aggregate(r, fact = 25) # aggregate to 25x25m
      if (is.null(dtm))
        dtm = r
      else
        dtm = merge(dtm, r)
    }
    y = y + 1
  }
  x = x + 1
  y = floor(ex['ymin'] / 1000)
}
mapview(dtm)



