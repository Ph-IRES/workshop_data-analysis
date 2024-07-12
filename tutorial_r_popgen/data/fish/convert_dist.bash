#!/bin/bash

sed 's/\([0-9]$\)/\1\nPop/g;
	s/^.*HR0[0-9]_UP,/0,/g;
	s/^.*HR0[0-9]_DN,/100,/g;
	s/^.*HR0[0-9]_scale_.,/100,/g;
	s/^.*DB.*,/285,/g;
	s/^.*HB.*,/380,/g;
	s/^.*PR.*,/490,/g;
	s/^.*RR.*,/540,/g;
	s/^.*YR.*,/580,/g;
	s/^.*JR.*,/610,/g;
	s/^.*NC.*_BW,/720,/g;
	s/^.*NC.*_EB,/750,/g;
	s/^.*SC.*,/1220,/g' SBmicro_pops.txt > SBmicro_pops_dist.txt

sed -i.bk '/POP/d' SBmicro_pops_dist.txt
