# UMAP Ward misclassification analysis
This R code provides a comprehensive workflow for performing UMAP projection, Ward clustering, and misclassification analysis on high-dimensional data. It's particularly useful for quality control and exploratory data analysis in omics studies.
## Functions
### `check_and_install_packages(pkg_list)`
**Description**: Utility function that checks for missing R packages and automatically installs them from CRAN.
**Parameters**:
- : Character vector of package names to check and install `pkg_list`

<<<<<<< HEAD
**Returns**:
- No return value (NULL). Installs missing packages and loads all required packages
- Throws an error if any packages fail to load after installation

**Example**:
``` r
required_packages <- c("ggplot2", "umap", "cluster")
check_and_install_packages(required_packages)
```
### `source_required_functions()`
**Description**: Sources all required analysis functions from the current working directory.
**Parameters**: None
**Returns**:
- No return value (NULL). Sources external R scripts containing analysis functions
- Throws an error if any required function files are missing

**Required Files**:
- `prepare_dataset.R`
- `perform_umap_projection.R`
- `perform_ward_clustering.R`
- `plot_umap_with_voronoi.R`
- `plot_misclassification_heatmap.R`

### `umap_ward_misclassification_analysis()`
**Description**: Main analysis function that performs a complete workflow including data preparation, UMAP projection, Ward clustering, visualization, and misclassification analysis.
#### Parameters

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | data.frame/matrix | Required | Input data with samples as rows and features as columns |
| `target` | vector | NULL | Optional target class labels (length must match nrow(data)) |
| `labels` | vector | NULL | Optional sample labels for visualization (length must match nrow(data)) |
| `output_dir` | character | "results" | Directory for saving output files |
| `file_prefix` | character | "umap_analysis" | Prefix for output filenames |
| `file_format` | character | "svg" | Plot format: "svg" or "png" |
| `label_points` | logical | TRUE | Whether to display point labels in plots |
| `row_font_size` | numeric | 6 | Font size for heatmap row labels |
| `width` | numeric | 12 | Plot width in inches |
| `height` | numeric | 9 | Plot height in inches |
| `dpi` | integer | 300 | Resolution for PNG output |
| `n_neighbors` | integer | 15 | Number of nearest neighbors for UMAP |
#### Returns
A named list containing the following components:

| Component | Type | Description |
| --- | --- | --- |
| `prepared_data` | data.frame | Processed input data ready for analysis |
| `umap_result` | list | Complete UMAP projection results including coordinates and parameters |
| `cluster_result` | list | Ward clustering results including cluster assignments |
| `voronoi_plot` | ggplot2 | UMAP scatter plot with Voronoi tessellation overlay |
| `heatmap_result` | list | Misclassification heatmap and associated statistics |
| `combined_plot` | grob | Combined visualization of Voronoi plot and heatmap |
| `misclassification_rate` | numeric | Proportion of misclassified samples (0-1) |
| `misclassified_samples` | data.frame | Details of misclassified samples with expected vs assigned classes |
#### Output Files
The function generates several output files in the specified directory:
1. **`{file_prefix}_voronoi.{format}`**: UMAP plot with Voronoi tessellation
2. **`{file_prefix}_heatmap.{format}`**: Misclassification heatmap
3. **`{file_prefix}_combined.{format}`**: Combined visualization
4. **`{file_prefix}_misclassified_samples.csv`**: CSV file listing misclassified samples (if any)

