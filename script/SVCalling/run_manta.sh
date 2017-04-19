#! /bin/bash

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Script used for calling lumpy on processed files. Run it with intelpython2 activated
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sets PATH
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
export PATH=/oplashare/data/mfalchi/samtools-1.3.1:$PATH
export eos="/eos/genome/local/14007a"
export logs="$eos/manta_logs"
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
                /oplashare/data/mfalchi/manta-1.0.3.centos5_x86_64/bin/configManta.py --bam $eos/realigned_BAM/$fileName.bam --referenceFasta  $eos/reference/human_g1k_v37.fasta --runDir $local/manta_results/$fileName &>> $logs/manta_${fileName}.log
		/usr/bin/time --output $logs/manta_time_${fileName} python $local/manta_results/$fileName/runWorkflow.py -m local &>> $logs/manta_${fileName}.log

		# copy output to newbam
		echo "" >> $logs/manta_${fileName}.log  
		echo "Copying output" >> $logs/manta_${fileName}.log  
		echo "" >> $logs/manta_${fileName}.log  
		eos cp --checksum $local/manta_results/${fileName}/ root://eosgenome.cern.ch/$eos/manta_results/
                
		kinit -R
        done
done </eos/genome/local/14007a/aligned_couples_onePair.txt


