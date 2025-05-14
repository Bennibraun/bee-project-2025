#!/bin/bash
#SBATCH -p nvidia-a100
#SBATCH --time=24:00:00
#SBATCH --mem=128GB
#SBATCH --cpus-per-task=16
#SBATCH --gres=gpu:1
#SBATCH -J dorado_demux
#SBATCH --output=/Users/bebr1814/scratch/chuong_data/logs/dorado_demux.%x-%j.output
#SBATCH --error=/Users/bebr1814/scratch/chuong_data/logs/dorado_demux.%x-%j.error

# usage: sbatch run_dorado_demux.sbatch

# to test on a node first:
# srun --partition=nvidia-a100-40GB --gres=gpu:1 -c 16 --mem=40GB --pty bash

# to check which nodes are available:
# sinfo

# for more detailed info:
# sinfo --node fijigpu-06 -O nodehost,cpusstate,gres,memory

# to check current allocation of gpus:
# scontrol show node=fijigpu-06

dorado=/Users/bebr1814/projects/chuong_bees/CL_Shared/programs/dorado-0.9.0-linux-x64/bin/dorado

pwd; hostname; date
echo "dorado version: "$($dorado --version)
echo $(date +"[%b %d %H:%M:%S] Running dorado demux...")

# run dorado
# default is to use all available GPUs (--device cuda:all)
mkdir -p calls
$dorado demux --output-dir calls --no-classify calls.bam --emit-fastq

echo $(date +"[%b %d %H:%M:%S] Done!")
