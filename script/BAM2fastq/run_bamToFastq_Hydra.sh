WDIR="/eos/genome/kinetic/14007a/tests"

date > /data/mfalchi/run_bamToFastq_Hydra.log

/data/mfalchi/Hydra-Version-0.5.3/bin/bamToFastq  -bam $WDIR/test.sorted.bam -fq1 $WDIR/hydra.test.sorted.end1.fq -fq2 $WDIR/hydra.test.sorted.end2.fq &>> /data/mfalchi/run_bamToFastq_Hydra.log

date >> /data/mfalchi/run_bamToFastq_Hydra.log
