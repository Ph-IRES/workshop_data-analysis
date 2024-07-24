 cat blast_rbd_06_E1_500.fasta | sed 's/^\(>.*$\)/\1@@@@/' |tr "\n" "\t" | sed 's/@@@@/\n/g' | sed 's/>/\n>/' | sed 's/\t//g' | tail -n+2 | paste - - | grep -v "Query" | ./parse_blast.awk > blast_rbd_06_E1_500.tsv
 
 cat blast_rbd_06_E1_500.fasta | sed 's/^\(>.*$\)/\1@@@@/' |tr "\n" "\t" | sed 's/@@@@/\n/g' | sed 's/>/\n>/' | sed 's/\t//g' | tail -n+2 | paste - - | grep -v "Query" | sed "s/\([A-Za-z:,'0-9\.]\) \([A-Za-z:,'0-9\.]\)/\1_\2/g" | ./parse_blast.awk > blast_rbd_06_E1_500.tsv
 
 
 # process fasta file from blast search to tidy format
 cat blast_rbd_06_E1_500.fasta | \
	sed 's/^\(>.*$\)/\1@@@@/' | \
	tr "\n" "\t" | \
	sed 's/@@@@/\n/g' | \
	sed 's/>/\n>/' | \
	sed 's/\t//g' | \
	tail -n+2 | \
	paste - - | \
	grep -v "Query" | \
	sed "s/\([A-Za-z:,'0-9\.]\)\s\s*\([A-Za-z:,'0-9\.]\)/\1_\2/g" | \
	sed "s/\([A-Za-z:,'0-9\.]\)\s\s*\([A-Za-z:,'0-9\.]\)/\1,\2/g" | \
	./parse_blast.awk | \
	sed -e 's/^gb//' \
		-e 's/^ref//' \
		-e 's/^dbj//' \
		-e 's/^emb//' > blast_rbd_06_E1_500_better.tsv