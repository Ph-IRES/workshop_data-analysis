#### INITIALIZATION ####
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(tidyverse)
library(janitor)

# install.packages("vegan")
library(vegan)

#### USER DEFINED VARIABLES ####

inFilePath1 = "./data_si_station_gis_78-79.rds"

#### READ IN DATA ####

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
  mutate(identification = str_replace(identification,
                                      " ",
                                      "_"),
         taxon = str_c(order,
                       family,
                       identification,
                       sep = "_")) %>%
  # sum all max_n counts for a taxon and op_code
  group_by(taxon,
           odu_station_code) %>%
  summarize(sum_specimen_count = sum(specimen_count)) %>%
  ungroup() %>%
  # convert tibble from long to wide format
  pivot_wider(names_from = taxon,
              values_from = sum_specimen_count,
              values_fill = 0) %>%
  # sort by op_code
  arrange(odu_station_code) %>%
  # remove the op_code column for vegan
  dplyr::select(-odu_station_code)

# convert metadata into tibble for vegan ingestion
# each row is a site
# each column is a dimension of site, such as depth, lat, long, region, etc

data_vegan.env <-
  data_si_70s %>%
  # make unique taxa
  mutate(identification = str_replace(identification,
                                      " ",
                                      "_"),
         taxon = str_c(order,
                       family,
                       identification,
                       sep = "_")) %>%
  # sum all max_n counts for a taxon and op_code
  group_by(taxon,
           odu_station_code,
           date_collected,
           island_name,
           province_state,
           province,
           province_code,
           municipality,
           municipality_code,
           precise_locality,
           centroid_latitude,
           centroid_longitude,
           adjusted_latitude,
           adjusted_longitude,
           depth_m,
           depth_cat,
           dist_shore,
           dist_shore_m_min,
           ecol_habitat,
           bottom,
           collection_method_type,
           method_capture_gal,
           chemical_euthanasia) %>%
  summarize(sum_specimen_count = sum(specimen_count)) %>%
  ungroup() %>%
  # convert tibble from long to wide format
  pivot_wider(names_from = taxon,
              values_from = sum_specimen_count,
              values_fill = 0) %>%
  # sort by odu_station_code
  arrange(odu_station_code) %>%
  # select columns for vegan env file
  dplyr::select(odu_station_code:chemical_euthanasia) %>%
  mutate(collection_method_type = factor(collection_method_type),
         depth_cat = factor(depth_cat),
         ecol_habitat = factor(ecol_habitat),
         bottom = factor(bottom),
         island_name = factor(island_name),
         chemical_euthanasia = factor(chemical_euthanasia))

# and now we "attach" the metadata to the data

attach(data_vegan.env)


#### Rarefaction Species Richness w vegan::rarefy (Observations are Individuals) ####

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

# slopes of rarefaction curves for each row
rareslope(BCI,
          sample = raremax)


#### vegan::rarefy SI78-79 plus ggplot####

# redo with data_vegan from SI78-79 data
S <- specnumber(data_vegan) # observed number of species
raremax <- min(rowSums(data_vegan))
Srare <- rarefy(data_vegan, 
                raremax,
                se = TRUE)


# make same plot as above, but with ggplot
# note that the y axis values are relatively low, this is because some sites had very few fish collected
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

# rarefaction curves for each row
rarecurve(data_vegan, 
          step = 2, 
          sample = raremax)

# slopes of rarefaction curves for each row
rareslope(data_vegan,
          sample = raremax)


#### vegan::rarefy SI78-79 plus ggplot, remove sites w low samp size####

# we could not compare the sites well because a few sites have low sample sizes
# so we will remove some sites so the remaining sites can be better compared
# realize that another strategy is necessary to compare all of the sites because
# low sample size = low diversity

samp_size <- rowSums(data_vegan)
samp_size

data_vegan_subset_sampsize <-
  data_vegan %>%
  bind_cols(samp_size) %>%
  # the name of the new column will vary based upon the number of columns in your data set
  # customize next line as necessary
  rename(samp_size = `...1041`) %>%
  filter(samp_size > 100) %>%
  dplyr::select(-samp_size)

data_vegan_subset_sampsize.env <-
  data_vegan.env %>%
  bind_cols(samp_size) %>%
  # the name of the new column will vary based upon the number of columns in your data set
  # customize next line as necessary
  rename(samp_size = `...23`) %>%
  filter(samp_size > 100) %>%
  dplyr::select(-samp_size)

S <- specnumber(data_vegan_subset_sampsize) # observed number of species
raremax <- min(rowSums(data_vegan_subset_sampsize))
Srare <- rarefy(data_vegan_subset_sampsize, 
                raremax,
                se = TRUE)


