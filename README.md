# Stevia RNA-seq Pathogen Detection Pipeline

A Linux/HPC pipeline for detecting **viruses, bacteria, and fungi** in **_Stevia rebaudiana_** RNA-seq data starting from paired-end `FASTQ` files.

This workflow is designed for:

- **paired-end RNA-seq**
- **rRNA-depleted libraries**
- **HPC clusters with SLURM**
- **host depletion without annotation**
- **pathogen discovery from non-host reads**
- **HTML reporting with R Markdown**

The pipeline uses:

- **FastQC / MultiQC** for read QC
- **fastp** for trimming
- **HISAT2** for host depletion against the Stevia genome
- **Kraken2 + Bracken** for taxonomic classification
- **Bowtie2** for read-level validation against pathogen references
- **rnaSPAdes** for non-host contig assembly
- **BLAST** for contig-level validation
- **R Markdown** for the final report

---

## Overview

The pipeline runs in five major stages:

1. **Setup on login node**
   - estimate read length
   - download the Stevia host genome
   - download curated bacterial, fungal, and viral references
   - prepare the custom Kraken2 library

2. **Read QC and trimming**
   - FastQC on raw reads
   - fastp trimming
   - FastQC on trimmed reads
   - MultiQC summary

3. **Host depletion**
   - build HISAT2 index from the Stevia genome
   - align trimmed reads to host
   - collect paired non-host reads

4. **Pathogen detection and validation**
   - build Kraken2 + Bracken database
   - classify non-host reads
   - estimate abundances
   - validate with Bowtie2 coverage
   - assemble non-host contigs with rnaSPAdes
   - validate contigs with BLAST

5. **Reporting**
   - render a full HTML report with tables and coverage plots

---

## Project structure

```text
stevia_pathoseq/
├── config/
│   └── project.env
├── data/
│   ├── SAMPLE_SE01_1.fq.gz
│   └── SAMPLE_SE01_2.fq.gz
├── envs/
│   ├── stevia_setup.yml
│   ├── stevia_rnaseq.yml
│   ├── stevia_pathogen.yml
│   └── stevia_report.yml
├── logs/
├── refs/
│   ├── custom_lists/
│   ├── custom_refs/
│   ├── host/
│   ├── kraken_curated/
│   └── validation/
├── report/
│   ├── report.Rmd
│   └── render_report.R
├── results/
│   ├── assembly/
│   ├── host/
│   ├── nonhost/
│   ├── pathogen/
│   ├── qc/
│   ├── report/
│   └── trim/
├── scripts/
│   ├── helpers/
│   ├── host/
│   ├── pathogen/
│   ├── qc/
│   ├── report/
│   ├── setup/
│   ├── setup/run_all_setup.sh
│   └── submit_jobs.sh
└── slurm/
    ├── 10_build_host_index.slurm
    ├── 20_qc_trim.slurm
    ├── 30_host_filter.slurm
    ├── 40_build_kraken_db.slurm
    └── 50_classify_validate.slurm
```

---

## Inputs

This pipeline expects:

- one or more paired-end RNA-seq samples in `./data`
- a configuration file in `config/project.env`

Example input files:

```bash
data/SAMPLE_SE01_1.fq.gz
data/SAMPLE_SE01_2.fq.gz
```

Example `config/project.env`:

```bash
SAMPLE=SAMPLE_SE01
R1=./data/SAMPLE_SE01_1.fq.gz
R2=./data/SAMPLE_SE01_2.fq.gz
THREADS=8
HOST_ACC=GCA_009936405.2
```

---

## Requirements

### System requirements

- Linux
- SLURM scheduler
- internet access on the **login node**
- enough disk space for:
  - references
  - Kraken2 database
  - BAM files
  - assembled contigs

### Software installation

This repository uses **Miniforge + mamba** to manage environments.

If Miniforge is not installed:

```bash
cd "$HOME"
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
bash Miniforge3-Linux-x86_64.sh -b -p "$HOME/miniforge3"

source "$HOME/miniforge3/etc/profile.d/conda.sh"
conda init bash
conda config --set channel_priority strict
```

---

## Create the environments

Place the YAML files in `./envs` (They are cloned here), then run:

```bash
bash create_mamba_envs.sh
```

Or create them manually:

```bash
source "$HOME/miniforge3/etc/profile.d/conda.sh"

mamba env create -f envs/stevia_setup.yml
mamba env create -f envs/stevia_rnaseq.yml
mamba env create -f envs/stevia_pathogen.yml
mamba env create -f envs/stevia_report.yml
```

---

## Pipeline logic

### 1. Setup stage

Run on the **login node** (This was done expecting the login node as the only one with access to the internet):

```bash
source "$HOME/miniforge3/etc/profile.d/conda.sh"
conda activate stevia_setup

bash scripts/setup/run_all_setup.sh
```

This stage performs:

- read length estimation
- host genome download from NCBI
- curated bacteria/fungi genus list generation
- Stevia-priority watchlist creation
- bacterial reference download
- fungal reference download
- bacterial/fungal FASTA merge
- Kraken2 taxonomy download
- viral reference download
- viral FASTA merge
- addition of custom references to the Kraken2 library

