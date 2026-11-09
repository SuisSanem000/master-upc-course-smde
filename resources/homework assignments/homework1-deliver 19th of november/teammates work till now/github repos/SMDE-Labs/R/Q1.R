# ============================================================
# Question 1: Visualisation, Chi-Square and t-Test
# ============================================================
# Outputs:
#   R/logs/Q1.log              full console output of this script
#   report/tables/q1*.csv      result tables (shown in the report with csv-table())
#   report/figures/q1*.png     charts

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

# save everything printed from here on to R/logs/Q1.log (and still show it)
if (sink.number() > 0) sink()   # close a log left open by a previous failed run
sink(file.path(log_dir, "Q1.log"), split = TRUE)

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
# a) Import data set to R assigning the type of each variable correctly
# ------------------------------------------------------------
section("a) Import data set and variable types")

# read the dataset
body <- read.csv("bodyPerformance.csv",
                 header = TRUE,
                 stringsAsFactors = FALSE,
                 check.names = FALSE)

# rename the variables
original_names <- names(body)
names(body) <- c(
            "age",
            "gender",
            "height_cm",
            "weight_kg",
            "body_fat_pct",     # body fat (%)
            "diastolic",        # the bottom number in a blood pressure reading
            "systolic",         # the top number in a blood pressure reading
            "grip_force",
            "sit_bend_cm",
            "sit_ups",
            "broad_jump_cm",
            "class"
)

# categorical variables
body$gender <- factor(body$gender,
                      levels = c("F", "M"),
                      labels = c("Female", "Male"))
body$class <- factor(body$class,
                     levels = c("D", "C", "B", "A"),
                     ordered = TRUE) # D < C < B < A

# numerical variables
num_vars <- c("age", "height_cm", "weight_kg", "body_fat_pct", "diastolic",
              "systolic", "grip_force", "sit_bend_cm", "sit_ups", "broad_jump_cm")
body[num_vars] <- lapply(body[num_vars],
                         as.numeric)

# check
dim(body)
str(body)
table(body$gender)
table(body$class)

# missing values per variable (all 0)
colSums(is.na(body))

# table: name, original name, type and levels of each variable
save_table(data.frame(
    Variable = names(body),
    Original = original_names,
    Type     = sapply(body, function(x) paste(class(x), collapse = " ")),
    Levels   = sapply(body, function(x) if (is.factor(x)) paste(levels(x), collapse = if (is.ordered(x)) " < " else ", ") else "")
), "q1a_variables")

# ------------------------------------------------------------
# b) Summarize the numerical variables and analyze their distributions
# ------------------------------------------------------------
section("b) Summary and distributions of the numerical variables")

summary(body[num_vars])

# table: summary statistics per variable
save_table(data.frame(
    Variable = num_vars,
    Min      = sapply(body[num_vars], min),
    Q1       = sapply(body[num_vars], quantile, 0.25),
    Median   = sapply(body[num_vars], median),
    Mean     = round(sapply(body[num_vars], mean), 2),
    Q3       = sapply(body[num_vars], quantile, 0.75),
    Max      = sapply(body[num_vars], max),
    SD       = round(sapply(body[num_vars], sd), 2)
), "q1b_summary")

# boxplots
save_figure("q1b_boxplots", function() {
    par(mfrow = c(2, 5))
    for (v in num_vars) {
        boxplot(body[[v]],
                main = v,
                col = "lightblue")
    }
})

# table: outliers (outside 1.5 * IQR from the quartiles) and zero values per variable
save_table(data.frame(
    Variable = num_vars,
    Outliers = sapply(body[num_vars], function(x) length(boxplot.stats(x)$out)),
    Zeros    = colSums(body[num_vars] == 0)
), "q1b_outliers")

# remove the outliers of the boxplots and of the summary table that are impossible:
# outside the adult health reference ranges (report, Appendix: reference table) or physically impossible.
# Plausible outliers (e.g. hypertension, sit_ups = 0, low BMI) are kept.
impossible <- list(
    "systolic < 70 or diastolic < 40" = body$systolic < 70 | body$diastolic < 40,   # far below hypotension (90/60)
    "systolic <= diastolic"           = body$systolic <= body$diastolic,              # systolic is always the higher one
    "body_fat_pct < essential or > 60" =
        body$body_fat_pct < ifelse(body$gender == "Female", 10, 2) | body$body_fat_pct > 60,
    "grip_force = 0"                  = body$grip_force == 0,                         # test not done
    "broad_jump_cm = 0"               = body$broad_jump_cm == 0,                      # test not done
    "sit_bend_cm > 50"                = body$sit_bend_cm > 50                         # 185 and 213 cm
)
impossible_vars <- list(c("systolic", "diastolic"), c("systolic", "diastolic"), "body_fat_pct",
                        "grip_force", "broad_jump_cm", "sit_bend_cm")
remove <- Reduce(`|`, impossible)

