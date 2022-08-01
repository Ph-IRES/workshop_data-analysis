#### INITIALIZATION ####
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(tidyverse)
library(janitor)
library(magrittr)
library(gridExtra)

# install.packages("rlang")
# install.packages("emmeans")
# library(devtools)
# devtools::install_github("singmann/afex@master")
# devtools::install_github("eclarke/ggbeeswarm")
# install.packages("multcomp")
# install.packages("multcompView")
# install.packages("performance")
# install.packages("fitdistrplus")
# install.packages("optimx")
# install.packages("effects")

library(fitdistrplus)
library(emmeans)
library(multcomp)
library(multcompView)
library(ggeffects)

library(rlang)
library(afex)
library(ggbeeswarm)
library(performance)
library(optimx)
library(effects)
library(prediction)
library(ggforce)

# NOTE: after loading these packages, you may find that tidyverse commands are affected 
#       the solution is to add the appropriate package name before commands that break code
#       such as `dplyr::select` if `select` doesn't work correctly anymore
#       this happens when multiple packages have the same command names. 
#       The last package loaded takes precidence, and your tidyverse commands break.
#       you could load tidyverse last, but invariably, you will load a package after tidyverse
#       so it's impossible to avoid this

#### USER DEFINED VARIABLES ####

# path to fish sex change data set
inFilePath2 = "./visayan_deer_3primer_microsat_amp_data.rds"
functionPath = "../functions/model_fitting_functions.R"

# you can make a default theme for your publication's figures.  This makes things easier for you. 
# feel free to customize as necessary
theme_myfigs <- 
  theme_classic() +
  theme(panel.background = element_rect(fill = 'white', 
                                        color = 'white'),
        panel.grid = element_blank(),
        panel.grid.major.y = element_line(color="grey95", 
                                          size=0.25),
        panel.border = element_blank(),
        axis.text.y = element_text(size = 9, 
                                   color = 'black'),
        axis.text.x = element_text(size = 9, 
                                   color = 'black'),
        # axis.title.x = element_blank(),
        axis.title.y = element_text(size = 10, 
                                    color = 'black'),
        plot.title = element_text(size = 10, 
                                  color = 'black'),
        plot.subtitle = element_text(size = 9, 
                                     color = 'black'),
        plot.caption = element_text(size = 9, 
                                    color = 'black', 
                                    hjust = 0),
        legend.text = element_text(size = 9, 
                                   color = 'black'),
        legend.title = element_text(size = 9, 
                                    color = 'black'),
        legend.background = element_blank(),
        legend.position="right"
  )



#### READ IN DATA ####

# read in data and remove rows with missing data or multiple bands
data_1bandperloc <-
  read_rds(inFilePath2) %>%
  filter(bands_per_locus <= 1) %>%
  drop_na(amplification) %>%
  mutate(success = case_when(amplification == 1 ~ 1,
                             TRUE ~ 0),
         failure = case_when(amplification == 0 ~ 1,
                             TRUE ~ 0),
         plate_row = factor(plate_row),
         plate_column = factor(plate_column),
         plate_number = factor(plate_number)) 

#### FUNCTIONS ####
# visualize statistical distributions (see fitdistrplus: An R Package for Fitting Distributions, 2020)
source(functionPath)

#### Explore Your Data For the Hypothesis Tests ####

# it is important to understand the nature of your data
# histograms can help you make decisions on how your data must be treated to conform with the assumptions of statistical models

data_1bandperloc %>%
  ggplot(aes(x=primer_x,
             fill = locus)) +
  geom_histogram() +
  theme_classic() +
  # theme(axis.text.x = element_text(angle = 0, 
  #                                  hjust=0.5)) +
  facet_grid(locus ~ .,
             scales = "free_x")

p_sampsize <-
  data_1bandperloc %>%
    group_by(plate_row,
             plate_column) %>%
    summarize(prop_amped = sum(amplification)/n(),
              n = n()) %>%
    ungroup() %>%
    mutate(plate_row = factor(plate_row,
                              levels = c("H",
                                         "G",
                                         "F",
                                         "E",
                                         "D",
                                         "C",
                                         "B",
                                         "A")),
           plate_column = factor(plate_column,
                                 levels = seq(1,
                                              12,
                                              1))) %>%
    complete(plate_row,
             plate_column,
             fill = list(prop_amped = NA,
                         n = 0)) %>%
    
    ggplot(aes(x = plate_column,
               y = plate_row,
               color = n)) +
    geom_point(size = 35) +
    scale_color_gradient(high = "blue4",
                         low = "white") +
    geom_text(aes(label = str_c("n = ",
                                n,
                                sep = "")),
              color = "black") +
    theme_bw() +
    labs(title = "Sample Size")
