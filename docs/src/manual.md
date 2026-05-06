# Manual

## Defining cuts

A *cut* in `Cutaway.jl` is a callable that takes a single context (an
event, a table row, or any user-defined record) and returns a `Bool`
indicating whether the context passes the cut. The bundled
[`Cut`](@ref) type covers the common case: it wraps an arbitrary
predicate function and stores a short `label` and an optional longer
`description`.

```@example manual
using Cutaway

c = Cut(r -> r.likelihood > 50; label = "likelihood > 50")
c((likelihood = 73,))
```

The positional form `Cut(predicate, label[, description])` is also
accepted, which is convenient when defining a vector of cuts inline:

```@example manual
cuts = [
    Cut(r -> r.likelihood    > 50,   "likelihood > 50"),
    Cut(r -> r.angular_error < 0.5,  "angular error < 0.5 deg"),
]
```

Cuts are then bundled with a base histogram into a [`CutHist`](@ref).
On every `push!(chist, x, context)`, the value `x` is added to the base
histogram and to each per-cut histogram whose cut passes when applied to
`context`. The split between `x` (what gets histogrammed) and `context`
(what the cuts inspect) lets cuts examine a richer record than the
scalar that ends up in the histogram - typically `x` is a single derived
quantity and `context` is the full row or event.

```@example manual
using StatsBase

chist = CutHist(Histogram(range(0, 1; length = 21)), cuts)
push!(chist, 0.7, (likelihood = 73, angular_error = 0.2))
chist
```

See the [Independent cuts](@ref) and [Cumulative cuts](@ref) examples
for the difference between the two evaluation modes.

## Advanced cuts: parameterised cuts

The plain [`Cut`](@ref) wrapper is fine for one-off predicates, but it
gets awkward when:

- the same logic is reused with different parameters (e.g. several
  likelihood thresholds in the same analysis),
- the cut needs to act on different context types (e.g. a generic table
  row in some pipelines and a typed event struct in others),
- the parameters and metadata are interesting to inspect or print.

In those cases, define your own subtype of [`AbstractCut`](@ref). The
only requirement is that instances are callable and return a `Bool`.
Multiple call methods can dispatch on the context type so that the same
cut works across data representations.

```@example manual
using Cutaway

@enum CutOp GT GE LT LE

function _apply(op::CutOp, val, threshold)
    op === GT ? val >  threshold :
    op === GE ? val >= threshold :
    op === LT ? val <  threshold :
                val <= threshold
end

struct LikelihoodCut <: AbstractCut
    threshold::Float64
    op::CutOp
    label::String
    description::String
end

LikelihoodCut(threshold, op; label = "", description = "") =
    LikelihoodCut(threshold, op, label, description)
nothing # hide
```

A single shared helper applies the cut, and one short call method per
context type plugs it into the relevant data representation. Here we
show two: a generic table row that exposes a `likelihood` column, and a
hypothetical event struct that stores it under a different name.

```@example manual
struct Event
    lik::Float64
    zenith::Float64
end

(c::LikelihoodCut)(row)           = _apply(c.op, row.likelihood, c.threshold)
(c::LikelihoodCut)(event::Event)  = _apply(c.op, event.lik,      c.threshold)
nothing # hide
```

The cut now works on both representations without the call site having
to know which one is in use:

```@example manual
cut = LikelihoodCut(50.0, GT; label = "likelihood > 50")

cut((likelihood = 73.0,))      # generic row
```

```@example manual
cut(Event(73.0, 0.4))          # typed event
```

And, because `LikelihoodCut <: AbstractCut`, instances drop into a
[`CutHist`](@ref) exactly like a `Cut` does:

```@example manual
using StatsBase

chist = CutHist(
    Histogram(range(-1, 1; length = 21)),
    [LikelihoodCut(50.0, GT; label = "lik > 50")],
)
push!(chist, cos(0.4), Event(73.0, 0.4))
chist
```

A few practical notes:

- Keep a `label` field (and ideally a `description`) on every
  `AbstractCut` subtype. The example pages reach into `cut.label` to
  populate plot legends, and following the same convention keeps custom
  cuts plot-compatible.
- The dispatch pattern shown above scales: add another call method for
  every new context type you want to support (a database row, an HDF5
  group, a different event type, ...). The cut object stays the same;
  the new method makes it understand the new representation.
- For cuts that share a common shape (e.g. all "compare a single field
  to a threshold"), it is often worth factoring out a small helper such
  as `_apply` above so each new cut type is a thin wrapper over it.
