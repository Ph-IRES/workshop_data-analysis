#### INITIALIZATION ####
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(tidyverse)
library(janitor)
library(readxl)
library(lubridate)
download.packages(MASS)

#### USER DEFINED VARIABLES ####

inFilePath = "./halichores_scapularis_measurements_bartlett_2.xlsx"
read_excel(inFilePath)
library(readxl)
inFilePath2 = "./halichores_scapularis_measurements_bartlett_2.txt"
location_data <- read_tsv(inFilePath2) %>%
  clean_names()

# outFilePath = "./data_combined.tsv"

#### READ IN DATA & CURATE ####

data <-
  read_excel(inFilePath,
             na="NA") %>%
  clean_names() %>%
  # remove individuals with no length data
  filter(!is.na(total_length_mm) | !is.na(standard_length_mm)) %>%
  # sex & stage needs to be cleaned, and primary needs to be split out
  mutate(date = ymd(date),
         weight_g = as.numeric(weight_g),
         weight_of_gonads_g = as.numeric(weight_of_gonads_g),
         stage = str_to_title(stage),
         sex_clean = case_when(stage == "PM?" | stage == "Primary M" ~ "PM" ,
                              sex == "Juvenile" ~ "U",
                               sex == "?" ~ "U",
                               sex == "F?" ~ "U",
                               sex == "inbetween" ~ "MF",
                               sex == "Transitional" ~ "MF",
                               TRUE ~ sex),
         change = case_when(sex_clean == "M" ~ "1",
                            sex_clean == "MF" ~ "1",
                            sex_clean == "F" | sex_clean=="PM" ~"0",
                            TRUE ~ sex_clean),
         sex_clean = factor(sex_clean,
                            levels = c("U",
                                       "F",
                                       "MF",
                                       "M", 
                                       "PM")),
         stage_clean = case_when(stage == "Juvenile" ~ "0",
                                 stage == "J" ~ "0",
                                 stage == "Inactive" & sex_clean == "M" ~ "5.5",
                                 stage == "Primary M" ~ "6",
                                 stage == "Active" & sex_clean == "M" ~ "5",
                                 stage == "Pm?" ~ "6",
                                 stage == "?" ~ NA_character_,
                                 TRUE ~ stage),
         stage_clean = as.numeric(stage_clean),
         primary = case_when(str_detect(stage,
                                        "Primary") ~ TRUE,
                             TRUE ~ FALSE))
  
  
glm_fit<-glm(change~total_length_mm, family="binomial", data=data, na.action=na.exclude)
lmdata<- data.frame(total_length_mm=seq(min(data$total_length_mm), max(data$total_length_mm), len=200))
lmdata$probchange = predict(glm_fit, lmdata, type="response")
plot(change ~ total_length_mm, data=data, col="blue")
lines(probchange ~ total_length_mm, lmdata, lwd=2)
LD50 <- dose.p(glm_fit, p = 0.5)
abline(v = LD50[[1]])

geom_vline(xintercept = LD50[[1]])

OR <-exp(cbind(OR = coef(glm_fit), confint(glm_fit)))

#dont use
glm_fit2<-glm(change~location, family="binomial", data=data, na.action=na.exclude)

OR2 <-exp(cbind(OR = coef(glm_fit2), confint(glm_fit2)))
#dont use


V# metadata <-
#   read_excel(inFilePath2,
#              na="NA") %>%
#   clean_names() %>%
#   rename(bait_weight_grams = weight_grams)

#### COMBINE DATA ####

# data_all <-
#   data %>%
#     left_join(metadata,
#                by = c("op_code" = "opcode",
#                       "depth_m" = "depth_m")) %>%
#   # rearrange order of columns, metadata then data
#   select(op_code,
#          site:long_e,
#          depth_m,
#          time_in:bait_weight_grams,
#          everything())

#### WRITE LONG FORMAT FILE ####

# data_all %>%
#   write_tsv(outFilePath)

#### VISuALIZE METADATA ####

# metadata %>%
#   ggplot(aes(x=depth_m,
#              fill = habitat)) +
#   geom_histogram() +
#   theme_classic() 
# ggsave("histogram_depth-x-habitat.png")
# 
# metadata %>%
#   ggplot(aes(x=depth_m,
#              fill = habitat)) +
#   geom_histogram() +
#   theme_classic() +
#   facet_grid(bait_type ~ bait_weight_grams)
# ggsave("histogram_depth-x-habitat-x-bait.png")
# 
# metadata %>%
#   ggplot(aes(x=habitat,
#              y=survey_length_hrs,
#              fill = habitat)) +
#   # geom_violin() +
#   geom_boxplot() +
#   theme_classic() 
# 
# metadata %>%
#   ggplot(aes(x=lat_n,
#              y=long_e,
#              color = habitat)) +
#   geom_point(size = 5) +
#   theme_classic() 

