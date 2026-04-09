#!/bin/bash
set -euo pipefail

# Usage:
#   retry_download.sh "<command>"
# Retries a command up to 5 times with increasing sleep.

cmd="$1"
attempts=5
n=1

until [ "$n" -gt "$attempts" ]; do
  echo "Attempt $n/$attempts"
  if eval "$cmd"; then
    exit 0
  fi
  sleep $((n * 60))
  n=$((n + 1))
done

echo "ERROR: command failed after $attempts attempts"
exit 1
