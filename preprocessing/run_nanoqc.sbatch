#!/bin/bash
#SBATCH -p short
#SBATCH -N 1
#SBATCH -c 32
#SBATCH --time=24:00:00
#SBATCH --mem=128GB
#SBATCH -J nano_qc
#SBATCH --output=/Users/bebr1814/scratch/chuong_data/logs/nano_qc.%x-%j.output
#SBATCH --error=/Users/bebr1814/scratch/chuong_data/logs/nano_qc.%x-%j.error

# Activate virtual environment
eval "$(conda shell.bash hook)"
conda activate nanopore_qc

pwd; hostname; date

inDir=/Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/region_merged
cd $inDir

# Set query files
queries=($(ls fasta/*.fasta | xargs -n 1 basename))



echo "Starting NanoStat..."
# Make output dir, if it doesn't exist
outDir=nanostat
mkdir -p $outDir

for i in ${!queries[@]}; do
	echo "Processing file: "${queries[$i]}
	NanoStat --fastq fasta/${queries[$i]} \
	--name ${queries[$i]%.fastq}_stats.txt \
	--outdir $outDir \
	--threads 32
done

echo $(date +"[%b %d %H:%M:%S] Done!")


echo "Starting NanoPlot..."

# Make output dir, if it doesn't exist
outDir=nanoplot
mkdir -p $outDir

for i in ${!queries[@]}; do
	echo "Processing file: "${queries[$i]}
	NanoPlot --fastq fasta/${queries[$i]} \
	--prefix ${queries[$i]%.fastq} \
	--outdir $outDir \
	--threads 32
done


# Not using Cramino bc it requires bam/cram

# echo "Starting Cramino..."

# # Make output dir, if it doesn't exist
# outDir=cramino
# mkdir -p $outDir

# for i in ${!queries[@]}; do
# 	echo "Processing file: "${queries[$i]}
# 	cramino --threads 32 \
# 	--hist \
# 	--arrow "${queries[$i]}.arrow" \
# 	--ubam \
# 	fastq/${queries[$i]}
# done

# echo $(date +"[%b %d %H:%M:%S] Done!")
