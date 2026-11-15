# ============================================================
# Question 3: Regression analysis (predict broad_jump_cm)
# ============================================================
# Outputs:
#   R/logs/Q3.log              full console output of this script
#   report/tables/q3*.csv      result tables (shown in the report with \csvtable)
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
tab_dir <- "report/tables"
fig_dir <- "report/figures"
for (d in c(log_dir, tab_dir, fig_dir)) dir.create(d, showWarnings = FALSE)

options(width = 80)

# save everything printed from here on to R/logs/Q3.log (and still show it)
if (sink.number() > 0) sink()   # close a log left open by a previous failed run
sink(file.path(log_dir, "Q3.log"), split = TRUE)

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

suppressPackageStartupMessages({
    library(lmtest)
    library(MASS)
    library(car)      # vif()
})

fmt_p <- function(p) sub("^<\\s*", "< ", format.pval(p, digits = 3, eps = 1e-16))

# ------------------------------------------------------------
# Data: cleaned data set of Question 1 (b), age groups as in Question 1 (e)
# ------------------------------------------------------------
section("Data preparation")

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

# age groups cut at 30, 40 and 50
body$age_cat <- cut(body$age,
                    breaks = c(-Inf, 30, 40, 50, Inf),
                    labels = c("<30", "30-39", "40-49", "50+"),
                    right = FALSE)

# ------------------------------------------------------------
# a) Best simple linear regression model to predict broad_jump_cm
# ------------------------------------------------------------
section("a) Best simple linear regression model")

# data frame with only the variables of the question (and the response)
q3 <- body[, c("broad_jump_cm", "body_fat_pct", "grip_force", "sit_ups", "gender", "age_cat")]

# numerical candidate predictors
predictors <- c("body_fat_pct", "grip_force", "sit_ups")

# table: correlation matrix of the response and the numerical predictors
r <- round(cor(q3[c("broad_jump_cm", predictors)]), 3)
save_table(cbind(data.frame(Variable = rownames(r)), as.data.frame(r)), "q3a_correlation")

# one simple linear regression per predictor: broad_jump_cm = b0 + b1 * x
# (do.call keeps the formula itself in the model call, which boxcox() needs to refit the model)
slr <- lapply(predictors, function(p)
    do.call("lm", list(formula = reformulate(p, response = "broad_jump_cm"), data = quote(q3))))
names(slr) <- predictors

# table: fitted equation and fit of each simple model
save_table(do.call(rbind, lapply(predictors, function(p) {
    s <- summary(slr[[p]])
    b <- coef(slr[[p]])
    data.frame(Equation  = sprintf("%.2f %s %.3f %s",
                                   b[1], ifelse(b[2] < 0, "-", "+"), abs(b[2]), p),
               R2        = round(s$r.squared, 3),
               Adj_R2    = round(s$adj.r.squared, 3),
               Sigma     = round(s$sigma, 2))           # residual standard error
})), "q3a_slr")

# best simple model: the highest R^2 (all have the same number of predictors)
best <- predictors[which.max(sapply(slr, function(m) summary(m)$r.squared))]
m_a  <- slr[[best]]
print(summary(m_a))   # t-test of the slope, cited in the report

# Box-Cox: the power lambda that makes the residuals closest to normal (lambda = 1: no transformation);
# the transformed model is only used to check whether it solves the non-constant variance (it does not)
bc <- boxcox(m_a, lambda = seq(-1, 3, by = 0.01), plotit = FALSE)
lambda <- bc$x[which.max(bc$y)]

# same model with the Box-Cox transformed response
q3$broad_jump_bc <- (q3$broad_jump_cm^lambda - 1) / lambda
m_a_bc <- lm(as.formula(paste("broad_jump_bc ~", best)), data = q3)

# assumptions of a model
#   normality of the residuals (Shapiro-Wilk, sample of 5000), H0: normal
#   constant variance (Breusch-Pagan),                         H0: homoscedasticity
#   independence (Durbin-Watson),                              H0: no autocorrelation
#   outliers: |standardized residual| > 2
assumption_row <- function(model, name) {
    r  <- residuals(model)
    set.seed(123)
    dw <- dwtest(model, alternative = "two.sided")
    data.frame(Model       = name,
               R2          = round(summary(model)$r.squared, 3),
               Shapiro_p   = fmt_p(shapiro.test(if (length(r) > 5000) sample(r, 5000) else r)$p.value),
               BP_p        = fmt_p(bptest(model)$p.value),
               DW          = round(unname(dw$statistic), 3),
               DW_p        = fmt_p(dw$p.value),
               Outliers    = sum(abs(rstandard(model)) > 2))
}

