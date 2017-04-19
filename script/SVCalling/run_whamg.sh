#! /bin/bash

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Script used for calling lumpy on processed files. Run it with intelpython2 activated
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sets PATH
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
export PATH=/oplashare/data/mfalchi/samtools-1.3.1:$PATH
export eos="/eos/genome/local/14007a"
export logs="$eos/whamg_logs"
export local="/data/mfalchi/"


while read p; do
# Our samples are couples, so we need to separate a given line into two pieces, in order to process each sample separately
  samples=$(echo $p | tr " " "\n")
        for file in $samples
        do
                kinit -R
                # Extracting the file name from the full path
                xpath=${file%/*}
                xbase=${file##*/}
                xfext=${xbase##*.}
                fileName=${xbase%.*}

                echo ${fileName}
                # Process the samples one by one here
                /usr/bin/time --output $logs/wham_time_${fileName}.log /oplashare/data/mfalchi/wham/bin/whamg -a $eos/reference/human_g1k_v37.fasta -f $eos/realigned_BAM/$fileName.bam > $eos/Wham_results/$fileName.vcf &> $logs/$fileName.log
                kinit -R
        done
done </eos/genome/local/14007a/aligned_couples_onePair.txt

