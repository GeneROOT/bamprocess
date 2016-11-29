#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sets PATH
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

PATH=/data/mfalchi/samtools-1.3.1:/data/mfalchi/pigz-2.3.4:$PATH

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
	date | awk '{print "Sorting started at " $0}' > $LDIR/$stem.log
	$sambamba sort --natural-sort --memory-limit $sambambamem --tmpdir $WDIR/$stem --out $WDIR/$stem.sorted.bam --compression-level $sambambacompression --nthreads $sambambathreads $1  &>> $LDIR/$stem.log
	date | awk '{print "Sorting ended at " $0}' >> $LDIR/$stem.log

	#Converts in two piped steps, that is: from BAM to an interleaved fastq
	#and then from the interleaved file to two files, one for each paired end.
	date | awk '{print "Conversion started at " $0}' >> $LDIR/$stem.log
	$reformat in=$WDIR/$stem.sorted.bam out=stdout.fq primaryonly | $reformat in=stdin.fq out1=$DDIR/$stem.R1.fq.gz out2=$DDIR/$stem.R2.fq.gz interleaved addcolon ow  &>> $LDIR/$stem.log
	date | awk '{print "Conversion ended at " $0}' >> $LDIR/$stem.log

	#Removing temporary directory
	rm -rf $WDIR/$stem

	#Recording this file as done
	echo $1 
}
export -f BAM2Fastq


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sets commands' path
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sambamba="/data/mfalchi/sambamba_v0.6.5"
reformat="/data/mfalchi/bbmap/reformat.sh"

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sets commands paramentes
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

njobs=4
sambambamem="16G"
sambambathreads=16
sambambacompression=6

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sets file's paths
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

SDIR="/eos/genome/kinetic/14007a/original_BAM"
WDIR="/eos/genome/kinetic/14007a/sorted_BAM"
DDIR="/eos/genome/kinetic/14007a/fastq"
LDIR="/data/mfalchi/logs/"

filelist="$SDIR/allBAM.txt"
donelist="$SDIR/doneBAM.txt"
todolist="$SDIR/todoBAM.txt"

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Selects files to process 
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

grep -vwFf $donelist $filelist > $todolist

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Files are processed 
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

parallel --keep-order --jobs $njobs BAM2Fastq :::: $todolist >> $donelist



