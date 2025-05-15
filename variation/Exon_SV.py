#!/usr/bin/env python3
import os
import glob
import pandas as pd
import matplotlib.pyplot as plt
import re

BED_DIR  = "/scratch/Users/milu3967/bedtools_SV_gene_map/output/all_sv/exon"
CSV_DIR  = "/scratch/Users/milu3967/bedtools_SV_gene_map/csv/all_sv"
PLOT_DIR = "/scratch/Users/milu3967/bedtools_SV_gene_map/plots/all_sv"

os.makedirs(CSV_DIR,  exist_ok=True)
os.makedirs(PLOT_DIR, exist_ok=True)

def parse_info(info_str):
    info_dict = {}
    for item in info_str.split(';'):
        if '=' in item:
            key, val = item.split('=', 1)
            info_dict[key] = val
        else:
            info_dict[item] = True
    return info_dict

def parse_gff_attrs(gff_str):
    attrs = {}
    parts = gff_str.split(';')
    if parts and not parts[0].startswith("ID="):
        attrs["type"] = parts[0]          
        parts = parts[1:]
    for part in parts:
        if '=' in part:
            key, val = part.split('=', 1)
            attrs[key] = val
    return attrs

bed_files = sorted(glob.glob(os.path.join(BED_DIR, "*_all_regions.bed")))
if not bed_files:
    raise SystemExit(f"No BED files found in {BED_DIR}")

records = []
for f in bed_files:
    sample = re.sub(r"_all_regions\.bed$", "", os.path.basename(f))

    with open(f) as fh:
        for line in fh:
            cols = line.rstrip('\n').split('\t')
            if len(cols) < 14 or cols[10] == ".":   
                continue

            chrom       = cols[0]
            pos         = int(cols[1])
            sv_id       = cols[2]
            info_str    = cols[7]
            gene_attrs  = cols[13]

            info        = parse_info(info_str)
            svtype      = info.get("SVTYPE", "NA")
            svlen       = abs(int(info.get("SVLEN", 0)))

            gattrs      = parse_gff_attrs(gene_attrs)
            gene_id     = gattrs.get("gene", gattrs.get("Name", "NA"))
            feature     = gattrs.get("type", "").lower()

            if feature in {"exon", "cds"}:
                records.append({
                    "sample":  sample,
                    "gene_id": gene_id,
                    "sv_id":   sv_id,
                    "svtype":  svtype,
                    "svlen":   svlen,
                })

df = pd.DataFrame(records)
print(f"Extracted {len(df)} exon‑overlapping SV records.")


df_unique = df.drop_duplicates(subset=["sample", "sv_id", "gene_id"])

per_sample_counts = (
    df_unique
      .groupby(["sample", "gene_id"])
      .size()
      .reset_index(name="sv_count")
      .sort_values(["sample", "sv_count"], ascending=[True, False])
)

by_sample_csv = os.path.join(CSV_DIR, "exonic_sv_gene_counts_by_sample.csv")
per_sample_counts.to_csv(by_sample_csv, index=False)
print(f"Saved per‑sample exon SV counts ➜ {by_sample_csv}")

# combine samples
gene_counts = (
    df_unique
      .groupby("gene_id")
      .size()
      .reset_index(name="sv_count")
      .sort_values("sv_count", ascending=False)
)
all_csv = os.path.join(CSV_DIR, "exonic_sv_gene_counts.csv")
gene_counts.to_csv(all_csv, index=False)
print(f"Saved combined gene counts ➜ {all_csv}")

# top 20 exon interrupted genes
gene_counts = gene_counts[gene_counts["gene_id"] != "NA"]
top_n      = 20
top_genes  = gene_counts.head(top_n)

plt.figure(figsize=(10, 6))
plt.barh(top_genes["gene_id"], top_genes["sv_count"])
plt.xlabel("Number of SVs")
plt.ylabel("Gene ID")
plt.title(f"Top {top_n} Genes with Exon‑Overlapping SVs (all samples)")
plt.gca().invert_yaxis()
plt.tight_layout()

plot_path = os.path.join(PLOT_DIR, "top_exonic_sv_genes.png")
plt.savefig(plot_path, dpi=300)
plt.close()
print(f"Plot saved ➜ {plot_path}")
