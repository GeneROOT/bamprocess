#! /bin/bash
#
# This script checks the status of the produced files in the BAM reprocessing.
#
# From the original BAM a sorted.BAM is procuced. This BAM is larger than the
# original, if not then there was an error in creating it.
# From the sorted.BAM forward and reverse fastq files are produced.
# Both files must exist and must have a size within 5% (?) of each other,
# if not there was an error.
# The size of both fastq files must be within 20% (?) of the original BAM file.
# if not there was an error.
# In all error cases the files in error will be removed so they can be reprocessed.
# All files passing the above criteria are added to the doneBAM.txt file.
#
# Author: Fons Rademakers, 4/2/2017.

# after relocation, change only eos variable
eos=/eos/genome/local/14007a

obam=$eos/original_BAM
sbam=$eos/sorted_BAM
fbam=$eos/fastq

# output files
allbam=$obam/allBAM.txt
donebam=$obam/doneBAM.txt1

#ls $obam/*.bam > $allbam
rm -f $donebam

# Only when option --delete is set delete the files
action="echo"
actionr="echo"
if [ $# -ge 1 ]; then
   if [ "x$1" == "x--delete" ]; then
      action="rm -f" 
      actionr="rm -rf"
   else
      echo "Usage: $0 [--delete]"
      exit 1
   fi
fi

# Loop over all BAMs and find sorted BAMs and fastq's

for bam in `cat $allbam`; do
   # get BAM id
   id=$(basename $bam .bam)

   # sorted BAM file
   sb=$sbam/$id.sorted.bam

   # forward and reverse fastq files
   r1=$fbam/$id.R1.fq.gz
   r2=$fbam/$id.R2.fq.gz

   # get size of original BAM file
   osize=$(ls -l $bam | awk '{ print $5 }')

   # check if sorted BAM file exists and get its size
   if [ -f $sb ]; then
      ssize=$(ls -l $sb | awk '{ print $5 }')

      # if sorted size is less than original size, file is truncated
      if [ $ssize -lt $osize ]; then
         echo "sorted truncated: $sb ($ssize) < $bam ($osize), skipping..."

         # remove its aretefacts, we have to reprocess the file
         $actionr $sbam/$id
         $action $sb
         $action $r1
         $action $r2
         continue
      fi

      # check if forward and reverse fastq files exist
      if [ -f $r1 -a -f $r2 ]; then
         # if both files exist check size, they should be close
         sr1=$(ls -l $r1 | awk '{ print $5 }')
         sr2=$(ls -l $r2 | awk '{ print $5 }')
         # fastq file difference greater than 5%, discard files
         rdiff=$(bc -l <<< "sr1=$sr1;if (sr1==0) sr1=1; x=(sr1-$sr2)/sr1*100; if (x<0) x=-x; print x")
         rt=$(bc -l <<< "if ($rdiff>5.) print 1 else print 0")
         if [ $rt -eq 1 ]; then
            echo "difference between $r1 and $r2 more than 5% ($rdiff), skipping..." 
            $action $r1
            $action $r2
            continue
         fi
         # total fastq files difference with original BAM more than 20%, discard files
         odiff=$(bc -l <<< "x=($osize-($sr1+$sr2))/$osize*100; if (x<0) x=-x; print x")
         ot=$(bc -l <<< "if ($odiff>20.) print 1 else print 0")
         if [ $ot -eq 1 ]; then
            echo "difference between $r1+$r2 and $bam more than 20% ($odiff), skipping..." 
            $action $r1
            $action $r2
            continue
         fi
         echo $bam >> $donebam
      else
         if [ -f $r1 ]; then
            echo "$r2 missing, skipping..."
            $action $r1
         fi
         if [ -f $r2 ]; then
            echo "$r1 missing, skipping..."
            $action $r2
         fi
      fi
   fi
done

exit 0
