# Cutaway

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://tamasgal.github.io/Cutaway.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://tamasgal.github.io/Cutaway.jl/dev)
[![Build Status](https://github.com/tamasgal/Cutaway.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/tamasgal/Cutaway.jl/actions/workflows/CI.yml?query=branch%3Amain)

`Cutaway.jl` bundles a histogram with a list of cuts and fills one
filtered histogram per cut as you stream data through it. Cuts can be
applied independently (each cut on its own) or cumulatively (each cut on
top of all preceding ones).

## Installation

`Cutaway.jl` is registered in the Julia General registry:

    julia> import Pkg; Pkg.add("Cutaway")

## Quickstart

```julia
using Cutaway, StatsBase

rows = [(zenith = π * rand(), likelihood = 100 * rand()) for _ in 1:10_000]

cuts = [
    Cut(r -> r.likelihood > 50;            label = "likelihood > 50"),
    Cut(r -> cos(r.zenith) < 0;            label = "upgoing"),
]

chist = CutHist(Histogram(range(-1, 1; length = 41)), cuts)

for r in rows
    push!(chist, cos(r.zenith), r)
end

chist.h            # baseline histogram, all events
chist.hcuts[1]     # events that passed `likelihood > 50`
chist.hcuts[2]     # events that passed `upgoing`
```

Pass `cumulative = true` to the `CutHist` constructor to apply the cuts
as an ordered chain instead, so `chist.hcuts[i]` only fills when cuts
`1..i` all pass.

Plotting examples with CairoMakie are available under
[Independent cuts](https://tamasgal.github.io/Cutaway.jl/dev/examples/independent_cuts/)
and
[Cumulative cuts](https://tamasgal.github.io/Cutaway.jl/dev/examples/cumulative_cuts/).
