#!/bin/bash

# this script will take a text file with records in genbank full format and extract the unique genes

# Example:
# bash unique_genes.bash downloads/portunus_pelagicus.gb output/portunus_pelagicus_unique_genes.txt


genbankRECORDS=$1
# genbankRECORDS=downloads/portunus_pelagicus.gb
outFILE=$2
# outFILE=output/portunus_pelagicus_unique_genes.txt

grep "/gene=" $genbankRECORDS | \
 sed 's/\s*\/gene=//g' | \
 sed 's/\"//g' | \
 sort | \
 uniq -c | \
 sed 's/^\s*//' \
 > $outFILE