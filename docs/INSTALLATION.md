# Installation and reproducibility

## Overview

This repository provides two modified IslandPath-DIMOB implementations:

- `software/production_control`: primary implementation used for
  the manuscript's 1,400 genomic island predictions.
- `software/expanded_conversion`: alternative coordinate-conversion
  implementation producing 1,578 predictions in a sensitivity analysis.

The two implementations differ in their conversion of candidate
genomic-island regions to coding-sequence boundaries.

## Software requirements

The implementation was tested on Linux with:

- Perl 5.32.1
- HMMER 3.4
- BioPerl 1.7.8
- Config::Simple 4.59
- Log::Log4perl 1.56
- Moose 2.2207
- MooseX::Singleton 0.30

Additional dependencies are resolved by Conda.

## Create the Conda environment

From the repository root:

```bash
conda env create -f environment/environment.yml
conda activate islandpath_dimob

```

## Mobility-gene HMM database

IslandPath-DIMOB requires the mobility-gene profile HMM database
`Pfam-A_mobgenes_201512_prok`.

The database is not included in this repository. Users must obtain
the appropriate database separately from an authorized source.

Prepare the database using HMMER:

    hmmpress /path/to/Pfam-A_mobgenes_201512_prok

This generates the HMMER index files required by `hmmscan`.

## Configuring the database

The `Dimob.config` file contains the HMM database setting:

    hmmer_db = hmmpfam/Pfam-A_mobgenes_201512_prok

The database must be available at this relative location when
running IslandPath-DIMOB, unless the configuration is updated.

The standalone regression script also supports:

    export ISLANDPATH_HMM_DB=/path/to/Pfam-A_mobgenes_201512_prok

This environment variable is used by the regression script,
not automatically by the main IslandPath-DIMOB program.

## Input requirements

The software accepts annotated GenBank genome assemblies.

The reported analysis used contig-aware GenBank inputs with
coding-sequence annotations.

## Running IslandPath-DIMOB

For the production-control implementation:

    cd software/production_control
    perl -Ilib Dimob.pl /path/to/genome.gbk /path/to/genome.gff3

For the expanded-conversion implementation:

    cd software/expanded_conversion
    perl -Ilib Dimob.pl /path/to/genome.gbk /path/to/genome.gff3

Run each implementation from its own directory to ensure
relative configuration paths are resolved correctly.

## Validation

From the repository root, run:

    python scripts/verify_validation.py

This verifies the deposited summary tables. It does not
independently reprocess the original 136 genome assemblies.

The standalone regression test requires the original HPC
analysis input files:

    export ISLANDPATH_BASE=/path/to/original/analysis
    export ISLANDPATH_HMM_DB=/path/to/Pfam-A_mobgenes_201512_prok

    bash scripts/test_standalone.sh RSPAM1

This regression test is not yet self-contained for external users.

## Interpretation of results

The production-control implementation generated 1,400 genomic-island
predictions across 136 dereplicated Pantoea ananatis genomes.

The expanded-conversion implementation generated 1,578 predictions.

The additional 178 predictions represent sensitivity to the
coordinate-conversion method and have not been independently
validated as genuine genomic islands.

Computational reproducibility and coordinate consistency do not
independently establish biological prediction accuracy.

## Environment reproducibility

The recommended installation method is
`environment/environment.yml`, which was tested successfully
using the RSPAM1 multicontig genome.

The file `environment/conda-linux-64-explicit.txt` records the
complete Linux x86-64 package set from the original analysis
environment. It is provided as an archival reference, not as
the recommended minimal installation method.
