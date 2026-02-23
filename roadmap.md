# RailToolKit Roadmap

This roadmap captures where we want to take the RailToolKit ecosystem. Nothing here is set in stone — priorities shift as contributors join and real-world needs emerge. If something on this list excites you, open an issue or start a discussion on [GitHub](https://github.com/railtoolkit).

---

## Core Ecosystem

### Meta Package `RailToolKit.jl`

A single entry point that re-exports the ecosystem's packages, manages compatible version sets, and provides a unified getting-started experience.

### Shared Object Model

Define the common types that all packages build on:

- Train
- Path / Route
- Train run (simulated)
- Historic runs (observed)

These live in a shared core package so that every tool in the ecosystem speaks the same language.

### RailML Import / Export

Read and write [RailML](https://www.railml.org/) files to connect RailToolKit with the broader railway data ecosystem and existing industry workflows.

---

## Train Simulation — TrainRuns.jl 2.0

The next major version of our flagship package:

- **Shortest running time** calculation (existing, improved)
- **Energy-efficient driving** strategies
- **Braking models**
  - Physics-based braking model
  - Driver braking model (cf. Medeossi, Lesson 3, p. 50)
- **Musterzug** (standard train configurations)
- **Input/output snippets** — ready-made examples for common use cases
- **Uncertainty propagation** via [Measurements.jl](https://juliaphysics.github.io/Measurements.jl/stable/)
- **Python bridge** — call TrainRuns from Python for wider adoption

---

## Infrastructure Data

### OpenStreetMap Fetcher

Pull railway infrastructure directly from OSM:

- Network graph extraction
- Gradient profiles
- Line speed limits
- Route definitions
- Shortest-path / route finding

### Vehicle Database

A community-maintained collection of rolling stock data:

- Interface to an online vehicle register
- Traction force–velocity calculator
- Braking force–velocity calculator
- Citizen-science contribution workflow for adding new vehicles

---

## Visualization

A plotting and diagramming layer for railway data, with backends for both interactive (Makie) and publication-quality (TikZ/PGFPlots) output:

### Track Schematics

- [tikz-trackschematics](https://github.com/railtoolkit/tikz-trackschematics) (LaTeX)
- Makie-based track schematics (interactive)
- Automated layout via SAT solver

### Diagrams & Plots

- Route maps
- Gradient / speed profiles (Makie, PGFPlots)
- Time-distance (timetable) diagrams (Makie, TikZ)

### Statistical Graphics

- Histograms
- Distribution plots

---

## Operations & Capacity

### Blocking Time Calculator

Compute blocking-time stairways for capacity analysis, including stochastic extensions for delay propagation studies.

### Timetabling

- **PESP solver** — Periodic Event Scheduling Problem for cyclic timetable construction
- **HACON timetable fetcher** — import timetable data from HACON/HaCon systems

---

## Statistics & Analysis

A package for working with historic operational data:

- Primary and secondary delay decomposition
- Dwell time analysis
- Data filtering and cleaning
- Uncertainty representation via [Measurements.jl](https://juliaphysics.github.io/Measurements.jl/stable/) or [FuzzyLogic.jl](https://github.com/lucaferranti/FuzzyLogic.jl)

---

## Community & Education

### Catalog of Operational Situations

A structured, open collection of operational scenarios, manoeuvres, and deadlock patterns — useful for teaching, benchmarking, and testing.

### Events & Programs

- **Summer of Code** — mentored projects for new contributors
- **Summer school / workshop** — hands-on literate programming with RailToolKit
- **Bar camp / unconference** — community-driven meetups
- **Community Q&A** — a knowledge base in the spirit of Stack Exchange, possibly via [Codidact](https://codidact.com)

---

## How to Contribute to the Roadmap

This is a living document. If you have ideas, corrections, or want to champion an item:

1. **Open an issue** on [GitHub](https://github.com/railtoolkit) to discuss a roadmap item
2. **Submit a PR** to update this file with new ideas or status changes
3. **Start building** — pick an item, open a draft PR, and let the community help
