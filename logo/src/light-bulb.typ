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

#let construction-style = (stroke: blueprint-ink + 0.1pt, dash: "densely-dotted")
#let dim-style = (stroke: blueprint-ink + 0.15pt)
#let dim-text(body) = text(size: 2pt, fill: blueprint-ink)[#body]
#let dim-length-cm(length) = dim-text[#calc.round(length / 1cm, digits: 2) cm]
#let dim-arrows = (
  start: (symbol: ">", scale: 0.1, fill: blueprint-ink, shorten-to: none),
  end: (symbol: ">", scale: 0.1, fill: blueprint-ink, shorten-to: none),
)
#let dim-arrow-end = (
  end: (symbol: ">", scale: 0.1, fill: blueprint-ink, shorten-to: none),
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

#let light-bulb(
  origin: (0cm, 0cm),
  show-shape: true,
  show-construction: false,
  show-points: false,
  show-dimensions: false,
  fill-a: black,
  fill-b: black,
  screw-gap: 0.1cm,
  // Outward silhouette offset (smooth; for boolean cutouts). Glass-circle
  // center stays fixed; radii / half-widths / extents grow by `expand`.
  expand: 0cm,
  // Overlap glass∪screw into one solid cutout silhouette.
  fuse: false,
  canvas: true,
) = {
  let draw = {
    import cetz.draw: *

    // -- parameters
    let e = expand
    let bulb-r0 = 0.5cm
    let bulb-radius = bulb-r0 + e
    let fitting-half = bulb-r0 / 2 + e
    let bulb-base-height = 0.3cm + e
    let bulb-fitting-height = 0.1cm + e
    let bulb-fitting-radius = 0.05cm + e
    let bulb-tangent-length = bulb-base-height / 2
    let bulb-neck-tangent = 10%
    let screw-width = bulb-r0 * 0.8 + 2 * e
    let screw-radius = 0.015cm + e
    let gap = if fuse or e > 0cm { -0.02cm } else { screw-gap }
    let screw-body-height = 0.21cm + 2 * e
    let screw-tip-width = bulb-r0 * 0.8 * 0.8 + 2 * e
    let screw-tip-offset = 0.03cm
    let screw-tip-height = 0.08cm + e
    // bezier ctrl length: tip side follows arc 19–12–20; body side stays vertical
    let screw-chemfer-tangent = 50% * (screw-tip-offset + screw-radius)

    // -- layer 0: hidden geometry (anchors for later layers)
    //
    // Point index:
    //   origin — neck (bulb / fitting junction)
    //   1      fitting bottom center
    //   2–3    fitting left-top / right-top
    //   4–5    span helper ends (left / right) — bezier controls
    //   6–7    bulb circle ∩ cross from 1 (left / right)
    //   8–9    neck tangents on 6→1 / 7→1 (bezier ctrl at 6/7)
    //   10     bulb center
    //   12     screw tip apex
    //   13–14  screw top edge L/R
    //   15–16  screw top-side L/R (after top fillets)
    //   17–18  screw body bottom L/R
    //   19–20  screw tip outer L/R
    //
    // Screw outline (CCW), fillets at 12, 16/14, 13/15; chemfer beziers at 20/18, 17/19:
    //   19 →[via 12]→ 20 →[bezier]→ 18 → 16 →[fillet]→ 14 → 13 →[fillet]→ 15 → 17 →[bezier]→ 19
    //
    on-layer(0, {
      register-point(origin, "origin")
      register-point((rel: (0, -bulb-base-height), to: origin), "1")
      register-point((rel: (-fitting-half, -bulb-base-height + bulb-fitting-height), to: origin), "2")
      register-point((rel: (fitting-half, -bulb-base-height + bulb-fitting-height), to: origin), "3")
      // glass center fixed at base radius so expand grows the circle outward
      register-point((rel: (0, bulb-r0), to: origin), "10")

      hide(circle("10", radius: bulb-radius, name: "bulb-top"))

      hide(line("2", (rel: (0, bulb-tangent-length), to: "2"), name: "bulb-span-left-helper"))
      hide(line("3", (rel: (0, bulb-tangent-length), to: "3"), name: "bulb-span-right-helper"))
      register-point("bulb-span-left-helper.end", "4")
      register-point("bulb-span-right-helper.end", "5")

      hide(line("1", (element: "bulb-top", point: "1", solution: 2), name: "bulb-cross-left"))
      hide(line("1", (element: "bulb-top", point: "1", solution: 1), name: "bulb-cross-right"))
      register-point("bulb-cross-left.end", "6")
      register-point("bulb-cross-right.end", "7")
      register-point(("6", bulb-neck-tangent, "1"), "8")
      register-point(("7", bulb-neck-tangent, "1"), "9")

      register-point(
        (rel: (-fitting-half + bulb-fitting-radius, -bulb-base-height + bulb-fitting-radius), to: origin),
        "fitting-fillet",
      )
      register-point(
        (rel: (fitting-half - bulb-fitting-radius, -bulb-base-height + bulb-fitting-radius), to: origin),
        "fitting-fillet-right",
      )
      register-point((rel: (0deg, bulb-fitting-radius), to: "fitting-fillet-right"), "fitting-br-start")
      register-point((rel: (-45deg, bulb-fitting-radius), to: "fitting-fillet-right"), "fitting-br-mid")
      register-point((rel: (-90deg, bulb-fitting-radius), to: "fitting-fillet-right"), "fitting-br-end")
      register-point((rel: (-90deg, bulb-fitting-radius), to: "fitting-fillet"), "fitting-bl-end")
      register-point((rel: (-135deg, bulb-fitting-radius), to: "fitting-fillet"), "fitting-bl-mid")
      register-point((rel: (180deg, bulb-fitting-radius), to: "fitting-fillet"), "fitting-bl-start")

      // screw: top at gap below 1; body down to bottom; tip below bottom
      register-point(
        (rel: (0, -bulb-base-height - gap - screw-body-height), to: origin),
        "screw-bottom",
      )
      register-point((rel: (0, -screw-tip-height), to: "screw-bottom"), "12")

      register-point(
        (rel: (-screw-width / 2 + screw-radius, -bulb-base-height - gap - screw-radius), to: origin),
        "screw-tl-fillet",
      )
      register-point(
        (rel: (screw-width / 2 - screw-radius, -bulb-base-height - gap - screw-radius), to: origin),
        "screw-tr-fillet",
      )
      register-point((rel: (90deg, screw-radius), to: "screw-tl-fillet"), "13")
      register-point((rel: (90deg, screw-radius), to: "screw-tr-fillet"), "14")
      register-point((rel: (180deg, screw-radius), to: "screw-tl-fillet"), "15")
      register-point((rel: (0deg, screw-radius), to: "screw-tr-fillet"), "16")
      register-point((rel: (135deg, screw-radius), to: "screw-tl-fillet"), "screw-tl-mid")
      register-point((rel: (45deg, screw-radius), to: "screw-tr-fillet"), "screw-tr-mid")

      register-point((rel: (-screw-width / 2, 0), to: "screw-bottom"), "17")
      register-point((rel: (screw-width / 2, 0), to: "screw-bottom"), "18")

      register-point(
        (rel: (-screw-tip-width / 2 + screw-radius, -screw-tip-offset - screw-radius), to: "screw-bottom"),
        "tip-fillet-left",
      )
      register-point(
        (rel: (screw-tip-width / 2 - screw-radius, -screw-tip-offset - screw-radius), to: "screw-bottom"),
        "tip-fillet-right",
      )
      register-point((rel: (180deg, screw-radius), to: "tip-fillet-left"), "19")
      register-point((rel: (0deg, screw-radius), to: "tip-fillet-right"), "20")

      // tip arc 19→12→20 (same circle as arc-through); CCW tangents at 19/20 for chemfer beziers
      hide(circle-through("19", "12", "20", name: "tip-arc"))
      let as-cm(length) = length / 1cm
      let tip-half = as-cm(screw-tip-width / 2)
      let tip-side-y = as-cm(screw-tip-offset + screw-radius)
      let tip-apex-y = as-cm(screw-tip-height)
      let tip-arc-cy = (
        tip-half * tip-half + tip-side-y * tip-side-y - tip-apex-y * tip-apex-y
      ) / (2 * (tip-apex-y - tip-side-y))
      let ry = -tip-side-y - tip-arc-cy
      let rlen = calc.sqrt(tip-half * tip-half + ry * ry)
      let t = as-cm(screw-chemfer-tangent)
      // radius→CCW: (rx, ry) ↦ (-ry, rx); at 20 rx=+half, at 19 rx=-half
      register-point(
        (rel: ((-ry / rlen) * t * 1cm, (tip-half / rlen) * t * 1cm), to: "20"),
        "20-ctrl",
      )
      register-point(
        (rel: ((ry / rlen) * t * 1cm, (tip-half / rlen) * t * 1cm), to: "19"),
        "19-ctrl",
      )
      // body sides — vertical tangents
      register-point((rel: (0, -screw-chemfer-tangent), to: "18"), "18-ctrl")
      register-point((rel: (0, -screw-chemfer-tangent), to: "17"), "17-ctrl")
    })

    // -- layer 1: construction
    if show-construction {
      on-layer(1, {
        circle("10", radius: bulb-radius, ..construction-style)
        rect(
          (rel: (-fitting-half, -bulb-base-height), to: origin),
          (rel: (2 * fitting-half, bulb-fitting-height)),
          ..construction-style,
          radius: (south: bulb-fitting-radius),
          name: "bulb-fitting",
        )

        line("1", "6", ..construction-style, name: "bulb-cross-left")
        line("1", "7", ..construction-style, name: "bulb-cross-right")
        line("2", "4", ..construction-style, name: "bulb-span-left-helper")
        line("3", "5", ..construction-style, name: "bulb-span-right-helper")
        line("6", "8", ..construction-style, name: "bulb-neck-tangent-left")
        line("7", "9", ..construction-style, name: "bulb-neck-tangent-right")
        line("20", "20-ctrl", ..construction-style, name: "screw-chemfer-20")
        line("18", "18-ctrl", ..construction-style, name: "screw-chemfer-18")
        line("17", "17-ctrl", ..construction-style, name: "screw-chemfer-17")
        line("19", "19-ctrl", ..construction-style, name: "screw-chemfer-19")

        bezier("6", "2", "8", "4", ..construction-style)
        bezier("7", "3", "9", "5", ..construction-style)

        merge-path({
          arc-through("19", "12", "20")
          bezier("20", "18", "20-ctrl", "18-ctrl")
          line("18", "16")
          arc-through("16", "screw-tr-mid", "14")
          line("14", "13")
          arc-through("13", "screw-tl-mid", "15")
          line("15", "17")
          bezier("17", "19", "17-ctrl", "19-ctrl")
        }, close: true, ..construction-style, name: "screw")
      })
    }

    // -- layer 2: point labels
    if show-points {
      on-layer(2, {
        show-point-label("origin", "origin")
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
        show-point-label("12", "12")
        show-point-label("13", "13")
        show-point-label("14", "14")
        show-point-label("15", "15")
        show-point-label("16", "16")
        show-point-label("17", "17")
        show-point-label("18", "18")
        show-point-label("19", "19")
        show-point-label("20", "20")
      })
    }

    // -- layer 3: dimensions
    if show-dimensions {
      on-layer(3, {
        set-style(stroke: dim-style.stroke)

        line(
          (rel: (50deg, 50% * bulb-radius), to: "10"),
          (rel: (50deg, bulb-radius), to: "10"),
          mark: dim-arrow-end,
          name: "bulb-radius-dim",
        )
        content(
          "bulb-radius-dim.mid",
          angle: "bulb-radius-dim.end",
          dim-text[R = #calc.round(bulb-radius / 1cm, digits: 2) cm],
          anchor: "south",
          padding: 1pt,
        )

        line(
          (rel: (-135deg, 0), to: "fitting-fillet"),
          (rel: (-135deg, bulb-fitting-radius), to: "fitting-fillet"),
          mark: dim-arrow-end,
          name: "bulb-fitting-radius-dim",
        )
        content(
          "bulb-fitting-radius-dim.mid",
          angle: "bulb-fitting-radius-dim.end",
          text(size: 2pt, fill: blueprint-ink)[#std.rotate(180deg)[r = #calc.round(bulb-fitting-radius / 1cm, digits: 2) cm]],
          anchor: "south",
          padding: 1pt,
        )

        line("10", "origin", mark: dim-arrows, name: "bulb-10-origin-dim")
        content("bulb-10-origin-dim.mid", dim-length-cm(bulb-radius), anchor: "west", padding: 0.5pt)
        line("origin", ("1", "|-", "2"), mark: dim-arrows, name: "bulb-origin-fitting-dim")
        content(
          "bulb-origin-fitting-dim.mid",
          dim-length-cm(bulb-base-height - bulb-fitting-height),
          anchor: "west",
          padding: 0.5pt,
        )
        line(("1", "|-", "2"), "1", mark: dim-arrows, name: "bulb-fitting-height-dim")
        content("bulb-fitting-height-dim.mid", dim-length-cm(bulb-fitting-height), anchor: "west", padding: 0.5pt)

        // -- screw: gap 1→13/14, body 14→18, tip to 12, width 17–18, fillet r
        line("1", ("1", "|-", "13"), mark: dim-arrows, name: "screw-gap-dim")
        content("screw-gap-dim.mid", dim-length-cm(screw-gap), anchor: "west", padding: 0.5pt)
        line(("1", "|-", "14"), ("1", "|-", "18"), mark: dim-arrows, name: "screw-body-height-dim")
        content("screw-body-height-dim.mid", dim-length-cm(screw-body-height), anchor: "west", padding: 0.5pt)
        line("screw-bottom", "12", mark: dim-arrows, name: "screw-tip-height-dim")
        content("screw-tip-height-dim.mid", dim-length-cm(screw-tip-height), anchor: "west", padding: 0.5pt)
        line("17", "18", mark: dim-arrows, name: "screw-width-dim")
        content("screw-width-dim.mid", dim-length-cm(screw-width), anchor: "south", padding: 0.5pt)
        line(
          (rel: (-135deg, 0), to: "screw-tr-fillet"),
          (rel: (-135deg, screw-radius), to: "screw-tr-fillet"),
          mark: dim-arrow-end,
          name: "screw-radius-dim",
        )
        content(
          "screw-radius-dim.mid",
          angle: "screw-radius-dim.end",
          text(size: 2pt, fill: blueprint-ink)[#std.rotate(180deg)[r = #calc.round(screw-radius / 1cm, digits: 2) cm]],
          anchor: "south",
          padding: 1pt,
        )

        line("3", "5", mark: dim-arrows, name: "bulb-tangent-dim")
        content("bulb-tangent-dim.mid", dim-length-cm(bulb-tangent-length), anchor: "west", padding: 0.5pt)
      })
    }

    // -- layer 4: bulb + screw shapes
    //   bulb: 6 →[arc]→ 7 →[bezier]→ 3 → br → bl → 2 →[bezier]→ 6
    //   screw: 19 →[12]→ 20 →[bezier]→ 18 → 16 →[14]→ 13 →[15]→ 17 →[bezier]→ 19
    //   gap bulb↔screw is geometric (screw-gap); inter-bulb cutout is in light-bulbs()
    if show-shape {
      on-layer(4, {
        let bulb-outline = {
          arc-through("6", (rel: (0, bulb-radius), to: "10"), "7")
          bezier("7", "3", "9", "5")
          line("3", "fitting-br-start")
          arc-through("fitting-br-start", "fitting-br-mid", "fitting-br-end")
          line("fitting-br-end", "fitting-bl-end")
          arc-through("fitting-bl-end", "fitting-bl-mid", "fitting-bl-start")
          line("fitting-bl-start", "2")
          bezier("2", "6", "4", "8")
        }
        let screw-outline = {
          arc-through("19", "12", "20")
          bezier("20", "18", "20-ctrl", "18-ctrl")
          line("18", "16")
          arc-through("16", "screw-tr-mid", "14")
          line("14", "13")
          arc-through("13", "screw-tl-mid", "15")
          line("15", "17")
          bezier("17", "19", "17-ctrl", "19-ctrl")
        }

        merge-path(bulb-outline, close: true, fill: fill-a, stroke: none, name: "bulb")
        merge-path(screw-outline, close: true, fill: fill-b, stroke: none, name: "screw")
      })
    }
  }
  if canvas {
    cetz.canvas(draw)
  } else {
    draw
  }
}

// Two light bulbs for the logo symbol (defaults from railedukit-logo.typ).
// Rear bulb is boolean-cut by an expanded front bulb (same outline family:
// circle + neck beziers), so the gap is a real transparent hole.
#let light-bulbs(
  show-shape: true,
  fill-a: black,
  fill-b: black,
  origin: (0cm, 0cm),
  scale-a: 65%,
  scale-b: 49%,
  screw-gap: 0.1cm,
  canvas: true,
) = {
  let bulb-b-offset = (0.415cm, 0.15cm)
  let origin-a = origin
  let origin-b = (origin.at(0) + bulb-b-offset.at(0), origin.at(1) + bulb-b-offset.at(1))
  let draw = {
    import cetz.draw: boolean, group, scale

    if show-shape {
      boolean(
        {
          scale(scale-b, origin: origin-b)
          light-bulb(
            show-shape: true,
            fill-a: fill-b,
            fill-b: fill-b,
            screw-gap: screw-gap,
            origin: origin-b,
            canvas: false,
          )
        },
        {
          scale(scale-a, origin: origin-a)
          light-bulb(
            show-shape: true,
            fill-a: fill-a,
            fill-b: fill-a,
            screw-gap: screw-gap,
            expand: screw-gap,
            fuse: true,
            origin: origin-a,
            canvas: false,
          )
        },
        op: "difference",
        fill-rule-a: "non-zero",
        fill-rule-b: "non-zero",
        fill: fill-b,
        stroke: none,
        name: "bulb-b",
      )
    }
    group(name: "bulb-a", {
      scale(scale-a, origin: origin-a)
      light-bulb(
        show-shape: show-shape,
        fill-a: fill-a,
        fill-b: fill-a,
        screw-gap: screw-gap,
        origin: origin-a,
        canvas: false,
      )
    })
  }
  if canvas {
    cetz.canvas(draw)
  } else {
    draw
  }
}

#light-bulb(
  show-shape: false,
  show-dimensions: true,
  show-construction: true,
  show-points: true,
  fill-a: blueprint-ink,
  fill-b: blueprint-ink.lighten(60%),
)

#light-bulbs(
  fill-a: blueprint-ink,
  fill-b: blueprint-ink.lighten(60%),
)
