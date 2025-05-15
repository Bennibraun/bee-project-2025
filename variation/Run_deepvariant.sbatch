#!/bin/bash
#SBATCH -p long
#SBATCH --nodes=1
#SBATCH --ntasks=10
#SBATCH --mem=25gb
#SBATCH --time=96:00:00
#SBATCH --job-name=DeepVariant_SNV
#SBATCH --output=logs/deepvariant_%A_%a.out
#SBATCH --error=logs/deepvariant_%A_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=milu3967@colorado.edu

module load singularity
module load samtools 

BAM_DIR="/scratch/Users/milu3967/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/alignments_amelhav3.1/bams"
REFERENCE="/scratch/Users/milu3967/SNV_analysis/reference/GCF_003254395.2_Amel_HAv3.1_genomic.fna"
OUTPUT_DIR="/scratch/Users/milu3967/SNV_analysis/deepvariant_outputs"
SIF_PATH="/scratch/Users/milu3967/SNV_analysis/deepvariant.sif" 

FAI_INDEX="${REFERENCE}.fai"

if [ ! -f "$FAI_INDEX" ]; then
    echo "ERROR: Failed to create FASTA index. Exiting."
    exit 1
fi

for BAM in "$BAM_DIR"/*.bam; do
    SAMPLE_NAME=$(basename "$BAM" .bam)

    
    singularity exec --bind /scratch,/scratch/Users/milu3967/SNV_analysis/reference,/scratch/Users/milu3967/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd "$SIF_PATH" run_deepvariant \
        --model_type=ONT_R104 \
        --vcf_stats_report=true \
        --ref="$REFERENCE" \
        --reads="$BAM" \
        --output_vcf="$OUTPUT_DIR/${SAMPLE_NAME}.vcf.gz" \
        --output_gvcf="$OUTPUT_DIR/${SAMPLE_NAME}.g.vcf.gz" \
        --num_shards=10 \
        --regions allowed_regions.bed \
        --intermediate_results_dir "$OUTPUT_DIR/intermediate_results" 

    echo "Completed processing $SAMPLE_NAME"
done
