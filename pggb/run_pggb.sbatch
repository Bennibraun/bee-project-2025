#!/bin/bash
#SBATCH --job-name=pggb_graph
#SBATCH --output=/Users/bebr1814/scratch/chuong_data/logs/pggb_graph.%x-%j.output
#SBATCH --error=/Users/bebr1814/scratch/chuong_data/logs/pggb_graph.%x-%j.error
#SBATCH --time=48:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=256G
#SBATCH --partition=long

eval "$(conda shell.bash hook)"
conda activate pggb

# Define input directory and output directory
input_reads=/Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/pggb/hifiasm_communities/chromosome_contigs/NC_001566.1.fa
outdir=/Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/pggb/hifiasm_communities_runs/NC_001566.1

# Run pggb
# -p is alignment identity (90%)
# -s is segment length (3000bp) - recommended is 5-10k but we may lose too many reads
# -n is haplotype number (10 bees X 2 haplotypes)
# -k sets the tolerance for local pairwise differences such that sequences can differ by only 1/k (currently 20 which is recommended for ~5% divergence)
pggb -i $input_reads -o $outdir -t 32 -p 90 -s 3000 -n 20 -k 20 --names-with-params --multiqc

echo "Done with pggb graph"