# with the small samples removed, we obtain a larger number of rarified species because 
# a larger number of fish are sampled for the rarefaction
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

rarecurve(data_vegan_subset_sampsize, 
          step = 2, 
          sample = raremax)

rareslope(data_vegan_subset_sampsize,
          sample = raremax)

#note that the same result for rarecurve can be achieved by changing sample =
# here we use the unfilterd data to achieve the same result
raremax
rarecurve(data_vegan, 
          step = 2, 
          sample = 130)

#### vegan::rarefy Combine Samples to Compare Larger Groups ####

# summarize data
data_vegan_dpth <-
  data_si_70s %>%
  mutate(identification = str_replace(identification,
                                      " ",
                                      "_"),
         taxon = str_c(order,
                       family,
                       identification,
                       sep = "_")) %>%
  group_by(taxon,
           depth_cat) %>%
  summarize(sum_specimen_count = sum(specimen_count)) %>%
  ungroup() %>%
  pivot_wider(names_from = taxon,
              values_from = sum_specimen_count,
              values_fill = 0) %>%
  arrange(depth_cat) %>%
  dplyr::select(-depth_cat)

# summarize env data
data_vegan_dpth.env <-
  data_si_70s %>%
  mutate(identification = str_replace(identification,
                                      " ",
                                      "_"),
         taxon = str_c(order,
                       family,
                       identification,
                       sep = "_")) %>%
  group_by(taxon,
           depth_cat) %>%
  summarize(sum_specimen_count = sum(specimen_count)) %>%
  ungroup() %>%
  pivot_wider(names_from = taxon,
              values_from = sum_specimen_count,
              values_fill = 0) %>%
  arrange(depth_cat) %>%
  dplyr::select(depth_cat) %>%
  mutate(depth_cat = factor(depth_cat))

# rarefaction
S <- specnumber(data_vegan_dpth) # observed number of species
raremax <- min(rowSums(data_vegan_dpth))
Srare <- rarefy(data_vegan_dpth, 
                raremax,
                se = TRUE)


# plot
t(Srare) %>%
  bind_cols(S) %>%
  rename(Srare = S,
         S = ...3,
         Srare_se = se) %>%
  bind_cols(data_vegan_dpth.env) %>%
  ggplot(aes(x=S,
             y=Srare,
             color = depth_cat)) +
  geom_point() +
  geom_errorbar(aes(ymin = Srare - Srare_se,
                    ymax = Srare + Srare_se),
                color = "grey") +
  # geom_smooth(se = FALSE,
  #             color = "blue3") +
  geom_abline(slope = 1,
              intercept = 0) +
  theme_classic() +
  labs(title = "Salvador Data Set",
       x = "Observed No. of Species",
       y = "Rarefied No. of Species")

# rarefaction curves for each row
rarecurve(data_vegan_dpth, 
          step = 2, 
          sample = raremax)

# slopes of rarefaction curves for each row
rareslope(data_vegan_dpth,
          sample = raremax)

#### Rarefaction Species Richness w vegan::specaccum (Observations are Samples) ####

# see specaccum in https://cloud.r-project.org/web/packages/vegan/vegan.pdf

data(BCI)

# The "exact" method finds the expected SAC using sample-based rarefaction method that has been independently developed numerous times (Chiarucci et al. 2008) and it is often known as Mao Tau estimate (Colwell et al. 2012). 
sp1 <- specaccum(BCI,
                 method = "exact")
plot(sp1, ci.type="poly", 
     col="blue", 
     lwd=2, 
     ci.lty=0, 
     ci.col="lightblue")

# The classic method is "random" which finds the mean SAC and its standard deviation from random permutations of the data, or subsampling without replacement (Gotelli & Colwell 2001). 
sp2 <- specaccum(BCI, 
                 method = "random")
summary(sp2)
boxplot(sp2, col="yellow", 
        add=TRUE, 
        pch="+")

# Fit Lomolino model to the *exact* accumulation
mod1 <- fitspecaccum(sp1, 
                     "lomolino")
coef(mod1)
fitted(mod1)
plot(sp1)

# Add Lomolino model using argument 'add'
plot(mod1, add = TRUE, col=2, lwd=2)

# Fit Arrhenius models to all *random* accumulations
mods <- fitspecaccum(sp2, 
                     "arrh")
plot(mods, col="hotpink")
# overlay boxplots of data in sp2 to compare to the Arrhenius model fits
boxplot(sp2, 
        col = "yellow", 
        border = "blue", 
        lty=1, 
        cex=0.3, 
        add= TRUE)
