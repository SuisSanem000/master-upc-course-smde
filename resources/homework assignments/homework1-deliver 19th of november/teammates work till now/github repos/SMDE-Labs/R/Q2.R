# ============================================================
# Question 2: ANOVA
# ============================================================
# Outputs:
#   R/logs/Q2.log              full console output of this script
#   report/tables/q2*.csv      result tables (shown in the report with csv-table())
#   report/figures/q2*.png     charts

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

# save everything printed from here on to R/logs/Q2.log (and still show it)
if (sink.number() > 0) sink()   # close a log left open by a previous failed run
sink(file.path(log_dir, "Q2.log"), split = TRUE)

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
# Data: cleaned data set of Question 1 (b), same preparation as Question 1 (a and e)
# ------------------------------------------------------------
section("Data preparation (as in Question 1)")

# cleaned data set written by R/Q1.R (b): impossible values removed
if (!file.exists("bodyPerformance_clean.csv")) stop("Run R/Q1.R first: it writes bodyPerformance_clean.csv")
body <- read.csv("bodyPerformance_clean.csv",
                 header = TRUE,
                 stringsAsFactors = FALSE,
                 check.names = FALSE)

names(body) <- c("age", "gender", "height_cm", "weight_kg", "body_fat_pct",
                 "diastolic", "systolic", "grip_force", "sit_bend_cm",
                 "sit_ups", "broad_jump_cm", "class")

body$gender <- factor(body$gender,
                      levels = c("F", "M"),
                      labels = c("Female", "Male"))
body$class <- factor(body$class,
                     levels = c("D", "C", "B", "A"),
                     ordered = TRUE) # D < C < B < A

num_vars <- c("age", "height_cm", "weight_kg", "body_fat_pct", "diastolic",
              "systolic", "grip_force", "sit_bend_cm", "sit_ups", "broad_jump_cm")
body[num_vars] <- lapply(body[num_vars],
                         as.numeric)

# age groups cut at 30, 40 and 50 (keep it the same as Question 1 e)
body$age_cat <- cut(body$age,
                    breaks = c(-Inf, 30, 40, 50, Inf),
                    labels = c("<30", "30-39", "40-49", "50+"),
                    right = FALSE)   # [a, b): 30 goes to "30-39"
table(body$age_cat)

# response variables of this question
resp_vars <- c("body_fat_pct", "diastolic", "sit_ups", "broad_jump_cm")

# ------------------------------------------------------------
# a) Distribution of body fat, diastolic blood pressure, sit-ups and broad
#    jump for each age group and for each performance class
# ------------------------------------------------------------
section("a) Distributions by age group and by performance class")

# TODO: summary statistics per group (e.g. aggregate()) -> save_table(..., "q2a_...")
# TODO: boxplots / histograms per age group and per class -> report/figures/q2a_*.png

# ------------------------------------------------------------
# b) Effect of age group and performance class on diastolic blood pressure,
#    body fat, sit-ups and broad jump (ANOVA)
# ------------------------------------------------------------
section("b) ANOVA: age group and performance class")

# TODO: remove outlying observations if required
# TODO: aov() for each response, with age_cat and with class
# TODO: assumptions: normality (shapiro.test, Q-Q plot), equal variances
#       (car::leveneTest, lmtest::bptest), independence (lmtest::dwtest)
# TODO: three post-hoc tests and compare them (e.g. Tukey, Bonferroni, LSD)

# ------------------------------------------------------------
# c) Effect of age and gender together on sit-ups and broad jump,
#    and their interaction (two-way ANOVA)
# ------------------------------------------------------------
section("c) Two-way ANOVA: age group x gender")

# TODO: aov(y ~ age_cat * gender) for sit_ups and broad_jump_cm
# TODO: interaction plot, assumptions and post-hoc tests

# ------------------------------------------------------------
# End
# ------------------------------------------------------------
sink()   # stop saving to the log