p_sampsize

p_amp <-
  data_1bandperloc %>%
    group_by(plate_row,
             plate_column) %>%
    summarize(prop_amped = sum(amplification)/n(),
              n = n()) %>%
    ungroup() %>%
    mutate(plate_row = factor(plate_row,
                  levels = c("H",
                             "G",
                             "F",
                             "E",
                             "D",
                             "C",
                             "B",
                             "A")),
           plate_column = factor(plate_column,
                                 levels = seq(1,
                                              12,
                                              1))) %>%
    complete(plate_row,
             plate_column,
             fill = list(prop_amped = NA,
                         n = 0)) %>%
    
    ggplot(aes(x = plate_column,
           y = plate_row,
           color = prop_amped)) +
    geom_point(size = 35) +
    scale_color_gradient(high = "green4",
                         low = "grey90") +
    geom_text(aes(label = round(prop_amped, 
                                2)),
              color = "black") +
    theme_bw() +
    labs(title = "Proportion Amplified")
p_amp

grid.arrange(p_sampsize,
             p_amp,
             nrow=2,
             ncol=1)


# p_amp <-
  data_1bandperloc %>%
  group_by(plate_row,
           plate_column) %>%
  summarize(prop_amped = sum(amplification)/n(),
            n = n(),
            n_loci = length(unique(locus)),
            n_ind = length(unique(individual))) %>%
  ungroup() %>%
  mutate(plate_row = factor(plate_row,
                            levels = c("H",
                                       "G",
                                       "F",
                                       "E",
                                       "D",
                                       "C",
                                       "B",
                                       "A")),
         plate_column = factor(plate_column,
                               levels = seq(1,
                                            12,
                                            1)),
         plate_address = str_c(plate_row,
                               plate_column,
                               sep="")) %>%
  complete(plate_row,
           plate_column,
           fill = list(prop_amped = NA,
                       n = 0)) %>%
  filter(n > 0) %>%
  ggplot(aes(x = n,
             y = prop_amped,
             color = n_loci,
             shape = factor(n_ind))) +
  geom_point(size = 3) +
  geom_smooth(aes(x=n,
                  y=prop_amped),
              se = FALSE,
              inherit.aes = FALSE) +
  scale_color_gradient(high = "green4",
                       low = "grey90") +
  theme_bw() +
  labs(title = "Proportion Amplified vs Sample Size")


# visualize statistical distributions (see fitdistrplus: An R Package for Fitting Distributions, 2020)
#  vis_dists() is a function that I made above in the FUNCTIONS section.  It accepts the tibble and column name to visualize.
#  vis_dists() creates three figures

# results in error making third plot because some values are zero and some of the distibutions are incompatible with zeros in data
vis_dists(data_1bandperloc,
          "amplification")



#### Make Visualization of Hypothesis Test ####
data_1bandperloc %>%
  group_by(locus) %>%
  # remove loci that failed on every sample to simplify
  filter(sum(amplification) > 0) %>%
  ungroup() %>%
  ggplot(aes(y=amplification,
             x = primer_x,
             color = locus)) +
  geom_jitter(size = 2,
              width = 0.025,
              height = 0.025) +
  geom_smooth(formula = "y ~ x", 
              method = "glm", 
              method.args = list(family="quasibinomial"), 
              se = FALSE) +
  theme_myfigs +
  labs(y = "Amplification Success Rate",
       x = "Primer Concentration (x)")


#### SEPARATE LOCI BY PRIMER CONCENTRATION GROUPS

#separate loci into groups by primer_x
data_locus_groups <- 
  data_1bandperloc  %>%
  group_by(locus) %>%
  # remove loci that failed on every sample to simplify
  filter(sum(amplification) > 0) %>%
  ungroup() %>%
  distinct(primer_x,
           locus) %>%
  group_by(locus) %>%
  summarize(n_primer_x = n()) 

data_1bandperloc_11 <-
  data_1bandperloc %>%
  left_join(data_locus_groups,
            by = "locus") %>%
  filter(n_primer_x == 11)

data_1bandperloc_3 <-
  data_1bandperloc %>%
  left_join(data_locus_groups,
            by = "locus") %>%
  filter(n_primer_x <= 3)  


#### Mixed Effects Hypothesis Test ####

#Here we use the visayan deer data set to demonstrate a mxed model with both fixed and randome factor.scope(

