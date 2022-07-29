#### INITIALIZATION ####
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(tidyverse)
library(janitor)
library(magrittr)
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

library(rlang)
library(emmeans)
library(afex)
library(ggbeeswarm)
library(multcomp)
library(multcompView)
library(performance)
library(fitdistrplus)
library(optimx)
library(effects)
library(ggeffects)
library(prediction)

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
        axis.title.x = element_blank(),
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
        legend.position="blank")


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
  drop_na(female_male)
  

#### FUNCTIONS ####
# process quast data
process_quast_data <- function(treatment){
  tbl_assembly %>%
    filter(!str_detect(assembly, 
                       "broken"),
           scaffig == "scaffolds",
           library == treatment,
           # merged == "unmerged"
    ) %>%
    group_by(library,  # this combined with the first filter statement selects treatement with best result
             species,
             assembler,
             contamination) %>%
    # filter(!!response_var == max(!!response_var,   # https://stackoverflow.com/questions/24569154/use-variable-names-in-functions-of-dplyr
    filter(n50 == max(n50,   # https://stackoverflow.com/questions/24569154/use-variable-names-in-functions-of-dplyr
                      na.rm=TRUE),
           !duplicated(cbind(species,  # this removes all but 1 row with duplicate info based on the columns specified, ie when there are multiple equally good treatments
                             library,
                             assembler,
                             contamination,
                             n50))) %>%
    tibble::rowid_to_column("id")  # this is added to make poisson dist a neg binom dist by making this col a random factor
  
  # mutate(assembler = factor(assembler,
  #                           ordered=TRUE),
  #        species = factor(species,
  #                         ordered=TRUE),
  #        contamination = factor(contamination,
  #                               ordered=TRUE))
}

process_busco_data <- function(treatment){
  tbl_busco %>%
    filter(#!str_detect(assembly, 
      # "broken"),
      scaffig == "scaffolds",
      library == treatment,
      # merged == "unmerged"
    ) %>% 
    group_by(library,  # this combined with the first filter statement selects treatement with best result
             species,
             assembler,
             contamination) %>%
    # filter(!!response_var == max(!!response_var,   # https://stackoverflow.com/questions/24569154/use-variable-names-in-functions-of-dplyr
    filter(complete_and_single_copy_buscos_s == max(complete_and_single_copy_buscos_s,   # https://stackoverflow.com/questions/24569154/use-variable-names-in-functions-of-dplyr
                                                    na.rm=TRUE),
           # missing_buscos_m == min(missing_buscos_m,   # https://stackoverflow.com/questions/24569154/use-variable-names-in-functions-of-dplyr
           #                         na.rm=TRUE),
           !duplicated(cbind(species,  # this removes all but 1 row with duplicate info based on the columns specified, ie when there are multiple equally good treatments
                             library,
                             assembler,
                             contamination,
                             complete_and_single_copy_buscos_s,
                             missing_buscos_m))
    ) %>%
    tibble::rowid_to_column("id")   # this is added to make poisson dist a neg binom dist by making this col a random factor
  # mutate(assembler = factor(assembler,
  #                           ordered=TRUE),
  #        species = factor(species,
  #                         ordered=TRUE),
  #        contamination = factor(contamination,
  #                               ordered=TRUE))
}

join_data <- function(data_quast,
                      data_busco){
  data_quast %>%
    full_join(data_busco,
              by = c("scaffig",
                     "species",
                     "library",
                     "assembler",
                     "contamination",
                     "repaired",
                     "ng_input_dna")) %>%
    dplyr::select(-contains("id.")) %>%
    tibble::rowid_to_column("id")  # this is added to make poisson dist a neg binom dist by making this col a random factor
}

# visualize raw quast data
vis_data <- function(data,
                     response_var,
                     y_label){
  ggplot(data,
         aes(y=!!response_var, 
             x=assembler,
             fill = contamination)) +
    geom_col(position="dodge") +
    theme_classic() +
    # theme(axis.text.x = element_text(angle = 0, 
    #                                  hjust=0.5)) +
    labs(y=y_label) +
    facet_grid(species ~ library)
}

