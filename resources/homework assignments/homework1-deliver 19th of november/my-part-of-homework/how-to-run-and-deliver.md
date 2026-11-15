# Step-by-Step Guide: How to Run the Project, Check Your Changes, and Deliver Q2

This guide summarizes all setup, running, LaTeX compilation, and Git delivery rules from `README.md`, `report/README.md`, and your teammates' WhatsApp chat.

---

## 1. One-Time Setup on Your Mac

1. **Install required R packages** (run once in your R console or terminal):
   ```sh
   Rscript -e 'install.packages(c("lmtest", "car", "languageserver", "jsonlite", "rlang"), repos="https://cloud.r-project.org")'
   ```
2. **Install LaTeX on Mac (BasicTeX + needed packages)**:
   - Install `BasicTeX.pkg` from `https://tug.org/mactex/morepackages.html`.
   - Open Terminal and install `latexmk` and the extra LaTeX packages used by the report:
     ```sh
     export PATH="/Library/TeX/texbin:$PATH"
     sudo tlmgr update --self
     sudo tlmgr install latexmk datatool csvsimple xstring enumitem xurl substr tracklang
     ```
   - Restart Antigravity / VS Code (`Cmd+Q`, then reopen) so it picks up `/Library/TeX/texbin`.
3. **Recommended VS Code Extensions** (optional, listed in `.vscode/extensions.json`):
   - Open the `SMDE-Labs` folder in VS Code, press `Cmd+Shift+X`, type `@recommended`, and install them (especially **LaTeX Workshop** and **LTeX+**).

---

## 2. How to Run the R Scripts to Generate Tables, Figures, and Logs

All generated files (`bodyPerformance_clean.csv`, `R/logs/`, `report/tables/`, `report/figures/`) are **git-ignored**, so you must run the R scripts locally before compiling the LaTeX report.

From the root of `SMDE-Labs/`, run:

```sh
Rscript R/Q1.R
Rscript R/Q2.R
Rscript R/Q3.R
```

- **Why run `R/Q1.R` first?** Because `R/Q1.R` cleans the raw data and writes `bodyPerformance_clean.csv` (12,742 rows), which `R/Q2.R` and `R/Q3.R` read.
- **What `R/Q2.R` generates**:
  - `R/logs/Q2.log`: Full console output of Question 2.
  - `report/tables/q2*.csv`: 10 result tables (`q2a_summary_age.csv`, `q2a_summary_class.csv`, `q2b_anova.csv`, `q2b_assumptions.csv`, `q2b_posthoc_age.csv`, `q2b_posthoc_class.csv`, `q2b_posthoc_summary.csv`, `q2c_anova.csv`, `q2c_assumptions.csv`, `q2c_posthoc.csv`).
  - `report/figures/q2*.png`: 5 figures (`q2a_boxplots_age.png`, `q2a_boxplots_class.png`, `q2b_qqplots.png`, `q2c_interaction.png`, `q2c_qqplots.png`).

---

## 3. How to Compile the LaTeX Report (`report/_build/ociamthesismain.pdf`)

Make sure you have already done **Step 1** (BasicTeX + `tlmgr install ...`) and **Step 2** (running `R/Q1.R`, `R/Q2.R`, and `R/Q3.R` so `report/tables/*.csv` and `report/figures/*.png` exist):

- **Option A — In Antigravity / VS Code (automatic on save)**:
  1. Completely quit (`Cmd+Q`) and reopen Antigravity / VS Code once after installing BasicTeX packages.
  2. Open `report/sections/q2.tex` (or `report/ociamthesismain.tex`) and press **`Cmd+S`** (Save).
  3. It automatically builds `report/_build/ociamthesismain.pdf`.
  *(Tip from Xiang in WhatsApp: If the PDF does not compile, delete the `report/_build/` folder and save again to rebuild).*

- **Option B — From the Terminal** (inside `SMDE-Labs/`):
  ```sh
  export PATH="/Library/TeX/texbin:$PATH"
  cd report
  latexmk -pdf -outdir=_build ociamthesismain.tex
  ```
  Your compiled PDF will be saved at `report/_build/ociamthesismain.pdf`.

---

## 4. How to Inspect the Changes Made in This Folder (`git diff`)

Inside `my-part-of-homework/SMDE-Labs/`:
1. The clean original repository from your teammates was committed first as a baseline.
2. Only two tracked files were modified for your Question 2 part and **left uncommitted** so you can inspect them directly in VS Code's **Source Control** tab or by running `git diff`:
   - `report/sections/q2.tex` (your complete Question 2 report section)
   - `report/sections/appendix.tex` (added `\subsection{Question 2}` tables and figures so all `\autoref{...}` links in `q2.tex` work)
3. The generated Q2 outputs (`R/logs/Q2.log`, `report/tables/q2*.csv`, `report/figures/q2*.png`) are also already generated inside `my-part-of-homework/SMDE-Labs/` so you can open and view every table and plot right away!

---

## 5. How to Deliver Your Work to Your Teammates' GitHub Repo

When you are ready to push your Question 2 report to your teammates' actual `SMDE-Labs` GitHub repository:

1. Copy the two updated files into your cloned `SMDE-Labs` GitHub repository:
   - `report/sections/q2.tex`
   - `report/sections/appendix.tex`
2. Inside your cloned `SMDE-Labs` GitHub repo, check `git status` to make sure only `report/sections/q2.tex` and `report/sections/appendix.tex` are staged (remember that `R/logs/`, `report/tables/`, and `report/figures/` are git-ignored).
   *(If any generated files were accidentally tracked earlier, Xiang shared this cleanup command in WhatsApp)*:
   ```sh
   git rm -r --cached -- Results/ bodyPerformance_clean.csv R/logs/ report/figures/ report/tables/ report-deprecated/figures/ report-deprecated/tables/
   ```
3. Commit and push to your teammates' repo:
   ```sh
   git add report/sections/q2.tex report/sections/appendix.tex
   git commit -m "Write Question 2 ANOVA report section and add Q2 appendix tables/figures"
   git push
   ```
