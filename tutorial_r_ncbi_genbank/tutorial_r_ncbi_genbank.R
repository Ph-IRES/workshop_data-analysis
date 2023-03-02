
#### Setup ####
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

#### Steps 1-2: PACKAGES ####

# this code checks to see if you have the packages and if not, it installs them then loads them using require() instead of library
packages_used <- 
  c("rentrez",
    "seqinr",
    "XML",
    "ape",
    "tidyverse")

packages_to_install <- 
  packages_used[!packages_used %in% installed.packages()[,1]]

if (length(packages_to_install) > 0) {
  install.packages(packages_to_install, 
                   Ncpus = Sys.getenv("NUMBER_OF_PROCESSORS") - 1)
}

lapply(packages_used, 
       require, 
       character.only = TRUE)

#### Steps 3-6  ####

search_results <- 
  entrez_search(
    db = "nucleotide", 
    term = "Portunus pelagicus[orgn]",
    retmax = 10000,
    # rettype = "xml",
    # parsed = TRUE
  )

ids <- search_results$ids

entrez_summary(
  db = "nucleotide", 
  id = ids, 
  web_history = 
) %>%
  extract_from_esummary("gene")

gc_content <- sapply(read.fasta(textConnection(sequences)), GC)



entrez_fetch(
  db = "nucleotide", 
  id = ids[1:10], 
  rettype = "genbank"
)


####  ####


# Set the search term and database to use
search_term <- "Portunus pelagicus[Organism]"

database <- "nucleotide"

# Use Entrez.esearch to retrieve the list of IDs for the search results
search_results <- 
  entrez_search(db = database, 
                term = search_term, 
                use_history = TRUE)

# Use the WebEnv and QueryKey values from the search_results to retrieve the data
data <- 
  entrez_fetch(db = database, 
               webenv = search_results$web_history[1], 
               # query_key = search_results$web_history[2], 
               rettype = "gb")

# Parse the data using the read.genbank function from the seqinr package
genes <- read.genbank(textConnection(data))

# Print the summary of the genes
summary(genes)

