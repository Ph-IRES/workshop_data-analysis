# How to trim the primers from ab1 files

After receiving sequence files, we need to trim the sequence matching the primers at the end of the files.

This can be a bit tricky because the orientation of reference genomes and sequences are not always the same.

---

## Software Installation

[Download FinchTV](https://digitalworldbiology.com/FinchTV) or [Download Chromas](https://technelysium.com.au/wp/chromas/)

   * double click the download, follow instructions

---

## 1. Find the original primer sequence

Some of the primers are listed in the [primers.fasta](https://github.com/tamucc-gcl/prj_rotablue_barcoding/blob/main/data/primers.fasta) file. 
If you don't see your primer there, check the [rbdf_Primers_coa_2024-03-06](https://tamucc-my.sharepoint.com/:x:/r/personal/chris_bird_tamucc_edu/_layouts/15/guestaccess.aspx?share=EbJqa9SiJDxMsdDO2VRDEsABBOdXy8YYheWYAQoxR3FKvw)

Note the forward and reverse sequence

For example:

LCO1490(forward)	GGTCAACAAATCATAAAGATATTGG

HCO2198(reverse)	TGATTTTTTGGTCACCCTGAAGTTTA

16SF			TTACGCTGTTATCCCTAA

16SAR			CGCCTGTTTATCAAAAACAT

If you can't find your primer contact Sharon, Kevin, and/or Chris.

---

## 2. Get the reverse and and reverse-complement sequences.


16S example:

| feature | sequence|
| ---|---|
|forward primer	|	TTACGCTGTTATCCCTAA |
| reverse	|	AATCCCTATTGTCGCATT |
| reverse-complement | TTAGGGATAACAGCGTAA |
| reverse primer |CGCCTGTTTATCAAAAACAT |
| reverse	| TACAAAAACTATTTGTCCGC |
| reverse-complement | ATGTTTTTGATAAACAGGCG|

Here is an online tool for getting the reverse and reverse-complement [Reverse Complement](https://www.bioinformatics.org/sms/rev_comp.html). 
*Paste your sequence and select the option you want.*

Also, if you have terminal in your computer, the reverse can easily be done with 
```
echo <sequence> | rev

16S example
echo “CGCCTGTTTATCAAAAACAT” | rev
TACAAAAACTATTTGTCCGC
```
then you can manually create the complement: ATGTTTTTGATAAACAGGCG

---

## 3. Find and remove primers

With all the posible options at hand, you are now ready to search and trim the primers from your sequences

**Open your ab1 file with FinchTV**

***If the orientation are as expected, then (try this first):***

At the end of the the Forward files,  search for the reserve primer and delete this sequence.

At the end of the the reverse files,  search for the reserve-complement of the reverse primer , delete this sequence.

CO1 example
* LCO file look for TGATTTTTTGGTCACCCTGAAGTTTA
* HCO file look for GGTCAACAAATCATAAAGATATTGG

Note: there might be some sequencing mistakes at the actual primer site meaning that sometimes 
you won't find the exact complete primer sequence. If you don't get a match with the full sequence,
then you can search for a chunck of the sequence, say a third of the sequence. 

For instance, in the LCO files, you might be able to find
TGATTTTTT, if the full sequence is not there

***If files have different orientations are as expected, then:***

In other words, if the above didn't work for you then...

You might have to search for the original and/or the reverse-complement in forward file or in both, as supposed to only in the reverse file

**TIP:** If you are not sure if you have found a primer (perhaps it has many mistakes), you can map the file to the reference genome using UGENE. *Instructions for mapping files to the references are [here](https://github.com/tamucc-gcl/prj_rotablue_barcoding/blob/main/scripts/howto_edit_ab1.md)*

You will now be able to see the end of the sequence next to the reference genome. 
The reference sequence will likely have the full primer sequence allowing to visualize sequencing mistakes in the ab1 file(s) and easily locate the primer sequence to remove. ***See 16S example below for illustration***

**16S EXEAMPLE**

For 16S, the orientation of the files made it so that we had to search for the reserve-complement in both the forward and reverse files

Original 16S primer sequences:

* 16SF	TTACGCTGTTATCCCTAA

* 16SAR	CGCCTGTTTATCAAAAACAT

At the end of the the Forward files (16SF),  search for the reverse-complement of the reserve primer:

reverse primer				  CGCCTGTTTATCAAAAACAT

reverse						      TACAAAAACTATTTGTCCGC

reverse-complement			ATGTTTTTGATAAACAGGCG (this one)

At the end of the reverse files (16SAR), search for the reverse-complement of the forward primer

forward primer				  TTACGCTGTTATCCCTAA

reverse						      AATCCCTATTGTCGCATT

reverse-complement			TTAGGGATAACAGCGTAA (this one)

In individual rbd_04, there were enough mistakes and extra bases after the primer sequence that made it hard to pin down the exact primer location.

Thus, I mapped the forward and reverse rbd_04 files to the 16S reference. 
There, I was able to identify the primer and see the mistakes and extra bases, and then remove the primer and all extra bases after as well ("CGA" in this example).

Note that I had to reverse-complement the reverse file in FinchTV in order to show me the same orientation as in UGENE.
*This is done by clicking the button with an backwards arrow "Reverse Complement"*

![Screen Shot 2024-04-19 at 5 52 04 PM](https://github.com/tamucc-gcl/prj_rotablue_barcoding/assets/40210956/df1a2d57-aca1-4af0-8dd5-3e58b89a1492)
