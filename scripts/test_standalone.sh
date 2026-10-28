#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
: "${ISLANDPATH_BASE:?Set ISLANDPATH_BASE to the original analysis directory}"

GENOME="${1:-RSPAM1}"
INPUT="$ISLANDPATH_BASE/first_cds_136/input/${GENOME}.fixed.gbk"
DB="$ISLANDPATH_BASE/islandpath_multicontig_fixed/hmmpfam/Pfam-A_mobgenes_201512_prok"

TEST="$ROOT/validation/standalone_test/$GENOME"

[[ -f "$INPUT" ]] || { echo "Missing input: $INPUT"; exit 1; }
[[ -f "$DB" ]] || { echo "Missing HMM database: $DB"; exit 1; }

mkdir -p "$TEST"

echo "Genome: $GENOME"
echo "Input: $INPUT"

for METHOD in production_control expanded_conversion; do

    echo
    echo "=== Testing $METHOD ==="

    SRC="$ROOT/software/$METHOD"
    WORK="$TEST/$METHOD"

    mkdir -p "$WORK/hmmpfam"

    cp "$INPUT" "$WORK/${GENOME}.fixed.gbk"

    # Use the deposited source files, not the original source tree.
    cp -a "$SRC/." "$WORK/"

    # Supply the HMM database as an external dependency.
    ln -sfn "$DB" "$WORK/hmmpfam/Pfam-A_mobgenes_201512_prok"

    for EXT in h3f h3i h3m h3p; do
        ln -sfn "${DB}.${EXT}" \
            "$WORK/hmmpfam/Pfam-A_mobgenes_201512_prok.${EXT}"
    done

    (
        cd "$WORK"

        perl -Ilib Dimob.pl \
            "${GENOME}.fixed.gbk" \
            "${GENOME}.dimob_output.txt" \
            > run.stdout.log 2> run.stderr.log
    )

    echo "Completed: $METHOD"

    find "$WORK" -maxdepth 1 -type f \
        \( -name '*.gff3' -o -name '*output.txt' \) \
        -printf '%f (%s bytes)\n'

done

echo
echo "Standalone test completed."
echo "Results: $TEST"
