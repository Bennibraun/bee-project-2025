#!/bin/bash


# Go through the .og files and look for strings matching "Amel_HAv3.1#1#NC"
# Matching files need to be copied over to the new dir, with the file name modified to include the matched chromosome name e.g. Amel_HAv3.1#1#NC_037642.1.gfaffix.unchop.Ygs.og

# Activate conda base environment
eval "$(conda shell.bash hook)"
conda activate pggb

# Get the list of og files
og_dir=/Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/pggb/flye_run/nextflow/FINAL_ODGI
new_og_dir=/Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/pggb/flye_run/chrom_graphs/ODGI
gfa_dir=/Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/pggb/flye_run/nextflow/FINAL_GFA
new_gfa_dir=/Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/pggb/flye_run/chrom_graphs/GFA

for gfa in $gfa_dir/*.gfa; do
	# Look for the string "Amel_HAv3.1#1#NC" in the file contents
	if grep -q "Amel_HAv3.1#1#NC" "$gfa"; then
		# Get the rest of the chromosome name (e.g. Amel_Hav3.1#1#NC_037642.1) and cut off the Amel_Hav3.1#1# part
		chrom_name=$(grep -o "Amel_HAv3.1#1#NC_[0-9]*" "$gfa" | cut -d'#' -f3)
		chrom_name=$chrom_name.1
		echo $chrom_name
		# Copy the file to the new directory with the new name
		cp "$gfa" "$new_gfa_dir/$chrom_name.gfa"
		# grab the matching og file
		og=${gfa/.view.gfa/.og}
		og=${og/FINAL_GFA/FINAL_ODGI}
		# Copy the og file to the new directory with the new name
		cp "$og" "$new_og_dir/$chrom_name.og"
	fi
done

# Missing:
# Amel_HAv3.1#1#NC_037647.1 (community 9)
# Amel_HAv3.1#1#NC_037649.1 (community 8)