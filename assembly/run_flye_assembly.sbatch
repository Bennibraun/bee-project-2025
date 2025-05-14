#!/bin/bash

## Script for running flye
##
## Example usage:
## inDir=dorado_corrected outDir=flye_assembly genomeSize=1.5g sbatch --array 0-0 flye.sbatch

# General settings
#SBATCH -p long
#SBATCH -N 1
#SBATCH -c 32
#SBATCH --time=100:00:00
#SBATCH --mem=120GB

# Job name and output
#SBATCH -J flye
#SBATCH --output=/Users/bebr1814/scratch/chuong_data/logs/flye.%x-%j.output
#SBATCH --error=/Users/bebr1814/scratch/chuong_data/logs/flye.%x-%j.error

# Activate conda base environment
eval "$(conda shell.bash hook)"

# Activate flye-specific conda environment
conda activate ont

genomeSize=225m
inDir=$1

# Set query files
queries=($(ls $inDir/*.fastq | xargs -n 1 basename))

outDir=flye_assembly/$(basename ${queries[$SLURM_ARRAY_TASK_ID]} .fasta)
mkdir -p $outDir

pwd; hostname; date
echo "Processing file: "${queries[$SLURM_ARRAY_TASK_ID]}

echo $(date +"[%b %d %H:%M:%S] Running flye...")

# use nano-corr for corrected reads
flye --nano-hq $inDir/${queries[$SLURM_ARRAY_TASK_ID]} \
--out-dir $outDir \
--genome-size $genomeSize \
--threads 32

echo $(date +"[%b %d %H:%M:%S] Done!")
