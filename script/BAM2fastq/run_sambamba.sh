date > /data/mfalchi/run_sambamba.log

/data/mfalchi/sambamba_v0.6.5 sort --natural-sort --memory-limit 60GB --tmpdir /eos/genome/kinetic/14007a/tests --out /eos/genome/kinetic/14007a/tests/test.sorted.bam --compression-level 0 --uncompressed-chunks  --nthreads 20 /eos/genome/kinetic/14007a/tests/test.bam &>> /data/mfalchi/run_sambamba.log

date >> /data/mfalchi/run_sambamba.log
