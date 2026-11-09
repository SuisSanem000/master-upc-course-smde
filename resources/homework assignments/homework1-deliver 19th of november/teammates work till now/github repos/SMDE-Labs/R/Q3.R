# ============================================================
# Question 3: TITLE OF QUESTION 3
# ============================================================
# Outputs:
#   R/logs/Q3.log              full console output of this script
#   report/tables/q3*.csv      result tables (shown in the report with csv-table())
#   report/figures/q3*.png     charts

# ------------------------------------------------------------
# Setup
# ------------------------------------------------------------

# all paths are relative to the repository root (the parent folder of R/):
# if R was started inside R/, move up to the parent folder
if (!file.exists("bodyPerformance.csv") && file.exists("../bodyPerformance.csv")) setwd("..")
if (!file.exists("bodyPerformance.csv")) stop("Run this script from the repository root or from the R/ folder")

# output folders
log_dir <- "R/logs"
tab_dir <- c("report/tables", "UPC_Template/tables")
fig_dir <- c("report/figures", "UPC_Template/figures")
for (d in c(log_dir, tab_dir, fig_dir)) dir.create(d, showWarnings = FALSE)

options(width = 80)

# save everything printed from here on to R/logs/Q3.log (and still show it)
if (sink.number() > 0) sink()   # close a log left open by a previous failed run
sink(file.path(log_dir, "Q3.log"), split = TRUE)

# print a section title in the log
section <- function(title) cat("\n", strrep("=", 60), "\n", title, "\n", strrep("=", 60), "\n", sep = "")

# save a data frame as <tab_dir>/<name>.csv (in every folder) and print it in the log
save_table <- function(df, name) {
    for (d in tab_dir) write.csv(df, file.path(d, paste0(name, ".csv")), row.names = FALSE)
    print(df, row.names = FALSE)
}

# save a chart as <fig_dir>/<name>.png (in every folder)
# draw: a function with the plotting code, e.g. function() hist(x)
save_figure <- function(name, draw, width = 1600, height = 700, res = 120) {
    for (d in fig_dir) {
        png(file.path(d, paste0(name, ".png")), width = width, height = height, res = res)
        draw()
        invisible(dev.off())
    }
}

# ------------------------------------------------------------
# a) TITLE OF PART A
# ------------------------------------------------------------
section("a) TITLE OF PART A")

# TODO: analysis of part a
#   save tables with:  save_table(my_data_frame, "q3a_name")
#   save charts with:  save_figure("q3a_name", function() {
#                          ... plotting code ...
#                      })

# ------------------------------------------------------------
# End
# ------------------------------------------------------------
sink()   # stop saving to the log
