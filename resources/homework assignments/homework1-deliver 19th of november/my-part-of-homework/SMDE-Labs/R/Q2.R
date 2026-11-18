# ============================================================
# Question 2: ANOVA
# ============================================================
# Outputs:
#   R/logs/Q2.log              full console output of this script
#   report/tables/q2*.csv      result tables (shown in the report with \csvtable)
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
tab_dir <- "report/tables"
fig_dir <- "report/figures"
for (d in c(log_dir, tab_dir, fig_dir)) dir.create(d, showWarnings = FALSE)

options(width = 80)

# save everything printed from here on to R/logs/Q2.log (and still show it)
if (sink.number() > 0) sink()   # close a log left open by a previous failed run
sink(file.path(log_dir, "Q2.log"), split = TRUE)

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

# packages for the assumption tests (install once: install.packages(c("car", "lmtest")))
suppressPackageStartupMessages({
    library(car)      # leveneTest(), Anova()
    library(lmtest)   # bptest(), dwtest()
})

# p-value as text, e.g. "< 1e-16" or "0.0312"
fmt_p <- function(p) sub("^<\\s*", "< ", format.pval(p, digits = 3, eps = 1e-16))

# palette blue, as in the figures of Question 3
blue <- "#2a78d6"

# ------------------------------------------------------------
# Data: cleaned data set of Question 1 (b), same preparation as Question 1 (a and e)
# ------------------------------------------------------------
section("Data preparation (as in Question 1)")

# cleaned data set written by R/Q1.R (b): impossible values and values outside the adult health ranges removed
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
print(table(body$age_cat))

# response variables of this question, and the two factors of a) and b)
resp_vars <- c("body_fat_pct", "diastolic", "sit_ups", "broad_jump_cm")
factors   <- c("age_cat", "class")

# ------------------------------------------------------------
# a) Distribution of body fat, diastolic blood pressure, sit-ups and broad
#    jump for each age group and for each performance class
# ------------------------------------------------------------
section("a) Distributions by age group and by performance class")

# table: n, mean, standard deviation and median of each variable in each group of a factor
group_summary <- function(f) {
    do.call(rbind, lapply(resp_vars, function(v) {
        g <- body[[f]]
        data.frame(Variable = v,
                   Group    = levels(g),
                   n        = as.vector(tapply(body[[v]], g, length)),
                   Mean     = round(as.vector(tapply(body[[v]], g, mean)), 2),
                   SD       = round(as.vector(tapply(body[[v]], g, sd)), 2),
                   Median   = as.vector(tapply(body[[v]], g, median)))
    }))
}
save_table(group_summary("age_cat"), "q2a_summary_age")
save_table(group_summary("class"),   "q2a_summary_class")

# figures: boxplots of each variable by group, one panel per variable
draw_boxplots <- function(f) function() {
    par(mfrow = c(1, 4))
    for (v in resp_vars) {
        boxplot(body[[v]] ~ body[[f]], col = adjustcolor(blue, alpha.f = 0.35), border = "grey20",
                xlab = f, ylab = v, main = v, outcex = 0.4)
    }
}
save_figure("q2a_boxplots_age",   draw_boxplots("age_cat"), width = 1800, height = 650)
save_figure("q2a_boxplots_class", draw_boxplots("class"),   width = 1800, height = 650)

# ------------------------------------------------------------
# b) Effect of age group and performance class on diastolic blood pressure,
#    body fat, sit-ups and broad jump (ANOVA)
# ------------------------------------------------------------
section("b) ANOVA: age group and performance class")

# One-way ANOVA: 8 models, each variable of resp_vars by age_cat and by class.
# H0: the mean is the same in all groups; H1: at least one mean is different.
# No extra outlying observations are removed: Q1 b) already removed the impossible values
# and those outside the adult health ranges, and the remaining ones are possible values.

# one-way ANOVA model y ~ g (do.call keeps the formula itself in the model call)
fit_oneway <- function(v, f) do.call("aov", list(formula = reformulate(f, response = v), data = quote(body)))

grid_b   <- expand.grid(Variable = resp_vars, Factor = factors, stringsAsFactors = FALSE)
models_b <- lapply(seq_len(nrow(grid_b)), function(i) fit_oneway(grid_b$Variable[i], grid_b$Factor[i]))
names(models_b) <- paste(grid_b$Variable, grid_b$Factor)

