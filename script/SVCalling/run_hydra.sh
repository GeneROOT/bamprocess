#! /bin/bash


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Script used for calling lumpy on processed files. Run it with intelpython2 activated
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sets PATH
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
export PATH=/oplashare/data/mfalchi/Hydra/scripts:/oplashare/data/mfalchi/Hydra/bin:/oplashare/data/mfalchi/samtools-1.3.1:$PATH

set ulimit -f 16384

kinit -R
/usr/bin/time --output /eos/genome/local/14007a/hydra_logs/time_logs_6148.log /oplashare/data/mfalchi/Hydra/hydra-multi.sh run -o '6148' /oplashare/data/mfalchi/Hydra/config.onePair.txt &> /eos/genome/local/14007a/hydra_logs/Test_logs_6148.log

kinit -R
/usr/bin/time --output /eos/genome/local/14007a/hydra_logs/time_logs_6149.log /oplashare/data/mfalchi/Hydra/hydra-multi.sh run -o '6149' /oplashare/data/mfalchi/Hydra/config.onePair2.txt &> /eos/genome/local/14007a/hydra_logs/Test_logs_6149.log
