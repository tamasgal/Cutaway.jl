module Cutaway

using StatsBase

export AbstractCut, Cut, CutHist, iscumulative

"""
    AbstractCut

Supertype for selection criteria. Concrete subtypes must be callable, taking
a single context (e.g. an event, a table row, or any user-defined record)
and returning a `Bool` that indicates whether the context passes the cut.

The bundled [`Cut`](@ref) type wraps an arbitrary predicate function and is
the recommended choice for ad-hoc cuts. To define a parameterised family of
cuts, subtype `AbstractCut` and add call methods that dispatch on the
context type.
"""
abstract type AbstractCut end

"""
    Cut(f; label="", description="")
    Cut(f, label, description="")

A cut backed by an arbitrary predicate `f(context) -> Bool`, optionally
annotated with a short `label` (used in plots and printouts) and a longer
`description`.

Both keyword and positional forms are accepted:

```julia
Cut(r -> r.likelihood > 50; label="likelihood > 50")
Cut(r -> r.likelihood > 50, "likelihood > 50")
```
"""
struct Cut <: AbstractCut
    f::Function
    label::AbstractString
    description::AbstractString

    function Cut(f; label::AbstractString="", description::AbstractString="")
        new(f, label, description)
    end
end

Cut(f, label::AbstractString, description::AbstractString="") =
    Cut(f; label=label, description=description)

(c::Cut)(context) = c.f(context)

"""
    CutHist(h::AbstractHistogram, cuts; cumulative=false)

Bundle a base histogram `h` with a list of `cuts` and one per-cut histogram
allocated as a `deepcopy` of `h`. A subsequent
[`push!(chist, x, context)`](@ref Base.push!(::CutHist, ::Any, ::Any))
always fills the base histogram with `x`, and additionally fills each
per-cut histogram according to whether the cuts pass when applied to
`context`.

When `cumulative=false` (the default), each cut is evaluated independently:
the per-cut histogram `hcuts[i]` is filled whenever `cuts[i](context)`
returns `true`.

When `cumulative=true`, the cuts are treated as an ordered chain. The loop
short-circuits on the first failing cut, so `hcuts[i]` only fills when all
of `cuts[1]`, `cuts[2]`, ..., `cuts[i]` pass. This is convenient for
visualising the cumulative effect of successive selections without having
to combine the predicates by hand.

The split between `x` (the value being histogrammed) and `context` (the
record the cuts inspect) lets cuts examine a richer object than the scalar
that ends up in the histogram.
"""
struct CutHist{H<:StatsBase.AbstractHistogram}
    h::H
    cuts::Vector{AbstractCut}
    hcuts::Vector{H}
    cumulative::Bool

    function CutHist(h::H, cuts::AbstractVector{<:AbstractCut};
                     cumulative::Bool=false) where H<:StatsBase.AbstractHistogram
        hcuts = [deepcopy(h) for _ in 1:length(cuts)]
        new{H}(h, AbstractCut[c for c in cuts], hcuts, cumulative)
    end
end

"""
    iscumulative(c::CutHist)

Return `true` if `c` applies its cuts as an ordered chain (each per-cut
histogram is filled only when all preceding cuts also pass), and `false` if
it evaluates each cut independently.
"""
iscumulative(c::CutHist) = c.cumulative

"""
    push!(chist::CutHist, x, context)

Add the value `x` to the base histogram of `chist`, and to each per-cut
histogram whose cut passes when applied to `context`. See [`CutHist`](@ref)
for the difference between the cumulative and independent semantics.
"""
function Base.push!(chist::CutHist, x, context)
    push!(chist.h, x)
    if iscumulative(chist)
        for idx in 1:length(chist.cuts)
            if chist.cuts[idx](context)
                push!(chist.hcuts[idx], x)
            else
                break
            end
        end
    else
        for (cut, h) in zip(chist.cuts, chist.hcuts)
            cut(context) || continue
            push!(h, x)
        end
    end
    chist
end

function Base.show(io::IO, c::CutHist)
    n = length(c.cuts)
    suffix = iscumulative(c) ? ", cumulative" : ""
    print(io, "CutHist($(n) cuts$(suffix))")
end

end
