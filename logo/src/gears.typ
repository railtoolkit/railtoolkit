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

#let gear(
  show-shape: true,
  show-construction: false,
  show-points: false,
  show-dimensions: false,
  fill: black,
  origin: (0cm, 0cm),
  gear-inner-radius: 0.5cm,
  gear-outer-radius: 1cm,
  tooth-count: 8,
  name-prefix: "",
  canvas: true,
) = {
  let draw = {
    import cetz.draw: arc-through, circle, compound-path, content, group, hide, intersections, line, merge-path, on-layer, set-style

    let id = name-prefix
  let notch-phase-offset = 360deg / tooth-count / 2
  let notch-phase = 360deg / tooth-count
  let notch-radius = calc.pi * gear-outer-radius / tooth-count / 2
  let chemfer-radius = notch-radius * 45%
  let notch-span-half = calc.acos(
    (2 * calc.pow(gear-outer-radius / 1cm, 2) - calc.pow(notch-radius / 1cm, 2))
      / (2 * calc.pow(gear-outer-radius / 1cm, 2)),
  )

  // hidden chemfer placement only (CeTZ: no circle–circle anchors)
  let chemfer-center-at(notch-angle, lo-side: true) = {
    let as-cm(length) = length / 1cm
    let to-cm(value) = value * 1cm
    let notch-center = (
      origin.at(0) + gear-outer-radius * calc.cos(notch-angle),
      origin.at(1) - gear-outer-radius * calc.sin(notch-angle),
    )
    let flank-angle = notch-angle + (if lo-side { -notch-span-half } else { notch-span-half })
    let flank-profile = (
      origin.at(0) + gear-outer-radius * calc.cos(flank-angle),
      origin.at(1) - gear-outer-radius * calc.sin(flank-angle),
    )
    let refs = {
      let (x1, y1, x2, y2) = (
        as-cm(origin.at(0)), as-cm(origin.at(1)),
        as-cm(notch-center.at(0)), as-cm(notch-center.at(1)),
      )
      let (rr1, rr2, dx, dy) = (
        as-cm(gear-outer-radius - chemfer-radius),
        as-cm(notch-radius + chemfer-radius),
        x2 - x1, y2 - y1,
      )
      let distance = calc.sqrt(dx * dx + dy * dy)
      let midpoint = (rr1 * rr1 - rr2 * rr2 + distance * distance) / (2 * distance)
      let half-chord = calc.sqrt(calc.max(0, rr1 * rr1 - midpoint * midpoint))
      let (ux, uy) = (dx / distance, dy / distance)
      let (mx, my) = (x1 + midpoint * ux, y1 + midpoint * uy)
      (
        (to-cm(mx + half-chord * (-uy)), to-cm(my + half-chord * ux)),
        (to-cm(mx - half-chord * (-uy)), to-cm(my - half-chord * ux)),
      )
    }
    let dist-squared(a, b) = {
      let (dx, dy) = (as-cm(a.at(0) - b.at(0)), as-cm(a.at(1) - b.at(1)))
      dx * dx + dy * dy
    }
    if dist-squared(refs.at(0), flank-profile) <= dist-squared(refs.at(1), flank-profile) {
      refs.at(0)
    } else {
      refs.at(1)
    }
  }

  // -- layer 0: hidden geometry + profile points
  //
  // Per notch X, clockwise p1 → p2 → p3 → p4:
  //   p1  lo-chemfer ∩ gear-outer-edge
  //   p2  notch ∩ lo-chemfer
  //   p3  notch ∩ hi-chemfer
  //   p4  gear-outer-edge ∩ hi-chemfer
  on-layer(0, {
    hide(circle(origin, radius: gear-outer-radius, name: id + "gear-outer-edge"))
    register-point(origin, id + "origin")

    for i in range(tooth-count) {
      let notch-angle = notch-phase-offset + i * notch-phase
      let prefix = id + "notch-" + str(i)
      let lo-chemfer = chemfer-center-at(notch-angle, lo-side: true)
      let hi-chemfer = chemfer-center-at(notch-angle, lo-side: false)

      let notch-center = (
        origin.at(0) + gear-outer-radius * calc.cos(notch-angle),
        origin.at(1) - gear-outer-radius * calc.sin(notch-angle),
      )

      register-point(notch-center, prefix + "-center")
      hide(circle(notch-center, radius: notch-radius, name: prefix))
      hide(circle(hi-chemfer, radius: chemfer-radius, name: prefix + "-hi-chemfer"))
      hide(circle(lo-chemfer, radius: chemfer-radius, name: prefix + "-lo-chemfer"))

      hide(line(
        origin,
        (origin, 200%, lo-chemfer),
        name: prefix + "-p1-ray",
      ))
      intersections(prefix + "-p1-hit", prefix + "-p1-ray", id + "gear-outer-edge")
      register-point(prefix + "-p1-hit.0", prefix + "-p1")

      hide(line(
        origin,
        (origin, 200%, hi-chemfer),
        name: prefix + "-p4-ray",
      ))
      intersections(prefix + "-p4-hit", prefix + "-p4-ray", id + "gear-outer-edge")
      register-point(prefix + "-p4-hit.0", prefix + "-p4")

      // tangent on notch (also on chemfer): center → chemfer, at distance notch-radius
      let on-notch-toward(chemfer-center) = {
        let (dx, dy) = (
          (chemfer-center.at(0) - notch-center.at(0)) / 1cm,
          (chemfer-center.at(1) - notch-center.at(1)) / 1cm,
        )
        let d = calc.sqrt(dx * dx + dy * dy)
        (
          notch-center.at(0) + notch-radius * dx / d,
          notch-center.at(1) + notch-radius * dy / d,
        )
      }
      register-point(on-notch-toward(lo-chemfer), prefix + "-p2")
      register-point(on-notch-toward(hi-chemfer), prefix + "-p3")

      hide(line(origin, notch-center, name: prefix + "-axis-ray"))
      intersections(prefix + "-valley-hit", prefix + "-axis-ray", prefix)
      register-point(prefix + "-valley-hit.0", prefix + "-valley")

      let outer-mid-angle = notch-angle + notch-phase / 2
      register-point((
        origin.at(0) + gear-outer-radius * calc.cos(outer-mid-angle),
        origin.at(1) - gear-outer-radius * calc.sin(outer-mid-angle),
      ), prefix + "-outer-mid")

      if i == 0 {
        let valley = (
          origin.at(0) + (gear-outer-radius - notch-radius) * calc.cos(notch-angle),
          origin.at(1) - (gear-outer-radius - notch-radius) * calc.sin(notch-angle),
        )
        register-point(notch-center, id + "dim-notch-center")
        register-point(valley, id + "dim-notch-valley")
      }
    }
  })

  // -- layer 1: construction
  if show-construction {
    on-layer(1, {
      circle(origin, radius: gear-inner-radius, ..construction-style, name: id + "gear-inner-edge")
      circle(origin, radius: gear-outer-radius, ..construction-style)
      for i in range(tooth-count) {
        let prefix = id + "notch-" + str(i)
        circle(prefix + "-center", radius: notch-radius, ..construction-style, name: prefix)
        circle(prefix + "-hi-chemfer", radius: chemfer-radius, ..construction-style)
        circle(prefix + "-lo-chemfer", radius: chemfer-radius, ..construction-style)
      }
    })
  }

  // -- layer 2: point labels
  if show-points {
    on-layer(2, {
      show-point-label(id + "origin", "origin")
      for i in range(tooth-count) {
        let prefix = id + "notch-" + str(i)
        show-point-label(prefix + "-p1", str(i) + "p1")
        show-point-label(prefix + "-p2", str(i) + "p2")
        show-point-label(prefix + "-p3", str(i) + "p3")
        show-point-label(prefix + "-p4", str(i) + "p4")
      }
    })
  }

  // -- layer 3: dimensions (one notch as reference)
  if show-dimensions {
    on-layer(3, {
      set-style(stroke: dim-style.stroke)
      let prefix = id + "notch-0"

      let dim-valley-angle = notch-phase-offset - notch-phase / 2

      line(
        (rel: (dim-valley-angle, 50% * gear-inner-radius), to: origin),
        (rel: (dim-valley-angle, gear-inner-radius), to: origin),
        mark: dim-arrow-end,
        name: id + "gear-inner-dim",
      )
      content(
        id + "gear-inner-dim.mid",
        angle: id + "gear-inner-dim.end",
        dim-text[R = #calc.round(gear-inner-radius / 1cm, digits: 2) cm],
        anchor: "south",
        padding: 1pt,
      )

      line(
        (rel: (dim-valley-angle, gear-inner-radius), to: origin),
        (rel: (dim-valley-angle, gear-outer-radius), to: origin),
        mark: dim-arrows,
        name: id + "gear-ring-thickness-dim",
      )
      content(
        id + "gear-ring-thickness-dim.mid",
        angle: id + "gear-ring-thickness-dim.end",
        dim-text[T = #calc.round((gear-outer-radius - gear-inner-radius) / 1cm, digits: 2) cm],
        anchor: "south",
        padding: 1pt,
      )

      line(
        id + "dim-notch-center",
        id + "dim-notch-valley",
        mark: dim-arrow-end,
        name: id + "dim-notch-radius",
      )
      content(
        id + "dim-notch-radius.mid",
        angle: id + "dim-notch-radius.end",
        text(size: 2pt, fill: blueprint-ink)[#rotate(180deg)[N = #calc.round(notch-radius / 1cm, digits: 2) cm]],
        anchor: "north",
        padding: 1pt,
      )

      line(
        (prefix + "-p3", 100%, prefix + "-hi-chemfer"),
        prefix + "-p3",
        mark: dim-arrow-end,
        name: prefix + "-chemfer-radius-dim",
      )
      content(
        prefix + "-chemfer-radius-dim.mid",
        angle: prefix + "-chemfer-radius-dim.end",
        text(size: 1.25pt, fill: blueprint-ink)[C = #calc.round(chemfer-radius / notch-radius, digits: 2) N],
        anchor: "south",
        padding: 1pt,
      )
    })
  }

  // -- layer 4: gear shape
  if show-shape {
    on-layer(4, {
      compound-path({
        merge-path({
          for i in range(tooth-count) {
            let prefix = id + "notch-" + str(i)
            let next = id + "notch-" + str(calc.rem(i + 1, tooth-count))
            arc-through(prefix + "-p2", prefix + "-valley", prefix + "-p3")
            arc-through(prefix + "-p4", prefix + "-outer-mid", next + "-p1")
          }
        }, close: true)
        circle(origin, radius: gear-inner-radius)
      }, fill: fill, stroke: none, fill-rule: "even-odd", name: id + "gear-shape")
      for i in range(tooth-count) {
        let prefix = id + "notch-" + str(i)
        circle(prefix + "-lo-chemfer", radius: chemfer-radius, fill: fill, stroke: none)
        circle(prefix + "-hi-chemfer", radius: chemfer-radius, fill: fill, stroke: none)
      }
    })
  }
  }
  if canvas {
    cetz.canvas(draw)
  } else {
    draw
  }
}

// Two gears for the logo symbol (defaults from railtoolkit-logo.typ).
#let gears(
  show-shape: true,
  fill-a: black,
  fill-b: black,
  origin: (0cm, 0cm),
  gear-inner-radius-a: 0.2cm,
  gear-outer-radius-a: 0.4cm,
  tooth-count-a: 8,
  gear-inner-radius-b: 0.15cm,
  gear-outer-radius-b: 0.3cm,
  tooth-count-b: 6,
  canvas: true,
) = {
  let gear-b-offset = (0.6cm, 0.45cm)
  let origin-a = origin
  let origin-b = (origin.at(0) + gear-b-offset.at(0), origin.at(1) + gear-b-offset.at(1))
  let draw = {
  gear(
    show-shape: show-shape,
    fill: fill-a,
    origin: origin-a,
    gear-inner-radius: gear-inner-radius-a,
    gear-outer-radius: gear-outer-radius-a,
    tooth-count: tooth-count-a,
    name-prefix: "a-",
    canvas: false,
  )
  gear(
    show-shape: show-shape,
    fill: fill-b,
    origin: origin-b,
    gear-inner-radius: gear-inner-radius-b,
    gear-outer-radius: gear-outer-radius-b,
    tooth-count: tooth-count-b,
    name-prefix: "b-",
    canvas: false,
  )
  }
  if canvas {
    cetz.canvas(draw)
  } else {
    draw
  }
}

#gear(
  show-shape: false,
  show-dimensions: true,
  show-construction: true,
  show-points: true,
  origin: (0cm, 0cm),
)

// #gears()