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
# install.packages("remotes")
# library(remotes)
# remotes::install_github("gavinsimpson/ggvegan")
library(ggvegan)

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

#### PREP DATA FOR VEGAN ####

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
         habitat = factor(habitat),
         bait_type = factor(bait_type),
         site = factor(site),
         survey_area = factor(survey_area))

# and now we "attach" the metadata to the data

attach(data_vegan.env)

#### ORDINATION: Detrended correspondence analysis ####

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


#### ORDINATION: Non-metric multidimensional scaling (NMDS) ####

ord <- metaMDS(data_vegan)
ord
summary(ord)
#fanciest plot
plot(ord, disp="sites", type="n")
ordihull(ord, habitat, col=1:2, lwd=3)
ordiellipse(ord, habitat, col=1:2, kind = "ehull", lwd=3)
ordiellipse(ord, habitat, col=1:2, draw="polygon")
points(ord, disp="sites", pch=21, col=1:2, bg="yellow", cex=1.3)
ordispider(ord, habitat, col=1:2, label = TRUE)


#### ORDINATION: NMDS Plotting with ggplot

# https://gavinsimpson.github.io/ggvegan/

ggord <- 
  fortify(ord) %>% 
  tibble() %>% 
  clean_names() %>%
  filter(score == "sites") %>% 
  bind_cols(tibble(data_vegan.env)) %>% 
  clean_names()

ggord %>%
  ggplot(aes(x = nmds1,
             y= nmds2,
             color = site_code,
             shape = habitat)) +
  geom_point(size = 5) +
  theme_classic() 


#### ORDINATION: NMDS Fitting Environmental Variables - Vectors & Surfaces ####

# Let us test for an effect of site and depth on the NMDS

ord.fit <- 
  envfit(ord ~ depth_m + site + bait_type, 
         data=data_vegan.env, 
         perm=999,
         na.rm = TRUE)
ord.fit
plot(ord, dis="site")
ordiellipse(ord, site, col=1:4, kind = "ehull", lwd=3)
plot(ord.fit)

# Plotting fitted surface of continuous variables (depth_m) on ordination plot
ordisurf(ord, depth_m, add=TRUE)

#### ORDINATION: NMDS Generating Species Loading Values - Vectors ####

# use envfit to generate species loading vectors
ord_species_vectors <- 
  envfit(ord$points, 
         data_vegan, 
         perm=1000)

ord_species_vectors

# convert envfit output to ggplot tibble
ggord_species_vectors <- 
  as.data.frame(scores(ord_species_vectors, 
                       display = "vectors")) %>%
  clean_names() %>%
  dplyr::rename(nmds1 = mds1,
                nmds2 = mds2) %>%
  mutate(species = rownames(.))

# convert metaMDS output to ggplot tibble
ggord <- 
  fortify(ord) %>% 
  tibble() %>% 
  clean_names() %>%
  filter(score == "sites") %>% 
  bind_cols(data_vegan.env) %>%
  clean_names()

#### nMDS Plot  ####

habitatcolors <- c("#6FAFC6", 
                   "#F08080")
habitatlabels <- c("Mesophotic Reef",
                   "Shallow Reef")

ggord_plot <- 
  ggord %>%
  ggplot(aes(x = nmds1,
             y = nmds2,
             color = habitat,
             shape = study_locations)) +
  # scale_x_continuous(limits = c(-3,3)) +
  geom_point(size = 5) +
  scale_shape_manual(values = c(16,2)) +
  # stat_ellipse(aes(group = studylocation_habitat,
  #                  lty=factor(study_locations))) +
  scale_linetype_manual(values=c(1,2,1,2)) +
  
  coord_fixed() + ## need aspect ratio of 1!
  geom_segment(data = ggord_species_vectors,
               aes(x = 0, 
                   xend = nmds1*3, 
                   y = 0, 
                   yend = nmds2*3),
               arrow = arrow(length = unit(.25,
                                           "cm")),
               color = "grey",
               inherit.aes = FALSE) +
  geom_text(data = ggord_species_vectors,
            aes(x = nmds1*3,
                y = nmds2*3,
                label = species),
            size = 3,
            inherit.aes = FALSE) +
  
  theme_classic() +
  xlab("NMDS 1") +
  ylab("NMDS 2") +
  labs(color = "Habitat", 
       shape = "Study Locations", 
       linetype = "Study Locations",
       title = "NMDS Plots of Fish Assemblage") + 
  scale_color_manual(values = habitatcolors,
                     # labels = habitatlabels
                     )
ggord_plot


#### CONSTRAINED ORDINATION ####

# constrained or “canonical” correspondence analysis (function cca)
ord <- cca(data_vegan ~ depth_m + site, 
           data=data_vegan.env)
ord
plot(ord, dis="site")
points(ord, disp="site", pch=21, col=1:2, bg="yellow", cex=1.3)
ordiellipse(ord, site, col=1:4, kind = "ehull", lwd=3)

# Significance tests of constraints
anova(ord)
anova(ord, by="term", permutations=999)
anova(ord, by="mar", permutations=999)
anova(ord, by="axis", permutations=999)


#### Conditioned or partial ordination ####

ord <- cca(data_vegan ~ depth_m + site + Condition(bait_type), 
           data=data_vegan.env)
anova(ord, by="term", permutations=999)


