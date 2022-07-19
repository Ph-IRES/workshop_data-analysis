
library("tidyverse")

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

#### Activity 1 ####

read_csv("davis_practive.csv")

davis_from_car <- read_csv("davis_practive.csv")

davis <- read_csv("davis_practive.csv") %>%
  drop_na()

davis %>% 
  select(-height, -repht) %>%
  filter(sex == "F",
         haircolor == "brown")

# drop_na removes all rows where there is an na in any column.

#### Activity 2 ####

davis %>% 
  select(-height, -repht) %>%
  filter(sex == "F",
         haircolor == "brown") %>%
  mutate(mean_weight = (weight + repwt)/2,
         weight_difference = weight - repwt,
         np = case_when(weight_difference < 0 ~ "Negative",
                        weight_difference > 0 ~ "Positive",
                        weight_difference == 0 ~ "No Change"))

#### Assignment 3 ####

davis %>%
  mutate(mean_weight = (weight + repwt)/2,
         weight_difference = weight - repwt) %>%
  group_by(haircolor,
           sex) %>%
  summarise(count = n(),
            mean_mean_weight = mean(mean_weight),
            sd_mean_weight = sd(mean_weight),
            median_mean_weight = median(mean_weight),
            IQR_mean_weight = IQR(mean_weight)) %>%
  ungroup()
