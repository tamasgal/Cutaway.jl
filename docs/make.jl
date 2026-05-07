using Documenter, Cutaway

makedocs(;
    modules = [Cutaway],
    sitename = "Cutaway.jl",
    authors = "Tamas Gal",
    format = Documenter.HTML(;
        assets = ["assets/custom.css"],
        sidebar_sitename = true,
        collapselevel = 2,
        warn_outdated = true,
    ),
    warnonly = [:missing_docs],
    pages = [
        "Home" => "index.md",
        "Manual" => "manual.md",
        "Examples" => Any[
            "examples/independent_cuts.md",
            "examples/cumulative_cuts.md",
            "examples/fhist.md",
        ],
        "API" => "api.md"
    ],
    repo = Documenter.Remotes.URL(
        "https://git.km3net.de/tgal/Cutaway.jl/blob/{commit}{path}#L{line}",
        "https://git.km3net.de/tgal/Cutaway.jl"
    ),
)

deploydocs(;
  repo = "git.km3net.de/tgal/Cutaway.jl",
  devbranch = "main",
  push_preview=true
)
