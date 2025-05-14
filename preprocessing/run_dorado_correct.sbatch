#!/bin/bash

## Script for read error correction with dorado
##
## Example usage:
## inDir=calls_default_parameters outDir=dorado_corrected sbatch --array 0-0 dorado_correct.sbatch

## General settings
#SBATCH -p nvidia-a100
#SBATCH --time=4-00:00:00
#SBATCH --mem=500GB
#SBATCH --cpus-per-task=64
#SBATCH --gres=gpu:4
#SBATCH -J dorado_correct
#SBATCH --output=/Users/bebr1814/scratch/chuong_data/logs/dorado_correct.%x-%j.output
#SBATCH --error=/Users/bebr1814/scratch/chuong_data/logs/dorado_correct.%x-%j.error

# to test on a node first:
# srun --partition=nvidia-a100-40GB --gres=gpu:1 -c 16 --mem=40GB --pty bash

# to check which nodes are available:
# sinfo

# for more detailed info:
# sinfo --node fijigpu-06 -O nodehost,cpusstate,gres,memory

# to check current allocation of gpus:
# scontrol show node=fijigpu-06

inDir=/Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/fastq
outDir=/Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/corrected_fastq

dorado=/Users/bebr1814/projects/chuong_bees/CL_Shared/programs/dorado-0.9.0-linux-x64/bin/dorado

# Set query files
queries=($(ls $inDir/*.fastq | xargs -n 1 basename))

# Make output dir, if it doesn't exist
mkdir -p $outDir

pwd; hostname; date
echo "dorado version: "$($dorado --version)
echo "Processing file: "${queries[$SLURM_ARRAY_TASK_ID]}

# run dorado
# default is to use all available GPUs (--device cuda:all) and all available threads
echo $(date +"[%b %d %H:%M:%S] Running dorado correct...")


$dorado correct $inDir/${queries[$SLURM_ARRAY_TASK_ID]} \
--verbose > $outDir/${queries[$SLURM_ARRAY_TASK_ID]%.fastq}.corrected.fasta

echo $(date +"[%b %d %H:%M:%S] Done!")