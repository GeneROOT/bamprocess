PATH=/data/mfalchi/samtools-1.3.1:$PATH
WDIR="/eos/genome/kinetic/14007a/tests"

date > /data/mfalchi/run_bamToFastq_bbmap.log

/data/mfalchi/bbmap/reformat.sh in=$WDIR/test.sorted.bam out=$WDIR/bbmap.test.fq ow allowidenticalnames primaryonly &>> /data/mfalchi/run_bamToFastq_bbmap.log

date >> /data/mfalchi/run_bamToFastq_bbmap.log

/data/mfalchi/bbmap/reformat.sh in=$WDIR/bbmap.test.fq out1=$WDIR/bbmap.test.end1.fq out2=$WDIR/bbmap.test.end2.fq ow &>> /data/mfalchi/run_bamToFastq_bbmap.log

date >> /data/mfalchi/run_bamToFastq_bbmap.log

