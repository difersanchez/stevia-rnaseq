#!/bin/bash
set -euo pipefail

source config/project.env
Rscript report/render_report.R "$(pwd)" "$SAMPLE"
