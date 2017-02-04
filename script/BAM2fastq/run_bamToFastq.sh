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
    # Renew AFS token
    kinit -R

    #Clean up file name
    fname="${1//[$'\t\r\n']}"

    #Extracts ID from filename
    stem=$(basename $fname .bam)
    
    #Creates temporary directory for this analysis
    mkdir -p $sortbam/$stem

    #Sorts by name
    echo "Sorting started at $(date) on $(hostname)" > $logs/BAM2Fastq_${stem}.log
    /oplashare/data/mfalchi/sambamba_v0.6.5 sort --natural-sort --memory-limit $sambambamem --tmpdir $sortbam/$stem --out $sortbam/$stem.sorted.bam --compression-level $sambambacompression --nthreads $sambambathreads $1  &>> $logs/BAM2Fastq_${stem}.log
    echo "Sorting ended at $(date) on $(hostname)" >> $logs/BAM2Fastq_${stem}.log

    # Renew AFS token
    kinit -R

    #Converts in two piped steps, that is: from BAM to an interleaved fastq
    #and then from the interleaved file to two files, one for each paired end.
    echo "Conversion started at $(date) on $(hostname)" >> $logs/BAM2Fastq_${stem}.log
    /oplashare/data/mfalchi/bbmap/reformat.sh in=$sortbam/$stem.sorted.bam out=stdout.fq primaryonly | /oplashare/data/mfalchi/bbmap/reformat.sh in=stdin.fq out1=$eos/fastq/$stem.R1.fq.gz out2=$eos/fastq/$stem.R2.fq.gz interleaved addcolon ow &>> $logs/BAM2Fastq_${stem}.log
    echo "Conversion ended at $(date) on $(hostname)" >> $logs/BAM2Fastq_${stem}.log

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
availablemachines=6

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sets command parameters
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

njobs=2
export sambambamem="32G"
export sambambathreads=16
export sambambacompression=6

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sets file's paths
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

allbams="$origbam/allBAM.txt"
donebams="$origbam/doneBAM.txt"
todobams="$origbam/todoBAM.txt"
mybams="$origbam/todoBAM$1.txt"
mydonebams="$origbam/doneBAM$1.txt"

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Selects files to process 
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#Removing already processed files from the list of file to process
grep -vwFf $donebams $allbams > $todobams

#Each machine will process a fair share of the work. 
awk -v machine=$1 -v availablemachines=$availablemachines 'NR%availablemachines == machine' $todobams > $mybams


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Files are processed 
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/oplashare/data/mfalchi/parallel-20161122/src/parallel --keep-order --jobs $njobs BAM2Fastq :::: $mybams >> $mydonebams
