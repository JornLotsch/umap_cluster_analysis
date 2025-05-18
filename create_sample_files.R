# Example: Generate toy data files for umap_cluster_analysis demonstration

# This script creates two example CSV files:
#   1. 'lipid_profiles.csv'  -- Simulated feature data (samples x lipid features)
#   2. 'sample_metadata.csv' -- Sample info (SampleID + SampleType/class)

# These files are compatible with the example in the README.

# ------------------------------
# Set parameters for toy data
set.seed(42)  # For reproducibility

n_samples <- 20         # Number of samples
n_features <- 8         # Number of lipid features

# Generate Sample IDs: "S1", "S2", ..., "S20"
sample_ids <- paste0("S", seq_len(n_samples))

# Assign sample types (e.g., two experimental groups)
sample_types <- rep(c("Control", "Case"), length.out = n_samples)

# Create feature matrix: random normal features, with shift for "Case" group
feature_matrix <- matrix(
  rnorm(n_samples * n_features, mean = 0, sd = 1),
  nrow = n_samples, ncol = n_features
)
# Add a shift to "Case" samples to simulate group differences
feature_matrix[sample_types == "Case", ] <- feature_matrix[sample_types == "Case", ] + 1.5

# Name the feature columns: Lipid1, Lipid2, ..., Lipid8
colnames(feature_matrix) <- paste0("Lipid", seq_len(n_features))

# Create DataFrame for features (each row = one sample)
lipid_profiles <- as.data.frame(feature_matrix)
rownames(lipid_profiles) <- sample_ids

# Write features to 'lipid_profiles.csv'
write.csv(lipid_profiles, "lipid_profiles.csv", row.names = FALSE)

# Create DataFrame for sample metadata (SampleID and SampleType)
sample_metadata <- data.frame(
  SampleID = sample_ids,
  SampleType = sample_types,
  stringsAsFactors = FALSE
)

# Write metadata to 'sample_metadata.csv'
write.csv(sample_metadata, "sample_metadata.csv", row.names = FALSE)

# After running this script, you will have two CSV files ready to use with umap_cluster_analysis!