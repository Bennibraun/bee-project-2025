#!/bin/bash
#SBATCH -p short
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=20gb
#SBATCH --time=2:00:00
#SBATCH --job-name=odgi_compute_depth
#SBATCH --output=/Users/bebr1814/scratch/chuong_data/logs/odgi_compute_depth.%x-%j.output
#SBATCH --error=/Users/bebr1814/scratch/chuong_data/logs/odgi_compute_depth.%x-%j.error

# run with sbatch --array=0-16

# 17 chromosomes

# Activate conda base environment
eval "$(conda shell.bash hook)"

conda activate pggb


# odgi depth -i NC_037642.1.gfaffix.unchop.Ygs.og --path Amel_Hav3.1#1#NC_037642.1 | bedtools makewindows -b /dev/stdin -w 5000 > Amel_Hav3.1.NC_037642.1.5kbp_windows.bed
# odgi depth -i NC_037642.1.gfaffix.unchop.Ygs.og -b Amel_Hav3.1.NC_037642.1.5kbp_windows.bed --threads 1 | bedtools sort > Amel_Hav3.1.NC_037642.1.5kbp_windows.depth.bed
# run these on all og files
# /Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/pggb/hifiasm_communities_runs/*/FINAL_ODGI/*.og

# og_files=($(ls /Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/pggb/hifiasm_communities_runs/*/FINAL_ODGI/*.og))
og_files=($(ls /Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/pggb/flye_run/chrom_graphs/ODGI/*.og))

og=${og_files[$SLURM_ARRAY_TASK_ID]}


# get the path name from the og file that matches Amel_Hav3.1
chrom_name=$(basename $og .og)

cd $(dirname $og)

# loop through paths and write the specific path to a file
# go through florida1, florida2, and tokyo3 specifically. hardcode below
# samples=("florida1" "florida3" "florida4" "thailand1" "thailand2" "thailand4" "tokyo1" "tokyo2" "tokyo3")
samples=("florida1" "florida2" "florida3" "florida4" "thailand1" "thailand2" "thailand4" "tokyo1" "tokyo2" "tokyo3")
for path in "${samples[@]}"; do

	# # do this for each haplotype (1 and 2)
	# for hap in {1..2}; do
	# 	# get every path name that starts with the sample name and write them all to a file, one per line
	# 	odgi paths -i $og -L | grep "${path}#${hap}" > $path.hap$hap.paths.txt

	# 	# run odgi depth
	# 	odgi depth -i $og --path Amel_HAv3.1#1#$chrom_name --subset-paths $path.hap$hap.paths.txt | bedtools makewindows -b /dev/stdin -w 5000 > $chrom_name.$path.hap$hap.5kbp_windows.bed
	# 	odgi depth -i $og -b $chrom_name.5kbp_windows.bed --subset-paths $path.hap$hap.paths.txt --threads 1 | bedtools sort > $chrom_name.$path.hap$hap.5kbp_windows.depth.bed

	# 	rm $chrom_name.$path.hap$hap.5kbp_windows.bed
	# 	rm $path.hap$hap.paths.txt

	# done

	# No haplotypes
	odgi paths -i $og -L | grep "${path}#1" > $chrom_name.$path.paths.txt
	odgi depth -i $og --path Amel_HAv3.1#1#$chrom_name --subset-paths $chrom_name.$path.paths.txt | bedtools makewindows -b /dev/stdin -w 5000 > $chrom_name.$path.5kbp_windows.bed
	odgi depth -i $og -b $chrom_name.$path.5kbp_windows.bed --subset-paths $chrom_name.$path.paths.txt --threads 1 | bedtools sort > $chrom_name.$path.5kbp_windows.depth.bed
	rm $chrom_name.$path.5kbp_windows.bed
	rm $chrom_name.$path.paths.txt

done

echo "Done"