## Enter Information About Your Data for A Hypothesis Test ##

# define your response variable, here it is binomial
response_var = quo(amplification) # quo() allows column names to be put into variables 

# enter the distribution family for your response variable
distribution_family = "binomial"


alpha_sig = 0.05

# we start with the loci subjected to 11 primer concentrations (we removed loci with no amplification to simplify)

# sampling_design11 = "amplification ~  locus * primer_x + (1|individual) + (1|plate_number/plate_row:plate_column)"
# sampling_design11 = "amplification ~  locus * primer_x + (1|individual) + (1|plate_number) + (plate_number|plate_row:plate_column)"
# sampling_design11 = "amplification ~  locus * primer_x + (1|individual) + (1|plate_number) + (plate_number|plate_row) + (plate_number|plate_column)"
sampling_design11 = "amplification ~  locus * primer_x + (1|individual) + (1|plate_number) + (1|plate_row) + (1|plate_column)"
# sampling_design11 = "amplification ~  locus * primer_x + (1|individual) + (1|plate_number)"
# sampling_design11 = "amplification ~  locus * primer_x + (1|individual) "
# sampling_design11 = "amplification ~  locus * primer_x * individual + (1|plate_number/plate_row:plate_column)"

model11 <-
  glmer(formula = sampling_design11, 
        family = distribution_family,
        data = data_1bandperloc_11)

model11
anova(model11)
summary(model11)

# visualize summary(model)
emmip(model11, 
      locus ~ primer_x,    # type = "response" for back transformed values
      cov.reduce = range) +
  geom_vline(xintercept=mean(data_1bandperloc_11$primer_x),
             color = "grey",
             linetype = "dashed") +
  geom_text(aes(x = mean(data_1bandperloc_11$primer_x),
                y = -2,
                label = "mean primer_x"),
            color = "grey") +
  theme_myfigs +
  labs(title = "Visualization of `summary(model11)`",
       subtitle = "",
       y = "Linear Prediciton",
       x = "Primer Concentration X")

#### Conduct A priori contrast tests for differences among sites ####

# now we move on to finish the hypothesis testing.  Are there differences between the sites?
# estimated marginal means 

emmeans_model <<-
  emmeans(model11,
          ~ primer_x + locus,
          alpha = alpha_sig)

emmeans_model_min_max <<-
  emmeans(model11,
        ~ primer_x + locus,
        alpha = alpha_sig,
        cov.reduce = range)

# emmeans back transformed to the original units of response var
summary(emmeans_model,      
        type="response")

summary(emmeans_model_min_max,      
        type="response")

# contrasts between sites
contrast(regrid(emmeans_model_min_max), # emmeans back transformed to the original units of response var
         method = 'pairwise', 
         simple = 'each', 
         combine = FALSE, 
         adjust = "bh")


#### Group Sites Based on Model Results ####

groupings_model <<-
  multcomp::cld(emmeans_model_min_max, 
                alpha = alpha_sig,
                Letters = letters,
                type="response",
                adjust = "bh") %>%
  as.data.frame %>%
  mutate(group = str_remove_all(.group," "),
         group = str_replace_all(group,
                                 "(.)(.)",
                                 "\\1,\\2")) %>%
  rename(response = 3)

groupings_model             # these values are back transformed, groupings based on transformed


# i noticed that the emmeans from groupings don't match those from emmeans so this is the table to use for making the figure
# the emmeans means and conf intervals match those produced by afex_plot, so I think those are what we want
groupings_model_fixed <<-
  summary(emmeans_model_min_max,      # emmeans back transformed to the original units of response var
          type="response") %>%
  tibble() %>%
  left_join(groupings_model %>%
              dplyr::select(-response:-asymp.UCL),
            # by = c(str_replace(fixed_vars,
            #                    "[\\+\\*]",
            #                    '" , "'))) %>%
            by = c("primer_x",
                   "locus")) %>%
  rename(response = 3)

groupings_model_fixed       # cld messes up back transformation, this takes values from emmeans and groupings from cld

#### Visualize Estimated Marginal Means Output With Group Categories ####

p <- 
  groupings_model_fixed %>%
  ggplot(aes(x=factor(primer_x),
             y=response,
             fill = locus)) +
  geom_col(position = "dodge",
           color = "black") +
  # scale_fill_manual(values = c("lightgrey",
  #                              "white"),
  #                   labels = c('Pre-Screen', 
  #                              'Post-Screen')) +
  # geom_point(data = data,
  #            aes(x = location,
  #                y = !!response_var,
  #                color = location
  #            ),
  #            position = position_dodge(width = 0.9),
  #            # color = "grey70",
