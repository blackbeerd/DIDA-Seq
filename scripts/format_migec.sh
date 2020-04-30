#!/bin/bash
#set -o errexit
#set -o pipefail

if [ $# -eq 0 ]; then
echo >&2 "
$(basename $0) - Adding string to fastq file to format it for migec demultiplexing step
USAGE: $(basename $0) -f <FASTQ file R1> -r <FASTQ file R2> [OPTIONS]
-f    FASTQ file(s) read 1                                                        [required]
-r    FASTQ file read 2                                                   [required]
-F    output name read 1
-R    output name read 2
"
exit 1
fi

while getopts "f:r:F:R:" op
do
    case "$op" in
        f)  fwd="$OPTARG";;
        r)  rev="$OPTARG";;
        F)  outFWD="$OPTARG";;
        R)  outREV="$OPTARG";;
        \?) exit 1;;
    esac
done

cat "$rev" | paste - - - - | awk '{OFS="\n"; print $1, substr($2,7,8)substr($2,16,8)$3,$4,"JJJJJJJJJJJJJJJJ"$5}' > "$outREV"

cat "$fwd" | paste - - - - | awk '{OFS="\n"; print $1, substr($2,7,8)substr($2,16,8)$3,$4,"JJJJJJJJJJJJJJJJ"$5}' > "$outFWD"

exit 0
