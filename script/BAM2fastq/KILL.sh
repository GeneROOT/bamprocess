#! /bin/bash

#set -x

echo "pkill -9 run_bamToFastq.sh"
pkill -9 run_bamToFastq.sh
echo "pkill -9 -f \"perl /oplashare/data/mfalchi/parallel\""
pkill -9 -f "perl /oplashare/data/mfalchi/parallel"
echo "pkill -9 sambamba_v0.6.5"
pkill -9 sambamba_v0.6.5

exit 0
