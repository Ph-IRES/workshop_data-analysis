#### INITIALIZATION ####
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(tidyverse)
library(magrittr)
# library(janitor)
# install.packages("fitdistrplus")

# install.packages("rlang")
# install.packages("emmeans")
# library(devtools)
# devtools::install_github("singmann/afex@master")
# devtools::install_github("eclarke/ggbeeswarm")
# install.packages("multcomp")
# install.packages("multcompView")
# install.packages("performance")
# install.packages("optimx")
# install.packages("effects")

library(fitdistrplus)
library(emmeans)
library(multcomp)
library(multcompView)
library(ggeffects)


# library(rlang)
# library(afex)
# library(ggbeeswarm)
# library(performance)
# library(optimx)
# library(effects)
# library(prediction)

# NOTE: after loading these packages, you may find that tidyverse commands are affected 
#       the solution is to add the appropriate package name before commands that break code
#       such as `dplyr::select` if `select` doesn't work correctly anymore
#       this happens when multiple packages have the same command names. 
#       The last package loaded takes precidence, and your tidyverse commands break.
#       you could load tidyverse last, but invariably, you will load a package after tidyverse
#       so it's impossible to avoid this

#### USER DEFINED VARIABLES ####

# path to fish sex change data set
inFilePath = "./halichores_scapularis_measurements_bartlett_2.rds"

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

data <-
  read_rds(inFilePath) %>%
  # make variable that has zero for female, one for male, and NA for everything else so we only focus in clear females and males
  mutate(female_male = case_when(sex_clean == "F" ~ 0,
                                 sex_clean == "M" ~ 1),
         # because our response variable is binomial (0,1), need to make count columns for the two outcomes for the stats command that requires binoial data to be fed in this way
         f_count = case_when(female_male == 0 ~ 1,
                             TRUE ~ 0),
         m_count = case_when(female_male == 1 ~ 1,
                             TRUE ~ 0),
         # make the fixed predictor variable a  factor
         # location = factor(location)
         ) %>%
  # we are removing all observations that were not classified as female or male for this binomial analysis
  drop_na(female_male)
  

#### FUNCTIONS ####
# Functions are commands that you define.  Here we define a function that makes several plots.
# running the code below will only save the function into memory.  Later we will call the function to make the plots
# visualize statistical distributions (see fitdistrplus: An R Package for Fitting Distributions, 2020)
vis_dists <- function(data,
                      response_var){
  
  data_plot <-
    data %>%
    drop_na(!!response_var) %>%
    # log() %>%
    pull(!!response_var)
  
  plotdist(data_plot)
  descdist(data_plot,
           boot=1000)
  
  fw <-
    try(fitdist(data_plot,
                "weibull"))
  fp <-
    try(fitdist(data_plot,
                "pois",
                method="mme"))
  fnb <-
    try(fitdist(data_plot,
                "nbinom",
                method="mme"))
  fg <-
    try(fitdist(data_plot,
                "gamma",
                method="mme"))
  fl <-
    try(fitdist(data_plot,
                "logis"))

  fln <-
    try(fitdist(data_plot,
                "lnorm"))

  fn <-
    try(fitdist(data_plot,
                "norm"))
  fge <-
    try(fitdist(data_plot,
                "geom",
                method="mme"))
  
  # remove distibutions that choke on neg or zero values if there are neg or zero values
  data_plot_lessorequal_zero = data_plot <= 0
  
  fits_to_plot <- 
    if(TRUE %in% data_plot_lessorequal_zero){
      list(fp, fl, fn, fge)
    } else {
      list(fw, fp, fnb, fg, fl, fln, fn, fge)
    }
  
  plot_legend <- 
    if(TRUE %in% data_plot_lessorequal_zero){
      c("Poisson", "Logis", "Normal", "Geom")
    } else {
      c("Weibull","Poisson","NegBinom","Gamma", "Logis","lognormal", "Normal", "Geom")
    }
denscomp(fge)
  par(mfrow = c(2, 2))
  try(denscomp(fits_to_plot, legendtext = plot_legend))
  try(qqcomp(fits_to_plot, legendtext = plot_legend))
  try(cdfcomp(fits_to_plot, legendtext = plot_legend))
  try(ppcomp(fits_to_plot, legendtext = plot_legend))
  par(mfrow = c(1, 1))
}


#### Explore Your Data For the Hypothesis Tests ####

# it is important to understand the nature of your data
# histograms can help you make decisions on how your data must be treated to conform with the assumptions of statistical models

data %>%
  pivot_longer(cols = c(contains("_mm"),
                        contains("_g")),
               names_to = "metric") %>%
  ggplot(aes(x=value,
             fill = sex_clean)) +
  geom_histogram() +
  theme_classic() +
  # theme(axis.text.x = element_text(angle = 0, 
  #                                  hjust=0.5)) +
  facet_grid(location ~ metric,
             scales = "free_x")

