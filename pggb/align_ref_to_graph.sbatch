#!/bin/bash
#SBATCH -p short
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mem=50gb
#SBATCH --time=11:00:00
#SBATCH --job-name=align_ref_to_graph
#SBATCH --output=/Users/bebr1814/scratch/chuong_data/logs/align_ref_to_graph.%x-%j.output
#SBATCH --error=/Users/bebr1814/scratch/chuong_data/logs/align_ref_to_graph.%x-%j.error

# run with sbatch --array=0-16

# 17 chromosomes

# Activate conda base environment
eval "$(conda shell.bash hook)"

# Activate minimap2-specific conda environment
conda activate pggb

# slurm array selection
gfa_files=($(ls /Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/pggb/hifiasm_communities_runs/*/FINAL_GFA/*.gfa))

gfa=${gfa_files[$SLURM_ARRAY_TASK_ID]}

ref_genome=/Users/bebr1814/projects/chuong_bees/data/reference/GCF_003254395.2/GCF_003254395.2_Amel_HAv3.1_genomic.fna

# make output directory one level up from gfa file
outDir=$(dirname $gfa)/alignments_amelhav3.1
mkdir -p $outDir

# Run minigraph
# -c: base alignment
# -x asm: assembly to reference mapping
# -t: number of threads
# gfa output file: https://github.com/lh3/gfatools/blob/master/doc/rGFA.md#the-graph-alignment-format-gaf
minigraph -c -x asm -t 16 $gfa $ref_genome > $outDir/$(basename $gfa).gaf

echo "Alignment complete. Output file: $outDir/$(basename $gfa).gaf"


# # Get stats
# # conda activate gaftools
# # gaftools stat -o $gaf.stats $gaf
# for gaf in /Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/pggb/hifiasm_communities_runs/*/FINAL_GFA/alignments_amelhav3.1/*.gaf; do
# 	echo "Processing $gaf"
# 	# Get stats
# 	gaftools stat -o $gaf.stats $gaf
# done
