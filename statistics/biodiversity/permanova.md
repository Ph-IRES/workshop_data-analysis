# PERMANOVA: PERMUTATIONAL MULTIVARIATE ANALYSIS OF VARIANCE

We will be following the [vegan manual](https://cloud.r-project.org/web/packages/vegan/vegan.pdf) and using `adonis2`

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


## test for differences in species composition with depth and site by each predictor, this is the default behavior, so `by` is not necessary
```r
adonis2(data_vegan ~ depth_m*site,
        data = data_vegan.env,
        by = "terms")
```

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
