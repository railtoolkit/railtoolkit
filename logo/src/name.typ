// Copyright 2026 Martin Scheidt (ORCID: 0000-0002-9384-8945) Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
// This license enables reusers to copy and distribute the material in any medium or format in unadapted form only, for noncommercial purposes only, and only if attribution is given to the creator.

#let blueprint-bg = rgb("#003b71")
#let blueprint-ink = rgb("#e8f4ff")

#set page(
  width: auto,
  height: auto,
  fill: blueprint-bg,
  margin: 2mm,
)
#import "@preview/cetz:0.5.2"

#let construction-style = (stroke: blueprint-ink + 0.1pt, dash: "densely-dashed")
#let dim-style = (stroke: blueprint-ink + 0.15pt)
#let dim-text(body) = text(size: 2pt, fill: blueprint-ink)[#body]
#let dim-length-cm(length) = dim-text[#calc.round(length / 1cm, digits: 2) cm]
#let dim-arrows = (
  start: (symbol: ">", scale: 0.2, fill: blueprint-ink, shorten-to: none),
  end: (symbol: ">", scale: 0.2, fill: blueprint-ink, shorten-to: none),
)
#let dim-arrow-end = (
  end: (symbol: ">", scale: 0.2, fill: blueprint-ink, shorten-to: none),
)

#let logo-font = "Nexa" // Nexa Bold.otf — requires `typst compile --font-path font …`

// Wordmark metrics from logo.ai (Nexa Bold), as fractions of the symbol height.
#let wordmark-spec = (
  font-size: 200.156 / 229.745,
  gap: 45.508 / 229.745,
  center-dy: (762.85 - 800.0) / 229.745,
)

#let register-point(pos, tag) = {
  import cetz.draw: anchor, circle, group, hide
  hide(group(name: str(tag), {
    circle(pos, radius: 0.01mm, stroke: none, fill: none, name: "mark")
    anchor("default", "mark")
  }))
}

#let show-point-label(at, tag, radius: 0.15mm) = {
  import cetz.draw: circle, content
  circle(at, radius: radius, ..dim-style, fill: blueprint-bg)
  content(
    at,
    text(size: 1.25pt, fill: blueprint-ink)[#tag],
    angle: 45deg,
    anchor: "west",
    padding: 1pt,
  )
}

/// Split a CamelCase wordmark at the first lowercase→uppercase boundary.
#let split-wordmark(text) = {
  let match = text.match(regex("^([[:alpha:]]+?)([[:upper:]][[:alpha:]]*)$"))
  if match != none {
    (match.captures.at(0), match.captures.at(1))
  } else {
    (text, "")
  }
}

#let name(
  bounds,
  show-shape: true,
  show-construction: false,
  show-points: false,
  show-dimensions: false,
  wordmark: "RailToolKit",
  fill-a: black,
  fill-b: black,
  wordmark-font: logo-font,
  canvas: true,
) = {
  let draw = {
    import cetz.draw: content, line, on-layer, set-style

    let (part1, part2) = split-wordmark(wordmark)
    let font-size = bounds.height * wordmark-spec.font-size
    let gap = bounds.height * wordmark-spec.gap
    let center-y = (bounds.top + bounds.bottom) / 2 + bounds.height * wordmark-spec.center-dy
    let position = (bounds.right + gap, center-y)

    // -- layer 0: hidden geometry
    on-layer(0, {
      register-point((bounds.right, center-y), "symbol-right")
      register-point(position, "wordmark-west")
      register-point((bounds.right, bounds.top), "symbol-top")
      register-point((bounds.right, bounds.bottom), "symbol-bottom")
    })

    // -- layer 1: numbered points
    if show-points {
      on-layer(1, {
        show-point-label("symbol-right", "1")
        show-point-label("wordmark-west", "2")
        show-point-label("symbol-top", "3")
        show-point-label("symbol-bottom", "4")
      })
    }

    // -- layer 2: construction lines
    if show-construction {
      on-layer(2, {
        line(
          (bounds.right, bounds.top),
          (bounds.right, bounds.bottom),
          ..construction-style,
          name: "symbol-height",
        )
        line(
          "symbol-right",
          "wordmark-west",
          ..construction-style,
          name: "wordmark-gap",
        )
        line(
          (bounds.right, center-y),
          (bounds.right + gap + 3cm, center-y),
          ..construction-style,
          name: "wordmark-baseline",
        )
      })
    }

    // -- layer 3: dimensions
    if show-dimensions {
      on-layer(3, {
        set-style(stroke: dim-style.stroke)

        line(
          (bounds.right + 2mm, bounds.top),
          (bounds.right + 2mm, bounds.bottom),
          mark: dim-arrows,
          name: "symbol-height-dim",
        )
        content(
          "symbol-height-dim.mid",
          dim-length-cm(bounds.height),
          anchor: "west",
          padding: 2pt,
        )

        line(
          "symbol-right",
          "wordmark-west",
          mark: dim-arrows,
          name: "wordmark-gap-dim",
        )
        content(
          "wordmark-gap-dim.mid",
          dim-length-cm(gap),
          anchor: "south",
          padding: 1pt,
        )

        line(
          (position.at(0) + 2mm, center-y - font-size / 2),
          (position.at(0) + 2mm, center-y + font-size / 2),
          mark: dim-arrows,
          name: "wordmark-size-dim",
        )
        content(
          "wordmark-size-dim.mid",
          dim-length-cm(font-size),
          anchor: "west",
          padding: 2pt,
        )
      })
    }

    // -- layer 4: wordmark
    if show-shape {
      on-layer(4, {
        content(
          position,
          box(width: auto)[
            #set text(font: wordmark-font, size: font-size, weight: "bold", hyphenate: false)
            #text(fill: fill-a)[#part1]#text(fill: fill-b)[#part2]
          ],
          anchor: "west",
          name: "wordmark",
        )
      })
    }
  }
  if canvas {
    cetz.canvas(draw)
  } else {
    draw
  }
}

#import "feathered-wheel.typ": symbol-bounds

#name(
  symbol-bounds(),
  show-shape: true,
  show-dimensions: true,
  show-construction: true,
  show-points: true,
  fill-a: blueprint-ink,
  fill-b: blueprint-ink.lighten(30%),
)
