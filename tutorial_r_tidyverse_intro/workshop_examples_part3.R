rm(list = ls())

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(tidyverse)
library(janitor)
library(lubridate)

source("workshop_functions.R")

#### Read In Data ####

stm <-tibble(storms) %>%
  storms_ymdh()

dmd <-tibble(diamonds)

#### Scatter Plots ####

stm %>%
  filter(year == 1998) %>%
  ggplot(aes(y = wind,
             x = ymdh,
             colour = name))

stm %>%
  filter(year == 1998) %>%
  ggplot(aes(y = wind,
             x = ymdh,
             colour = name)) + 
  geom_point()

stm %>%
  filter(year == 1998) %>%
  ggplot(aes(y = wind,
             x = ymdh,
             colour = name)) + 
  geom_point() + 
  geom_line() 

### Tend Lines ###

stm %>%
  filter(year == 1998,
         month == "9") %>%
  ggplot(aes(y = wind,
             x = ymdh,
             color = name)) + 
  geom_point() + 
  geom_smooth()

stm %>%
  filter(year == 1998,
         month == "9") %>%
  ggplot(aes(y = wind,
             x = ymdh,
             color = name)) + 
  geom_point() + 
  geom_smooth(method = "lm")

stm %>%
  filter(year == 1998,
         month == "9") %>%
  ggplot(aes(y = wind,
             x = ymdh,
             color = name)) + 
  geom_point() + 
  geom_smooth(method = "lm",
              formula = y ~ poly(x,3))

stm %>%
  filter(year == 1998,
         month == "9") %>%
  ggplot(aes(y = wind,
             x = ymdh,
             color = name)) + 
  geom_point() + 
  geom_smooth(method = "lm",
              formula = y ~ poly(x,3),
              se = FALSE)

#### Histograms Density and Bar Plots ####

dmd %>%
  ggplot(aes(x = price,
             fill = cut)) +
  geom_histogram(bins = 10)

dmd %>%
  ggplot(aes(x = price,
             color = clarity)) +
  geom_density()

stm %>%
  group_by(category) %>%
  summarise(mean_winds = mean(wind)) %>%
  ungroup() %>%
  ggplot(aes(x = category,
             y = mean_winds,
             fill = category)) +
  geom_col()

### Error Bars ###

stm %>%
  group_by(category) %>%
  summarise(mean_winds = mean(wind),
            sd_winds = sd(wind)) %>%
  ungroup() %>%
  ggplot(aes(x = category,
             y = mean_winds,
             fill = category)) +
  geom_col() +
  geom_errorbar(aes(ymin = mean_winds - sd_winds,
                    ymax = mean_winds + sd_winds))

### Box and Violin Plot ###

dmd %>%
  ggplot(aes(x = cut, 
             y = depth,
             fill = cut)) +
  geom_boxplot()

dmd %>%
  ggplot(aes(x = cut, 
             y = depth,
             fill = cut)) +
  geom_violin()

#### Faceting ####

dmd %>%
  ggplot(aes(x = price,
             fill = cut)) +
  geom_histogram(bins = 100) +
  facet_grid(. ~ cut)

dmd %>%
  ggplot(aes(x = price,
             fill = cut)) +
  geom_histogram(bins = 100) +
  facet_grid(color~cut)

stm %>%
  filter(year == 1998,
         month == "9") %>%
  ggplot(aes(y = wind,
             x = ymdh,
             color = name)) + 
  geom_point() + 
  geom_smooth(method = "lm",
              formula = y ~ poly(x,3),
              se = FALSE) +
  facet_wrap(~name,
             nrow=5)

stm %>%
  filter(year == 1998,
         month == "9") %>%
  ggplot(aes(y = wind,
             x = ymdh,
             color = name)) + 
  geom_point() + 
  geom_smooth(method = "lm",
              formula = y ~ poly(x,3),
              se = FALSE) +
  facet_wrap(category~name)

#### Modifying Plot Visuals ####

stm %>%
  group_by(month_word, year) %>%
  summarise(mean_wind = mean(wind)) %>%
  ungroup() %>%
  ggplot(aes(x = as.numeric(as.character(year)),
             y = month_word,
             colour = mean_wind,
             size = mean_wind)) +
  geom_point()

library(RColorBrewer)

(themes_plot <- 
    stm %>%
    group_by(category) %>%
    summarise(mean_winds = mean(wind),
              sd_winds = sd(wind)) %>%
    ungroup() %>%
    ggplot(aes(x = category,
               y = mean_winds,
               fill = category)) +
    geom_col() +
    geom_errorbar(aes(ymin = mean_winds - sd_winds,
                      ymax = mean_winds + sd_winds)) +
    xlab("Category") +
    ylab("Mean Wind Speed") +
    labs(fill = "Category",
         title = "Mean Wind Speeds for Documented Hurricanes, 
       Tropical Storms,\nand Tropical Depressions from 1975 - 2020"))

themes_plot +
  theme_bw()

themes_plot +
  theme_classic()

themes_plot +
  theme_dark()

themes_plot +
  theme_minimal()

themes_plot +
  theme_void()

plot2save <- 
    stm %>%
    group_by(category) %>%
    summarise(mean_winds = mean(wind),
              sd_winds = sd(wind)) %>%
    ungroup() %>%
    ggplot(aes(x = category,
               y = mean_winds,
               fill = category)) +
    geom_col() +
    geom_errorbar(aes(ymin = mean_winds - sd_winds,
                      ymax = mean_winds + sd_winds),
                  width = .5,
                  size = .75) +

    labs(y = "Mean Wind Speed",
         x = "Category",
         fill = "Category",
         title = "Mean Wind Speeds for Documented Hurricanes,\nTropical Storms, and Tropical Depressions from 1975 - 2020") +
    theme_classic() +
    theme(panel.grid.major.y = element_line(linewidth  = .5, 
                                            linetype = "longdash", 
                                            colour = "darkgrey"),
          panel.grid.minor.y = element_line(linewidth = .1,
                                            linetype = "dashed",
                                            colour = "lightgrey"),
          axis.title = element_text(size = 16, colour = "black"),
          axis.text = element_text(size = 12, colour = "black"),
          title = element_text(size = 16, colour = "black"),
          legend.position = "none")

ggsave(plot2save,
       filename = "saved_plot.png",
       units = "in",
       width = 8,
       height = 5)


