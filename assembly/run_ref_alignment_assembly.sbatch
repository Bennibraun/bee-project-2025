#!/bin/bash

## Script for aligning reads to a reference genome using minimap2

# General settings
#SBATCH -p long
#SBATCH -N 1
#SBATCH -c 32
#SBATCH --time=50:00:00
#SBATCH --mem=120GB

# Job name and output
#SBATCH -J minimap2
#SBATCH --output=/Users/bebr1814/scratch/chuong_data/logs/minimap2.%x-%j.output
#SBATCH --error=/Users/bebr1814/scratch/chuong_data/logs/minimap2.%x-%j.error

# Activate conda base environment
eval "$(conda shell.bash hook)"

# Activate minimap2-specific conda environment
conda activate ont

# Define input and output directories
inDir=/Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/flye_assembly
refGenome=/Users/bebr1814/projects/chuong_bees/data/reference/GCF_003254395.2/GCF_003254395.2_Amel_HAv3.1_genomic.fna

# Set query files (get the name of the dir containing the assembly)
queries=($(find "$inDir" -mindepth 2 -maxdepth 2 -type f -name "assembly.fasta"))

outDir=/Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/assembly_alignments_amelhav3.1
mkdir -p $outDir

pwd; hostname; date
echo "Processing file: "${queries[$SLURM_ARRAY_TASK_ID]}

echo $(date +"[%b %d %H:%M:%S] Running minimap2...")

sample_name=$(basename $(dirname ${queries[$SLURM_ARRAY_TASK_ID]}))

# Run minimap2 alignment
minimap2 -ax asm5 -eqx $refGenome ${queries[$SLURM_ARRAY_TASK_ID]} \
    -t 32 > $outDir/${sample_name}.sam

# Convert SAM to BAM and sort
samtools view -Sb $outDir/${sample_name}.sam | samtools sort -o $outDir/${sample_name}.sorted.bam
rm $outDir/${sample_name}.sam

# Index BAM file
samtools index $outDir/${sample_name}.sorted.bam

echo $(date +"[%b %d %H:%M:%S] Done!")