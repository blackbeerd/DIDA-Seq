#!/bin/bash
#set -o errexit
#set -o pipefail

if [ $# -eq 0 ]; then
echo >&2 "
$(basename $0) - Trimming first three and last three bases off of each read
USAGE: $(basename $0) 
-i    input bam file                                           
-o    output trimmed bam file
-r    raw file to determine readlength
"
exit 1
fi

while getopts "i:o:r:" op
do
    case "$op" in
        i)  input="$OPTARG";;
        o)  output="$OPTARG";;
        r)  raw="$OPTARG";;
        \?) exit 1;;
    esac
done

rl=$( cat $raw | head -4 | paste - - - - | awk '{print $2}' | wc -m )
readlength=$( echo "$rl - 1" | bc )
end_trim=$( echo "$readlength - 2" | bc )
trim_parameter=$( echo "1-3,"$end_trim"-"$readlength )

gatk ClipReads --input $input --output $output -CT "$trim_parameter"

exit 0
