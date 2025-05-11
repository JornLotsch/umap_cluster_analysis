#' Perform Ward.D2 hierarchical clustering on projection data
#'
#' @description
#' This function applies Ward.D2 hierarchical clustering to a dataset,
#' typically the result of a dimensionality reduction technique like UMAP.
#' It also renames clusters to better align with target classes when provided.
#'
#' @param projection_data Data frame containing projection coordinates or the
#'                       result from perform_umap_projection()
#' @param target Optional vector of target classes for cluster alignment
#' @param distance_metric Character, distance metric to use (default: "euclidean")
#' @param n_clusters Integer, number of clusters (default: based on target values)
#' @param max_clusters Integer, maximum number of clusters to consider (default: 10)
#'
#' @return A list containing:
#'   \item{clusters}{Vector of renamed cluster assignments}
#'   \item{original_clusters}{Vector of original cluster assignments}
#'   \item{cluster_object}{The hclust object from hierarchical clustering}
#'   \item{n_clusters}{Number of clusters used}
#'   \item{distance_matrix}{Distance matrix used for clustering}
#'
#' @importFrom stats dist hclust cutree
#' @importFrom combinat permn
perform_ward_clustering <- function(projection_data,
                                    target = NULL,
                                    distance_metric = "euclidean",
                                    n_clusters = NULL,
                                    max_clusters = 10) {

  # Check if required packages are installed
  required_packages <- c("stats", "combinat")
  for (pkg in required_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      stop(paste("Package", pkg, "is required but not installed. Please install it."))
    }
  }

  # Validate input
  if (!is.data.frame(projection_data) || nrow(projection_data) == 0) {
    stop("Input data must be a non-empty data frame.")
  }

  # Extract projected data if input is the result from perform_umap_projection
  if ("Projected" %in% names(projection_data)) {
    X <- projection_data$Projected

    # Extract target if not provided but available in the projection result
    if (is.null(target) && "UniqueData" %in% names(projection_data) &&
      "Target" %in% names(projection_data$UniqueData)) {
      target <- projection_data$UniqueData$Target
    }
  } else {
    X <- projection_data
  }

  # If target is NULL, initialize with default values
  if (is.null(target)) {
    target <- rep(1, nrow(X))
  }

  # Determine number of clusters
  if (is.null(n_clusters)) {
    # Default to number of unique values in target
    n_clusters <- min(length(unique(target)), max_clusters)

    # Ensure we have at least 2 clusters
    n_clusters <- max(2, n_clusters)
  }

  # Perform Ward.D2 hierarchical clustering
  message("Performing Ward.D2 clustering...")
  distance_matrix <- stats::dist(X, method = distance_metric)
  cluster_object <- stats::hclust(distance_matrix, method = "ward.D2")

  # Cut the tree to get cluster assignments
  cluster_assignments <- as.numeric(stats::cutree(cluster_object, k = n_clusters))

  # Rename clusters to better match the target (if provided)
  if (!is.null(target) && length(unique(target)) > 1) {
    message("Renaming clusters to align with target classes...")
    renamed_clusters <- renameClusters(trueCls = target, currentCls = cluster_assignments)
  } else {
    renamed_clusters <- cluster_assignments
  }

  # Function to align cluster names with likely class labels of the prior classification
  renameClusters <- function(trueCls, currentCls, K = 12) {
    # Helper function to reduce clusters
    ReduceClsToK <- function(Cls, K = 12) {
      uniqueCls <- unique(Cls)
      while (length(uniqueCls) > K) {
        counts <- table(Cls)
        to_merge <- names(sort(counts)[1:2])
        Cls[Cls %in% to_merge] <- to_merge[1]
        uniqueCls <- unique(Cls)
      }
      return(Cls)
    }

    # Preprocess input
    trueCls[!is.finite(trueCls)] <- 9999
    currentCls[!is.finite(currentCls)] <- 9999

    # Warnings
    if (length(unique(trueCls)) > 9) {
      warning("Too many clusters in PriorCls. Consider using cloud computing.")
    }
    if (length(unique(currentCls)) > K) {
      warning("Too many clusters in CurrentCls. Combining smallest clusters.")
      currentCls <- ReduceClsToK(currentCls, K)
    }

    # Normalize clusters
    trueCls <- as.numeric(factor(trueCls))
    currentCls <- as.numeric(factor(currentCls))

    # Get unique labels
    uniqueLabels <- sort(unique(c(trueCls, currentCls)))
    nLabels <- length(uniqueLabels)

    # Generate permutations
    permutations <- combinat::permn(nLabels)

    # Find best permutation
    bestAccuracy <- 0
    bestPermutation <- NULL

    for (perm in permutations) {
      newLabels <- perm[match(currentCls, seq_along(perm))]
      accuracy <- sum(trueCls == newLabels) / length(trueCls)
      if (accuracy > bestAccuracy) {
        bestAccuracy <- accuracy
        bestPermutation <- perm
      }
    }

    # Rename clusters
    renamedCls <- bestPermutation[match(currentCls, seq_along(bestPermutation))]

    return(renamedCls)
  }

  # Return the result
  return(list(
    clusters = renamed_clusters,
    original_clusters = cluster_assignments,
    cluster_object = cluster_object,
    n_clusters = n_clusters,
    distance_matrix = distance_matrix
  ))
}