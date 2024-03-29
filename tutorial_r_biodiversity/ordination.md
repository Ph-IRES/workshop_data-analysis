# ORDINATION

We are following the [Vegan: an introduction to ordination](https://cloud.r-project.org/web/packages/vegan/vignettes/intro-vegan.pdf) vignette, but replacing the `dune` data set with `data_vegan` from the `salvador` repo.

You can consult the [`vegan` manual](https://cloud.r-project.org/web/packages/vegan/vegan.pdf) where the vignette does not go into enough depth.

Note that `vegan` is not `tidyverse` compatible, meaning that its functions are meant to be used with `base R` commands. If you want to use `ggplot`, you will have to harness the vegan output yourself, which really is not very difficult.  Just realize that the `plot` command is not `ggplot` and not compatible with `ggplot`. We do show how to use the `ggvegan` package to visualize an NMDS plot, but ymmv with `ggvegan`.


---

## Getting Started: Wrangle data into format compatible with vegan.

For the species count data, each column is a taxon and each row is a unique site or observation

We will use the count data from the `salvador` repo which is already here in this directory.  

Open `data_wrangling_vis_salvador_ordination.R` in R studio and run lines 1-128

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


## ORDINATION: Detrended correspondence analysis (DCA)

```r
ord <- decorana(data_vegan)
ord
summary(ord)
#boring plot
plot(ord)
```
	
![](Rplot.png)
The symbols represent the sites (black circles) and the taxa (red +)

```r
#fancier plot
plot(ord, type = "n")
points(ord, display = "sites", cex = 0.8, pch=21, col="black", bg="yellow")
text(ord, display = "spec", cex=0.7, col="red")
```

![](Rplot01.png)
The sites are black circles and the taxa are spelled out in red.

```r
#fanciest plot
plot(ord, disp="sites", type="n")
ordihull(ord, habitat, col=1:2, lwd=3)
ordiellipse(ord, habitat, col=1:2, kind = "ehull", lwd=3)
ordiellipse(ord, habitat, col=1:2, draw="polygon")
points(ord, disp="sites", pch=21, col=1:2, bg="yellow", cex=1.3)
ordispider(ord, habitat, col=1:2, label = TRUE)
```

![](Rplot02.png)
Color coded by habitat, where deep reef is black and shallow reef is red.

---

### ORDINATION: Plotting with ggplot instead of base R

# follow the ggvegan installation instructions here https://gavinsimpson.github.io/ggvegan/

ggord <- 
  fortify(ord) %>% 
  tibble() %>% 
  clean_names() %>%
  filter(score == "sites") %>% 
  bind_cols(tibble(data_vegan.env)) %>% 
  clean_names()

ggord %>%
  ggplot(aes(x = nmds1,
             y= nmds2,
             color = site_code,
             shape = habitat)) +
  geom_point(size = 5) +
  theme_classic()



---

### ORDINATION: Non-metric multidimensional scaling

```r
ord <- metaMDS(data_vegan)
ord
summary(ord)
#fanciest plot
plot(ord, disp="sites", type="n")
ordihull(ord, habitat, col=1:2, lwd=3)
ordiellipse(ord, habitat, col=1:2, kind = "ehull", lwd=3)
ordiellipse(ord, habitat, col=1:2, draw="polygon")
points(ord, disp="sites", pch=21, col=1:2, bg="yellow", cex=1.3)
ordispider(ord, habitat, col=1:2, label = TRUE)
```

![](Rplot03.png)

---

### ORDINATION: Fitting Environmental Variables

Let us test for an effect of site and depth on the NMDS

```r
ord.fit <- 
  envfit(ord ~ depth_m + site + bait_type, 
         data=data_vegan.env, 
         perm=999,
         na.rm = TRUE)
ord.fit
plot(ord, dis="site")
ordiellipse(ord, site, col=1:4, kind = "ehull", lwd=3)
plot(ord.fit)
```

![](Rplot04.png)
Ellipses represent the sites.

Add the fitted surface for depth to the ordination plot

```r
ordisurf(ord, depth_m, add=TRUE)

```

![](Rplot05.png)

---

### ORDINATION: Constrained Ordination

Example with CCA, constrained or “canonical” correspondence analysis

```r
ord <- cca(data_vegan ~ depth_m + site , data=data_vegan.env)
ord
plot(ord, dis="site")
points(ord, disp="site", pch=21, col=1:2, bg="yellow", cex=1.3)
ordiellipse(ord, site, col=1:4, kind = "ehull", lwd=3)
```

---

### ORDINATION: Constrained Ordination Significance Tests

```r
anova(ord)
```
	Permutation test for cca under reduced model
	Permutation: free
	Number of permutations: 999

	Model: cca(formula = data_vegan ~ depth_m + site, data = data_vegan.env)
			 Df ChiSquare      F Pr(>F)    
	Model     4    1.2457 1.6115  0.001 ***
	Residual 60   11.5946                  
	---
	Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

```r
anova(ord, by="term", permutations=999)
```
	Permutation test for cca under reduced model
	Terms added sequentially (first to last)
	Permutation: free
	Number of permutations: 999

	Model: cca(formula = data_vegan ~ depth_m + site, data = data_vegan.env)
			 Df ChiSquare      F Pr(>F)   
	depth_m   1    0.3114 1.6114  0.002 **
	site      3    0.9343 1.6116  0.002 **
	Residual 60   11.5946                 
	---
	Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

```r
anova(ord, by="mar", permutations=999)
```
	Permutation test for cca under reduced model
	Marginal effects of terms
	Permutation: free
	Number of permutations: 999

	Model: cca(formula = data_vegan ~ depth_m + site, data = data_vegan.env)
			 Df ChiSquare      F Pr(>F)    
	depth_m   1    0.1831 0.9476  0.575    
	site      3    0.9343 1.6116  0.001 ***
	Residual 60   11.5946                  
	---
	Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

```r
anova(ord, by="axis", permutations=999)
```
	Permutation test for cca under reduced model
	Forward tests for axes
	Permutation: free
	Number of permutations: 999

	Model: cca(formula = data_vegan ~ depth_m + site, data = data_vegan.env)
			 Df ChiSquare      F Pr(>F)    
	CCA1      1    0.5233 2.7080  0.001 ***
	CCA2      1    0.3428 1.7740  0.042 *  
	CCA3      1    0.2374 1.2287  0.411    
	CCA4      1    0.1421 0.7354  0.931    
	Residual 60   11.5946                  
	---
	Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

---

### ORDINATION: Conditioned or partial ordination

If there are covariates that we are not interested in testing the effect of, but we want to account for their impact on the response variables, we can partial out these covariates 

```r
ord <- cca(data_vegan ~ depth_m + site + Condition(bait_type), 
           data=data_vegan.env)
anova(ord, by="term", permutations=999)
```

	Permutation test for cca under reduced model
	Terms added sequentially (first to last)
	Permutation: free
	Number of permutations: 999

	Model: cca(formula = data_vegan ~ depth_m + site + Condition(bait_type), data = data_vegan.env)
			 Df ChiSquare      F Pr(>F)   
	depth_m   1    0.1778 0.9359  0.586   
	site      2    0.7661 2.0168  0.002 **
	Residual 55   10.4467                 
	---
	Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

