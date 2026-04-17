#!/bin/bash
set -euo pipefail

# 1. Ensure project environment is loaded
if [ -f "config/project.env" ]; then
    source config/project.env
else
    echo "ERROR: config/project.env not found. Run from project root."
    exit 1
fi

# 2. Define and verify essential paths
# Using full paths or paths relative to project root ensures consistency
SAMPLE_DIR="results/pathogen"
BAM="${SAMPLE_DIR}/${SAMPLE}.vs_pathogens.bam"
IDX="${SAMPLE_DIR}/${SAMPLE}.idxstats.tsv"

TOP_LIST="${SAMPLE_DIR}/${SAMPLE}.top_refs.tsv"
TOP_BED="${SAMPLE_DIR}/${SAMPLE}.top_refs.bed"
TOP_DEPTH="${SAMPLE_DIR}/${SAMPLE}.depth_top.tsv"

# 3. Pre-flight checks: Do the inputs exist?
for FILE in "$BAM" "$IDX"; do
    if [ ! -s "$FILE" ]; then
        echo "ERROR: Required input file missing or empty: $FILE"
        exit 1
    fi
done

echo "--- Starting Depth Subset Preparation for ${SAMPLE} ---"


# 4. Step 1: Create the Top 9 List
echo "Filtering top 9 references from idxstats..."

TMP_SORTED="${SAMPLE_DIR}/${SAMPLE}.idxstats.sorted.tmp"

awk '$1 != "*" && $3 > 0 { print $1, $2, $3 }' "$IDX" > "${TMP_SORTED}.unsorted"
sort -T "." -k3,3nr "${TMP_SORTED}.unsorted" > "$TMP_SORTED"
head -n 9 "$TMP_SORTED" > "$TOP_LIST"

rm -f "${TMP_SORTED}.unsorted" "$TMP_SORTED"

echo "Filtering finished"

# Check if the file was actually written before moving on
if [[ -f "$TOP_LIST" ]]; then
    echo "Filtering finished. Found $(wc -l < "$TOP_LIST") references."
else
    echo "ERROR: Filtering failed to create $TOP_LIST"
    exit 1
fi

# 5. Step 2: Safety check - did we find any hits?
if [ ! -s "$TOP_LIST" ]; then
    echo "NOTICE: No mapped pathogen references found. Creating empty depth file."
    touch "$TOP_DEPTH"
    exit 0
fi

# 6. Step 3: Create the BED file (Critical step that failed before)
echo "Generating BED file: ${TOP_BED}"
awk 'BEGIN{OFS="\t"} {print $1, "0", $2}' "$TOP_LIST" > "$TOP_BED"

# 7. Step 4: Calculate Depth with samtools
# We add -aa for better report visualization
echo "Running samtools depth (this may take a moment)..."
if command -v samtools &> /dev/null; then
    samtools depth -b "$TOP_BED" "$BAM" > "$TOP_DEPTH"
else
    echo "ERROR: samtools command not found. Is your conda environment active?"
    exit 1
fi

echo "--- Subset Preparation Complete ---"
echo "Output:"
echo "  $TOP_LIST"
echo "  $TOP_BED"
echo "  $TOP_DEPTH"
