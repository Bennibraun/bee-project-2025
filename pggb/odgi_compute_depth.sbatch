#!/bin/bash
#SBATCH -p short
#SBATCH --nodes=1
#SBATCH --ntasks=16
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

# og=${og_files[$SLURM_ARRAY_TASK_ID]}

cd /Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/pggb/flye_run/chrom_graphs/ODGI

for og in "${og_files[@]}"; do


	chrom_name=$(basename $og .og)

	echo $chrom_name


	# run odgi depth
	odgi depth -i $og --path Amel_HAv3.1#1#$chrom_name | bedtools makewindows -b /dev/stdin -w 5000 > $chrom_name.5kbp_windows.bed
	odgi depth -i $og -b $chrom_name.5kbp_windows.bed --threads 1 | bedtools sort > $chrom_name.5kbp_windows.depth.bed

	# # vg specifically
	# chrom_name=NC_037641.1
	# og=/Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/pggb/flye_run/chrom_graphs/ODGI/$chrom_name.og
	# odgi depth -i $og --path Amel_HAv3.1#1#$chrom_name | bedtools makewindows -b /dev/stdin -w 20 | awk -v s=5020485 -v e=5039661 -v chr=$chrom_name '$2 >= s && $3 <= e' > $chrom_name.20bp_windows.bed
	# odgi depth -i $og -b $chrom_name.20bp_windows.bed --threads 1 | bedtools sort > $chrom_name.20bp_windows.depth.bed
	
	# # gapdh specifically 
	# chrom_name=NC_037647.1
	# og=/Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/pggb/flye_run/chrom_graphs/ODGI/$chrom_name.og
	# odgi depth -i $og --path Amel_HAv3.1#1#$chrom_name | bedtools makewindows -b /dev/stdin -w 20 | awk -v s=10691747 -v e=10702395 -v chr=$chrom_name '$2 >= s && $3 <= e' > $chrom_name.20bp_windows.bed
	# odgi depth -i $og -b $chrom_name.20bp_windows.bed --threads 1 | bedtools sort > $chrom_name.20bp_windows.depth.bed
	

done


# # get the path name from the og file that matches Amel_Hav3.1
# # chrom_name=$(basename $og .gfaffix.unchop.Ygs.og)
# chrom_name=$(basename $og .og)

# cd $(dirname $og)

# # run odgi depth
# odgi depth -i $og --path Amel_HAv3.1#1#$chrom_name | bedtools makewindows -b /dev/stdin -w 5000 > $chrom_name.5kbp_windows.bed
# odgi depth -i $og -b $chrom_name.5kbp_windows.bed --threads 1 | bedtools sort > $chrom_name.5kbp_windows.depth.bed


echo "Done"