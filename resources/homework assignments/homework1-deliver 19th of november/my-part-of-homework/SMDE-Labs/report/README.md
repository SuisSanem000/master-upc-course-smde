# LaTeX report: writing rules

LaTeX version of the SMDE first assignment report. It is based on the
(unofficial) [UPC thesis template](https://github.com/sabirdvd/LaTeX-template-for-UPC-thesis-);
the template files that the report does not use are hidden in VS Code.

## Files

| File | Content |
|---|---|
| `ociamthesismain.tex` | Main file: packages, title page fields, contents, sections, appendix, references |
| `ociamthesis.cls` | Document class: page layout and title page |
| `macros.tex` | Colours and macros (`\task`, `\csvtable`, comments) |
| `sections/q1.tex`, `q2.tex`, `q3.tex` | One file per question |
| `sections/appendix.tex` | A Tables, B Figures, C R Code and Outputs |
| `refs.bib` | References |
| `tables/`, `figures/` | Written by the R scripts in `../R/` (do not edit by hand) |

Build with LaTeX Workshop in VS Code (output in `_build/`) or
`latexmk -pdf -outdir=_build ociamthesismain.tex`.

## Structure

- One `\section{}` per question and one `\subsection{}` per part (a, b, ...).
- Each subsection starts with the statement of the part, copied verbatim:
  `\task{...}`.
- Tables and figures go in the appendix; the text cites them. May move to the text if needed.
- The body (from Section 1 to the end of the last question) must fit in
  **12 pages**; the contents, appendix and references do not count.

## Writing

- **One sentence per line** in the `.tex` files (a line break after `.`, `?`
  or `!`). LaTeX joins the lines of a paragraph; an empty line starts a new
  paragraph.
- **Variables**: always use their R names in monospace, with the `_` escaped:
  `\texttt{height\_cm}`, `\texttt{sit\_bend\_cm}`, `\texttt{age\_cat}`.
  Do not use everyday terms ("blood pressure", "flexibility"): we do not know
  how the data were collected. If a measure needs an explanation, add it once
  as a footnote: `\footnote{...}`.
- **Numbers**: every number in the text must come from a table, a figure or an
  R log (`R/logs/*.log`). Write conclusions, not the numbers already shown in a
  table. A derived value is shown as an equation, e.g.
  `$\mathrm{CV} = \mathrm{SD}/\bar{x} = 8.46/15.21 \approx 0.56$`.
- **Units and ranges**: a thin space between a number and its unit
  (`67.5\,kg`), `--` for ranges (`18--24\%`), math mode for negative numbers (`$-25$`), and `\%` for percentages.

## Tables and figures

- Table from a CSV written by R:
  `\csvtable[\footnotesize]{q1b_summary}{Caption.}{tab:q1b-summary}`
  (the optional font size is `\small` by default).
- Figure:

  ```latex
  \begin{figure}[htbp]
    \centering
    \includegraphics[width=\linewidth]{q1b_histograms}
    \caption{Histograms of the numerical variables.}
    \label{fig:q1b-histograms}
  \end{figure}
  ```

## Spelling and grammar (LTeX+)

The [LTeX+](https://marketplace.visualstudio.com/items?itemName=ltex-plus.vscode-ltex-plus)
extension checks the spelling and grammar of the `.tex` and `.md` files while
writing. Its rules are in `.vscode/settings.json`:

- **American English** (`en-US`). Proper names keep their own
  spelling (*Statistical Modelling and Design of Experiments*).
- R variable names in `\texttt{}` are not spell-checked.
- A word that is correct but unknown (a name, an acronym, a technical term):
  use the quick fix **Add to dictionary**. It is saved in
  `.vscode/settings.json` (`ltex.dictionary`), so it is shared with the team.
- Do not disable a rule for a single false alarm: use the quick fix
  **Hide false positive** instead.

## Comments

- `\xfcomment{...}`, `\sscomment{...}`, `\aoccomment{...}`: one per author.
- Start them with `TODO:` for work still to do and `Extension:` for possible
  additions that are not done.
- Hide all comments in the final version with `\showtodofalse` in `macros.tex`.
