#### INITIALIZE ####
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

#### USER DEFINED VARIABLES ####
library(pegas)
source("functions_sanger.R")
# https://github.com/Ph-IRES/phylogenetic_tools
source("../../../phylogenetic_tools/phylogeny_functions.R")

#### Make Consensus Seqs from Fwd-Rev Curated AB1 ####
processCuratedAB1(
    ab1_dir = "../output/sanger_curated_ab1_ischnura_luta/",
    out_file = "../output/sanger_curated_ab1_ischnura_luta/ischnura_luta_coi_consensus_sequences.fasta"
  )

#### Update GenBank Fasta Seq Names ####
renameBlastFastaSeqs(
  inTsvFile = "../output/sanger_curated_ab1_ischnura_luta/blast_rbd_06_E1_500_better.tsv",
  inFastaFile = "../output/sanger_curated_ab1_ischnura_luta/blast_rbd_06_E1_500.fasta",
  outFastaFile = "../output/sanger_curated_ab1_ischnura_luta/blast_rbd_06_E1_500_renamed.fasta"
)

#### Concat Fastas, Deduplicate Haplotypes, Align ####
concatFastas(
  inFilePaths = c("../output/sanger_curated_ab1_ischnura_luta/ischnura_luta_coi_consensus_sequences.fasta",
                  "../output/sanger_curated_ab1_ischnura_luta/blast_rbd_06_E1_500_renamed.fasta"),
  outFilePath = "../output/sanger_curated_ab1_ischnura_luta/ischnura_luta_coi.fasta"
)

uniqueSeqsFastaFile(
  inFilePath = "../output/sanger_curated_ab1_ischnura_luta/ischnura_luta_coi.fasta",
  outFilePath = "../output/sanger_curated_ab1_ischnura_luta/ischnura_luta_coi_haps.fasta"
)

fasta <-
  alignFastaFile(
    inFilePath = "../output/sanger_curated_ab1_ischnura_luta/ischnura_luta_coi_haps.fasta",
    outFilePath = "../output/sanger_curated_ab1_ischnura_luta/ischnura_luta_coi_haps_aligned.fasta"
  )

#### MAXIMUM LIKELIHOOD PHYLOGENY ####

tree <-
  fasta %>%
  fasta2tree(
    # my_outgroup = "HQ875717"
    my_outgroup = "OR653522"
    # my_outgroup = "AURORA"
  )

saveNewickTree(tree, 
               "../output/sanger_curated_ab1_ischnura_luta/tree_ischnura_luta_500_renamed.nwk")

#### PLOT TREE ####
tree %>%
  plotGgTree(
    threshold_bootstraps = 50,
    tip_color = "red", 
    tip_pattern = "^rbd",
    show_node_id = FALSE
  )

#### PLOT HAPLOTYPE NETWORK ####

sequences <- read.dna(file ="../output/sanger_curated_ab1_ischnura_luta/rbd_sequences_nooutgroup.fasta", format = "fasta")
haplo_data <- haplotype(sequences)
haplo_div <- hap.div(haplo_data)

hap_net <- haploNet(haplo_data)
plot(hap_net, size = attr(hap_net, "freq"), label = TRUE)
text(x = -3, y = -2, labels = paste("Hapl. Div.:", round(haplo_div, 2)), pos = 2)


# num_haplotypes <- length(attr(haplo_data, "index"))
# colors <- rainbow(num_haplotypes)
# plot(hap_net, size = attr(hap_net, "freq"), label = TRUE, col = colors)
# 
# greyscales <- gray(seq(0.2, 0.9, length.out = num_haplotypes))
# plot(hap_net, size = attr(hap_net, "freq"), label = TRUE, bg = greyscales)