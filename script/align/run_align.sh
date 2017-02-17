#! /bin/bash

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sets PATH
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

PATH=/oplashare/data/mfalchi/samtools-1.3.1:/oplashare/data/mfalchi/pigz-2.3.4:$PATH

# Paths
export eos="/eos/genome/local/14007a"
export fastq="$eos/fastq"
export newbam="$eos/realigned_BAM"
export logs="$eos/logs2"

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Defines function coding for the conversion pipeline
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

align() 
{
    # Renew AFS token
    kinit -R

    stem=$1

	# Runs speedseq align
    /oplashare/data/mfalchi/speedseq/bin/speedseq align -M $mem -v -t $threads -T /data/mfalchi/${stem}_tmp_dir -R "@RG\tID:id\tSM:$stem\tLB:lib" -o $newbam/ /eos/genome/local/14007a/reference/human_g1k_v37.fasta.gz /eos/genome/local/14007a/fastq/$stem.R1.fq.gz /eos/genome/local/14007a/fastq/$stem.R2.fq.gz  &> /eos/genome/local/14007a/tests/speedseq_${stem}.log  

    # Renew AFS token
    kinit -R
	
	mv /data/mfalchi/${stem}_tmp_dir/${stem}* 
	#Cleans local directory (EOS does not support pipes)
	rm -rf /data/mfalchi/${stem}_tmp_dir/
}
export -f align

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sets general parameters
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#Number of machine I can use to parallelise my job. 
#The $1 paramenter of this script will identify the current machine 
#(ranging from 0 to availablemachines-1)
availablemachines=6

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sets command parameters
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

njobs=$2
export mem="32G"
export threads=4

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sets file's paths
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

allfastq="$fastq/myTwins.txt"
donefastq="$fastq/doneTwins.txt"
todofastq="$fastq/todoTwins.txt"
myfastq="$origbam/myTwins$1.txt"

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Selects files to process 
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#Removing already processed files from the list of file to process
grep -vwFf $donefastq $allfastq > todofastq

#Each machine will process a fair share of the work. 
awk -v machine=$1 -v availablemachines=$availablemachines 'NR%availablemachines == machine' $todofastq > $myfastq


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Files are processed 
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/oplashare/data/mfalchi/parallel-20161122/src/parallel --keep-order --jobs $njobs align :::: $myfastq 
