#' Perform UMAP projection and misclassification analysis
#'
#' @description
#' A comprehensive analysis workflow that integrates data preparation,
#' UMAP projection, clustering, and visualization. This function handles
#' the entire process from raw data to final visualizations and outputs
#' both a Voronoi UMAP plot and a misclassification heatmap.
#'
#' @param data Data frame or matrix containing input data
#' @param target Optional vector of target values for classification
#' @param labels Optional vector of labels for data points
#' @param output_dir Character, directory for saving plots (default: "results")
#' @param file_prefix Character, prefix for output filenames (default: "umap_analysis")
#' @param file_format Character, "svg" or "png" (default: "svg")
#' @param n_neighbors Integer, number of neighbors for UMAP (default: 15)
#' @param n_clusters Integer, number of clusters (default: based on target values)
#' @param width Numeric, plot width in inches (default: 12)
#' @param height Numeric, plot height in inches (default: 9)
#' @param dpi Integer, resolution for PNG output (default: 300)
#'
#' @return A list containing all analysis components:
#'   \item{prepared_data}{Data frame with prepared input data}
#'   \item{umap_result}{UMAP projection results}
#'   \item{cluster_result}{Clustering results}
#'   \item{voronoi_plot}{UMAP Voronoi plot}
#'   \item{heatmap_result}{Misclassification heatmap results}
#'   \item{combined_plot}{Combined visualization of both plots}
#'   \item{misclassification_rate}{Numeric value indicating the proportion of misclassified samples}
#'   \item{misclassified_samples}{Data frame containing labels, expected classes, and assigned clusters for misclassified samples}
#'
#' @importFrom ggplot2 ggsave
#' @importFrom gridExtra grid.arrange
umap_cluster_analysis <- function(data,
                                  target = NULL,
                                  labels = NULL,
                                  output_dir = "results",
                                  file_prefix = "umap_analysis",
                                  file_format = "svg",
                                  n_neighbors = 15,
                                  n_clusters = NULL,
                                  width = 12,
                                  height = 9,
                                  dpi = 300) {

  # Check and load required packages
  required_packages <- c("ggplot2", "tidyr", "scales", "deldir", "umap", "combinat", "gridExtra")
  check_and_install_packages(required_packages)

  # Create output directory if it doesn't exist
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
    message(paste("Created output directory:", output_dir))
  }

  # Source required functions
  source_required_functions()

  # Prepare data
  message("Preparing data...")
  prepared_data <- prepare_dataset(data, Target = target, Label = labels)

  # Perform UMAP projection
  message("Performing UMAP projection...")
  umap_result <- perform_umap_projection(
    X = prepared_data[, !colnames(prepared_data) %in% c("Target", "Label")],
    target = prepared_data$Target,
    n_neighbors = n_neighbors
  )

  # Perform clustering
  message("Performing clustering...")
  cluster_result <- perform_ward_clustering(
    projection_data = umap_result$Projected,
    target = prepared_data$Target,
    n_clusters = n_clusters
  )

  # Combine data for visualization
  combined_data <- data.frame(
    umap_result$Projected,
    Target = prepared_data$Target,
    Label = prepared_data$Label,
    Cluster = cluster_result$clusters
  )

  # Create Voronoi plot
  message("Creating UMAP Voronoi plot...")
  voronoi_plot <- plot_umap_with_voronoi(
    umap_projection = combined_data,
    targets = combined_data$Target,
    labels = combined_data$Label,
    label_points = FALSE
  )

  # Create misclassification heatmap
  message("Creating misclassification heatmap...")
  heatmap_result <- plot_misclassification_heatmap(
    data = combined_data,
    prior_class_col = "Target",
    cluster_col = "Cluster",
    label_col = "Label"
  )

  # Identify misclassified samples
  message("Identifying misclassified samples...")
  expected_cluster <- as.numeric(as.factor(combined_data$Target))
  misclassified_indices <- which(expected_cluster != combined_data$Cluster)
  misclassified_samples <- data.frame(
    Label = combined_data$Label[misclassified_indices],
    ExpectedClass = combined_data$Target[misclassified_indices],
    AssignedCluster = combined_data$Cluster[misclassified_indices]
  )

  # Create combined plot
  message("Creating combined visualization...")
  combined_plot <- gridExtra::grid.arrange(
    voronoi_plot,
    heatmap_result$plot,
    ncol = 2,
    widths = c(1.5, 1)
  )

  # Save plots
  file_extension <- ifelse(file_format == "png", "png", "svg")

  # Save individual plots
  voronoi_file <- file.path(output_dir, paste0(file_prefix, "_voronoi.", file_extension))
  heatmap_file <- file.path(output_dir, paste0(file_prefix, "_heatmap.", file_extension))
  combined_file <- file.path(output_dir, paste0(file_prefix, "_combined.", file_extension))

  message(paste("Saving Voronoi plot to", voronoi_file))
  ggplot2::ggsave(
    filename = voronoi_file,
    plot = voronoi_plot,
    width = width * 0.6,
    height = height,
    dpi = dpi
  )

  message(paste("Saving heatmap to", heatmap_file))
  ggplot2::ggsave(
    filename = heatmap_file,
    plot = heatmap_result$plot,
    width = width * 0.4,
    height = height,
    dpi = dpi
  )

  message(paste("Saving combined plot to", combined_file))
  ggplot2::ggsave(
    filename = combined_file,
    plot = combined_plot,
    width = width,
    height = height,
    dpi = dpi
  )

  # Write misclassified samples to file
  if (nrow(misclassified_samples) > 0) {
    misclassified_file <- file.path(output_dir, paste0(file_prefix, "_misclassified_samples.csv"))
    message(paste("Writing misclassified samples to", misclassified_file))
    write.csv(misclassified_samples, file = misclassified_file, row.names = FALSE)
  }

  # Return results
  message("Analysis complete!")
  return(list(
    prepared_data = prepared_data,
    umap_result = umap_result,
    cluster_result = cluster_result,
    voronoi_plot = voronoi_plot,
    heatmap_result = heatmap_result,
    combined_plot = combined_plot,
    misclassification_rate = heatmap_result$misclassification_rate,
    misclassified_samples = misclassified_samples
  ))
}

# Example usage
# Load lipid profile data (samples as rows, lipid species as columns)
# lipid_profiles <- read.csv("lipid_profiles.csv")
# sample_types <- read.csv("sample_metadata.csv")$SampleType
#
# # Perform integrated UMAP projection and misclassification analysis
# results <- umap_cluster_analysis(
#   data = lipid_profiles,
#   target = sample_types,
#   n_neighbors = 12,  # Adjusted for lipidomics data structure
#   output_dir = "qc_results"
# )
#
# # Report misclassification rate and examine misclassified samples
# cat("Sample misclassification rate:",
#     sprintf("%.2f%%", results$misclassification_rate * 100))
# print(results$misclassified_samples)