#!/bin/bash
#SBATCH -p short
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --mem=40gb
#SBATCH --time=11:00:00
#SBATCH --job-name=align_to_gfa_vg_map
#SBATCH --output=/Users/bebr1814/scratch/chuong_data/logs/align_to_gfa_vg_map.%x-%j.output
#SBATCH --error=/Users/bebr1814/scratch/chuong_data/logs/align_to_gfa_vg_map.%x-%j.error

# sbatch /Users/bebr1814/projects/chuong_bees/scripts/pggb/align_to_graph_vg_map.sbatch /Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/pggb/flye_run/chrom_graphs/GFA/NC_001566.1.gfa /Users/bebr1814/projects/chuong_bees/data/public/PRJNA292680_WGS/fastq/SRR2157935_1.fastq /Users/bebr1814/projects/chuong_bees/data/public/PRJNA292680_WGS/fastq/SRR2157935_2.fastq


set -euo pipefail

cd /Users/bebr1814/projects/chuong_bees/data/public/PRJNA292680_WGS/vg_map_alignments

# Input files
GFA=$1                # e.g. your_graph.gfa
READ1=$2              # e.g. reads_1.fq.gz
READ2=$3              # e.g. reads_2.fq.gz
THREADS=${4:-8}       # Default to 8 threads if not specified

# Derive base names
BASE=$(basename "$GFA" .gfa)
# VG=${BASE}.vg
# XG=${BASE}.xg
# GCSA=${BASE}.gcsa
# GAM=${BASE}.gam
# GAF=${BASE}.gaf

# # # 1. Convert GFA to VG
# # echo "Converting $GFA to VG format..."
# # vg convert -g "$GFA" > "$VG"

# # 1.5. Make the nodes shorter because the index process complained
# echo "Shortening nodes in VG..."
# vg mod -X 256 "$VG" > "$VG.short"
# mv "$VG.short" "$VG"

# # 2. Indexing
# echo "Indexing graph..."
# vg index -x "$XG" -g "$GCSA" -k 16 "$VG"

# # 3. Align reads with vg map
# echo "Mapping reads..."
# vg map -x "$XG" -g "$GCSA" -f "$READ1" -f "$READ2" -t "$THREADS" > "$GAM"

# # 4. Convert to GAF
# echo "Converting GAM to GAF..."
# vg view -a "$GAM" -g > "$GAF"

# echo "Done. Output written to:"
# echo "  $VG"
# echo "  $XG"
# echo "  $GCSA"
# echo "  $GAM"
# echo "  $GAF"


# Instead of vg map, try vg giraffe
# https://github.com/vgteam/vg/wiki/Mapping-short-reads-with-Giraffe

# First, index the graph
echo "gwbt"
date
vg gbwt --gbz-format -g ${BASE}.gbz -G $GFA
echo "done"
date

echo "index"
vg index -j ${BASE}.dist $GFA
echo "done"
date

echo "minimizer"
vg minimizer -d ${BASE}.dist -o ${BASE}.shortread.withzip.min -z ${BASE}.shortread.zipcodes ${BASE}.gbz
echo "done"
date