# table: assumptions of the best model, original and Box-Cox response
save_table(rbind(assumption_row(m_a, "Original"),
                 assumption_row(m_a_bc, paste0("Box-Cox (lambda = ", lambda, ")"))),
           "q3a_assumptions")

# scatter plots of the response against each predictor, with the fitted line
save_figure("q3a_scatter", function() {
    set.seed(123)
    jit <- function(v) if (mean(v == round(v)) > 0.99) jitter(v, amount = 0.5) else v   # no stripes
    par(mfrow = c(1, 3))
    for (p in predictors) {
        plot(jit(q3[[p]]), jit(q3$broad_jump_cm),
             xlab = p, ylab = "broad_jump_cm",
             main = sprintf("%s (R2 = %.3f)", p, summary(slr[[p]])$r.squared),
             pch = 20, cex = 0.3, col = rgb(0.16, 0.47, 0.84, 0.15))   # palette blue, as in the other figures
        abline(slr[[p]], col = "grey20", lwd = 2)
    }
}, width = 1600, height = 550)

# diagnostic plots of the best model, as in the slides: residuals vs fitted (constant variance,
# linearity) and normal Q-Q (normality)
save_figure("q3a_diagnostics", function() {
    par(mfrow = c(1, 2))
    plot(m_a, which = 1:2, pch = 20, cex = 0.3)
}, width = 1600, height = 700)

# Box-Cox profile log-likelihood
save_figure("q3a_boxcox", function() {
    boxcox(m_a, lambda = seq(0, 3, by = 0.05))
    title(main = paste("Box-Cox: broad_jump_cm ~", best))
}, width = 900, height = 600)

# ------------------------------------------------------------
# b) Multiple linear regression with the two most important numerical variables
# ------------------------------------------------------------
section("b) Multiple linear regression")

# from here on the response is broad_jump_cm without transformation, since the assumptions of the
# model of b) hold without it

# formula "broad_jump_cm ~ x1 + x2 + ..." from a vector of predictor names
resp_formula <- function(vars) as.formula(paste("broad_jump_cm ~", paste(vars, collapse = " + ")))

# R^2, adjusted R^2 and residual standard error of a model
fit_row <- function(model) {
    s <- summary(model)
    data.frame(R2     = round(s$r.squared, 3),
               Adj_R2 = round(s$adj.r.squared, 3),
               Sigma  = round(s$sigma, 2))
}

# full model with the three numerical predictors
m_full <- lm(resp_formula(predictors), data = q3)

# the three models with two predictors, compared with the full model by a partial F-test
# (H0: the coefficient of the removed predictor is 0)
pairs_b  <- combn(predictors, 2, simplify = FALSE)
models_b <- lapply(pairs_b, function(vars) lm(resp_formula(vars), data = q3))

# fitted equation of a model as text, e.g. "72.64 + 1.790 grip_force + 1.297 sit_ups"
eq_text <- function(model) {
    b <- coef(model)
    paste0(sprintf("%.2f", b[1]),
           paste(sprintf(" %s %.3f %s", ifelse(b[-1] < 0, "-", "+"), abs(b[-1]), names(b)[-1]), collapse = ""))
}

# table: the three models with two predictors: fitted equation, adjusted R^2, residual standard
# error, and partial F-test against the full model (H0: the coefficient of the predictor not in the
# model is 0)
save_table(do.call(rbind, lapply(seq_along(pairs_b), function(i) {
    m  <- models_b[[i]]
    pf <- anova(m, m_full)
    data.frame(Equation  = eq_text(m),
               Adj_R2    = round(summary(m)$adj.r.squared, 3),
               Sigma     = round(summary(m)$sigma, 2),
               F_partial = round(pf$F[2], 1),
               p_partial = fmt_p(pf$`Pr(>F)`[2]))
})), "q3b_selection")

# chosen model: the two predictors with the highest adjusted R^2
# (= the full model without the predictor with the smallest partial F)
best_b <- which.max(sapply(models_b, function(m) summary(m)$adj.r.squared))
pred_b <- pairs_b[[best_b]]
m_b    <- models_b[[best_b]]
print(summary(m_b))   # t-tests of the coefficients, cited in the report

# assumptions of the model of b), and multicollinearity between its predictors (VIF > 10: high)
save_table(cbind(assumption_row(m_b, paste("b)", paste(pred_b, collapse = " + "))),
                 VIF = round(max(vif(m_b)), 2)),
           "q3b_assumptions")

