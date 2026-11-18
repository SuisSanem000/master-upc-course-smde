# SMDE Labs

Labs and assignments for **Statistical Modelling and Design of Experiments (SMDE)**
at UPC, written in **R**, with the report in **LaTeX**.

The current work is the **First Assignment**: Question 1 (visualisation,
chi-square and t-test) and Question 2 (ANOVA), on the `bodyPerformance.csv`
data set.

## Data set

`bodyPerformance.csv` has **13,393 rows** and **12 columns**, with no missing values.

| Column in the CSV | Name in R | Type in R | Description |
|---|---|---|---|
| `age` | `age` | numeric | Age in years (21 to 64) |
| `gender` | `gender` | factor: `Female`, `Male` | Gender (`F` / `M` in the file) |
| `height_cm` | `height_cm` | numeric | Height (cm) |
| `weight_kg` | `weight_kg` | numeric | Weight (kg) |
| `body fat_%` | `body_fat_pct` | numeric | Body fat (%) |
| `diastolic` | `diastolic` | numeric | Diastolic blood pressure (bottom number) |
| `systolic` | `systolic` | numeric | Systolic blood pressure (top number) |
| `gripForce` | `grip_force` | numeric | Grip strength force (kg) |
| `sit and bend forward_cm` | `sit_bend_cm` | numeric | Sit and bend forward (cm) |
| `sit-ups counts` | `sit_ups` | numeric | Number of sit-ups in a set time |
| `broad jump_cm` | `broad_jump_cm` | numeric | Broad jump distance (cm) |
| `class` | `class` | ordered factor: `D < C < B < A` | Overall performance: A = excellent, B = good, C = fair, D = poor |

## Setup

**Install R** (4.x) and the recommended VS Code extensions.

   The extensions this project uses are listed in `.vscode/extensions.json`.
   To install them:

   - **From VS Code**: open the repository folder, accept the
     *"Do you want to install the recommended extensions?"* notification, or open
     the Extensions view (`Ctrl+Shift+X`), type `@recommended` and click
     *Install* on each one.
   - **From a terminal** (installs every extension listed in the file):

     ```sh
     python -c "import json; print('\n'.join(json.load(open('.vscode/extensions.json'))['recommendations']))" | xargs -n 1 code --install-extension
     ```

   The R extension needs these R packages (install them once, from an R console):

   ```r
   install.packages(c("languageserver", "jsonlite", "rlang"))
   ```

   The analyses (and the [statistics guides](docs/README.md)) also use these packages:

   ```r
   install.packages(c("lmtest", "car"))
   ```

## Technical details

### R scripts: one per question

| Script | Question |
|---|---|
| `R/Q1.R` | Question 1: visualisation, chi-square and t-test |
| `R/Q2.R` | Question 2: ANOVA |
| `R/Q3.R` | Question 3 |

Run a script from the repository root (or from `R/`: it moves to the parent
folder by itself). All paths are relative to the repository root, so no setup
is needed:

```sh
Rscript R/Q1.R
```

Each script starts with the same setup block, which defines:

| Helper | Use |
|---|---|
| `section("a) Title")` | Prints a section title in the log, one per sub-question |
| `save_table(df, "q1b_summary")` | Saves a data frame as `q1b_summary.csv` in `tab_dir` and prints it in the log |
| `save_figure("q1b_name", function() { ... })` | Draws the plotting code into `q1b_name.png` in `fig_dir` (optional `width`, `height`, `res`) |
| `tab_dir`, `fig_dir` | Output folders of the report: `report/tables` and `report/figures` |

Name tables and charts `q<question><part>_<name>` (e.g. `q2b_tukey`), so each
file shows where it comes from.

### Generated files (do not edit by hand)

These folders are written by the R scripts, overwritten on every run and
git-ignored, so run the scripts before compiling the report:

| Folder | Content | Written by |
|---|---|---|
| `R/logs/` | `Q1.log`, `Q2.log`, ...: the full console output of each script | `sink()` in the setup block |
| `report/tables/` | `q*.csv`: result tables shown in the report | `save_table()` |
| `report/figures/` | `q*.png`: charts shown in the report | `save_figure()` |

To update the report after changing a script, run the script again and then
compile the report.

### Report (Typst, deprecated)
> [!WARNING]
> **DEPRECATED:** This report in Typst is deprecated and may be removed. The R
> scripts no longer write its `tables/` and `figures/`, so it only compiles if
> they are copied from `report/`.

The Typst report is in `report-deprecated/`. Compile it, or preview it in VS Code with Tinymist:

```sh
typst compile report-deprecated/main.typ
```

| File | Content |
|---|---|
| `main.typ` | The report: title page, contents, one section per question (`=`), one subsection per part (`==`), appendix |
| `settings.typ` | Colours, `show-todo`, the document style (`report-style`) and the `appendix` layout |
| `macros.typ` | Reusable functions (below) |
| `images/` | Logos of the title page |

Macros in `macros.typ`:

