# What I Did for Question 2 (Short Summary)

If your teammates ask what you did to prepare the Question 2 report, you can share this short list:

- **Ran the R scripts (`R/Q1.R` and `R/Q2.R`)** to generate the cleaned dataset (`12,742` rows), the console log (`R/logs/Q2.log`), and all **10 tables** and **5 plots** for Question 2.
- **Reviewed all Q2 outputs** (summary tables, ANOVA tables, assumption tests, post-hoc tables, boxplots, Q-Q plots, and interaction plots) and verified every number against the logs and CSV files.
- **Wrote the Question 2 report in [`report/sections/q2.tex`](SMDE-Labs/report/sections/q2.tex)** covering parts **(a)**, **(b)**, and **(c)**, matching the team's LaTeX conventions (`one sentence per line`, `\texttt{}` for variable names, and citing appendix tables/figures).
- **Updated [`report/sections/appendix.tex`](SMDE-Labs/report/sections/appendix.tex)** by adding `\subsection{Question 2}` with all 10 Q2 tables and 5 Q2 figures so every `\autoref{...}` link compiles cleanly.
- **Tested the full LaTeX build** (`ociamthesismain.tex`) to make sure there are no missing references or compilation errors, and pushed only `report/sections/q2.tex` and `report/sections/appendix.tex` to `main`.
