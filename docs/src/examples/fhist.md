# Using FHist.jl as the histogram backend

[`FHist.jl`](https://github.com/Moelf/FHist.jl) provides a richer
histogram type (`Hist1D`, `Hist2D`, ...) than `StatsBase.Histogram`,
with first-class support for weighted entries, pulls, and Makie
plotting. Its `HistXD <: StatsBase.AbstractHistogram`, so it drops into
[`CutHist`](@ref) without any extra wiring.

The two main ergonomic wins compared to the
[Independent cuts](@ref) example are:

- `Hist1D(; binedges = ...)` constructs an empty, zero-filled histogram
  in one call, with named-argument binning.
- FHist ships Makie recipes, so `stairs!(ax, h)` plots a `Hist1D`
  directly - no helper around `stairs!(edges, weights)` needed.

We reuse the same synthetic event table as in the other examples.

```@example fhist
using Random, CSV, DataFrames

rng = MersenneTwister(42)
N = 20_000

df = DataFrame(
    zenith        = acos.(2 .* rand(rng, N) .- 1),
    likelihood    = 30 .+ 60 .* rand(rng, N),
    angular_error = 0.05 .+ 2.0 .* rand(rng, N) .^ 2,
    trigger_pct   = clamp.(0.2 .+ 0.6 .* randn(rng, N), 0, 1),
)
events = df
nothing # hide
```

The `CutHist` construction is the same as before; only the histogram
type changes.

```@example fhist
using Cutaway, FHist

cuts = [
    Cut(r -> r.likelihood    > 50;    label = "likelihood > 50"),
    Cut(r -> r.angular_error < 0.5;   label = "angular error < 0.5 deg"),
    Cut(r -> r.trigger_pct   > 0.5;   label = "trigger fraction > 0.5"),
]

baseline = Hist1D(; binedges = range(-1, 1; length = 41))
chist = CutHist(baseline, cuts)

for row in eachrow(events)
    push!(chist, cos(row.zenith), row)
end
chist
```

FHist exposes the underlying counts and edges through accessor
functions, which is handy for quick numerical checks alongside the
plot.

```@example fhist
(total = integral(chist.h),
 after_likelihood    = integral(chist.hcuts[1]),
 after_angular_error = integral(chist.hcuts[2]),
 after_trigger       = integral(chist.hcuts[3]))
```

Plotting is a direct call to Makie's `stairs!`, with no helper:

```@example fhist
using CairoMakie

fig = Figure(size = (720, 420))
ax = Axis(fig[1, 1]; xlabel = "cos(zenith)", ylabel = "events / bin")
stairs!(ax, chist.h; label = "all events", color = :black, linewidth = 2)
for (cut, h) in zip(chist.cuts, chist.hcuts)
    stairs!(ax, h; label = cut.label)
end
axislegend(ax; position = :lt)
fig
```

The same code works unchanged with `cumulative = true` to chain the
cuts (see [Cumulative cuts](@ref)).
