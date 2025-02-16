# BIODIVERSITY ANALYSES

## R Packages for Biodiversity Analyses

* [vegan](https://cloud.r-project.org/web/packages/vegan/index.html)
* [BiodiversityR](https://rdrr.io/cran/BiodiversityR/)
* [adiv](https://besjournals.onlinelibrary.wiley.com/doi/epdf/10.1111/2041-210X.13430)
* [iNext](https://cran.r-project.org/web/packages/iNEXT/index.html)

---

## Getting Started: Install `vegan` and any necessary dependencies 

```r
install.packages("vegan")
```

Note that Rtools is required but not found, so I followed the instructions given below to install Rtools

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


---

## ANALYSES

* [Ordination](ordination.md)
	* dimensional reduction of data, visualize differences among observations with many dimensions of info
	* morphometrics, biodiversity, genetics
* [PERMANOVA](permanova.md)
	* test for differences in species composition or genetic composition or morpho-composition
	* can be coaxed to do analysis of molecular variance, AMOVA (Excoffier et al 1992)
* [Species Richness, Rarefaction & Species Accumulation Curves](rarefactionS.md)
	* 

---

## Other Tutorials

* https://www.mooreecology.com/uploads/2/4/2/1/24213970/vegantutor.pdf
* http://www.kembellab.ca/r-workshop/biodivR/SK_Biodiversity_R.html
* https://peat-clark.github.io/BIO381/veganTutorial.html

