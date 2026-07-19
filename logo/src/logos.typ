// Copyright 2026 Martin Scheidt (ORCID: 0000-0002-9384-8945) Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
// This license enables reusers to copy and distribute the material in any medium or format in unadapted form only, for noncommercial purposes only, and only if attribution is given to the creator.

#set page(width: auto, height: auto, margin: 0mm, fill: none)
#import "@preview/cetz:0.5.2"
#import "feathered-wheel.typ": feathered-wheel, symbol-bounds
#import "gears.typ": gears
#import "light-bulb.typ": light-bulbs
#import "name.typ": name

#let railtoolkit-color = rgb("#025a96")
#let railtoolkit-color-light = rgb("#567695")

#let railedukit-color = rgb("#006600")
#let railedukit-color-light = rgb("#598059")

#let logo(
  fill-a: black,
  fill-b: black,
  wheel-origin: (0cm, 0cm),
  centre-origin: (0cm, 0cm),
  centre-scale: 100%,
  centre: none,
  with-text: false,
  wordmark: "",
  canvas: true,
) = {
  let draw = {
    import cetz.draw: group, scale

    feathered-wheel(
      fill-a: fill-a,
      fill-b: fill-b,
      origin: wheel-origin,
      canvas: false,
    )
    group({
      scale(centre-scale, origin: centre-origin)
      centre(
        fill-a: fill-a,
        fill-b: fill-b,
        origin: centre-origin,
        canvas: false,
      )
    })
    if with-text {
      name(
        symbol-bounds(origin: wheel-origin),
        wordmark: wordmark,
        fill-a: fill-a,
        fill-b: fill-b,
        canvas: false,
      )
    }
  }
  if canvas {
    cetz.canvas(draw)
  } else {
    draw
  }
}

#let railtoolkit-logo(..args) = logo(
  fill-a: railtoolkit-color,
  fill-b: railtoolkit-color-light,
  centre-origin: (-0.25cm, -0.2cm),
  centre: gears,
  wordmark: "RailToolKit",
  ..args,
)

#let railedukit-logo(..args) = logo(
  fill-a: railedukit-color,
  fill-b: railedukit-color-light,
  centre-origin: (-0.1cm, -0.2cm),
  centre: light-bulbs,
  wordmark: "RailEduKit",
  ..args,
)

#railtoolkit-logo(with-text: true)

#v(1cm)

#railedukit-logo(with-text: true)
