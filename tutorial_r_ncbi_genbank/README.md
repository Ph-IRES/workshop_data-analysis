# TUTORIAL: QUERYING NCBI GENBANK WITH R

NCBI is

---

---

---

## Querying NCBI GenBank using R

### Step 1: Install the necessary packages

The first step is to install the necessary packages that you will need to access NCBI GenBank and perform queries using R. The two main packages that you will need are rentrez and seqinr. You can install them by running the following code in your R console:

```r
install.packages("rentrez")
install.packages("seqinr")
```

### Step 2: Load the necessary packages

Once you have installed the packages, you need to load them into your R session using the following code:

```r

library(rentrez)
library(seqinr)
```

### Step 3: Construct a search query

The next step is to construct a search query that will retrieve the sequence data you are interested in. You can use the entrez_search function from the rentrez package to do this. For example, if you want to search for all sequences from the species Homo sapiens with the keyword "insulin", you can use the following code:

```r

search_query <- entrez_search(db = "nucleotide", term = "Homo sapiens[orgn] AND insulin")
```

### Step 4: Retrieve the IDs of the search results

Once you have constructed your search query, you can use the search_query$ids command to retrieve the IDs of the search results. For example:

```r

search_results <- entrez_search(db = "nucleotide", term = "Homo sapiens[orgn] AND insulin")
ids <- search_results$ids
```

### Step 5: Retrieve the sequence data

Finally, you can use the entrez_fetch function from the rentrez package to retrieve the sequence data for the IDs you are interested in. For example, to retrieve the sequence data for the first 10 IDs, you can use the following code:

```r

sequences <- entrez_fetch(db = "nucleotide", id = ids[1:10], rettype = "fasta")
```

### Step 6: Analyze the sequence data

Once you have retrieved the sequence data, you can analyze it using the various functions provided by the seqinr package. For example, to compute the GC content of the sequences, you can use the following code:

```r

gc_content <- sapply(read.fasta(textConnection(sequences)), GC)
```

This will compute the GC content for each of the sequences and store the results in a vector called gc_content.