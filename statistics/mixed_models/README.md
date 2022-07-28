# TESTING HYPOTHESES WITH MIXED MODELS

Under construction

---

## Getting Started

Open [`miexed_models.R`](mixed_models.R) in Rstudio and run the `INITIALIZATION` section

NOTE: after loading these packages, you may find that tidyverse commands are affected. The solution is to add the appropriate package name before commands that break code such as `dplyr::select` if `select` doesn't work correctly anymore. This happens when multiple packages have the same command names. The last package loaded takes precidence, and your tidyverse commands break. You could load tidyverse last, but invariably, you will load a package after tidyverse that breaks one of its commands, so it's impossible to avoid this.

We will use Ingrids data set on sex change in _Halichores scapularis_ which has been saved as an R data structure (RDS) file. 

---

## Explore Your Data For the Hypothesis Tests

### basic ggplot plots
It is important to understand the nature of your data. Histograms can help you make decisions on how your data must be treated to conform with the assumptions of statistical models.

![](Rplot.png)
Fig 1. Histograms of fish measurements by location and sex.  U=immature, sex cannot be determined, F=female, MF=both sex organs, M=male, PM=primary male, NA= no observation made

![](Rplot01.png)
Fig 2. Histograms of fish measurements by location and sex. The stages range from 0=immature sex undecipherable to 4=mature female to ...

Im noticing that the left skewed distribution of `weight_of_gonads_g` is quite different from the other metrics. It may have to be handled differently.

---

### fitdistrplus: An R Package for Fitting Distributions

`vis_dists()` is a function that I made in the FUNCTIONS section of this script.  It accepts the tibble and column name to visualize.

vis_dists() creates three figures

![](Rplot02.png)
Fig 3. Histogram and cumulative distribution of `total_length_mm`

![](Rplot03.png)
Fig 4. Cullen and Frey Graph of kurtosis vs square of skewness for `total_length_mm`. **I really like this one.**  This shows you which statistical distribution the data most closely resembles.  Here, the data is nearly log normal, but better fit by the beta distribution.

![](Rplot04.png)
Fig 5. 4 additional plots that allow you to determine the distribution that most closely fits `total_length_mm`

---

## Make Visualization of Hypothesis Test

Here we will test for the effect of size on the sex of _Halichores scapularis_ among different locations.

![](Rplot05.png)
Fig 6. Plots of fish sex (F=0, M=1) against total length.  Fit lines are logistic.

---

##
