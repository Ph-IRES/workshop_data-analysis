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

## Identifying the Distribution Family for you Hypothesis Test

It is especially important to identify the correct statistical distribution for your **response variable**, so the plots above can be used to help with identifying the correct distribution family for that.

Here are some rules of thumb:
* Binomial
	* if your unit of observation falls into one of two categories, such as Male or Female, then your data is binomial
	* percentage and proportion data that can be converted to count data is binomial


---

## Make Visualization of Hypothesis Test

Here we will test for the effect of size on the sex of _Halichores scapularis_ among different locations.

![](Rplot05.png)
Fig 6. Plots of fish sex (F=0, M=1) against total length.  Fit lines are logistic.

Some things to notice are that there are not many males from Dumaguete and not many females from Buenavista.  Consequently we might want to test some other hypotheses later. For example, testing for differences in total length by sex and location might be useful. But lets save this for later.

---

## Fixed Effects Hypthesis Test

If you only have variables that are [fixed](https://www.stat.purdue.edu/~ghobbs/STAT_512/Lecture_Notes/ANOVA/Topic_34.pdf) then we can use `glm()` to test your hypotheses.

```r
model <<- 
  glm(formula = female_male ~  total_length_mm + location, 
      family = distribution_family,
      data = data)
```

![](Rplot06.png)
Fig 7. Plots of fish sex (F=0, M=1) against total length.  Fit lines are logistic.


---

## Enter Information About Your Data for A Hypothesis Test

I tried to make it easier to get the correct statistical model by breaking it down to the different components
	* response var
		* binomial response vars
	* [fixed effect vars](https://www.stat.purdue.edu/~ghobbs/STAT_512/Lecture_Notes/ANOVA/Topic_34.pdf)
	* [random effect vars](https://www.stat.purdue.edu/~ghobbs/STAT_512/Lecture_Notes/ANOVA/Topic_34.pdf)

Consult the R script

---

## Fitting Statistical Model w [afex::mixed](https://www.rdocumentation.org/packages/afex/versions/1.1-1/topics/mixed)

[afex package on github](https://github.com/singmann/afex)
[afex help forum](https://afex.singmann.science/)


