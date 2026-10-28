#!/usr/bin/env python3
"""Verify published per-genome summary consistency; no external dependencies."""
import csv
from pathlib import Path
root = Path(__file__).resolve().parents[1]
path = root / 'validation/genome_comparison.csv'
with path.open(newline='') as f:
    rows = list(csv.DictReader(f))
assert len(rows) == 136, f'Expected 136 genomes, found {len(rows)}'
assert len({r['genome'] for r in rows}) == 136
sums = {k: sum(int(r[k]) for r in rows) for k in ('production_gis','control_gis','expanded_gis')}
assert sums == {'production_gis':1400,'control_gis':1400,'expanded_gis':1578}, sums
assert all(r['production_control_exact'].strip().lower() == 'true' for r in rows)
assert sum(int(r['expanded_minus_control']) for r in rows) == 178
print('PASS: 136 genomes, production/control 1,400, expanded 1,578, all production-control exact.')
print('NOTE: This validates the summary table, not raw GFF3s or source-code equivalence.')
