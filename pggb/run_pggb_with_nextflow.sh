#!/bin/bash
#SBATCH -p short
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mem=500gb
#SBATCH --time=11:00:00
#SBATCH --job-name=pggb_nf	
#SBATCH --output=/Users/bebr1814/scratch/chuong_data/logs/pggb_nf.%x-%j.output
#SBATCH --error=/Users/bebr1814/scratch/chuong_data/logs/pggb_nf.%x-%j.error


eval "$(conda shell.bash hook)"
conda activate nextflow

singularity=/usr/bin/singularity


# for fasta in /Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/flye_assembly/*.fastq/assembly.fasta; do
# 	# the sample name is the dirname, split by . and take the first part
# 	SAMPLE=$(basename $(dirname $fasta) | cut -d '.' -f 1)
# 	# copy the file to /Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/pggb/flye_run/fasta
# 	cp $fasta /Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/pggb/flye_run/fasta/$SAMPLE.fasta
# done

# # rename contigs

# INPUT_DIR="/Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/pggb/flye_run/fasta"
# # Output directory for extracted FASTA files
# OUTPUT_DIR="/Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/pggb/flye_run/fasta_pggb"
# mkdir -p "$OUTPUT_DIR"
# OUTPUT_FASTA="$OUTPUT_DIR/all_contigs.fasta"
# rm $OUTPUT_FASTA

# # loop through assembly.fasta files in the input directory
# for ASSEMBLY in "$INPUT_DIR"/*.fasta; do
# 	SAMPLE=$(basename $ASSEMBLY .fasta)

# 	# rename reads such that ">contig_100" becomes ">florida1#1#contig_100"
#     awk -v sample="$SAMPLE" '
#         /^>/ {print ">" sample "#1#" substr($0, 2); next}
#         {print}
#     ' "$ASSEMBLY" >> $OUTPUT_FASTA
# done

# samtools faidx $OUTPUT_FASTA

# bgzip $OUTPUT_FASTA


# INPUT_FASTA="/Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/pggb/hifiasm_communities/chromosome_contigs/NC_001566.1.fa"
# OUTDIR="/Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/pggb/hifiasm_communities_runs/NC_001566.1"
INPUT_FASTA=/Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/pggb/flye_run/fasta_pggb/all_contigs.fasta.gz
OUTDIR=/Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/pggb/flye_run/nextflow
N_HAPLOTYPES=11

cd $OUTDIR

nextflow pull nf-core/pangenome

nextflow run nf-core/pangenome \
	--input $INPUT_FASTA \
	--outdir $OUTDIR \
	--n_haplotypes $N_HAPLOTYPES \
	--communities \
	-profile singularity \
	-resume

