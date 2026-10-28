# Pre-release checklist

- [ ] Collect **actual** `production_control` and `expanded_conversion` Perl source trees from HPC.
- [ ] Check `software/` contains `Dimob.pl`, `Dimob.config`, required `lib/` modules and licensed runtime data.
- [ ] Confirm the two software trees differ only in the intended `Dimob.pm` conversion call.
- [ ] Record upstream IslandPath-DIMOB source version and generate an upstream-to-patch diff.
- [ ] Review upstream license, redistribution rights, and third-party Pfam/HMM data licenses; include required notices.
- [ ] Review source tree for absolute HPC paths, credentials, user names and unneeded logs.
- [ ] Add tested dependency versions (`perl`, BioPerl, HMMER, other Perl modules) and setup instructions.
- [ ] Validate a single- and multicontig fixture on a fresh environment.
- [ ] Re-run `scripts/verify_validation.py`.
- [ ] Archive immutable input accession list and input GBK checksums (avoid large binary input uploads unless licensed).
- [ ] Include the full 136-genome per-genome comparisons and final coordinate QC results from HPC.
- [ ] Tag a release and record its commit hash in the manuscript citation.
- [ ] Do not publish the experimental expanded variant as an accuracy improvement without independent validation.