#            # shape = 1,
#            size = 1)
  geom_errorbar(aes(ymin=asymp.LCL,
                  ymax=asymp.UCL),
              width = 0.2,
              color = "grey50",
              # size = 1,
              position = position_dodge(width=0.9)) +
  guides(color = "none",
         shape = "none") +   #remove color legend
  geom_text(aes(label=group),
            position = position_dodge(width=0.9),
            vjust = -0.5,
            hjust = -0.15,
            size = 8 / (14/5)) +  # https://stackoverflow.com/questions/25061822/ggplot-geom-text-font-size-control
  theme_myfigs +
  # ylim(ymin, 
  #      ymax) +
  labs(x = "Primer Concentration (X)",
       y = "Probability of Amplification Success") +
  theme(legend.position=c(0.33,0.8),  
        legend.title=element_blank()) +
  facet_grid(. ~ locus)

p


#### Visualize Fixed Effect Model Fit (Response Var vs Continuous X Var by Group) ####

# this generates a tibble with the model predictions that can be plotted
# however, it does not do a good job of showing us where the model is extrapolating 
emmeans_ggpredict <- 
  ggemmeans(model11,
            terms = c("primer_x [all]",
                      "locus")) 
# compatible with ggplot
# shows models, but extrapolates beyond observations
plot(emmeans_ggpredict) +
  #this is our custom plot theme defined in USER DEFINED VARIABLES
  theme_myfigs


# the next several blocks of code will only show us predictions within the ranges of observation by location

# this way uses ggpredict, which has some nice features
#make a tibble that has the max and min continuous xvar for each categorical xvar
min_max_xvar <-  
  data_1bandperloc_11 %>%
  rename(x = primer_x,
         group = locus) %>%
  group_by(group) %>%
  filter(x == max(x) |
           x == min(x)) %>%
  dplyr::select(group,
                x) %>%
  arrange(group,
          x) %>%
  distinct() %>%
  mutate(min_max = case_when(row_number() %% 2 == 0 ~ "max_x",
                             TRUE ~ "min_x")) %>%
  pivot_wider(names_from = min_max,
              values_from = x)
# then use that tibble to filter the object made by ggpredict and plot
emmeans_ggpredict %>%
  left_join(min_max_xvar) %>% 
  filter(x >= min_x,
         x <= max_x) %>% 
  plot() +
  #add in our observed values of female_male
  geom_jitter(data = data_1bandperloc_11,
              aes(x = primer_x,
                  y = amplification,
                  color = locus),
              size = 3,
              inherit.aes = FALSE,
              width = 0.025,
              height = 0.025) +
  theme_myfigs


# alternatively, we can use the predict command.  The logic used is similar to above.
x_increment = 1

data_predict <-
  unique(data$location) %>%
  purrr::map_df(~tibble(total_length_mm = seq(data %>%
                                                filter(location == .x) %>%
                                                filter(total_length_mm == min(total_length_mm)) %>%
                                                pull(total_length_mm),
                                              data %>%
                                                filter(location == .x) %>%
                                                filter(total_length_mm == max(total_length_mm)) %>%
                                                pull(total_length_mm),
                                              x_increment),
                        location = .x)) 
ggpredict(model,
          newdata = data.frame(data_predict),
          terms = c("total_length_mm [all]",
                    "location"))

# plot model and data
bind_cols(data_predict,
          prob_male = predict(model,
                              data.frame(data_predict),
                              type = "response",
                              se.fit = TRUE)) %>%
  ggplot(aes(x = total_length_mm,
             y = prob_male,
             color = location)) +
  geom_point(data = data,
             aes(x = total_length_mm,
                 y = female_male,
                 color = location),
             size = 5) +
  geom_line(size = 2) +
  theme_classic()








#### OLD ####




# https://github.com/strengejacke/ggeffects
ggemmeans_model11 <-
ggpredict(model11,
          c("primer_x",
            "locus"),
          # type="random",
          # condition = c(total_length_mm = 0)
          ) 
plot(ggemmeans_model11) +
  theme_classic() +
  geom_point(size=4) +
  labs(title = "Loci Amplified from 0.1 - 1.25x w/ at Least 1 Success",
       subtitle = sampling_design11,
       x = "Primer Concentration (X)",
       y = "Probability of Amplifcation Success")

# ggplot(ggemmeans_model2,
#        aes(x=x,
#            y = predicted,
#            color = group,
#            shape = group)) +
#   geom_line() +
#   geom_point(size=4) +
#   labs(title = sampling_design2,
#        x = "Primer Concentration (X)",
#        y = "Probability of Amplifcation Success")



