# umap_cluster_analysis

## Why umap_cluster_analysis?

Laboratory errors in lipidomics can produce biologically plausible but incorrect results. Our package integrates dimensionality reduction with cluster analysis to detect these errors through an intuitive visual framework, enabling researchers to identify problematic samples before they impact downstream analyses.

## Ideal for

- Lipidomic quality control pipelines
- Multi-omics data validation
- Sample classification verification
- Biomarker discovery studies
- Clinical research quality assurance

## Technical Highlights

- ✅ **Comprehensive Analysis**: From raw data to final visualizations in a single function  
- 📈 **Detailed Outputs**: Includes coordinates, clusters, visualizations, and a misclassified samples list  
- 🧮 **Statistical Rigor**: Based on established dimensionality reduction and clustering algorithms  
- 📊 **Publication-Ready Graphics**: Generates high-quality SVG/PNG outputs for direct use in publications  

---

## Installation

Clone this repository and source the function in your R environment:

---

## Example Usage

Below is a complete example of running UMAP-based clustering and checking for misclassifications.

### Load your data frame: each row is a sample, each column a feature (e.g., lipid species)
lipid_profiles <- read.csv("lipid_profiles.csv")
### Load or extract your class labels for each sample
sample_metadata <- read.csv("sample_metadata.csv") sample_types <- sample_metadata$SampleType
### Run the integrated UMAP projection and clustering/misclassification analysis
results <- umap_cluster_analysis( data = lipid_profiles, # Features data target = sample_types, # Ground truth (prior classes) labels = sample_metadata$SampleID, # Optional: row labels for plots, if available output_dir = 
### Output misclassification rate and list which samples were misclassified
cat("Sample misclassification rate:", sprintf("%.2f%%", results$misclassification_rate * 100), "\n")
if (!is.null(resultsmisclassified_samples) && nrow(resultsmisclassified_samples) > 0) { cat("Misclassified samples:\n") print(results$misclassified_samples) } else { cat("No misclassified samples.\n") }
### Optionally: view UMAP plot object, if provided
print(results$umap_plot)


---

## Function Arguments

- `data`: Data frame or matrix of numeric features (samples in rows, features in columns).
- `target`: Vector or factor of true class labels.
- `labels`: (Optional) Row labels for plotting and output (e.g., sample IDs).
- `output_dir`: (Optional) Directory to save SVG/PNG plots and QC outputs.

---

## Output Explanation

- **misclassification_rate**: Fraction of samples assigned to the wrong cluster, compared to ground truth labels.
- **misclassified_samples**: Data frame listing the misclassified samples, their IDs, true labels, and predicted clusters.
- **umap_plot**: R `ggplot2` object for the UMAP visualization (can be customized or exported).
- **qc_results directory**: Contains publication-ready SVG/PNG plots and summary tables of clustering results.

---

## Citation

If you use this tool in your work, please cite the repository or contact the maintainer for citation details.

---

## License

Distributed under the MIT License. See `LICENSE` for more information.

---

## Contact

For questions, issues, or feature requests, please open an issue on GitHub or contact the maintainer.
