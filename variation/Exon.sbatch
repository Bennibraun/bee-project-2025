#!/bin/bash
#SBATCH -p short
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --mem=25gb
#SBATCH --time=0:30:00
#SBATCH --job-name=SV_Bedtools
#SBATCH --output=logs/bedtools_%A_%a.out
#SBATCH --error=logs/bedtools_%A_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=milu3967@colorado.edu
#SBATCH --array=1-10

source ~/.bashrc
eval "$(mamba shell hook --shell bash)"
mamba activate annotsv

VCF_DIR="/scratch/Users/milu3967/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/alignments_amelhav3.1/sniffles_variants"
OUTPUT_DIR="/scratch/Users/milu3967/bedtools_SV_gene_map/output/all_sv/exon"
ANNOTATION_DIR="/scratch/Users/milu3967/bedtools_SV_gene_map/genome_annotations"
GFF_FILE="$ANNOTATION_DIR/GCF_003254395.2_Amel_HAv3.1_genomic.gff"
BED_FILE="$ANNOTATION_DIR/Amel_HAv3.1_exons_cds.bed"

VCF_FILES=(
    "florida1.vcf" "florida2.vcf" "florida3.vcf" "florida4.vcf"
    "thailand1.vcf" "thailand2.vcf" "thailand4.vcf"
    "tokyo1.vcf" "tokyo2.vcf" "tokyo3.vcf"
)

VCF_FILE="${VCF_FILES[$SLURM_ARRAY_TASK_ID - 1]}"

echo "Running bedtools intersect (LOJ) for $VCF_FILE..."
bedtools intersect \
  -a "$VCF_DIR/$VCF_FILE" \
  -b "$BED_FILE" \
  -loj \
  -wa -wb \
  > "$OUTPUT_DIR/${VCF_FILE%.vcf}_all_regions.bed"

mamba deactivate
