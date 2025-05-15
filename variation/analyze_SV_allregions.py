import os
import glob
import pandas as pd
import matplotlib.pyplot as plt
import re

BED_DIR = "/scratch/Users/milu3967/bedtools_SV_gene_map/output/all_sv"
PLOT_DIR = "/scratch/Users/milu3967/bedtools_SV_gene_map/plots/all_sv"
CSV_DIR  = "/scratch/Users/milu3967/bedtools_SV_gene_map/csv/all_sv"

def parse_info(info_str):
    info_dict = {}
    for item in info_str.split(';'):
        if '=' in item:
            key, val = item.split('=', 1)
            info_dict[key] = val
        else:
            # Some flags have no value (e.g. 'PRECISE')
            info_dict[item] = True
    return info_dict

def parse_gff_attrs(gff_str):
    attrs = {}
    for part in gff_str.split(';'):
        if '=' in part:
            key, val = part.split('=', 1)
            attrs[key] = val
    return attrs

bed_files = sorted(glob.glob(os.path.join(BED_DIR, "*_all_regions.bed")))
if not bed_files:
    print(f"No BED files found in {BED_DIR} matching '*_all_regions.bed'. Exiting.")
    exit(1)

print("Found BED files:")
for f in bed_files:
    print(f"  {f}")

records = []
for f in bed_files:
    basename = os.path.basename(f)
    sample_name = re.sub(r"_all_regions\.bed$", "", basename)

    with open(f, 'r') as infile:
        for line in infile:
            if line.startswith('#') or not line.strip():
                continue
            
            cols = line.strip().split('\t')

            if len(cols) < 14:
                continue

            chrom = cols[0]      
            pos   = int(cols[1]) 
            sv_id = cols[2]      
            ref   = cols[3]
            alt   = cols[4]
            qual  = cols[5]
            fltr  = cols[6]
            info_str = cols[7]
            fmt   = cols[8]  
            sample_gt = cols[9]  

            gene_chrom = cols[10]
            gene_start = cols[11]
            gene_end   = cols[12]
            gff_attrs_str = cols[13]

            info_dict = parse_info(info_str)
            svtype = info_dict.get("SVTYPE", "NA")

            svlen_str = info_dict.get("SVLEN", "0")
            try:
                svlen = abs(int(svlen_str))
            except ValueError:
                svlen = 0
  
            has_overlap = not (gene_chrom == "." or gene_chrom == "")

            gene_id = "NA"
            region_class = "intergenic"
            if has_overlap:
                gene_attrs = parse_gff_attrs(gff_attrs_str)
                gene_id = gene_attrs.get("gene", gene_attrs.get("Name", "NA"))

                gbkey_val = gene_attrs.get("gbkey", None)
                if gbkey_val:
                    gbkey_val = gbkey_val.lower()
                    if "exon" in gbkey_val or "cds" in gbkey_val:
                        region_class = "exonic"
                    elif "utr" in gbkey_val:
                        region_class = "UTR"
                    elif "intron" in gbkey_val:
                        region_class = "intronic"
                    elif "gene" in gbkey_val or "lncrna" in gbkey_val:
                        region_class = "genic_other"
                    else:
                        region_class = "genic_other"
            
            record = {
                "sample": sample_name,
                "chrom": chrom,
                "pos": pos,
                "sv_id": sv_id,
                "svtype": svtype,
                "svlen": svlen,
                "gene_id": gene_id,
                "region_class": region_class,
                "has_overlap": has_overlap  
            }
            records.append(record)

df_raw = pd.DataFrame(records)
print(f"\nParsed {len(df_raw)} lines from bedtools -loj files.\n")


def agg_func(x):
    return pd.Series({
        "svtype": x["svtype"].iloc[0],
        "svlen":  x["svlen"].iloc[0],
        "is_genic_any": x["has_overlap"].any()
    })

df_agg = df_raw.groupby(["sample", "sv_id"], as_index=False).apply(agg_func)

df_agg["region_class"] = df_agg["is_genic_any"].apply(lambda g: "genic" if g else "intergenic")


type_counts = df_agg.groupby(["sample","svtype"]).size().reset_index(name="count")
type_counts_pivot = type_counts.pivot(index="sample", columns="svtype", values="count").fillna(0)

type_counts_pivot.to_csv(os.path.join(CSV_DIR, "sv_type_counts_per_sample.csv"))

type_counts_pivot.plot(kind="bar")
plt.xlabel("Sample")
plt.ylabel("Count of SVs")
plt.title("SV counts by type and sample")
plt.tight_layout()
plt.savefig(os.path.join(PLOT_DIR, "plot_a1_svtype_counts.png"))
plt.close()

bin_edges = [0, 50, 100, 1000, 10000, 1e9]
bin_labels = ["<50","50-100","100-1k","1k-10k",">10k"]
df_agg["size_bin"] = pd.cut(df_agg["svlen"], bins=bin_edges, labels=bin_labels, include_lowest=True)

size_counts = df_agg.groupby(["sample","size_bin"]).size().reset_index(name="count")
size_counts_pivot = size_counts.pivot(index="sample", columns="size_bin", values="count").fillna(0)

size_counts_pivot.to_csv(os.path.join(CSV_DIR, "sv_sizebin_counts_per_sample.csv"))

size_counts_pivot.plot(kind="bar")
plt.xlabel("Sample")
plt.ylabel("Count of SVs")
plt.title("SV counts by size bin")
plt.tight_layout()
plt.savefig(os.path.join(PLOT_DIR, "plot_a2_svsize_distribution.png"))
plt.close()

genic_counts = df_agg.groupby(["sample","region_class"]).size().reset_index(name="count")
genic_pivot = genic_counts.pivot(index="sample", columns="region_class", values="count").fillna(0)


if "genic" in genic_pivot.columns and "intergenic" in genic_pivot.columns:
    pass  
else:
    pass

genic_pivot.to_csv(os.path.join(CSV_DIR, "genic_vs_intergenic_counts_per_sample.csv"))

genic_pivot.plot(kind="bar")
plt.xlabel("Sample")
plt.ylabel("Count of SVs")
plt.title("Genic vs. Intergenic SVs (collapsed duplicates)")
plt.tight_layout()
plt.savefig(os.path.join(PLOT_DIR, "plot_b1_genic_vs_intergenic.png"))
plt.close()

per_bee_counts = df_agg.groupby("sample")["sv_id"].nunique().reset_index(name="total_SVs")
per_bee_counts.to_csv(os.path.join(CSV_DIR, "sv_counts_per_sample.csv"), index=False)

plt.bar(per_bee_counts["sample"], per_bee_counts["total_SVs"])
plt.xticks(rotation=90)
plt.xlabel("Sample")
plt.ylabel("Total distinct SV calls")
plt.title("Total SVs per sample (no multi-gene duplicates)")
plt.tight_layout()
plt.savefig(os.path.join(PLOT_DIR, "plot_c1_total_SVs_per_sample.png"))
plt.close()

sum_svlen = df_agg.groupby("sample")["svlen"].sum().reset_index(name="sum_SV_length")
sum_svlen.to_csv(os.path.join(CSV_DIR, "sum_svlen_per_sample.csv"), index=False)

plt.bar(sum_svlen["sample"], sum_svlen["sum_SV_length"])
plt.xticks(rotation=90)
plt.xlabel("Sample")
plt.ylabel("Sum of SV lengths")
plt.title("Sum of SV lengths per sample")
plt.tight_layout()
plt.savefig(os.path.join(PLOT_DIR, "plot_c2_sum_SVlen_per_sample.png"))
plt.close()

