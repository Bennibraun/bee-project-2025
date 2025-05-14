#!/bin/bash
#SBATCH -p short
#SBATCH --nodes=1
#SBATCH --ntasks=64
#SBATCH --mem=500gb
#SBATCH --time=11:00:00
#SBATCH --job-name=wfmash
#SBATCH --output=/Users/bebr1814/scratch/chuong_data/logs/wfmash.%x-%j.output
#SBATCH --error=/Users/bebr1814/scratch/chuong_data/logs/wfmash.%x-%j.error



eval "$(conda shell.bash hook)"
conda activate wfmash_env

fasta=/Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/pggb/fasta_input/hifiasm.all_contigs.fasta
cat /Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/hifiasm/*/*.fastq.bp.hap*.p_ctg.renamed.fasta > $fasta

# fasta=/Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/pggb/fasta_input/hifiasm.smalltest.fasta


# index
bgzip -@ 64 $fasta
fasta=$fasta.gz
samtools faidx -@ 64 $fasta

wfmash -p 94 -n 90 -t 64 -m -w 1024 $fasta $fasta > ${fasta%.fasta.gz}.wfmash.paf

echo "Done!"