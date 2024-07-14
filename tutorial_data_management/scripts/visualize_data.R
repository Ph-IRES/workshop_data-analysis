#### USER DEFINED VARIABLES ####
script_wrangle_data_path <- "wrangle_data.R"

#### INSTALL/LOAD PACKAGES ####
source(script_wrangle_data_path)

packages_used <- 
  c(
    "tidyverse", 
    "janitor",
    "lubridate",
    "rstudioapi"
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

#### VISUALIZE DATA ####

data_all %>%
  ggplot() +
  aes(
    x = length_mm,
    y = weight_g,
    color = species
  ) +
  geom_point() +
  geom_smooth(
    method = "nls",
    formula = y ~ a * x^b,
    se = FALSE,
    method.args =
      list(
        start = list(
          a = 1,
          b = 1
        )
      )
  ) +
  theme_classic()
