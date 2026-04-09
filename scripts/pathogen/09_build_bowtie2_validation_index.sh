#!/bin/bash
set -euo pipefail

bowtie2-build refs/validation/all_refs.fa refs/validation/all_refs