# figure: scatter plot matrix of the response and the two predictors of b):
# below the diagonal the scatter plots with their fitted line, above it the correlations,
# on the diagonal the histograms. Whole-number values are jittered by up to 0.5 so that they do not form stripes;
# the response goes last, so that the bottom row shows it (y) against each predictor (x)
save_figure("q3b_pairs", function() {
    set.seed(123)
    jit <- function(v) if (mean(v == round(v)) > 0.99) jitter(v, amount = 0.5) else v   # counts and whole cm
    panel_fit <- function(x, y, ...) {
        points(jit(x), jit(y), pch = 20, cex = 0.25, col = rgb(0.16, 0.47, 0.84, 0.10))
        abline(lm(y ~ x), col = "grey20", lwd = 2)
    }
    panel_cor <- function(x, y, ...) {
        usr <- par("usr"); on.exit(par(usr = usr))
        par(usr = c(0, 1, 0, 1))
        text(0.5, 0.5, sprintf("r = %.3f", cor(x, y)), cex = 3, font = 2)
    }
    panel_hist <- function(x, ...) {
        usr <- par("usr"); on.exit(par(usr = usr))
        h <- hist(x, breaks = 40, plot = FALSE)
        par(usr = c(usr[1:2], 0, max(h$counts) * 1.45))   # room for the name above the bars
        rect(h$breaks[-length(h$breaks)], 0, h$breaks[-1], h$counts,
             col = adjustcolor("#2a78d6", alpha.f = 0.6), border = "white")   # same blue as the points
    }
    pairs(q3[c(pred_b, "broad_jump_cm")], lower.panel = panel_fit, upper.panel = panel_cor,
          diag.panel = panel_hist, gap = 0.5, cex.labels = 2, font.labels = 2, label.pos = 0.88,
          cex.axis = 1.4, font.axis = 2)
}, width = 1300, height = 1300)

# diagnostic plots of the model of b), as in a): residuals vs fitted and normal Q-Q
save_figure("q3b_diagnostics", function() {
    par(mfrow = c(1, 2))
    plot(m_b, which = 1:2, pch = 20, cex = 0.3)
}, width = 1600, height = 700)

# comparison with the simple model of a) on the same response (without transformation),
# and partial F-test of the predictor added in b) (H0: its coefficient is 0)
pf_ab <- if (best %in% pred_b) anova(m_a, m_b) else NULL   # only valid if a) is nested in b)
save_table(rbind(
    cbind(data.frame(Model = "a)", Predictors = best), fit_row(m_a),
          data.frame(F_partial = "-", p_partial = "-")),
    cbind(data.frame(Model = "b)", Predictors = paste(pred_b, collapse = " + ")), fit_row(m_b),
          data.frame(F_partial = if (is.null(pf_ab)) "-" else as.character(round(pf_ab$F[2], 1)),
                     p_partial = if (is.null(pf_ab)) "-" else fmt_p(pf_ab$`Pr(>F)`[2])))),
    "q3b_comparison")

# observed against predicted broad_jump_cm of some models, side by side with the same axes;
# the closer the points to the grey line y = x (not a regression line), the better the model
draw_fit <- function(models, labels) {
    lim <- range(q3$broad_jump_cm, sapply(models, function(m) range(fitted(m))))
    par(mfrow = c(1, length(models)))
    for (i in seq_along(models)) {
        plot(fitted(models[[i]]), q3$broad_jump_cm, pch = 20, cex = 0.3,
             col = rgb(0.16, 0.47, 0.84, 0.15), xlim = lim, ylim = lim, asp = 1,
             xlab = "Predicted broad_jump_cm", ylab = "Observed broad_jump_cm",
             main = sprintf("%s\nadjusted R2 = %.3f, residual SE = %.2f cm", labels[i],
                            summary(models[[i]])$adj.r.squared, summary(models[[i]])$sigma))
        abline(0, 1, col = "grey30", lwd = 2)
        legend("topleft", "y = x", col = "grey30", lwd = 2, bty = "n")
    }
}

# figure: models of a) and b)
save_figure("q3b_vs_a", function() {
    draw_fit(list(m_a, m_b), c(paste("a)", best), paste("b)", paste(pred_b, collapse = " + "))))
}, width = 1600, height = 800)

# ------------------------------------------------------------
# c) Model of b) with a factor: (i) age_cat, (ii) gender
# ------------------------------------------------------------
section("c) Model of b) with a factor: (i) age_cat, (ii) gender")

# a factor enters the model as dummy (0/1) variables, one per level except the first,
# which is the reference category (age_cat "<30", gender "Female"); each dummy coefficient is the
# expected difference with the reference category when grip_force and sit_ups stay constant

