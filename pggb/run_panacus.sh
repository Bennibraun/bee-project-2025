#!/bin/bash

gfa_list=($(ls /Users/bebr1814/projects/chuong_bees/data/20250211_1135_P2S-00613-A_PBA08559_66fdcccd/uncorrected_fastq/pggb/hifiasm_communities_runs/*/FINAL_GFA/*.gfa))

for gfa in ${gfa_list[@]}; do
	cd $(dirname $gfa)
	mkdir -p panacus
	cd panacus
	panacus histgrowth -t6 -q 0.1,0.5,1 -S $gfa > histgrowth.tsv
	panacus-visualize -e histgrowth.tsv > histgrowth.pdf
done