# x_increment = 1
# 
# data_predict <-
#   unique(data$location) %>%
#   purrr::map_df(~tibble(total_length_mm = seq(data %>%
#                                                 filter(location == .x) %>%
#                                                 filter(total_length_mm == min(total_length_mm)) %>%
#                                                 pull(total_length_mm),
#                                               data %>%
#                                                 filter(location == .x) %>%
#                                                 filter(total_length_mm == max(total_length_mm)) %>%
#                                                 pull(total_length_mm),
#                                               x_increment),
#                         location = .x)) 
# 
# # plot model and data
# bind_cols(data_predict,
#           prob_male = predict(model,
#                               data.frame(data_predict),
#                               type = "response")) %>%
#   ggplot(aes(x = total_length_mm,
#              y = prob_male,
#              color = location)) +
#   geom_point(data = data,
#              aes(x = total_length_mm,
#                  y = female_male,
#                  color = location),
#              size = 5) +
#   geom_line(size = 2) +
#   theme_classic()


# estimated marginal means & contrasts
emmeans_model <<-
  emmeans(model,
          ~ locus * primer_x,
          alpha = alpha_sig)

contrasts_model <<- 
  contrast(emmeans_model, 
           method = 'pairwise', 
           simple = 'each', 
           combine = FALSE, 
           adjust = "bh")

contrasts_model_regrid <<- 
  contrast(regrid(emmeans_model), 
           method = 'pairwise', 
           simple = 'each', 
           combine = FALSE, 
           adjust = "bh")

groupings_model <<-
  multcomp::cld(emmeans_model, 
                alpha = alpha_sig,
                Letters = letters,
                type="response",
                adjust = "bh") %>%
  as.data.frame %>%
  mutate(group = str_remove_all(.group," "),
         group = str_replace_all(group,
                                 "(.)(.)",
                                 "\\1,\\2")) %>%
  rename(response = 3)

# i noticed that the emmeans from groupings don't match those from emmeans so this is the table to use for making the figure
# the emmeans means and conf intervals match those produced by afex_plot, so I think those are what we want
groupings_model_fixed <<-
  summary(emmeans_model,      # emmeans back transformed to the original units of response var
          type="response") %>%
  tibble() %>%
  left_join(groupings_model %>%
              dplyr::select(-response:-asymp.UCL),
            # by = c(str_replace(fixed_vars,
            #                    "[\\+\\*]",
            #                    '" , "'))) %>%
            by = c("locus",
                   "primer_x")) %>%
  rename(response = 3)


model
model$anova_table
# summary(model)
# emmeans_model               # emmeans in transformed units used for analysis
summary(emmeans_model,      # emmeans back transformed to the original units of response var
        type="response")
# contrasts_model             # contrasts in transformed units used for analysis
contrasts_model_regrid      # contrasts are back transformed
# groupings_model             # these values are back transformed, groupings based on transformed
groupings_model_fixed       # cld messes up back transformation, this takes values from emmeans and groupings from cld


#### Visualize Statistical Results From Previous Section ####

p <- 
  groupings_model_fixed %>%
  ggplot(aes(x=locus,
             y=response,
             fill = locus)) +
  geom_col(position = "dodge",
           color = "black") +
  # scale_fill_manual(values = c("lightgrey",
  #                              "white"),
  #                   labels = c('Pre-Screen', 
  #                              'Post-Screen')) +
  # geom_point(data = data,
  #            aes(x = location,
  #                y = !!response_var,
  #                color = location
  #            ),
  #            position = position_dodge(width = 0.9),
  #            # color = "grey70",
#            # shape = 1,
#            size = 1)
geom_errorbar(aes(ymin=asymp.LCL,
                  ymax=asymp.UCL),
              width = 0.2,
              color = "grey50",
              # size = 1,
              position = position_dodge(width=0.9)) +
  guides(color = "none",
         shape = "none") +   #remove color legend
  geom_text(aes(label=group),
            position = position_dodge(width=0.9),
            vjust = -0.5,
            hjust = -0.15,
            size = 8 / (14/5)) +  # https://stackoverflow.com/questions/25061822/ggplot-geom-text-font-size-control
  theme_myfigs +
  # ylim(ymin, 
  #      ymax) +
  labs(x = "",
       y = "Probability of Amplification at 0.854") +
  theme(legend.position=c(0.67,0.8),  
        legend.title=element_blank())

p

