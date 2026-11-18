// ============================================================
// Reusable macros
// ============================================================
#import "settings.typ": *

// ------------------------------------------------------------
// Page layout
// ------------------------------------------------------------
#let setup-page(title, names, course) = (
  header: [
    #set text(size: 11pt)

    #grid(
      columns: (1fr, 1fr),

      align(left)[
        #text(
          fill: upc-blue,
          weight: "bold",
        )[#title]
      ],

      align(right)[
        #text(fill: text-gray)[#course]
      ],
    )

    #v(5pt)

    #line(
      length: 100%,
      stroke: 1.5pt + upc-red,
    )
  ],

  footer: [
    #set text(size: 10pt)

    #grid(
      columns: (1fr, 1fr),

      align(left)[
        #text(fill: text-gray)[#names]
      ],

      align(right)[
        #text(fill: page-gray)[
          #context {
            counter(page).display()
          }
        ]
      ],
    )
  ],
)


// ------------------------------------------------------------
// Title page (no header/footer, not counted in page numbering)
// ------------------------------------------------------------
#let title-page(
  title,
  subtitle: none,
  course: none,
  authors: (),
  date: datetime.today().display("[month repr:long] [year]"),
) = page(
  header: none,
  footer: none,
  margin: (top: 2cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm),
)[
  #set par(justify: false)
  #set align(center)

  // University / faculty logos on one row
  #grid(
    columns: (auto, auto),
    column-gutter: 0.5cm,
    align: horizon,
    image("images/logo-upc.png", height: 2cm),
    image("images/logo-fib.png", height: 2cm),
  )

  #v(1fr)

  #text(size: 34pt, weight: "bold", fill: upc-blue)[#title]
  #if subtitle != none [
    #v(0.4em)
    #text(size: 20pt, fill: text-gray)[#subtitle]
  ]

  #if course != none [
    #v(1.2em)
    #text(size: 18pt, fill: upc-blue)[#course]
  ]

  #v(1fr)

  #text(size: 10pt, weight: "bold", fill: text-gray)[AUTHORS]
  #v(0.3em)
  #for a in authors [
    #text(size: 12pt)[#a] \
  ]

  #v(1.5cm)

  #text(size: 11pt, fill: page-gray)[#date]
]

// ------------------------------------------------------------
// Table of contents
// ------------------------------------------------------------
#let table-of-contents(depth: 2) = {
  show heading: it => text(24pt)[#it #v(1em)]
  show outline.entry: it => link(
    it.element.location(),
    if it.level == 1 { strong } else { x => x }(
      it.indented(it.prefix(), it.inner()),
    ),
  )
  outline()
  
  pagebreak()
}

// ------------------------------------------------------------
// Comments
// ------------------------------------------------------------


#let xfcomment(content) = if show-todo {
  text(
    fill: xf-color,
    font: "DejaVu Sans Mono",
    size: 9pt,
  )[XF: #content]
}

#let sscomment(content) = if show-todo {
  text(
    fill: ss-color,
    font: "DejaVu Sans Mono",
    size: 9pt,
  )[SS: #content]
}

#let aoccomment(content) = if show-todo {
  text(
    fill: aoc-color,
    font: "DejaVu Sans Mono",
    size: 9pt,
  )[AOC: #content]
}


// ------------------------------------------------------------
// Question text under a subsection
// ------------------------------------------------------------
#let task(body) = block(
  above: 0.4em,
  below: 1em,
  text(size: 9.5pt, style: "italic", fill: text-gray, body),
)

// ------------------------------------------------------------
// Table from a CSV file written by the R scripts (report/tables/<name>.csv)
// ------------------------------------------------------------
#let csv-table(
  name,
  caption: none,
  label: none,
  columns: auto,
  size: 9pt,
) = {
  let rows = csv("tables/" + name + ".csv")
  let head = rows.first()
  let data = rows.slice(1)
  let n = head.len()

  let is-number(s) = s.match(regex("^[<>]?\\s*-?[0-9.]+(e[-+]?[0-9]+)?$")) != none
  let aligns = range(n).map(i => {
    if data.all(r => r.at(i) == "" or is-number(r.at(i))) { right } else { left }
  })

  let tab = {
    set text(size: size)
    table(
      columns: if columns == auto { n } else { columns },
      align: (x, y) => aligns.at(x) + horizon,
      stroke: none,
      inset: (x: 6pt, y: 4pt),
      fill: (x, y) => if y > 0 and calc.even(y) { code-bg },
      table.hline(stroke: 1pt + upc-blue),
      table.header(..head.map(h => strong(h.replace("_", " ")))),
      table.hline(stroke: 0.5pt + upc-blue),
      ..data.flatten(),
      table.hline(stroke: 1pt + upc-blue),
    )
  }

  let fig = figure(tab, kind: table, caption: caption)
  if label != none [#fig#label] else { fig }
}
