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
    repo = Documenter.Remotes.GitHub("tamasgal", "Cutaway.jl"),
)

deploydocs(;
  repo = "github.com/tamasgal/Cutaway.jl",
  devbranch = "main",
  push_preview = true,
)
