#! /bin/bash

#set -x

echo "killall -w -s 9 /oplashare/data/mfalchi/GeneROOT/script/BAM2fastq/run_bamToFastq.sh"
killall -w -s 9 /oplashare/data/mfalchi/GeneROOT/script/BAM2fastq/run_bamToFastq.sh
echo "killall -w -s 9 /oplashare/data/mfalchi/parallel-20161122/src/parallel"
killall -w -s 9 /oplashare/data/mfalchi/parallel-20161122/src/parallel
echo "killall -w -s 9 /oplashare/data/mfalchi/sambamba_v0.6.5"
killall -w -s 9 /oplashare/data/mfalchi/sambamba_v0.6.5

exit 0
