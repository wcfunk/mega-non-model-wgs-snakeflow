#!/usr/bin/env bash
# group_fastqs_by_underscores_combined.sh
# Usage:
#   ./group_fastqs_by_underscores_combined.sh [ROOT] [GLOB] [subdir1 subdir2 ...]
# Defaults:
#   ROOT=data/fastqs
#   GLOB='*gz'       # matches .fq.gz and .fastq.gz (and other *gz if present)

set -euo pipefail

ROOT="${1:-data/fastqs}"
GLOB="${2:-*gz}"
shift || true
shift || true

# Clean any old combined outputs in the CWD.
rm -f fastq_listing.underscores-*.txt 2>/dev/null || true

# Subdirs to process: user-provided or discover all immediate subdirs of ROOT.
declare -a SUBDIRS=("$@")
if [ ${#SUBDIRS[@]} -eq 0 ]; then
  while IFS= read -r -d '' d; do
    SUBDIRS+=("$d")
  done < <(find "$ROOT" -mindepth 1 -maxdepth 1 -type d -print0)
fi

found_any=0
for dir in "${SUBDIRS[@]}"; do
  # Accept either bare names (e.g., wm152) or full paths.
  if [[ "$dir" != /* && "$dir" != "$ROOT/"* ]]; then
    path="$ROOT/$dir"
  else
    path="$dir"
  fi

  [[ -d "$path" ]] || { echo "Skip (not a directory): $path" >&2; continue; }

  # Only files directly inside each subdir (no recursion).
  while IFS= read -r -d '' f; do
    found_any=1
    base="${f##*/}"                    # filename only
    underscores="${base//[^_]/}"       # keep only underscores
    count="${#underscores}"            # number of underscores
    ls -l --color=never -- "$f" >> "fastq_listing.underscores-${count}.txt"
  done < <(find "$path" -maxdepth 1 -type f -name "$GLOB" -print0)
done

if [[ $found_any -eq 0 ]]; then
  echo "No files matching '$GLOB' found under: ${SUBDIRS[*]:-all immediate subdirs of $ROOT}" >&2
else
  echo "Wrote combined listings: fastq_listing.underscores-*.txt" >&2
fi
