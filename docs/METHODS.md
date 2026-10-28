# Methods wording (review before manuscript submission)

Genomic islands (GIs) were predicted in 136 *Pantoea ananatis* genomes using a modified IslandPath-DIMOB implementation (Bertelli and Brinkman, 2018; repository: https://github.com/jjpadilla1987/islandpath). Modifications addressed processing of fragmented multicontig assemblies by preserving contig boundaries during candidate-region clustering. The production coordinate-conversion implementation was retained for primary analysis. A controlled alternative expanded each retained six-CDS window to its constituent CDSs before downstream mobility-gene filtering. Predictions were compared by contig and interval coordinates across all genomes. The control reproduced all production GI coordinates exactly (1,400 islands), whereas the expanded conversion produced 1,578 islands. Both datasets were screened for unknown contigs, invalid boundaries, duplicate intervals and within-method overlaps, using normalized accession identifiers when GenBank and GFF3 version suffixes differed. No coordinate-integrity issues remained after identifier reconciliation. The 1,400-island implementation was used for primary comparisons; the expanded version was considered a sensitivity analysis, not a confirmed improvement in biological specificity.

## Reporting caveats

- Verify that the deposited source actually implements the described contig-specific clustering and coordinate conversion.
- Record the upstream baseline/version and provide a diff against it; do not equate a production-control match with upstream equivalence.
- GI prediction is computational and requires independent biological corroboration.
- The choice of production vs expanded implementation is methodological and should be explicit.
- Record software versions, HMM database provenance, commands, and checksums.
