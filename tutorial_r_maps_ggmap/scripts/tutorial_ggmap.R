#### SET WORKING DIR ####
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

#### LOAD PACKAGES ####

packages_used <- 
  c(
    "tidyverse",
    "janitor",
    "ggmap"
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

#### Get an API Key ####

# consult help
?ggmap::register_google()


#### Google Maps ####

(map <- get_googlemap("waco texas", zoom = 12))
