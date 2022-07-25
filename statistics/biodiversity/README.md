# BIODIVERSITY ANALYSIS

## R Packages

* [vegan](https://cloud.r-project.org/web/packages/vegan/index.html)
* [BiodiversityR](https://rdrr.io/cran/BiodiversityR/)
* [adiv](https://besjournals.onlinelibrary.wiley.com/doi/epdf/10.1111/2041-210X.13430)

---

## Other Tutorials

* https://www.mooreecology.com/uploads/2/4/2/1/24213970/vegantutor.pdf
* http://www.kembellab.ca/r-workshop/biodivR/SK_Biodiversity_R.html
* https://peat-clark.github.io/BIO381/veganTutorial.html

---

## Getting Started

1. Install `vegan` and any necessary dependencies 

	```
	> install.packages("vegan")
	WARNING: Rtools is required to build R packages but no version of Rtools compatible with the currently running version of R was found. Note that the following incompatible version(s) of Rtools were found:

	  - Rtools 3.4 (installed at C:\RBuildTools\3.4)
	  - Rtools 3.5 (installed at C:\RBuildTools\3.5)

	Please download and install the appropriate version of Rtools before proceeding:

	https://cran.rstudio.com/bin/windows/Rtools/
	Installing package into ‘C:/Users/cbird/AppData/Local/R/win-library/4.2’
	(as ‘lib’ is unspecified)
	also installing the dependency ‘permute’

	trying URL 'https://cran.rstudio.com/bin/windows/contrib/4.2/permute_0.9-7.zip'
	Content type 'application/zip' length 225001 bytes (219 KB)
	downloaded 219 KB

	trying URL 'https://cran.rstudio.com/bin/windows/contrib/4.2/vegan_2.6-2.zip'
	Content type 'application/zip' length 3700068 bytes (3.5 MB)
	downloaded 3.5 MB

	package ‘permute’ successfully unpacked and MD5 sums checked
	package ‘vegan’ successfully unpacked and MD5 sums checked

	The downloaded binary packages are in
		C:\Users\cbird\AppData\Local\Temp\RtmpaKbQtZ\downloaded_packages
	>
	```

	Note that Rtools is required but not found, so I followed the instructions given above to install Rtools

2. Wrangle data into format compatible with vegan.

	For the species count data, each column is a taxon and each row is a unique site or observation

	We will use the count data from the `salvador` repo which is already here in this directory.  
	
	Open `data_wrangling_vis_salvador.R` in R studio and run lines 1-52
	
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

## ANALYSES

* [Ordination](ordination.md)