# Use nls() methods to the list of models
sapply(mods$models, AIC)

#### vegan::estaccumR Extrapolated Species Richness Curve in a Species Pool Based on Abundance ####

# see `specpool` in https://cloud.r-project.org/web/packages/vegan/vegan.pdf

# abundance based richness rarefaction curve
  # creates 1 curve per data frame, so if you want multiple curves, have to make them separately then combine into 1 tibble to plot
  # increase permutations to 999 if you use this for your project
p<-estaccumR(data_vegan, permutations = 50)
p.plot<-plot(p, display = c("chao","ace"))
p.plot
# to make plot w ggplot, see https://stackoverflow.com/questions/52652195/convert-rarefaction-plots-from-vegan-to-ggplot2-in-r

#### vegan::poolaccum Extrapolated Species Richness Curve in a Species Pool Based on Presence Absence ####

# incidence based (presence / absence) richness rarefaction curve
  # creates 1 curve per data frame, so if you want multiple curves, have to make them separately then combine into 1 tibble to plot
  # increase permutations to 999 if you use this for your project
p<-poolaccum(data_vegan, permutations = 50)
p.plot<-plot(p, display = c("jack1","jack2", "chao", "boot"))
p.plot
# to make plot w ggplot, see https://stackoverflow.com/questions/52652195/convert-rarefaction-plots-from-vegan-to-ggplot2-in-r


#### vegan::specpool - Extrapolated Species Richness in a Species Pool Based on Incidence (Abundance) ####

pool <- 
  estimateR(x = data_vegan) %>%
  t() %>%
  as_tibble()

pool %>%
  clean_names() %>%
  bind_cols(data_vegan.env %>%
              dplyr::select(depth_cat,
                            odu_station_code)) %>%
  mutate(depth_cat = factor(depth_cat,
                            levels = c("<2m",
                                       "2-15m",
                                       ">15m"))) %>%
  pivot_longer(cols = s_chao1:se_ace) %>%
  mutate(se_value = case_when(str_detect(name,
                                         "se_") ~ "se",
                              TRUE ~ "value"),
         name = str_remove(name,
                           "se*_")) %>%
  pivot_wider(names_from = se_value) %>% 
  rename(sp_richness_est = value,
         estimator = name) %>%
  ggplot(aes(x= depth_cat,
             y= sp_richness_est)) +
  geom_boxplot() +
  geom_point(aes(y = s_obs),
             color = "red3") +
  theme_classic() +
  labs(title = "Extrapolated Species Richness - Abundance") +
  facet_grid(. ~ estimator)


#### vegan::specpool - Extrapolated Species Richness in a Species Pool Based on Incidence (Presence Absence) ####

pool <- with(data_vegan.env, specpool(x = data_vegan, 
                                      pool = depth_cat,
                                      smallsample = TRUE))
pool %>%
  clean_names() %>%
  mutate(depth_cat = rownames(.),
         depth_cat = factor(depth_cat,
                            levels = c("<2m",
                                       "2-15m",
                                       ">15m"))) %>%
  pivot_longer(cols = chao:boot_se) %>%
  mutate(se_value = case_when(str_detect(name,
                                   "_se") ~ "se",
                        TRUE ~ "value"),
         name = str_remove(name,
                           "_se")) %>%
  pivot_wider(names_from = se_value) %>%
  rename(sp_richness_est = value,
         estimator = name) %>%
  ggplot(aes(x= depth_cat,
             y= sp_richness_est)) +
  geom_col() +
  geom_point(aes(y = species),
             color = "red3") +
  geom_errorbar(aes(ymin = sp_richness_est - se,
                    ymax = sp_richness_est + se)) +
  theme_classic() +
  labs(title = "Extrapolated Species Richness - Presence/Absence") +
  facet_grid(. ~ estimator)

#### Species Richness & Proportion of of Extrapolated Species Observed, Based on Incidence (Presence Absence) ####

op <- par(mfrow=c(1,
                  2))

# observed number of species in each sample: `specnumber`
boxplot(specnumber(data_vegan) ~ depth_cat, 
        data = data_vegan.env,
        col = "blue", 
        border = "black")

# propotion of total extrapolated species observed
  # observed number of species in each sample: `specnumber` divided by
  # extrapolated number of species: `specpool2vect(specpool())`, relies on `pool` tibble created above
boxplot(specnumber(data_vegan)/specpool2vect(pool) ~ depth_cat,
        data = data_vegan.env, 
        col = "blue", 
        border = "black")




