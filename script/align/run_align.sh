#! /bin/bash

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sets PATH
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

PATH=/oplashare/data/mfalchi/samtools-1.3.1:/oplashare/data/mfalchi/pigz-2.3.4:$PATH

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

export mem=32
export threads=4

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sets file's paths
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

export eos="/eos/genome/local/14007a"
export fastq="$eos/fastq"
export newbam="$eos/realigned_BAM"
export logs="$eos/logs2"

allfastq="$fastq/MZ_to_align.txt"
donefastq="$fastq/doneTwins.txt"
todofastq="$fastq/todoTwins.txt"
myfastq="$fastq/myTwins$1.txt"

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Defines function coding for the conversion pipeline
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

align() 
{
    # Renew AFS token
    kinit -R

    stem=$1
    echo $stem

    echo "" > $logs/speedseq_${stem}.log  
    echo "Starting alignment at $(date) on $(hostname)" > $logs/speedseq_${stem}.log  
    echo "" >> $logs/speedseq_${stem}.log  
   
    # Runs speedseq align
    /oplashare/data/mfalchi/speedseq/bin/speedseq align -M $mem -v -t $threads -T /data/mfalchi/${stem}_tmp_dir -R "@RG\tID:id\tSM:$stem\tLB:lib" -o $newbam/ $eos/reference/human_g1k_v37.fasta.gz $fastq/$stem.R1.fq.gz $fastq/$stem.R2.fq.gz  &> $logs/speedseq_${stem}.log  

    # Renew AFS token
    kinit -R

    echo "" >> $logs/speedseq_${stem}.log  
    echo "Alignment completed at $(date) on $(hostname)" > $logs/speedseq_${stem}.log  
    echo "" >> $logs/speedseq_${stem}.log  
   
    echo "" >> $logs/speedseq_${stem}.log  
    echo "Removing /data/mfalchi/${stem}_tmp_dir/" > $logs/speedseq_${stem}.log    

    #Cleans local directory (EOS does not support pipes)
    rm -rf /data/mfalchi/${stem}_tmp_dir/
    echo "   Done ${stem}" > $logs/speedseq_${stem}.log    
	
}
export -f align


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Selects files to process 
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#Removing already processed files from the list of file to process
grep -vwFf $donefastq $allfastq > $todofastq

#Each machine will process a fair share of the work. 
awk -v machine=$1 -v availablemachines=$availablemachines 'NR%availablemachines == machine' $todofastq > $myfastq

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Files are processed 
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/oplashare/data/mfalchi/parallel-20161122/src/parallel --keep-order --jobs $2 align :::: $myfastq 