### Setup scripts

```text
scripts/setup/01_estimate_read_length.sh
scripts/setup/02_download_host_genome.sh
scripts/setup/03_write_curated_lists.sh
scripts/setup/04_download_bacteria_refs.sh
scripts/setup/05_download_fungi_refs.sh
scripts/setup/06_merge_bactfungi_refs.sh
scripts/setup/07_download_kraken_taxonomy.sh
scripts/setup/08_download_viral_refs.sh
scripts/setup/09_merge_viral_refs.sh
scripts/setup/10_add_refs_to_kraken_library.sh
```

---

## 2. Submit the pipeline jobs

After setup is complete:

```bash
bash scripts/submit_jobs.sh
```

This submits the following SLURM jobs in order:

1. `10_build_host_index.slurm`
2. `20_qc_trim.slurm`
3. `30_host_filter.slurm`
4. `40_build_kraken_db.slurm`
5. `50_classify_validate.slurm`

Dependencies are handled automatically inside `scripts/submit_jobs.sh`.

---

## 3. Stage-by-stage description

### A. Host index building

SLURM job:

```text
slurm/10_build_host_index.slurm
```

Called script:

```text
scripts/host/01_build_hisat2_index.sh
```

Purpose:

- build a HISAT2 index from the Stevia host genome FASTA

Output:

```text
refs/host/hisat2_index/stevia.*.ht2
```

---

### B. QC and trimming

SLURM job:

```text
slurm/20_qc_trim.slurm
```

Called scripts:

```text
scripts/qc/01_fastqc_raw.sh
scripts/qc/02_fastp_trim.sh
scripts/qc/03_fastqc_trimmed.sh
scripts/qc/04_multiqc.sh
```

Purpose:

- assess raw read quality
- trim adapters and low-quality regions
- reassess trimmed reads
- aggregate QC results

Key outputs:

```text
results/qc/multiqc/multiqc_report.html
results/trim/<SAMPLE>.fastp.html
results/trim/<SAMPLE>.fastp.json
results/trim/<SAMPLE>_R1.trim.fq.gz
results/trim/<SAMPLE>_R2.trim.fq.gz
```

---

### C. Host depletion

SLURM job:

```text
slurm/30_host_filter.slurm
```

Called script:

```text
scripts/host/02_filter_host_reads.sh
```

Purpose:

- align trimmed reads to the Stevia genome with HISAT2
- keep non-host paired reads for pathogen detection

Key outputs:

```text
results/host/<SAMPLE>.hisat2.summary.txt
results/host/<SAMPLE>.flagstat.txt
results/host/<SAMPLE>.idxstats.txt
results/nonhost/<SAMPLE>_nonhost_R1.fq.gz
results/nonhost/<SAMPLE>_nonhost_R2.fq.gz
```

---

### D. Kraken2 and Bracken database building

SLURM job:

```text
slurm/40_build_kraken_db.slurm
```

Called scripts:

```text
scripts/pathogen/01_build_kraken_db.sh
scripts/pathogen/02_build_bracken_db.sh
```

Purpose:

- build the custom Kraken2 database
- prepare Bracken abundance estimation metadata

Outputs:

```text
refs/kraken_curated/
```

---

### E. Pathogen classification and validation

SLURM job:

```text
slurm/50_classify_validate.slurm
```

Called scripts:

```text
scripts/pathogen/03_kraken2_classify.sh
scripts/pathogen/04_bracken_species.sh
scripts/pathogen/05_bracken_genus.sh
scripts/pathogen/06_extract_candidate_species.sh
scripts/pathogen/07_build_validation_fasta.sh
scripts/pathogen/08_make_blast_db.sh
scripts/pathogen/09_build_bowtie2_validation_index.sh
scripts/pathogen/10_align_nonhost_to_validation_refs.sh
scripts/pathogen/11_compute_validation_metrics.sh
scripts/pathogen/12_rnaspades_assembly.sh
scripts/pathogen/13_blast_contigs.sh
```

Purpose:

- classify non-host reads taxonomically
- estimate species and genus abundances
- extract candidate pathogens
- build validation references
- compute alignment-based coverage metrics
- assemble non-host reads
- BLAST contigs against pathogen references

Key outputs:

```text
results/pathogen/<SAMPLE>.k2.report
results/pathogen/<SAMPLE>.k2.out
results/pathogen/<SAMPLE>.bracken.species.tsv
results/pathogen/<SAMPLE>.bracken.genus.tsv
results/pathogen/<SAMPLE>.candidate_species.tsv
results/pathogen/<SAMPLE>.coverage.tsv
results/pathogen/<SAMPLE>.depth.tsv
results/pathogen/<SAMPLE>.idxstats.tsv
results/pathogen/<SAMPLE>.contigs_vs_pathogen_refs.tsv
results/assembly/<SAMPLE>_rnaspades/transcripts.fasta
```

---

## 4. Render the report

After all jobs finish successfully:

```bash
source "$HOME/miniforge3/etc/profile.d/conda.sh"
conda activate stevia_report

bash scripts/report/01_render_report.sh
```

This calls:

```text
report/render_report.R
```

which renders:

```text
report/report.Rmd
```

Final output:

```text
results/report/<SAMPLE>_pathogen_report.html
```

---

## Main output files

### QC

```text
results/qc/multiqc/multiqc_report.html
results/trim/<SAMPLE>.fastp.html
results/trim/<SAMPLE>.fastp.json
```

### Host depletion

```text
results/host/<SAMPLE>.hisat2.summary.txt
results/nonhost/<SAMPLE>_nonhost_R1.fq.gz
results/nonhost/<SAMPLE>_nonhost_R2.fq.gz
```

### Classification

```text
results/pathogen/<SAMPLE>.k2.report
results/pathogen/<SAMPLE>.bracken.species.tsv
results/pathogen/<SAMPLE>.bracken.genus.tsv
results/pathogen/<SAMPLE>.candidate_species.tsv
```

### Validation

```text
results/pathogen/<SAMPLE>.coverage.tsv
results/pathogen/<SAMPLE>.depth.tsv
results/pathogen/<SAMPLE>.idxstats.tsv
results/pathogen/<SAMPLE>.contigs_vs_pathogen_refs.tsv
results/assembly/<SAMPLE>_rnaspades/transcripts.fasta
```

### Report

```text
results/report/<SAMPLE>_pathogen_report.html
```

---

## How to run from scratch

### Step 1. Clone repository

```bash
git clone <your-repo-url>
cd stevia_pathoseq
```

### Step 2. Create folders

```bash
mkdir -p data config envs logs report   refs/custom_lists refs/custom_refs refs/host refs/kraken_curated refs/validation   results/assembly results/host results/nonhost results/pathogen results/qc/raw   results/qc/trimmed results/qc/multiqc results/report results/trim   scripts/helpers scripts/setup scripts/qc scripts/host scripts/pathogen scripts/report   slurm
```

### Step 3. Add input FASTQ files

```bash
cp /path/to/your/*fq.gz data/
```

### Step 4. Edit `config/project.env`

Set:

- `SAMPLE`
- `R1`
- `R2`
- `THREADS`
- `HOST_ACC`

### Step 5. Install Miniforge and environments

```bash
bash create_mamba_envs.sh
```

### Step 6. Run setup on login node

```bash
source "$HOME/miniforge3/etc/profile.d/conda.sh"
conda activate stevia_setup
bash scripts/setup/run_all_setup.sh
```

### Step 7. Submit SLURM jobs

```bash
bash scripts/submit_jobs.sh
```

### Step 8. Render the report

```bash
conda activate stevia_report
bash scripts/report/01_render_report.sh
```

---

## Notes

- This pipeline uses **genome-based host depletion only**.
- No host annotation is required.
- The Kraken2 database is intentionally **lighter and curated**, not exhaustive.
- The bacterial and fungal downloads are based on **curated plant-associated genera**.
- Viral references are downloaded separately and merged into the custom Kraken2 library.
- The report prioritizes taxa relevant to **Stevia and plant pathology** through a manual watchlist.

---

## Troubleshooting

### Kraken2 viral download problems

If NCBI downloads are unstable, rerun:

```bash
bash scripts/setup/08_download_viral_refs.sh
bash scripts/setup/09_merge_viral_refs.sh
bash scripts/setup/10_add_refs_to_kraken_library.sh
```

### Missing non-host reads

Check:

```bash
results/host/<SAMPLE>.hisat2.summary.txt
```

If nearly all reads align to host, non-host output may be small.

### Report renders empty or fails

Check that these files exist first:

```text
results/trim/<SAMPLE>.fastp.json
results/host/<SAMPLE>.hisat2.summary.txt
results/pathogen/<SAMPLE>.k2.report
results/pathogen/<SAMPLE>.bracken.species.tsv
results/pathogen/<SAMPLE>.coverage.tsv
results/pathogen/<SAMPLE>.depth.tsv
results/pathogen/<SAMPLE>.contigs_vs_pathogen_refs.tsv
refs/validation/reference_map.tsv
refs/custom_lists/stevia_priority_watchlist.tsv
```

---

## Repository contents to commit

At minimum, commit:

- `README.md`
- `config/project.env` template
- `envs/*.yml`
- `scripts/`
- `slurm/`
- `report/report.Rmd`
- `report/render_report.R`

Do **not** commit:

- large reference downloads
- Kraken2 databases
- FASTQ files
- BAM files
- large results directories

Add them to `.gitignore`.

---

---

## Citation / tool list

Core tools used by this workflow:

- HISAT2
- FastQC
- MultiQC
- fastp
- Kraken2
- Bracken
- Bowtie2
- rnaSPAdes
- BLAST
- R Markdown

---

## Contact / maintenance

Update the following files first if you adapt the pipeline:

- `config/project.env`
- `scripts/setup/03_write_curated_lists.sh`
- `report/report.Rmd`

These control the sample, curated reference scope, and reporting behavior.
