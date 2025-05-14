#!/bin/bash
#SBATCH -p long
#SBATCH -N 1
#SBATCH -c 32
#SBATCH --time=100:00:00
#SBATCH --mem=120GB

# Job name and output
#SBATCH -J hifiasm
#SBATCH --output=/Users/bebr1814/scratch/chuong_data/logs/hifiasm.%x-%j.output
#SBATCH --error=/Users/bebr1814/scratch/chuong_data/logs/hifiasm.%x-%j.error

# Activate conda base environment
eval "$(conda shell.bash hook)"
conda activate ont

genomeSize=225m
inDir=/Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/fastq

# Set query files
queries=($(ls $inDir/*.fastq | xargs -n 1 basename))

outDir=/Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/hifiasm/$(basename ${queries[$SLURM_ARRAY_TASK_ID]} .fastq)
mkdir -p $outDir
cd $outDir

pwd; hostname; date
echo "Processing file: "${queries[$SLURM_ARRAY_TASK_ID]}

echo $(date +"[%b %d %H:%M:%S] Running hifiasm...")

hifiasm --ont -o ${queries[$SLURM_ARRAY_TASK_ID]} -t 32 $inDir/${queries[$SLURM_ARRAY_TASK_ID]}

echo $(date +"[%b %d %H:%M:%S] Done!")
