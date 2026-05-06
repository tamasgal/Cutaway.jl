# Cutaway

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://tgal.pages.km3net.de/Cutaway.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://tgal.pages.km3net.de/Cutaway.jl/dev)
[![Build Status](https://git.km3net.de/tgal/Cutaway.jl/badges/main/pipeline.svg)](https://git.km3net.de/tgal/Cutaway.jl/pipelines)
[![Coverage](https://git.km3net.de/tgal/Cutaway.jl/badges/main/coverage.svg)](https://git.km3net.de/tgal/Cutaway.jl/commits/main)

`Cutaway.jl` bundles a histogram with a list of cuts and fills one
filtered histogram per cut as you stream data through it. Cuts can be
applied independently (each cut on its own) or cumulatively (each cut on
top of all preceding ones).

## Installation

`Cutaway.jl` is not in the General registry but is available via the
[KM3NeT Julia registry](https://git.km3net.de/common/julia-registry):

    git clone https://git.km3net.de/common/julia-registry ~/.julia/registries/KM3NeT
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
[Independent cuts](https://tgal.pages.km3net.de/Cutaway.jl/dev/examples/independent_cuts/)
and
[Cumulative cuts](https://tgal.pages.km3net.de/Cutaway.jl/dev/examples/cumulative_cuts/).
