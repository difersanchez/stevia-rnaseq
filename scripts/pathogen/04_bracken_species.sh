#!/bin/bash
set -euo pipefail

source config/project.env

READ_LEN=$(python - <<'PY' "results/nonhost/${SAMPLE}_nonhost_R1.fq.gz"
import gzip, sys
n = 0
total = 0
with gzip.open(sys.argv[1], "rt") as fh:
    for i, line in enumerate(fh, 1):
        if i % 4 == 2:
            total += len(line.rstrip())
            n += 1
            if n == 100000:
                break
print(round(total / n))
PY
)

bracken \
  -d refs/kraken_curated \
  -i "results/pathogen/${SAMPLE}.k2.report" \
  -o "results/pathogen/${SAMPLE}.bracken.species.tsv" \
  -r "$READ_LEN" \
  -l S \
  -t 10
