

# make a 1d viz of the coverage
odgi viz -i NC_037642.1.gfaffix.unchop.Ygs.og -o path_cov_viz.png -x 2000 -O

# make a graph depth bed file of 5kbp windows following the path Amel_Hav3.1#1#NC_037642.1
odgi depth -i NC_037642.1.gfaffix.unchop.Ygs.og --path Amel_Hav3.1#1#NC_037642.1 | bedtools makewindows -b /dev/stdin -w 5000 > Amel_Hav3.1.NC_037642.1.5kbp_windows.bed
odgi depth -i NC_037642.1.gfaffix.unchop.Ygs.og -b Amel_Hav3.1.NC_037642.1.5kbp_windows.bed --threads 1 | bedtools sort > Amel_Hav3.1.NC_037642.1.5kbp_windows.depth.bed


# make a layout of the graph for the path Amel_Hav3.1#1#NC_037642.1
odgi layout -i NC_037642.1.gfaffix.unchop.Ygs.og -o Amel_Hav3.1.NC_037642.1.lay