| Macro | Use |
|---|---|
| `#title-page(...)` | Title page with logos, title, course, authors and date |
| `#table-of-contents()` | Table of contents on its own page |
| `#setup-page(...)` | Header and footer of the pages (`#set page(..setup-page(...))`) |
| `#task[...]` | Question statement in grey italics under a subsection title |
| `#csv-table("name", caption: [...], label: <...>)` | Table from `tables/name.csv`: header from the first row, numbers right-aligned, numbered "Table N" caption |
| `#xfcomment[...]`, `#sscomment[...]`, `#aoccomment[...]` | Author comments (see below) |

Charts use Typst's built-in `figure` with an image from `figures/`.
Example of a subsection with a table and a chart, referenced from the text:

```typst
== Descriptive Statistics <q1b>

#task[Summarize the numerical variables and analyze their distributions.]

The summary statistics are in @tab-q1b-summary and the histograms in @fig-q1b-histograms.

#csv-table(
  "q1b_summary",
  caption: [Summary statistics of the numerical variables.],
  label: <tab-q1b-summary>,
)

#figure(
  image("figures/q1b_histograms.png", width: 100%),
  caption: [Histograms of the numerical variables.],
) <fig-q1b-histograms>
```

Tables and charts are in the appendix for now (`= Tables`, `= Figures` after
`#show: appendix`), but can be moved into the body. The body is numbered from
page 1, so its last page number is the page count (limit: 12 pages without the
appendix).

### Report (LaTeX)

Spelling and grammar are checked with the LTeX+ extension (American English, rules in `.vscode/settings.json`).

Writing rules of the report (variables, numbers, references, comments):
[`report/README.md`](report/README.md).

The report is in `report/`. It is based on the (unofficial) UPC thesis
template; the template files it does not use are hidden in VS Code
(`.vscode/settings.json`).

Compile it with LaTeX Workshop in VS Code (it builds into
`report/_build/`, which is git-ignored), or from the command line:

```sh
cd report
latexmk -pdf -outdir=_build ociamthesismain.tex
```

| File | Content |
|---|---|
| `ociamthesismain.tex` | Main file: packages, title page fields, contents, `\input` of each section, appendix |
| `ociamthesis.cls` | Document class: page layout and the title page (`\maketitle`) |
| `macros.tex` | Colours and macros (below) |
| `sections/q1.tex`, `q2.tex`, `q3.tex` | One `\section` per question, one `\subsection` per part |
| `sections/appendix.tex` | Appendix A Tables and B Figures |
| `tables/`, `figures/` | Written by the R scripts |
| `images/` | Logo banner of the title page |

The title page is set in the preamble of `ociamthesismain.tex` with `\title`,
`\author`, `\course`, `\degree`, `\doctype`, `\faculty`, `\university` and
`\titlelogo`.

| Macro | Typst equivalent | Use |
|---|---|---|
| `\task{...}` | `#task[...]` | Question statement in grey italics under a subsection title |
| `\csvtable{name}{caption}{label}` | `#csv-table(...)` | Table from `tables/name.csv` (booktabs rules, numbers right-aligned, "Table N" caption above) |
| `\xfcomment{...}`, `\sscomment{...}`, `\aoccomment{...}` | `#xfcomment[...]`, ... | Author comments; hide them all with `\showtodofalse` in `macros.tex` |

Example of a subsection with a table and a chart:

```latex
\subsection{Descriptive Statistics}\label{sec:q1b}

\task{Summarize the numerical variables and analyze their distributions.}

The summary statistics are in \autoref{tab:q1b-summary} and the histograms in
\autoref{fig:q1b-histograms}.

\csvtable{q1b_summary}{Summary statistics of the numerical variables.}{tab:q1b-summary}

\begin{figure}[htbp]
  \centering
  \includegraphics[width=\linewidth]{q1b_histograms}
  \caption{Histograms of the numerical variables.}
  \label{fig:q1b-histograms}
\end{figure}
```

The contents page is numbered in roman numerals and the body from page 1, so
the page number of the last body page is the page count (limit: 12 pages
without the appendix).

### Comments in the report

Each author has a comment command, shown in their colour with their initials:

```latex
\xfcomment{Check this value against the R output.}    % XF (blue)
\sscomment{Add the interpretation of the p-value.}    % SS (green)
\aoccomment{Move this table into the body?}            % AOC (purple)
```

Comments can contain references and formatting (`\xfcomment{See \autoref{tab:q1b-summary}.}`).
To hide **all** comments in the final version, use `\showtodofalse` in `report/macros.tex`.

## Statistics guides

R guides written from the course slides, in [`docs/`](docs/README.md). Each one
gives the R code, the hypotheses, how to check the assumptions and the lecture
example reproduced in R:

- [Probability distributions](docs/probability-distributions.md)
- [Hypothesis testing and t-tests](docs/hypothesis-testing.md)
- [ANOVA](docs/anova.md)
- [Simple linear regression](docs/simple-linear-regression.md)
- [Multiple linear regression](docs/multiple-linear-regression.md)
