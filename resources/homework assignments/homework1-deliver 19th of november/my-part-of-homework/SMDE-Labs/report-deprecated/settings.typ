// ============================================================
// Document settings
// ============================================================

// ---------- Colors ----------
#let upc-blue = rgb("#003B5C")
#let upc-red = rgb("#E30613")
#let text-gray = rgb("#555555")
#let page-gray = rgb("#777777")
#let code-bg = rgb("#F5F6F7")

#let xf-color = rgb("#0066CC")
#let ss-color = rgb("#008000")
#let aoc-color = rgb("#8A2BE2")

// ---------- Constants ----------
#let show-todo = true

// ---------- Report style ----------
#let report-style(body) = {
  // page
  set page(
    paper: "a4",
    margin: (
      top: 2.2cm,
      bottom: 2cm,
      left: 2.5cm,
      right: 2.5cm,
    ),
  )

  // main text
  set text(size: 11pt)

  // paragraphs
  set par(
    justify: true,
    leading: 0.65em,
  )

  // numbered lists
  set enum(
    indent: 1.5em,
    body-indent: 0.6em,
    spacing: 1em,
    numbering: (..n) => strong(numbering("1.", ..n)),
  )

  // headings: numbered sections (1) and subsections (1.1)
  set heading(numbering: "1.1")
  show heading: set text(fill: upc-blue)
  show heading.where(level: 1): set block(above: 1.8em, below: 1em)
  show heading.where(level: 2): set block(above: 1.5em, below: 0.6em)

  // captions: tables above the table, figures below the figure
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.caption: set text(size: 9.5pt)

  body
}

#let appendix(body) = {
  // Start appendices on a new page, with letter numbering from A
  pagebreak(weak: true)
  counter(heading).update(0)
  set heading(numbering: "A.1", supplement: [Appendix])

  // Show level-1 headings as "Appendix A: Title"
  show heading.where(level: 1): it => {
    // Restart equation numbering in each appendix
    counter(math.equation).update(0)
    block(below: 1em)[
      #it.supplement #counter(heading).display("A"): #it.body
    ]
  }

  // Number equations per appendix: (A.1), (A.2), ...
  set math.equation(numbering: (..n) => {
    let h = counter(heading).get().first()
    numbering("(A.1)", h, ..n)
  })

  body
}
