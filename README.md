# IslandPath-DIMOB: multicontig validation and coordinate-conversion sensitivity

This repository documents a modified IslandPath-DIMOB workflow for fragmented, multicontig bacterial assemblies, with validation on 136 *Pantoea ananatis* genomes.

**Important:** This deposit kit contains the documentation, scripts and aggregate validation tables. The actual modified Perl software must be collected from the HPC installation using `scripts/collect_hpc_sources.sh` before publishing. Do not describe this kit alone as a complete executable patch.

## Implementation variants

- `software/production_control/`: multicontig-aware implementation using `defline2gi()` for conversion of candidate dinucleotide windows to CDS coordinates. This reproduces the production GFF3s exactly across 136 genomes (1,400 islands).
- `software/expanded_conversion/`: same implementation, except the relevant conversion call uses `windows_to_cds()`. This yields 1,578 islands, including 178 intervals without overlap with control islands. **Experimental sensitivity variant, not an independently validated improvement.**

The controlled source comparison should show exactly one intended conversion-call difference in `lib/Dimob.pm`. The scripts verify this. Differences from upstream IslandPath-DIMOB must be documented in a separate upstream diff before claiming a specific upstream patch.

## Validation findings

| Measurement | Control | Expanded |
| --- | ---: | ---: |
| Genomes | 136 | 136 |
| GI intervals | 1,400 | 1,578 |
| Total GI bp | 36,397,837 | 47,603,331 |
| Coordinate violations | 0 | 0 |
| Duplicate intervals | 0 | 0 |
| Overlapping intervals within a method | 0 | 0 |

- All 136 production GFF3s matched the control implementation exactly by `(contig, start, end)`.
- Every control island overlaps one expanded island; all control sequence coverage is contained in expanded coverage.
- Expanded-only intervals: 178, totaling 3,780,616 bp.
- Extensions of the 1,400 existing intervals add 7,424,878 bp.
- Total additional sequence: 11,205,494 bp.
- GenBank record IDs with version suffixes (e.g., `.1`) were matched to versionless GFF3 sequence IDs during QC; no source GFF3 was edited.

These are **computational reproducibility and coordinate integrity** findings. They do not prove that any candidate island was acquired by horizontal transfer or that the expanded method has higher biological accuracy.

## Repository layout

- `software/` — populated from the actual HPC source directories by the collection script
- `scripts/collect_hpc_sources.sh` — collect the two executable implementations, checksums, and source comparison
- `scripts/verify_validation.py` — verify summary invariants from published comparison tables
- `validation/` — per-genome comparison and GI summary tables, plus analysis summary
- `figures/` — optional R script for Figure 4; separate Gubbins/MOB-suite/FastBAPS inputs not distributed here
- `docs/METHODS.md` — suggested methods wording and caveats
- `docs/RELEASE_CHECKLIST.md` — pre-publication review

## Reproduction

On the LSU HPC, run:

```bash
bash scripts/collect_hpc_sources.sh
python scripts/verify_validation.py
```

For execution, install the dependencies and follow the original IslandPath-DIMOB usage, supplying an input GenBank and output GFF3 filename:

```bash
perl software/production_control/Dimob.pl genome.gbk genome.gff3
```

**Reproducibility requires the original input assemblies, source versions, runtime dependencies, and the exact command environment.** The validation tables are provided as small audit artifacts; full genomic inputs and output files are intentionally not included in this kit.

## Attribution and licensing

Original method: IslandPath-DIMOB, Bertelli and Brinkman (2018). Cite the original publication and this repository with a versioned release/commit identifier. **Verify the upstream software license and preserve all copyright notices before redistributing modified source code.** No license is granted by this deposit kit for third-party source code.