# the two models are independent: (i) model of b) + age_cat, (ii) model of b) + gender
m_c_age    <- lm(resp_formula(c(pred_b, "age_cat")), data = q3)
m_c_gender <- lm(resp_formula(c(pred_b, "gender")),  data = q3)
print(summary(m_c_age))      # overall F-test, cited in the report
print(summary(m_c_gender))   # overall F-test, cited in the report

# coefficients of a model and their 95% confidence intervals (a coefficient is significant at a
# 95% confidence level when its interval does not contain 0)
coef_table <- function(model) {
    ci <- confint(model, level = 0.95)
    data.frame(Term     = names(coef(model)),
               Estimate = round(coef(model), 3),
               CI_lower = round(ci[, 1], 3),
               CI_upper = round(ci[, 2], 3))
}

# tables: coefficients and 95% confidence intervals of each model
save_table(coef_table(m_c_age),    "q3c_age_coef")
save_table(coef_table(m_c_gender), "q3c_gender_coef")

# table: overall summary of the two models
model_row <- function(model, name, vars) {
    cbind(data.frame(Model = name, Predictors = paste(vars, collapse = " + ")),
          fit_row(model))
}
save_table(rbind(model_row(m_c_age,    "c i)",  c(pred_b, "age_cat")),
                 model_row(m_c_gender, "c ii)", c(pred_b, "gender"))),
           "q3c_summary")

# figure: predicted broad_jump_cm for each category, against one predictor with the other at its mean;
# rows: age_cat (model c i) and gender (model c ii); columns: grip_force and sit_ups on the x axis
save_figure("q3c_categories", function() {
    cols  <- c("#2a78d6", "#eb6834", "#1baf7a", "#eda100")   # blue, orange, aqua, yellow
    units <- c(grip_force = "(kg)", sit_ups = "")
    draw_panel <- function(model, f, xvar, main) {
        other  <- setdiff(pred_b, xvar)
        x_grid <- seq(quantile(q3[[xvar]], 0.05), quantile(q3[[xvar]], 0.95), length.out = 100)
        lv <- levels(q3[[f]])
        y <- sapply(lv, function(l) {
            nd <- data.frame(x_grid, mean(q3[[other]]), factor(l, levels = lv))
            names(nd) <- c(xvar, other, f)
            predict(model, nd)
        })
        matplot(x_grid, y, type = "l", lty = seq_along(lv), lwd = 2, col = cols[seq_along(lv)],
                xlab = paste(xvar, units[xvar]), ylab = "Predicted broad_jump_cm",
                main = sprintf("%s (%s at its mean)", main, other))
        legend("topleft", lv, col = cols[seq_along(lv)], lty = seq_along(lv), lwd = 2,
               title = f, bty = "n")
    }
    par(mfrow = c(2, 2))
    for (xvar in pred_b) draw_panel(m_c_age,    "age_cat", xvar, "c i) b) + age_cat")
    for (xvar in pred_b) draw_panel(m_c_gender, "gender",  xvar, "c ii) b) + gender")
}, width = 1600, height = 1300)

# ------------------------------------------------------------
# d) Comparison of the model of b) with the two models of c)
# ------------------------------------------------------------
section("d) Comparison of the model of b) with the two models of c)")

models_d <- list("b)" = m_b, "c i)" = m_c_age, "c ii)" = m_c_gender)
vars_d   <- list(pred_b, c(pred_b, "age_cat"), c(pred_b, "gender"))
label_d  <- paste(names(models_d), sapply(vars_d, paste, collapse = " + "))

# table: fit of the three models, and partial F-test of each factor against the model of b)
# (b) is nested in both models of c); H0: all the coefficients of the added factor are 0)
save_table(do.call(rbind, lapply(seq_along(models_d), function(i) {
    pf <- if (i == 1) NULL else anova(m_b, models_d[[i]])
    cbind(data.frame(Model = names(models_d)[i], Predictors = paste(vars_d[[i]], collapse = " + ")),
          fit_row(models_d[[i]]),
          data.frame(F_partial = if (is.null(pf)) "-" else as.character(round(pf$F[2], 1)),
                     Df        = if (is.null(pf)) "-" else as.character(pf$Df[2]),
                     p_partial = if (is.null(pf)) "-" else fmt_p(pf$`Pr(>F)`[2])))
})), "q3d_comparison")

# chosen model: c ii) (model of b) + gender): highest adjusted R^2, smallest error,
# and only one coefficient more than the model of b)
m_final <- m_c_gender

