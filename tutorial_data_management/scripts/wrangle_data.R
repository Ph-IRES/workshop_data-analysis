#### USER DEFINED VARIABLES ####
data_morphology_path <- "../data/morphology_data.csv"
data_locations_path <- "../data/sampling_locations.csv"

#### INSTALL/LOAD PACKAGES ####
packages_used <- 
  c(
    "tidyverse", 
    "janitor",
    "lubridate",
    "rstudioapi",
    "purrr"
  )

packages_to_install <- 
  packages_used[!packages_used %in% installed.packages()[,1]]

if (length(packages_to_install) > 0) {
  install.packages(
    packages_to_install, 
    Ncpus = 1
    # Ncpus = Sys.getenv("NUMBER_OF_PROCESSORS") - 1
  )
}

lapply(packages_used, 
       require, 
       character.only = TRUE)

#### SET WORKING DIRECTORY ####

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

#### READ IN DATA ####

data_all <-
  read_csv(data_morphology_path) %>%
  clean_names() %>%
  left_join(
    read_csv(data_locations_path) %>%
      clean_names()
  ) %>%
  rename(age_yrs = age)
