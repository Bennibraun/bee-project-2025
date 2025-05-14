#!/bin/bash
#SBATCH -p short
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mem=50gb
#SBATCH --time=4:00:00
#SBATCH --job-name=match_communities
#SBATCH --output=/Users/bebr1814/scratch/chuong_data/logs/match_communities.%x-%j.output
#SBATCH --error=/Users/bebr1814/scratch/chuong_data/logs/match_communities.%x-%j.error


# Usage: ./align_community.sh community.fasta [num_samples]

# Set defaults
NUM_SAMPLES=${2:-1000}  # Default to 1000 samples if not specified

# Input arguments
COMMUNITY_FASTA=$1
REFERENCE_FASTA=/Users/bebr1814/projects/chuong_bees/data/reference/GCF_003254395.2/GCF_003254395.2_Amel_HAv3.1_genomic.fna
OUTPUT_FILE=$1.chr.txt

# Check if required arguments are provided
if [[ -z "$COMMUNITY_FASTA" ]]; then
    echo "Usage: $0 <community.fasta> [num_samples]"
    exit 1
fi

# Create a temporary file for sampled sequences
SAMPLED_FASTA="$(dirname $COMMUNITY_FASTA)/$(basename $COMMUNITY_FASTA).sampled.$NUM_SAMPLES.fasta"

# Sample sequences
seqtk sample -s42 "$COMMUNITY_FASTA" "$NUM_SAMPLES" > "$SAMPLED_FASTA"

# Align sampled sequences to the reference genome
temp_bam=$(dirname $COMMUNITY_FASTA)/$(basename $COMMUNITY_FASTA).temp.bam
minimap2 -ax asm5 -t 16 "$REFERENCE_FASTA" "$SAMPLED_FASTA" | samtools view -bS | samtools sort -o $temp_bam

# Index the BAM file
samtools index $temp_bam

# Count alignments per chromosome
samtools view $temp_bam | cut -f 3 | sort | uniq -c | sort -nr > "$OUTPUT_FILE"

# Clean up temporary files
rm "$SAMPLED_FASTA" $temp_bam $temp_bam.bai

echo "Alignment summary saved to $OUTPUT_FILE"

