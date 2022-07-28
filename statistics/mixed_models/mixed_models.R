#### INITIALIZATION ####
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(tidyverse)
library(janitor)
# install.packages("rlang")
# install.packages("emmeans")
# install.packages("afex")
# library(devtools)
# devtools::install_github("eclarke/ggbeeswarm")
# install.packages("multcomp")
# install.packages("performance")
# install.packages("fitdistrplus")

library(rlang)
library(emmeans)
library(afex)
library(ggbeeswarm)
library(multcomp)
library(performance)
library(fitdistrplus)

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

theme_assembly_quality <- 
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
  read_rds(inFilePath)
  

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
    pull(!!response_var) %>% 
    # log() %>%
    descdist(data=.,
             boot=1000)
  
  fw <-
    data %>%
    pull(!!response_var) %>% 
    # log() %>%
    fitdist(.,
            "weibull")
  fp <-
    data %>%
    pull(!!response_var) %>% 
    # log() %>%
    fitdist(.,
            "pois",
            method="mme")
  fnb <-
    data %>%
    pull(!!response_var) %>% 
    # log() %>%
    fitdist(.,
            "nbinom",
            method="mme")
  fg <-
    data %>%
    pull(!!response_var) %>%
    # log() %>%
    fitdist(.,
            "gamma",
            method="mme")
  fl <-
    data %>%
    pull(!!response_var) %>% 
    # log() %>%
    fitdist(.,
            "logis")
  fln <-
    data %>%
    pull(!!response_var) %>% 
    # log() %>%
    fitdist(.,
            "lnorm")
  fn <-
    data %>%
    pull(!!response_var) %>% 
    # log() %>%
    fitdist(.,
            "norm")
  fge <-
    data %>%
    pull(!!response_var) %>% 
    # log() %>%
    fitdist(.,
            "geom",
            method="mme")
  
  
  par(mfrow = c(2, 2))
  plot.legend <- c("Weibull","Poisson","NegBinom","Gamma", "Logis","lognormal", "Normal", "Geom")
  denscomp(list(fw, fp, fg, fl, fln, fn, fge), legendtext = plot.legend)
  qqcomp(list(fw, fp, fg, fl, fln, fn, fge), legendtext = plot.legend)
  cdfcomp(list(fw, fp, fg, fl, fln, fn, fge), legendtext = plot.legend)
  ppcomp(list(fw, fp, fg, fl, fln, fn, fge), legendtext = plot.legend)
  
}
# hypothesis testing
run_stats <- function(data,
                      response_var,
                      rand_var,
                      distribution_family,
                      binom_vars = NULL,
                      alpha_sig = 0.05){
  
  # this handles binomial vs other families bc binomial requires binom_vars variable
  if(length(binom_vars) == 0){
    design <- 
      paste(quo_text(response_var),         # this stitches together the formula
            "~ contamination * assembler",
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
    ggplot(aes(x=assembler,
               y=response,
               fill = contamination)) +
    geom_col(position = "dodge",
             color = "black") +
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



#### FIG 01a, TABLE 2, stat test n50 500 ####
fig = "01"
response_var = quo(weight_g) # quo() allows column names to be put into variables 
rand_var = "+ (1|species) + (1|id)"
treatment = "500NR"
distribution_family = "poisson"
y_label = "N50 (bp)"
hide_legend = FALSE
fig_w = 3.25
fig_h = 3

#### visualize continuous variables ####

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
vis_dists(data,
          quo(weight_g))


# hypothesis tests
run_stats(data,
          response_var,
          rand_var,
          distribution_family)

p.custom # model results
p.defaults # default results if we didn't customize
model$anova_table
emmeans_model               # emmeans in transformed units used for analysis
summary(emmeans_model,      # emmeans back transformed to the original units of response var
        type="response")
contrasts_model             # contrasts in transformed units used for analysis
groupings_model             # these values are back transformed, groupings based on transformed
groupings_model_fixed       # cld messes up back transformation, this takes values from emmeans and groupings from cld

# aggregate & store hypothesis test results into tibbles

table_03 <- 
  get_table_03(model$anova_table,
               response_var,
               distribution_family,
               treatment)

table_04 <-
  get_table_04(groupings_model_fixed,
               response_var,
               distribution_family,
               treatment)

table_05 <-
  get_table_05(contrasts_model$`simple contrasts for assembler`,
               response_var,
               distribution_family,
               treatment)  

# check assumptions

# visualize statistical results
vis_stats(groupings_model_fixed,
          data,
          response_var,
          treatment,
          hide_legend)

ggsave(str_c("products/fig", 
             fig,
             quo_text(response_var),
             treatment,
             ".png",
             sep = "_"),
       units = "in",
       width = fig_w,
       height = fig_h)
