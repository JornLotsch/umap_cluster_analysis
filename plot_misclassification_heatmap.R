#' Create a heatmap showing cluster assignments and misclassifications
#'
#' @description
#' Generates a heatmap comparing prior class assignments with clustering results to
#' identify and visualize misclassified samples. Supports multiple clusters and uses
#' a colorblind-friendly palette.
#'
#' @param data Data frame containing prior classes and cluster assignments
#' @param prior_class_col Character, column name for prior classes (default: "Target")
#' @param cluster_col Character, column name for cluster assignments (default: "Cluster")
#' @param label_col Character, column name for row labels (default: row names)
#' @param title Character, plot title (default: "Cluster Assignments and Misclassifications")
#' @param row_font_size Numeric, font size for row labels (default: 6)
#'
#' @return A list containing:
#'   \item{plot}{ggplot2 object with the misclassification heatmap}
#'   \item{data}{Data frame with prior classes, clusters and misclassification indicators}
#'   \item{long_data}{Long-format data used for plotting}
#'   \item{misclassification_rate}{Numeric, percentage of misclassified samples}
#'
#' @importFrom ggplot2 ggplot geom_tile scale_fill_manual theme_minimal labs theme element_text element_rect element_blank
#' @importFrom tidyr pivot_longer
#' @importFrom scales alpha
plot_misclassification_heatmap <- function(data,
                                           prior_class_col = "Target",
                                           cluster_col = "Cluster",
                                           label_col = NULL,
                                           title = "Cluster Assignments and Misclassifications",
                                           row_font_size = 6) {

  # Check required packages
  required_packages <- c("ggplot2", "tidyr", "scales")
  for (pkg in required_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      stop(paste("Package", pkg, "is required but not installed"))
    }
  }

  # Input validation
  if (!is.data.frame(data)) {
    stop("Input must be a data frame")
  }

  if (!(prior_class_col %in% colnames(data))) {
    stop(paste("Column", prior_class_col, "not found in data"))
  }

  if (!(cluster_col %in% colnames(data))) {
    stop(paste("Column", cluster_col, "not found in data"))
  }

  # Use row names if label column not specified
  if (is.null(label_col)) {
    if (!is.null(rownames(data))) {
      data$row_label <- rownames(data)
    } else {
      data$row_label <- 1:nrow(data)
    }
  } else {
    if (!(label_col %in% colnames(data))) {
      stop(paste("Label column", label_col, "not found in data"))
    }
    data$row_label <- data[[label_col]]
  }

  # Create a clean data frame with just what we need
  clean_data <- data.frame(
    row_label = data$row_label,
    prior_class = as.factor(data[[prior_class_col]]),
    cluster = as.factor(data[[cluster_col]])
  )

  # Determine misclassified cases
  clean_data$misclassified <- ifelse(
    clean_data$prior_class == clean_data$cluster,
    0,  # Not misclassified
    1   # Misclassified
  )

  # Transform to long format for plotting
  prepare_long_data <- function(df) {
    # Create data columns for the heatmap
    df_plot <- data.frame(
      row = df$row_label,
      prior_class = df$prior_class,
      cluster = df$cluster,
      misclassified = df$misclassified
    )

    # Convert misclassified to factor with specific coding for coloring
    # Use an offset higher than any cluster number to ensure it has a unique color
    max_cluster_num <- max(as.numeric(df_plot$prior_class), as.numeric(df_plot$cluster))
    df_plot$misclassified <- as.factor(df_plot$misclassified * (max_cluster_num + 1))

    # Convert all columns to character for consistent transformation
    cols_to_convert <- c("prior_class", "cluster", "misclassified")
    df_plot[cols_to_convert] <- lapply(df_plot[cols_to_convert], as.character)

    # Transform to long format
    df_long <- tidyr::pivot_longer(
      df_plot,
      cols = cols_to_convert,
      names_to = "column",
      values_to = "value"
    )

    # Reverse order of rows for proper display (top to bottom)
    df_long$row <- factor(df_long$row, levels = rev(unique(df_long$row)))

    # Define the order for columns (x-axis)
    column_order <- c("prior_class", "cluster", "misclassified")
    df_long$column <- factor(df_long$column, levels = column_order)

    # Make column names more readable
    levels(df_long$column) <- c("Prior Class", "Cluster", "Misclassified")

    return(df_long)
  }

  # Prepare long format data
  df_long <- prepare_long_data(clean_data)

  # Extended colorblind palette from plot_umap_with_voronoi
  cb_palette <- c(
    "#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00",
    "#CC79A7", "#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2",
    "#D55E00", "#CC79A7"
  )

  # Get all unique values (all possible clusters plus 0 and misclassified marker)
  unique_values <- unique(df_long$value)
  misclassified_value <- unique(df_long$value[df_long$column == "Misclassified" & df_long$value != "0"])

  # Create a color mapping with fixed colors for "0" and misclassified
  # and cb_palette colors for actual clusters
  color_mapping <- setNames(
    c("lightyellow", cb_palette[1:(length(unique_values)-2)], "salmon"),
    c("0", setdiff(setdiff(unique_values, "0"), misclassified_value), misclassified_value)
  )

  # Create labels for legend
  label_mapping <- setNames(
    c("Not misclassified",
      paste("Class/cluster", setdiff(setdiff(unique_values, "0"), misclassified_value)),
      "Misclassified"),
    c("0", setdiff(setdiff(unique_values, "0"), misclassified_value), misclassified_value)
  )

  # Calculate misclassification rate
  misclass_rate <- round(100 * sum(clean_data$misclassified) / nrow(clean_data), 1)
  subtitle <- paste0("Misclassification rate: ", misclass_rate, "%")

  # Create ggplot2 heatmap
  ggplot_heatmap <- ggplot2::ggplot(df_long, ggplot2::aes(x = column, y = row, fill = factor(value))) +
    ggplot2::geom_tile(color = "white", size = 0.5) +
    ggplot2::scale_fill_manual(
      values = color_mapping,
      na.value = "white",
      name = "Classification",
      labels = label_mapping
    ) +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::labs(
      title = title,
      subtitle = subtitle,
      x = NULL, y = NULL
    ) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 90, vjust = 0.5, hjust = 1),
      axis.text.y = ggplot2::element_text(size = row_font_size),
      legend.position = "top",
      legend.background = ggplot2::element_rect(fill = scales::alpha("white", 0.5), color = NA),
      panel.grid = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank()
    )

  # Return the plot and data
  return(list(
    plot = ggplot_heatmap,
    data = clean_data,
    long_data = df_long,
    misclassification_rate = misclass_rate
  ))
}