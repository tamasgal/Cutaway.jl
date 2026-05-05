# Cutaway

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://tgal.pages.km3net.de/Cutaway.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://tgal.pages.km3net.de/Cutaway.jl/dev)
[![Build Status](https://git.km3net.de/tgal/Cutaway.jl/badges/main/pipeline.svg)](https://git.km3net.de/tgal/Cutaway.jl/pipelines)
[![Coverage](https://git.km3net.de/tgal/Cutaway.jl/badges/main/coverage.svg)](https://git.km3net.de/tgal/Cutaway.jl/commits/main)

Welcome to the `Cutaway.jl` repository!


## Documentation

Check out the **[Latest Documention](https://tgal.pages.km3net.de/Cutaway.jl/dev)**
which also includes tutorials and examples.


## Installation

`Cutaway.jl` is not an officially registered Julia package but it's available via
the [KM3NeT Julia registry](https://git.km3net.de/common/julia-registry). To add
the KM3NeT Julia registry to your local Julia registry list, follow the
instructions in its
[README](https://git.km3net.de/common/julia-registry#adding-the-registry) or simply do

    git clone https://git.km3net.de/common/julia-registry ~/.julia/registries/KM3NeT
    
After that, you can add `Cutaway.jl` just like any other Julia package:

    julia> import Pkg; Pkg.add("Cutaway")
    

## Quickstart

``` julia-repl
julia> using Cutaway
```