# visualize statistical distributions (see fitdistrplus: An R Package for Fitting Distributions, 2020)
vis_dists <- function(data,
                      response_var){
  
  data %>%
    pull(!!response_var) %>% 
    # log() %>%
    plotdist(.)
  
  data %>%
    drop_na(!!response_var) %>%
    pull(!!response_var) %>% 
    # log() %>%
    descdist(data=.,
             boot=1000)
  
  fw <-
    data %>%
    drop_na(!!response_var) %>%
    pull(!!response_var) %>% 
    # log() %>%
    try(fitdist(.,
                "weibull"))
  
  fp <-
    data %>%
    drop_na(!!response_var) %>%
    pull(!!response_var) %>% 
    # log() %>%
    fitdist(.,
            "pois",
            method="mme")
  fnb <-
    data %>%
    drop_na(!!response_var) %>%
    pull(!!response_var) %>% 
    # log() %>%
    fitdist(.,
            "nbinom",
            method="mme")
  fg <-
    data %>%
    drop_na(!!response_var) %>%
    pull(!!response_var) %>%
    # log() %>%
    fitdist(.,
            "gamma",
            method="mme")
  fl <-
    data %>%
    drop_na(!!response_var) %>%
    pull(!!response_var) %>% 
    # log() %>%
    fitdist(.,
            "logis")
  
  fln <-
    data %>%
    drop_na(!!response_var) %>%
    pull(!!response_var) %>% 
    # log() %>%
    try(fitdist(.,
                "lnorm"))
  fn <-
    data %>%
    drop_na(!!response_var) %>%
    pull(!!response_var) %>% 
    # log() %>%
    fitdist(.,
            "norm")
  fge <-
    data %>%
    drop_na(!!response_var) %>%
    pull(!!response_var) %>% 
    # log() %>%
    fitdist(.,
            "geom",
            method="mme")
  
  
  par(mfrow = c(2, 2))
  plot.legend <- c("Weibull","Poisson","NegBinom","Gamma", "Logis","lognormal", "Normal", "Geom")
  try(denscomp(list(fw, fp, fg, fl, fln, fn, fge), legendtext = plot.legend))
  try(qqcomp(list(fw, fp, fg, fl, fln, fn, fge), legendtext = plot.legend))
  try(cdfcomp(list(fw, fp, fg, fl, fln, fn, fge), legendtext = plot.legend))
  try(ppcomp(list(fw, fp, fg, fl, fln, fn, fge), legendtext = plot.legend))
  
}
# hypothesis testing
run_stats <- function(data,
                      response_var,
                      fixed_var,
                      rand_var,
                      distribution_family,
                      binom_vars = NULL,
                      alpha_sig = 0.05){
  
  # this handles binomial vs other families bc binomial requires binom_vars variable
  if(length(binom_vars) == 0){
    design <- 
      paste(quo_text(response_var),         # this stitches together the formula
            # "~ contamination * assembler",
            quo_text(fixed_var),
            rand_var)
  } else {
    design <- paste(quo_text(binom_vars),         # this stitches together the formula
                    "~ contamination * assembler",
                    rand_var)
  }
  
  # custom model  
  model <<- 
    afex::mixed(formula = design, 
                family = distribution_family,
                method = "LRT",
                sig_symbols = rep("", 4),
                # all_fit = TRUE,
                data = data)
  
  if(length(binom_vars) == 0){
    p.custom <<- 
      afex_plot(model,               # https://rdrr.io/github/singmann/afex/man/afex_plot.html
                x = "assembler",
                trace = "contamination",
                mapping = c("shape", "fill"),
                data_geom = ggpol::geom_boxjitter,
                data_arg = list(
                  width = 0.4, 
                  jitter.width = 0.5,
                  # jitter.height = 10,
                  outlier.intersect = TRUE),
                point_arg = list(size = 3), 
                line_arg = list(linetype = 0),
                error_arg = list(size = 1.5, width = 0)) +  
      scale_fill_manual(values = c("lightgrey",
                                   "white"),
                        # labels = c('Pre-Screen', 
                        #            'Post-Screen')
      ) +
      theme_classic() +
      labs(title="affex:mixed model fit custom family")
  } else {
    p.custom <<- "need to figure out how to plot binomial model results"
  }
  # cbind(
  #   afex_plot(model, ~assembler, ~contamination, 
  #             error = "model", return = "data")$means[,c("assembler", "contamination", "y", "SE")],
  #   multivariate = afex_plot(model, ~assembler, ~contamination,
  #                            error = "model", return = "data")$means$error,
  #   mean = afex_plot(model, ~assembler, ~contamination,
  #                    error = "mean", return = "data")$means$error,
  #   # within = afex_plot(model, ~assembler, ~contamination,
  #   #                    error = "within", return = "data")$means$error,
  #   between = afex_plot(model, ~assembler, ~contamination,
  #                       error = "between", return = "data")$means$error)
  
  emmeans_model <<-
    emmeans(model,
            ~ assembler * contamination,
            alpha = alpha_sig)
  
  contrasts_model <<- contrast(emmeans_model, 
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
              by = c("assembler",
                     "contamination")) %>%
    rename(response = 3)
  
  # default model
  model.defaults <<- 
    afex::mixed(paste(quo_text(response_var),         # this stitches together the formula
                      "~ contamination * assembler + (1|species)"), 
                sig_symbols = rep("", 4),
                data = data)
  
  # p.defaults <<- 
  #   afex_plot(model.defaults,               # https://rdrr.io/github/singmann/afex/man/afex_plot.html
  #             x = "assembler",
  #             trace = "contamination",
  #             # data_geom = ggpol::geom_boxjitter,
  #             dodge = 0.9,
  #             data_geom = ggbeeswarm::geom_beeswarm,
  #             data_arg = list(
  #               dodge.width = 0.9,  ## needs to be same as dodge
  #               cex = 1,
  #               color = "darkgrey",
  #               size = 3),
  #             point_arg = list(size = 3), 
  #             line_arg = list(linetype = 0),
  #             error_arg = list(size = 1, width = 0)
  #             ) +  
  #     theme_classic() +
  #     labs(title="affex:mixed model fit defaults")
  
  p.defaults <<- 
    afex_plot(model.defaults,               # https://rdrr.io/github/singmann/afex/man/afex_plot.html
              x = "assembler",
              trace = "contamination",
              mapping = c("shape", "fill"),
              data_geom = ggpol::geom_boxjitter,
              data_arg = list(
                width = 0.4, 
                jitter.width = 0.5,
                # jitter.height = 10,
                outlier.intersect = TRUE),
              point_arg = list(size = 3), 
              line_arg = list(linetype = 0),
              error_arg = list(size = 1.5, width = 0)) +  
    scale_fill_manual(values = c("lightgrey",
                                 "white"),
                      # labels = c('Pre-Screen', 
                      #            'Post-Screen')
    ) +
    theme_classic() +
    labs(title="affex:mixed model fit defaults")
  
  
  emmeans_model.defaults <<-
    emmeans(model.defaults,
            ~ assembler * contamination,
            alpha = alpha_sig)
  
  contrasts_model.defaults <<- contrast(emmeans_model.defaults, 
                                        method = 'pairwise', 
                                        simple = 'each', 
                                        combine = FALSE, 
                                        adjust = "bh")
  
  groupings_model.defaults <<-
    multcomp::cld(emmeans_model.defaults, 
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
  groupings_model_fixed.defaults <<-
    summary(emmeans_model.defaults,      # emmeans back transformed to the original units of response var
            type="response") %>%
    tibble() %>%
    left_join(groupings_model.defaults %>%
                dplyr::select(-response:-upper.CL),
              by = c("assembler",
                     "contamination")) %>%
    rename(response = 3)
}

# aggregate hypothesis tests

get_table_03 <- function(anova_table,
                         response_var,
                         distribution_family,
                         treatment){
  anova_table %>%
    as_tibble(rownames = "param") %>%
    clean_names() %>%
    mutate(response = quo_text(response_var),
           dist_family = distribution_family,
           library = treatment) %>%
    rename(p = pr_chisq) %>%
    dplyr::select(response,
                  dist_family,
                  library,
                  param, 
                  df,
                  chi_df,
                  chisq,
                  p)
}

get_table_04 <- function(groupings_model_fixed,
                         response_var,
                         distribution_family,
                         treatment){
  groupings_model_fixed %>%
    clean_names() %>%
    mutate(response = quo_text(response_var),
           dist_family = distribution_family,
           library = treatment) %>%
    rename(ci_upper = 7,
           ci_lower = 6) %>%
    dplyr::select(response,
                  dist_family,
                  library,
                  assembler, 
                  contamination,
                  response,
                  se,
                  df,
                  ci_lower,
                  ci_upper,
                  group,
                  group_2)
}

get_table_05 <- function(contrast_table,
                         response_var,
                         distribution_family,
                         treatment){
  contrast_table %>%
    as_tibble() %>%
    clean_names() %>%
    mutate(response = quo_text(response_var),
           dist_family = distribution_family,
           library = treatment) %>%
    rename(p = p_value) %>%
    dplyr::select(response,
                  dist_family,
                  library,
                  contamination,
                  contrast, 
                  estimate,
                  se,
                  df,
                  z_ratio,
                  p)
}


# visualize stats
vis_stats <- function(data,
                      data_all,
                      response_var,
                      treatment,
                      hide_legend = FALSE,
                      ymin = 0,
                      ymax = NA){
  
  p <- 
    data %>%
    ggplot(aes(x=total_length_mm,
               y=female_male,
               color = location)) +
    geom_point() +
    scale_fill_manual(values = c("lightgrey",
                                 "white"),
                      labels = c('Pre-Screen', 
                                 'Post-Screen')) +
    geom_point(data = data_all,
               aes(x = assembler,
                   y = !!response_var,
                   shape = contamination,
                   color = species
               ),
               position = position_dodge(width = 0.9),
               # color = "grey70",
               # shape = 1,
               size = 1)
  
  if(treatment == "all"){
    p <- p +
      scale_color_manual(values = c("#53B400",
                                    "#00C094",
                                    "#A58AFF"))
  }
  
  p <- p +
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
    theme_assembly_quality +
    ylim(ymin, 
         ymax) +
    labs(title = str_c("Libraries:",
                       str_to_upper(treatment) %>%
                         str_remove("[NR].*"),
                       "ng",
                       sep = " "),
         x = "ASSEMBLER",
         y = y_label) 
  
  if(hide_legend == TRUE){
    p + theme(legend.position="blank",   #c(0.25,0.8)
              legend.title=element_blank())
  } else {
    p + theme(legend.position=c(0.33,0.8),  
              legend.title=element_blank())
  }
  
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

model <<- 
  glm(formula = female_male ~  total_length_mm + location, 
      family = distribution_family,
      data = data)

# this generates a tibble with the model predictions that can be plotted
  # however, it does not do a good job of showing us where the model is extrapolating 
emmeans_ggpredict <- 
  ggemmeans(model,
            terms = c("total_length_mm [all]",
                      "location")) 
  # compatible with ggplot
  plot(emmeans_ggpredict)


# the next several blocks of code will only show us predictions within the ranges of observation by location
  
# data %>%
#   group_by(location) %>%
#   filter(total_length_mm == max(total_length_mm) | 
#            total_length_mm == min(total_length_mm)) %>%
#   dplyr::select(location,
#                 total_length_mm)

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

# plot model and data
bind_cols(data_predict,
          prob_male = predict(model,
                              data.frame(data_predict),
                              type = "response")) %>%
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

# now we move on to finish the hypothesis testing.  Are there differences between the sites?
# estimated marginal means & contrasts
emmeans_model <<-
  emmeans(model,
          ~ total_length_mm + location,
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
            by = c("total_length_mm",
                   "location")) %>%
  rename(response = 3)


model
anova(model)
summary(model)
emmeans_model               # emmeans in transformed units used for analysis
summary(emmeans_model,      # emmeans back transformed to the original units of response var
        type="response")
contrasts_model             # contrasts in transformed units used for analysis
contrasts_model_regrid      # contrasts are back transformed
groupings_model             # these values are back transformed, groupings based on transformed
groupings_model_fixed       # cld messes up back transformation, this takes values from emmeans and groupings from cld


#### Visualize Statistical Results From Previous Section ####

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

#### Mixed Effects Hypothesis Test ####


## Enter Information About Your Data for A Hypothesis Test ##

# define your response variable, here it is binomial
response_var = quo(female_male) # quo() allows column names to be put into variables 

# if you have binom response var then `quo(cbind(outcome1_count, outcome2_count))` 
# if you don't have a binomial response var then set this to ""
# this is the way the afex::mixed command wants its binomial data, rather than percents or proportions or true/false or a single column of 0 and 1
binom_vars = quo(cbind(m_count, f_count)) 

# enter partial formula for fixed predictor variables
# one fixed var: "varname"
# two fixed vars with interaction: "var1name * var2name"
# two fixed vars with no interaction: "var1name + var2name"
# if you don't have any fixed vars then set to ""
fixed_vars = "location"

# enter partial formula for fixed predictor variables
# one rand var: "(1|varname)"
# two rand vars: "(1|var1name) + (1|var2name)"
# afex::mixed requires a rand var and cannot have the same var here as in fixed_vars
rand_vars = "(1|total_length_mm)"

# enter the distribution family for your response variable
distribution_family = "binomial"
alpha_sig = 0.05
hide_legend = FALSE


# construct full model formula from variables above 
if(length(binom_vars) == 0 & length(fixed_vars) == 0){
  sampling_design <- 
    paste(quo_text(response_var),         # this stitches together the formula
          " ~ ",
          rand_vars)
} else if(length(binom_vars) == 0 & length(fixed_vars) > 0){
  sampling_design <- 
    paste(quo_text(response_var),         # this stitches together the formula
          " ~ ",
          fixed_vars,
          " + ",
          rand_vars)
} else if(length(binom_vars) > 0 & length(fixed_vars) == 0){
  sampling_design <- paste(quo_text(binom_vars),         # this stitches together the formula
                  " ~ ",
                  rand_vars)
} else if(length(binom_vars) > 0 & length(fixed_vars) > 0){
  sampling_design <- paste(quo_text(binom_vars),         # this stitches together the formula
                           " ~ ",
                           fixed_vars,
                           " + ",
                           rand_vars)
}

# view full model formula
sampling_design

# fit mixed model
model <<- 
  afex::mixed(formula = female_male ~  location + (1|total_length_mm), 
              family = distribution_family,
              method = "LRT",
              sig_symbols = rep("", 4),
              # all_fit = TRUE,
              data = data)

#plot
try(
  afex_plot(model,
            "location") +
    theme(axis.text.x = element_text(angle=90))
)

model <-
glmer(formula = female_male ~  location + (1|total_length_mm), 
      family = distribution_family,
      data = data)

# https://github.com/strengejacke/ggeffects
ggpredict(model,
          "location",
          # type="random",
          # condition = c(total_length_mm = 0)
          ) %>%
  plot() +
  theme_classic()

draw(model, type = "average")

effect("location",
       mod = model)

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

# plot model and data
bind_cols(data_predict,
          prob_male = predict(model,
                              data.frame(data_predict),
                              type = "response")) %>%
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














# estimated marginal means & contrasts
emmeans_model <<-
  emmeans(model,
          ~ location,
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
            by = c("location",
                   "prob")) %>%
  rename(response = 3)


model
model$anova_table
summary(model)
emmeans_model               # emmeans in transformed units used for analysis
summary(emmeans_model,      # emmeans back transformed to the original units of response var
        type="response")
contrasts_model             # contrasts in transformed units used for analysis
contrasts_model_regrid      # contrasts are back transformed
groupings_model             # these values are back transformed, groupings based on transformed
groupings_model_fixed       # cld messes up back transformation, this takes values from emmeans and groupings from cld


#### Visualize Statistical Results From Previous Section ####

p <- 
  groupings_model_fixed %>%
  ggplot(aes(x=location,
             y=prob,
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
  theme(legend.position=c(0.67,0.8),  
        legend.title=element_blank())

p