#### VISUALIZE DATA ####

# points that deviate substantially from the best fit line potentially indicate errors in the lengths, these should be double checked
pdf("figures_1.pdf") 
data %>%
  ggplot(aes(x=standard_length_mm,
             y=total_length_mm)) +
  geom_point(size = 3) +
  geom_smooth() +
  theme_classic() +
  xlab("Standard Length (mm)") +
  ylab("Total Length (mm)") +
  labs(title = expression(italic(H.~scapularis)~Standard~Length~(mm)~vs.~Total~Length~(mm)~by~Location)) +
  facet_grid(location ~ .) 

data %>%
  ggplot(aes(x=standard_length_mm,
             y=weight_g)) +
  geom_point(size = 3) +
  geom_smooth() +
  theme_classic() +
  xlab("Standard Length (mm)") +
  ylab("Weight (g)") +
  labs(title = expression(italic(H.~scapularis)~Standard~Length~(mm)~vs.~Weight~(g)~by~Location)) +
  facet_grid(location ~ .)

data %>%
  filter(sex_clean=="F") %>%
  ggplot(aes(x=weight_g,
             y=weight_of_gonads_g)) +
  geom_point(size = 3) +
  geom_smooth() +
  theme_classic() +
  xlab("Weight (g)") +
  ylab("Weight of Gonads (g)") +
  labs(title = expression(italic(H.~scapularis)~Female~Weight~(g)~vs.~Female~Weight~of~Gonads~(g)~by~Location)) +
  facet_grid(location ~ .)
dev.off()

#color sites instead of paneling

data %>%
  filter(sex_clean=="F") %>%
  ggplot(aes(x=weight_g,
             y=weight_of_gonads_g,
             group=location, 
             color=location,
             shape=as.factor(stage_clean))) +
  geom_point(size = 3) +
  #geom_point(aes(color=as.factor(stage_clean), shape = location)) +
  geom_smooth(aes(fill=location)) +
  theme_classic() +
  xlab("Weight (g)") +
  ylab("Weight of Gonads (g)") +
  labs(title = expression(italic(H.~scapularis)~Female~Weight~(g)~vs.~Female~Weight~of~Gonads~(g)~by~Location)) 
  
geom_point(shape=1,size=3,color="black") 
#geom_point(aes(color=location)) +
 # scale_color_manual(values=c("gold", "coral", "lightskyblue")) +
  #geom_smooth(aes(color=location)) +
  #scale_color_manual(values=c("gold", "coral", "lightskyblue")) +
  #geom_smooth(aes(fill=location)) +
  #scale_fill_manual(values=c("gold", "coral", "lightskyblue")) +
#color sites instead of paneling

data %>%
  ggplot(aes(x=standard_length_mm,
             y=weight_of_gonads_g,
             color = sex_clean)) +
  geom_point(size = 3) +
  geom_smooth(method = "lm",
              se = FALSE) +
  geom_smooth(aes(x=standard_length_mm,
                  y=weight_of_gonads_g,
                  color = standard_length_mm),
              color = "black") +
  theme_classic() +
  facet_grid(location ~ .)

data %>%
  ggplot(aes(x=total_length_mm,
             y=weight_g)) +
  geom_point(size = 3) +
  geom_smooth() +
  theme_classic() +
  facet_grid(location ~ .)

data %>%
  ggplot(aes(y=standard_length_mm,
             x=sex_clean,
             fill = sex_clean)) +
  geom_boxplot() +
  theme_classic() +
  facet_grid(. ~ location)

# what defines a primary male? Here, there are males not identified as primary that are smaller than those identified as primary.  Also note the those identified as primary are longer than those identified as MF
data %>%
  ggplot(aes(y=standard_length_mm,
             x=sex_clean,
             fill = sex_clean)) +
  geom_boxplot() +
  theme_classic() +
  facet_grid(. ~ location + primary,
             scales = "free_x")

