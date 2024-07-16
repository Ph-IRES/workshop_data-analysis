# Create a "Reference Genome Sequence" for `*.ab1` File Processing with UGENE

---

## Software Installation

[Download UGENE](http://ugene.net/download-all.html) and [Installation Instructions](https://doc.ugene.net/wiki/display/UM/Download+and+Installation)

   * Unzip the download, open the dir, double click file named `ugeneui`

---

## Download all the Mitochondrial Genome Sequences Similar to Your Target Species

We want to generate a reference sequence that we can map our Sanger sequences (`*.ab1` files) to.  This reference should be from species that are closely related so that there is a high similarity in sequence, but also represent a diversity of species. Therefore, we will create a consensus sequence from the mitochondrial genomes of several closely related species that starts at the first primer nucleotide on the 5' side of our amplicons and ends at the last 3' nucleotide. The best way to accomplish this is with NCBI Blast. 

1. Goto [NCBI Blast](https://blast.ncbi.nlm.nih.gov/Blast.cgi)

2. Copy and paste a FASTA file for the species of interest into the `Enter Query Sequence` box

   * you will have to use FinchTV to copy the Sequence
   * this is a `blastn` search

3. Expand the `Algorithm paramters` section and set `Max target sequences` to a number that returns more than just the genus of the species  you are blasting.

   * _Ischnura luta_ is 1000
   * Selecting `Distance tree of results` just above the output table (on the right) is useful for this

4. In the `Sequences producing significant alignments` table, uncheck `select all`.  Then `ctrl+f` and search the word "genome". Check each sequence that is a mitochondrial genome

5. Select the `Alignments` tab,  and note the beginning and end position of the mitogenoms (`Sbjct`) aligned to your query sequence.

   * Experiment with the different `Alignment view` options, 
   * and use `CDS feature` checkbox to identify records where genes have been annotated

6. Go back to `Descriptions` tab and uncheck any mitogenome without annotation.

   * optional, if there are a few genomes that are aligned (same beginning and end positions), you can select only those

7. Click the `GenBank` link just above the table, in the new window, click the `Send to:`/ `Coding Sequences` / `FASTA Nucleotide` then click `Create File`

	* Move the file to `prj_rotablue_barcoding/output` and 
	* name it `prj_rotablue_barcoding/output/blast-rbd_02_E1_LCOI-1000-mitogenomes-codingseqs.fasta`, where 
	   * `rbd_02_E1_LCOI` is the name of the query sequence (it's ok to use another query seq)  
	   * `1000` is the number of `Max target sequences`

---

## Use UGENE to Generate a Consensus Sequence of Just the Amplicon Region 

Now that we have the sequences needed to make the consensus, we have to process them to create the consensus sequence that can serve as our "reference" when mapping our `*.ab1` files.

0. In UGENE open (or create) a project named `prj_rotablue_barcoding/output/rotablue_barcoding_blast_mitogenomes_ORGANISMNAMEHERE.uprj`

1. Use UGENE to open the `prj_rotablue_barcoding/output/blast-*-mitogenomes-codingseqs.fasta` file

   * `As separate sequences...`
   
2. Select the sequences in the `Objects` panel with cytochrome c oxidase 1 (COI, CO1, COX1), then export them as a FASTA file

   * name it `prj_rotablue_barcoding/output/blast-rbd_02_E1_LCOI-1000-mitogenomes-codingseqs-coi.fasta`
   * don't save the file to the project
   
3. Use UGENE to open the `blast-*-mitogenomes-codingseqs-coi.fasta` file

4. Align the sequences

   This can be accomplished several ways:
   
   * manually edit the Alignment
   * Use `Tools/Multiple Sequence Alignment`
   * Use `Sanger data analysis/Map reads to reference`
   
5. Search the alignment for the priming position of the primers ([Folmer 1994](https://www.mbari.org/wp-content/uploads/2016/01/Folmer_94MMBB.pdf), LCO1490, HCO2198) and trim the sequence outside of the amplicon region.

    For your reference, the primer sequences should be saved in prj_rotablue_barcoding/data/primers.fasta

    The sequence at the end of the LCO files is HCO2198:

        * TGATTTTTTGGTCACCCTGAAGTTTA

    The sequence at the end of the HCO files is the reverse compliment of LCO1490:

        * CCAATATCTTTATGATTTGTTGACC

   * `right-click: Navigation/Search in sequences`
   * `Search context: Sequences`
   * Copy and paste a primer seq into the `Search pattern:`
   * `Algorithm: InsDel`
   * Adjust `Should match:` value downwards until there is 1 match per sequence in the alignment
   * click `Next` to goto each matching region.
   * Select and delete the sequence before the fwd primer (LCO1490) and after the rev primer (HCO2198)
   
6. Copy the consensus sequence and paste into a fasta file

   * create file with notepad ++ or bbedit, `prj_rotablue_barcoding/output/blast-rbd_02_E1_LCOI-coi-consensus_reference.fasta`
   * name sequence: `>consensus_coi_folmer`
   * to get the simpple majority consensus,
       * open the consensus tab,
       * select one of the sequences to be the reference,
       * select Levitsky,
       * and change threshold to 50%
      * `Right-click` the alignment then, `Copy/paste / Copy Consensus`
   
This file can be used to map fwd and rev `*.ab1` sequences in UGENE
