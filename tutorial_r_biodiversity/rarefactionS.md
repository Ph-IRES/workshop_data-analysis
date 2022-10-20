# RAREFACTION SPECIES RICHNESS

We will be following the [vegan manual](https://cloud.r-project.org/web/packages/vegan/vegan.pdf) 


---

## Other Packages

* [`fossil`](https://search.r-project.org/CRAN/refmans/fossil/html/00Index.html)
	* see [`spp.est`](https://search.r-project.org/CRAN/refmans/fossil/html/spp.est.html)
* [`BAT`](https://search.r-project.org/CRAN/refmans/BAT/html/00Index.html)
	* [`alpha.estimate`](https://search.r-project.org/CRAN/refmans/BAT/html/alpha.estimate.html)
* [`iNEXT`](https://github.com/AnneChao/iNEXT)
* [Chaos Software](http://chao.stat.nthu.edu.tw/wordpress/software_download/)
	* [Chaos Github](https://github.com/AnneChao?tab=repositories)
* [mobr: Measurement of Biodiversity](https://rdrr.io/cran/mobr/)
	* [mobr::rarefaction()](https://rdrr.io/cran/mobr/man/rarefaction.html)

---

## Other Tutorials

* [Primer of Ecology Using R](https://hankstevens.github.io/Primer-of-Ecology/diversity.html)

---

## Getting Started: Wrangle data into format compatible with vegan.

For the species count data, each column is a taxon and each row is a unique site or observation

We will use the count data from the 78-79 smithsonian expecidition which is already here in this directory.  

Open `data_wrangling_vis_rarefaction.R` in R studio and run lines 1-130

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
