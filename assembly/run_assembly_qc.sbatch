#!/bin/bash
#SBATCH -p short
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem=10gb
#SBATCH --time=4:00:00
#SBATCH --job-name=asm_qc
#SBATCH --output=/Users/bebr1814/scratch/chuong_data/logs/asm_qc.%x-%j.output
#SBATCH --error=/Users/bebr1814/scratch/chuong_data/logs/asm_qc.%x-%j.error


eval "$(conda shell.bash hook)"
conda activate nanopore_asm

# get input files
inputs=($(ls /Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/hifiasm/*/*ctg.fasta))
cd /Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/hifiasm

# Slurm array
fasta=${inputs[$SLURM_ARRAY_TASK_ID]}
echo "Processing file: $fasta"

# Run QUAST
# https://quast.sourceforge.net/docs/manual.html
mkdir -p quast
cd quast
# quast $fasta -t 4 -o $(basename $(dirname $fasta) .fastq)
quast $fasta -t 4 -o $(basename $fasta .fasta)
cd ..

echo "Done!"

# Run BUSCO
# https://busco.ezlab.org/busco_userguide.html#running-busco
mkdir -p busco
cd busco
# busco -i $fasta -f -o $(basename $(dirname $fasta) .fastq) -m genome --lineage_dataset hymenoptera_odb10 -c 4
busco -i $fasta -f -o $(basename $fasta .fasta) -m genome --lineage_dataset hymenoptera_odb10 -c 4
cd ..

echo "Done!"