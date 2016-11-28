PATH=/data/mfalchi/samtools-1.3.1:/data/mfalchi/pigz-2.3.4:$PATH
WDIR="/eos/genome/kinetic/14007a/tests"

date > /data/mfalchi/run_bamToFastq_bbmap_unsort.log

/data/mfalchi/bbmap/reformat.sh in=$WDIR/test.bam out=$WDIR/bbmap.unsort.test.fq ow allowidenticalnames primaryonly &>> /data/mfalchi/run_bamToFastq_bbmap_unsort.log

date >> /data/mfalchi/run_bamToFastq_bbmap_unsort.log

/data/mfalchi/bbmap/reformat.sh in=$WDIR/bbmap.unsort.test.fq out1=$WDIR/bbmap.unsort.test.end1.fq out2=$WDIR/bbmap.unsort.test.end2.fq ow &>> /data/mfalchi/run_bamToFastq_bbmap_unsort.log

date >> /data/mfalchi/run_bamToFastq_bbmap_unsort.log

