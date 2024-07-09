##Reads .fasta alignment and determines unique haplotypes
#Requires an aligned and end-trimmed .fasta file
#alignments must begin and terminate at same point for all sequences.  
#longer or shorter sequences will be interpreted as unique haplotypes regardless of internal sequence!
#returns a multifasta file of unique haplotypes
#using goby_seqs.fasta as example here.  In go 64 sequences, out come 38 deduplicated "haplotypes"

if (!require("haplotypes")) install.packages("haplotypes")
if (!require("ape")) install.packages("ape")
library(haplotypes)
library(ape)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

#reads in data.  

alignment<-haplotypes::read.fas(file="goby_seqs.fasta")

#generates haplotype files#
#selection of indel treatment is rather important here.  Most predictable is to set them as a 5th character state
haps<-haplotype(alignment, indels="5th")

#some file format contortions...
haps.dna <- as.dna(haps)
haps.dnabin <- haplotypes::as.DNAbin(haps.dna)

#and using ape::write.dna for the output file
write.dna(haps.dnabin, file = 'goby_uniques_haplotypes.fasta', format = 'fasta' )

