#### Mixed Effects Hypothesis Test ####

#Here we use the visayan deer data set to demonstrate a mxed model with both fixed and randome factor.scope(

## Enter Information About Your Data for A Hypothesis Test ##

# define your response variable, here it is binomial
response_var = quo(amplification) # quo() allows column names to be put into variables 

# enter the distribution family for your response variable
distribution_family = "binomial"

# if you have binom response var then `quo(cbind(outcome1_count, outcome2_count))` 
# if you don't have a binomial response var then set this to ""
# this is the way the afex::mixed command wants its binomial data, rather than percents or proportions or true/false or a single column of 0 and 1
binom_vars = quo(cbind(success, 
                       failure)) 

# enter partial formula for fixed predictor variables
# one fixed var: "varname"
# two fixed vars with interaction: "var1name * var2name"
# two fixed vars with no interaction: "var1name + var2name"
# if you don't have any fixed vars then set to ""
fixed_vars = "locus * primer_x"

# enter partial formula for fixed predictor variables
# one rand var: "(1|varname)"
# two rand vars: "(1|var1name) + (1|var2name)"
# afex::mixed requires a rand var and cannot have the same var here as in fixed_vars
rand_vars = "(1|individual) + (1|plate_number)"

alpha_sig = 0.05


# # construct full model formula from variables above 
# if(length(binom_vars) == 0 & length(fixed_vars) == 0){
#   sampling_design <- 
#     paste(quo_text(response_var),         # this stitches together the formula
#           " ~ ",
#           rand_vars)
# } else if(length(binom_vars) == 0 & length(fixed_vars) > 0){
#   sampling_design <- 
#     paste(quo_text(response_var),         # this stitches together the formula
#           " ~ ",
#           fixed_vars,
#           " + ",
#           rand_vars)
# } else if(length(binom_vars) > 0 & length(fixed_vars) == 0){
#   sampling_design <- paste(quo_text(binom_vars),         # this stitches together the formula
#                   " ~ ",
#                   rand_vars)
# } else if(length(binom_vars) > 0 & length(fixed_vars) > 0){
#   sampling_design <- paste(quo_text(binom_vars),         # this stitches together the formula
#                            " ~ ",
#                            fixed_vars,
#                            " + ",
#                            rand_vars)
# }
# 
# # view full model formula
# sampling_design
# 
# # fit mixed model
# model <<- 
#   afex::mixed(formula = sampling_design, 
#               family = distribution_family,
#               method = "LRT",
#               sig_symbols = rep("", 4),
#               # all_fit = TRUE,
#               data = data_1bandperloc)
# 
# model
# #plot
# try(
#   afex_plot(model,
#             "location") +
#     theme(axis.text.x = element_text(angle=90))
# )