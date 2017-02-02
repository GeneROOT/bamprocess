#! /bin/bash

#set -x

echo "pgrep -a run_bamToFastq.sh"
pgrep -a run_bamToFastq.sh
echo "pgrep -af \"perl /oplashare/data/mfalchi/parallel\""
pgrep -af "perl /oplashare/data/mfalchi/parallel"
echo "pgrep -a sambamba_v0.6.5"
pgrep -a sambamba_v0.6.5

exit 0
