WDIR="/eos/genome/kinetic/14007a/tests"

date > /data/mfalchi/run_bamToFastq.log

/data/mfalchi/bedtools2/bin/bamToFastq  -i $WDIR/test.sorted.bam -fq $WDIR/test.sorted.end1.fq -fq2 $WDIR/test.sorted.end2.fq &>> /data/mfalchi/run_bamToFastq.log

date >> /data/mfalchi/run_bamToFastq.log