# table: rule, removed values (systolic/diastolic for blood pressure) and number of rows removed
save_table(data.frame(
    Rule   = c(names(impossible), "Any of the above"),
    Values = c(mapply(function(rows, vars) {
                   v <- unique(do.call(paste, c(body[rows, vars, drop = FALSE], sep = "/")))
                   paste(sort(v), collapse = ", ")
               }, impossible, impossible_vars), ""),
    Rows   = c(sapply(impossible, sum), sum(remove))
), "q1b_removed")

# cleaned data set for the rest of the assignment (Q1 c-g, Q2): same columns and codes as the original file
write.csv(read.csv("bodyPerformance.csv", check.names = FALSE)[!remove, ],
          "bodyPerformance_clean.csv", row.names = FALSE)
body <- body[!remove, ]
cat("Rows removed:", sum(remove), "- rows left:", nrow(body), "
")

# histograms (cleaned data)
save_figure("q1b_histograms", function() {
    par(mfrow = c(2, 5))   # 2 rows x 5 columns of plots
    for (v in num_vars) {
        hist(body[[v]],
             main = v,
             xlab = v,
             breaks = 30,
             col = "lightblue")
    }
})

# Q-Q plots: points on the red line = normal distribution
save_figure("q1b_qqplots", function() {
    par(mfrow = c(2, 5))
    for (v in num_vars) {
        qqnorm(body[[v]], main = v, pch = 20, cex = 0.4)
        qqline(body[[v]], col = "red", lwd = 2)
    }
})

# normality test
# H0: the variable is normally distributed
# shapiro.test() accepts at most 5000 values -> random sample of 5000
set.seed(123)
shapiro_p <- sapply(body[num_vars], function(x) shapiro.test(sample(x, 5000))$p.value)

# table: Shapiro-Wilk p-value per variable
save_table(data.frame(
    Variable  = num_vars,
    Shapiro_p = format.pval(shapiro_p, digits = 3, eps = 1e-16)
), "q1b_shapiro")

# ------------------------------------------------------------
# c) Compare systolic and diastolic blood pressure by gender
# ------------------------------------------------------------
section("c) Blood pressure comparison by gender")

# Remove observations with invalid blood pressure values
body_c <- subset(body,
                 diastolic > 0 &
                 systolic > 0 &
                 !is.na(gender))

# Divide observations by gender
male <- subset(body_c, gender == "Male")
female <- subset(body_c, gender == "Female")

cat("Observations after cleaning:", nrow(body_c), "\n")
cat("Male observations:", nrow(male), "\n")
cat("Female observations:", nrow(female), "\n")

if (nrow(male) == 0 || nrow(female) == 0) {
    stop("One gender group is empty. Check gender values.")
}

# Histograms with the same intervals for both genders
save_figure("q1c_histograms", function() {
    par(mfrow = c(2, 2))

    sys_breaks <- pretty(range(body_c$systolic), n = 30)
    dia_breaks <- pretty(range(body_c$diastolic), n = 30)

    hist(male$systolic,
         main = "Male - Systolic",
         xlab = "Systolic (mmHg)",
         breaks = sys_breaks,
         col = "lightblue")

    hist(female$systolic,
         main = "Female - Systolic",
         xlab = "Systolic (mmHg)",
         breaks = sys_breaks,
         col = "pink")

    hist(male$diastolic,
         main = "Male - Diastolic",
         xlab = "Diastolic (mmHg)",
         breaks = dia_breaks,
         col = "lightblue")

    hist(female$diastolic,
         main = "Female - Diastolic",
         xlab = "Diastolic (mmHg)",
         breaks = dia_breaks,
         col = "pink")
}, width = 1400, height = 900)

# Boxplots
save_figure("q1c_boxplots", function() {
    par(mfrow = c(1, 2))

    boxplot(systolic ~ gender,
            data = body_c,
            main = "Systolic by Gender",
            xlab = "Gender",
            ylab = "Systolic (mmHg)",
            col = c("pink", "lightblue"))

    boxplot(diastolic ~ gender,
            data = body_c,
            main = "Diastolic by Gender",
            xlab = "Gender",
            ylab = "Diastolic (mmHg)",
            col = c("pink", "lightblue"))
}, width = 1200, height = 600)


# Mean blood pressure
mean_bp <- aggregate(cbind(systolic, diastolic) ~ gender,
                     data = body_c, FUN = mean)

# Median blood pressure
median_bp <- aggregate(cbind(systolic, diastolic) ~ gender,
                       data = body_c, FUN = median)

# Standard deviation
sd_bp <- aggregate(cbind(systolic, diastolic) ~ gender,
                   data = body_c, FUN = sd)

# Combine into one table
bp_summary <- data.frame(
    Gender = mean_bp$gender,
    Systolic_mean = mean_bp$systolic,
    Systolic_median = median_bp$systolic,
    Systolic_SD = sd_bp$systolic,
    Diastolic_mean = mean_bp$diastolic,
    Diastolic_median = median_bp$diastolic,
    Diastolic_SD = sd_bp$diastolic
)

cat("\nBlood pressure summary by gender:\n")
save_table(bp_summary, "q1c_summary")


# ------------------------------------------------------------
# d) F-test and two-sample t-tests
# ------------------------------------------------------------
section("d) F-test and two-sample t-tests")

# F-test - Equality of Variances
f_sys <- var.test(male$systolic, female$systolic)
f_dia <- var.test(male$diastolic, female$diastolic)

f_results <- data.frame(
    Variable = c("Systolic", "Diastolic"),
    F = c(f_sys$statistic, f_dia$statistic),
    P_value = c(f_sys$p.value, f_dia$p.value)
)

cat("\nF-test results:\n")
save_table(f_results, "q1d_f_test")

# Two-sample t-tests
# Systolic - Welch's t-test - F-test indicated unequal variances
t_sys <- t.test(male$systolic, female$systolic,
                var.equal = FALSE,
                alternative = "two.sided",
                conf.level = 0.95)

# Diastolic - Student's t-test - F-test indicated equal variances
t_dia <- t.test(male$diastolic, female$diastolic,
                var.equal = TRUE,
                alternative = "two.sided",
                conf.level = 0.95)

# t-test results
t_results <- data.frame(
    Variable = c("Systolic", "Diastolic"),
    Test = c("Welch", "Student"),
    T = c(t_sys$statistic, t_dia$statistic),
    DF = c(t_sys$parameter, t_dia$parameter),
    P_value = c(t_sys$p.value, t_dia$p.value),
    CI_lower = c(t_sys$conf.int[1], t_dia$conf.int[1]),
    CI_upper = c(t_sys$conf.int[2], t_dia$conf.int[2])
)

cat("\nt-test results:\n")
save_table(t_results, "q1d_t_test")

# ------------------------------------------------------------
# e) Categorize age into four groups (cuts at 30, 40 and 50)
# ------------------------------------------------------------
section("e) Age groups")

# [a, b) intervals: 30 goes to "30-39" (same cut as Q2.R)
body$age_cat <- cut(body$age,
                    breaks = c(-Inf, 30, 40, 50, Inf),
                    labels = c("<30", "30-39", "40-49", "50+"),
                    right = FALSE)

# check: range of age in each group
aggregate(age ~ age_cat, data = body, FUN = range)

# table: frequency of each age group
age_freq <- table(body$age_cat)
save_table(data.frame(
    Age_group = names(age_freq),
    n         = as.vector(age_freq),
    Percent   = sprintf("%.1f", 100 * as.vector(prop.table(age_freq)))   # always 1 decimal
), "q1e_age_groups")

# bar chart of the age groups
save_figure("q1e_age_groups", function() {
    barplot(age_freq,
            xlab = "Age group",
            ylab = "Number of individuals",
            col = "lightblue")
}, width = 900, height = 600)

# ------------------------------------------------------------
# f) Association between age group and class, and age group and gender
#    (chi-square test of independence)
# ------------------------------------------------------------
section("f) Chi-square tests: age group x class, age group x gender")

# contingency tables
tab_class  <- table(body$age_cat, body$class)
tab_gender <- table(body$age_cat, body$gender)

# save a contingency table with the age group as first column
save_contingency <- function(tab, name) {
    df <- as.data.frame.matrix(tab)
    save_table(cbind(Age_group = rownames(df), df), name)
}
save_contingency(tab_class, "q1f_age_class")
save_contingency(tab_gender, "q1f_age_gender")

# chi-square tests of independence
# H0: the two variables are independent
chi_class  <- chisq.test(tab_class)
chi_gender <- chisq.test(tab_gender)
chi_class
chi_gender

# table: test results and smallest expected count (assumption: all >= 5)
save_table(data.frame(
    Test         = c("Age group x class", "Age group x gender"),
    Chi_squared  = round(c(chi_class$statistic, chi_gender$statistic), 2),
    df           = c(chi_class$parameter, chi_gender$parameter),
    p_value      = sub("^<", "< ", format.pval(c(chi_class$p.value, chi_gender$p.value), digits = 3, eps = 1e-16)),   # "< 1e-16" as in q1b_shapiro
    Min_expected = round(c(min(chi_class$expected), min(chi_gender$expected)), 1)
), "q1f_chisq")

# proportions of class and gender within each age group
save_figure("q1f_proportions", function() {
    # stacked bar chart of the proportions in each age group, legend above it
    prop_barplot <- function(tab, title, legend_title, cols) {
        barplot(t(prop.table(tab, 1)),
                xlab = "Age group", ylab = "Proportion",
                col = cols)
        title(main = title, line = 4)
        legend("top", inset = c(0, -0.14), horiz = TRUE, bty = "n",
               legend = colnames(tab), fill = cols, title = legend_title)
    }
    par(mfrow = c(1, 2), mar = c(5, 4, 6, 1), xpd = TRUE)   # top margin for the legends
    prop_barplot(tab_class, "Class by age group", "Class",
                 c("#d7191c", "#fdae61", "#abd9e9", "#2c7bb6"))
    prop_barplot(tab_gender, "Gender by age group", "Gender",
                 c("#f4a582", "#92c5de"))
})

# ------------------------------------------------------------
# End
# ------------------------------------------------------------
sink()   # stop saving to the log
