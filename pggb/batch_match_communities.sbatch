#!/bin/bash
#SBATCH -p short
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mem=50gb
#SBATCH --time=4:00:00
#SBATCH --job-name=match_communities
#SBATCH --output=/Users/bebr1814/scratch/chuong_data/logs/match_communities.%x-%j.output
#SBATCH --error=/Users/bebr1814/scratch/chuong_data/logs/match_communities.%x-%j.error

# Usage: ./batch_align_communities.sh <directory_with_fastas> [num_samples]

# Set default values
NUM_SAMPLES=${2:-1000}  # Default to 1000 samples if not specified

# Input arguments
INPUT_DIR=$1

# Check if required arguments are provided
if [[ -z "$INPUT_DIR" ]]; then
    echo "Usage: $0 <directory_with_fastas> [num_samples]"
    exit 1
fi

# Loop through each FASTA file in the directory
for FASTA in "$INPUT_DIR"/*.fa; do
    # Run the alignment script
    /Users/bebr1814/projects/chuong_bees/scripts/match_communities_to_chromosomes.sbatch "$FASTA" "$NUM_SAMPLES"
done
