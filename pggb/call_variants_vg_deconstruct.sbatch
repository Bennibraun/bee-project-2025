#!/bin/bash
#SBATCH -p short
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --mem=500gb
#SBATCH --time=11:00:00
#SBATCH --job-name=vg_deconstruct
#SBATCH --output=/Users/bebr1814/scratch/chuong_data/logs/vg_deconstruct.%x-%j.output
#SBATCH --error=/Users/bebr1814/scratch/chuong_data/logs/vg_deconstruct.%x-%j.error

eval "$(conda shell.bash hook)"
conda activate pggb

# Use vg deconstruct -t 8 -v -a -p [Amel_path] [gfa]


gfas=($(ls /Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/pggb/hifiasm_communities_runs/*/FINAL_GFA/*.gfaffix.unchop.Ygs.view.gfa))

# grab the gfa for this array job
gfa=${gfas[$SLURM_ARRAY_TASK_ID]}

chrom_name=$(basename $gfa .gfaffix.unchop.Ygs.view.gfa)

cd $(dirname $gfa)

vg deconstruct -t 1 -v -a -P "Amel_Hav3.1" $gfa > $chrom_name.vcf
