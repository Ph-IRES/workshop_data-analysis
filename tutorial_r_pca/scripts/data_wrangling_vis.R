#### INITIALIZATION ####
library(rstudioapi)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(tidyverse)
library(janitor)
library(readxl)
# install.packages("devtools")
# library(devtools)
# install_github("vqv/ggbiplot")
library(ggbiplot)
# install.packages("missMDA")
library(missMDA)


#### USER DEFINED VARIABLES ####

inFilePath1 = "../data/Morphometric Measurements_New.xlsx"
sheet1 = "Geomorphometric Master List"
sheet2 = "Lai Ratios"
sheet3 = "data_all"
sheet4 = "Morphometric Master List"

# outFilePath = "./data_combined.tsv"

#### READ IN DATA & CURATE ####

data_geomorph_master <-
  read_excel(inFilePath1,
             sheet = sheet1,
             skip=1) %>% 
  clean_names() 

data_lai_ratios <-
  read_excel(inFilePath1,
             sheet = sheet2) %>%
  clean_names()

# some of these column names are a bit long.  I suggest abbreviating these names, and then making another sheet that provides the abbrviations and full descriptions
data_all <-
  read_excel(
    inFilePath1,
    sheet = sheet3,
    skip = 1
  ) %>%
  clean_names() 

data_morph_master <-
  read_excel(inFilePath1,
             sheet = sheet4,
             skip = 1) %>%
  janitor::clean_names() %>%
  # note, there was a conflict between ggbiplot and dplyr, both have "rename" command
  # because ggbiplot was loaded second, its rename command takes precidence, so we have to specify
  # that we want dplyr's rename command `dplyr::rename`
  dplyr::rename(
    carapace_width_1 = carapace_width_excluding_9th_anterior_lateral_tooth_cw1,
    carapace_width_2 = carapace_width_including_9th_anterior_lateral_tooth_cw2
  ) %>%
  # rather than calculating the ratios in excel and then manually merging them together, 
  # calculating them from the raw morph master list sheet will result in fewer errors
  mutate(cw1_cl = carapace_width_1 / carapace_length_cl,
         cw2_cl = carapace_width_2 / carapace_length_cl)

#### COMBINE DATA ####

# as an example, you could easily join the Lai Ratios to the morpho master list
# but I suggest calculating the ratios instead, as described above

data_all_joined <- 
  data_morph_master %>%
  select(-cw1_cl,
         -cw2_cl) %>%
  left_join(data_lai_ratios,
            by = c("code",
                   "baranguay"))

#### VISuALIZE ####

# lets view all of the ratios by site
data_lai_ratios %>%
  mutate(site = str_remove(code,
                           "[0-9]+$"),
         province = str_remove(baranguay,
                               "^.*, ")) %>%
  pivot_longer(cols = cw1_cl:pl_tw,
               names_to = "ratio") %>% 
  ggplot(aes(y=value)) +
  geom_boxplot() +
  theme_classic() +
  facet_grid(ratio ~ province + site,
             scales = "free_y")
ggsave("../output/boxplot_morphratio-x-site.png")

#### PCA ####
lai_ratio.pca <- 
  prcomp(data_lai_ratios %>%
           select(-code:-baranguay,
                  -mal_dal), 
         center = TRUE,
         scale. = TRUE)

summary(lai_ratio.pca)

ggbiplot(lai_ratio.pca) +
  theme_classic() +
  labs(title = "PC1 x PC2")

ggbiplot(lai_ratio.pca,
         labels = data_lai_ratios %>%
           pull(code)) +
  theme_classic() +
  labs(title = "PC1 x PC2",
       subtitle = "Labeled with ID #s")

ggbiplot(lai_ratio.pca,
         labels = data_lai_ratios %>%
           pull(code),
         ellipse = TRUE,
         groups = data_lai_ratios %>%
           mutate(province = str_remove(baranguay,
                                        "^.*, ")) %>%
           pull(province)) +
  theme_classic() +
  labs(title = "PC1 x PC2",
       subtitle = "Grouped by Province, With Ellipses")

ggbiplot(lai_ratio.pca,
         labels = data_lai_ratios %>%
           pull(code),
         ellipse = TRUE,
         groups = data_lai_ratios %>%
           mutate(province = str_remove(baranguay,
                                        "^.*, ")) %>%
           pull(province),
         choices = c(3,4)) +
  theme_classic() +
  labs(title = "PC3 x PC4",
       subtitle = "Grouped by Province, With Ellipses")

ggbiplot(lai_ratio.pca,
         labels = data_lai_ratios %>%
           pull(code),
         ellipse = TRUE,
         groups = data_lai_ratios %>%
           mutate(province = str_remove(baranguay,
                                        "^.*, ")) %>%
           pull(province),
         choices = c(3,4),
         var.axes = FALSE) +
  theme_classic() +
  labs(title = "PC3 x PC4",
       subtitle = "Grouped by Province, With Ellipses, Variables Removed")

#### Missing Data Imputation ####

data_lai_ratios_imputed <- 
  data_lai_ratios %>%
  dplyr::mutate(
    across(
      where(is.numeric), 
      ~replace(
        ., 
        is.na(.), 
        mean(., 
             na.rm=TRUE)
      )
    )
  )

data_lai_ratios_imputed


# Perform PCA
lai_ratio_imputed.pca <- 
  data_lai_ratios_imputed %>%
  select(-code, -baranguay) %>%
  prcomp(center = TRUE, scale. = TRUE)


summary(lai_ratio_imputed.pca)
summary(lai_ratio.pca)

ggbiplot(lai_ratio_imputed.pca,
         labels = data_lai_ratios %>%
           pull(code),
         ellipse = TRUE,
         groups = data_lai_ratios %>%
           mutate(province = str_remove(baranguay,
                                        "^.*, ")) %>%
           pull(province),
         choices = c(3,4),
         var.axes = FALSE) +
  theme_classic() +
  labs(title = "PC3 x PC4",
       subtitle = "Grouped by Province, With Ellipses, Variables Removed")


#### Missing value imputation for PCA ####


# Estimate the number of dimensions
nb <- 
  estim_ncpPCA(
    data_lai_ratios %>%
      select(-code:-baranguay)
  )

# Impute the missing values
lai_ratio_imputed_2 <- 
  imputePCA(data_lai_ratios %>%
              select(-code:-baranguay), 
            ncp = nb$ncp)

# Now use this data in your PCA
lai_ratio_imputed_2.pca <- 
  prcomp(lai_ratio_imputed_2$completeObs, 
         center = TRUE, 
         scale. = TRUE)

summary(lai_ratio_imputed_2.pca)
summary(lai_ratio.pca)
summary(lai_ratio_imputed.pca)

ggbiplot(lai_ratio_imputed_2.pca,
         labels = data_lai_ratios %>%
           pull(code),
         ellipse = TRUE,
         groups = data_lai_ratios %>%
           mutate(province = str_remove(baranguay,
                                        "^.*, ")) %>%
           pull(province),
         choices = c(3,4),
         var.axes = FALSE) +
  theme_classic() +
  labs(title = "PC3 x PC4",
       subtitle = "Grouped by Province, With Ellipses, Variables Removed")