data %>%
  ggplot(aes(y=total_length_mm,
             x=sex_clean,
             fill = sex_clean)) +
  geom_boxplot() +
  theme_classic() +
  facet_grid(. ~ location)

data %>%
  ggplot(aes(y=weight_g,
             x=sex_clean,
             fill = sex_clean)) +
  geom_boxplot() +
  theme_classic() +
  facet_grid(. ~ location)

data %>% 
  pivot_longer(cols = c(total_length_mm, 
                        standard_length_mm, 
                        weight_g, 
                        weight_of_gonads_g)) %>%
  ggplot(aes(y=value,
             x=sex_clean,
             fill = sex_clean)) +
  geom_boxplot() +
  theme_classic() +
  facet_wrap(. ~ location + name,
             scales = "free_y")

data %>%
  ggplot(aes(x=standard_length_mm,
             y=stage_clean,
             color = sex_clean)) +
  geom_point(size = 3) +
  theme_classic() +
  facet_grid(. ~ location)

#Map stuff
#### INITIALIZATION ####
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(tidyverse)
library(janitor)
# install.packages("maps")
# install.packages("viridis")
require(maps)
require(viridis)
theme_set(
  theme_void()
)
install.packages("ggthemes")
library(ggthemes)

#### USER DEFINED VARIABLES ####

inFilePath1 = "metadata.rds"


#### READ IN DATA####

read_rds(inFilePath)


#### SIMPLE MAP OF SITE LOCATIONS ####
location_data %>%
  ggplot(aes(x=longitude,
             y=latitude,
             color = sub_location,
             shape = sub_location)) +
  geom_point(size = 3)

#### MAP OF WORLD USING MAPS PKG ####
#https://www.datanovia.com/en/blog/how-to-create-a-map-using-ggplot2/

world_map <- map_data("world")

world_map %>%
  ggplot(aes(x = long, 
             y = lat, 
             group = group)) +
  geom_polygon(fill="tan", 
               color = "brown4")

#### MAP OF ONE REGION USING MAPS PKG ####
map_data("world",
         region = "Philippines") %>%
  ggplot(aes(x = long, 
             y = lat,
             group = group)) +
  geom_polygon(fill="lightgray",
               colour = "black") 

#### MAP OF ONE REGION USING MAPS PKG, ONLY NAME SOME SUBREGIONS, INCLUDE SURVEY SITES FROM METADATA ####

subregion_label_data <- 
  map_data("world",
           region = "Philippines") %>%
  dplyr::group_by(subregion,
                  group) %>%
  dplyr::summarize(long = mean(long), 
                   lat = mean(lat)) %>%
  filter(subregion == "Negros" |
           subregion == "Cebu")

region_label_data <- 
  map_data("world",
           region = "Philippines") %>%
  dplyr::group_by(region) %>%
  dplyr::summarize(long = mean(long), 
                   lat = mean(lat))

map_data("world",
         region = "Philippines") %>%
  ggplot(aes(long,
             lat,
             group=group)) +
  geom_polygon(fill="lightgray",
               color = "black") +
  # subregion names
  geom_text(data = subregion_label_data,
            aes(label = subregion),
            size = 6,
            hjust = 0.5) +
  # region names
  geom_text(data = region_label_data,
            aes(x = long,
                y= lat,
                label = region),
            size = 10,
            hjust = 0.5,
            inherit.aes = FALSE) +
  # this next block is where the data points are added from metadata
  geom_point(data = location_data,
             aes(x = longitude,
                 y = latitude,
                 color = sub_location),
             inherit.aes = FALSE) +
  theme_classic()


#### zoom in on a set of subregions within a region ####

# define window
minLat = 7
minLong = 119
maxLat = 12
maxLong = 122.5

# make vector of unique subregions within window
subregions_keep <-
  map_data("world") %>%
  filter(long > minLong,
         long < maxLong,
         lat > minLat,
         lat < maxLat) %>%
  distinct(subregion) %>%
  pull()

# filter world map down to only the subregions
subregions_keep %>%
  purrr::map_df(~ map_data("world") %>%
                  filter(subregion == .x)) %>%
  # change lat and long values in keeper subregions that fall outside window to the window boundaries, prevents whacky shapes
  mutate(lat = case_when(lat < minLat ~ minLat,
                         lat > maxLat ~ maxLat,
                         TRUE ~ lat),
         long = case_when(long < minLong ~ minLong,
                          long > maxLong ~ maxLong,
                          TRUE ~ long)) %>%
  ggplot(aes(long,
             lat,
             group=group)) +
  # don't set color, otherwise you might get lines at the edges of the window
  geom_polygon(fill="green4") +
  geom_text(aes(x = 121,
                y= 8,
                label = "Sulu Sea"),
            size = 10,
            hjust = 0.5,
            inherit.aes = FALSE) +
  geom_point(data = location_data,
             aes(x = longitude,
                 y = latitude,
                 color = sub_location),
             inherit.aes = FALSE) +
  theme_classic()

