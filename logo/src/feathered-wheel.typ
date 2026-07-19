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

#let construction-style = (stroke: blueprint-ink + 0.1pt, dash: "dashed")
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

/// Bounding box of the feathered-wheel symbol in canvas coordinates.
#let symbol-bounds(
  origin: (0cm, 0cm),
  wheel-inner-radius: 1cm,
  ring-thickness: 0.4cm,
  wheel-cut-angle: 42deg,
) = {
  let wheel-outer-radius = wheel-inner-radius + ring-thickness
  let top = origin.at(1) + wheel-outer-radius
  let bottom = origin.at(1) + wheel-inner-radius * calc.sin(-90deg - wheel-cut-angle)
  let right = origin.at(0) + wheel-outer-radius
  (top: top, bottom: bottom, right: right, height: top - bottom)
}

#let feathered-wheel(
  show-shape: true,
  show-construction: false,
  show-points: false,
  show-dimensions: false,
  fill-a: black,
  fill-b: black,
  origin: (0cm, 0cm),
  wheel-inner-radius: 1cm,
  ring-thickness: 0.4cm,
  wheel-cut-angle: 42deg,
  feather-arm-length: 2.5cm,
  canvas: true,
) = {
  let draw = {
  import cetz.draw: arc, arc-through, circle, content, hide, intersections, line, merge-path, on-layer, set-style

  // -- parameters  

  let wheel-outer-radius = wheel-inner-radius + ring-thickness
  let ring-cut-y = wheel-inner-radius * calc.sin(-90deg - wheel-cut-angle)
  let feather-spacing-height = (wheel-inner-radius - ring-cut-y - 2 * ring-thickness) / 3

  let feather-divider-y-1 = ring-cut-y + feather-spacing-height
  let feather-divider-y-2 = feather-divider-y-1 + ring-thickness
  let feather-divider-y-3 = feather-divider-y-2 + feather-spacing-height
  let feather-divider-y-4 = feather-divider-y-3 + ring-thickness

  if feather-spacing-height <= 0pt {
    block(fill: red.lighten(85%), inset: 4pt, radius: 2pt)[
      *Warning:* Segment height 1/3/5 is #feather-spacing-height — ring-thickness is too large for the available vertical span.
    ]
  }

  // -- layer 0: hidden geometry (anchors for later layers)

  // Point index:
  //   origin — wheel center
  //   1–2    wheel apexes (inner / outer)
  //   3–4    ring cut (inner / outer)
  //   5–8    inner-arc dividers, bottom → top
  //   9–11   upper feather (inner arm / outer arm + tip center / tip left)
  //   12–14  middle feather (arm / tip center / tip bottom)
  //   15–18  lower feather (outer attach / tip center / tip left / tip bottom)
  // 
  on-layer(0, {
    hide({
      circle(origin, radius: wheel-inner-radius, name: "wheel-inner-edge")
      circle(origin, radius: wheel-outer-radius, name: "wheel-outer-edge")
    })

    register-point(origin, "origin")
    register-point((0cm, wheel-inner-radius), "1")
    register-point((0cm, wheel-outer-radius), "2")
    register-point((-90deg - wheel-cut-angle, wheel-inner-radius), "3")

    hide(line(
      "3",
      (rel: (-ring-thickness * 3, 0), to: "3"),
      name: "ring-cut-ray",
    ))
    intersections("ring-cut", "ring-cut-ray", "wheel-outer-edge")
    register-point("ring-cut.0", "4")

    hide(line(
      "1",
      (rel: (-feather-arm-length, 0), to: "1"),
      name: "upper-feather-inner",
    ))
    hide(line(
      "2",
      (rel: (-feather-arm-length, 0), to: "2"),
      name: "upper-feather-outer",
    ))
    register-point("upper-feather-inner.end", "9")
    register-point("upper-feather-outer.end", "10")

    hide(circle("10", radius: ring-thickness, name: "upper-feather-tip"))
    hide(line(
      "10",
      (rel: (-ring-thickness, 0), to: "10"),
      name: "upper-feather-outer-tip",
    ))
    register-point("upper-feather-outer-tip.end", "11")

    hide(line(
      (0cm, feather-divider-y-1),
      (rel: (-wheel-inner-radius * 2, 0), to: (0cm, feather-divider-y-1)),
      name: "feather-divider-ray-1",
    ))
    intersections("feather-divider-1-hit", "feather-divider-ray-1", "wheel-inner-edge")
    register-point("feather-divider-1-hit.0", "5")

    hide(line(
      (0cm, feather-divider-y-2),
      (rel: (-wheel-outer-radius * 2, 0), to: (0cm, feather-divider-y-2)),
      name: "feather-divider-ray-2",
    ))
    intersections("feather-divider-2-hit", "feather-divider-ray-2", "wheel-inner-edge")
    intersections("lower-feather-15", "feather-divider-ray-2", "wheel-outer-edge")
    register-point("feather-divider-2-hit.0", "6")
    register-point("lower-feather-15.0", "15")

    hide(circle(
      (rel: (-ring-thickness, 0), to: "15"),
      radius: ring-thickness,
      name: "lower-feather-tip",
    ))
    register-point((rel: (-ring-thickness, 0), to: "15"), "16")
    hide(line(
      (rel: (-ring-thickness, 0), to: "15"),
      (rel: (-ring-thickness * 2, 0), to: "15"),
      name: "lower-feather-tip-edge",
    ))
    register-point("lower-feather-tip-edge.end", "17")
    register-point((rel: (0, -ring-thickness), to: "16"), "18")

    hide(line(
      (0cm, feather-divider-y-3),
      (rel: (-wheel-inner-radius * 2, 0), to: (0cm, feather-divider-y-3)),
      name: "feather-divider-ray-3",
    ))
    intersections("feather-divider-3-hit", "feather-divider-ray-3", "wheel-inner-edge")
    register-point("feather-divider-3-hit.0", "7")

    hide(line(
      (0cm, feather-divider-y-4),
      (rel: (-wheel-inner-radius * 2, 0), to: (0cm, feather-divider-y-4)),
      name: "feather-divider-ray-4",
    ))
    intersections("feather-divider-4-hit", "feather-divider-ray-4", "wheel-inner-edge")
    hide(line(
      (0cm, feather-divider-y-4),
      (rel: (-feather-arm-length, 0), to: (0cm, feather-divider-y-4)),
      name: "middle-feather-divider-4",
    ))
    register-point("feather-divider-4-hit.0", "8")
    register-point("middle-feather-divider-4.end", "12")

    hide(circle(
      (rel: (ring-thickness, 0), to: "middle-feather-divider-4.end"),
      radius: ring-thickness,
      name: "middle-feather-tip",
    ))
    register-point((rel: (ring-thickness, 0), to: "middle-feather-divider-4.end"), "13")
    register-point((rel: (0, -ring-thickness), to: "13"), "14")
  })

  // -- layer 1: numbered points
  if show-points {
    on-layer(1, {
      show-point-label(origin, "origin")
      show-point-label("1", "1")
      show-point-label("2", "2")
      show-point-label("3", "3")
      show-point-label("4", "4")
      show-point-label("5", "5")
      show-point-label("6", "6")
      show-point-label("7", "7")
      show-point-label("8", "8")
      show-point-label("9", "9")
      show-point-label("10", "10")
      show-point-label("11", "11")
      show-point-label("12", "12")
      show-point-label("13", "13")
      show-point-label("14", "14")
      show-point-label("15", "15")
      show-point-label("16", "16")
      show-point-label("17", "17")
      show-point-label("18", "18")
    })
  }

  // -- layer 2: construction lines
  if show-construction {
    on-layer(2, {
    circle(
      origin,
      radius: wheel-inner-radius,
      ..construction-style,
    )
    circle(
      origin,
      radius: wheel-outer-radius,
      ..construction-style,
    )

    line("3", "4", ..construction-style, name: "ring-cut")

    line("1", "9", ..construction-style, name: "upper-feather-inner")
    line("2", "10", ..construction-style, name: "upper-feather-outer")
    circle("10", radius: ring-thickness, ..construction-style, name: "upper-feather-tip")
    line("10", "11", ..construction-style, name: "upper-feather-outer-tip")

    line(
      (0cm, feather-divider-y-1),
      (rel: (-feather-arm-length, 0), to: (0cm, feather-divider-y-1)),
      ..construction-style,
      name: "lower-feather-divider-1",
    )
    line(
      (0cm, feather-divider-y-2),
      (rel: (-feather-arm-length, 0), to: (0cm, feather-divider-y-2)),
      ..construction-style,
      name: "lower-feather-divider-2",
    )
    circle(
      (rel: (-ring-thickness, 0), to: "15"),
      radius: ring-thickness,
      ..construction-style,
      name: "lower-feather-tip",
    )
    line(
      (rel: (-ring-thickness, 0), to: "15"),
      "17",
      ..construction-style,
      name: "lower-feather-tip-edge",
    )

    line(
      (0cm, feather-divider-y-3),
      (rel: (-feather-arm-length, 0), to: (0cm, feather-divider-y-3)),
      ..construction-style,
      name: "middle-feather-divider-3",
    )
    line(
      (0cm, feather-divider-y-4),
      (rel: (-feather-arm-length, 0), to: (0cm, feather-divider-y-4)),
      ..construction-style,
      name: "middle-feather-divider-4",
    )
    circle(
      (rel: (ring-thickness, 0), to: "12"),
      radius: ring-thickness,
      ..construction-style,
      name: "middle-feather-tip",
    )
    line("12", "13", ..construction-style, name: "middle-feather-tip-edge")

    line(
      "10",
      ("10", "|-", "12"),
      ..construction-style,
      name: "feather-10-12-dim",
    )
    })
  }

  // -- layer 3: dimensions
  if show-dimensions {
    on-layer(3, {
      set-style(stroke: dim-style.stroke)

      line(
        (-60deg, 50% * wheel-inner-radius),
        (-60deg, wheel-inner-radius),
        mark: dim-arrow-end,
        name: "wheel-inner-dim",
      )
      content(
        "wheel-inner-dim.mid",
        angle: "wheel-inner-dim.end",
        dim-text[R = #calc.round(wheel-inner-radius / 1cm, digits: 2) cm],
        anchor: "south",
        padding: 1pt,
      )

      line(
        (-60deg, wheel-inner-radius),
        (-60deg, wheel-outer-radius),
        mark: dim-arrows,
        name: "wheel-ring-thickness-dim",
      )
      content(
        "wheel-ring-thickness-dim.mid",
        angle: "wheel-ring-thickness-dim.end",
        dim-text[T = #calc.round(ring-thickness / 1cm, digits: 2) cm],
        anchor: "south",
        padding: 1pt,
      )

      line(origin, "3", name: "origin-3-dim")
      arc(
        (0cm, -25% * wheel-inner-radius),
        start: -90deg,
        delta: -wheel-cut-angle,
        radius: 25% * wheel-inner-radius,
        name: "pt-4-angle",
      )
      content(
        (-90deg - wheel-cut-angle / 2, 15% * wheel-inner-radius),
        dim-text[#calc.round(wheel-cut-angle / 1deg)°],
        anchor: "center",
      )

      line("2", (rel: (0, 30% * ring-thickness), to: "2"), name: "upper-feather-length-tick-start")
      line("10", (rel: (0, 30% * ring-thickness), to: "10"), name: "upper-feather-length-tick-end")
      line(
        (rel: (0, 25% * ring-thickness), to: "2"),
        (rel: (0, 25% * ring-thickness), to: "10"),
        mark: dim-arrows,
        name: "upper-feather-arm-dim",
      )
      content("upper-feather-arm-dim.mid", dim-length-cm(feather-arm-length), anchor: "south", padding: 1pt)
      line(
        (rel: (-120deg, 50% * ring-thickness), to: "10"),
        (rel: (-120deg, ring-thickness), to: "10"),
        mark: dim-arrow-end,
        name: "upper-feather-tip-dim",
      )
      content(
        "upper-feather-tip-dim.mid",
        angle: "upper-feather-tip-dim.end",
        text(size: 2pt, fill: blueprint-ink)[#rotate(180deg)[T]],
        anchor: "south",
        padding: 1pt,
      )

      line("15", (rel: (0, -30% * ring-thickness), to: "15"), name: "lower-feather-tip-dim-tick-15")
      line("16", (rel: (0, -30% * ring-thickness), to: "16"), name: "lower-feather-tip-dim-tick-16")
      line(
        (rel: (0, -25% * ring-thickness), to: "15"),
        (rel: (0, -25% * ring-thickness), to: "16"),
        mark: dim-arrows,
        name: "lower-feather-tip-dim",
      )
      content("lower-feather-tip-dim.mid", dim-text[T], anchor: "north", padding: 1pt)

      line("12", (rel: (0, 30% * ring-thickness), to: "12"), name: "middle-feather-tip-dim-tick-12")
      line("13", (rel: (0, 30% * ring-thickness), to: "13"), name: "middle-feather-tip-dim-tick-13")
      line(
        (rel: (0, 25% * ring-thickness), to: "12"),
        (rel: (0, 25% * ring-thickness), to: "13"),
        mark: dim-arrows,
        name: "middle-feather-tip-dim",
      )
      content("middle-feather-tip-dim.mid", dim-text[T], anchor: "south", padding: 1pt)

      line("4", ("4", "|-", (0cm, feather-divider-y-1)), mark: dim-arrows, name: "feather-division-dim-1")
      content("feather-division-dim-1.mid", dim-text[G], anchor: "west", padding: 2pt)
      line(("4", "|-", (0cm, feather-divider-y-1)), ("4", "|-", (0cm, feather-divider-y-2)), mark: dim-arrows, name: "feather-division-dim-2")
      content("feather-division-dim-2.mid", dim-text[T], anchor: "west", padding: 2pt)
      line(("4", "|-", (0cm, feather-divider-y-2)), ("4", "|-", (0cm, feather-divider-y-3)), mark: dim-arrows, name: "feather-division-dim-3")
      content("feather-division-dim-3.mid", dim-text[G], anchor: "west", padding: 2pt)
      line(("4", "|-", (0cm, feather-divider-y-3)), ("4", "|-", (0cm, feather-divider-y-4)), mark: dim-arrows, name: "feather-division-dim-4")
      content("feather-division-dim-4.mid", dim-text[T], anchor: "west", padding: 2pt)
      line(("4", "|-", (0cm, feather-divider-y-4)), ("4", "|-", (0cm, wheel-inner-radius)), mark: dim-arrows, name: "feather-division-dim-5")
      content(
        "feather-division-dim-5.mid",
        dim-text[G = #calc.round(feather-spacing-height / 1cm, digits: 3) cm],
        anchor: "west",
        padding: 2pt,
      )
    })
  }

  // -- layer 4: feathered-wheel shape
  if show-shape {
    on-layer(4, {
      // step 1 — wheel ring (fill-a)
      //   1 →[CW arc]→ 3 → 4 →[CCW arc]→ 2 → 11 →[arc via SW]→ 9 → 1
      merge-path({
        arc-through("1", (0cm, -wheel-inner-radius), "3")
        line("3", "4")
        arc-through("4", (0cm, -wheel-outer-radius), "2")
        line("2", "11")
        arc-through("11", (rel: (225deg, ring-thickness), to: "10"), "9")
        line("9", "1")
      }, close: true, fill: fill-a, stroke: none, name: "wheel-ring")

      // step 2 — middle feather (fill-b)
      //   8 → 12 →[arc]→ 14 → 7 →[arc]→ 8
      merge-path({
        line("8", "12")
        arc-through("12", (rel: (225deg, ring-thickness), to: "13"), "14")
        line("14", "7")
        arc-through(
          "7",
          (
            -calc.sqrt(calc.max(
              0,
              calc.pow(wheel-inner-radius / 1cm, 2)
                - calc.pow(((feather-divider-y-3 + feather-divider-y-4) / 2) / 1cm, 2),
            )) * 1cm,
            (feather-divider-y-3 + feather-divider-y-4) / 2,
          ),
          "8",
        )
      }, close: true, fill: fill-b, stroke: none, name: "middle-feather")

      // step 3 — lower feather (fill-b)
      //   6 → 17 →[arc]→ 18 → 5 →[arc]→ 6
      merge-path({
        line("6", "17")
        arc-through("17", (rel: (225deg, ring-thickness), to: "16"), "18")
        line("18", "5")
        arc-through(
          "5",
          (
            -calc.sqrt(calc.max(
              0,
              calc.pow(wheel-inner-radius / 1cm, 2)
                - calc.pow(((feather-divider-y-1 + feather-divider-y-2) / 2) / 1cm, 2),
            )) * 1cm,
            (feather-divider-y-1 + feather-divider-y-2) / 2,
          ),
          "6",
        )
      }, close: true, fill: fill-b, stroke: none, name: "lower-feather")
    })
  }
  }
  if canvas {
    cetz.canvas(draw)
  } else {
    draw
  }
}

#feathered-wheel(
  show-shape: false,
  show-dimensions: true,
  show-construction: true,
  show-points: true,
)
