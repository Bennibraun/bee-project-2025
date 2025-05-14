#!/bin/bash


# # Predefined chromosome names
# # these are all the full chromosomes (+mt)
# CHROMS=(">NC_037638.1 Apis mellifera strain DH4 linkage group LG1, Amel_HAv3.1, whole genome shotgun sequence" ">NC_037639.1 Apis mellifera strain DH4 linkage group LG2, Amel_HAv3.1, whole genome shotgun sequence" ">NC_037640.1 Apis mellifera strain DH4 linkage group LG3, Amel_HAv3.1, whole genome shotgun sequence" ">NC_037641.1 Apis mellifera strain DH4 linkage group LG4, Amel_HAv3.1, whole genome shotgun sequence" ">NC_037642.1 Apis mellifera strain DH4 linkage group LG5, Amel_HAv3.1, whole genome shotgun sequence" ">NC_037643.1 Apis mellifera strain DH4 linkage group LG6, Amel_HAv3.1, whole genome shotgun sequence" ">NC_037644.1 Apis mellifera strain DH4 linkage group LG7, Amel_HAv3.1, whole genome shotgun sequence" ">NC_037645.1 Apis mellifera strain DH4 linkage group LG8, Amel_HAv3.1, whole genome shotgun sequence" ">NC_037646.1 Apis mellifera strain DH4 linkage group LG9, Amel_HAv3.1, whole genome shotgun sequence" ">NC_037647.1 Apis mellifera strain DH4 linkage group LG10, Amel_HAv3.1, whole genome shotgun sequence" ">NC_037648.1 Apis mellifera strain DH4 linkage group LG11, Amel_HAv3.1, whole genome shotgun sequence" ">NC_037649.1 Apis mellifera strain DH4 linkage group LG12, Amel_HAv3.1, whole genome shotgun sequence" ">NC_037650.1 Apis mellifera strain DH4 linkage group LG13, Amel_HAv3.1, whole genome shotgun sequence" ">NC_037651.1 Apis mellifera strain DH4 linkage group LG14, Amel_HAv3.1, whole genome shotgun sequence" ">NC_037652.1 Apis mellifera strain DH4 linkage group LG15, Amel_HAv3.1, whole genome shotgun sequence" ">NC_037653.1 Apis mellifera strain DH4 linkage group LG16, Amel_HAv3.1, whole genome shotgun sequence" ">NC_001566.1 Apis mellifera ligustica mitochondrion, complete genome")

# # Input directory containing BAM files
# INPUT_DIR="/Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/assembly_alignments_amelhav3.1/bams"
# # Output directory for extracted FASTA files
# OUTPUT_DIR="/Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/assembly_alignments_amelhav3.1/pggb/fasta_input"
# mkdir -p "$OUTPUT_DIR"

# # Process each BAM file in the input directory
# for BAM in "$INPUT_DIR"/*.bam; do
#     BASENAME=$(cut -d. -f1 <<< $(basename "$BAM"))
    
#     # Extract reads for each chromosome
#     for CHR in "${CHROMS[@]}"; do
#         samtools fasta -@ 4 -F 4 -r "$CHR" "$BAM" > "$OUTPUT_DIR/${BASENAME}_${CHR}.fasta"
#     done

#     # Extract reads that do not align to any of the given chromosomes
#     samtools view -@ 4 -F 4 "$BAM" | awk -v CHROMS="${CHROMS[*]}" '
#     BEGIN {
#         split(CHROMS, arr, " ");
#         for (i in arr) chroms[arr[i]] = 1;
#     }
#     {
#         if (!($3 in chroms)) print $1;
#     }' | samtools fasta -@ 4 -N - "$BAM" > "$OUTPUT_DIR/${BASENAME}_unaligned.fasta"

# done



INPUT_DIR="/Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/flye_assembly"
# Output directory for extracted FASTA files
OUTPUT_DIR="/Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/pggb/fasta_input"
mkdir -p "$OUTPUT_DIR"
OUTPUT_FASTA="$OUTPUT_DIR/all_contigs.fasta"
rm $OUTPUT_FASTA

# loop through assembly.fasta files in the input directory
for ASSEMBLY in "$INPUT_DIR"/*/assembly.fasta; do
	# get the sample ID (flye_assembly/florida1.barcode10.fastq/assembly.fasta -> florida1)
	SAMPLE=$(cut -d. -f1 <<< $(dirname "$ASSEMBLY" | xargs basename))

	# rename reads such that ">contig_100" becomes ">florida1#1#contig_100"
    awk -v sample="$SAMPLE" '
        /^>/ {print ">" sample "#1#" substr($0, 2); next}
        {print}
    ' "$ASSEMBLY" >> $OUTPUT_FASTA
done

samtools faidx $OUTPUT_FASTA

bgzip $OUTPUT_FASTA