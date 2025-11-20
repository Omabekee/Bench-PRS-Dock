library(ggplot2)
library(reshape2)

# -----------------------------
# Data: means and SDs (n = 3)
# -----------------------------
# Keep the tool order EXACTLY as you want it on the x-axis
tool_order <- c("BridgePRS", "PRSCSx", "SDPRX", "XP-BLUP", "XPASS")

# Setup (means)
df_setup_mean <- data.frame(
  Tool   = c("PRSCSx","SDPRX","XPASS","BridgePRS","XP-BLUP"),
  Metric = "Setup Time",
  Manual = c(12.33, 110.33, 588.67, 367.00, 36.67),
  Docker = c(15.67,  44.67,  88.00,   69.00, 10.00)
)

# Setup (SDs)
df_setup_sd <- data.frame(
  Tool     = c("PRSCSx","SDPRX","XPASS","BridgePRS","XP-BLUP"),
  Metric   = "Setup Time",
  ManualSD = c(0.58, 25.80, 7.57, 26.10, 1.53),
  DockerSD = c(0.58,  4.04, 1.73,  2.65, 0.82)
)

# Runtime (means)
df_runtime_mean <- data.frame(
  Tool   = c("PRSCSx","SDPRX","XPASS","BridgePRS","XP-BLUP"),
  Metric = "Runtime",
  Manual = c(44.67, 38.67, 12.67, 56.67, 37.33),
  Docker = c(174.33, 36.33, 16.00, 70.00, 40.33)
)

# Runtime (SDs)
df_runtime_sd <- data.frame(
  Tool     = c("PRSCSx","SDPRX","XPASS","BridgePRS","XP-BLUP"),
  Metric   = "Runtime",
  ManualSD = c(18.90, 5.13, 0.58, 1.53, 0.58),
  DockerSD = c(25.10, 4.93, 1.73, 2.65, 0.58)
)

# ---------------------------------
# Helper: make long mean+sd safely
# ---------------------------------
to_long_with_sd <- function(df_mean, df_sd, tool_order) {
  m_long <- melt(df_mean, id.vars = c("Tool","Metric"),
                 variable.name = "Mode", value.name = "Mean")
  s_long <- melt(df_sd,   id.vars = c("Tool","Metric"),
                 variable.name = "Mode", value.name = "SD")

  # Rename SD modes ("ManualSD" -> "Manual", "DockerSD" -> "Docker")
  s_long$Mode <- gsub("SD$", "", s_long$Mode)

  out <- merge(m_long, s_long, by = c("Tool","Metric","Mode"), sort = FALSE)

  # lock tool order exactly as requested
  out$Tool <- factor(out$Tool, levels = tool_order)

  out
}

setup_long  <- to_long_with_sd(df_setup_mean,  df_setup_sd,  tool_order)
runtime_long<- to_long_with_sd(df_runtime_mean, df_runtime_sd, tool_order)

# -----------------------------
# Styling
# -----------------------------
colors <- c("Manual" = "#c7a32dff", "Docker" = "#59b9e2ff")

plot_bars_sd <- function(dat, file_name) {
  p <- ggplot(dat, aes(x = Tool, y = Mean, fill = Mode)) +
    geom_col(position = position_dodge(width = 0.8), width = 0.7) +
    geom_errorbar(
      aes(ymin = Mean - SD, ymax = Mean + SD),
      position = position_dodge(width = 0.8),
      width = 0.25, linewidth = 0.8, color = "gray30"
    ) +
    scale_fill_manual(values = colors, name = "Mode") +
    labs(x = "PRS Tool", y = "Time (seconds)") +
    theme_minimal(base_size = 14) +
    theme(
      legend.position = "right",
      legend.title = element_text(face = "bold"),
      legend.text  = element_text(size = 12),
      axis.text.x  = element_text(angle = 30, hjust = 1, face = "bold"),
      axis.title.x = element_text(face = "bold"),
      axis.title.y = element_text(face = "bold"),
      plot.title   = element_blank(),
      plot.subtitle= element_blank()
    )

  ggsave(file_name, p, width = 9, height = 6, dpi = 400)
  cat("Saved:", file_name, "\n")
}

# -----------------------------
# Save plots (no surprises)
# -----------------------------
out_dir <- "/home/bonyido/PIPELINE_JULY_2025/PRS-Project-App/python_version/bench-prs-dock/plots"
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

plot_bars_sd(setup_long,  file.path(out_dir, "setup_barchart_errorbars.png"))
plot_bars_sd(runtime_long,file.path(out_dir, "runtime_barchart_errorbars.png"))

cat("Done. Bars match your original order and heights; SDs added cleanly.\n")
