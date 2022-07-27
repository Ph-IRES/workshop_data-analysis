# PERMANOVA: PERMUTATIONAL MULTIVARIATE ANALYSIS OF VARIANCE

We will be following the [vegan manual](https://cloud.r-project.org/web/packages/vegan/vegan.pdf) and using `adonis2`

Descriptions of PERMANOVA:
* [Wikipedia](https://en.wikipedia.org/wiki/Permutational_analysis_of_variance)
* [Cornell](https://cscu.cornell.edu/workshop/introduction-to-permanova/)
* [Marti Anderson](https://onlinelibrary.wiley.com/doi/full/10.1002/9781118445112.stat07841)

---

## Getting Started: Wrangle data into format compatible with vegan.

For the species count data, each column is a taxon and each row is a unique site or observation

We will use the count data from the `salvador` repo which is already here in this directory.  

Open [`data_wrangling_vis_salvador_permanova.R`](data_wrangling_vis_salvador_permanova.R) in R studio and run lines 1-130

Now we can wrangle the tibble `data` into vegan format

```r
data_vegan <-
  data %>%
  # make unique taxa
  mutate(taxon = str_c(family,
					   genus,
					   species,
					   sep = "_")) %>%
  # sum all max_n counts for a taxon and op_code
  group_by(taxon,
		   op_code) %>%
  summarize(sum_max_n = sum(max_n)) %>%
  ungroup() %>%
  # convert tibble from long to wide format
  pivot_wider(names_from = taxon,
			  values_from = sum_max_n,
			  values_fill = 0) %>%
  # sort by op_code
  arrange(op_code) %>%
  # remove the op_code column for vegan
  dplyr::select(-op_code)
```

For the metadata, each row must be in same order as in data tibble above:

```r
metadata_vegan <-
  data_all %>%
  # make unique taxa
  mutate(taxon = str_c(family,
					   genus,
					   species,
					   sep = "_")) %>%
  # sum all max_n counts for a taxon and op_code
  group_by(taxon,
		   op_code,
		   site,
		   survey_area,
		   habitat,
		   lat_n,
		   long_e,
		   depth_m,
		   bait_type) %>%
  summarize(sum_max_n = sum(max_n)) %>%
  ungroup() %>%
  # convert tibble from long to wide format
  pivot_wider(names_from = taxon,
			  values_from = sum_max_n,
			  values_fill = 0) %>%
  # sort by op_code
  arrange(op_code) %>%
  # remove the op_code column for vegan
  dplyr::select(op_code:bait_type) %>%
  mutate(site_code = str_remove(op_code,
								"_.*$"))
```

and lastly, we "attach" the metadata to the data

```r
attach(data_vegan.env)
```
 

---

## global test of model, differences in species composition with depth and site

The global test of the whole model is the most powerful test of your hypothesis that you can perform. The result of this test should be the first reported in your results for the test of your model.  If the global test of the model is not significant, then there is no reason to test the individual terms of the model.  In the example here, the global test is significant (see the `Pr(>F)` column in the PERMANOVA table.)

```r
adonis2(data_vegan ~ depth_m*site,
        data = data_vegan.env,
        by = NULL)
```

	Permutation test for adonis under reduced model
	Permutation: free
	Number of permutations: 999

	adonis2(formula = data_vegan ~ depth_m * site, data = data_vegan.env, by = NULL)
		 Df SumOfSqs    R2      F Pr(>F)    
	Model     7   5.9585 0.239 2.5573  0.001 ***
	Residual 57  18.9728 0.761                  
	Total    64  24.9313 1.000                  
	---
	Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

### INTERPRETATION OF PERMANOVA OUTPUT

Interpretion of the results of PERMANOVA is straight forward and just like an ANOVA. For descriptions of PERMANOVA, see the bulleted list at the top of this document.

* _Permutations_:  PERMANOVA utilizes a [permutation test](https://en.wikipedia.org/wiki/Permutation_test) to determine if there are significant differences in the [respoonse (dependent) variables](https://en.wikipedia.org/wiki/Permutation_test) among the groups defined by the [predictor (independent) variables](https://en.wikipedia.org/wiki/Permutation_test). The purpose of the permutations is to generate a [null distribution](https://en.wikipedia.org/wiki/Null_distribution) that the observed test statistic can be compared against. The [test statistic](https://en.wikipedia.org/wiki/Test_statistic) is a value that indicates the amount of difference among the groupings of your [unit of observation](https://en.wikipedia.org/wiki/Unit_of_observation). For PERMANOVA, the test statistic is _F_.  _It is important to realize that if you use PERMANOVA for genetic data, you must calculate the test statics yourself because a different test statistic is used - Wrights F Statistic._  But we digress.  In a nutshell, the permutation test proceeds with the units of observation (video transects or survey sites or individuals or ...) being randomly shuffled among the multivariate response variable values (`data_vegan`). These values can represent DNA sequences, community composition, morphology, etc.  Imagine shuffling entire rows in the `data_vegan.env` tibble 999 times, and calculating the test statistic for each of the 999 permutations - this is the null distribution. The more permutations you do, the more precise your [p-value](https://en.wikipedia.org/wiki/P-value) is. As an example, if you only do 5 permutations, the only possible p values are 0, 0.2, 0.4, 0.6, 0.8, and 1. With 1000 permutations, they are 0, 0.001, 0.002, ..., 0.999, 1

* Statistical Model: `adonis2(formula = data_vegan ~ depth_m * site, data = data_vegan.env, by = NULL)` The statistical model specified is repeated back to you.  `data_vegan` contains the response variables.  Technically, `data_vegan` is converted to a matrix of dissimilarity prior to calculating the test statistic. This matrix has one row and column for each unit of observation and the values in the matrix represent how similar (0 = identical) or dissimilar (larger values = more different) each pair of observations are.  In the example above, there are 65 videos, so a 65 x 65 dissimilarity matrix is created by PERMANOVA to represent the differences in the number of species and individuals observed. FWIW, the [Bray Curtis dissimilarity index](https://en.wikipedia.org/wiki/Bray%E2%80%93Curtis_dissimilarity) is used by default. 

* _[P-values](https://en.wikipedia.org/wiki/P-value)_:  In the PERMANOVA table, the `Pr(>F)` column is the p-value.  In the example above, this p-value represents that probability of observing a "permuted" _F_ test statistic greater than or equal to the observed _F_ statistic.  Put another way, in your permutations, this value is the number of times permuted _F_ >= observed _F_ divided by the number of permutations. In the example above, we are testing the whole model (global test) which is the most powerful test of our hypothesis that the community composition of fishes in the video surveys differ by `depth_m` and `site`.  The are multiple videos per `site`, a categorical variable, and `depth_m` is a continuous variable so there are many different depths.  In the examples below, we show how to generate P-values for each predictor variable in the model. 

* `F`: The observed test statistic

* `R2`: this is the proportion of total variation explained by each term (row) in the PERMANOVA table. These values are calculated from the `SumOfSqs` column.  In the case above the `model` and `residual` sums of squares are divided by the `Total` to obtain `R2`.

* `SumOfSqs`: This is the sum of squared differences, or a statement about the amount of variation explained by a term or factor in the model.  In the example above, the terms are the whole model (`Model`) and the error (`Residual`).  The `Total` is the sum of the `SumofSqs` of the terms.

* `Df`: [degrees of freedom](https://en.wikipedia.org/wiki/Degrees_of_freedom) represent how many independent observations are contributing to the hypothesis test.  You need at least 1 df (2 observations) to generate a p-value with which to evaluate your hypothesis.

* `Signif. codes`:  I would ignore these.  The scientist determines the threshold for statistical significance and it depends on the question you are asking and the magnitude of consequences if you commit either [Type I or Type II error](https://en.wikipedia.org/wiki/Type_I_and_type_II_errors).  Sometimes, it is prudent to be more permissive (higher p values considered significant), and others it is advisable to be more strict (lower p value threshold).

## test for differences in species composition with depth and site by each predictor, this is the default behavior, so `by` is not necessary

Once we have found the model to be significant, we can move on to testing whether each term in the statistical model is non-randomly related to the response variables.

```r
adonis2(data_vegan ~ depth_m*site,
        data = data_vegan.env,
        by = "terms")
```

	Permutation test for adonis under reduced model
	Terms added sequentially (first to last)
	Permutation: free
	Number of permutations: 999

	adonis2(formula = data_vegan ~ depth_m * site, data = data_vegan.env, by = "terms")
				 Df SumOfSqs      R2      F Pr(>F)    
	depth_m       1   1.8549 0.07440 5.5727  0.001 ***
	site          3   2.5297 0.10147 2.5333  0.001 ***
	depth_m:site  3   1.5738 0.06313 1.5761  0.003 ** 
	Residual     57  18.9728 0.76100                  
	Total        64  24.9313 1.00000                  
	---
	Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

The interpretation of these results should be straight forward. The one new concept is the [interaction term](https://en.wikipedia.org/wiki/Interaction_(statistics)) `depth_m:site`.  This term is significant if the relationship between the response variables (community composition, `data_vegan`) and `depth_m` is different at different sites. Note that `depth_m:site` is signficant.  Also note that we cannot decipher from this output how community composition varies by depth at the different sites, we only can determine that there is a 0.997 probabilty that the observed differences are not due to random variation. Other tools such as PCA and Ordination plots, or other types of plots based on species diversity (richness and abundance) can provide more context.  So, we visualize the differences with other tools, but the statistical test of those differences is done with PERMANOVA.

---

# the rest of these examples demonstrate additional functionality. your data and sampling design dicate how your parameterize `adonis2`


## test for differences in species composition with depth and site by each predictor, marginal effects
```r
adonis2(data_vegan ~ depth_m*site,
        data = data_vegan.env,
        by = "margin")
```

## dissimilarity indices can be selected, see `vegdist` in the vegan manual for options

```r
adonis2(data_vegan ~ depth_m*site,
        data = data_vegan.env,
        method = "bray")

adonis2(data_vegan ~ depth_m*site,
        data = data_vegan.env,
        method = "euclidean")
```


## by default, missing data will cause adonis2 to fail, but there are other alternatives
```r
# only non-missing site scores, remove all rows with missing data
adonis2(data_vegan ~ depth_m*site,
        data = data_vegan.env,
        na.action = na.omit)
```

## do not remove rows with missing data, but give NA for scores of missing observations or results that cannot be calculated
```r
adonis2(data_vegan ~ depth_m*site,
        data = data_vegan.env,
        na.action = na.exclude)
```

## constrain permutations within sites, if site is a "block" factor, then this is correct and including site as a factor is incorrect
```r
adonis2(data_vegan ~ bait_type*habitat,
        data = data_vegan.env,
        strata = site)
		```
