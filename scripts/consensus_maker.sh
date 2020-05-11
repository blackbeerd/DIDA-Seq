#!/bin/bash
#set -o errexit
#set -o pipefail

if [ $# -eq 0 ]; then
echo >&2 "
$(basename $0) - Adding string to fastq file to format it for migec demultiplexing step
USAGE: $(basename $0) 
-s    python script to run                                         
-i    input bam file                                           
-t    output tagcounts file
-o    output consensus file
-m    minimum processors usef
-c    minimum gd cutoff
-N    gd N cutoff
-r    raw file to determine readlength
"
exit 1
fi

while getopts "s:i:t:o:m:c:N:r:" op
do
    case "$op" in
        s)  script="$OPTARG";;
        i)  input="$OPTARG";;
        t)  tagcounts="$OPTARG";;
        o)  output="$OPTARG";;
        m)  min="$OPTARG";;
        c)  gd_cutoff="$OPTARG";;
        N)  gd_Ncutoff="$OPTARG";;
        r)  raw="$OPTARG";;
        \?) exit 1;;
    esac
done

rl=$( cat $raw | head -4 | paste - - - - | awk '{print $2}' | wc -m )
readlength=$( echo "$rl - 1" | bc )

python $script --infile $input --tagfile $tagcounts --outfile $output --min $min --max 1000 --cutoff $gd_cutoff --Ncutoff $gd_Ncutoff --readlength $readlength --read_type dpm --filt n --tag_type gd


exit 0
