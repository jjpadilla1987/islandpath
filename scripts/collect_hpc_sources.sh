#!/usr/bin/env bash
set -euo pipefail
BASE=${ISLANDPATH_BASE:-/ddnA/work/jpadilla/jroja11/pan_analysis/reanalyze/islandpath_dimob}
REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
CONTROL="$BASE/validation/islandpath_conversion_control"
EXPANDED="$BASE/islandpath_multicontig_fixed"
for source in "$CONTROL" "$EXPANDED"; do
  test -f "$source/Dimob.pl" || { echo "Missing: $source/Dimob.pl" >&2; exit 1; }
  test -f "$source/lib/Dimob.pm" || { echo "Missing: $source/lib/Dimob.pm" >&2; exit 1; }
done
mkdir -p "$REPO/software" "$REPO/validation/hpc"
# Copy only code and configuration. Runtime HMM databases may have separate licenses.
for method in production_control expanded_conversion; do
  if [[ "$method" == production_control ]]; then source="$CONTROL"; else source="$EXPANDED"; fi
  target="$REPO/software/$method"
  mkdir -p "$target"
  cp "$source/Dimob.pl" "$source/Dimob.config" "$target/"
  rsync -a --delete --exclude='*.log' --exclude='*.ptt' --exclude='*.gbk' --exclude='*.gff3' --exclude='*.hmm' --exclude='*.h3*' "$source/lib/" "$target/lib/"
done
# Diff is expected to be nonzero because the conversion call is intentionally different.
diff -ru "$REPO/software/production_control" "$REPO/software/expanded_conversion" > "$REPO/validation/hpc/control_vs_expanded.diff" || true
find "$REPO/software" -type f -print0 | sort -z | xargs -0 sha256sum > "$REPO/validation/hpc/software_sha256.txt"
RUN="$BASE/validation/full_136_comparison"
for f in genome_comparison.csv island_comparison.csv validation_summary.csv coordinate_qc_summary.csv coordinate_issues.csv overlap_comparison.csv genomes.txt; do
  if [[ -f "$RUN/$f" ]]; then cp "$RUN/$f" "$REPO/validation/hpc/$f"; fi
done
printf '\nSource trees collected. Review diff and licenses before committing.\n'
echo 'Diff lines:'; wc -l "$REPO/validation/hpc/control_vs_expanded.diff"