# figure: observed against predicted broad_jump_cm of the three models
save_figure("q3d_fit", function() draw_fit(models_d, label_d), width = 1800, height = 700)

# ------------------------------------------------------------
# e) Validity of the final model (c ii: model of b) + gender)
# ------------------------------------------------------------
section("e) Validity of the final model")

r_final  <- residuals(m_final)
rs_final <- rstandard(m_final)

# assumption tests on the residuals (same as in a) and b))
set.seed(123)
sw_final <- shapiro.test(if (length(r_final) > 5000) sample(r_final, 5000) else r_final)
bp_final <- bptest(m_final)
dw_final <- dwtest(m_final, alternative = "two.sided")

# constant variance between the two genders: Levene test on the residuals (H0: equal variances)
lev_final <- leveneTest(r_final ~ q3$gender)
sd_gender <- tapply(r_final, q3$gender, sd)

# multicollinearity
vif_final <- vif(m_final)

# table: validity checks of the final model
verdict <- function(p, reject, keep) ifelse(p < 0.05, reject, keep)
save_table(data.frame(
    Check = c("Normality",
              "Constant variance", "Equal variance by gender", "Independence",
              "Outliers", "Multicollinearity"),
    Method = c("Shapiro-Wilk", "Breusch-Pagan", "Levene",
               "Durbin-Watson", "|std. residual| > 2", "VIF"),
    Result = c(sprintf("W = %.4f", sw_final$statistic),
               sprintf("BP = %.1f", bp_final$statistic),
               sprintf("F = %.1f", lev_final$`F value`[1]),
               sprintf("DW = %.3f", dw_final$statistic),
               sprintf("%d (%.1f%%)", sum(abs(rs_final) > 2), 100 * mean(abs(rs_final) > 2)),
               sprintf("max VIF = %.2f", max(vif_final))),
    p_value = c(fmt_p(sw_final$p.value), fmt_p(bp_final$p.value),
                fmt_p(lev_final$`Pr(>F)`[1]), fmt_p(dw_final$p.value), "-", "-"),
    Conclusion = c(verdict(sw_final$p.value, "rejected", "not rejected"),
                   verdict(bp_final$p.value, "rejected", "not rejected"),
                   paste(verdict(lev_final$`Pr(>F)`[1], "rejected", "not rejected"),
                         sprintf("(SD %.1f vs %.1f)", sd_gender[1], sd_gender[2])),   # Female vs Male
                   verdict(dw_final$p.value, "rejected", "not rejected"),
                   ifelse(mean(abs(rs_final) > 2) <= 0.05, "about 5% (as expected)", "more than 5%"),
                   ifelse(max(vif_final) < 10, "no (VIF < 10)", "yes (VIF >= 10)"))
), "q3e_validity")

# Extension (not in the slides): standard errors that stay valid when the variance is not constant
# (heteroscedasticity-consistent HC3, car::hccm); if the predictors stay significant,
# the conclusions do not depend on the constant variance assumption
rob <- coeftest(m_final, vcov = hccm(m_final, type = "hc3"))
save_table(data.frame(Term      = rownames(rob),
                      Estimate  = round(rob[, "Estimate"], 3),
                      SE        = round(coef(summary(m_final))[, "Std. Error"], 3),
                      SE_robust = round(rob[, "Std. Error"], 3),
                      t_robust  = round(rob[, "t value"], 2),
                      p_robust  = fmt_p(rob[, "Pr(>|t|)"])),
           "q3e_robust")

# figure: residual analysis of the final model
save_figure("q3e_residuals", function() {
    par(mfrow = c(2, 2))
    plot(m_final, which = 1:2, pch = 20, cex = 0.3)
    # histogram of the residuals with the normal density of the same mean and standard deviation
    hist(r_final, breaks = 60, freq = FALSE, col = "grey85", border = "white",
         xlab = "Residuals", main = "Histogram of the residuals")
    curve(dnorm(x, mean(r_final), sd(r_final)), add = TRUE, col = "#2a78d6", lwd = 2)
    # spread of the residuals in each gender
    boxplot(r_final ~ q3$gender, col = "grey85", xlab = "gender", ylab = "Residuals",
            main = sprintf("Residuals by gender (SD: %s %.1f, %s %.1f)",
                           names(sd_gender)[1], sd_gender[1], names(sd_gender)[2], sd_gender[2]))
    abline(h = 0, col = "grey40", lty = 2)
}, width = 1500, height = 1200)

# ------------------------------------------------------------
# End
# ------------------------------------------------------------
sink()   # stop saving to the log
