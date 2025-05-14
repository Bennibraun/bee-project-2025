#!/bin/bash
#SBATCH -p short
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --mem=25gb
#SBATCH --time=1:00:00


eval "$(conda shell.bash hook)"
conda activate assembly_qc

cores=8

cd /Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/assembly_alignments_amelhav3.1/sniffles_variants

indir=/Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/assembly_alignments_amelhav3.1/bams
bams=($(ls $indir/*.sorted.bam | xargs -n 1 basename))

# BASE_DIR="/Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/alignments_amelhav3.1/bams"
# find "$BASE_DIR" -mindepth 2 -type f \( -name "alignment.sorted.bam" -o -name "alignment.sorted.bam.bai" \) | while read file; do
#     sample_name=$(basename "$(dirname "$file")")  # Extract the unique directory name
#     ext="${file##*.}"  # Extract file extension (bam or bai)
#     mv "$file" "$BASE_DIR/${sample_name}.sorted.${ext}"
# done
# find . -mindepth 1 -type d -exec rm -r {} +

echo "Processing file: "${bams[$SLURM_ARRAY_TASK_ID]}

# split each file name by "." and get the first element
sample_ids=($(echo ${bams[@]} | tr ' ' '\n' | cut -d'.' -f1 | tr '\n' ' '))
echo "Sample IDs: "${sample_ids[@]}

# # start array
# sniffles --input $bams[]
#  --reference $ref_fa --threads $cores --vcf ${sample_id}_flye_aligned_to_${ref_name}.vcf --output-rnames --allow-overwrite
sniffles --input $indir/${bams[$SLURM_ARRAY_TASK_ID]} --threads $cores --vcf ${sample_ids[$SLURM_ARRAY_TASK_ID]}.vcf --output-rnames --allow-overwrite
 
echo "Done with sniffles"


# bgzip and tabix
for vcf in *.vcf; do
    bgzip -c "$vcf" > "$vcf.gz"
    tabix -p vcf "$vcf.gz"
done

vcf-compare *.vcf.gz > vcf_compare_stats.txt

grep '^VN' vcf_compare_stats.txt | cut -f2- > venn_data.txt
grep '^SN' vcf_compare_stats.txt | grep 'Number of lost sites' | cut -f2- > lost_sites.txt



# convert vcf to bedpe (to be used with Ribbon/SplitThread: https://github.com/marianattestad/ribbon)
# chrom1,start1,stop1,chrom2,start2,stop2,variant_name,score,strand1,strand2,variant_type,split
for vcf in *.vcf; do
    echo "chrom1,start1,stop1,chrom2,start2,stop2,variant_name,score,strand1,strand2,variant_type,split\n" > "${vcf%.vcf}.bedpe"
    grep -v "^#" "$vcf" | awk -v OFS="," '
    {
        split($8, info, ";");
        start1 = $2;
        end1 = start1 + 1;
        
        sv_type=".";
        end2=".";
        for (i in info) {
            if (info[i] ~ /^SVTYPE=/) {
                sv_type = substr(info[i], 8);
            }
            if (info[i] ~ /^END=/) {
                end2 = substr(info[i], 5);
            }
        }
        
        print $1, start1, end1, $1, end2, end2+1, $3, ".", "+", "-", sv_type, "."
    }' >> "${vcf%.vcf}.bedpe"
done

# grab coverage from bams
for bam in /Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/alignments_amelhav3.1/bams/*.bam; do
    mosdepth -n --fast-mode --by 10000 $(basename $bam .bam) $bam
done


# Make consensus calls (https://github.com/fritzsedlazeck/SURVIVOR/wiki)
# 1000kb overlap threshold, 3 samples must support, agree on type and strand, min 30bp size
module load bcftools
for region in florida thailand tokyo; do
    ls ${region}*.vcf > ${region}_vcfs.txt
    SURVIVOR merge ${region}_vcfs.txt 100 3 1 1 0 30 ${region}_consensus.vcf
    bcftools sort -o ${region}_consensus.sorted.vcf ${region}_consensus.vcf
    bgzip ${region}_consensus.sorted.vcf
    tabix -p vcf ${region}_consensus.sorted.vcf.gz
done


# Compare consensus calls
bcftools isec -n~100 -w1 florida_consensus.sorted.vcf.gz thailand_consensus.sorted.vcf.gz tokyo_consensus.sorted.vcf.gz > florida_unique.vcf
bcftools isec -n~100 -w1 thailand_consensus.sorted.vcf.gz florida_consensus.sorted.vcf.gz tokyo_consensus.sorted.vcf.gz > thailand_unique.vcf
bcftools isec -n~100 -w1 tokyo_consensus.sorted.vcf.gz florida_consensus.sorted.vcf.gz thailand_consensus.sorted.vcf.gz > tokyo_unique.vcf

bcftools isec -n~110 -w1 florida_consensus.sorted.vcf.gz thailand_consensus.sorted.vcf.gz tokyo_consensus.sorted.vcf.gz > FL_TH_shared.vcf
bcftools isec -n~110 -w1 florida_consensus.sorted.vcf.gz tokyo_consensus.sorted.vcf.gz thailand_consensus.sorted.vcf.gz > FL_TK_shared.vcf
bcftools isec -n~110 -w1 thailand_consensus.sorted.vcf.gz tokyo_consensus.sorted.vcf.gz florida_consensus.sorted.vcf.gz > TH_TK_shared.vcf

bcftools isec -n~111 -w1 florida_consensus.sorted.vcf.gz thailand_consensus.sorted.vcf.gz tokyo_consensus.sorted.vcf.gz > all_shared.vcf


# Compare individual files
for main_vcf in *.vcf.gz; do
    for compare_vcf in *.vcf.gz; do
        bcftools isec -n~11 -w1 $main_vcf $compare_vcf > pairwise_overlaps/${main_vcf%.vcf}_vs_${compare_vcf}.vcf
    done
done



# Alternate method (not using SURVIVOR)
# Make consensus calls
bcftools isec -n~1111000000 -w1 -c all florida1.vcf.gz florida2.vcf.gz florida3.vcf.gz florida4.vcf.gz thailand1.vcf.gz thailand2.vcf.gz thailand4.vcf.gz tokyo1.vcf.gz tokyo2.vcf.gz tokyo3.vcf.gz > florida_unique.vcf
bcftools isec -n~0000111000 -w1 -c all florida1.vcf.gz florida2.vcf.gz florida3.vcf.gz florida4.vcf.gz thailand1.vcf.gz thailand2.vcf.gz thailand4.vcf.gz tokyo1.vcf.gz tokyo2.vcf.gz tokyo3.vcf.gz > thailand_unique.vcf
bcftools isec -n~0000000111 -w1 -c all florida1.vcf.gz florida2.vcf.gz florida3.vcf.gz florida4.vcf.gz thailand1.vcf.gz thailand2.vcf.gz thailand4.vcf.gz tokyo1.vcf.gz tokyo2.vcf.gz tokyo3.vcf.gz > tokyo_unique.vcf

# Make comparison calls
bcftools isec -n~1111111000 -w1 -c all florida1.vcf.gz florida2.vcf.gz florida3.vcf.gz florida4.vcf.gz thailand1.vcf.gz thailand2.vcf.gz thailand4.vcf.gz tokyo1.vcf.gz tokyo2.vcf.gz tokyo3.vcf.gz > FL_TH_shared.vcf
bcftools isec -n~1111000111 -w1 -c all florida1.vcf.gz florida2.vcf.gz florida3.vcf.gz florida4.vcf.gz thailand1.vcf.gz thailand2.vcf.gz thailand4.vcf.gz tokyo1.vcf.gz tokyo2.vcf.gz tokyo3.vcf.gz > FL_TK_shared.vcf
bcftools isec -n~0000111111 -w1 -c all florida1.vcf.gz florida2.vcf.gz florida3.vcf.gz florida4.vcf.gz thailand1.vcf.gz thailand2.vcf.gz thailand4.vcf.gz tokyo1.vcf.gz tokyo2.vcf.gz tokyo3.vcf.gz > TH_TK_shared.vcf
bcftools isec -n~1111111111 -w1 -c all florida1.vcf.gz florida2.vcf.gz florida3.vcf.gz florida4.vcf.gz thailand1.vcf.gz thailand2.vcf.gz thailand4.vcf.gz tokyo1.vcf.gz tokyo2.vcf.gz tokyo3.vcf.gz > all_shared.vcf

