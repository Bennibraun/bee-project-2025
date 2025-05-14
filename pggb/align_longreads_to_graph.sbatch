#!/bin/bash
#SBATCH -p short
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mem=40gb
#SBATCH --time=23:00:00
#SBATCH --job-name=align_longreads_to_graph
#SBATCH --output=/Users/bebr1814/scratch/chuong_data/logs/align_longreads_to_graph.%x-%j.output
#SBATCH --error=/Users/bebr1814/scratch/chuong_data/logs/align_longreads_to_graph.%x-%j.error

# run with sbatch --array=0-16

# 17 chromosomes

# Activate conda base environment
eval "$(conda shell.bash hook)"

# Activate minimap2-specific conda environment
conda activate pggb

# slurm array selection
# gfa_files=($(ls /Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/pggb/hifiasm_communities_runs/*/FINAL_GFA/*.gfa))

# gfa=${gfa_files[$SLURM_ARRAY_TASK_ID]}
gfa=/Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/pggb/hifiasm_communities_runs/NC_037649.1/FINAL_GFA/NC_037649.1.gfaffix.unchop.Ygs.view.gfa


#/Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/fastq/florida1.barcode10.fastq
bee_id=$(basename $1 | cut -d'.' -f1)

# make output directory one level up from gfa file
outDir=$(dirname $gfa)/alignments_${bee_id}
mkdir -p $outDir

out_gaf=$outDir/${bee_id}.$(basename $gfa).gaf

# Run minigraph
# -c: base alignment
# -x asm: assembly/reference to graph mapping, lr: long read to graph mapping
# -t: number of threads
# gfa output file: https://github.com/lh3/gfatools/blob/master/doc/rGFA.md#the-graph-alignment-format-gaf
minigraph -c -x lr -t 16 $gfa $1 > $out_gaf

echo "Alignment complete. Output file: $out_gaf"


# # Get stats
conda deactivate
conda activate gaftools

gaftools stat -o $out_gaf.stats $out_gaf

echo "Stats complete. Output file: $out_gaf.stats"

echo "DONE"
