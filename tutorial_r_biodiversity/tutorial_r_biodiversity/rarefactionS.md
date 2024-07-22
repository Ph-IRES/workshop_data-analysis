# SPECIES RICHNESS, RAREFACTION, and ACCUMULATION CURVES

We will be following the [vegan manual](https://cloud.r-project.org/web/packages/vegan/vegan.pdf) 


---

## Getting Started: Wrangle data into format compatible with vegan.

For the species count data, each column is a taxon and each row is a unique site or observation

We will use the count data from the 78-79 smithsonian expedidition which is already here in this directory.  

In your local copy of the `workshop_data-analysis` reop, open `tutorial_r_biodiversity/data_wrangling_vis_rarefaction.R` in R studio and run lines 1-130

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

Continue the tutorial by following the comments and running the code in `tutorial_r_biodiversity/data_wrangling_vis_rarefaction.R`

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