# table: ANOVA of the 8 models; Eta_sq = share of the variability explained by the factor
# (size of the effect: with n of about 12,700 even tiny differences are significant)
save_table(do.call(rbind, lapply(seq_len(nrow(grid_b)), function(i) {
    s <- summary(models_b[[i]])[[1]]
    data.frame(Variable = grid_b$Variable[i],
               Factor   = grid_b$Factor[i],
               Df       = s$Df[1],
               F        = round(s$`F value`[1], 1),
               p_value  = fmt_p(s$`Pr(>F)`[1]),
               Eta_sq   = round(s$`Sum Sq`[1] / sum(s$`Sum Sq`), 3))
})), "q2b_anova")

# assumptions of a model on its residuals, with the groups g:
#   normality (Shapiro-Wilk, sample of 5000), H0: normal
#   equal variances (Levene and Breusch-Pagan), H0: equal variances
#   independence (Durbin-Watson), H0: no autocorrelation
#   Var_ratio: largest / smallest group variance (rule of thumb: about 2 or less)
assumption_row <- function(model, y, g) {
    r <- residuals(model)
    set.seed(123)
    v <- tapply(y, g, var)
    data.frame(Shapiro_p = fmt_p(shapiro.test(if (length(r) > 5000) sample(r, 5000) else r)$p.value),
               Levene_p  = fmt_p(leveneTest(y ~ g)$`Pr(>F)`[1]),
               BP_p      = fmt_p(bptest(model)$p.value),
               DW_p      = fmt_p(dwtest(model, alternative = "two.sided")$p.value),
               Var_ratio = round(max(v) / min(v), 2))
}

# table: assumptions of the 8 models
save_table(do.call(rbind, lapply(seq_len(nrow(grid_b)), function(i) {
    v <- grid_b$Variable[i]; f <- grid_b$Factor[i]
    cbind(data.frame(Variable = v, Factor = f), assumption_row(models_b[[i]], body[[v]], body[[f]]))
})), "q2b_assumptions")

# figure: normal Q-Q plots of the residuals of the 8 models (top: age_cat, bottom: class)
save_figure("q2b_qqplots", function() {
    par(mfrow = c(2, 4))
    for (i in seq_len(nrow(grid_b))) {
        r <- residuals(models_b[[i]])
        qqnorm(r, pch = 20, cex = 0.3, col = adjustcolor(blue, alpha.f = 0.4),
               main = paste(grid_b$Variable[i], "~", grid_b$Factor[i]))
        qqline(r, col = "grey20", lwd = 2)
    }
}, width = 1800, height = 900)

# post-hoc tests of a factor: for each pair of groups, the difference of means (later - earlier group)
# and the p-value of Tukey HSD, Bonferroni and LSD (no correction, pooled SD); a pair differs if p <= 0.05
posthoc_table <- function(y, g, model, term) {
    lv  <- levels(g)
    tk  <- TukeyHSD(model, term)[[term]]
    bon <- pairwise.t.test(y, g, p.adjust.method = "bonferroni")$p.value
    lsd <- pairwise.t.test(y, g, p.adjust.method = "none")$p.value
    pairs <- combn(seq_along(lv), 2)
    do.call(rbind, lapply(seq_len(ncol(pairs)), function(k) {
        a <- lv[pairs[1, k]]; b <- lv[pairs[2, k]]   # b comes after a in the levels
        data.frame(Pair         = paste(b, "vs", a),
                   Diff         = round(tk[paste0(b, "-", a), "diff"], 2),
                   Tukey_p      = tk[paste0(b, "-", a), "p adj"],
                   Bonferroni_p = bon[b, a],
                   LSD_p        = lsd[b, a])
    }))
}

# post-hoc tests of the models that reject H0, one table per factor, and the number of
# pairs that differ according to each test
posthoc_b <- lapply(seq_len(nrow(grid_b)), function(i) {
    v <- grid_b$Variable[i]; f <- grid_b$Factor[i]
    p_anova <- summary(models_b[[i]])[[1]]$`Pr(>F)`[1]
    if (p_anova > 0.05) return(NULL)
    cbind(data.frame(Variable = v, Factor = f), posthoc_table(body[[v]], body[[f]], models_b[[i]], f))
})
posthoc_b <- do.call(rbind, posthoc_b)

# p-values as text; very small Tukey p-values are not accurate (limit of ptukey, about 1e-8 to 1e-11
# depending on the group sizes), so they are shown as "< 1e-7"
format_posthoc <- function(d) {
    d$Tukey_p      <- ifelse(d$Tukey_p < 1e-7, "< 1e-7", fmt_p(d$Tukey_p))
    d$Bonferroni_p <- fmt_p(d$Bonferroni_p)
    d$LSD_p        <- fmt_p(d$LSD_p)
    d
}
for (f in factors) {
    save_table(format_posthoc(posthoc_b[posthoc_b$Factor == f, setdiff(names(posthoc_b), "Factor")]),
               if (f == "age_cat") "q2b_posthoc_age" else "q2b_posthoc_class")
}

