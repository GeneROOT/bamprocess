#! /bin/bash

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sets PATH
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

PATH=/oplashare/data/mfalchi/samtools-1.3.1:/oplashare/data/mfalchi/pigz-2.3.4:$PATH

# Paths
export eos="/eos/genome/local/14007a"
export origbam="$eos/original_BAM"
export sortbam="$eos/sorted_BAM"
export logs="$eos/logs"

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Defines function coding for the conversion pipeline
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

BAM2Fastq() 
{
    #Clean up file name
    fname="${1//[$'\t\r\n']}"

    #Extracts ID from filename
    stem=$(basename $fname .bam)
    
    #Creates temporary directory for this analysis
    mkdir -p $sortbam/$stem

    #Sorts by name
    date | awk '{print "Sorting started at " $0}' > $logs/BAM2Fastq_${stem}.log
    /oplashare/data/mfalchi/sambamba_v0.6.5 sort --natural-sort --memory-limit $sambambamem --tmpdir $sortbam/$stem --out $sortbam/$stem.sorted.bam --compression-level $sambambacompression --nthreads $sambambathreads $1  &>> $logs/BAM2Fastq_${stem}.log
    date | awk '{print "Sorting ended at " $0}' >> $logs/BAM2Fastq_${stem}.log

    #Converts in two piped steps, that is: from BAM to an interleaved fastq
    #and then from the interleaved file to two files, one for each paired end.
    date | awk '{print "Conversion started at " $0}' >> $logs/BAM2Fastq_${stem}.log
    /oplashare/data/mfalchi/bbmap/reformat.sh in=$sortbam/$stem.sorted.bam out=stdout.fq primaryonly | /oplashare/data/mfalchi/bbmap/reformat.sh in=stdin.fq out1=$eos/fastq/$stem.R1.fq.gz out2=$eos/fastq/$stem.R2.fq.gz interleaved addcolon ow &>> $logs/BAM2Fastq_${stem}.log
    date | awk '{print "Conversion ended at " $0}' >> $logs/BAM2Fastq_${stem}.log

    #Removing temporary directory
    rm -rf $sortbam/$stem

    #Recording this file as done
    echo $fname
}
export -f BAM2Fastq

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sets general parameters
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#Number of machine I can use to parallelise my job. 
#The $1 paramenter of this script will identify the current machine 
#(ranging from 0 to availablemachines-1)
availablemachines=4

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sets commands paramentes
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

njobs=2
sambambamem="32G"; export sambambamem
sambambathreads=16; export sambambathreads
sambambacompression=6; export sambambacompression 

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sets file's paths
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

filelist="$origbam/allBAM.txt"
donelist="$origbam/doneBAM.txt"
todolist="$origbam/todoBAM.txt"
mylist="$origbam/todoBAM$1.txt"

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Selects files to process 
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#Removing already processed files from the list of file to process
grep -vwFf $donelist $filelist > $todolist

#Each machine will process a fair share of the work. 
awk -v machine=$1 -v availablemachines=$availablemachines 'NR%availablemachines == machine' $todolist > $mylist


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Files are processed 
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/oplashare/data/mfalchi/parallel-20161122/src/parallel --keep-order --jobs $njobs BAM2Fastq :::: $mylist >> $donelist
