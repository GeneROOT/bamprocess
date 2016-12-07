#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sets PATH
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

PATH=/oplashare/data/mfalchi/samtools-1.3.1:/oplashare/data/mfalchi/pigz-2.3.4:$PATH

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Defines function coding for the conversion pipeline
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

BAM2Fastq() 
{
	#Extracts ID from filename
	stem=$(basename $1 .bam)
	
	#Creates temporary directory for this analysis
	mkdir -p $WDIR/$stem

	#Sorts by name
	date | awk '{print "Sorting started at " $0}' > $LDIR/BAM2Fastq_${stem}.log
	$sambamba sort --natural-sort --memory-limit $sambambamem --tmpdir $WDIR/$stem --out $WDIR/$stem.sorted.bam --compression-level $sambambacompression --nthreads $sambambathreads $1  &>> $LDIR/BAM2Fastq_${stem}.log
	date | awk '{print "Sorting ended at " $0}' >> $LDIR/BAM2Fastq_${stem}.log

	#Converts in two piped steps, that is: from BAM to an interleaved fastq
	#and then from the interleaved file to two files, one for each paired end.
	date | awk '{print "Conversion started at " $0}' >> $LDIR/BAM2Fastq_${stem}.log
	$reformat in=$WDIR/$stem.sorted.bam out=stdout.fq primaryonly | $reformat in=stdin.fq out1=$DDIR/$stem.R1.fq.gz out2=$DDIR/$stem.R2.fq.gz interleaved addcolon ow  &>> $LDIR/BAM2Fastq_${stem}.log
	date | awk '{print "Conversion ended at " $0}' >> $LDIR/BAM2Fastq_${stem}.log

	#Removing temporary directory
	rm -rf $WDIR/$stem

	#Recording this file as done
	echo $1 
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
# Sets commands' path
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sambamba="/oplashare/data/mfalchi/sambamba_v0.6.5"
reformat="/oplashare/data/mfalchi/bbmap/reformat.sh"
parallel="/oplashare/data/mfalchi/parallel-20161122/src/parallel"

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sets commands paramentes
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

njobs=2
sambambamem="32G"
sambambathreads=16
sambambacompression=6

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sets file's paths
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

SDIR="/eos/genome/kinetic/14007a/original_BAM"
WDIR="/eos/genome/kinetic/14007a/sorted_BAM"
DDIR="/eos/genome/kinetic/14007a/fastq"
LDIR="/eos/genome/kinetic/14007a/logs"

filelist="$SDIR/allBAM.txt"
donelist="$SDIR/doneBAM.txt"
todolist="$SDIR/todoBAM.txt"
mylist="$SDIR/todoBAM$1.txt"

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

$parallel --keep-order --jobs $njobs BAM2Fastq :::: $mylist >> $donelist



