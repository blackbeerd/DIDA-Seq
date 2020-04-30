#!/bin/bash

mkdir samples/undefined
mv samples/demultiplexed/*/undef* samples/undefined

for i in samples/demultiplexed/*/*_R1.fastq; do cat $i | sed -e 's/ R1 UMI:/|/' -e 's/:JJJJJJJJ/ /' | paste - - - - | awk '{OFS="\n"; print $1, substr($2,17,149),$3,substr($4,17,149)}' > $i.smi; done 

for i in samples/demultiplexed/*/*_R2.fastq; do cat $i | sed -e 's/ R2 UMI:/|/' -e 's/:JJJJJJJJ/ /' | paste - - - - | awk '{OFS="\n"; print $1, substr($2,17,149),$3,substr($4,17,149)}' > $i.smi; done

mv samples/demultiplexed/*/*fastq.smi samples/demultiplexed

echo "complete" > samples/demultiplexed/smi_complete.txt
