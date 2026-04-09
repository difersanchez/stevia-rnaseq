#!/bin/bash
set -euo pipefail

jid1=$(sbatch --parsable slurm/10_build_host_index.slurm)
jid2=$(sbatch --parsable slurm/20_qc_trim.slurm)
jid3=$(sbatch --parsable --dependency=afterok:${jid1}:${jid2} slurm/30_host_filter.slurm)
jid4=$(sbatch --parsable --dependency=afterok:${jid3} slurm/40_build_kraken_db.slurm)
jid5=$(sbatch --parsable --dependency=afterok:${jid4} slurm/50_classify_validate.slurm)

echo "hisat2 index:  $jid1"
echo "qc+trim:       $jid2"
echo "host filter:   $jid3"
echo "kraken build:  $jid4"
echo "classify:      $jid5"
