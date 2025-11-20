library(ggplot2)

# ---------------------------------------------------------------------
# Data
# ---------------------------------------------------------------------
df_setup <- data.frame(
  Tool = c("PRSCSx", "SDPRX", "XPASS", "BridgePRS", "XP-BLUP"),
  Ratio = c(12.33/15.67, 110.33/44.67, 588.67/88, 367/69, 36.67/10)
)

df_runtime <- data.frame(
  Tool = c("PRSCSx", "SDPRX", "XPASS", "BridgePRS", "XP-BLUP"),
  Ratio = c(44.67/174.33, 38.67/36.33, 12.67/16.00, 56.67/70.00, 37.33/40.33)
)

colors <- c("#277da1", "#577590", "#4d908e", "#43aa8b", "#90be6d")

# ---------------------------------------------------------------------
# Function: Fold Efficiency Plot
# ---------------------------------------------------------------------
plot_efficiency <- function(df, file_name, y_label) {
  # Round ratio for display
  df$Label <- paste0(round(df$Ratio, 1), "×")

  p <- ggplot(df, aes(x = Tool, y = Ratio, fill = Tool)) +
    geom_col(width = 0.6, alpha = 0.9, color = "white", linewidth = 0.4) +
    geom_hline(yintercept = 1, linetype = "dashed", color = "red") +
    # Add numeric fold labels
    geom_text(aes(label = Label),
              vjust = -0.5, size = 3.8, fontface = "bold", color = "#333333") +
    scale_fill_manual(values = colors) +
    labs(
      x = "PRS Tool",
      y = y_label
    ) +
    expand_limits(y = max(df$Ratio) * 1.25) +
    theme_minimal(base_size = 13, base_family = "sans") +
    theme(
      axis.title.y = element_text(face = "bold", size = 11, margin = margin(r = 10)),
      axis.title.x = element_text(face = "bold", size = 11, margin = margin(t = 8)),
      axis.text.x = element_text(face = "bold", color = "#333333", size = 10),
      axis.text.y = element_text(size = 10, color = "#333333"),
      panel.grid.major.x = element_blank(),
      panel.grid.minor = element_blank(),
      legend.position = "none",
      plot.title = element_blank(),
      plot.subtitle = element_blank(),
      plot.margin = margin(10, 15, 10, 10)
    )

  ggsave(file_name, plot = p, width = 7, height = 4.2, dpi = 600)
  cat("Efficiency ratio plot saved to:", file_name, "\n")
}

# ---------------------------------------------------------------------
# 🔧 Function: Percent Improvement Plot
# ---------------------------------------------------------------------
plot_percent_improvement <- function(df, file_name, y_label) {
  df$Percent <- (1 - 1 / df$Ratio) * 100  # (1 - Docker/Manual) × 100

  p <- ggplot(df, aes(x = Tool, y = Percent, fill = Tool)) +
    geom_col(width = 0.6, alpha = 0.9, color = "white", linewidth = 0.4) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
    scale_fill_manual(values = colors) +
    labs(
      x = "PRS Tool",
      y = y_label
    ) +
    expand_limits(y = max(df$Percent) * 1.15) +
    theme_minimal(base_size = 13, base_family = "sans") +
    theme(
      axis.title.y = element_text(face = "bold", size = 11, margin = margin(r = 10)),
      axis.title.x = element_text(face = "bold", size = 11, margin = margin(t = 8)),
      axis.text.x = element_text(face = "bold", color = "#333333", size = 10),
      axis.text.y = element_text(size = 10, color = "#333333"),
      panel.grid.major.x = element_blank(),
      panel.grid.minor = element_blank(),
      legend.position = "none",
      plot.title = element_blank(),
      plot.subtitle = element_blank(),
      plot.margin = margin(10, 15, 10, 10)
    )

  ggsave(file_name, plot = p, width = 7, height = 4.2, dpi = 600)
  cat("Percent improvement plot saved to:", file_name, "\n")
}

# ---------------------------------------------------------------------
# Output Paths
# ---------------------------------------------------------------------
output_dir <- "/home/bonyido/PIPELINE_JULY_2025/PRS-Project-App/python_version/bench-prs-dock/plots"
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

setup_fold_path <- file.path(output_dir, "setup_efficiency_ratio.png")
runtime_fold_path <- file.path(output_dir, "runtime_efficiency_ratio.png")
setup_pct_path <- file.path(output_dir, "setup_percent_improvement.png")
runtime_pct_path <- file.path(output_dir, "runtime_percent_improvement.png")

# ---------------------------------------------------------------------
# Generate All Four Plots
# ---------------------------------------------------------------------
plot_efficiency(df_setup, setup_fold_path, "Setup Ratio (>1 = Docker faster)")
plot_efficiency(df_runtime, runtime_fold_path, "Runtime Ratio (>1 = Docker faster)")
plot_percent_improvement(df_setup, setup_pct_path, "Setup Time Change (%)")
plot_percent_improvement(df_runtime, runtime_pct_path, "Runtime Change (%)")

cat("All efficiency plots updated with red dashed line and smaller fonts!\n")
