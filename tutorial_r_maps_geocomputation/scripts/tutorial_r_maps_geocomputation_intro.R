#### Making Maps With R ####

# Open Instructions In your web browser:
# https://r.geocompx.org/adv-map


#### LOAD PACKAGES ####

# install.packages(
#   "spDataLarge", 
#   repos = "https://nowosad.github.io/drat/", 
#   type = "source")
# 
# install.packages(
#   "tmap", 
#   repos = c(
#     "https://r-tmap.r-universe.dev",
#     "https://cloud.r-project.org"))

packages_used <- 
  c(
    "tidyverse",
    "janitor",
    "sf",
    "terra",
    "spData",
    "spDataLarge",
    "tmap",
    "leaflet"
  )

packages_to_install <-
  packages_used[!packages_used %in% installed.packages()[, 1]]

if (length(packages_to_install) > 0) {
  install.packages(
    packages_to_install,
    Ncpus = parallel::detectCores() - 1
  )
}

lapply(
  packages_used,
  require,
  character.only = TRUE
)





####  9.2.1 tmap basics ####

# https://r.geocompx.org/adv-map#tmap-basics

# read in example data

nz_elev = 
  rast(
    system.file(
      "raster/nz_elev.tif", 
      package = "spDataLarge"
    )
  )

# Add fill layer to nz shape
tm_shape(nz) +
  tm_fill() 
# Add border layer to nz shape
tm_shape(nz) +
  tm_borders() 
# Add fill and border layers to nz shape
tm_shape(nz) +
  tm_fill() +
  tm_borders() 

 




#### Dude, where's my maps? ####

# https://r.geocompx.org/read-write

list.files(system.file(
  "shapes/", 
  package = "spData"
))

list.files(system.file(
  "raster/", 
  package = "spDataLarge"
))

f = system.file(
  "shapes/world.gpkg", 
  package = "spData"
)

world = read_sf(f)

tm_shape(world) +
  tm_borders() +
  tm_fill() +
  tm_layout(title = "World Map")

tanzania = 
  read_sf(
    f, 
    query = 'SELECT * FROM world WHERE name_long = "Tanzania"'
  )

tm_shape(tanzania) +
  tm_borders() +
  tm_fill() +
  tm_layout(title = "Tanzania")

tanzania_buf = st_buffer(tanzania, 50000)
tanzania_buf_geom = st_geometry(tanzania_buf)
tanzania_buf_wkt = st_as_text(tanzania_buf_geom)

tanzania_neigh = read_sf(f, wkt_filter = tanzania_buf_wkt)

tm_shape(tanzania_neigh) +
  tm_borders() +
  tm_fill(col = "black") +
  tm_layout(title = "Tanzania & Neighbors")