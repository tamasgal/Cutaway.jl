# Cumulative cuts

This example shows the cumulative variant of `CutHist`: the cuts are
treated as an ordered chain, and each per-cut histogram is filled only when
all preceding cuts also pass. This makes it easy to visualise the
incremental effect of stacking selections, without having to combine the
predicates by hand.

We reuse the same kind of synthetic event table as in the
[Independent cuts](@ref) example.

```@example cumulative
using Random, CSV, DataFrames

rng = MersenneTwister(42)
N = 20_000

df = DataFrame(
    zenith        = acos.(2 .* rand(rng, N) .- 1),
    likelihood    = 30 .+ 60 .* rand(rng, N),
    angular_error = 0.05 .+ 2.0 .* rand(rng, N) .^ 2,
    trigger_pct   = clamp.(0.2 .+ 0.6 .* randn(rng, N), 0, 1),
)

csvfile = tempname() * ".csv"
CSV.write(csvfile, df)
events = CSV.read(csvfile, DataFrame)
nothing # hide
```

The cuts list is the same as before, but we pass `cumulative = true`. With
this flag, `chist.hcuts[2]` collects events that pass cuts 1 and 2,
`chist.hcuts[3]` collects events that pass cuts 1, 2, and 3, and so on.
The labels are prefixed with `+` to reflect the chain.

```@example cumulative
using Cutaway, StatsBase

cuts = [
    Cut(r -> r.likelihood    > 50;    label = "likelihood > 50"),
    Cut(r -> r.angular_error < 0.5;   label = "+ angular error < 0.5 deg"),
    Cut(r -> r.trigger_pct   > 0.5;   label = "+ trigger fraction > 0.5"),
]

baseline = Histogram(range(-1, 1; length = 41))
chist = CutHist(baseline, cuts; cumulative = true)

for row in eachrow(events)
    push!(chist, cos(row.zenith), row)
end
chist
```

```@example cumulative
using CairoMakie

function step_hist!(ax, h::Histogram; kwargs...)
    edges = collect(h.edges[1])
    weights = Float64.(h.weights)
    stairs!(ax, edges, vcat(weights, last(weights)); step = :post, kwargs...)
end

fig = Figure(size = (720, 420))
ax = Axis(fig[1, 1]; xlabel = "cos(zenith)", ylabel = "events / bin")
step_hist!(ax, chist.h; label = "all events", color = :black, linewidth = 2)
for (cut, h) in zip(chist.cuts, chist.hcuts)
    step_hist!(ax, h; label = cut.label)
end
axislegend(ax; position = :lt)
fig
```

Each successive line drops below the previous one because the cuts are
combined automatically: every event that contributes to the third
histogram has, by construction, already passed the first two.
