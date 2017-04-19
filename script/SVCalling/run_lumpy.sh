#! /bin/bash


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Script used for calling lumpy on processed files. Run it with intelpython2 activated
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sets PATH
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
export PATH=/oplashare/data/mfalchi/samtools-1.3.1:$PATH


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
    		/usr/bin/time --output /eos/genome/local/14007a/lumpy_new_logs/lumpy_info_${fileName}.log /oplashare/data/mfalchi/lumpy-sv/bin/lumpyexpress -T /data/mfalchi/tmp -P -B /eos/genome/local/14007a/realigned_BAM/$fileName.bam -S /eos/genome/local/14007a/realigned_BAM/$fileName.splitters.bam -D /eos/genome/local/14007a/realigned_BAM/$fileName.discordants.bam  -o /eos/genome/local/14007a/lumpy_logged_results/$fileName.vcf &>> /eos/genome/local/14007a/lumpy_new_logs/lumpy_${fileName}.log


		kinit -R
	done
done </eos/genome/local/14007a/aligned_couples_onePair.txt

