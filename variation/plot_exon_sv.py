import re
from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

region_colors = {
    "Florida":  "#1b9e77",
    "Tokyo":    "#d95f02",
    "Thailand": "#7570b3",
}
def infer_geography(sample_name: str) -> str:
    return re.split(r"[\d_]", sample_name, maxsplit=1)[0].lower()

sns.set_theme(style="white", context="talk") 
overall_df = pd.read_csv(overall_csv)
per_sample = pd.read_csv(by_sample_csv)
per_sample["geography"] = per_sample["sample"].apply(infer_geography)
per_sample["geography"] = per_sample["geography"].str.title()

overall_sorted = overall_df.sort_values("sv_count", ascending=False)
top_genes = overall_sorted.head(top_n)["gene_id"].tolist()

per_sample_top = per_sample[per_sample["gene_id"].isin(top_genes)]

cat_order = top_genes

grp = (
    per_sample_top
    .groupby(["geography", "gene_id"], as_index=False)["sv_count"]
    .sum()
    )

plt.figure(figsize=(14, 7))
ax = sns.barplot(
    data=grp,
    x="gene_id",
    y="sv_count",
    hue="geography",
    order=cat_order,
    palette=region_colors
)
ax.set_title("Top 20 Genes with Exonic SVs")
ax.set_xlabel("Gene ID")
ax.set_ylabel("Number of distinct SVs")
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
plt.xticks(rotation=60, ha="right")
plt.tight_layout()
plt.savefig("top20_genes_grouped_by_geography.png", dpi=300)
plt.show()
plt.close()

plt.figure(figsize=(14, 7))
ax = sns.barplot(
    data=overall_sorted.head(top_n),
    x="gene_id",
    y="sv_count",
    order=cat_order,
    color="Green"
)
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
plt.title("Top 20 Genes with Exonic SVs (All Samples Pooled)")
plt.xlabel("Gene ID")
plt.ylabel("Number of distinct SVs")
plt.xticks(rotation=60, ha="right")
plt.tight_layout()
plt.savefig("top20_genes_overall.png", dpi=300)
plt.show()
plt.close()
