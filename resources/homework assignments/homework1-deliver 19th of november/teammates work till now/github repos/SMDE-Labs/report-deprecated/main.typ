#import "settings.typ": *
#import "macros.typ": *

#show: report-style
#show raw: set text(style: "italic")

// ------------------------------------------------------------
// TITLE PAGE
// ------------------------------------------------------------
#title-page(
  "First Assignment",
  subtitle: "Fall 2026",
  course: "Statistical Modelling and Design of Experiments",
  authors: ("Simin S.", "Antonina Oliwia C.", "Xiang Feng Y."),
)

#set page(..setup-page(
  "First Assignment",
  "Simin S., Antonina Oliwia C., Xiang Feng Y.",
  "Statistical Modelling and Design of Experiments",
))

// ------------------------------------------------------------
// TABLE OF CONTENTS
// ------------------------------------------------------------
#table-of-contents()

// The body is numbered from page 1 (the 12-page limit excludes the appendix)
#counter(page).update(1)

// ============================================================
// 1. FIRST QUESTION
// ============================================================
= Visualisation, Chi-Square and t-Test <q1>

// ------------------------------------------------------------
// a)
// ------------------------------------------------------------
== Data Import and Variable Types <q1a>

#task[Import the data set to R assigning the type of each variable correctly.]

We have imported the data set and renamed the columns to valid R names (e.g. `body fat_%` becomes `body_fat_pct`).

After that, we gave each variable the type that matches its measurement scale:

- *Nominal categorical:* _gender_ is a factor with the levels `Female` and `Male`.
- *Ordinal categorical:* _class_ is an ordered factor with the levels $D < C < B < A$, from poor to excellent performance.
- *Numerical:* the other variables are numeric. Age could be stored as an integer, but we kept it numeric for simplicity.

The result shows that the data set has 13,393 observations of 12 variables with no missing values. The name, type and levels of each variable are listed in @tab-q1a-variables.

// ------------------------------------------------------------
// b)
// ------------------------------------------------------------
== Descriptive Statistics <q1b>

#task[Summarize the numerical variables and analyze their distributions.]

#xfcomment[Interpret the central tendency, dispersion and shape of the numerical variables using @tab-q1b-summary, @tab-q1b-checks, @fig-q1b-histograms and @fig-q1b-boxplots.]

// ------------------------------------------------------------
// c)
// ------------------------------------------------------------
== Blood Pressure by Gender <q1c>

#task[Consider the variables of diastolic and systolic blood pressure. Eliminate the zero values and check their distributions for the gender groups using proper graph(s). Interpret your findings.]

#xfcomment("Discuss differences in blood pressure distributions between males and females based on your graphs.")

// ------------------------------------------------------------
// d)
// ------------------------------------------------------------
== Confidence Intervals for Systolic Blood Pressure <q1d>

#task[Construct 95% confidence intervals for the mean systolic blood pressure of two gender groups and interpret them.]

#xfcomment("State the resulting intervals and explain their practical meaning in context.")

// ------------------------------------------------------------
// e)
// ------------------------------------------------------------
== Age Groups <q1e>

#task[Categorize the variable age into four categories cutting from the values 30, 40 and 50 and save it as a new variable into your data frame.]

#xfcomment("Verify frequency counts for each new age category to ensure proper binning.")

// ------------------------------------------------------------
// f)
// ------------------------------------------------------------
== Association of Age Groups with Class and Gender <q1f>

#task[Analyze the association first between age groups and class and then between age groups and gender by using proper statistical method.]

#xfcomment("Report test statistics, p-values, and state conclusions regarding independence.")

// ------------------------------------------------------------
// g)
// ------------------------------------------------------------
== Physical Performance by Gender <q1g>

#task[Test whether physical performance test results of the individuals are affected from the gender. Check the assumptions and visualize the relationship between these two characteristics.]

#xfcomment("Summarize assumption checks and discuss whether physical performance differs significantly by gender.")

// ============================================================
// 2. SECOND QUESTION
// ============================================================
= Title of Question 2 <q2>

== Title of Part a <q2a>

#task[Statement of part a.]

#xfcomment("Your analysis here.")

== Title of Part b <q2b>

#task[Statement of part b.]

#xfcomment("Your analysis here.")

// ============================================================
// 3. THIRD QUESTION
// ============================================================
= Title of Question 3 <q3>

== Title of Part a <q3a>

#task[Statement of part a.]

#xfcomment("Your analysis here.")

== Title of Part b <q3b>

#task[Statement of part b.]

#xfcomment("Your analysis here.")

// ============================================================
// APPENDIX
// ============================================================
#show: appendix

// ------------------------------------------------------------
// APPENDIX A: TABLES (CSV files written by R/Q*.R in report/tables/)
// ------------------------------------------------------------
= Tables

== Question 1

#csv-table(
  "q1a_variables",
  caption: [Variables of the data set: name in R, original name, type and levels.],
  label: <tab-q1a-variables>,
)

#csv-table(
  "q1b_summary",
  caption: [Summary statistics of the numerical variables.],
  label: <tab-q1b-summary>,
)

#csv-table(
  "q1b_checks",
  caption: [Shapiro-Wilk p-value (random sample of 5,000), number of outliers ($1.5 times "IQR"$ rule) and number of zero values of the numerical variables.],
  label: <tab-q1b-checks>,
)

// ------------------------------------------------------------
// APPENDIX B: FIGURES (PNG files written by R/Q*.R in report/figures/)
// ------------------------------------------------------------
#pagebreak()
= Figures

== Question 1

#figure(
  image("figures/q1b_histograms.png", width: 100%),
  caption: [Histograms of the numerical variables.],
) <fig-q1b-histograms>

#figure(
  image("figures/q1b_boxplots.png", width: 100%),
  caption: [Boxplots of the numerical variables.],
) <fig-q1b-boxplots>
