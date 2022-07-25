#### INITIALIZATION ####
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(tidyverse)
library(janitor)

# install.packages("vegan")
library(vegan)

#### USER DEFINED VARIABLES ####

inFilePath1 = "./data_si_station_gis_78-79.rds"

#### READ IN DATA & CURATE ####

data_si_70s <- 
  read_rds(inFilePath1)

#### PREP DATA FOR VEGAN ####

# convert species count data into tibble for vegan ingestion
  # each row is a site
  # each column is a taxon
  # data are counts

data_vegan <-
  data_si_70s %>%
  # make unique taxa
  mutate(taxon = str_c(order,
                       family,
                       identification,
                       sep = "_")) %>%
  # sum all max_n counts for a taxon and op_code
  group_by(taxon,
           station_code) %>%
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
         habitat = factor(habitat),
         bait_type = factor(bait_type),
         site = factor(site),
         survey_area = factor(survey_area))

# and now we "attach" the metadata to the data

attach(data_vegan.env)


#### Rarefaction Species Richness w vegan::rarefy ####

# vegan manual - https://cloud.r-project.org/web/packages/vegan/vegan.pdf

# this is the example from the manual with their data
data(BCI)
S <- specnumber(BCI) # observed number of species
raremax <- min(rowSums(BCI))
Srare <- rarefy(BCI, raremax)

plot(S, Srare, xlab = "Observed No. of Species", ylab = "Rarefied No. of Species")
abline(0, 1)

# draws a rarefaction curve for each row of the input data
rarecurve(BCI, step = 20, sample = raremax, col = "blue", cex = 0.6)

# redo with data_vegan from salvador data
S <- specnumber(data_vegan) # observed number of species
raremax <- min(rowSums(data_vegan))
Srare <- rarefy(data_vegan, 
                raremax,
                se = TRUE)

# make same plot as above, but with ggplot
t(Srare) %>%
  bind_cols(S) %>%
  rename(Srare = S,
         S = ...3,
         Srare_se = se) %>%
  ggplot(aes(x=S,
             y=Srare)) +
  geom_point() +
  geom_errorbar(aes(ymin = Srare - Srare_se,
                    ymax = Srare + Srare_se),
                color = "grey") +
  geom_smooth(se = FALSE,
              color = "blue3") +
  geom_abline(slope = 1,
              intercept = 0) +
  theme_classic() +
  labs(title = "Salvador Data Set",
       x = "Observed No. of Species",
       y = "Rarefied No. of Species")

test <-
  rarecurve(data_vegan, 
            step = 2, 
            sample = raremax) %>%
  as.matrix()
  as_tibble(.rows = length(S))

data_vegan.s <-
  data_vegan.env
bind_cols(S,
          Srare)

