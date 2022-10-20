rm(list=ls())

#install.packages("tidyverse")
library("tidyverse")

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

#### Reading in data ####
fastqc_tbl <- read_tsv("fastqc_data.tsv")
read_delim("fastqc_data.tsv", 
           delim = "\t")


#### Subsetting Your Data ####

fastqc_tbl %>%
  select(id,
         total_sequences)

fastqc_tbl %>%
  select(-starts_with("percent"))

fastqc_tbl %>%
  filter(total_sequences >= 50000000)

fastqc_tbl %>%
  filter(percent_gc_content == 44 | percent_gc_content == 45,
         total_sequences <= 50000000 & total_sequences >= 30000000)

fastqc_tbl %>%
  filter(total_sequences >= 50000000) %>%
  select(id, 
         percent_duplication)

#### Changing and Creating Columns ####
fastqc_tbl %>% 
  mutate(log_total_sequences = log10(total_sequences)) 

fastqc_tbl %>% 
  mutate(percent_duplication = percent_duplication/100) 

fastqc_tbl %>%
  mutate(percent_duplication_as_decimal = percent_duplication/100,
         number_of_nonduplicate_sequences = percent_duplication_as_decimal * total_sequences,
         number_of_duplicated_sequences = (1 - percent_duplication_as_decimal) * total_sequences) %>%
  select(id,
         total_sequences,
         number_of_nonduplicate_sequences,
         number_of_duplicated_sequences)

fastqc_tbl %>%
  mutate(gc_interpretation = case_when(percent_gc_content < 45 ~ "Less than 40% GC Content",
                                       percent_gc_content > 50 ~ "Greater then 50% GC Content",
                                       TRUE ~ "Inbetween 40 and 50% GC Content")) %>%
  select(id,
         gc_interpretation)

(fastqc_tbl_separate <- fastqc_tbl %>%
    separate(id,
             into = c("wga",
                      "species",
                      "repair",
                      "ng_dna"),
             sep = "_"))

(fastqc_tbl_unite <- fastqc_tbl_separate %>%
    relocate(species, 
             ng_dna,
             repair,
             wga) %>%
    unite("id", 
          species:wga,
          sep = "-"))

#### Summarising a Tibble ####

fastqc_tbl_separate %>%
  group_by(species) %>%
  summarise(number_of_observations = n()) %>%
  ungroup()

fastqc_tbl_separate %>%
  group_by(wga, ng_dna) %>%
  summarise(number_of_observations = n(),
            mean_failed_percent = mean(percent_failed),
            median_failed_percent = median(percent_failed),
            mean_duplicate_percent = mean(total_sequences),
            median_duplicate_percent = median(total_sequences),
            mean_number_of_nonduplicate_sequences = mean((1-(percent_duplication/100)) * total_sequences)) %>%
  ungroup()



