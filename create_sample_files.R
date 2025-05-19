# create_sample_lipidomics_data.R

set.seed(123)  # For reproducibility

n_samples <- 100         # Total samples
n_features <- 8          # Features (lipids)
samples_per_class <- 50  # 2 classes, balanced

# Sample IDs
sample_ids <- sprintf("S%03d", 1:n_samples)
# Class assignment
sample_types <- rep(c("ClassA", "ClassB"), each = samples_per_class)

# Simulate base features: both classes start similar
feature_matrix <- matrix(rnorm(n_samples * n_features, mean = 0, sd = 1),
                         nrow = n_samples, ncol = n_features)

# Add group-specific differences to promote class separation for UMAP
# ClassA: shift Lipid1, Lipid2 higher
feature_matrix[1:samples_per_class, 1:2] <- feature_matrix[1:samples_per_class, 1:2] + 2
# ClassB: shift Lipid5, Lipid6 higher
feature_matrix[(samples_per_class+1):n_samples, 5:6] <- feature_matrix[(samples_per_class+1):n_samples, 5:6] + 2

# Add a bit of random noise to a few samples to simulate misclassification potential
n_errors <- 6
error_indices <- sample(1:n_samples, n_errors)
feature_matrix[error_indices, ] <- feature_matrix[error_indices, ] + rnorm(n_errors * n_features, mean = 0, sd = 2)

# Name the features "Lipid1"..."Lipid8"
colnames(feature_matrix) <- paste0("Lipid", 1:n_features)

# Create and write lipid profile data frame
lipid_profiles <- as.data.frame(feature_matrix)
lipid_profiles$SampleID <- sample_ids  # Optionally, include SampleID as a column
# Usually features-only file: remove SampleID
write.csv(lipid_profiles[, 1:n_features], "lipid_profiles.csv", row.names = FALSE)

# Sample metadata: SampleID and Class label
sample_metadata <- data.frame(
  SampleID = sample_ids,
  SampleType = sample_types,
  stringsAsFactors = FALSE
)
write.csv(sample_metadata, "sample_metadata.csv", row.names = FALSE)

cat("Created arbitrary lipid_profiles.csv and sample_metadata.csv for UMAP cluster analysis example.\n")