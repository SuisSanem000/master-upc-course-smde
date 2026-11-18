# ============================================================
# Question 1: Visualisation, Chi-Square and t-Test
# ============================================================
# Outputs:
#   R/logs/Q1.log              full console output of this script
#   report/tables/q1*.csv      result tables (shown in the report with \csvtable)
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
tab_dir <- "report/tables"
fig_dir <- "report/figures"
for (d in c(log_dir, tab_dir, fig_dir)) dir.create(d, showWarnings = FALSE)

options(width = 80)

# save everything printed from here on to R/logs/Q1.log (and still show it)
if (sink.number() > 0) sink()   # close a log left open by a previous failed run
sink(file.path(log_dir, "Q1.log"), split = TRUE)

# print a section title in the log
section <- function(title) cat("\n", strrep("=", 60), "\n", title, "\n", strrep("=", 60), "\n", sep = "")

# save a data frame as <tab_dir>/<name>.csv and print it in the log
save_table <- function(df, name) {
    write.csv(df, file.path(tab_dir, paste0(name, ".csv")), row.names = FALSE)
    print(df, row.names = FALSE)
}

# save a chart as <fig_dir>/<name>.png
# draw: a function with the plotting code, e.g. function() hist(x)
save_figure <- function(name, draw, width = 1600, height = 700, res = 120) {
    png(file.path(fig_dir, paste0(name, ".png")), width = width, height = height, res = res)
    draw()
    invisible(dev.off())
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

# table: summary statistics per variable (used for the raw and the cleaned data)
summary_table <- function(df) data.frame(
    Variable = num_vars,
    Min      = sapply(df[num_vars], min),
    Q1       = sapply(df[num_vars], quantile, 0.25),
    Median   = sapply(df[num_vars], median),
    Mean     = round(sapply(df[num_vars], mean), 2),
    Q3       = sapply(df[num_vars], quantile, 0.75),
    Max      = sapply(df[num_vars], max),
    SD       = round(sapply(df[num_vars], sd), 2)
)
save_table(summary_table(body), "q1b_summary")

# boxplots (used for the raw and the cleaned data)
draw_boxplots <- function(df) function() {
    par(mfrow = c(2, 5))
    for (v in num_vars) {
        boxplot(df[[v]],
                main = v,
                col = "lightblue")
    }
}
save_figure("q1b_boxplots", draw_boxplots(body))

# table: outliers (outside 1.5 * IQR from the quartiles) and zero values per variable
save_table(data.frame(
    Variable = num_vars,
    Outliers = sapply(body[num_vars], function(x) length(boxplot.stats(x)$out)),
    Zeros    = colSums(body[num_vars] == 0)
), "q1b_outliers")


# remove the observations that are impossible or outside the adult health reference ranges
# (report, Appendix: reference table): very rare in people who do these performance tests.
female <- body$gender == "Female"
bmi    <- body$weight_kg / (body$height_cm / 100)^2
rules <- list(
    "systolic < 90 or diastolic < 60"   = body$systolic < 90 | body$diastolic < 60,     # hypotension
    "systolic > 180 or diastolic > 120" = body$systolic > 180 | body$diastolic > 120,   # hypertensive crisis
    "systolic <= diastolic"             = body$systolic <= body$diastolic,              # systolic is always the higher one
    "body_fat_pct < essential or > obesity + 10" =                                      # obesity: 25 men / 32 women
        body$body_fat_pct < ifelse(female, 10, 2) | body$body_fat_pct > ifelse(female, 42, 35),
    "BMI < 16 or >= 40"                 = bmi < 16 | bmi >= 40,                         # margin below underweight (< 18.5), obesity class III
    "grip_force = 0"                    = body$grip_force == 0,                         # test not done
    "broad_jump_cm = 0"                 = body$broad_jump_cm == 0,                      # test not done
    "sit_bend_cm > 50"                  = body$sit_bend_cm > 50                         # 185 and 213 cm
)
rule_vars <- list(c("systolic", "diastolic"), c("systolic", "diastolic"), c("systolic", "diastolic"),
                  "body_fat_pct", c("height_cm", "weight_kg"), "grip_force", "broad_jump_cm", "sit_bend_cm")
remove <- Reduce(`|`, rules)

# table: rule, removed values (systolic/diastolic for blood pressure; only their number if more than 10)
# and number of rows removed
save_table(data.frame(
    Rule   = c(names(rules), "Any of the above"),
    Values = c(mapply(function(rows, vars) {
                   v <- unique(do.call(paste, c(body[rows, vars, drop = FALSE], sep = "/")))
                   if (length(v) > 10) paste(length(v), "values") else paste(sort(v), collapse = ", ")
               }, rules, rule_vars), ""),
    Rows   = c(sapply(rules, sum), sum(remove))
), "q1b_removed")

# cleaned data set for the rest of the assignment (Q1 c-g, Q2): same columns and codes as the original file
write.csv(read.csv("bodyPerformance.csv", check.names = FALSE)[!remove, ],
          "bodyPerformance_clean.csv", row.names = FALSE)
body <- body[!remove, ]
cat("Rows removed:", sum(remove), "- rows left:", nrow(body), "
")

# summary table and boxplots of the cleaned data
save_table(summary_table(body), "q1b_summary_clean")
save_figure("q1b_boxplots_clean", draw_boxplots(body))

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

# Combine into one table: one row per measure and gender
bp_summary <- data.frame(
    Measure = rep(c("systolic", "diastolic"), each = nrow(mean_bp)),
    Gender  = rep(as.character(mean_bp$gender), 2),
    Mean    = round(c(mean_bp$systolic, mean_bp$diastolic), 2),
    Median  = c(median_bp$systolic, median_bp$diastolic),
    SD      = round(c(sd_bp$systolic, sd_bp$diastolic), 2)
)

cat("\nBlood pressure summary by gender:\n")
save_table(bp_summary, "q1c_summary")


# ------------------------------------------------------------
# d) One-sample t-tests and 95% confidence intervals of systolic by gender
# ------------------------------------------------------------
section("d) One-sample t-tests for systolic blood pressure")

# One-sample t-tests for each gender
t_male <- t.test(male$systolic, conf.level = 0.95, mu=120)
t_female <- t.test(female$systolic, conf.level = 0.95, mu=120)

# Format p-values
p_values <- sub("^< ?", "< ", c(
    format.pval(t_male$p.value, digits = 3, eps = 1e-300),
    format.pval(t_female$p.value, digits = 3, eps = 1e-300)
))

# Results
t_results <- data.frame(
    Gender = c("Male", "Female"),
    Mean = round(c(unname(t_male$estimate), unname(t_female$estimate)), 2),
    T = round(c(unname(t_male$statistic), unname(t_female$statistic)), 2),
    DF = c(unname(t_male$parameter), unname(t_female$parameter)),
    P_value = p_values,
    CI_lower = round(c(t_male$conf.int[1], t_female$conf.int[1]), 2),
    CI_upper = round(c(t_male$conf.int[2], t_female$conf.int[2]), 2)
)

cat("\nOne-sample t-test results:\n")
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
# g) Physical performance comparison by gender
# ------------------------------------------------------------
section("g) Physical performance comparison by gender")

variables <- c("grip_force",
               "sit_bend_cm",
               "sit_ups",
               "broad_jump_cm")

# distribution plots

save_figure("q1g_distributions", function() {

    par(mfrow = c(2, 2))

    for (v in variables) {

        x <- male[[v]]
        y <- female[[v]]

        d_m <- density(x)
        d_f <- density(y)

        plot(d_m,
             main = v,
             xlab = v,
             xlim = range(x, y),
             ylim = c(0, max(d_m$y, d_f$y)),
             col = "blue",
             lwd = 2)

        lines(d_f, col = "red", lwd = 2)

        legend("topright",
               legend = c("Male", "Female"),
               col = c("blue", "red"),
               lty = 1, lwd = 2)
    }

}, width = 1400, height = 900)

# 2. Shapiro-Wilk normality tests

set.seed(123)
male_sample <- sample(nrow(male), 5000)

shapiro_results <- data.frame()

for (v in variables) {

    s_m <- shapiro.test(male[[v]][male_sample])
    s_f <- shapiro.test(female[[v]])

    shapiro_results <- rbind(shapiro_results,
        data.frame(
            Variable = c(v, v),
            Gender = c("Male", "Female"),
            W = round(c(s_m$statistic, s_f$statistic), 4),
            P_value = sub("^< ?", "< ", format.pval(c(s_m$p.value, s_f$p.value), digits = 3, eps = 1e-16))
        ))
}

cat("\nShapiro-Wilk results:\n")
save_table(shapiro_results, "q1g_shapiro")


# Boxplots - Checking Outliers


save_figure("q1g_boxplots", function() {

    par(mfrow = c(2, 2))

    for (v in variables) {
        boxplot(body_c[[v]] ~ body_c$gender,
                main = v,
                xlab = "Gender",
                ylab = v,
                col = c("pink", "lightblue"))
    }

}, width = 1400, height = 900)

# F-tests - Equality of Variances

f_results <- data.frame()
t_results <- data.frame()

for (v in variables) {

    x <- male[[v]]
    y <- female[[v]]

    # F-test
    f <- var.test(x, y)

    # Choose t-test based on F-test
    test <- if (f$p.value < 0.05) "Welch" else "Student"

    f_results <- rbind(f_results,
        data.frame(
            Variable = v,
            F = round(unname(f$statistic), 3),
            P_value = sub("^<", "< ", format.pval(f$p.value, digits = 3, eps = 1e-16)),
            Test_chosen = test
        ))

    # Two-sample t-test

    t <- t.test(x, y,
                var.equal = (test == "Student"),
                alternative = "two.sided",
                conf.level = 0.95)

    t_results <- rbind(t_results,
        data.frame(
            Variable = v,
            Test = test,
            T = round(unname(t$statistic), 2),
            DF = round(unname(t$parameter), 1),
            P_value = sub("^< ?", "< ", format.pval(t$p.value, digits = 3, eps = 1e-16)),
            CI_lower = round(t$conf.int[1], 2),
            CI_upper = round(t$conf.int[2], 2)
        ))
}

cat("\nF-test results:\n")
save_table(f_results, "q1g_f_test")

cat("\nt-test results:\n")
save_table(t_results, "q1g_t_test")


# ------------------------------------------------------------
# End
# ------------------------------------------------------------
sink()   # stop saving to the log