data %>%
  pivot_longer(cols = c(contains("_mm"),
                        contains("_g")),
               names_to = "metric") %>%
  ggplot(aes(x=value,
             fill = factor(stage_clean))) +
  geom_histogram() +
  theme_classic() +
  # theme(axis.text.x = element_text(angle = 0, 
  #                                  hjust=0.5)) +
  facet_grid(location ~ metric,
             scales = "free_x")

# I'm noticing that the left skewed distribution of `weight_of_gonads_g` is quite different from the other metrics
# it may have to be handled differently

# visualize statistical distributions (see fitdistrplus: An R Package for Fitting Distributions, 2020)
#  vis_dists() is a function that I made above in the FUNCTIONS section.  It accepts the tibble and column name to visualize.
#  vis_dists() creates three figures
vis_dists(data,
          "total_length_mm")
vis_dists(data,
          "standard_length_mm")
vis_dists(data,
          "weight_g")
# results in error making third plot because some values are zero and some of the distibutions are incompatible with zeros in data
vis_dists(data,
          "weight_of_gonads_g")
# results in error making third plot because some values are zero and some of the distibutions are incompatible with zeros in data
vis_dists(data,
          "female_male")



#### Make Visualization of Hypothesis Test ####
data %>%
  drop_na(female_male) %>%
  ggplot(aes(y=female_male,
             x = total_length_mm,
             color = location)) +
  geom_point(size = 5) +
  geom_smooth(formula = "y ~ x", 
              method = "glm", 
              method.args = list(family="quasibinomial"), 
              se = T) +
  theme_classic() +
  facet_grid(location ~ .)


#### Fixed Effects Hypothesis Test, Logistic Regression, 1 Slope ####

# here we set some variables for convenience
distribution_family = "binomial"
alpha_sig = 0.05

model <<- 
  glm(formula = female_male ~  total_length_mm + location, 
      family = distribution_family,
      data = data)


# view properties of model
ref_grid(model)

#show parameter estimates and other summary model stats and pvals
model
summary(model)

# visualize summary(model)
emmip(model, 
      location ~ total_length_mm,    # type = "response" for back transformed values
      cov.reduce = range) +
  geom_vline(xintercept=mean(data$total_length_mm),
             color = "grey",
             linetype = "dashed") +
  geom_text(aes(x = mean(data$total_length_mm),
                y = -10,
                label = "mean total_length_mm"),
            color = "grey") +
  theme_myfigs +
  labs(title = "Visualization of `summary(model)`",
       subtitle = "",
       y = "Linear Prediciton\n(Site 'Estimates' Derived from Mean Tot L)\n(Intercept 'Estimate' is mean of groups intersects y=0)",
       x = "Mean Total Length")

#### Conduct A priori contrast tests for differences among sites ####

# now we move on to finish the hypothesis testing.  Are there differences between the sites?
# estimated marginal means 



emmeans_model <<-
  emmeans(model,
          ~ total_length_mm + location,
          alpha = alpha_sig)

# emmeans back transformed to the original units of response var
summary(emmeans_model,      
        type="response")

# contrasts between sites
contrast(regrid(emmeans_model), # emmeans back transformed to the original units of response var
         method = 'pairwise', 
         simple = 'each', 
         combine = FALSE, 
         adjust = "bh")


#### Group Sites Based on Model Results ####

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

groupings_model             # these values are back transformed, groupings based on transformed


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
            by = c("total_length_mm",
                   "location")) %>%
  rename(response = 3)

groupings_model_fixed       # cld messes up back transformation, this takes values from emmeans and groupings from cld

#### Visualize Estimated Marginal Means Output With Group Categories ####

p <- 
  groupings_model_fixed %>%
  ggplot(aes(x=location,
             y=response,
             fill = location)) +
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
       y = "Probability of 116mm Fish Being Male") +
  theme(legend.position=c(0.33,0.8),  
        legend.title=element_blank())

p


#### Visualize Fixed Effect Model Fit (Response Var vs Continuous X Var by Group) ####

# this generates a tibble with the model predictions that can be plotted
  # however, it does not do a good job of showing us where the model is extrapolating 
emmeans_ggpredict <- 
  ggemmeans(model,
            terms = c("total_length_mm [all]",
                      "location")) 
  # compatible with ggplot
  # shows models, but extrapolates beyond observations
  plot(emmeans_ggpredict) +
    #this is our custom plot theme defined in USER DEFINED VARIABLES
    theme_myfigs


# the next several blocks of code will only show us predictions within the ranges of observation by location

# this way uses ggpredict, which has some nice features
  #make a tibble that has the max and min continuous xvar for each categorical xvar
  min_max_xvar <-  
    data %>%
      rename(x = total_length_mm,
             group = location) %>%
      group_by(group) %>%
      filter(x == max(x) |
               x == min(x)) %>%
      dplyr::select(group,
                    x) %>%
      arrange(group,
              x) %>%
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
    geom_jitter(data = data,
               aes(x = total_length_mm,
                   y = female_male,
                   color = location),
               size = 3,
               inherit.aes = FALSE,
               width = 0,
               height = 0.02) +
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