#### set map completely by lat and long for regions and subregions within the window ####
minLat = 8.5
minLong = 122.5
maxLat = 10.5
maxLong = 124.5

regions_keep <-
  map_data("world") %>%
  filter(long > minLong,
         long < maxLong,
         lat > minLat,
         lat < maxLat) %>%
  distinct(region) %>%
  pull()

subregions_keep <-
  map_data("world") %>%
  filter(long > minLong,
         long < maxLong,
         lat > minLat,
         lat < maxLat) %>%
  distinct(subregion) %>%
  pull()

subregion_label_data <- 
  map_data("world") %>%
  filter(long > minLong,
         long < maxLong,
         lat > minLat,
         lat < maxLat) %>%
  dplyr::group_by(subregion) %>%
  dplyr::summarize(long = mean(long), 
                   lat = mean(lat))

map_data_regions <- 
  regions_keep %>%
  purrr::map_df(~ map_data("world") %>%
                  filter(region == .x))

subregions_keep %>%
  purrr::map_df(~ map_data_regions %>%
                  filter(subregion == .x)) %>%
  
  mutate(lat = case_when(lat < minLat ~ minLat,
                         lat > maxLat ~ maxLat,
                         TRUE ~ lat),
         long = case_when(long < minLong ~ minLong,
                          long > maxLong ~ maxLong,
                          TRUE ~ long)) %>%
  ggplot(aes(long,
             lat,
             group=group)) +
  geom_polygon(fill="lightgray") +
  # region names
  geom_text(data = subregion_label_data,
            aes(x = long,
                y= lat,
                label = subregion),
            size = 10,
            hjust = 0.5,
            inherit.aes = FALSE) +
  # geom_text(aes(x = 121,
  #               y= 8,
  #               label = "Sulu Sea"),
  #           size = 10,
  #           hjust = 0.5,
  #           color = "grey20",
  #           inherit.aes = FALSE) +
  geom_point(data = location_data,
             aes(x = longitude,
                 y = latitude,
                 color = sub_location,
                 shape = sub_location),
             inherit.aes = FALSE,
             size=5) +
  theme_classic()



# 
# data %>%
#   group_by(pipettor,
#            channel,
#            trial) %>%
#   summarize(mean_mass_g = mean(mass_g),
#             sd_mass_g = sd(mass_g)) %>%
#   ggplot(aes(x=channel,
#              y=mean_mass_g,
#              color = pipettor)) +
#   geom_point() +
#   geom_errorbar(aes(ymin=mean_mass_g - sd_mass_g,
#                     ymax = mean_mass_g + sd_mass_g)) +
#   geom_hline(yintercept = 0.013,
#              color = "grey",
#              linetype = "dashed") +
#   theme_classic() +
#   facet_grid(trial ~ pipettor,
#              scales = "free_x")
# ggsave("mean-mass_vs_channel_x_pipettor.png")
# 
# data %>%
#   ggplot(aes(x=order,
#              y=mass_g,
#              color = pipettor)) +
#   geom_point() +
#   geom_smooth() +
#   geom_hline(yintercept = 0.013,
#              color = "grey",
#              linetype = "dashed") +
#   theme_classic() +
#   facet_grid(. ~ trial,
#              scales = "free_x")
# ggsave("mass_vs_order_x_pipettor.png")
# 
# data %>%
#   group_by(pipettor,
#            channel,
#            trial) %>%
#   summarize(mean_mass_g = mean(mass_g),
#             sd_mass_g = sd(mass_g),
#             order = min(order)) %>%
#   ggplot(aes(x=order,
#              y=sd_mass_g,
#              color = pipettor)) +
#   geom_point() +
#   geom_smooth() +
#   geom_hline(yintercept = 0,
#              color = "grey",
#              linetype = "dashed") +
#   theme_classic() +
#   facet_grid(. ~ trial,
#              scales = "free_x")
# ggsave("sd-mass_vs_order_x_pipettor.png")
