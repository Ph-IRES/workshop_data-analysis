# PERMANOVA: PERMUTATIONAL MULTIVARIATE ANALYSIS OF VARIANCE

We will be following the [vegan manual](https://cloud.r-project.org/web/packages/vegan/vegan.pdf) and using `adonis2`

---

## Getting Started: Wrangle data into format compatible with vegan.

[See Ordination Tutorial](ordination.md)

---

## global test of model, differences in species composition with depth and site
```r
adonis2(data_vegan ~ depth_m*site,
        data = data_vegan.env,
        by = NULL)
```

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
