# DNA Barcoding Tutorial: Curating Sanger (`*.ab1`) Sequence Data

In the tutorial, we will learn how to use free software tools to manually edit your DNA sequence files (`*.ab1`).

It is necessary to edit raw data files from Sanger sequencing because the machine makes mistakes in calling nucleotides and human eyes can be used to correct these machine errors.

This repository is modeled after an actual repository that follows the principles of data organization and mgmt taught in this workshop. Consequently, the sequence data is located in the `data` dir.  The instructions on how to process the data are in the `scripts` dir.  

Because the curation of Sanger sequencing data is a rare exception to the data science philosophy, where all changes to files are documented in code, we provide a protocol in the scripts that describes how the raw data files should be edited.

Because we will be editing the raw data files, and we don't want to alter the raw data files, we will make a copy of the raw data files in the `output` dir and edit those.  This way, it is possible to evaluate how the sequences were altered.

Proceed to the [scripts dir](./scripts) to start the tutorial.