## Usage Example
``` r
# Load your data
lipid_profiles <- read.csv("lipid_profiles.csv")
sample_metadata <- read.csv("sample_metadata.csv")
sample_types <- sample_metadata$SampleType

# Run the analysis
results <- umap_ward_misclassification_analysis(
  data = lipid_profiles,
  target = sample_types,
  labels = sample_metadata$SampleID,
  output_dir = "qc_results",
  file_prefix = "lipid_analysis",
  file_format = "png",
  width = 14,
  height = 10
)
=======
## Overview

Laboratory errors can produce topically plausible but incorrect results. This package integrates dimensionality reduction (UMAP) with cluster analysis (Ward’s hierarchical clustering) to detect such errors through an intuitive visual framework, enabling researchers to identify problematic samples before they impact downstream analyses.

## Use cases

- Laboratory quality control pipelines
- Multi-omics data validation
- Sample classification verification
- Biomarker discovery studies
- Clinical research quality assurance

## Technical highlights

- ✅ **Comprehensive analysis**: From raw data to final visualizations in a single function  
- 📈 **Detailed outputs**: Includes UMAP coordinates, clusters, visualizations, and a misclassified samples list  
- 🧮 **Statistical rigor**: Uses established UMAP and hierarchical clustering algorithms for robust results  
- 📊 **Publication-ready graphics**: Generates high-quality SVG/PNG outputs for direct use in publications  

---

## Installation

Clone this repository and source the function in your R environment:

---

## Example usage

Below is a complete example of running UMAP-based clustering and checking for misclassifications.

#### Load your data frame: each row is a sample, each column a feature (e.g., lipid species)
```
lipid_profiles <- read.csv("lipid_profiles.csv")
```
#### Load or extract your class labels for each sample
```
sample_metadata <- read.csv("sample_metadata.csv") sample_types <- sample_metadata$SampleType
```
#### Run the integrated UMAP projection and clustering/misclassification analysis
```
results <- umap_ward_misclassification_analysis( data = lipid_profiles, target = sample_types, 
labels = sample_metadata$SampleID, output_dir = "results")
```
#### Output misclassification rate and list which samples were misclassified
```
cat("Sample misclassification rate:", sprintf("%.2f%%", results$misclassification_rate * 100), "\n")
if (!is.null(resultsmisclassified_samples) && nrow(resultsmisclassified_samples) > 0) {
cat("Misclassified samples:\n") print(results$misclassified_samples) } else { cat("No misclassified samples.\n")
}
```
#### Optionally: view UMAP plot object, if provided
```
print(results$umap_plot)
print(results$voronoi_plot)
```
<img src="./umap_analysis_combined.svg">
>>>>>>> origin/main

# Check misclassification rate
cat("Misclassification rate:", 
    sprintf("%.2f%%", results$misclassification_rate * 100), "\n")

<<<<<<< HEAD
# View misclassified samples
if (nrow(results$misclassified_samples) > 0) {
  print(results$misclassified_samples)
}
=======
## Simulated example data set
>>>>>>> origin/main

# Access individual components
umap_coordinates <- results$umap_result$Projected
cluster_assignments <- results$cluster_result$clusters
```
## Dependencies
The package automatically installs and loads the following R packages:
- : Data visualization `ggplot2`
- `tidyr`: Data manipulation
- `scales`: Plot scaling functions
- `deldir`: Voronoi tessellation
- `umap`: UMAP dimensionality reduction
- : Combining plots `gridExtra`

## Requirements
- R >= 3.6.0
- External function files (listed in ) `source_required_functions()`
- Write permissions in the output directory

## Error Handling
The function includes comprehensive input validation:
- Checks data types and dimensions
- Validates parameter ranges and formats
- Ensures required files exist
- Verifies directory permissions
- Provides informative error messages for troubleshooting

<<<<<<< HEAD
=======
# See create_sample_lipidomics_data.R in the repository for reproducible example data creation.

---

## Function arguments

- `data`: Data frame or matrix of numeric features (samples in rows, features in columns).
- `target`: Vector or factor of true class labels.
- `labels`: (Optional) Row labels for plotting and output (e.g., sample IDs).
- `output_dir`: (Optional) Directory to save SVG/PNG plots and QC outputs.
- `n_neighbors`: *(Optional, default = 15)* Integer; the size of the local neighborhood used by UMAP for manifold approximation. Adjust to control the local/global structure captured in the projection.

---

## Output explanation

- **misclassification_rate**: Fraction of samples assigned to the wrong cluster, compared to ground truth labels.
- **misclassified_samples**: Data frame listing the misclassified samples, their IDs, true labels, and predicted clusters.
- **voronoi_plot**: R `ggplot2` object for the UMAP visualization (can be customized or exported).
- **qc_results directory**: Contains publication-ready SVG/PNG plots and summary tables of clustering results.

---

## Citation

If you use this tool in your work, please cite the repository or contact the maintainer for citation details. <tbd>

---
>>>>>>> origin/main