# table: number of the 6 pairs of groups that differ according to each test
save_table(aggregate(cbind(Tukey = Tukey_p <= 0.05, Bonferroni = Bonferroni_p <= 0.05, LSD = LSD_p <= 0.05)
                     ~ Variable + Factor, data = posthoc_b, FUN = sum),
           "q2b_posthoc_summary")

# ------------------------------------------------------------
# c) Effect of age and gender together on sit-ups and broad jump,
#    and their interaction (two-way ANOVA)
# ------------------------------------------------------------
section("c) Two-way ANOVA: age group x gender")

# Two-way ANOVA with interaction, for sit_ups and broad_jump_cm:
# one F-test for age_cat, gender and the interaction age_cat:gender
resp_c   <- c("sit_ups", "broad_jump_cm")
models_c <- lapply(resp_c, function(v)
    do.call("aov", list(formula = as.formula(paste(v, "~ age_cat * gender")), data = quote(body))))
names(models_c) <- resp_c

# table: ANOVA of each model with type II tests (car::Anova): each main effect is tested adjusted
# for the other, since the groups are unbalanced and age and gender are related (the share of men
# differs between age groups); the interaction test is the same as with summary(aov());
# Eta_sq_partial = share of the variability not explained by the other terms that this term explains
save_table(do.call(rbind, lapply(resp_c, function(v) {
    s  <- Anova(models_c[[v]], type = 2)
    ss_res <- s$`Sum Sq`[nrow(s)]
    k  <- seq_len(nrow(s) - 1)   # without the residuals row
    data.frame(Variable       = v,
               Term           = rownames(s)[k],
               Df             = s$Df[k],
               F              = round(s$`F value`[k], 1),
               p_value        = fmt_p(s$`Pr(>F)`[k]),
               Eta_sq_partial = round(s$`Sum Sq`[k] / (s$`Sum Sq`[k] + ss_res), 3))
})), "q2c_anova")

# figure: interaction plots, mean of each variable by age group, one line per gender
# (parallel lines = no interaction)
save_figure("q2c_interaction", function() {
    par(mfrow = c(1, 2))
    for (v in resp_c) {
        interaction.plot(body$age_cat, body$gender, body[[v]], type = "b", pch = c(16, 17),
                         col = c(blue, "#eb6834"), lty = c(1, 2), lwd = 2,
                         xlab = "age_cat", ylab = paste("mean of", v), trace.label = "gender",
                         main = v, legend = TRUE)
    }
}, width = 1600, height = 700)

# table: assumptions of the two models, with the 8 groups age_cat x gender
cell <- interaction(body$age_cat, body$gender)
save_table(do.call(rbind, lapply(resp_c, function(v)
    cbind(data.frame(Variable = v), assumption_row(models_c[[v]], body[[v]], cell)))),
    "q2c_assumptions")

# figure: normal Q-Q plots of the residuals of the two models
save_figure("q2c_qqplots", function() {
    par(mfrow = c(1, 2))
    for (v in resp_c) {
        r <- residuals(models_c[[v]])
        qqnorm(r, pch = 20, cex = 0.3, col = adjustcolor(blue, alpha.f = 0.4), main = paste(v, "~ age_cat * gender"))
        qqline(r, col = "grey20", lwd = 2)
    }
}, width = 1600, height = 700)

# post-hoc tests of age_cat: if the interaction is significant, the effect of age_cat is compared
# separately in each gender (one-way model in each gender); if not, on the main effect of age_cat
# (gender has only 2 levels, so its F-test is enough)
posthoc_c <- do.call(rbind, lapply(resp_c, function(v) {
    p_int <- summary(models_c[[v]])[[1]]$`Pr(>F)`[3]
    if (p_int <= 0.05) {
        do.call(rbind, lapply(levels(body$gender), function(gd) {
            d <- body[body$gender == gd, ]
            m <- do.call("aov", list(formula = reformulate("age_cat", response = v), data = quote(d)))
            cbind(data.frame(Variable = v, Gender = gd), posthoc_table(d[[v]], d$age_cat, m, "age_cat"))
        }))
    } else {
        cbind(data.frame(Variable = v, Gender = "both"), posthoc_table(body[[v]], body$age_cat, models_c[[v]], "age_cat"))
    }
}))
save_table(format_posthoc(posthoc_c), "q2c_posthoc")

# ------------------------------------------------------------
# End
# ------------------------------------------------------------
sink()   # stop saving to the log
