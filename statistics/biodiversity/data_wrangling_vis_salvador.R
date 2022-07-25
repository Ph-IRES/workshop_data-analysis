#### INITIALIZATION ####
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(tidyverse)
library(janitor)
library(readxl)
# install.packages("maps")
# install.packages("viridis")
require(maps)
require(viridis)
theme_set(
  theme_void()
)
# install.packages("vegan")
library(vegan)

#### USER DEFINED VARIABLES ####

inFilePath1 = "./WorkingData_CLEANED_TUB,CAG.xlsx"
inFilePath2 = "./PHIRES_MetaData.xlsx"

#### READ IN DATA & CURATE ####

data <-
  read_excel(inFilePath1,
             na="NA") %>%
  clean_names() %>%
  # there is a different depth for CAG_024 in data vs metadata
  # solution: go with metadata depth, confirm with Gene & Rene
  mutate(depth_m = case_when(op_code == "CAG_024" ~ 8,
                             TRUE ~ depth_m),
         family = str_to_title(family),
         genus = str_to_title(genus),
         species = str_to_lower(species),
         trophic_groups = str_to_title(trophic_groups))

metadata <-
  read_excel(inFilePath2,
             na="NA") %>%
  clean_names() %>%
  dplyr::rename(bait_weight_grams = weight_grams) %>%
  mutate(site = str_to_title(site),
         survey_area = str_to_title(survey_area),
         habitat = str_to_title(habitat),
         bait_type = str_to_title(bait_type))

#### COMBINE DATA ####

data_all <-
  data %>%
    left_join(metadata,
               by = c("op_code" = "opcode",
                      "depth_m" = "depth_m")) %>%
  # rearrange order of columns, metadata then data
  select(op_code,
         site:long_e,
         depth_m,
         time_in:bait_weight_grams,
         everything())

#### DIVERSITY ####

# convert species count data into tibble for vegan ingestion
  # each row is a site
  # each column is a taxon
  # data are counts

data_vegan <-
  data %>%
  # make unique taxa
  mutate(taxon = str_c(family,
                       genus,
                       species,
                       sep = "_")) %>%
  # sum all max_n counts for a taxon and op_code
  group_by(taxon,
           op_code) %>%
  summarize(sum_max_n = sum(max_n)) %>%
  ungroup() %>%
  # convert tibble from long to wide format
  pivot_wider(names_from = taxon,
              values_from = sum_max_n,
              values_fill = 0) %>%
  # sort by op_code
  arrange(op_code) %>%
  # remove the op_code column for vegan
  dplyr::select(-op_code)

# convert metadata into tibble for vegan ingestion
# each row is a site
# each column is a dimension of site, such as depth, lat, long, region, etc

data_vegan.env <-
  data_all %>%
  # make unique taxa
  mutate(taxon = str_c(family,
                       genus,
                       species,
                       sep = "_")) %>%
  # sum all max_n counts for a taxon and op_code
  group_by(taxon,
           op_code,
           site,
           survey_area,
           habitat,
           lat_n,
           long_e,
           depth_m,
           bait_type) %>%
  summarize(sum_max_n = sum(max_n)) %>%
  ungroup() %>%
  # convert tibble from long to wide format
  pivot_wider(names_from = taxon,
              values_from = sum_max_n,
              values_fill = 0) %>%
  # sort by op_code
  arrange(op_code) %>%
  # remove the op_code column for vegan
  dplyr::select(op_code:bait_type) %>%
  mutate(site_code = str_remove(op_code,
                                "_.*$"),
         site_code = factor(site_code),
         habitat = factor(habitat))

# and now we "attach" the metadata to the data

attach(data_vegan.env)

# Detrended correspondence analysis
ord <- decorana(data_vegan)
ord
summary(ord)
#boring plot
plot(ord)
#fancier plot
plot(ord, type = "n")
points(ord, display = "sites", cex = 0.8, pch=21, col="black", bg="yellow")
text(ord, display = "spec", cex=0.7, col="red")
#fanciest plot
plot(ord, disp="sites", type="n")
ordihull(ord, habitat, col=1:2, lwd=3)
ordiellipse(ord, habitat, col=1:2, kind = "ehull", lwd=3)
ordiellipse(ord, habitat, col=1:2, draw="polygon")
points(ord, disp="sites", pch=21, col=1:2, bg="yellow", cex=1.3)
ordispider(ord, habitat, col=1:2, label = TRUE)

# Non-metric multidimensional scaling
ord <- metaMDS(data_vegan)
ord
summary(ord)
plot(ord)
plot(ord, type = "n")
points(ord, display = "sites", cex = 0.8, pch=21, col="red", bg="yellow")
text(ord, display = "spec", cex=0.7, col="blue")
