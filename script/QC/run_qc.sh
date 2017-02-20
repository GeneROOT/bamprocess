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
availablemachines=5

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sets command parameters
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

export threads=4

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sets file's paths
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

export eos="/eos/genome/local/14007a"
export fastq="$eos/fastq"
export qc="$eos/fastQC"
export logs="$eos/logsQC"

allfastq="$fastq/MZ_to_QC.txt"
donefastq="$fastq/doneQC.txt"
todofastq="$fastq/todoQCTwins.txt"
myfastq="$fastq/myTwinsQC$1.txt"

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Defines function coding for the conversion pipeline
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

extractQCinfo()
#$1 is the working directory
#$2 is the basename for the fastQC output (inlcuding working directory)
#$2 is the stem for the new files
{
	#Renames HTML file, extracts QC summary and removes archive
	mv $1/${2}_fastqc.html $1/$3_fastqc.html
	unzip -p $1/${2}_fastqc.zip ${2}_fastqc/fastqc_data.txt > $1/${3}_fastqc_data.txt  
	# rm -rf $1/${2}_fastqc.zip
}
export -f extractQCinfo

qualityassessment() 
{
    # Renew AFS token
    kinit -R

    stem=$1
    echo $stem
 
    echo "Starting fastQC at $(date) on $(hostname)" > $logs/fastqc_${stem}.log  
    echo "" >> $logs/fastqc_${stem}.log  
   
    # Runs fastqc align
    /oplashare/data/mfalchi/FastQC/fastqc --quiet --noextract --format fastq --threads $threads --outdir=$qc/ $fastq/${stem}.R1.fq.gz &>> $logs/fastqc_${stem}.log  
	extractQCinfo $qc $stem.R1.fq $stem.R1
	
    # Renew AFS token
    kinit -R
	
    /oplashare/data/mfalchi/FastQC/fastqc --quiet --noextract --format fastq --threads $threads --outdir=$eos/fastQC/ $fastq/${stem}.R2.fq.gz  &>> $logs/fastqc_${stem}.log
	extractQCinfo $qc $stem.R2.fq $stem.R2
	    
    echo "" >> $logs/fastqc_${stem}.log  
    echo "fastQC ended at $(date) on $(hostname)" >> $logs/fastqc_${stem}.log  
    echo "" >> $logs/fastqc_${stem}.log  
}
export -f qualityassessment


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

/oplashare/data/mfalchi/parallel-20161122/src/parallel --keep-order --jobs $2 qualityassessment :::: $myfastq 
