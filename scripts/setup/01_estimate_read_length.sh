#!/bin/bash
set -euo pipefail

source config/project.env
mkdir -p config

python - <<'PY' "$R1" > config/read_length.txt
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

echo "Estimated raw read length: $(cat config/read_length.txt)"
